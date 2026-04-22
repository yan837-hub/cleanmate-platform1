# CleanMate Platform — 系统逻辑全链路文档

> **用途**：作为漏洞分析、代码审查、功能对接和答辩参考时的"路线图"。所有类名、字段名、表名均与代码/数据库保持一致。
> **最后更新**：2026-04-22（更新：评价图片、投诉图片、服务照片、通知类型完整梳理）
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
9. [重点难点防坑指南](#九重点难点防坑指南)
10. [模拟答辩 Q&A](#十模拟答辩-qa)

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
  ├── customer_profile（顾客扩展信息）
  ├── cleaner_profile（保洁员扩展信息：avg_score、技能标签、常驻坐标）
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
- `service_fee`：服务费（≈ actual_fee）
- `overtime_fee`：超时加班费（按小时计费时才有）
- `commission`：平台佣金（默认 20%，来自 `system_config.commission_rate`）
- `cleaner_income_amount`：保洁员实收 = service_fee × (1 - commission_rate)

### 2.6 评价、投诉与其他（9张表）

```
order_review（订单评价，含图片）
complaint（投诉与售后，含图片）
service_photo（保洁员拍摄的服务过程照片，分前/中/后三阶段）
customer_address（顾客服务地址，支持多地址管理）
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
            └─ 改期中 → [9] RESCHEDULING → 确认后 → [1]

[3] ACCEPTED → 打卡 → [4] IN_SERVICE（服务中）
[4] IN_SERVICE → 提交完成 → [5] PENDING_CONFIRM（待顾客确认）
[5] PENDING_CONFIRM → 确认/自动 → [6] COMPLETED（已完成）
[5] PENDING_CONFIRM → 拒绝确认发起投诉 → [7] AFTER_SALE（售后处理中）
[6] COMPLETED → 7天内发起投诉 → [7] AFTER_SALE
[7] AFTER_SALE → 管理员处理完 → [6] COMPLETED

任何状态 → 取消 → [8] CANCELLED（已取消）
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
      │    ├─ 4 = 部分退款（需输入具体退款金额）
      │    ├─ 3 = 免费重做（需指定新预约时间）
      │    └─ 2 = 驳回投诉
      └─ 管理员备注（必填）
      │
      ▼ PUT /admin/complaints/{id}
```

### 6.3 四种结案结果的联动处理

**result=1（全额退款）：**
```
order.actual_fee = 0
order.status → 6（已完成）
fee_detail: service_fee=0, commission=0, cleaner_income_amount=0
payment_record: 新增退款流水
通知顾客"全额退款"
通知保洁员"本单收入已清零"
```

**result=2（驳回投诉）：**
```
order.status → 6（已完成）
fee_detail 不变（保洁员收入不受影响）
通知顾客"投诉已驳回，服务质量认定无问题"
```

**result=3（免费重做）：**
```
order.status → 1（重回待派单）
order.cleaner_id = null（清除原保洁员）
order.appoint_time 可更新为 new_appoint_time
order.actual_fee = 0
清除原保洁员的 cleaner_time_lock
通知顾客"已安排免费重做，平台将重新为您派单"
通知原保洁员"本单收入清零"
```

**result=4（部分退款）：**
```
order.actual_fee = original_actual_fee - refund_amount
order.status → 6（已完成）
fee_detail 按退款金额同步调整
payment_record: 新增部分退款流水
通知顾客"部分退款 ¥{refund_amount}"
```

### 6.4 投诉结案后的评价逻辑

| 投诉结果 | 是否允许评价 |
|---|---|
| result=1（全额退款） | ✓ 允许（投诉已结案且非免费重做） |
| result=2（驳回） | ✓ 允许 |
| result=3（免费重做） | ✗ 不允许（订单重置为待派单，属新服务流程） |
| result=4（部分退款） | ✓ 允许 |

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

*本文档基于 CleanMate 项目当前完整代码实现分析，最后更新：2026-04-22*
