-- ============================================================
-- 居家上门保洁服务管理系统 数据库建表脚本
-- 数据库：MySQL 8.0+
-- 字符集：utf8mb4
-- ============================================================

CREATE DATABASE IF NOT EXISTS cleaning_service DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cleaning_service;

-- ============================================================
-- 一、用户模块
-- ============================================================

-- 1. 用户表（顾客 + 保洁员 + 管理员统一账号表）
CREATE TABLE `user` (
  `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `phone`        VARCHAR(20)  NOT NULL                COMMENT '手机号（登录账号）',
  `password`     VARCHAR(100) NOT NULL                COMMENT '密码（BCrypt加密）',
  `nickname`     VARCHAR(50)  DEFAULT NULL            COMMENT '昵称',
  `avatar_url`   VARCHAR(255) DEFAULT NULL            COMMENT '头像URL',
  `role`         TINYINT      NOT NULL                COMMENT '角色：1=顾客 2=保洁员 3=平台管理员',
  `status`       TINYINT      NOT NULL DEFAULT 1      COMMENT '账号状态：1=正常 2=待审核 3=停用 4=封禁',
  `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_role_status` (`role`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户账号表';

-- 2. 顾客扩展信息表
CREATE TABLE `customer_profile` (
  `id`          BIGINT      NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT      NOT NULL COMMENT '关联user.id',
  `real_name`   VARCHAR(50) DEFAULT NULL COMMENT '真实姓名',
  `created_at`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='顾客扩展信息';

-- 3. 顾客地址表
CREATE TABLE `customer_address` (
  `id`           BIGINT       NOT NULL AUTO_INCREMENT,
  `user_id`      BIGINT       NOT NULL COMMENT '关联user.id',
  `label`        VARCHAR(20)  DEFAULT NULL COMMENT '地址标签，如：家、公司',
  `contact_name` VARCHAR(50)  NOT NULL     COMMENT '联系人姓名',
  `contact_phone`VARCHAR(20)  NOT NULL     COMMENT '联系电话',
  `province`     VARCHAR(30)  NOT NULL     COMMENT '省',
  `city`         VARCHAR(30)  NOT NULL     COMMENT '市',
  `district`     VARCHAR(30)  NOT NULL     COMMENT '区',
  `detail`       VARCHAR(200) NOT NULL     COMMENT '详细地址',
  `longitude`    DECIMAL(10,7) DEFAULT NULL COMMENT '经度',
  `latitude`     DECIMAL(10,7) DEFAULT NULL COMMENT '纬度',
  `is_default`   TINYINT      NOT NULL DEFAULT 0 COMMENT '是否默认：1=是 0=否',
  `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='顾客地址表';

-- 4. 保洁公司表
CREATE TABLE `cleaning_company` (
  `id`             BIGINT       NOT NULL AUTO_INCREMENT,
  `name`           VARCHAR(100) NOT NULL COMMENT '公司名称',
  `license_no`     VARCHAR(50)  DEFAULT NULL COMMENT '营业执照号',
  `license_img`    VARCHAR(255) DEFAULT NULL COMMENT '营业执照图片URL',
  `contact_name`   VARCHAR(50)  DEFAULT NULL COMMENT '联系人',
  `contact_phone`  VARCHAR(20)  DEFAULT NULL COMMENT '联系电话',
  `address`        VARCHAR(200) DEFAULT NULL COMMENT '公司地址',
  `status`         TINYINT      NOT NULL DEFAULT 2 COMMENT '状态：1=正常 2=待审核 3=停用',
  `audit_remark`   VARCHAR(200) DEFAULT NULL COMMENT '审核备注',
  `audited_by`     BIGINT       DEFAULT NULL COMMENT '审核管理员user_id',
  `audited_at`     DATETIME     DEFAULT NULL COMMENT '审核时间',
  `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='保洁公司表';

-- 5. 保洁员扩展信息表
CREATE TABLE `cleaner_profile` (
  `id`              BIGINT       NOT NULL AUTO_INCREMENT,
  `user_id`         BIGINT       NOT NULL COMMENT '关联user.id',
  `real_name`       VARCHAR(50)  NOT NULL COMMENT '真实姓名',
  `id_card`         VARCHAR(20)  NOT NULL COMMENT '身份证号',
  `id_card_front`   VARCHAR(255) DEFAULT NULL COMMENT '身份证正面URL',
  `id_card_back`    VARCHAR(255) DEFAULT NULL COMMENT '身份证背面URL',
  `cert_img`        VARCHAR(255) DEFAULT NULL COMMENT '资格证图片URL',
  `health_cert_img` VARCHAR(255) DEFAULT NULL COMMENT '健康证图片URL',
  `company_id`      BIGINT       DEFAULT NULL COMMENT '所属公司ID，可为空（个人保洁员）',
  `service_area`    VARCHAR(200) DEFAULT NULL COMMENT '服务区域描述',
  `longitude`       DECIMAL(10,7) DEFAULT NULL COMMENT '常驻位置经度（用于派单距离计算）',
  `latitude`        DECIMAL(10,7) DEFAULT NULL COMMENT '常驻位置纬度',
  `bio`             VARCHAR(500) DEFAULT NULL COMMENT '个人简介',
  `skill_tags`      VARCHAR(200) DEFAULT NULL COMMENT '擅长服务类型标签，逗号分隔',
  `avg_score`       DECIMAL(3,2) NOT NULL DEFAULT 5.00 COMMENT '综合评分（1-5）',
  `order_count`     INT          NOT NULL DEFAULT 0 COMMENT '累计接单数',
  `audit_status`    TINYINT      NOT NULL DEFAULT 2 COMMENT '审核状态：1=通过 2=待审核 3=拒绝',
  `audit_remark`    VARCHAR(200) DEFAULT NULL COMMENT '拒绝原因',
  `audited_by`      BIGINT       DEFAULT NULL COMMENT '审核管理员user_id',
  `audited_at`      DATETIME     DEFAULT NULL,
  `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`),
  KEY `idx_company_id` (`company_id`),
  KEY `idx_audit_status` (`audit_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='保洁员扩展信息表';

-- ============================================================
-- 二、服务管理模块
-- ============================================================

-- 6. 服务类型表
CREATE TABLE `service_type` (
  `id`              BIGINT       NOT NULL AUTO_INCREMENT,
  `name`            VARCHAR(50)  NOT NULL COMMENT '服务名称',
  `description`     VARCHAR(500) DEFAULT NULL COMMENT '服务描述',
  `cover_img`       VARCHAR(255) DEFAULT NULL COMMENT '封面图URL',
  `price_mode`      TINYINT      NOT NULL COMMENT '计价模式：1=按小时 2=按面积 3=固定套餐',
  `base_price`      DECIMAL(8,2) NOT NULL COMMENT '基础单价（元/小时 或 元/㎡ 或 套餐价）',
  `min_duration`    INT          DEFAULT NULL COMMENT '最短服务时长（分钟），按小时计费时使用',
  `suggest_workers` INT          NOT NULL DEFAULT 1 COMMENT '建议保洁员人数',
  `sort_order`      INT          NOT NULL DEFAULT 0 COMMENT '排序权重，越大越靠前',
  `status`          TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：1=上架 2=下架',
  `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务类型表';

-- 7. 面积阶梯定价表（服务类型为按面积计费时使用）
CREATE TABLE `service_price_tier` (
  `id`             BIGINT       NOT NULL AUTO_INCREMENT,
  `service_type_id`BIGINT       NOT NULL COMMENT '关联service_type.id',
  `area_min`       INT          NOT NULL COMMENT '面积下限（㎡，含）',
  `area_max`       INT          NOT NULL COMMENT '面积上限（㎡，不含）',
  `unit_price`     DECIMAL(8,2) NOT NULL COMMENT '该区间单价（元/㎡）',
  PRIMARY KEY (`id`),
  KEY `idx_service_type_id` (`service_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='面积阶梯定价表';

-- ============================================================
-- 三、订单模块
-- ============================================================

-- 8. 订单表
CREATE TABLE `service_order` (
  `id`              BIGINT       NOT NULL AUTO_INCREMENT,
  `order_no`        VARCHAR(32)  NOT NULL COMMENT '订单编号（系统生成，唯一）',
  `source`          TINYINT      NOT NULL DEFAULT 1 COMMENT '订单来源：1=平台自有 2=外部导入 3=手动录入',
  `customer_id`     BIGINT       NOT NULL COMMENT '下单顾客user_id',
  `cleaner_id`      BIGINT       DEFAULT NULL COMMENT '派单保洁员user_id',
  `service_type_id` BIGINT       NOT NULL COMMENT '服务类型ID',
  `address_id`      BIGINT       DEFAULT NULL COMMENT '服务地址ID（来自customer_address）',
  `address_snapshot`VARCHAR(500) NOT NULL COMMENT '下单时地址快照（防止地址修改影响历史订单）',
  `longitude`       DECIMAL(10,7) DEFAULT NULL COMMENT '服务地址经度',
  `latitude`        DECIMAL(10,7) DEFAULT NULL COMMENT '服务地址纬度',
  `house_area`      DECIMAL(6,1) DEFAULT NULL COMMENT '房屋面积（㎡）',
  `plan_duration`   INT          DEFAULT NULL COMMENT '预约服务时长（分钟）',
  `actual_duration` INT          DEFAULT NULL COMMENT '实际服务时长（分钟），完工时填写',
  `appoint_time`    DATETIME     NOT NULL COMMENT '预约上门时间',
  `remark`          VARCHAR(500) DEFAULT NULL COMMENT '顾客备注',
  `status`          TINYINT      NOT NULL DEFAULT 1 COMMENT '订单状态：1=待派单 2=已派单待确认 3=已接单 4=服务中 5=待确认完成 6=已完成 7=售后处理中 8=已取消',
  `cancel_reason`   VARCHAR(200) DEFAULT NULL COMMENT '取消原因',
  `estimate_fee`    DECIMAL(8,2) DEFAULT NULL COMMENT '预估费用',
  `actual_fee`      DECIMAL(8,2) DEFAULT NULL COMMENT '实际费用（完工确认后）',
  `deposit_fee`     DECIMAL(8,2) DEFAULT NULL COMMENT '已付定金',
  `pay_status`      TINYINT      NOT NULL DEFAULT 0 COMMENT '支付状态：0=未支付 1=已付定金 2=已全额支付',
  `auto_confirm_at` DATETIME     DEFAULT NULL COMMENT '48h自动确认时间',
  `completed_at`    DATETIME     DEFAULT NULL COMMENT '完成时间',
  `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_customer_id` (`customer_id`),
  KEY `idx_cleaner_id` (`cleaner_id`),
  KEY `idx_status` (`status`),
  KEY `idx_appoint_time` (`appoint_time`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务订单表';

-- 9. 订单状态流转日志表
CREATE TABLE `order_status_log` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `order_id`    BIGINT       NOT NULL COMMENT '订单ID',
  `from_status` TINYINT      DEFAULT NULL COMMENT '流转前状态',
  `to_status`   TINYINT      NOT NULL COMMENT '流转后状态',
  `operator_id` BIGINT       DEFAULT NULL COMMENT '操作人user_id（系统自动触发时为NULL）',
  `remark`      VARCHAR(200) DEFAULT NULL COMMENT '备注',
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单状态流转日志';

-- ============================================================
-- 四、档期管理模块
-- ============================================================

-- 10. 保洁员每周固定工作时段表
CREATE TABLE `cleaner_schedule_template` (
  `id`          BIGINT   NOT NULL AUTO_INCREMENT,
  `cleaner_id`  BIGINT   NOT NULL COMMENT '保洁员user_id',
  `day_of_week` TINYINT  NOT NULL COMMENT '星期几：1=周一 ... 7=周日',
  `start_time`  TIME     NOT NULL COMMENT '工作开始时间',
  `end_time`    TIME     NOT NULL COMMENT '工作结束时间',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cleaner_id` (`cleaner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='保洁员每周固定档期模板';

-- 11. 保洁员档期特殊调整表（单日覆盖）
CREATE TABLE `cleaner_schedule_override` (
  `id`          BIGINT   NOT NULL AUTO_INCREMENT,
  `cleaner_id`  BIGINT   NOT NULL COMMENT '保洁员user_id',
  `date`        DATE     NOT NULL COMMENT '特殊调整日期',
  `is_off`      TINYINT  NOT NULL DEFAULT 0 COMMENT '是否全天不可接单：1=是',
  `start_time`  TIME     DEFAULT NULL COMMENT '当日可工作开始时间（is_off=0时有效）',
  `end_time`    TIME     DEFAULT NULL COMMENT '当日可工作结束时间',
  `remark`      VARCHAR(100) DEFAULT NULL COMMENT '备注（如：请假）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cleaner_date` (`cleaner_id`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='保洁员档期特殊调整表';

-- 12. 时段锁定表（已接单的时间段，防止冲突）
CREATE TABLE `cleaner_time_lock` (
  `id`          BIGINT   NOT NULL AUTO_INCREMENT,
  `cleaner_id`  BIGINT   NOT NULL COMMENT '保洁员user_id',
  `order_id`    BIGINT   NOT NULL COMMENT '关联订单ID',
  `lock_start`  DATETIME NOT NULL COMMENT '锁定开始时间（含通勤缓冲）',
  `lock_end`    DATETIME NOT NULL COMMENT '锁定结束时间（含通勤缓冲）',
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cleaner_id_time` (`cleaner_id`, `lock_start`, `lock_end`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='保洁员时段锁定表';

-- ============================================================
-- 五、派单模块
-- ============================================================

-- 13. 派单记录表
CREATE TABLE `dispatch_record` (
  `id`           BIGINT   NOT NULL AUTO_INCREMENT,
  `order_id`     BIGINT   NOT NULL COMMENT '订单ID',
  `cleaner_id`   BIGINT   NOT NULL COMMENT '被派保洁员user_id',
  `dispatch_type`TINYINT  NOT NULL COMMENT '派单方式：1=系统自动 2=管理员手动 3=保洁员抢单',
  `score`        DECIMAL(6,2) DEFAULT NULL COMMENT '系统自动派单时的综合得分',
  `distance_km`  DECIMAL(6,2) DEFAULT NULL COMMENT '估算距离（km）',
  `status`       TINYINT  NOT NULL DEFAULT 1 COMMENT '状态：1=待响应 2=已接单 3=已拒绝 4=已超时',
  `respond_at`   DATETIME DEFAULT NULL COMMENT '保洁员响应时间',
  `expire_at`    DATETIME NOT NULL COMMENT '响应截止时间（推送后30min）',
  `operator_id`  BIGINT   DEFAULT NULL COMMENT '手动派单的管理员user_id',
  `prev_order_id`     BIGINT       DEFAULT NULL COMMENT '计分时参考的上一单ID',
  `prev_distance_km`  DECIMAL(6,2) DEFAULT NULL COMMENT '从上一单位置到本单的距离（km）',
  `time_feasible`     TINYINT      NOT NULL DEFAULT 1 COMMENT '时间可行性：1=可行 0=偏紧（评分已降权）',
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_cleaner_id` (`cleaner_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='派单记录表';

-- ============================================================
-- 六、履约跟踪模块
-- ============================================================

-- 14. 签到打卡记录表
CREATE TABLE `checkin_record` (
  `id`           BIGINT        NOT NULL AUTO_INCREMENT,
  `order_id`     BIGINT        NOT NULL COMMENT '订单ID',
  `cleaner_id`   BIGINT        NOT NULL COMMENT '保洁员user_id',
  `checkin_time` DATETIME      NOT NULL COMMENT '签到时间',
  `longitude`    DECIMAL(10,7) DEFAULT NULL COMMENT '签到位置经度',
  `latitude`     DECIMAL(10,7) DEFAULT NULL COMMENT '签到位置纬度',
  `distance_m`   INT           DEFAULT NULL COMMENT '与订单地址偏差距离（米）',
  `is_abnormal`  TINYINT       NOT NULL DEFAULT 0 COMMENT '是否位置异常（偏差>500m）：1=是',
  `handled_by`   BIGINT        DEFAULT NULL COMMENT '异常处理管理员user_id',
  `handle_remark`VARCHAR(200)  DEFAULT NULL COMMENT '异常处理备注',
  `created_at`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_id` (`order_id`),
  KEY `idx_cleaner_id` (`cleaner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='保洁员签到打卡记录';

-- 15. 服务过程照片表
CREATE TABLE `service_photo` (
  `id`         BIGINT       NOT NULL AUTO_INCREMENT,
  `order_id`   BIGINT       NOT NULL COMMENT '订单ID',
  `cleaner_id` BIGINT       NOT NULL COMMENT '上传保洁员user_id',
  `phase`      TINYINT      NOT NULL COMMENT '拍摄阶段：1=服务前 2=服务中 3=服务后',
  `img_url`    VARCHAR(255) NOT NULL COMMENT '照片URL',
  `taken_at`   DATETIME     NOT NULL COMMENT '拍摄时间（时间戳）',
  `longitude`  DECIMAL(10,7) DEFAULT NULL COMMENT '拍摄位置经度',
  `latitude`   DECIMAL(10,7) DEFAULT NULL COMMENT '拍摄位置纬度',
  `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_id_phase` (`order_id`, `phase`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务过程照片表';

-- ============================================================
-- 七、费用结算模块
-- ============================================================

-- 16. 费用明细表
CREATE TABLE `fee_detail` (
  `id`             BIGINT       NOT NULL AUTO_INCREMENT,
  `order_id`       BIGINT       NOT NULL COMMENT '订单ID',
  `service_fee`    DECIMAL(8,2) NOT NULL COMMENT '基础服务费',
  `overtime_fee`   DECIMAL(8,2) NOT NULL DEFAULT 0 COMMENT '超时费',
  `coupon_deduct`  DECIMAL(8,2) NOT NULL DEFAULT 0 COMMENT '优惠券抵扣',
  `actual_fee`     DECIMAL(8,2) NOT NULL COMMENT '实际应付总额',
  `deposit_fee`    DECIMAL(8,2) NOT NULL DEFAULT 0 COMMENT '已付定金',
  `tail_fee`       DECIMAL(8,2) NOT NULL DEFAULT 0 COMMENT '尾款金额',
  `commission_rate`DECIMAL(5,4) NOT NULL COMMENT '平台佣金比例（如0.2000=20%）',
  `commission_fee` DECIMAL(8,2) NOT NULL COMMENT '平台佣金金额',
  `cleaner_income` DECIMAL(8,2) NOT NULL COMMENT '保洁员实际收入',
  `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单费用明细表';

-- 17. 支付记录表
CREATE TABLE `payment_record` (
  `id`           BIGINT       NOT NULL AUTO_INCREMENT,
  `order_id`     BIGINT       NOT NULL COMMENT '订单ID',
  `pay_type`     TINYINT      NOT NULL COMMENT '支付类型：1=定金 2=尾款 3=全额',
  `amount`       DECIMAL(8,2) NOT NULL COMMENT '支付金额',
  `pay_method`   TINYINT      NOT NULL DEFAULT 99 COMMENT '支付方式：1=微信 2=支付宝 99=模拟支付',
  `pay_status`   TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：1=待支付 2=成功 3=失败',
  `pay_time`     DATETIME     DEFAULT NULL COMMENT '支付成功时间',
  `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付记录表';

-- 18. 保洁员收入明细表
CREATE TABLE `cleaner_income` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `cleaner_id`  BIGINT       NOT NULL COMMENT '保洁员user_id',
  `order_id`    BIGINT       NOT NULL COMMENT '来源订单ID',
  `amount`      DECIMAL(8,2) NOT NULL COMMENT '本单收入',
  `settle_month`VARCHAR(7)   NOT NULL COMMENT '结算月份（格式：2025-01）',
  `status`      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：1=待结算 2=已结算',
  `settled_at`  DATETIME     DEFAULT NULL COMMENT '实际结算时间',
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cleaner_settle` (`cleaner_id`, `settle_month`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='保洁员收入明细表';

-- ============================================================
-- 八、评价与售后模块
-- ============================================================

-- 19. 订单评价表
CREATE TABLE `order_review` (
  `id`              BIGINT       NOT NULL AUTO_INCREMENT,
  `order_id`        BIGINT       NOT NULL COMMENT '订单ID',
  `customer_id`     BIGINT       NOT NULL COMMENT '评价顾客user_id',
  `cleaner_id`      BIGINT       NOT NULL COMMENT '被评保洁员user_id',
  `score_attitude`  TINYINT      NOT NULL COMMENT '服务态度评分（1-5）',
  `score_quality`   TINYINT      NOT NULL COMMENT '清洁效果评分（1-5）',
  `score_punctual`  TINYINT      NOT NULL COMMENT '准时到达评分（1-5）',
  `avg_score`       DECIMAL(3,2) NOT NULL COMMENT '综合评分（三项均值）',
  `content`         VARCHAR(500) DEFAULT NULL COMMENT '文字评价',
  `imgs`            VARCHAR(1000) DEFAULT NULL COMMENT '评价图片URLs，逗号分隔',
  `is_visible`      TINYINT      NOT NULL DEFAULT 1 COMMENT '是否可见：1=可见 0=已屏蔽',
  `hide_reason`     VARCHAR(200) DEFAULT NULL COMMENT '屏蔽原因',
  `hidden_by`       BIGINT       DEFAULT NULL COMMENT '屏蔽操作管理员user_id',
  `reply_content`   VARCHAR(500) DEFAULT NULL COMMENT '保洁员回复内容',
  `replied_at`      DATETIME     DEFAULT NULL COMMENT '回复时间',
  `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_id` (`order_id`),
  KEY `idx_cleaner_id` (`cleaner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单评价表';

-- 20. 投诉与售后表
CREATE TABLE `complaint` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT,
  `order_id`      BIGINT       NOT NULL COMMENT '订单ID',
  `customer_id`   BIGINT       NOT NULL COMMENT '投诉顾客user_id',
  `cleaner_id`    BIGINT       NOT NULL COMMENT '被投诉保洁员user_id',
  `reason`        VARCHAR(500) NOT NULL COMMENT '投诉原因',
  `imgs`          VARCHAR(1000) DEFAULT NULL COMMENT '证明照片URLs，逗号分隔',
  `status`        TINYINT      NOT NULL DEFAULT 1 COMMENT '状态：1=待处理 2=处理中 3=已结案',
  `result`        TINYINT      DEFAULT NULL COMMENT '判定结果：1=全额退款 2=部分退款 3=驳回 4=免费重做',
  `refund_amount` DECIMAL(8,2) DEFAULT NULL COMMENT '退款金额（部分退款时）',
  `admin_remark`  VARCHAR(500) DEFAULT NULL COMMENT '管理员处理说明',
  `handled_by`    BIGINT       DEFAULT NULL COMMENT '处理管理员user_id',
  `handled_at`    DATETIME     DEFAULT NULL COMMENT '处理完成时间',
  `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='投诉与售后表';

-- ============================================================
-- 九、消息通知模块
-- ============================================================

-- 21. 站内消息表
CREATE TABLE `notification` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT       NOT NULL COMMENT '接收用户user_id',
  `type`        TINYINT      NOT NULL COMMENT '通知类型：1=下单成功 2=派单成功 3=保洁员上门 4=服务完成 5=新订单待接 6=审核结果 7=投诉通知 8=超时告警',
  `title`       VARCHAR(100) NOT NULL COMMENT '通知标题',
  `content`     VARCHAR(500) NOT NULL COMMENT '通知内容',
  `ref_id`      BIGINT       DEFAULT NULL COMMENT '关联业务ID（如订单ID）',
  `is_read`     TINYINT      NOT NULL DEFAULT 0 COMMENT '是否已读：0=未读 1=已读',
  `read_at`     DATETIME     DEFAULT NULL,
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_read` (`user_id`, `is_read`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='站内消息通知表';

-- ============================================================
-- 十、系统管理模块
-- ============================================================

-- 22. 系统参数配置表
CREATE TABLE `system_config` (
  `id`          INT          NOT NULL AUTO_INCREMENT,
  `config_key`  VARCHAR(50)  NOT NULL COMMENT '参数键',
  `config_value`VARCHAR(200) NOT NULL COMMENT '参数值',
  `description` VARCHAR(200) DEFAULT NULL COMMENT '参数说明',
  `updated_by`  BIGINT       DEFAULT NULL COMMENT '最后修改管理员user_id',
  `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统参数配置表';

-- 初始化服务类型数据
INSERT INTO `service_type` (`name`, `description`, `price_mode`, `base_price`, `min_duration`, `suggest_workers`, `sort_order`, `status`) VALUES
('日常保洁', '日常家庭清洁，吸尘拖地、擦拭家具、卫生间清洁，让家焕然一新', 1, 35.00, 120, 1, 100, 1),
('深度保洁', '全屋深度清洁，不留死角，包含橱柜内部、家电表面、墙壁等细节处理', 1, 50.00, 180, 2, 90, 1),
('开荒保洁', '新房装修后首次清洁，去除建筑污渍、墙壁灰尘、门窗玻璃等全面清洁', 1, 60.00, 240, 2, 80, 1),
('家电清洗', '空调、油烟机、洗衣机、冰箱等家电专业深度清洗，延长使用寿命', 3, 80.00, NULL, 1, 70, 1),
('玻璃清洗', '门窗玻璃、阳台玻璃专业清洁，还原通透效果', 2, 10.00, NULL, 1, 60, 1),
('地板打蜡', '木地板、复合地板专业养护打蜡，恢复光泽延长使用寿命', 2, 15.00, NULL, 1, 50, 1);

-- 玻璃清洗阶梯定价（id=5）
INSERT INTO `service_price_tier` (`service_type_id`, `area_min`, `area_max`, `unit_price`) VALUES
(5, 0,   50,  10.00),
(5, 50,  100,  9.00),
(5, 100, 9999, 8.00);

-- 地板打蜡阶梯定价（id=6）
INSERT INTO `service_price_tier` (`service_type_id`, `area_min`, `area_max`, `unit_price`) VALUES
(6, 0,   50,  15.00),
(6, 50,  100, 13.00),
(6, 100, 9999,12.00);

-- 初始化系统参数
INSERT INTO `system_config` (`config_key`, `config_value`, `description`) VALUES
('commission_rate',        '0.20',  '平台佣金比例，默认20%'),
('commute_buffer_minutes', '30',    '派单通勤缓冲时间（分钟）'),
('dispatch_timeout_minutes','30',   '保洁员接单响应超时时间（分钟）'),
('deposit_rate',           '0.20',  '定金比例，默认20%'),
('auto_confirm_hours',     '48',    '完工后自动确认等待时间（小时）'),
('checkin_max_distance_m', '500',   'GPS签到允许最大偏差距离（米）');

-- 23. 操作日志表
CREATE TABLE `operation_log` (
  `id`           BIGINT       NOT NULL AUTO_INCREMENT,
  `operator_id`  BIGINT       NOT NULL COMMENT '操作人user_id',
  `module`       VARCHAR(50)  NOT NULL COMMENT '操作模块（如：派单、审核、封禁）',
  `action`       VARCHAR(100) NOT NULL COMMENT '操作描述',
  `ref_id`       BIGINT       DEFAULT NULL COMMENT '关联业务ID',
  `before_data`  TEXT         DEFAULT NULL COMMENT '操作前数据快照（JSON）',
  `after_data`   TEXT         DEFAULT NULL COMMENT '操作后数据快照（JSON）',
  `ip`           VARCHAR(50)  DEFAULT NULL COMMENT '操作IP',
  `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_operator_id` (`operator_id`),
  KEY `idx_module` (`module`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员操作日志表';

-- ============================================================
-- 完成
-- ============================================================

-- 24. 改期申请表
CREATE TABLE `order_reschedule` (
  `id`            BIGINT       NOT NULL AUTO_INCREMENT,
  `order_id`      BIGINT       NOT NULL,
  `customer_id`   BIGINT       NOT NULL,
  `old_time`      DATETIME     NOT NULL COMMENT '原预约时间',
  `new_time`      DATETIME     NOT NULL COMMENT '申请改到的时间',
  `status`        TINYINT      NOT NULL DEFAULT 1 COMMENT '1=待审核 2=已通过 3=已拒绝',
  `handle_remark` VARCHAR(200) DEFAULT NULL,
  `handled_by`    BIGINT       DEFAULT NULL,
  `handled_at`    DATETIME     DEFAULT NULL,
  `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='改期申请表';
