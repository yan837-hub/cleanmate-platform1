/*
  CleanMate 居家保洁服务管理系统
  PowerDesigner PDM 导入专用 SQL
  外键策略：每张表保留 1~2 条核心外键，保持连线美观，去除冗余审计/操作人外键
  表数量：23 张
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ================================================
-- 根表（无外键）
-- ================================================

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id`         bigint       NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `phone`      varchar(20)  NOT NULL COMMENT '手机号（唯一）',
  `password`   varchar(100) NOT NULL COMMENT '密码（BCrypt）',
  `nickname`   varchar(50)      NULL DEFAULT NULL COMMENT '昵称',
  `avatar_url` varchar(255)     NULL DEFAULT NULL COMMENT '头像URL',
  `role`       tinyint      NOT NULL COMMENT '角色：1=顾客 2=保洁员 3=管理员',
  `status`     tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1=正常 2=待审核 3=停用 4=封禁',
  `created_at` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_phone` (`phone`)
) ENGINE = InnoDB COMMENT = '用户账号表';

DROP TABLE IF EXISTS `service_type`;
CREATE TABLE `service_type` (
  `id`              bigint       NOT NULL AUTO_INCREMENT,
  `name`            varchar(50)  NOT NULL COMMENT '服务名称',
  `description`     varchar(500)     NULL DEFAULT NULL COMMENT '服务描述',
  `cover_img`       varchar(255)     NULL DEFAULT NULL COMMENT '封面图URL',
  `price_mode`      tinyint      NOT NULL COMMENT '计价模式：1=按小时 2=按面积 3=固定套餐',
  `base_price`      decimal(8,2) NOT NULL COMMENT '基础单价',
  `min_duration`    int              NULL DEFAULT NULL COMMENT '最短服务时长（分钟）',
  `suggest_workers` int          NOT NULL DEFAULT 1 COMMENT '建议保洁员人数',
  `sort_order`      int          NOT NULL DEFAULT 0 COMMENT '排序权重',
  `status`          tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1=上架 2=下架',
  `created_at`      datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB COMMENT = '服务类型表';

DROP TABLE IF EXISTS `cleaning_company`;
CREATE TABLE `cleaning_company` (
  `id`            bigint       NOT NULL AUTO_INCREMENT,
  `name`          varchar(100) NOT NULL COMMENT '公司名称',
  `license_no`    varchar(50)      NULL DEFAULT NULL COMMENT '营业执照号',
  `license_img`   varchar(255)     NULL DEFAULT NULL COMMENT '营业执照图片URL',
  `contact_name`  varchar(50)      NULL DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20)      NULL DEFAULT NULL COMMENT '联系电话',
  `address`       varchar(200)     NULL DEFAULT NULL COMMENT '公司地址',
  `status`        tinyint      NOT NULL DEFAULT 2 COMMENT '状态：1=正常 2=待审核 3=停用',
  `audit_remark`  varchar(200)     NULL DEFAULT NULL COMMENT '审核备注',
  `audited_at`    datetime         NULL DEFAULT NULL COMMENT '审核时间',
  `created_at`    datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB COMMENT = '保洁公司表';

-- ================================================
-- 第二层：直接依赖根表
-- ================================================

DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config` (
  `id`           int          NOT NULL AUTO_INCREMENT,
  `config_key`   varchar(50)  NOT NULL COMMENT '参数键（唯一）',
  `config_value` varchar(200) NOT NULL COMMENT '参数值',
  `description`  varchar(200)     NULL DEFAULT NULL COMMENT '参数说明',
  `updated_by`   bigint           NULL DEFAULT NULL COMMENT '最后修改管理员user_id',
  `updated_at`   datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_config_key` (`config_key`),
  INDEX `fk_system_config_user` (`updated_by`),
  CONSTRAINT `fk_system_config_user`
    FOREIGN KEY (`updated_by`) REFERENCES `user` (`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '系统参数配置表';

DROP TABLE IF EXISTS `customer_address`;
CREATE TABLE `customer_address` (
  `id`            bigint       NOT NULL AUTO_INCREMENT,
  `user_id`       bigint       NOT NULL COMMENT '关联user.id',
  `label`         varchar(20)      NULL DEFAULT NULL COMMENT '地址标签',
  `contact_name`  varchar(50)  NOT NULL COMMENT '联系人姓名',
  `contact_phone` varchar(20)  NOT NULL COMMENT '联系电话',
  `province`      varchar(30)  NOT NULL COMMENT '省',
  `city`          varchar(30)  NOT NULL COMMENT '市',
  `district`      varchar(30)  NOT NULL COMMENT '区',
  `detail`        varchar(200) NOT NULL COMMENT '详细地址',
  `longitude`     decimal(10,7)    NULL DEFAULT NULL COMMENT '经度',
  `latitude`      decimal(10,7)    NULL DEFAULT NULL COMMENT '纬度',
  `is_default`    tinyint      NOT NULL DEFAULT 0 COMMENT '是否默认：1=是 0=否',
  `created_at`    datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_customer_address_user` (`user_id`),
  CONSTRAINT `fk_customer_address_user`
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '顾客地址表';

DROP TABLE IF EXISTS `service_price_tier`;
CREATE TABLE `service_price_tier` (
  `id`              bigint       NOT NULL AUTO_INCREMENT,
  `service_type_id` bigint       NOT NULL COMMENT '关联service_type.id',
  `area_min`        int          NOT NULL COMMENT '面积下限（㎡，含）',
  `area_max`        int          NOT NULL COMMENT '面积上限（㎡，不含）',
  `unit_price`      decimal(8,2) NOT NULL COMMENT '该区间单价（元/㎡）',
  PRIMARY KEY (`id`),
  INDEX `fk_price_tier_service_type` (`service_type_id`),
  CONSTRAINT `fk_price_tier_service_type`
    FOREIGN KEY (`service_type_id`) REFERENCES `service_type` (`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '面积阶梯定价表';

DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification` (
  `id`         bigint       NOT NULL AUTO_INCREMENT,
  `user_id`    bigint       NOT NULL COMMENT '接收用户user_id',
  `type`       tinyint      NOT NULL COMMENT '通知类型',
  `title`      varchar(100) NOT NULL COMMENT '通知标题',
  `content`    varchar(500) NOT NULL COMMENT '通知内容',
  `ref_id`     bigint           NULL DEFAULT NULL COMMENT '关联业务ID',
  `is_read`    tinyint      NOT NULL DEFAULT 0 COMMENT '是否已读：0=未读 1=已读',
  `read_at`    datetime         NULL DEFAULT NULL,
  `created_at` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_notification_user` (`user_id`),
  CONSTRAINT `fk_notification_user`
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '站内消息通知表';

DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log` (
  `id`          bigint       NOT NULL AUTO_INCREMENT,
  `operator_id` bigint       NOT NULL COMMENT '操作人user_id',
  `module`      varchar(50)  NOT NULL COMMENT '操作模块',
  `action`      varchar(100) NOT NULL COMMENT '操作描述',
  `ref_id`      bigint           NULL DEFAULT NULL COMMENT '关联业务ID',
  `before_data` text             NULL COMMENT '操作前数据快照（JSON）',
  `after_data`  text             NULL COMMENT '操作后数据快照（JSON）',
  `ip`          varchar(50)      NULL DEFAULT NULL COMMENT '操作IP',
  `created_at`  datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_operation_log_operator` (`operator_id`),
  CONSTRAINT `fk_operation_log_operator`
    FOREIGN KEY (`operator_id`) REFERENCES `user` (`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '管理员操作日志表';

-- ================================================
-- 第三层：依赖 user + cleaning_company
-- ================================================

DROP TABLE IF EXISTS `cleaner_profile`;
CREATE TABLE `cleaner_profile` (
  `id`              bigint       NOT NULL AUTO_INCREMENT,
  `user_id`         bigint       NOT NULL COMMENT '关联user.id',
  `real_name`       varchar(50)  NOT NULL COMMENT '真实姓名',
  `id_card`         varchar(20)  NOT NULL COMMENT '身份证号',
  `id_card_front`   varchar(255)     NULL DEFAULT NULL COMMENT '身份证正面URL',
  `id_card_back`    varchar(255)     NULL DEFAULT NULL COMMENT '身份证背面URL',
  `cert_img`        varchar(255)     NULL DEFAULT NULL COMMENT '资格证图片URL',
  `health_cert_img` varchar(255)     NULL DEFAULT NULL COMMENT '健康证图片URL',
  `company_id`      bigint           NULL DEFAULT NULL COMMENT '所属公司ID（可为空）',
  `service_area`    varchar(200)     NULL DEFAULT NULL COMMENT '服务区域描述',
  `longitude`       decimal(10,7)    NULL DEFAULT NULL COMMENT '常驻位置经度',
  `latitude`        decimal(10,7)    NULL DEFAULT NULL COMMENT '常驻位置纬度',
  `bio`             varchar(500)     NULL DEFAULT NULL COMMENT '个人简介',
  `skill_tags`      varchar(200)     NULL DEFAULT NULL COMMENT '技能标签（逗号分隔）',
  `avg_score`       decimal(3,2) NOT NULL DEFAULT 5.00 COMMENT '综合评分（1-5）',
  `order_count`     int          NOT NULL DEFAULT 0 COMMENT '累计接单数',
  `audit_status`    tinyint      NOT NULL DEFAULT 2 COMMENT '审核状态：1=通过 2=待审核 3=拒绝',
  `audit_remark`    varchar(200)     NULL DEFAULT NULL COMMENT '拒绝原因',
  `audited_at`      datetime         NULL DEFAULT NULL,
  `created_at`      datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_user_id` (`user_id`),
  INDEX `fk_cleaner_profile_company` (`company_id`),
  CONSTRAINT `fk_cleaner_profile_user`
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_cleaner_profile_company`
    FOREIGN KEY (`company_id`) REFERENCES `cleaning_company` (`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '保洁员扩展信息表';

DROP TABLE IF EXISTS `cleaner_schedule_template`;
CREATE TABLE `cleaner_schedule_template` (
  `id`          bigint   NOT NULL AUTO_INCREMENT,
  `cleaner_id`  bigint   NOT NULL COMMENT '保洁员user_id',
  `day_of_week` tinyint  NOT NULL COMMENT '星期几：1=周一 ... 7=周日',
  `start_time`  time     NOT NULL COMMENT '工作开始时间',
  `end_time`    time     NOT NULL COMMENT '工作结束时间',
  `created_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_cleaner_week` (`cleaner_id`, `day_of_week`),
  CONSTRAINT `fk_schedule_template_cleaner`
    FOREIGN KEY (`cleaner_id`) REFERENCES `user` (`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '保洁员每周固定档期模板';

DROP TABLE IF EXISTS `cleaner_schedule_override`;
CREATE TABLE `cleaner_schedule_override` (
  `id`         bigint       NOT NULL AUTO_INCREMENT,
  `cleaner_id` bigint       NOT NULL COMMENT '保洁员user_id',
  `date`       date         NOT NULL COMMENT '特殊调整日期',
  `is_off`     tinyint      NOT NULL DEFAULT 0 COMMENT '是否当天不可接单：1=是',
  `start_time` time             NULL DEFAULT NULL COMMENT '当日开始时间',
  `end_time`   time             NULL DEFAULT NULL COMMENT '当日结束时间',
  `remark`     varchar(100)     NULL DEFAULT NULL COMMENT '备注',
  `created_at` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_cleaner_date` (`cleaner_id`, `date`),
  CONSTRAINT `fk_schedule_override_cleaner`
    FOREIGN KEY (`cleaner_id`) REFERENCES `user` (`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '保洁员档期特殊调整表';

-- ================================================
-- 第四层：核心订单表（依赖 user + service_type + customer_address）
-- ================================================

DROP TABLE IF EXISTS `service_order`;
CREATE TABLE `service_order` (
  `id`               bigint       NOT NULL AUTO_INCREMENT,
  `order_no`         varchar(32)  NOT NULL COMMENT '订单编号（唯一）',
  `source`           tinyint      NOT NULL DEFAULT 1 COMMENT '订单来源：1=平台自营 2=外部导入 3=手动录入',
  `customer_id`      bigint       NOT NULL COMMENT '下单顾客user_id',
  `cleaner_id`       bigint           NULL DEFAULT NULL COMMENT '派单保洁员user_id',
  `service_type_id`  bigint       NOT NULL COMMENT '服务类型ID',
  `address_id`       bigint           NULL DEFAULT NULL COMMENT '服务地址ID',
  `address_snapshot` varchar(500) NOT NULL COMMENT '下单时地址快照',
  `longitude`        decimal(10,7)    NULL DEFAULT NULL COMMENT '服务地址经度',
  `latitude`         decimal(10,7)    NULL DEFAULT NULL COMMENT '服务地址纬度',
  `house_area`       decimal(6,1)     NULL DEFAULT NULL COMMENT '房屋面积（㎡）',
  `plan_duration`    int              NULL DEFAULT NULL COMMENT '预约服务时长（分钟）',
  `actual_duration`  int              NULL DEFAULT NULL COMMENT '实际服务时长（分钟）',
  `appoint_time`     datetime     NOT NULL COMMENT '预约上门时间',
  `remark`           varchar(500)     NULL DEFAULT NULL COMMENT '顾客备注',
  `status`           tinyint      NOT NULL DEFAULT 1 COMMENT '订单状态（1~8）',
  `cancel_reason`    varchar(200)     NULL DEFAULT NULL COMMENT '取消原因',
  `estimate_fee`     decimal(8,2)     NULL DEFAULT NULL COMMENT '预估费用',
  `actual_fee`       decimal(8,2)     NULL DEFAULT NULL COMMENT '实际费用',
  `deposit_fee`      decimal(8,2)     NULL DEFAULT NULL COMMENT '已付定金',
  `pay_status`       tinyint      NOT NULL DEFAULT 0 COMMENT '支付状态：0=未支付 1=已付定金 2=全额',
  `auto_confirm_at`  datetime         NULL DEFAULT NULL COMMENT '48h自动确认时间',
  `completed_at`     datetime         NULL DEFAULT NULL COMMENT '完成时间',
  `created_at`       datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_order_no` (`order_no`),
  INDEX `idx_customer_id` (`customer_id`),
  INDEX `fk_order_service_type` (`service_type_id`),
  INDEX `fk_order_address` (`address_id`),
  CONSTRAINT `fk_order_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `user` (`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_order_service_type`
    FOREIGN KEY (`service_type_id`) REFERENCES `service_type` (`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_order_address`
    FOREIGN KEY (`address_id`) REFERENCES `customer_address` (`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '服务订单表';

-- ================================================
-- 第五层：所有订单子表（统一挂 service_order）
-- ================================================

DROP TABLE IF EXISTS `cleaner_time_lock`;
CREATE TABLE `cleaner_time_lock` (
  `id`         bigint   NOT NULL AUTO_INCREMENT,
  `cleaner_id` bigint   NOT NULL COMMENT '保洁员user_id',
  `order_id`   bigint   NOT NULL COMMENT '关联订单ID',
  `lock_start` datetime NOT NULL COMMENT '锁定开始时间',
  `lock_end`   datetime NOT NULL COMMENT '锁定结束时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_order_id` (`order_id`),
  CONSTRAINT `fk_time_lock_order`
    FOREIGN KEY (`order_id`) REFERENCES `service_order` (`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '保洁员时段锁定表';

DROP TABLE IF EXISTS `dispatch_record`;
CREATE TABLE `dispatch_record` (
  `id`            bigint       NOT NULL AUTO_INCREMENT,
  `order_id`      bigint       NOT NULL COMMENT '订单ID',
  `cleaner_id`    bigint       NOT NULL COMMENT '被派保洁员user_id',
  `dispatch_type` tinyint      NOT NULL COMMENT '派单方式：1=系统自动 2=管理员手动 3=抢单',
  `score`         decimal(6,2)     NULL DEFAULT NULL COMMENT '综合得分',
  `distance_km`   decimal(6,2)     NULL DEFAULT NULL COMMENT '估算距离（km）',
  `status`        tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1=待响应 2=已接单 3=已拒绝 4=已超时',
  `respond_at`    datetime         NULL DEFAULT NULL COMMENT '保洁员响应时间',
  `expire_at`     datetime     NOT NULL COMMENT '响应截止时间',
  `operator_id`   bigint           NULL DEFAULT NULL COMMENT '手动派单管理员user_id',
  `created_at`    datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_dispatch_order` (`order_id`),
  CONSTRAINT `fk_dispatch_order`
    FOREIGN KEY (`order_id`) REFERENCES `service_order` (`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '派单记录表';

DROP TABLE IF EXISTS `checkin_record`;
CREATE TABLE `checkin_record` (
  `id`            bigint        NOT NULL AUTO_INCREMENT,
  `order_id`      bigint        NOT NULL COMMENT '订单ID',
  `cleaner_id`    bigint        NOT NULL COMMENT '保洁员user_id',
  `checkin_time`  datetime      NOT NULL COMMENT '签到时间',
  `longitude`     decimal(10,7)     NULL DEFAULT NULL COMMENT '签到经度',
  `latitude`      decimal(10,7)     NULL DEFAULT NULL COMMENT '签到纬度',
  `distance_m`    int               NULL DEFAULT NULL COMMENT '与订单地址偏差距离（米）',
  `is_abnormal`   tinyint       NOT NULL DEFAULT 0 COMMENT '是否异常：1=是',
  `handled_by`    bigint            NULL DEFAULT NULL COMMENT '异常处理管理员user_id',
  `handle_remark` varchar(200)      NULL DEFAULT NULL COMMENT '处理备注',
  `created_at`    datetime      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_order_id` (`order_id`),
  CONSTRAINT `fk_checkin_order`
    FOREIGN KEY (`order_id`) REFERENCES `service_order` (`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '保洁员签到打卡记录';

DROP TABLE IF EXISTS `service_photo`;
CREATE TABLE `service_photo` (
  `id`         bigint        NOT NULL AUTO_INCREMENT,
  `order_id`   bigint        NOT NULL COMMENT '订单ID',
  `cleaner_id` bigint        NOT NULL COMMENT '上传保洁员user_id',
  `phase`      tinyint       NOT NULL COMMENT '拍摄阶段：1=服务前 2=服务中 3=服务后',
  `img_url`    varchar(255)  NOT NULL COMMENT '照片URL',
  `taken_at`   datetime      NOT NULL COMMENT '拍摄时间',
  `longitude`  decimal(10,7)     NULL DEFAULT NULL COMMENT '拍摄经度',
  `latitude`   decimal(10,7)     NULL DEFAULT NULL COMMENT '拍摄纬度',
  `created_at` datetime      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_photo_order` (`order_id`),
  CONSTRAINT `fk_photo_order`
    FOREIGN KEY (`order_id`) REFERENCES `service_order` (`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '服务过程照片表';

DROP TABLE IF EXISTS `fee_detail`;
CREATE TABLE `fee_detail` (
  `id`              bigint       NOT NULL AUTO_INCREMENT,
  `order_id`        bigint       NOT NULL COMMENT '订单ID',
  `service_fee`     decimal(8,2) NOT NULL COMMENT '基础服务费',
  `overtime_fee`    decimal(8,2) NOT NULL DEFAULT 0.00 COMMENT '超时费',
  `coupon_deduct`   decimal(8,2) NOT NULL DEFAULT 0.00 COMMENT '优惠抵扣',
  `actual_fee`      decimal(8,2) NOT NULL COMMENT '实际应付总额',
  `deposit_fee`     decimal(8,2) NOT NULL DEFAULT 0.00 COMMENT '已付定金',
  `tail_fee`        decimal(8,2) NOT NULL DEFAULT 0.00 COMMENT '尾款金额',
  `commission_rate` decimal(5,4) NOT NULL COMMENT '平台佣金比例',
  `commission_fee`  decimal(8,2) NOT NULL COMMENT '平台佣金金额',
  `cleaner_income`  decimal(8,2) NOT NULL COMMENT '保洁员实际收入',
  `created_at`      datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_order_id` (`order_id`),
  CONSTRAINT `fk_fee_detail_order`
    FOREIGN KEY (`order_id`) REFERENCES `service_order` (`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '订单费用明细表';

DROP TABLE IF EXISTS `payment_record`;
CREATE TABLE `payment_record` (
  `id`         bigint       NOT NULL AUTO_INCREMENT,
  `order_id`   bigint       NOT NULL COMMENT '订单ID',
  `pay_type`   tinyint      NOT NULL COMMENT '支付类型：1=定金 2=尾款 3=全额',
  `amount`     decimal(8,2) NOT NULL COMMENT '支付金额',
  `pay_method` tinyint      NOT NULL DEFAULT 99 COMMENT '支付方式：1=微信 2=支付宝 99=模拟',
  `pay_status` tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1=待支付 2=成功 3=失败',
  `pay_time`   datetime         NULL DEFAULT NULL COMMENT '支付成功时间',
  `created_at` datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_payment_order` (`order_id`),
  CONSTRAINT `fk_payment_order`
    FOREIGN KEY (`order_id`) REFERENCES `service_order` (`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '支付记录表';

DROP TABLE IF EXISTS `cleaner_income`;
CREATE TABLE `cleaner_income` (
  `id`           bigint       NOT NULL AUTO_INCREMENT,
  `cleaner_id`   bigint       NOT NULL COMMENT '保洁员user_id',
  `order_id`     bigint       NOT NULL COMMENT '来源订单ID',
  `amount`       decimal(8,2) NOT NULL COMMENT '本单收入',
  `settle_month` varchar(7)   NOT NULL COMMENT '结算月份（格式：2025-01）',
  `status`       tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1=待结算 2=已结算',
  `settled_at`   datetime         NULL DEFAULT NULL COMMENT '实际结算时间',
  `created_at`   datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_order_id` (`order_id`),
  CONSTRAINT `fk_income_order`
    FOREIGN KEY (`order_id`) REFERENCES `service_order` (`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '保洁员收入明细表';

DROP TABLE IF EXISTS `order_review`;
CREATE TABLE `order_review` (
  `id`             bigint       NOT NULL AUTO_INCREMENT,
  `order_id`       bigint       NOT NULL COMMENT '订单ID',
  `customer_id`    bigint       NOT NULL COMMENT '评价顾客user_id',
  `cleaner_id`     bigint       NOT NULL COMMENT '被评保洁员user_id',
  `score_attitude` tinyint      NOT NULL COMMENT '服务态度评分（1-5）',
  `score_quality`  tinyint      NOT NULL COMMENT '清洁效果评分（1-5）',
  `score_punctual` tinyint      NOT NULL COMMENT '准时到达评分（1-5）',
  `avg_score`      decimal(3,2) NOT NULL COMMENT '综合评分（三项均值）',
  `content`        varchar(500)     NULL DEFAULT NULL COMMENT '文字评价',
  `imgs`           varchar(1000)    NULL DEFAULT NULL COMMENT '评价图片URLs',
  `is_visible`     tinyint      NOT NULL DEFAULT 1 COMMENT '是否可见：1=可见 0=已屏蔽',
  `hide_reason`    varchar(200)     NULL DEFAULT NULL COMMENT '屏蔽原因',
  `reply_content`  varchar(500)     NULL DEFAULT NULL COMMENT '保洁员回复',
  `replied_at`     datetime         NULL DEFAULT NULL COMMENT '回复时间',
  `created_at`     datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_order_id` (`order_id`),
  CONSTRAINT `fk_review_order`
    FOREIGN KEY (`order_id`) REFERENCES `service_order` (`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '订单评价表';

DROP TABLE IF EXISTS `complaint`;
CREATE TABLE `complaint` (
  `id`            bigint       NOT NULL AUTO_INCREMENT,
  `order_id`      bigint       NOT NULL COMMENT '订单ID',
  `customer_id`   bigint       NOT NULL COMMENT '投诉顾客user_id',
  `cleaner_id`    bigint       NOT NULL COMMENT '被投诉保洁员user_id',
  `reason`        varchar(500) NOT NULL COMMENT '投诉原因',
  `imgs`          varchar(1000)    NULL DEFAULT NULL COMMENT '证明照片URLs',
  `status`        tinyint      NOT NULL DEFAULT 1 COMMENT '状态：1=待处理 2=处理中 3=已结案',
  `result`        tinyint          NULL DEFAULT NULL COMMENT '处理结果：1=全额退款 2=部分退款 3=驳回 4=调解',
  `refund_amount` decimal(8,2)     NULL DEFAULT NULL COMMENT '退款金额',
  `admin_remark`  varchar(500)     NULL DEFAULT NULL COMMENT '管理员处理说明',
  `handled_at`    datetime         NULL DEFAULT NULL COMMENT '处理完成时间',
  `created_at`    datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_complaint_order` (`order_id`),
  CONSTRAINT `fk_complaint_order`
    FOREIGN KEY (`order_id`) REFERENCES `service_order` (`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '投诉与售后表';

DROP TABLE IF EXISTS `order_reschedule`;
CREATE TABLE `order_reschedule` (
  `id`            bigint       NOT NULL AUTO_INCREMENT,
  `order_id`      bigint       NOT NULL COMMENT '订单ID',
  `customer_id`   bigint       NOT NULL COMMENT '申请顾客user_id',
  `old_time`      datetime     NOT NULL COMMENT '原预约时间',
  `new_time`      datetime     NOT NULL COMMENT '申请改到的时间',
  `status`        tinyint      NOT NULL DEFAULT 1 COMMENT '1=待审核 2=已通过 3=已拒绝',
  `handle_remark` varchar(200)     NULL DEFAULT NULL COMMENT '处理备注',
  `handled_at`    datetime         NULL DEFAULT NULL,
  `created_at`    datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_reschedule_order` (`order_id`),
  CONSTRAINT `fk_reschedule_order`
    FOREIGN KEY (`order_id`) REFERENCES `service_order` (`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '改期申请表';

DROP TABLE IF EXISTS `order_status_log`;
CREATE TABLE `order_status_log` (
  `id`          bigint       NOT NULL AUTO_INCREMENT,
  `order_id`    bigint       NOT NULL COMMENT '订单ID',
  `from_status` tinyint          NULL DEFAULT NULL COMMENT '流转前状态',
  `to_status`   tinyint      NOT NULL COMMENT '流转后状态',
  `operator_id` bigint           NULL DEFAULT NULL COMMENT '操作人user_id（系统触发时为NULL）',
  `remark`      varchar(200)     NULL DEFAULT NULL COMMENT '备注',
  `created_at`  datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_status_log_order` (`order_id`),
  CONSTRAINT `fk_status_log_order`
    FOREIGN KEY (`order_id`) REFERENCES `service_order` (`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB COMMENT = '订单状态流转日志';

SET FOREIGN_KEY_CHECKS = 1;
