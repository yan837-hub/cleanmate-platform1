# CleanMate Platform — 系统逻辑全链路文档

> **用途**：作为漏洞分析、代码审查、功能对接和答辩参考时的"路线图"。所有类名、字段名、表名均与代码/数据库保持一致。
> **最后更新**：2026-05-25（补充：source 完整链路、Haversine 公式推导、状态机取消/改期修正、Q10-Q22 技术栈/JWT/索引/并发/创新点等全面答辩 Q&A）
> **技术栈**：Spring Boot 3.2.5 + MyBatis-Plus 3.5.7 + MySQL 8.0 + Vue 3 + Vite + Pinia + Element Plus

---

## 目录

1. [系统整体架构](#一系统整体架构)
2. [数据库设计 — 全量字段说明](#二数据库设计)
3. [核心链路①：下单与接单](#三核心链路一下单与接单)
4. [核心链路②：上门服务到结算](#四核心链路二上门到结算)
5. [评价系统全链路](#五评价系统全链路)
6. [投诉与售后全链路](#六投诉与售后全链路)
7. [服务过程照片系统](#七服务过程照片系统)
8. [图片上传通用机制](#八图片上传通用机制)
9. [重点难点防坑指南](#九重点难点防坑指南)（9.1~9.10）
   - 9.1 JWT 登录令牌机制
   - 9.2 订单状态机防错设计
   - 9.3 保洁员档期三层校验
   - 9.4 自动派单评分算法
   - 9.5 评价可见性与 avg_score 同步
   - 9.6 Haversine 球面距离公式（含推导）
   - 9.7 地址快照机制
   - 9.8 系统参数动态配置
   - 9.9 站内通知系统（12种类型）
   - **9.10 订单来源 source 完整链路**
10. [模拟答辩 Q&A](#十模拟答辩-qa)（Q1~Q22）
    - Q1~Q9：原有题目
    - Q10：技术栈选型
    - Q11：前后端通信链路
    - Q12：JWT 完整工作流程
    - Q13：CSRF / 密码存储
    - Q14：角色权限控制
    - Q15：MyBatis-Plus / 分页 / 自动填充
    - Q16：事务 / 通知容错设计
    - Q17：数据库索引设计
    - Q18：并发抢单乐观锁
    - Q19：定时任务清单
    - Q20：系统创新点
    - Q21：地址快照设计
    - Q22：外部接口鉴权

---

## 一、系统整体架构

### 大白话类比：这个系统就像一家"外卖平台"

| 角色 | 类比 | 在本系统中 |
|------|------|-----------|
| **顾客** | 点外卖的人 | 发布保洁需求、付定金/尾款、评价、投诉 |
| **保洁员** | 骑手/厨师 | 接单、打卡上门、提交完成、回复评价 |
| **管理员** | 平台运营人员 | 审核保洁员、派单、处理投诉、管理评价、查看数据 |

### 三层结构（前端 → 后端 → 数据库）

```
┌─────────────────────────────────────────────────────────────┐
│  【前端界面】Vue 3 + Element Plus                            │
│  浏览器/App界面，用户能看到、点到的所有按钮和页面            │
│  运行在用户的电脑浏览器上（端口 5173）                       │
└─────────────────────┬───────────────────────────────────────┘
                      │  HTTP请求（类比"服务员传菜单"）
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  【后端服务】Spring Boot 3.2.5（Java）                       │
│  "大厨"，接收请求、处理业务逻辑、决定做什么                  │
│  运行在服务器上（端口 8080，接口以 /api 开头）               │
└─────────────────────┬───────────────────────────────────────┘
                      │  SQL 查询（类比"去仓库取/存食材"）
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  【数据库】MySQL 8.0                                         │
│  "仓库"，永久保存所有数据（用户、订单、评价、投诉…）         │
│  数据库名：cleaning_service                                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 二、数据库设计

整个系统按功能分为以下几组表。

### 2.1 用户体系（4张表）

```
user（主表，所有角色都在这里）
  ├── cleaner_profile（保洁员扩展信息：avg_score、技能标签、常驻坐标）
  ├── customer_address（顾客服务地址，支持多地址管理，多对一）
  └── cleaning_company（所属保洁公司，保洁员多对一）
```

- `user.role`：1=顾客，2=保洁员，3=管理员
- `cleaner_profile.avg_score`：动态计算字段，每次评价提交/隐藏时自动重算（只统计 `is_visible=1` 的评价均值），直接影响自动派单优先级

### 2.2 服务与定价（2张表）

```
service_type（服务类型：日常清洁/深度清洁/家电清洗…）
service_price_tier（按面积分级定价明细，service_type 1:N）
```

**三种计费模式（`price_mode` 字段）：**

| `price_mode` | 含义 | 计算方式 |
|---|---|---|
| 1 | 按小时收费 | 实际时长（小时）× `hourly_price` |
| 2 | 按面积收费 | 按房屋面积落入哪个 `service_price_tier` 区间取单价 |
| 3 | 固定套餐价 | 直接取 `service_type.base_price` |

### 2.3 订单系统（3张表）— 核心

```
service_order（主订单表，最核心的表）
order_status_log（状态变更日志，每次变更写一条，完整追溯）
order_reschedule（改期申请记录）
```

**`service_order` 关键字段：**

| 字段 | 含义 |
|---|---|
| `order_no` | 订单号，格式 `CM` + 时间戳 + 4位随机数 |
| `status` | 当前状态（1~9，详见状态机） |
| `pay_status` | 支付状态（0=未支付，1=已付定金，2=已付全款） |
| `customer_id` | 下单顾客 |
| `cleaner_id` | 接单保洁员（为空=待接单） |
| `service_type_id` | 服务类型 |
| `address_id` | 顾客服务地址 ID |
| `address_snapshot` | 下单时地址的完整文本快照（防止事后改地址混乱） |
| `appoint_time` | 预约时间 |
| `estimate_fee` | 预估费用（下单时计算） |
| `actual_fee` | 实际费用（完工后计算） |
| `auto_confirm_at` | 自动确认时间（保洁员报完成后 +48 小时） |
| `completed_at` | 实际完成时间 |

### 2.4 档期与锁单系统（3张表）

```
cleaner_schedule_template（保洁员每周固定工作时间模板）
cleaner_schedule_override（特殊日期调整：请假/时间变更，优先级最高）
cleaner_time_lock（已被占用的时间段，防止一人同时接两单）
```

`cleaner_time_lock` 锁定范围 = 预约时间前 30 分钟 → 预约时间 + 服务时长 + 30 分钟（通勤缓冲，来自 `system_config`）。

### 2.5 财务系统（3张表）

```
fee_detail（费用明细：服务费、加班费、平台佣金、保洁员实际收入）
payment_record（支付流水：每次付款/退款各一条）
cleaner_income（保洁员收入账单，按月汇总）
```

`fee_detail` 关键字段：
- `service_fee`：基础服务费
- `overtime_fee`：超时加班费（按小时计费时才有）
- `commission_rate`：平台佣金比例（如 0.2000 = 20%，来自 `system_config`）
- `commission_fee`：平台佣金金额
- `cleaner_income`：保洁员实收 = service_fee × (1 - commission_rate)

### 2.6 评价、投诉与其他（8张表）

```
order_review（订单评价，含图片）
complaint（投诉与售后，含图片）
service_photo（保洁员拍摄的服务过程照片，分前/中/后三阶段）
dispatch_record（派单记录：谁被派了、方式、是否接受）
checkin_record（保洁员打卡记录：时间、GPS坐标、是否异常）
notification（站内消息通知，12种类型）
system_config（系统参数，无需重启即可生效）
operation_log（管理员操作日志）
```

#### `order_review` 完整字段

| 字段 | 类型 | 说明 |
|---|---|---|
| `order_id` | bigint | 订单ID（唯一索引，一单一评） |
| `customer_id` | bigint | 评价的顾客 user_id |
| `cleaner_id` | bigint | 被评的保洁员 user_id |
| `score_attitude` | tinyint | 服务态度评分（1~5） |
| `score_quality` | tinyint | 清洁效果评分（1~5） |
| `score_punctual` | tinyint | 准时程度评分（1~5） |
| `avg_score` | decimal | 综合评分（三项均值，自动计算） |
| `content` | varchar | 文字评价内容（可空） |
| `imgs` | varchar | **评价图片 URLs，逗号分隔，可空（最多3张）** |
| `is_visible` | tinyint | 是否可见：1=可见，0=已屏蔽 |
| `hide_reason` | varchar | 屏蔽原因（管理员填写） |
| `hidden_by` | bigint | 屏蔽操作的管理员 user_id |
| `reply_content` | varchar | 保洁员回复内容（可空） |
| `replied_at` | datetime | 保洁员回复时间 |

#### `complaint` 完整字段

| 字段 | 类型 | 说明 |
|---|---|---|
| `order_id` | bigint | 关联订单ID |
| `customer_id` | bigint | 投诉的顾客 user_id |
| `cleaner_id` | bigint | 被投诉的保洁员 user_id |
| `reason` | varchar | **投诉原因（必填）** |
| `imgs` | varchar | **投诉凭证照片 URLs，逗号分隔，可空（最多5张）** |
| `status` | tinyint | 1=待处理，2=处理中，3=已结案 |
| `result` | tinyint | 判定结果：1=全额退款，2=驳回，3=免费重做，4=部分退款 |
| `refund_amount` | decimal | 退款金额（result=4 时有值） |
| `admin_remark` | varchar | 管理员处理说明 |
| `handled_by` | bigint | 处理管理员 user_id |
| `handled_at` | datetime | 处理完成时间 |

#### `service_photo` 字段

| 字段 | 类型 | 说明 |
|---|---|---|
| `order_id` | bigint | 关联订单ID |
| `cleaner_id` | bigint | 上传的保洁员 user_id |
| `phase` | tinyint | 拍摄阶段：1=服务前，2=服务中，3=服务后 |
| `img_url` | varchar | 图片URL |
| `taken_at` | datetime | 拍摄时间 |
| `longitude` | decimal | 拍摄时GPS经度（可空） |
| `latitude` | decimal | 拍摄时GPS纬度（可空） |

---

## 三、核心链路一：下单与接单

### 完整流程图

```
顾客选择服务类型
      │
      ▼
[前端: Book.vue] 填写预约时间、地址、面积
      │ POST /api/customer/orders
      ▼
[后端: ServiceOrderServiceImpl.createOrder()]
      ├─ 校验服务类型是否正常上架
      ├─ 校验地址是否属于该顾客
      ├─ 计算预估费用（根据计费模式）
      ├─ 生成订单号："CM" + 时间戳 + 4位随机数
      ├─ 保存地址快照（防止事后改地址混乱）
      │
      ▼
[数据库] service_order 表新增一行（status=1, cleaner_id=空）
         order_status_log 新增记录（"顾客下单"）
         notification 推送通知给顾客
      │
      ▼
订单进入"待接单池"
      │
      ├───────────────────┬───────────────────┐
      ▼                   ▼                   ▼
【方式①：保洁员抢单】 【方式②：系统自动派单】 【方式③：管理员手动派单】
```

---

### 方式①：保洁员抢单（GrabPool 抢单池）

**大白话：** 就像滴滴打车，订单放在"抢单池"里，保洁员看到感兴趣的单子自己去抢。

**前端（GrabPool.vue）：**
- 每 30 秒自动刷新，拉取所有 `status=1` 的订单
- 距离（`distanceKm`）和预估收入（`estimatedIncome`）由**后端算好后直接返回**，前端只展示

> **距离是怎么算的？** 后端用保洁员在个人资料中设置的**常驻位置**（`cleaner_profile.longitude / latitude`），与订单服务地址坐标，用 Haversine 公式计算，并非实时设备 GPS。

**后端（grabOrder 方法）按顺序做了什么：**

```
Step 1: 校验订单状态仍为"待接单"（防止被别人同时抢走）
Step 2: 校验保洁员账号状态正常、审核已通过
Step 3: 档期三层校验（详见 9.3 节）
         ↓ 时间冲突 → 返回错误"您该时段已有订单"
Step 4: 全部通过 →
         service_order: cleaner_id=我的ID, status 1→3（直接跳过 status=2）
         dispatch_record: 新增记录（type=3 抢单，status=2 已接受）
         cleaner_time_lock: 锁定时段（预约时间前后各 +30 分钟通勤缓冲）
         order_status_log: 记录状态变化
         notification: 通知顾客"有保洁员接单了"
```

> **为什么抢单直接到 status=3？** 抢单是保洁员**主动选择**，无需等待确认。而系统/手动派单需要等保洁员确认，所以会经过 status=2（已派单待确认）这个中间状态。

---

### 方式②：系统自动派单（autoDispatch 算法）

**筛选流程（三层漏斗）：**

```
所有保洁员
      ▼ 第一层：账号资格筛选（状态正常 AND 审核通过）
      ▼ 第二层：档期校验（预约时段内有空）
      ▼ 第三层：距离筛选（与服务地址直线距离 ≤ 30km，可配置）
      ▼
合格候选人列表 → 对每人计算综合得分 → 选最高分
```

**综合评分公式：**

```
距离得分  = 1000 ÷ (距离km + 1) × 50%
评分得分  = 平均评分 × 20 × 30%
均衡得分  = 100 ÷ ln(近30天接单数 + 2) × 20%
──────────────────────────────────────────────
综合得分  = (距离得分 + 评分得分 + 均衡得分) × 时间可行系数
           （时间可行：正常=1.0；赶场来不及=0.5 惩罚）
```

**选出最高分后：**
- `service_order`: status 1→2（已派单待确认）
- `dispatch_record`: 新增（type=1 自动派单，status=1 等待响应，30 分钟过期）
- 通知保洁员：请在 30 分钟内确认接单

**保洁员确认/拒绝：**
- 确认 → dispatch_record.status=2，order.status 2→3，创建时间锁
- 拒绝/超时 → dispatch_record.status=3，order.status 2→1（**退回抢单池**）

---

## 四、核心链路二：上门到结算

```
保洁员接单（status=3: 已接单）
      │
      ▼ 保洁员到达现场后"打卡签到"
[后端: checkinOrder]
      ├─ 校验：必须在预约时间前 15 分钟到后 N 分钟内打卡
      ├─ GPS 校验（Haversine 公式）：
      │    ├─ ≤ 500 米：正常打卡 ✓
      │    └─ > 500 米：标记异常打卡，通知所有管理员，但不阻止服务继续！
      ├─ 写入 checkin_record
      ├─ service_order: status 3→4（服务中）
      └─ 通知顾客"保洁员已到达"
      │
      ▼ 服务中（status=4）：保洁员可上传服务过程照片
[后端: CleanerOrderController.uploadPhoto]
      ├─ POST /cleaner/orders/{orderId}/photos（multipart，携带 phase 参数）
      └─ 写入 service_photo（phase: 1=服务前，2=服务中，3=服务后）
      │
      ▼ 服务结束，保洁员提交实际用时
[后端: reportComplete]
      ├─ 计算实际费用（用实际时长，而非预估时长）
      │    ├─ 如果超时（按小时计费）：加收加班费
      │    └─ 计算平台佣金（默认 20%）和保洁员实收
      ├─ 写入 fee_detail（费用明细）
      ├─ 写入 cleaner_income（保洁员本月收入增加）
      ├─ service_order: status 4→5（待顾客确认）
      │    设置 auto_confirm_at = 当前时间 + 48 小时
      └─ 通知顾客"服务已完成，48 小时内未操作将自动确认"
      │
      ▼ 顾客确认 / 48 小时后系统自动确认（@Scheduled 定时扫描）
[后端: confirmComplete]
      └─ service_order: status 5→6（已完成），记录 completed_at
      │
      ▼ 顾客付尾款
[后端: payOrder]
      ├─ 写入 payment_record
      └─ service_order: pay_status 1→2（已付全款）
      │
      ▼ 顾客评价（条件：status=6 且 pay_status=2；或投诉已结案且非免费重做）
[后端: submitReview]
      ├─ 写入 order_review（三项评分 + 可选文字 + 可选图片）
      └─ 重新计算 cleaner_profile.avg_score（只统计 is_visible=1 的评价）
```

### 订单状态机完整图

```
顾客下单
  └─→ [1] PENDING_DISPATCH（待派单/待接单）
            ├─ 保洁员抢单 ──────────────────────→ [3] ACCEPTED（已接单）
            ├─ 系统/手动派单 → [2] DISPATCHED（已派单待确认）
            │                       ├─ 保洁员接受 → [3] ACCEPTED
            │                       └─ 拒绝/超时 → [1]（退回）
            └─ 改期中 → [9] RESCHEDULING → 保洁员同意/拒绝 → 均回到 [3]

[3] ACCEPTED → 打卡 → [4] IN_SERVICE（服务中）
[4] IN_SERVICE → 提交完成 → [5] PENDING_CONFIRM（待顾客确认）
[5] PENDING_CONFIRM → 确认/自动 → [6] COMPLETED（已完成）
[5] PENDING_CONFIRM → 拒绝确认发起投诉 → [7] AFTER_SALE（售后处理中）
[6] COMPLETED → 7天内发起投诉 → [7] AFTER_SALE
[7] AFTER_SALE → 管理员处理完 → [6] COMPLETED

取消规则：仅 [1][2][3] 可取消 → [8] CANCELLED（已取消）
         其中 [3] 已接单取消：必须距预约时间 > refund_deadline_hours（默认2小时），否则拒绝
改期规则：仅 [3] 已接单 → 申请改期 → [9] RESCHEDULING → 保洁员同意/拒绝 → 均回到 [3]
         且需距预约时间 > 120 分钟才可提交改期申请
```

每次状态变更都在 `order_status_log` 写一条记录（操作人、前状态、后状态、时间戳），出了问题可完整追溯，就像快递物流轨迹。

---

## 五、评价系统全链路

### 5.1 评价提交流程

```
条件：status=6（已完成）且 pay_status=2（已付全款）
     或：status=7（售后中）且投诉已结案（status=3）且非免费重做（result≠3）
      │
      ▼
[前端: customer/OrderDetail.vue] 评价弹窗
      ├─ 三项评分（各 1~5 星）：服务态度 / 清洁效果 / 准时程度
      ├─ 文字评价（选填，textarea）
      └─ 图片上传（选填，最多 3 张）
           ├─ el-upload → POST /api/common/upload → 返回图片 URL
           └─ 所有 URL 存入 reviewForm.imgs 数组
      │
      ▼
提交时：imgs 数组 join(',') 转字符串 → POST /api/customer/orders/{orderId}/review
      │
      ▼
[后端: CustomerOrderController.submitReview()]
      ├─ 权限校验：订单归属当前顾客
      ├─ 状态校验：canReview 逻辑（见上）
      ├─ 防重复：检查是否已存在 order_review
      ├─ 计算综合评分：avg_score = (态度 + 质量 + 准时) / 3.0
      ├─ 写入 order_review（imgs 为空白则存 null）
      └─ 重算 cleaner_profile.avg_score
           └─ 只统计该保洁员所有 is_visible=1 的评价均值
```

### 5.2 评价显示规则

| 查看者 | 可见范围 |
|---|---|
| 顾客自己 | 永远能看到自己写的评价（含图片） |
| 保洁员 | 只看到 `is_visible=1` 的评价（含图片）；管理员隐藏的看不到 |
| 管理员 | 看全部，可隐藏/恢复，需填写屏蔽原因 |

### 5.3 保洁员回复评价

- **入口：** Cleaner/Reviews.vue，每条可见评价下方有"回复"按钮
- **接口：** PUT /api/cleaner/reviews/{reviewId}/reply（`reply_content`、`replied_at` 字段）
- **限制：** 只能回复一次，回复后不可修改

### 5.4 管理员审核评价

- **接口列表：**
  - GET `/admin/reviews` — 分页列表，支持按可见状态筛选、关键词搜索
  - PUT `/admin/reviews/{id}/hide` — 屏蔽评价（需填 `hide_reason`）
  - PUT `/admin/reviews/{id}/show` — 恢复显示
- **屏蔽联动：** 屏蔽/恢复后，立即触发重算保洁员 `avg_score`
- **前端展示：** 管理员列表中直接展示评价图片（缩略图）

### 5.5 图片存储格式

- `order_review.imgs` 字段：逗号分隔的图片 URL 字符串
- 例如：`http://localhost:8080/api/files/img_abc.jpg,http://localhost:8080/api/files/img_def.jpg`
- 前端取用时：`imgs.split(',').filter(Boolean)` 得到 URL 数组后渲染 `<el-image>`

---

## 六、投诉与售后全链路

### 6.1 投诉提交流程

**两种触发时机：**

| 时机 | 订单状态 | 触发方式 |
|---|---|---|
| 拒绝确认完成 | status=5（待顾客确认） | 点击"拒绝确认/发起投诉"按钮 |
| 完成后售后 | status=6（已完成），**完成后7天内** | 点击"发起售后投诉"按钮 |

```
[前端: customer/OrderDetail.vue] 投诉弹窗
      ├─ 投诉原因（必填，textarea）
      └─ 凭证图片（选填，最多 5 张）
           ├─ el-upload → POST /api/common/upload → 返回图片 URL
           └─ 所有 URL 存入 complaintForm.imgs 数组
      │
      ▼
提交时：imgs 数组 join(',') 转字符串 → POST /api/customer/orders/{orderId}/complaint
      │
      ▼
[后端: CustomerOrderController.submitComplaint()]
      ├─ 权限校验：订单归属当前顾客
      ├─ 状态校验：status=5 或 (status=6 且在 completed_at 后 7 天内)
      ├─ 防重复：每个订单只能有一条投诉
      ├─ 写入 complaint 表（status=1 待处理）
      ├─ service_order: status → 7（售后处理中）
      └─ 通知所有管理员（role=3）新投诉告警
```

> **字段校验：** `reason` 必填（前端和后端均校验），`imgs` 选填（可以不上传图片）。

### 6.2 管理员处理投诉流程

```
[前端: admin/Complaints.vue]
      ├─ 列表：按状态筛选（待处理/处理中/已结案），支持关键词搜索
      ├─ 统计卡片：各状态数量
      └─ 详情抽屉：显示投诉信息、投诉图片、订单金额
      │
      ▼ 点击"处理"按钮
[处理弹窗]
      ├─ 更新状态：2（处理中）或 3（已结案）
      ├─ 若结案，必选判定结果：
      │    ├─ 1 = 全额退款
      │    ├─ 2 = 部分退款（需输入具体退款金额）
      │    ├─ 3 = 驳回投诉
      │    └─ 4 = 免费重做（需指定新预约时间）
      └─ 管理员备注（必填）
      │
      ▼ PUT /admin/complaints/{id}
```

### 6.3 四种结案结果的联动处理

**result=1（全额退款）：**
```
order.actual_fee = 0
order.status → 6（已完成）
fee_detail: service_fee=0, commission_fee=0, cleaner_income=0
payment_record: 新增退款流水
通知顾客"全额退款"
通知保洁员"本单收入已清零"
```

**result=2（部分退款）：**
```
order.actual_fee = original_actual_fee - refund_amount
order.status → 6（已完成）
fee_detail 按退款金额同步调整
payment_record: 新增部分退款流水
通知顾客"部分退款 ¥{refund_amount}"
```

**result=3（驳回投诉）：**
```
order.status → 6（已完成）
fee_detail 不变（保洁员收入不受影响）
通知顾客"投诉已驳回，服务质量认定无问题"
```

**result=4（免费重做）：**
```
order.status → 1（重回待派单）
order.cleaner_id = null（清除原保洁员）
order.appoint_time 可更新为 new_appoint_time
order.actual_fee = 0
清除原保洁员的 cleaner_time_lock
通知顾客"已安排免费重做，平台将重新为您派单"
通知原保洁员"本单收入清零"
```

### 6.4 投诉结案后的评价逻辑

| 投诉结果 | 是否允许评价 |
|---|---|
| result=1（全额退款） | ✓ 允许（投诉已结案且非免费重做） |
| result=2（部分退款） | ✓ 允许 |
| result=3（驳回） | ✓ 允许 |
| result=4（免费重做） | ✗ 不允许（订单重置为待派单，属新服务流程） |

---

## 七、服务过程照片系统

### 7.1 功能说明

保洁员在服务中（status=4）可上传三个阶段的服务照片，作为服务质量的客观记录。

```
上传入口：[前端: cleaner/OrderDetail.vue]（status=4 时显示上传区域）
      │
      ▼ 选择拍摄阶段（服务前/服务中/服务后）→ 选择图片文件
POST /api/cleaner/orders/{orderId}/photos?phase={1|2|3}
（multipart/form-data，文件字段名为 file）
      │
      ▼
[后端: CleanerOrderController.uploadPhoto()]
      ├─ 权限校验：订单归属当前保洁员
      ├─ 状态校验：只有 status=4（服务中）时才可上传
      ├─ 文件类型校验：jpg/jpeg/png/gif/webp
      ├─ 保存文件到服务器上传目录（生成唯一文件名）
      └─ 写入 service_photo 表（orderId、cleanerId、phase、imgUrl、takenAt）
```

### 7.2 三个拍摄阶段

| `phase` | 含义 | 用途 |
|---|---|---|
| 1 | 服务前 | 记录服务前的环境状况（防止纠纷） |
| 2 | 服务中 | 展示工作过程 |
| 3 | 服务后 | 展示清洁成果 |

### 7.3 查询接口

- GET `/api/cleaner/orders/{orderId}/photos` — 获取该订单所有照片，按 phase 和 taken_at 排序
- 顾客端和管理员端均可通过对应权限接口查看服务照片

---

## 八、图片上传通用机制

### 8.1 通用上传接口

**路径：** `POST /api/common/upload`（无需特定角色，登录即可访问）

```
请求：multipart/form-data，文件字段名为 "file"
校验：文件类型必须为 jpg/jpeg/png/gif/webp
处理：
      ├─ 生成唯一文件名：img_{UUID}.{ext}
      ├─ 保存到服务器配置的上传目录（${upload.path}）
      └─ 返回：Result<String>，data = 完整可访问的图片 URL
               格式：${upload.url-prefix}/img_{UUID}.{ext}
               例：http://localhost:8080/api/files/img_abc123.jpg
```

### 8.2 各场景图片上传规格汇总

| 场景 | 接口 | 数量限制 | 是否必填 |
|---|---|---|---|
| 评价图片 | `/api/common/upload` | 最多 3 张 | **选填** |
| 投诉凭证图片 | `/api/common/upload` | 最多 5 张 | **选填** |
| 服务过程照片 | `/api/cleaner/orders/{id}/photos` | 无上限，按 phase 存储 | **选填** |

### 8.3 图片 URL 的存储方式

- **评价/投诉：** 多张图片 URL 拼接成逗号分隔字符串，存入对应表的 `imgs` 字段
- **服务过程照片：** 每张照片单独一条 `service_photo` 记录，不拼接

### 8.4 前端上传组件模板

```vue
<el-upload
  action="/api/common/upload"
  :headers="{ Authorization: 'Bearer ' + getToken() }"
  list-type="picture-card"
  :limit="3"
  accept="image/*"
  :on-success="(res) => form.imgs.push(res.data)"
  :on-remove="(file) => form.imgs = form.imgs.filter(u => u !== file.response?.data)"
>
  <el-icon><Plus /></el-icon>
</el-upload>
```

---

## 九、重点难点防坑指南

### 9.1 JWT 登录令牌机制

**大白话类比：** JWT 就像游乐园的"手环"。进园时验身份发手环（JWT Token），之后去每个项目只看手环，手环 24 小时后自动失效。

**技术实现：**

1. **登录时（AuthController.login）：** 校验手机号 + 密码（BCrypt 比对）→ 生成 JWT（编码了用户ID、角色、手机号、过期时间）→ 前端存入 localStorage

2. **之后每次请求（JwtAuthenticationFilter）：** 前端请求头 `Authorization: Bearer xxxxx` → 后端拦截器验证签名和有效期 → 解析出用户 ID 和角色放入安全上下文

3. **权限控制（SecurityConfig）：**
   - `/customer/**` → 只有顾客（role=1）
   - `/cleaner/**` → 只有保洁员（role=2）
   - `/admin/**` → 只有管理员（role=3）
   - `/api/common/upload` → 登录用户均可

---

### 9.2 订单状态机防错设计

每个状态变更接口，第一步都是校验当前状态是否符合预期，不符合则抛出 `BusinessException(ErrorCode.ORDER_STATUS_ERROR)`，禁止跨状态跳跃。`@Transactional` 注解确保"校验+修改"是原子操作，防止并发漏洞。

---

### 9.3 保洁员档期三层校验

```
第一层：今天有没有特殊安排？（schedule_override 表，优先级最高）
        - 全天请假 → 直接不可用
        - 时间有调整 → 按调整后时间算
           ↓ 没有特殊设置
第二层：按固定周几排班有空吗？（schedule_template 表）
        - 预约时段在工作时间之外 → 不可用
           ↓ 在工作时间内
第三层：这个时段已被其他订单占用了吗？（cleaner_time_lock 表）
        - 时间段重叠 → 不可用
           ↓ 没有冲突
结论：可以接这单！
```

**30 分钟通勤缓冲：** 接了一单 10:00-12:00，系统锁住 **9:30-12:30**（前后各 +30 分钟），防止保洁员没有路上时间。30 分钟来自 `system_config.commute_buffer_minutes`，管理员可动态调整。

---

### 9.4 自动派单评分算法

**三个维度为什么缺一不可？**
- **只看距离：** 远的保洁员永远接不到单，不公平
- **只看评分：** 评分高的总是接单，疲惫后质量下降
- **均衡因子（ln 函数）：** 对数函数天然"边际递减"效果——从 0 单到 1 单差距大，从 99 到 100 几乎无影响，恰好模拟"越忙越少分配"

若找不到候选人（附近都有档期冲突），系统自动给所有管理员发告警通知，由人工介入手动派单。

---

### 9.5 评价可见性与 avg_score 同步

```
管理员隐藏评价
      ├─ order_review.is_visible = 0
      ├─ 记录 hide_reason 和 hidden_by（责任可追溯）
      └─ 立即重算 cleaner_profile.avg_score（只统计 is_visible=1 的均值）

管理员恢复评价
      ├─ order_review.is_visible = 1
      └─ 立即重算 cleaner_profile.avg_score

avg_score 影响：保洁员的评分得分（派单权重的 30%），隐藏差评会让评分变高
```

---

### 9.6 Haversine 地球球面距离公式

系统没有调用任何地图 API，而是用 **Haversine 球面距离公式** 纯数学计算，考虑了地球曲率。三处使用：
1. 自动派单：筛选 30 公里范围内的候选保洁员
2. 抢单池：展示各订单离保洁员的距离（km）
3. 打卡校验：判断保洁员是否到达顾客家附近（500 米判定）

**公式推导（代码在 `DistanceUtil.java`）：**

```
输入：两点经纬度 (lat1, lon1) 和 (lat2, lon2)，单位：度

Step 1. 转弧度差
  dLat = toRadians(lat2 - lat1)
  dLon = toRadians(lon2 - lon1)

Step 2. Haversine 中间量 a（球面三角核心）
  a = sin²(dLat/2)
    + cos(toRadians(lat1)) × cos(toRadians(lat2)) × sin²(dLon/2)

Step 3. 中心角 c（反正切）
  c = 2 × atan2(√a, √(1-a))

Step 4. 弧长 = 地球半径 × c
  距离(km) = 6371.0 × c
```

**为什么不直接用欧氏距离？**
经纬度坐标不是笛卡尔坐标，相差 1° 的实际距离随纬度变化：赤道约 111 km，高纬度处更短。Haversine 把球面弧长转换为真实公里数，城市范围内误差 < 0.1%，精度足够。

**代码实现：**
- `calculateKm()` → 返回 double，精确到小数点后2位
- `calculateMeters()` → 直接返回 `(int)(km × 1000)`，打卡场景用

---

### 9.7 地址快照机制

顾客下单时，系统将当时的完整地址信息（省市区详址、联系人、联系电话）序列化成字符串，存入 `service_order.address_snapshot`。即使顾客事后修改或删除地址，订单中的地址不变，保洁员不会跑错地方，历史查询也不会出现"地址不存在"的错误。

---

### 9.8 系统参数动态配置

`system_config` 表存储所有可调整的业务参数，**无需重启服务器即可生效**：

| 参数 Key | 默认值 | 含义 |
|---|---|---|
| `commission_rate` | 0.20 | 平台佣金比例（20%） |
| `commute_buffer_minutes` | 30 | 时间锁通勤缓冲（分钟） |
| `dispatch_timeout_minutes` | 30 | 派单响应超时时间（分钟） |
| `deposit_rate` | 0.20 | 定金比例（预估费的 20%） |
| `auto_confirm_hours` | 48 | 自动确认小时数 |
| `checkin_max_distance_m` | 500 | 打卡异常判定距离（米） |
| `cleaner_cancel_hours` | 4 | 保洁员最晚取消提前小时数 |

---

### 9.9 站内通知系统（12种类型）

> 通知写入用 `try { ... } catch (Exception ignored) {}` 包裹，**通知失败不影响主流程事务**。

`notification` 表的 `type` 字段枚举：

| type | 枚举名 | 触发场景 | 接收人 |
|---|---|---|---|
| 1 | ORDER_CREATED | 顾客下单成功 | 顾客 |
| 2 | ORDER_DISPATCHED | 系统/手动派单 | 保洁员 |
| 3 | CLEANER_CHECKIN | 保洁员打卡上门 | 顾客 |
| 4 | SERVICE_COMPLETED | 保洁员提交完成 | 顾客 |
| 5 | NEW_ORDER_GRAB | 新订单进入抢单池 | 保洁员（广播） |
| 6 | AUDIT_RESULT | 保洁员审核结果 | 保洁员 |
| 7 | COMPLAINT_NOTIFY | 新投诉提交 | **所有管理员** |
| 8 | TIMEOUT_ALERT | 自动派单无人接/打卡超时 | **所有管理员** |
| 9 | ORDER_REMINDER | 订单出行提醒（服务前 N 小时） | 保洁员 |
| 10 | RESCHEDULE_REQUEST | 顾客申请改期 | 对应保洁员 |
| 11 | RESCHEDULE_RESULT | 保洁员同意/拒绝改期 | 顾客 |
| 12 | ABNORMAL_CHECKIN | 保洁员打卡位置异常 | **所有管理员** |

---

---

### 9.10 订单来源（source）完整链路

#### 9.10.1 定义

`ServiceOrder.source` 是一个 `Integer` 字段，无枚举类，全靠约定数值：

| 值 | 含义 |
|---|---|
| 1 | 平台自有（顾客自己在前端下单） |
| 2 | 外部导入（模拟第三方平台推单，如"京东到家"） |
| 3 | 手动录入（管理员在后台填表录入） |

---

#### 9.10.2 source=1 完整链路

**谁触发：** 顾客在前端下单页面点"提交预约"

**前端（`order.js → createOrder(data)`）：**
```
POST /customer/orders
payload 里没有 source 字段（顾客不需要传）
```

**后端（`ServiceOrderServiceImpl.createOrder()`，第99行）：**
```java
order.setSource(1);   // 后端硬编码写 1
order.setLongitude(address.getLongitude());  // 坐标从顾客地址簿取
order.setLatitude(address.getLatitude());
```

订单号前缀：`CM`（例：`CM20250525143012_0321`）

流程：校验服务类型 → 校验地址归属 → 计算预估费用 → 保存快照 → 写状态日志 → 通知顾客 → **返回订单ID，不触发派单**

---

#### 9.10.3 source=2 完整链路

**谁触发：** 管理员在订单管理页点"模拟外部导入"按钮

**前端（`admin/Orders.vue`，`batchImport()`）：**
```
buildMockOrders()  // 本地构造4条随机订单
  - 随机重庆主城区地址 + 坐标（±0.08°偏移）
  - 随机手机号（randPhone）
  - 随机服务类型：日常/深度/开荒保洁
  - 平台来源随机：京东到家 / 美团到家
  - 预约时间：未来1~4天随机时段
循环调用 importExternalOrder(order)
  Header: X-Platform-Key: jd2home_mock_key
  POST /external/orders/import
```

**后端（`ExternalOrderController.importOrder()`）：**
```
校验 X-Platform-Key == "jd2home_mock_key"（硬编码，模拟API密钥鉴权，不走JWT）
  → orderService.importOrder(dto, source=2, operatorId=null)
```

**进入共用 `importOrder()` 方法（第1291行）：**
```
1. 按名称精确匹配服务类型
2. 按手机号找顾客 → 找不到就自动注册
   source==2 → nickname = "外部用户_XXXX"（尾4位手机号）
3. 计算预估费用（用 serviceType.minDuration）
4. 构建备注前缀 "[京东到家:JD1234] "
5. 解析预约时间
6. 订单号前缀：source==2 → "JD_"（例：JD_20250525143012_0321）
7. 保存订单，setSource(2)，坐标从dto取（前端已随机生成）
8. 写状态日志，remark="外部平台导入"
9. source==3 才写操作日志，source==2 跳过
10. CompletableFuture.runAsync(autoDispatch) 异步触发派单
```

---

#### 9.10.4 source=3 完整链路

**谁触发：** 管理员点"录入订单"按钮，填表提交

**前端（`admin/Orders.vue`，`submitManual()`）：**
```
校验必填：customerPhone、serviceTypeName、addressDetail、appointTime
longitude/latitude 选填，空则传 null
POST /admin/orders/manual-create（带JWT，走管理员权限）
```

**后端（`AdminOrderController.manualCreate()`）：**
```
从 Authentication 取 adminId
  → orderService.importOrder(dto, source=3, operatorId=adminId)
```

**同样进入 `importOrder()`：**
```
1~5. 同上
6. 订单号前缀："MANUAL_"
   source==3 → nickname = "用户_XXXX"（与外部"外部用户_XXXX"区分）
7. 保存订单，setSource(3)，坐标 = 管理员手填（可为null）
8. 写状态日志，remark="管理员手动录入"
9. source==3 额外写一条 OperationLog（记录哪个管理员操作）
10. 同样触发 CompletableFuture.runAsync(autoDispatch)
```

---

#### 9.10.5 三种来源汇合后

三种 source 创建的订单，落库后 `status=1`（待派单），**后续流程完全一样**。source 字段此后只用于：
- 管理后台订单列表的来源筛选
- `OrderVO.sourceLabel` 展示（平台自有 / 外部导入 / 手动录入）

**关键区别汇总：**

| 维度 | source=1 | source=2 | source=3 |
|------|----------|----------|----------|
| 谁操作 | 顾客自己 | 前端模拟第三方推单 | 管理员手动填表 |
| 鉴权方式 | JWT（顾客Token） | 固定平台密钥（X-Platform-Key） | JWT（管理员Token） |
| 创建入口 | `createOrder()` | `importOrder(dto, 2, null)` | `importOrder(dto, 3, adminId)` |
| 顾客账号 | 已登录顾客 | 按手机号自动注册 | 按手机号自动注册 |
| 坐标来源 | 顾客地址簿（精确） | 前端随机生成（±0.08°偏移） | 管理员手填（可为null） |
| 订单号前缀 | `CM` | `JD_` | `MANUAL_` |
| 操作日志 | 无 | 无 | 额外写一条 OperationLog |
| 派单触发 | 不触发，等管理员操作 | 异步自动派单 | 异步自动派单 |

---

## 十、模拟答辩 Q&A

### Q1：如何防止一个保洁员同时接两个时间冲突的订单？

> 系统设计了**时间锁（cleaner_time_lock）机制**。每当保洁员接受或抢到一个订单时，系统在 `cleaner_time_lock` 表中插入一条记录，锁定"预约时间前 30 分钟"到"预约时间加服务时长后 30 分钟"这整段时间（前后 30 分钟是通勤缓冲，来自系统参数表）。
>
> 在抢单/接单之前，后端先查询这张表检查是否有时间段重叠，有重叠直接返回错误。同时，接单操作用了 `@Transactional` 注解，"校验+写入"是原子事务，不存在并发导致两人同时通过检查的问题。

---

### Q2：如果顾客忘记确认服务完成，订单会一直挂着吗？

> 不会。系统设计了 **48 小时自动确认机制**。保洁员提交"服务完成"时，系统在 `service_order.auto_confirm_at` 记录"当前时间 + 48 小时"。后端有一个 `@Scheduled` 定时任务定期扫描，一旦超时且订单仍在"待确认"状态，自动改为"已完成"并通知顾客。48 小时这个值来自系统参数表，管理员可灵活调整，无需修改代码。

---

### Q3：登录安全是怎么保证的？

> 多层安全保护：
>
> **第一层：密码不明文存储。** BCrypt 哈希算法单向不可逆，且每次结果都不同（随机盐值），数据库泄露也无法反推原始密码。
>
> **第二层：JWT 令牌签名防篡改。** Token 用服务器私钥 HMAC-SHA256 签名，任何人修改内容后签名失效，后端拒绝请求。
>
> **第三层：Token 有效期。** 默认 24 小时过期，即使被截获，危险窗口有限。
>
> **第四层：角色权限隔离。** 顾客的 Token 调用 `/admin/**` 接口时，后端验证角色字段，直接拒绝。

---

### Q4：自动派单算法如何保证公平性？

> 派单算法有三个核心维度：**距离（50%）、用户评分（30%）、近期均衡度（20%）**，三者组合兼顾效率和公平。
>
> **均衡因子**最体现公平设计，使用 `100 / ln(近30天接单数 + 2)`。对数函数特点是：接单少的保洁员得分高（系统优先分配），但随接单量增加，得分递减越来越慢，防止"最忙的人永远不被新订单选中"的极端情况。
>
> 此外，算法还检测**时间可行性**：如果保洁员上一单结束后来不及赶到新地点，综合得分乘以 0.5 惩罚系数，保护保洁员权益也保障顾客体验。

---

### Q5：数据库有那么多张表，查询会不会很慢？

> 几个关键设计保证了查询性能：
>
> **第一，地址快照避免冗余 JOIN。** 地址在下单时序列化存入主订单表，查订单详情时不用联表查 `customer_address`。
>
> **第二，索引优化高频查询字段。** `service_order` 上的 `customer_id`、`cleaner_id`、`status` 都有索引，覆盖"查某顾客所有订单"、"查所有待接单订单"等最常用场景。
>
> **第三，业务层组装替代超级 SQL。** 订单详情 VO 在 Service 层做多次独立查询再拼装，比一个超级复杂的多表 JOIN 更易维护，也更好定位瓶颈。

---

### Q6：评价图片和投诉凭证照片是如何存储的？

> 系统采用了**本地文件存储 + URL 引用**的方案：
>
> 前端调用通用上传接口 `POST /api/common/upload`，后端将图片保存到服务器本地目录（路径来自配置文件，可部署时改为云存储），并返回可访问的 URL。
>
> 评价和投诉各自的 `imgs` 字段存储这些 URL，用**逗号分隔**（如 `url1,url2,url3`），展示时 `split(',')` 还原成数组渲染图片列表。这样的设计简单直接，适合毕业设计规模；如需上生产，只需把文件保存改接阿里云 OSS 等，数据库结构不需要变化。
>
> 评价图片最多 3 张，投诉凭证最多 5 张，均由前端 `el-upload` 的 `limit` 参数控制。

---

### Q7：投诉处理后，各种情况下保洁员和顾客各自发生了什么？

> 系统设计了四种结案结果，各自有明确的联动逻辑：
>
> - **全额退款：** 保洁员本单收入清零，顾客退回全款，订单标记已完成
> - **驳回投诉：** 保洁员收入不受影响，顾客投诉被否认，订单标记已完成
> - **免费重做：** 订单重置为"待派单"，原保洁员收入清零，平台重新为顾客安排保洁员上门服务
> - **部分退款：** 按管理员指定金额退款，保洁员收入相应扣减，订单标记已完成
>
> 每种结果都会通过站内通知告知顾客和保洁员处理结果，同时记录操作日志，责任可追溯。

---

---

### Q8：数据库的外键约束是怎么设计的？数据完整性如何保障？

> 本系统对外键约束做了**选择性使用**：核心的用户归属关系（如 `cleaner_profile.user_id`、`customer_address.user_id`、`service_order.customer_id`）保留了物理外键，防止产生孤儿数据；而高频写入的业务关联（如订单与保洁员、投诉与订单、派单记录等）没有设置物理外键，原因有两点：
>
> **第一，性能考虑。** 外键约束在每次插入、更新时触发级联检查，在高并发派单场景下会产生额外的行锁竞争，影响系统响应速度。
>
> **第二，操作灵活性。** 业务上存在软删除、状态标记、免费重做时清除保洁员等操作，物理外键在这些场景下会引发不必要的约束冲突。
>
> 无物理外键的关联，数据完整性由**三层应用层防护**保障：
>
> **第一层：Service 层写入前显式校验关联合法性。** 例如顾客下单前，后端先查询 `service_type` 确认服务类型存在且上架；保洁员注册时，先查询 `cleaning_company` 确认公司存在且状态正常；若关联数据不存在，直接抛出 `BusinessException`，不进行写入。
>
> ```java
> // 下单前校验服务类型
> ServiceType type = serviceTypeService.getById(dto.getServiceTypeId());
> if (type == null || type.getStatus() != 1)
>     throw new BusinessException("服务类型不存在或已下架");
>
> // 注册保洁员时校验公司
> CleaningCompany company = companyService.getById(dto.getCompanyId());
> if (company == null || company.getStatus() != 1)
>     throw new BusinessException(400, "所选公司不存在或已停用");
> ```
>
> **第二层：`@Transactional` 事务保证多表写入的原子性。** 注册时 `user` 表和 `cleaner_profile` 表同时写入，要么全部成功，要么全部回滚，不会出现用户建了但档案没建的半成功状态。
>
> **第三层：数据库唯一索引兜底。** 数据库层仍保留了 `uk_phone`（手机号唯一）、`uk_order_no`（订单号唯一）、`uk_order_id`（费用明细、评价等一单一条）等关键唯一索引，防止并发写入产生重复数据。
>
> 这也是目前互联网系统的主流做法，阿里巴巴《Java 开发手册》中明确建议不在数据库层使用外键约束，完整性由应用层保障。

---

### Q9：Service 层有些接口继承后什么都没写，是不是漏了？

> 没有漏，这是 MyBatis-Plus 的标准设计。`IService` 继承后自带 20+ 个基础方法（`save`、`removeById`、`updateById`、`getById`、`list`、`page`、`lambdaQuery` 等），空接口意味着这张表的所有操作用继承来的方法就够了，Controller 可以直接链式调用，无需额外编码。
>
> 扫描本项目 22 个 Service，分三类：
>
> **第一类：纯继承，接口和实现均为空（如 `IUserService`、`ICleanerProfileService`）**
> Controller 直接使用 `lambdaQuery()` 条件构造器完成增删改查，例如：
> ```java
> userService.lambdaQuery().eq(User::getRole, 1).eq(User::getStatus, status).page(new Page<>(current, size));
> userService.updateById(user);
> ```
> 这些调用全部来自 `IService`，Service 文件本身不需要任何代码。
>
> **第二类：有少量自定义方法（如 `INotificationService`）**
> 只声明了一个 `sendNotification()` 方法，实现里把几个字段组装成 `Notification` 对象后调用继承来的 `save()`，本质上仍是对基础方法的简单封装，避免在每个调用处重复拼装字段。
>
> **第三类：有完整业务逻辑（核心，如 `IServiceOrderService`、`ICleanerScheduleTemplateService`）**
> `IServiceOrderService` 定义了 15 个自定义方法，覆盖下单、抢单、派单、打卡、完工上报、自动确认等完整订单流程；`ICleanerScheduleTemplateService` 封装了档期三层校验（特殊调整 override → 周模板 template → 时间锁 time_lock）。这些复杂业务逻辑全部集中在 Service 层，Controller 只负责接收参数和返回结果，体现了职责分离原则。

---
>


---

### Q10：系统用了哪些技术，各自起什么作用？

> **后端核心：**
> - **Spring Boot 3.2.5**：Java 主框架，内嵌 Tomcat，约定大于配置，快速搭建 RESTful 服务
> - **Spring Security**：认证授权框架，管理 JWT 验证、角色权限拦截、密码加密
> - **MyBatis-Plus 3.5.7**：ORM 框架，内置通用 CRUD，Lambda 链式查询，分页插件自动加 LIMIT，避免手写大量 SQL
> - **MySQL 8.0**：关系型数据库，存储全部业务数据
> - **JJWT 0.12.5**：JWT 生成和解析库，`io.jsonwebtoken` 包
> - **Lombok**：注解生成 getter/setter/构造器，减少样板代码
> - **Hutool 5.8.27**：工具库，文件操作等
> - **Java 17**：使用 switch 表达式、文本块等新特性
>
> **前端核心：**
> - **Vue 3**：渐进式前端框架，组件化开发，响应式数据绑定
> - **Vue Router**：前端路由，实现 SPA 单页应用跳转，全局守卫做权限控制
> - **Pinia**：状态管理，存储全局登录用户信息（token、role）
> - **Axios**：HTTP 请求库，封装了请求拦截（自动加 Token）和响应拦截（统一错误处理）
> - **Element Plus**：UI 组件库，表格/表单/弹窗/上传等开箱即用
> - **Vite**：构建工具，开发时热更新快

---

### Q11：前后端是如何通信的？

> 前端用 **Axios** 发 HTTP 请求，后端用 **Spring Boot RESTful** 接口响应，数据格式统一 JSON。
>
> **完整链路：**
> ```
> 用户操作 → Vue 组件
>   → src/utils/request.js（Axios 封装）
>     → 请求拦截器：自动添加 "Authorization: Bearer <token>"
>       → 后端 Spring Security 过滤链
>         → JwtAuthenticationFilter：解析 Token，写入 SecurityContext
>           → Controller → Service → Mapper → MySQL
>             → 返回统一 Result<T> { code, message, data }
>               → 响应拦截器：code=200 返回 data；401 跳登录页
>                 → Vue 组件渲染
> ```
>
> **跨域（CORS）：** `SecurityConfig` 里配置 `CorsConfigurationSource`，允许所有 Origin 和请求头，开发阶段联调不受同源限制。
>
> **统一响应格式：**
> ```json
> { "code": 200, "message": "成功", "data": {...} }
> { "code": 1001, "message": "订单不存在", "data": null }
> { "code": 401, "message": "请先登录", "data": null }
> ```

---

### Q12：JWT 的完整工作流程是什么？

> **登录（生成 Token）：**
> 用户提交手机号+密码 → `AuthController` BCrypt 比对密码 → 生成 JWT（Payload 含 `userId`、`role`、过期时间）→ 返回前端 → 前端存 localStorage
>
> **每次请求（验证 Token）：**
> `JwtAuthenticationFilter`（`OncePerRequestFilter`）拦截每个请求：
> 1. 取 `Authorization` 请求头，截去 `"Bearer "` 前缀
> 2. `JwtUtil.isTokenValid()` 验签 + 过期检查
> 3. 解析 Claims，取出 `userId`（subject）和 `role`
> 4. 构造 `UsernamePasswordAuthenticationToken`，写入 `SecurityContextHolder`
> 5. Controller 通过 `Authentication auth` 取到 `(Long)auth.getPrincipal()` 即 userId
>
> **JWT 三段结构：** `Header.Payload.Signature`，用服务器密钥 HMAC-SHA256 签名，任何人修改 Payload 后签名失效，后端拒绝。
>
> **有效期：** 配置在 `application.yml` 的 `jwt.expiration`，Token 过期后需重新登录。

---

### Q13：为什么禁用了 CSRF 保护？密码怎么存储的？

> **CSRF 禁用原因：** `SecurityConfig` 里 `.csrf(AbstractHttpConfigurer::disable)`。CSRF 攻击利用的是浏览器自动携带 Cookie/Session，本项目用 JWT 放请求头（`Authorization`），浏览器不会自动携带，不存在 CSRF 攻击面，因此关闭。
>
> **密码存储：** BCrypt 算法（`PasswordEncoderFactories.createDelegatingPasswordEncoder()`）。BCrypt 特点：①单向不可逆；②每次加密结果不同（内置随机盐）；③数据库泄露也无法反推明文。数据库里存的是 `{bcrypt}$2a$10$...` 形式的哈希串。

---

### Q14：Spring Security 如何做角色权限控制？

> `SecurityConfig.securityFilterChain()` 中配置：
> ```java
> .requestMatchers("/admin/**").hasRole("ADMIN")       // role=3
> .requestMatchers("/cleaner/**").hasAnyRole("CLEANER","ADMIN")  // role=2
> .requestMatchers("/customer/**").hasAnyRole("CUSTOMER","ADMIN") // role=1
> ```
> 角色信息从 JWT 的 `role` 字段解析，转成 Spring Security 的 `GrantedAuthority`（`ROLE_ADMIN` 等）。
>
> **白名单（无需登录）：** `/auth/login`、`/auth/register`、`/public/**`、`/files/**`、`/external/**`（外部平台用 API 密钥鉴权，不走 JWT）。
>
> **前端路由权限：** `router/index.js` 全局 `beforeEach` 守卫做体验层防护，后端 Spring Security 做安全层防护，两者缺一不可。

---

### Q15：MyBatis-Plus 起什么作用？分页怎么实现的？

> **作用：** ORM 框架，内置 20+ 通用方法（`save`、`removeById`、`updateById`、`getById`、`list`、`page`、`lambdaQuery` 等），简单 CRUD 不用写 SQL，复杂查询用 `LambdaQueryWrapper` 链式构造，类型安全。
>
> **分页：** `MybatisPlusConfig` 注册 `PaginationInnerInterceptor`，拦截 SQL 自动追加 `LIMIT offset, size`，不用手写分页 SQL。统一用 `PageResult<T>` 包装返回（含 `total`、`current`、`size`、`records`）。
>
> **`created_at` / `updated_at` 自动填充：** `MyMetaObjectHandler` 实现 `MetaObjectHandler`，实体字段加 `@TableField(fill = FieldFill.INSERT)` 注解，insert 时自动填当前时间，update 时自动更新 `updated_at`，代码里不需要手动 `setCreatedAt(now)`。

---

### Q16：哪些地方用了事务？为什么通知失败不影响主流程？

> **事务：** 所有核心业务方法都加了 `@Transactional(rollbackFor = Exception.class)`：下单、抢单、签到、完工上报、自动派单、手动派单、取消订单等。保证多表写入要么全部成功，要么全部回滚，不会产生"订单保存了但状态日志没写"的半完成状态。
>
> **通知失败不影响主流程：** `notify()` 私有方法内部用了 `try { ... } catch (Exception ignored) {}`，把通知写入失败的异常吞掉，不向外层事务传播，确保通知功能的辅助性质不会破坏核心业务事务。这是一种有意识的"容错降级"设计。

---

### Q17：数据库索引是怎么设计的？

> **核心原则：查询频率高的字段建索引，写多读少的日志表少建索引，避免降低写入性能。**
>
> | 表 | 关键索引 | 解决什么查询 |
> |---|---|---|
> | `user` | `uk_phone` | 登录时按手机号查，唯一索引防重复注册 |
> | `user` | `idx_role_status(role, status)` | 派单时批量查 `WHERE role=2 AND status=1` 的保洁员，复合索引覆盖 |
> | `service_order` | `uk_order_no` | 按订单号全局唯一查 |
> | `service_order` | `idx_customer_id` | 顾客查自己订单列表 |
> | `service_order` | `idx_cleaner_id` | 保洁员查自己订单，派单时查其已有订单 |
> | `service_order` | `idx_status` | 定时任务批量扫描某状态订单 |
> | `service_order` | `idx_appoint_time` | 定时任务按预约时间扫超时订单 |
> | `cleaner_time_lock` | `idx_cleaner_id_time(cleaner_id, lock_start, lock_end)` | 档期冲突检查：`WHERE cleaner_id=? AND lock_start < ? AND lock_end > ?`，三列复合覆盖整个查询 |
> | `cleaner_income` | `idx_cleaner_settle(cleaner_id, settle_month)` | 保洁员按月查收入 |
> | `notification` | `idx_user_read(user_id, is_read)` | 查未读消息：`WHERE user_id=? AND is_read=0` |
> | `checkin_record` | `uk_order_id` | 一单只能签到一次，唯一索引防重复 |
> | `order_review` | `uk_order_id` | 一单只能评价一次，唯一索引防重复 |

---

### Q18：并发抢单是怎么保证只有一人成功的？

> 保洁员抢单时用 **MySQL 行级锁 + 条件更新**（乐观锁思路），代码在 `ServiceOrderServiceImpl.grabOrder()` 第178行：
>
> ```java
> boolean grabbed = this.lambdaUpdate()
>     .eq(ServiceOrder::getId, orderId)
>     .eq(ServiceOrder::getStatus, OrderStatus.PENDING_DISPATCH.getCode())  // 条件：必须还是待派单
>     .set(ServiceOrder::getCleanerId, cleanerId)
>     .set(ServiceOrder::getStatus, OrderStatus.ACCEPTED.getCode())
>     .update();
> if (!grabbed) throw new BusinessException("手慢了！该订单已被其他保洁员接单");
> ```
>
> 多人同时抢单时，MySQL 对满足 `WHERE id=? AND status=1` 的行加排它锁，只有一条 UPDATE 能成功修改，其余返回影响行数 0，后端抛出"手慢了"。整个方法加了 `@Transactional`，校验 + 写入是原子操作。

---

### Q19：定时任务有哪些，分别做什么？

> 系统有多个 `@Scheduled` 定时任务（在 `ScheduledTaskService` 类中）：
>
> | 任务 | 触发条件 | 逻辑 |
> |------|---------|------|
> | 派单超时回退 | 定期扫描 | 查 `dispatch_record.status=1 AND expire_at < now`，标记为超时，订单退回 status=1 |
> | 签到超时自动取消 | 定期扫描 | 查 `status=3 AND appoint_time < now-2h`，自动取消并通知管理员 |
> | 过期未接单自动取消 | 定期扫描 | 查 `status IN(1,2) AND appoint_time < now`，自动取消退款 |
> | 48h 自动确认 | 定期扫描 | 查 `status=5 AND auto_confirm_at < now`，自动完成并结算保洁员收入 |
> | 出行提醒推送 | 每10分钟 | 查预约时间在 [now+50min, now+70min] 的 status=3 订单，推送提醒给保洁员 |

---

### Q20：系统的创新点或亮点是什么？

> **1. 智能三维评分派单算法：** 距离（50%）+ 历史评分（30%）+ 均衡负载（20%）加权模型，结合时间可行性惩罚系数，比单一按距离派单更智能、更公平。
>
> **2. 档期三合一校验机制：** 周模板 + 特殊调整（override）+ 时段锁三层结构，优先级明确，既支持灵活的个人档期配置，又精确防止时间冲突。
>
> **3. 签到位置异常不阻断设计：** GPS 偏差超阈值时不直接拒绝签到，而是放行 + 异步通知管理员审查，避免 GPS 误差导致保洁员无法正常打卡，保留人工核查能力。
>
> **4. 多源订单统一管理：** `source` 字段区分平台自有/外部导入/手动录入，三种来源走统一订单流程，外部导入时自动创建顾客账号并异步触发派单。
>
> **5. 全参数可配置化：** 所有关键业务参数（派单半径、通勤缓冲、佣金比例、自动确认时间等）存 `system_config` 表，管理员后台实时修改无需重启。
>
> **6. 抢单并发乐观锁：** MySQL 行级锁保证多人抢单原子性，只有一人成功，其余得到明确拒绝。
>
> **7. 完整的订单状态追溯：** 每次状态变更写 `order_status_log`，记录操作人、前后状态、时间，出问题可完整追溯，类似快递物流轨迹。

---

### Q21：地址快照是什么设计，解决了什么问题？

> 顾客下单时，系统将当时的完整地址（省市区详址、联系人、联系电话）序列化成字符串存入 `service_order.address_snapshot`。即使顾客事后修改或删除地址，历史订单中的地址不变，保洁员不会跑错地方，历史查询也不会出现"地址不存在"的错误。这是**数据去规范化**的经典应用场景：用冗余存储换取历史数据稳定性。

---

### Q22：外部平台对接接口（`/external/**`）为什么不走 JWT？

> 外部平台是机器对机器（M2M）的调用，没有用户概念，无法登录获取 JWT。系统为此设计了独立的 API 密钥鉴权：`ExternalOrderController` 校验请求头 `X-Platform-Key` 是否等于约定的平台密钥（`jd2home_mock_key`），这是常见的第三方接口鉴权模式（类似短信平台的 AppKey）。`/external/**` 路径在 `SecurityConfig` 白名单中，绕过 Spring Security 的 JWT 过滤，但有独立的密钥校验，安全性由密钥保障。

---

*本文档基于 CleanMate 项目当前完整代码实现分析，最后更新：2026-05-25*
