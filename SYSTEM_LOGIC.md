# CleanMate Platform — 系统逻辑全链路文档

> **用途**：作为漏洞分析、代码审查和功能对接时的"路线图"。所有类名、字段名、表名均与代码/数据库保持一致。
> **生成日期**：2026-04-11（最后更新：补充评价管理模块）
> **技术栈**：Spring Boot 3.2.5 + MyBatis-Plus 3.5.7 + MySQL 8.0 + Vue 3 + Vite + Pinia + Element Plus

---


## 目录

1. [系统整体架构 —— 餐厅类比](#一系统整体架构)
2. [数据库设计 —— 仓库的抽屉们](#二数据库设计)
3. [核心功能链路①：顾客下单到保洁员接单](#三核心链路一下单与接单)
4. [核心功能链路②：上门服务到完成结算](#四核心链路二上门到结算)
5. [重点难点"防坑"指南](#五重点难点防坑指南)
6. [模拟答辩 Q&A](#六模拟答辩-qa)

---

## 一、系统整体架构

### 大白话类比：这个系统就像一家"外卖平台"

想象一家外卖平台（比如美团），里面有三种人：

| 角色 | 类比 | 在本系统中 |
|------|------|-----------|
| **顾客** | 点外卖的人 | 发布保洁需求、付钱、评价 |
| **保洁员** | 骑手/厨师 | 接单、上门服务、提交完成 |
| **管理员** | 平台运营人员 | 审核、派单、处理投诉、查看数据 |

### 三层结构（前端 → 后端 → 数据库）

```
┌─────────────────────────────────────────────────────────────┐
│  【前端界面】Vue 3 + Element Plus                            │
│  浏览器/App界面，用户能看到、点到的所有按钮和页面            │
│  运行在用户的电脑浏览器上（端口5173）                        │
└─────────────────────┬───────────────────────────────────────┘
                      │  HTTP请求（类比"服务员传菜单"）
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  【后端服务】Spring Boot 3.2.5（Java）                       │
│  "大厨"，接收请求、处理业务逻辑、决定做什么                  │
│  运行在服务器上（端口8080，接口以/api开头）                  │
└─────────────────────┬───────────────────────────────────────┘
                      │  SQL查询（类比"去仓库取/存食材"）
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  【数据库】MySQL 8.0                                         │
│  "仓库"，永久保存所有数据（用户、订单、评价...）             │
│  数据库名：cleaning_service，共24张表                        │
└─────────────────────────────────────────────────────────────┘
```

**前后端如何对话？** 前端通过 **HTTP接口（API）** 和后端通信，就像你用手机APP点餐，APP帮你把"我要一份宫保鸡丁"这个请求发到厨房，厨房做好了再把结果返回来。每一次用户点按钮，背后都是一次这样的"对话"。

---

## 二、数据库设计

### 大白话：数据库就是有格子的大仓库，每张"表"是一类抽屉

整个系统有 **24张表**，按功能分为6组：

### 2.1 用户体系（4张表）

```
user（主表，所有用户都在这里）
  ├── customer_profile（顾客扩展信息）
  ├── cleaner_profile（保洁员扩展信息：评分、技能、位置坐标）
  └── cleaning_company（所属保洁公司）
```

**关键设计：** 用一张 `user` 表管理所有角色，用 `role` 字段区分（1=顾客，2=保洁员，3=管理员）。保洁员比顾客多了"公司归属"、"身份证审核"、"平均评分"等字段，所以单独用 `cleaner_profile` 表存这些额外信息。

**类比：** 就像公司HR系统，员工表里有"普通员工"和"经理"，经理还有一个单独的"经理信息表"记录他管哪个部门。

### 2.2 服务与定价（2张表）

```
service_type（服务类型：日常清洁/深度清洁/家电清洗...）
service_price_tier（按面积分级定价明细）
```

**三种计费模式：**
- `price_mode=1` **按小时收费**：保洁时长 × 单价
- `price_mode=2` **按面积收费**：房屋面积 × 单价（不同面积段有不同单价，存在 `service_price_tier`）
- `price_mode=3` **固定套餐价**：直接取 `base_price`

### 2.3 订单系统（3张表）—— 核心

```
service_order（主订单表，最核心的表）
order_status_log（状态变更记录，每次状态改变都写一条，可追溯）
order_reschedule（改期申请记录）
```

**`service_order` 的关键字段：**
- `status`：订单当前状态（1~9，详见第三节）
- `cleaner_id`：为空时表示还没有保洁员接单
- `address_snapshot`：下单时的地址快照（防止顾客事后改地址造成混乱）
- `appoint_time`：预约时间
- `estimate_fee` / `actual_fee`：预估费用 / 实际费用

### 2.4 档期与锁单系统（3张表）

```
cleaner_schedule_template（保洁员每周工作时间模板）
cleaner_schedule_override（特殊日期调整，如某天请假）
cleaner_time_lock（已被占用的时间段，防止一人同时接两单）
```

**类比：** 就像理发师的预约系统。
- `template` = 固定工作时间（周一到周五 9:00-18:00）
- `override` = 某天特殊安排（周三下午请假）
- `time_lock` = 已经预约了的时间段（周二下午3点被占用了）

### 2.5 财务系统（3张表）

```
fee_detail（费用明细：服务费、加班费、平台佣金、保洁员实际收入）
payment_record（支付流水：每次付款都记一条）
cleaner_income（保洁员收入账单，按月结算）
```

### 2.6 其他（8张表）

```
customer_address（顾客服务地址，支持多地址管理）
dispatch_record（派单记录：谁被派了、什么方式、是否接受）
checkin_record（保洁员打卡记录：时间、GPS坐标、是否异常）
service_photo（服务过程照片：前/中/后三个阶段）
order_review（评价：态度分、质量分、准时分）
complaint（投诉与售后）
notification（站内消息通知）
system_config（系统参数配置，如佣金比例、派单超时时间，支持动态调整）
operation_log（管理员操作日志，记录谁改了什么）
```

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
      │
      ├─ 校验服务类型是否正常上架
      ├─ 校验地址是否属于该顾客
      ├─ 计算预估费用（根据计费模式）
      ├─ 生成订单号："CM" + 时间戳 + 4位随机数
      ├─ 保存地址快照（防止事后改地址）
      │
      ▼
[数据库] service_order 表新增一行（status=1, cleaner_id=空）
        order_status_log 新增记录（"顾客下单"）
        notification 推送通知给顾客
      │
      ▼
订单进入"待接单池"
      │
      ├──────────────────────┬──────────────────────┐
      │                      │                      │
      ▼                      ▼                      ▼
【方式①：保洁员抢单】  【方式②：系统自动派单】  【方式③：管理员手动派单】
```

---

### 方式①：保洁员抢单（Grab Pool 抢单池）

**大白话：** 就像滴滴打车，订单放在"抢单池"里，保洁员看到感兴趣的单子自己去抢。

**前端（GrabPool.vue）做了什么：**
- 每30秒自动刷新，拉取所有 `status=1` 的订单（只传分页参数，不传 GPS）
- 距离（`distanceKm`）和预估收入（`estimatedIncome`）由**后端算好后直接返回**，前端只负责展示
- 点"抢单"按钮后调用接口

> **距离是怎么算的？** 后端用保洁员在个人资料中设置的**常驻位置**（`cleaner_profile.longitude / latitude`），与订单服务地址坐标，用 Haversine 公式计算得出，并非实时设备 GPS。

**后端（grabOrder方法）按顺序做了什么：**

```
Step 1: 校验订单状态是否仍为"待接单"（防止被别人同时抢走）
Step 2: 校验保洁员账号状态正常、审核已通过
Step 3: 档期三层校验（详见五-3节）
         ↓ 如果时间冲突 → 返回错误"您该时段已有订单"
Step 4: 全部通过 →
         service_order: cleaner_id=我的ID, status=1→3（直接跳过status=2）
         dispatch_record: 新增记录（type=3抢单, status=2已接受）
         cleaner_time_lock: 锁定时间段（预约时间前后各+30分钟通勤缓冲）
         order_status_log: 记录状态变化
         notification: 通知顾客"有保洁员接单了"
```

**关键细节 —— 为什么抢单可以直接到 status=3？**
> 因为抢单是保洁员**主动选择**，不存在"不确定是否接受"的中间状态。而系统派单/手动派单需要等保洁员确认，所以会经过 status=2（已派单待确认）这个中间状态。

---

### 方式②：系统自动派单（autoDispatch算法）

**大白话：** 就像算法给外卖订单分配最合适的骑手——不是随机的，而是按照"距离近、评分高、最近不太忙"三个维度综合打分，选最高分的那个人。

**筛选流程（三层漏斗）：**

```
所有保洁员
      │
      ▼ 第一层：账号资格筛选
      │  账号状态=正常 AND 审核状态=已通过
      ▼ 第二层：档期校验
      │  预约时间段内有空（没有假期/没有时间冲突）
      ▼ 第三层：距离筛选
      │  与服务地址的直线距离 ≤ 30公里（可配置）
      ▼
合格候选人列表 → 对每人计算综合分数 → 选最高分
```

**综合评分公式：**

```
距离得分  = 1000 ÷ (距离km + 1) × 50%     → 越近越高
评分得分  = 平均评分 × 20 × 30%            → 评价越好越高
均衡得分  = 100 ÷ ln(近30天接单数+2) × 20% → 最近接单越少越高（防止一人独占）
─────────────────────────────────────────────────────────
综合得分  = (距离得分 + 评分得分 + 均衡得分) × 时间可行系数
           （时间可行：正常=1.0；赶场来不及=0.5 惩罚）
```

**选出最高分后：**
- `service_order`: status=1→2（已派单待确认）
- `dispatch_record`: 新增记录（type=1自动派单，status=1等待响应，30分钟过期）
- 通知保洁员：请在30分钟内确认接单

**保洁员确认/拒绝：**
- 确认 → dispatch_record.status=2，order.status=2→3，创建时间锁
- 拒绝/超时 → dispatch_record.status=3，order.status=2→1（**退回抢单池**）

---

## 四、核心链路二：上门到结算

### 完整流程

```
保洁员接单（status=3: 已接单）
      │
      ▼ 保洁员到达现场后"打卡签到"
[后端: checkinOrder]
      ├─ 校验：必须在预约时间前15分钟到后N分钟内打卡
      ├─ GPS校验：计算打卡坐标与服务地址的距离（Haversine球面公式）
      │    ├─ ≤500米：正常打卡 ✓
      │    └─ >500米：标记为"异常打卡"，通知所有管理员，但不阻止服务继续！
      ├─ 写入 checkin_record
      ├─ service_order: status=3→4（服务中）
      └─ 通知顾客"保洁员已到达"
      │
      ▼ 服务结束，保洁员提交实际用时
[后端: reportComplete]
      ├─ 计算实际费用（用实际时长，不是预估时长）
      │    ├─ 如果超时（按小时计费）：加收加班费
      │    └─ 计算平台佣金（默认20%）和保洁员实际收入
      ├─ 写入 fee_detail（费用明细）
      ├─ 写入 cleaner_income（保洁员本月收入增加）
      ├─ service_order: status=4→5（待顾客确认）
      │    设置"自动确认时间"= 当前时间 + 48小时
      └─ 通知顾客"服务已完成，48小时内未操作将自动确认"
      │
      ▼ 顾客确认 / 48小时后系统自动确认
[后端: confirmComplete]
      └─ service_order: status=5→6（已完成），记录 completed_at
      │
      ▼ 顾客付尾款
[后端: payOrder]
      ├─ 写入 payment_record
      └─ service_order: pay_status=1→2（已付全款）
      │
      ▼ 顾客评价（条件：status=6 且 已付全款）
[后端: submitReview]
      ├─ 写入 order_review（三项评分，is_visible=1）
      └─ 重新计算 cleaner_profile.avg_score（所有可见评价的均值）
```

### 特殊情况：投诉与售后（status=7）

```
顾客在 status=5（待确认）时发起投诉
  或在 status=6（已完成）后7天内发起投诉
      │
      ▼
service_order: status→7（售后中），写入 complaint 表
      │
      ▼ 管理员处理
      ├─ result=1：全额退款 → order.status→6
      ├─ result=2：拒绝投诉 → order.status→6
      ├─ result=3：免费返工 → 重新安排保洁员上门
      └─ result=4：部分退款 → 退部分金额，order.status→6
```

---

## 五、重点难点"防坑"指南

### 5.1 JWT登录令牌机制

**大白话类比：** JWT就像游乐园的"手环"。

- 进园时买票验身份（**登录**），工作人员给你套上手环（**JWT Token**）
- 之后你去每个游乐项目，工作人员只看手环是否有效，不用再问你叫什么名字
- 手环24小时后自动失效，需要重新登录

**技术实现：**

1. **登录时（AuthController.login）：**
   - 校验手机号 + 密码（BCrypt比对）
   - 用密钥生成JWT字符串，里面编码了：用户ID、角色、手机号、过期时间
   - 把Token返回给前端，前端存储在 localStorage 中

2. **之后每次请求（JwtAuthenticationFilter）：**
   - 前端在请求头带上：`Authorization: Bearer xxxxx`
   - 后端拦截器提取Token → 验证签名和有效期 → 解析出用户ID和角色
   - 把用户信息放入"安全上下文"，后续代码直接取用

3. **权限控制（SecurityConfig）：**
   - `/customer/**` → 只有顾客能访问
   - `/cleaner/**` → 只有保洁员能访问
   - `/admin/**` → 只有管理员能访问
   - `/auth/login` 等 → 无需登录（白名单）

**为什么不用传统 Session？**
> JWT 是**无状态的**，服务器不需要存储用户会话，适合分布式部署。Token本身携带了所有必要信息，任何一台服务器都能验证，扩展性更强。

---

### 5.2 订单状态机

**大白话：** 状态机就像红绿灯系统，规定了"什么状态下可以做什么操作，做完变成什么状态"，不能随意跳跃。

```
1 - 待接单/待派单
      ├→（抢单）→ 3 - 已接单
      └→（派单）→ 2 - 已派单待确认
                        ├→（接受）→ 3 - 已接单
                        └→（拒绝/超时）→ 1

3 - 已接单 →（打卡）→ 4 - 服务中
4 - 服务中 →（提交完成）→ 5 - 待顾客确认
5 - 待顾客确认 →（确认/自动）→ 6 - 已完成
              └→（投诉）→ 7 - 售后中 →（处理完）→ 6

任何状态 → 8（已取消）
状态3 → 9（改期中）→ 1（重新待派）
```

**每次状态变更都会在 `order_status_log` 写一条记录**（操作人、前状态、后状态、时间），出了问题可以完整追溯，就像快递的物流轨迹。

---

### 5.3 保洁员档期三层校验

**大白话：** 给保洁员排班时，按三个层次检查他是否有空：

```
第一层：今天有没有特殊安排？（schedule_override表，优先级最高）
        - 今天全天请假 → 直接不行
        - 今天时间有调整 → 按调整后的时间算
           ↓ 今天没有特殊设置
第二层：按固定周几排班有空吗？（schedule_template表）
        - 预约时段在工作时间之外 → 不行
           ↓ 在工作时间内
第三层：这个时段已经被其他订单占用了吗？（time_lock表）
        - 时间段重叠 → 不行
           ↓ 没有冲突
结论：可以接这单！
```

**30分钟通勤缓冲的设计：**
> 接了一单 10:00-12:00，系统会锁住 **9:30-12:30**（前后各+30分钟）。防止保洁员接完一单立刻要赶去另一单，连路上时间都没有。这个30分钟是从 `system_config` 表读取的，管理员可以动态调整。

---

### 5.4 自动派单评分算法

**三个维度为什么缺一不可？**
- **只看距离**：远的保洁员永远接不到单，不公平
- **只看评分**：评分高的总是接单，疲惫后服务质量下降
- **均衡因子（ln函数）**：对数函数天然有"边际递减"效果——从0单到1单差距大，从99单到100单几乎无影响，恰好模拟了"越忙越少分配"的合理逻辑

**总结：这个算法保证了"好而近且最近不太忙"的保洁员优先接单，同时防止接单量严重向少数人倾斜。**

---

### 5.5 评价系统与管理员审核

**评价的可见性控制逻辑：**

```
顾客提交评价 → is_visible=1（默认可见）
      │
      ├─ 顾客自己：永远能看到自己的评价
      ├─ 保洁员：只看到 is_visible=1 的（管理员隐藏的看不到）
      └─ 管理员：看全部，可以隐藏/恢复

管理员隐藏评价时：
      ├─ is_visible=0
      ├─ 记录 hide_reason 和 hidden_by（责任可追溯）
      └─ 重新计算保洁员平均分（只统计 is_visible=1 的评价）
```

**三项评分设计的意义：**
- `score_attitude`（服务态度）：保洁员是否礼貌
- `score_quality`（服务质量）：打扫效果好不好
- `score_punctual`（准时程度）：是否按时到达
- 三项平均值自动存入 `order_review.avg_score`
- 保洁员档案的 `avg_score` = 所有可见评价的综合均值，影响派单优先级

---

### 5.6 地理距离计算（Haversine公式）

**大白话：** 系统需要知道保洁员和顾客家之间的真实直线距离，用于：
1. 自动派单时筛选30公里范围内的候选人
2. 抢单池中展示各订单离保洁员的距离
3. 打卡时判断保洁员是否真的到了顾客家附近（500米判定）

系统没有调用任何地图API，而是用 **Haversine球面距离公式** 纯数学计算。这个公式考虑了地球是球形的因素，比简单的勾股定理更精确。

---

### 5.7 地址快照机制

**大白话类比：** 就像网购时"生成订单后地址就固定了"。

顾客下单时，系统会把当时的完整地址信息（省市区详址、联系人、联系电话）序列化成一段文字，存入 `service_order.address_snapshot` 字段。

**为什么要这样做？**
> 如果顾客下单后修改或删除了这个地址，订单里还是记着当时的地址，保洁员不会跑错地方；查历史订单时也能看到当时的真实地址，不会出现"地址不存在"的错误。

---

### 5.8 系统参数动态配置

`system_config` 表中存储了所有可调整的业务参数，**无需重启服务器即可生效**：

| 参数Key | 默认值 | 含义 |
|---------|--------|------|
| commission_rate | 0.20 | 平台佣金比例（20%） |
| commute_buffer_minutes | 30 | 时间锁通勤缓冲（分钟） |
| dispatch_timeout_minutes | 30 | 派单响应超时时间 |
| deposit_rate | 0.20 | 定金比例（预估费的20%） |
| auto_confirm_hours | 48 | 自动确认小时数 |
| checkin_max_distance_m | 500 | 打卡异常判定距离（米） |
| cleaner_cancel_hours | 4 | 保洁员最晚取消提前小时数 |

---

## 六、模拟答辩 Q&A

---

### Q1：你的系统是如何防止一个保洁员同时接两个时间冲突的订单的？

**回答口径：**

> 我的系统设计了**时间锁（cleaner_time_lock）机制**。每当保洁员接受或抢到一个订单时，系统会在 `cleaner_time_lock` 表里插入一条记录，锁定从"预约时间前30分钟"到"预约时间加服务时长后30分钟"这整段时间。前后30分钟是通勤缓冲时间，来自系统参数表，管理员可以动态调整。
>
> 在保洁员抢单或接单之前，后端会先查询这张表，检查是否有时间段重叠。如果有重叠，直接返回错误"您该时段已有订单，无法接单"。同时，接单操作用了 `@Transactional` 注解，整个检查+写入是一个原子事务，不存在并发导致的"两人同时通过检查"的问题。

---

### Q2：如果顾客忘记确认服务完成，订单会一直挂着吗？

**回答口径：**

> 不会。系统设计了**48小时自动确认机制**。保洁员提交"服务完成"时，系统会在 `service_order` 的 `auto_confirm_at` 字段记录"当前时间+48小时"。后端有一个定时任务（Spring的 `@Scheduled`）定期扫描，一旦超过该时间且订单仍在"待确认"状态，自动将状态改为"已完成"并通知顾客。
>
> 这个设计参考了主流电商平台（如淘宝）的自动收货逻辑，48小时这个数值也是从系统参数表读取的，可以由管理员灵活调整，而不需要修改代码。

---

### Q3：你的登录安全是怎么保证的？如果黑客截获了Token怎么办？

**回答口径：**

> 系统采取了多层安全保护：
>
> **第一层：密码不明文存储。** 用户密码注册时用 **BCrypt哈希算法** 加密后存入数据库。BCrypt的特点是单向不可逆，且每次加密结果都不同（加了随机盐值），即使数据库泄露也无法反推原始密码。
>
> **第二层：JWT令牌签名防篡改。** Token使用服务器私钥签名（HMAC-SHA256），任何人修改Token内容后签名会失效，后端会拒绝请求。
>
> **第三层：Token有效期。** Token默认24小时过期，即使被截获，危险窗口有限。生产环境配合HTTPS传输可进一步防止中间人攻击。
>
> **第四层：角色权限隔离。** 即使有了Token，访问 `/admin/**` 接口时，后端还会验证Token中的角色是否为管理员，顾客的Token无法调用管理员接口，做到了最小权限原则。

---

### Q4：系统的自动派单算法，你是怎么保证公平性的？

**回答口径：**

> 我的派单算法有三个核心维度：**距离（权重50%）、用户评分（30%）、近期订单均衡度（20%）**，三者组合兼顾了效率和公平性。
>
> **均衡因子**是最体现公平设计的地方，使用了 `100 / ln(近30天接单数 + 2)` 这个公式。对数函数的特点是：接单少的保洁员得分高（系统优先分配给他），但随着接单量增加，得分递减会越来越慢，防止"接单最多的人永远不被新订单选中"的极端情况，也防止"最忙的人越来越忙"的马太效应。
>
> 此外，算法还检测**时间可行性**：如果保洁员上一单结束后来不及赶到新地点，综合得分乘以0.5的惩罚系数，既保护了保洁员的合理权益，也保障了顾客的服务质量。
>
> 如果算法找不到合适的候选人（比如附近保洁员都有档期冲突），系统会自动给所有管理员发送告警通知，由人工介入手动处理，做到了自动化与人工兜底的结合。

---

### Q5：你的数据库有那么多张表，查询订单详情时会不会很慢？

**回答口径：**

> 这是个很好的性能问题。我在设计上有几个考量：
>
> **第一，地址快照避免了冗余JOIN。** 顾客地址详情在下单时就序列化成字符串存入主订单表，查询订单详情时不需要再联表查 `customer_address`，减少一次JOIN的同时还保证了历史数据的完整性。
>
> **第二，索引优化高频查询字段。** `service_order` 上的 `customer_id`、`cleaner_id`、`status` 字段都建有索引，这是最常用的筛选条件（如"查某个顾客的所有订单"、"查所有待接单订单"），索引可以大幅提升查询速度，从全表扫描变成索引查找。
>
> **第三，业务层组装替代超级SQL。** 订单详情视图（OrderVO）需要拼接多项信息，采用在Service层做多次独立查询再拼装的方式，比一个超级复杂的多表JOIN更易维护，也更好定位性能瓶颈。
>
> 在本系统的规模（毕业设计阶段）下，这些设计已经足够满足性能要求。如果未来数据量增大，还可以引入缓存（如Redis）对高频读取的订单详情进行缓存优化。

---

*本答辩文档基于 CleanMate 项目当前完整代码实现分析，生成于 2026-04-16*

---

## 目录

1. [核心业务图谱](#1-核心业务图谱)
2. [功能模块索引](#2-功能模块索引)
3. [关键操作数据流](#3-关键操作数据流)（含3.7评价全链路、3.8档期校验）
4. [数据库字典](#4-数据库字典)
5. [技术实现亮点](#5-技术实现亮点)

---

## 1. 核心业务图谱

### 1.1 实体关系总览

```
User (用户账户)
 ├── role=1 → CustomerProfile (顾客档案, 1:1)
 │              └── CustomerAddress (收货地址, 1:N)
 ├── role=2 → CleanerProfile (保洁员档案, 1:1)
 │              ├── CleaningCompany (所属公司, N:1)
 │              ├── CleanerScheduleTemplate (固定档期模板, 1:N)
 │              ├── CleanerScheduleOverride (特殊日期调整, 1:N)
 │              └── CleanerTimeLock (时段锁定, 1:N)
 └── role=3 → 管理员（无专属档案表）

ServiceType (服务类型)
 └── ServicePriceTier (面积分级定价, 1:N)

ServiceOrder (服务订单) ← 核心枢纽
 ├── FK customer_id → User
 ├── FK cleaner_id  → User
 ├── FK service_type_id → ServiceType
 ├── FK address_id  → CustomerAddress
 ├── OrderStatusLog (状态变更日志, 1:N)
 ├── DispatchRecord (派单记录, 1:N)
 ├── CleanerTimeLock (时段锁定, 1:1)
 ├── CheckinRecord (签到记录, 1:1)
 ├── ServicePhoto (服务过程照片, 1:N)
 ├── FeeDetail (费用明细, 1:1)
 ├── PaymentRecord (支付记录, 1:N)
 ├── CleanerIncome (保洁员收入流水, 1:1)
 ├── OrderReview (评价, 1:1)
 ├── Complaint (投诉售后, 1:1)
 └── OrderReschedule (改期申请, 1:N)

Notification (站内消息)
 └── FK user_id → User (任意角色均可接收)

SystemConfig (系统参数) — 全局读写，影响派单/计费/签到逻辑
OperationLog (管理员操作日志)
```

### 1.2 订单状态机

```
顾客下单
  └─→ [1] PENDING_DISPATCH（待派单）
            ├─→ 管理员手动/自动派单 → [2] DISPATCHED_PENDING_CONFIRM（已派单，待保洁员确认）
            │         ├─→ 保洁员接单 → [3] ACCEPTED（已接单）
            │         └─→ 保洁员拒单 / 超时 → 回到 [1]
            └─→ 保洁员抢单（GRAB）→ 直接跳到 [3] ACCEPTED
  [3] ACCEPTED
    └─→ 保洁员签到打卡 → [4] IN_SERVICE（服务中）
  [4] IN_SERVICE
    └─→ 保洁员完工上报 → [5] PENDING_COMPLETE_CONFIRM（待顾客确认完成）
  [5] PENDING_COMPLETE_CONFIRM
    ├─→ 顾客确认完成 → [6] COMPLETED（已完成）
    ├─→ 48h自动确认 → [6] COMPLETED
    └─→ 顾客发起投诉 → [7] AFTER_SALE（售后处理中）
  任意状态
    ├─→ 顾客/保洁员取消 → [8] CANCELLED（已取消）
    └─→ 改期申请批准 → [9] RESCHEDULING（改期中）→ 回到 [1]
```

### 1.3 角色权限边界

| 角色 | role值 | Spring Security权限 | 可访问路径前缀 |
|------|--------|---------------------|----------------|
| 顾客 CUSTOMER | 1 | ROLE_CUSTOMER | `/customer/**` |
| 保洁员 CLEANER | 2 | ROLE_CLEANER | `/cleaner/**` |
| 管理员 ADMIN | 3 | ROLE_ADMIN | `/admin/**`（也可访问前两者） |
| 匿名 | - | 无 | `/auth/**`, `/service-types`, `/files/**`, `/external/**` |

---

## 2. 功能模块索引

### 2.1 认证模块

| 功能 | 接口 (Controller) | 核心逻辑 (Service) | 涉及数据库表 |
|------|-------------------|--------------------|--------------|
| 注册 | `POST /auth/register` → `AuthController.register` | 手机号查重 → BCrypt加密 → 插入user → 插入customer_profile或cleaner_profile | `user`, `customer_profile`, `cleaner_profile` |
| 登录 | `POST /auth/login` → `AuthController.login` | 查user by phone → BCrypt.matches验密 → JwtUtil.generateToken | `user` |
| 获取当前用户信息 | `GET /auth/me` → `AuthController.getMe` | JWT中取userId → 查user+profile，拼装Map返回 | `user`, `cleaner_profile`, `cleaning_company` |
| 修改密码 | `PUT /auth/password` → `AuthController.changePassword` | 验旧密码 → BCrypt加密新密码 → updateById | `user` |

**JWT流程**：`JwtUtil.generateToken(userId, role, phone)` → Header `Authorization: Bearer <token>` → `JwtAuthenticationFilter`拦截每个请求，解析token → 注入`UsernamePasswordAuthenticationToken`到SecurityContext → Controller通过`Authentication`参数获取当前用户ID。

---

### 2.2 顾客功能模块

#### 地址管理

| 功能 | 接口 | 核心逻辑 | 涉及表 |
|------|------|----------|--------|
| 查询地址列表 | `GET /customer/addresses` → `CustomerAddressController.listAddresses` | lambdaQuery by userId | `customer_address` |
| 新增地址 | `POST /customer/addresses` | save | `customer_address` |
| 修改地址 | `PUT /customer/addresses/{id}` | 校验归属 → updateById | `customer_address` |
| 删除地址 | `DELETE /customer/addresses/{id}` | 校验归属 → removeById | `customer_address` |
| 设为默认 | `PUT /customer/addresses/{id}/default` | update其他为0 → 当前为1 | `customer_address` |

#### 订单管理（顾客侧）

| 功能 | 接口 | 核心逻辑 | 涉及表 |
|------|------|----------|--------|
| 下单 | `POST /customer/orders` → `CustomerOrderController.createOrder` | ServiceOrderServiceImpl.createOrder（详见§3.1） | `service_order`, `order_status_log`, `notification` |
| 订单列表 | `GET /customer/orders` | listCustomerOrders by customerId + status分页 | `service_order` |
| 订单详情 | `GET /customer/orders/{orderId}` | getOrderVO → toVO拼装（含保洁员信息、费用、评价及保洁员回复） | `service_order`, `cleaner_profile`, `fee_detail`, `order_review` |
| 取消订单 | `PUT /customer/orders/{orderId}/cancel` | 校验状态(1/2/3) → status=8 → 释放timeLock | `service_order`, `cleaner_time_lock`, `order_status_log` |
| 确认完成 | `PUT /customer/orders/{orderId}/confirm` | 校验状态=5 → status=6 → 发通知 | `service_order`, `notification`, `order_status_log` |
| 上报保洁员未到 | `PUT /customer/orders/{orderId}/report-absence` | 校验状态=3 → status=1 → 发管理员通知 | `service_order`, `notification`, `order_status_log` |
| 查看评价 | `GET /customer/orders/{orderId}/review` | 直接查 order_review WHERE orderId=? （**不过滤 is_visible**，顾客永远可见自己的评价） | `order_review` |
| 提交评价 | `POST /customer/orders/{orderId}/review` | 校验status=6且未评价 → 保存review（is_visible=1） → 重新计算cleaner_profile.avg_score（所有可见评价均值） | `order_review`, `cleaner_profile` |
| 提交投诉 | `POST /customer/orders/{orderId}/complaint` | 校验status=6 → 保存complaint → status=7 | `complaint`, `service_order`, `notification` |
| 申请改期 | `POST /customer/orders/{orderId}/reschedule` | 保存reschedule → status=9 → 通知保洁员 | `order_reschedule`, `service_order`, `notification` |
| 预付定金 | `POST /customer/orders/{orderId}/pay-deposit` | 读deposit_rate配置 → 计算depositFee → 保存payment_record → 更新pay_status=1 | `payment_record`, `service_order`, `system_config` |
| 尾款支付 | `POST /customer/orders/{orderId}/pay-final` | 读fee_detail.tail_fee → 保存payment_record → pay_status=2 | `payment_record`, `fee_detail`, `service_order` |
| 全款支付 | `POST /customer/orders/{orderId}/pay-full` | 计算actualFee → 保存payment_record → pay_status=2 | `payment_record`, `service_order` |

---

### 2.3 保洁员功能模块

#### 档案管理

| 功能 | 接口 | 核心逻辑 | 涉及表 |
|------|------|----------|--------|
| 查看个人档案 | `GET /cleaner/profile/me` → `CleanerProfileController.getMyProfile` | lambdaQuery by userId | `cleaner_profile` |
| 更新档案 | `PUT /cleaner/profile/me` | 校验归属 → updateById | `cleaner_profile` |
| 上传图片 | `POST /cleaner/profile/upload` | MultipartFile → 存到/files/目录 → 返回URL | 文件系统 |

#### 档期管理

| 功能 | 接口 | 核心逻辑 | 涉及表 |
|------|------|----------|--------|
| 查看周模板 | `GET /cleaner/schedule/template` → `CleanerScheduleController.getTemplate` | lambdaQuery by cleanerId | `cleaner_schedule_template` |
| 保存周模板 | `PUT /cleaner/schedule/template` | 先删全部 → 批量insert | `cleaner_schedule_template` |
| 查看特殊调整 | `GET /cleaner/schedule/overrides` | 按月份过滤 | `cleaner_schedule_override` |
| 添加特殊调整 | `POST /cleaner/schedule/overrides` | 唯一约束uk_cleaner_date防重 → save | `cleaner_schedule_override` |
| 删除特殊调整 | `DELETE /cleaner/schedule/overrides/{id}` | 校验归属 → removeById | `cleaner_schedule_override` |
| 查看锁定时段 | `GET /cleaner/schedule/locks` | 按月份过滤timeLock | `cleaner_time_lock` |

#### 订单管理（保洁员侧）

| 功能 | 接口 | 核心逻辑 | 涉及表 |
|------|------|----------|--------|
| 抢单池 | `GET /cleaner/orders/pool` → `CleanerOrderController.getGrabPool` | 查status=1且cleanerId=null的订单 | `service_order` |
| 抢单 | `POST /cleaner/orders/{orderId}/grab` | grabOrder（详见§3.3） | `service_order`, `dispatch_record`, `cleaner_time_lock`, `order_status_log`, `notification` |
| 接单（派单后） | `POST /cleaner/orders/{orderId}/accept` | acceptOrder → status=3 | `service_order`, `dispatch_record`, `order_status_log`, `notification` |
| 拒单 | `POST /cleaner/orders/{orderId}/reject` | rejectOrder → status=1, dispatch_record.status=3 → 重新派单 | `service_order`, `dispatch_record`, `order_status_log` |
| 签到打卡 | `POST /cleaner/orders/{orderId}/checkin` | checkinOrder（详见§3.4） | `checkin_record`, `service_order`, `notification` |
| 完工上报 | `PUT /cleaner/orders/{orderId}/complete` | reportComplete（详见§3.5） | `fee_detail`, `cleaner_income`, `service_order`, `notification` |
| 上传服务照片 | `POST /cleaner/orders/{orderId}/photos` | 存文件 → save service_photo | `service_photo` |
| 处理改期申请 | `PUT /cleaner/reschedules/{id}/handle` | 审批 → 更新reschedule.status → 若批准则更新order.appointTime + 重置status=1 | `order_reschedule`, `service_order`, `cleaner_time_lock` |
| 查看收入 | `GET /cleaner/orders/income` | 分页查cleaner_income by cleanerId | `cleaner_income` |
| 查看我的评价 | `GET /cleaner/orders/reviews` | 分页查 order_review WHERE cleaner_id=? **AND is_visible=1**（被管理员屏蔽的评价不可见） | `order_review` |
| 回复评价 | `PUT /cleaner/orders/reviews/{reviewId}/reply` | 校验归属 → 校验reply_content为NULL（只能回复一次） → update reply_content+replied_at | `order_review` |

---

### 2.4 管理员功能模块

#### 审核模块

| 功能 | 接口 | 核心逻辑 | 涉及表 |
|------|------|----------|--------|
| 保洁员审核列表 | `GET /admin/audit/cleaners` | 分页查cleaner_profile by auditStatus | `cleaner_profile`, `user` |
| 审核保洁员 | `PUT /admin/audit/cleaners/{id}` | 更新audit_status+remark+audited_by+audited_at → 发通知 | `cleaner_profile`, `notification` |
| 启停保洁员账号 | `PUT /admin/audit/cleaners/{userId}/status` | 更新user.status | `user` |
| 公司列表/审核 | `GET/PUT /admin/audit/companies` | 查/更新cleaning_company.status | `cleaning_company` |

#### 派单模块

| 功能 | 接口 | 核心逻辑 | 涉及表 |
|------|------|----------|--------|
| 待派单列表 | `GET /admin/dispatch/pending` | 查status=1或2的订单 | `service_order` |
| 查看候选保洁员 | `GET /admin/dispatch/candidates/{orderId}` | getDispatchCandidates：按距离+档期打分排序 | `cleaner_profile`, `cleaner_time_lock` |
| 自动派单 | `POST /admin/dispatch/auto/{orderId}` | autoDispatch（详见§3.2） | `service_order`, `dispatch_record`, `notification` |
| 手动派单 | `POST /admin/dispatch/manual` | 指定cleanerId → status=2 → 写dispatch_record → 发通知 | `service_order`, `dispatch_record`, `notification` |

#### 订单管理

| 功能 | 接口 | 核心逻辑 | 涉及表 |
|------|------|----------|--------|
| 订单列表 | `GET /admin/orders` | 多条件分页 | `service_order` |
| 订单详情 | `GET /admin/orders/{orderId}` | getOrderVO | `service_order` + 关联表 |
| 人工录单 | `POST /admin/orders/manual-create` | importOrder with source=3 | `service_order`, `user`, `customer_address` |

#### 统计模块

| 功能 | 接口 | 核心逻辑 | 涉及表 |
|------|------|----------|--------|
| 数据总览 | `GET /admin/stats/overview` | 查用户数/订单数/收入聚合 | `user`, `service_order`, `fee_detail` |
| 趋势图 | `GET /admin/stats/trend` | 按天聚合近N天数据 | `service_order` |
| 服务类型分布 | `GET /admin/stats/service-type` | GROUP BY service_type_id | `service_order` |
| 保洁员排行 | `GET /admin/stats/cleaner-rank` | ORDER BY order_count/avg_score | `cleaner_profile` |

#### 其他

| 功能 | 接口 | 涉及表 |
|------|------|--------|
| 投诉处理 | `PUT /admin/complaints/{id}` | `complaint`, `service_order`, `payment_record` |
| 评价列表 | `GET /admin/reviews` | 分页查 order_review，支持按 is_visible/关键词过滤，关联查询顾客昵称、保洁员昵称、订单号 | `order_review`, `user`, `service_order` |
| 屏蔽评价 | `PUT /admin/reviews/{id}/hide` | 更新 is_visible=0 + hide_reason + hidden_by（当前管理员ID） | `order_review` |
| 恢复显示 | `PUT /admin/reviews/{id}/show` | 更新 is_visible=1，清空 hide_reason/hidden_by | `order_review` |
| 系统参数配置 | `GET/PUT /admin/system-config` | `system_config` |
| 顾客管理 | `GET/PUT /admin/customers` | `user`, `customer_profile` |
| 服务类型管理 | `GET/POST/PUT /admin/service-types` | `service_type`, `service_price_tier` |
| 操作日志 | `GET /admin/operation-log` | `operation_log` |

---

## 3. 关键操作数据流

### 3.1 顾客下单（`createOrder`）

```
[前端 Book.vue]
  → api/order.js: createOrder(dto)
  → POST /customer/orders (CustomerOrderController.createOrder)
  → Authentication → JwtAuthenticationFilter → customerId提取
  → ServiceOrderServiceImpl.createOrder(dto, customerId)

Service层逻辑（@Transactional）：
  1. serviceTypeService.getById(dto.serviceTypeId)
     → 检查 service_type.status != 2（未下架）
  2. addressService.getById(dto.addressId)
     → 检查 customer_address.user_id == customerId（防越权）
  3. calculateFee(serviceType, planDuration, houseArea)
     ├─ priceMode=1（按时） → basePrice × planDuration / 60
     ├─ priceMode=2（按面积）→ 查 service_price_tier 匹配档位 → unitPrice × houseArea
     └─ priceMode=3（固定套餐）→ basePrice
  4. 生成 orderNo = "CM" + yyyyMMddHHmmss + 4位随机数
  5. save(ServiceOrder)  ← 写入 service_order
     status = 1(PENDING_DISPATCH), payStatus = 0
  6. statusLogService.save(OrderStatusLog)  ← 写入 order_status_log
     fromStatus=null, toStatus=1, remark="顾客下单"
  7. notificationService.sendNotification(customerId, 1, "订单已提交", ..., orderId)
     ← 写入 notification

返回：order.getId() → 前端跳转至订单详情页
```

**落库表**：`service_order` → `order_status_log` → `notification`

---

### 3.2 自动派单（`autoDispatch`）

```
[触发方式]
  A. 管理员点击"自动派单" → POST /admin/dispatch/auto/{orderId}
  B. 顾客下单后由后端异步触发（CompletableFuture，如实现）

AdminDispatchController.autoDispatch(orderId, Authentication)
  → ServiceOrderServiceImpl.autoDispatch(orderId, operatorId)

Service层逻辑（@Transactional）：
  1. 查 service_order，校验 status=1 或 2
     若status=2（已派但超时）→ 重置 status=1, cleanerId=null
  2. 读系统配置：
     - dispatch_max_distance_km（默认30）
     - commute_buffer_minutes（默认30）
     - dispatch_timeout_minutes（默认30）
  3. 获取候选保洁员列表（getDispatchCandidates）：
     a. 查 cleaner_profile WHERE audit_status=1（审核通过）
     b. JOIN user WHERE status=1（账号正常）
     c. DistanceUtil.calculateKm 过滤距离 <= maxDistKm
     d. checkAvailability：查 cleaner_schedule_template + cleaner_schedule_override + cleaner_time_lock
     e. 综合评分：距离得分 + 评分得分 + 接单数得分 → 排序取第一
  4. 选中 bestCleaner → save(DispatchRecord)
     ← 写入 dispatch_record（type=1 AUTO, status=1 待响应）
  5. 更新 service_order：status=2, cleanerId=bestCleaner.id
     ← 更新 service_order
  6. 发通知给保洁员（type=2 ORDER_DISPATCHED）
     ← 写入 notification

返回："已派单给：{nickname}"
```

**落库表**：`dispatch_record` → `service_order` → `notification`

---

### 3.3 保洁员抢单（`grabOrder`）

```
[前端 GrabPool.vue]
  → api/order.js: grabOrder(orderId)
  → POST /cleaner/orders/{orderId}/grab (CleanerOrderController.grabOrder)
  → ServiceOrderServiceImpl.grabOrder(orderId, cleanerId)

Service层逻辑（@Transactional）：
  1. 查 service_order 校验 status=1
  2. 查 user 校验 status=1（账号未被停用）
  3. 查 cleaner_profile 校验 audit_status=1（审核通过）
  4. 时段可用性三合一校验（CleanerScheduleTemplateServiceImpl.checkAvailability）：
     lockStart = appointTime - commuteBuffer(30min)
     lockEnd   = appointTime + planDuration + commuteBuffer(30min)
     ① 查 cleaner_schedule_override WHERE cleaner_id=? AND date=?
        → is_off=1 则 SCHEDULE_NOT_COVER
        → 时段不在range内 则 SCHEDULE_NOT_COVER
     ② 无override → 查 cleaner_schedule_template WHERE day_of_week=?
        → 无记录 则 SCHEDULE_NOT_COVER
        → 时段不在range内 则 SCHEDULE_NOT_COVER
     ③ 查 cleaner_time_lock WHERE cleaner_id=? AND lockStart<lockEnd AND lockEnd>lockStart
        → 存在 则 TIME_LOCK_CONFLICT → 抛 BusinessException
  5. updateById(order)：cleanerId=cleanerId, status=3(ACCEPTED)
     ← 更新 service_order
  6. save(DispatchRecord)：type=3(GRAB), status=2(已接受)
     ← 写入 dispatch_record
  7. save(CleanerTimeLock)：lockStart/lockEnd
     ← 写入 cleaner_time_lock
  8. logStatusChange(1→3, "保洁员抢单")
     ← 写入 order_status_log
  9. notificationService 通知顾客
     ← 写入 notification
```

**落库表**：`service_order` → `dispatch_record` → `cleaner_time_lock` → `order_status_log` → `notification`

---

### 3.4 保洁员签到打卡（`checkinOrder`）

```
[前端 CleanerOrderDetail 或 GrabPool]
  → POST /cleaner/orders/{orderId}/checkin?longitude=xx&latitude=xx
  → ServiceOrderServiceImpl.checkinOrder(orderId, cleanerId, longitude, latitude)

Service层逻辑（@Transactional）：
  1. 校验 order.cleanerId == cleanerId（防越权）
  2. 校验 status=3(ACCEPTED)
  3. 时间窗口校验：
     - now < appointTime - 15min → CHECKIN_TOO_EARLY
     - now > appointTime + planDuration → CHECKIN_TOO_LATE
  4. 读 system_config.checkin_max_distance_m（默认500）
     DistanceUtil.calculateMeters(lat,lng, order.lat, order.lng)
     → isAbnormal = distanceM > maxCheckinDistM ? 1 : 0
  5. save(CheckinRecord)：checkinTime/longitude/latitude/distanceM/isAbnormal
     ← 写入 checkin_record
  6. 若 isAbnormal=1 → 通知所有 role=3 管理员（type=12 ABNORMAL_CHECKIN）
     ← 写入 notification（批量）
  7. updateById(order)：status=4(IN_SERVICE)
     ← 更新 service_order
  8. logStatusChange(3→4, "保洁员签到打卡")
     ← 写入 order_status_log
  9. 通知顾客：type=3 CLEANER_CHECKIN
     ← 写入 notification
```

**落库表**：`checkin_record` → `notification` → `service_order` → `order_status_log`

---

### 3.5 保洁员完工上报（`reportComplete`）

```
[前端 OrderDetail（保洁员）]
  → PUT /cleaner/orders/{orderId}/complete?actualDuration=xx
  → ServiceOrderServiceImpl.reportComplete(orderId, cleanerId, actualDuration)

Service层逻辑（@Transactional）：
  1. 校验 order.cleanerId==cleanerId 且 status=4(IN_SERVICE)
  2. 计算实际费用（computeActualFee）：
     - priceMode=1 → basePrice × actualDuration / 60
     - priceMode=2 → 同createOrder面积计费
     - priceMode=3 → basePrice
  3. 超时附加费（仅priceMode=1）：
     overtimeMin = actualDuration - planDuration（若>0）
     overtimeFee = basePrice × overtimeMin / 60
     actualFee += overtimeFee
  4. 读 system_config.commission_rate（默认0.20）
     commissionFee = actualFee × commissionRate
     cleanerIncome = actualFee - commissionFee
  5. save(FeeDetail)：serviceFee/overtimeFee/actualFee/commissionRate/commissionFee/cleanerIncome
     ← 写入 fee_detail
  6. save(CleanerIncome)：amount=cleanerIncome, settleMonth="yyyy-MM", status=1（待结算）
     ← 写入 cleaner_income
  7. updateById(order)：actualDuration/actualFee/status=5/autoConfirmAt=now+48h
     ← 更新 service_order
  8. logStatusChange(4→5, "保洁员完工上报")
     ← 写入 order_status_log
  9. 通知顾客：type=4 SERVICE_COMPLETED，"48小时内确认"
     ← 写入 notification
```

**落库表**：`fee_detail` → `cleaner_income` → `service_order` → `order_status_log` → `notification`

---

### 3.6 顾客支付定金

```
[前端 OrderDetail.vue → 支付弹窗]
  → POST /customer/orders/{orderId}/pay-deposit
  → CustomerOrderController.payDeposit

逻辑：
  1. 读 system_config.deposit_rate（默认0.20）
  2. depositFee = order.estimateFee × deposit_rate（四舍五入2位）
  3. save(PaymentRecord)：orderId/payType=1/amount=depositFee/payMethod=99(mock)/payStatus=2(success)/payTime=now
     ← 写入 payment_record
  4. updateById(order)：depositFee=depositFee, payStatus=1（已付定金）
     ← 更新 service_order

返回：{depositFee, message: "定金支付成功（模拟）"}
```

**落库表**：`payment_record` → `service_order`

---

### 3.7 评价全链路

```
【顾客提交评价】
[前端 CustomerOrderDetail.vue → 评价表单]
  → api/order.js: submitReview(orderId, {scoreAttitude, scoreQuality, scorePunctual, content})
  → POST /customer/orders/{orderId}/review (CustomerOrderController.submitReview)

前置校验：
  1. 订单归属校验：order.customerId == currentUserId
  2. 状态校验：status=6(已完成) 或 status=7且投诉非免费重做
  3. 支付校验：payStatus=2（已全额支付）
  4. 重复校验：order_review WHERE orderId=? 不存在

写入逻辑：
  1. avgScore = (attitude + quality + punctual) / 3.0
  2. save(OrderReview)：is_visible=1, replyContent=NULL
     ← 写入 order_review
  3. 重新计算保洁员综合评分（仅计 is_visible=1 的评价）：
     newAvg = SUM(avg_score) / COUNT(*) WHERE cleaner_id=? AND is_visible=1
     lambdaUpdate cleaner_profile.avg_score = newAvg

落库表：order_review → cleaner_profile

---

【保洁员查看 & 回复评价】
[前端 CleanerReviews.vue]
  → GET /cleaner/orders/reviews?current=1&size=10
  → CleanerOrderController.getMyReviews
  → 查 order_review WHERE cleaner_id=? AND is_visible=1（屏蔽的不可见）

[保洁员回复]
  → PUT /cleaner/orders/reviews/{reviewId}/reply {replyContent}
  → CleanerOrderController.replyReview
  → 校验归属 + 校验 review.replyContent == NULL（只能回复一次）
  → lambdaUpdate reply_content + replied_at=now()

---

【管理员屏蔽/恢复评价】
[前端 AdminReviews.vue]
  → GET /admin/reviews → 关联查询顾客昵称 + 保洁员昵称 + 订单号

[屏蔽]
  → PUT /admin/reviews/{id}/hide {hideReason}
  → AdminReviewController.hide
  → is_visible=0, hide_reason=?, hidden_by=adminId
  ※ 屏蔽后：保洁员端立即不可见；顾客在订单详情中仍可见（不过滤）

[恢复]
  → PUT /admin/reviews/{id}/show
  → AdminReviewController.show
  → is_visible=1, hide_reason=NULL, hidden_by=NULL
```

**可见性设计原则**：屏蔽针对保洁员公开展示生效，不影响顾客查看自己的历史评价，避免顾客困惑。

---

### 3.8 档期可用性校验（核心调度逻辑）

```
CleanerScheduleTemplateServiceImpl.checkAvailability(cleanerId, lockStart, lockEnd)

入参说明：
  lockStart = appointTime - commuteBuffer（含通勤缓冲）
  lockEnd   = appointTime + planDuration + commuteBuffer
  serviceStart = lockStart + buffer（实际服务开始）
  serviceEnd   = lockEnd - buffer（实际服务结束）

查询链（优先级 override > template）：
  1. cleaner_schedule_override WHERE cleaner_id=? AND date=lockStart.toLocalDate()
     ├─ isOff=1 → SCHEDULE_NOT_COVER（该天休息）
     └─ start/end不覆盖serviceStart~serviceEnd → SCHEDULE_NOT_COVER
  2. 若无override：cleaner_schedule_template WHERE cleaner_id=? AND day_of_week=?
     ├─ 无记录 → SCHEDULE_NOT_COVER（该天未设排班）
     └─ start/end不覆盖serviceStart~serviceEnd → SCHEDULE_NOT_COVER
  3. cleaner_time_lock WHERE cleaner_id=? AND lockStart < lockEnd AND lockEnd > lockStart（时段有交叠）
     → exists → TIME_LOCK_CONFLICT

返回值：OK / SCHEDULE_NOT_COVER / TIME_LOCK_CONFLICT
```

---

## 4. 数据库字典

> 数据库名：`cleaning_service`，字符集：utf8mb4，共23张表

### 4.1 用户体系

#### `user` — 用户账户（所有角色共用）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK AI | 用户ID |
| phone | VARCHAR(20) UNIQUE | 手机号（唯一，登录凭证） |
| password | VARCHAR(100) | BCrypt加密后的密码 |
| nickname | VARCHAR(50) | 昵称 |
| avatar_url | VARCHAR(255) | 头像URL |
| role | TINYINT | **1=顾客 2=保洁员 3=管理员** |
| status | TINYINT | **1=正常 2=待审核 3=禁用 4=封禁** |
| created_at / updated_at | DATETIME | 创建/更新时间（MyBatis-Plus自动填充） |

#### `customer_profile` — 顾客扩展档案

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK AI | |
| user_id | BIGINT UNIQUE **FK→user.id** | 1:1关联user |
| real_name | VARCHAR(50) | 真实姓名 |
| created_at | DATETIME | |

#### `customer_address` — 顾客地址

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK AI | |
| user_id | BIGINT **FK→user.id** | 归属顾客 |
| label | VARCHAR(20) | 地址标签（家、公司等） |
| contact_name / contact_phone | VARCHAR | 联系人姓名/电话 |
| province/city/district/detail | VARCHAR | 行政区划+详细地址 |
| longitude/latitude | DECIMAL(10,7) | 经纬度（用于距离计算） |
| is_default | TINYINT | 1=默认地址 |

#### `cleaning_company` — 保洁公司

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK AI | |
| name | VARCHAR(100) | 公司名称 |
| license_no / license_img | VARCHAR | 营业执照号/图片 |
| status | TINYINT | **1=正常 2=待审核 3=禁用** |
| audited_by | BIGINT **FK→user.id** | 审核管理员 |

#### `cleaner_profile` — 保洁员扩展档案

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK AI | |
| user_id | BIGINT UNIQUE **FK→user.id** | 1:1关联user |
| company_id | BIGINT **FK→cleaning_company.id** | 所属公司 |
| id_card / id_card_front / id_card_back | VARCHAR | 身份证号/正反面图片 |
| longitude/latitude | DECIMAL(10,7) | 保洁员当前/常驻位置（用于派单距离计算） |
| skill_tags | VARCHAR(200) | 技能标签（逗号分隔） |
| avg_score | DECIMAL(3,2) | 综合评分（下单确认后更新） |
| order_count | INT | 历史接单数 |
| audit_status | TINYINT | **1=通过 2=待审核 3=拒绝** |
| audited_by | BIGINT **FK→user.id** | 审核管理员 |

---

### 4.2 服务体系

#### `service_type` — 服务类型

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK AI | |
| name | VARCHAR(50) | 服务名称（日常保洁、深度保洁等） |
| price_mode | TINYINT | **1=按时收费 2=按面积收费 3=固定套餐** |
| base_price | DECIMAL(8,2) | 基础单价（元/小时 或 元/㎡ 或 固定总价） |
| min_duration | INT | 最短服务时长（分钟） |
| suggest_workers | INT | 建议派几名保洁员 |
| status | TINYINT | **1=上架 2=下架** |

#### `service_price_tier` — 面积分级定价

| 字段 | 类型 | 说明 |
|------|------|------|
| service_type_id | BIGINT **FK→service_type.id** | 属于哪种服务 |
| area_min/area_max | INT | 面积区间（㎡） |
| unit_price | DECIMAL(8,2) | 该区间单价（元/㎡） |

---

### 4.3 订单体系

#### `service_order` — 服务订单（核心表）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT PK AI | 订单ID |
| order_no | VARCHAR(32) UNIQUE | 订单号（CM+时间戳+4位随机数） |
| source | TINYINT | **1=平台下单 2=外部导入 3=人工录单** |
| customer_id | BIGINT **FK→user.id** | 下单顾客 |
| cleaner_id | BIGINT **FK→user.id** | 接单保洁员（派单前为NULL） |
| service_type_id | BIGINT **FK→service_type.id** | 服务类型 |
| address_id | BIGINT **FK→customer_address.id** | 服务地址 |
| address_snapshot | VARCHAR(500) | 下单时的地址快照（防地址被修改后影响历史订单） |
| longitude/latitude | DECIMAL(10,7) | 服务地址经纬度（从address复制，用于距离计算） |
| house_area | DECIMAL(6,1) | 房屋面积（㎡） |
| plan_duration | INT | 预计服务时长（分钟） |
| actual_duration | INT | 实际服务时长（完工后填入） |
| appoint_time | DATETIME | 预约服务时间 |
| status | TINYINT | **1=待派单 2=已派单待确认 3=已接单 4=服务中 5=待完成确认 6=已完成 7=售后处理 8=已取消 9=改期中** |
| estimate_fee | DECIMAL(8,2) | 预估费用（下单时计算） |
| actual_fee | DECIMAL(8,2) | 实际费用（完工后计算） |
| deposit_fee | DECIMAL(8,2) | 已付定金金额 |
| pay_status | TINYINT | **0=未支付 1=已付定金 2=已全额支付** |
| auto_confirm_at | DATETIME | 自动确认时间（完工后+48h） |
| cancel_reason | VARCHAR(200) | 取消原因 |

#### `order_status_log` — 订单状态变更日志

| 字段 | 类型 | 说明 |
|------|------|------|
| order_id | BIGINT **FK→service_order.id** | 所属订单 |
| from_status / to_status | TINYINT | 状态转换前后值 |
| operator_id | BIGINT **FK→user.id** | 操作者（顾客/保洁员/管理员） |
| remark | VARCHAR(200) | 操作描述（如"保洁员抢单"） |

#### `order_reschedule` — 改期申请

| 字段 | 类型 | 说明 |
|------|------|------|
| order_id | BIGINT **FK→service_order.id** | |
| old_time / new_time | DATETIME | 原时间/申请改至的时间 |
| status | TINYINT | **1=待处理 2=已批准 3=已拒绝** |
| handled_by | BIGINT **FK→user.id** | 审批人（通常是保洁员） |

---

### 4.4 档期体系

#### `cleaner_schedule_template` — 固定周档期模板

| 字段 | 类型 | 说明 |
|------|------|------|
| cleaner_id | BIGINT **FK→user.id** | |
| day_of_week | TINYINT | **1=周一 ... 7=周日** |
| start_time / end_time | TIME | 当天工作时间段 |

#### `cleaner_schedule_override` — 特殊日期调整

| 字段 | 类型 | 说明 |
|------|------|------|
| cleaner_id | BIGINT **FK→user.id** | |
| date | DATE | 具体日期（唯一约束 uk_cleaner_date） |
| is_off | TINYINT | **1=全天休息**（优先级最高） |
| start_time / end_time | TIME | 该天特殊工作时间（is_off=0时有效） |

#### `cleaner_time_lock` — 时段锁定（防重叠接单）

| 字段 | 类型 | 说明 |
|------|------|------|
| cleaner_id | BIGINT **FK→user.id** | |
| order_id | BIGINT **FK→service_order.id** | 对应的订单 |
| lock_start / lock_end | DATETIME | 锁定时段（含通勤缓冲，比实际服务时间各扩30分钟） |

---

### 4.5 派单体系

#### `dispatch_record` — 派单记录

| 字段 | 类型 | 说明 |
|------|------|------|
| order_id | BIGINT **FK→service_order.id** | |
| cleaner_id | BIGINT **FK→user.id** | 被派的保洁员 |
| dispatch_type | TINYINT | **1=系统自动 2=管理员手动 3=保洁员抢单** |
| score | DECIMAL(6,2) | 自动派单综合评分 |
| distance_km | DECIMAL(6,2) | 保洁员到服务地址距离 |
| status | TINYINT | **1=待响应 2=已接受 3=已拒绝 4=已超时** |
| expire_at | DATETIME | 响应截止时间（派单后+30min） |
| operator_id | BIGINT **FK→user.id** | 手动派单的管理员 |

---

### 4.6 服务执行体系

#### `checkin_record` — 签到记录

| 字段 | 类型 | 说明 |
|------|------|------|
| order_id | BIGINT UNIQUE **FK→service_order.id** | 一订单一签到 |
| cleaner_id | BIGINT **FK→user.id** | |
| checkin_time | DATETIME | 实际签到时间 |
| longitude/latitude | DECIMAL(10,7) | 签到时的GPS坐标 |
| distance_m | INT | 与服务地址的偏差距离（米） |
| is_abnormal | TINYINT | **1=位置异常（>500m）** |
| handled_by | BIGINT **FK→user.id** | 异常处理管理员 |

#### `service_photo` — 服务过程照片

| 字段 | 类型 | 说明 |
|------|------|------|
| order_id | BIGINT **FK→service_order.id** | |
| phase | TINYINT | **1=服务前 2=服务中 3=服务后** |
| img_url | VARCHAR(255) | 图片存储路径 |
| longitude/latitude | DECIMAL(10,7) | 拍照时的GPS坐标（可选） |

---

### 4.7 结算体系

#### `fee_detail` — 费用明细（完工时生成）

| 字段 | 类型 | 说明 |
|------|------|------|
| order_id | BIGINT UNIQUE **FK→service_order.id** | |
| service_fee | DECIMAL(8,2) | 基础服务费 |
| overtime_fee | DECIMAL(8,2) | 超时附加费 |
| coupon_deduct | DECIMAL(8,2) | 优惠券抵扣（预留，当前为0） |
| actual_fee | DECIMAL(8,2) | 实际应付总额 |
| deposit_fee | DECIMAL(8,2) | 定金金额 |
| tail_fee | DECIMAL(8,2) | 尾款（actual_fee - 已付定金） |
| commission_rate | DECIMAL(5,4) | 平台佣金比例（如0.2000=20%） |
| commission_fee | DECIMAL(8,2) | 平台佣金金额 |
| cleaner_income | DECIMAL(8,2) | 保洁员实收（actual_fee - commission_fee） |

#### `payment_record` — 支付记录

| 字段 | 类型 | 说明 |
|------|------|------|
| order_id | BIGINT **FK→service_order.id** | 一个订单可有多条（定金+尾款） |
| pay_type | TINYINT | **1=定金 2=尾款 3=全款** |
| amount | DECIMAL(8,2) | 支付金额 |
| pay_method | TINYINT | **1=微信 2=支付宝 99=模拟支付** |
| pay_status | TINYINT | **1=待支付 2=成功 3=失败** |

#### `cleaner_income` — 保洁员收入流水

| 字段 | 类型 | 说明 |
|------|------|------|
| cleaner_id | BIGINT **FK→user.id** | |
| order_id | BIGINT **FK→service_order.id** | |
| amount | DECIMAL(8,2) | 本单收入（完工后写入） |
| settle_month | VARCHAR(7) | 结算月份（格式"2025-01"） |
| status | TINYINT | **1=待结算 2=已结算** |

---

### 4.8 评价与售后

#### `order_review` — 评价

| 字段 | 类型 | 说明 |
|------|------|------|
| order_id | BIGINT UNIQUE **FK→service_order.id** | 一单一评价 |
| customer_id / cleaner_id | BIGINT **FK→user.id** | 评价顾客 / 被评保洁员 |
| score_attitude/score_quality/score_punctual | TINYINT | 服务态度/清洁效果/准时到达（各1-5分） |
| avg_score | DECIMAL(3,2) | 三项均值（落库后同步更新cleaner_profile.avg_score） |
| content | VARCHAR(500) | 文字评价内容（可为空） |
| imgs | VARCHAR(1000) | 评价图片URLs，逗号分隔（可为空） |
| is_visible | TINYINT | **1=显示 0=已屏蔽**；屏蔽后保洁员端不可见，顾客自己仍可见 |
| hide_reason | VARCHAR(200) | 屏蔽原因（管理员填写） |
| hidden_by | BIGINT **FK→user.id** | 执行屏蔽操作的管理员ID |
| reply_content | VARCHAR(500) | 保洁员回复内容（只能回复一次，replied_at有值则不允许再改） |
| replied_at | DATETIME | 保洁员回复时间 |

**可见性规则**：
- 顾客：查自己的评价时不过滤 `is_visible`，永远可见
- 保洁员：查询时强制 `AND is_visible=1`，被屏蔽的评价不可见
- 管理员：可查全部，并可执行屏蔽/恢复操作

#### `complaint` — 投诉售后

| 字段 | 类型 | 说明 |
|------|------|------|
| order_id | BIGINT **FK→service_order.id** | |
| status | TINYINT | **1=待处理 2=处理中 3=已关闭** |
| result | TINYINT | **1=全额退款 2=部分退款 3=驳回 4=免费返工** |
| refund_amount | DECIMAL(8,2) | 退款金额（@TableField(exist=false) 不落库，业务字段） |
| handled_by | BIGINT **FK→user.id** | 处理管理员 |

---

### 4.9 通知与系统

#### `notification` — 站内消息

| 字段 | 类型 | 说明 |
|------|------|------|
| user_id | BIGINT **FK→user.id** | 接收者（任意角色） |
| type | TINYINT | **1=下单成功 2=已派单 3=保洁员到达 4=服务完成 5=可抢单 6=审核结果 7=投诉 8=超时预警 9=服务提醒 10=改期请求 11=改期结果 12=异常签到** |
| ref_id | BIGINT | 关联业务ID（通常是order.id） |
| is_read | TINYINT | **0=未读 1=已读** |

#### `system_config` — 系统参数配置

| config_key | config_value | 说明 |
|------------|--------------|------|
| commission_rate | "0.20" | 平台佣金比例 |
| commute_buffer_minutes | "30" | 通勤缓冲时间（分钟），影响时段锁定范围 |
| dispatch_timeout_minutes | "30" | 派单响应超时时间（分钟） |
| deposit_rate | "0.20" | 定金比例 |
| auto_confirm_hours | "48" | 自动确认完成等待时间（小时） |
| checkin_max_distance_m | "500" | 签到位置允许偏差距离（米） |

#### `operation_log` — 管理员操作日志

| 字段 | 类型 | 说明 |
|------|------|------|
| operator_id | BIGINT **FK→user.id** | 操作者 |
| module | VARCHAR(50) | 模块（如"dispatch"） |
| before_data / after_data | TEXT(JSON) | 操作前后的快照（JSON格式） |
| ip | VARCHAR(50) | 操作者IP |

---

## 5. 技术实现亮点

### 5.1 安全认证 — JWT无状态鉴权

- **工具类**：`JwtUtil.java` — 使用JJWT 0.12.5，密钥长度≥256位
- **过滤器**：`JwtAuthenticationFilter extends OncePerRequestFilter` — 每个请求执行一次，解析Header中的Bearer Token，注入SecurityContext
- **白名单**：`SecurityConfig.java` — `/auth/**`, `/service-types`, `/files/**`, `/external/**` 无需鉴权
- **角色隔离**：`/admin/**` 需ROLE_ADMIN，`/cleaner/**` 需ROLE_CLEANER，`/customer/**` 需ROLE_CUSTOMER
- **越权防护**：Controller层从Authentication提取当前userId，与业务数据中的userId对比校验（如地址归属、订单归属）

### 5.2 事务管理 — Spring @Transactional

以下方法加了 `@Transactional(rollbackFor = Exception.class)`，保证原子性：
- `createOrder` — 订单+状态日志+通知
- `grabOrder` — 订单更新+派单记录+时段锁定+状态日志+通知
- `checkinOrder` — 签到记录+订单状态+通知
- `reportComplete` — 费用明细+保洁员收入+订单状态+通知
- `autoDispatch` — 派单记录+订单状态+通知

### 5.3 调度冲突防护 — 三层时段校验

```
Layer 1: cleaner_schedule_template（常规周档期）
Layer 2: cleaner_schedule_override（特殊日期覆盖，优先级更高）
Layer 3: cleaner_time_lock（已接单的硬锁定，含通勤缓冲）
```
任意层校验失败均中止操作，抛BusinessException返回具体原因。

### 5.4 地理距离计算 — Haversine公式

- 工具类：`DistanceUtil.java`
- `calculateKm(lat1, lng1, lat2, lng2)` — 返回千米（用于派单候选人筛选）
- `calculateMeters(...)` — 返回米（用于签到偏差检测）
- 无外部地图API依赖，纯数学计算

### 5.5 派单评分算法

自动派单时对每个候选保洁员计算综合分：
```
score = 距离得分（近者高） + avg_score得分 × 权重 + order_count得分 × 权重
```
取score最高者派单，同时校验档期可用性。

### 5.6 地址快照机制

下单时将地址信息序列化为字符串存入`service_order.address_snapshot`：
```java
snapshot = province + city + district + detail + " | " + contactName + " " + contactPhone
```
即使顾客后续修改或删除地址，历史订单的服务地址记录不变。

### 5.7 系统参数动态读取

佣金比例、通勤缓冲、签到距离等参数均从`system_config`表实时读取，无需重启服务即可调整业务规则。

### 5.8 异常签到不阻断设计

保洁员GPS偏差超过阈值时：
- 签到仍正常放行，订单继续推进（不影响正常业务）
- 系统向所有管理员发送type=12的站内消息，供后台人工核查
- `checkin_record.is_abnormal=1` 标记，管理员可通过列表筛选

### 5.9 全局异常处理

`GlobalExceptionHandler` 统一拦截：
- `BusinessException` → code+message透传给前端
- JSR-303 `@Valid` 校验失败 → 字段级错误聚合返回
- `AccessDeniedException` → 403
- `AuthenticationException` → 401
- 未知异常 → 500 + 通用错误信息

### 5.10 统一响应结构

```java
// Result<T>
{
  "code": 200,       // 业务状态码
  "message": "ok",  // 提示信息
  "data": {...}      // 响应数据（泛型）
}

// PageResult<T>
{
  "list": [...],
  "total": 100,
  "current": 1,
  "size": 10
}
```

### 5.11 前端安全机制

- `utils/auth.js` — token存localStorage，封装getToken/setToken/removeToken
- `utils/request.js` — Axios拦截器自动携带Bearer Token，401时清除token跳转登录页
- `router/index.js` — 路由守卫：无token跳登录，角色不符跳首页（防直接URL访问）
- `store/user.js` — Pinia存储用户状态，刷新后调用`/auth/me`恢复

### 5.12 模拟支付

当前支付接口使用`payMethod=99`（模拟支付），支付逻辑为直接写入payment_record并标记success，实际对接微信/支付宝时只需替换`payMethod`判断分支。

---

*文档结束。如需追踪某个接口的完整链路，参考§3各小节的数据流图。*
