/*
 Navicat Premium Dump SQL

 Source Server         : mysql
 Source Server Type    : MySQL
 Source Server Version : 80037 (8.0.37)
 Source Host           : localhost:3306
 Source Schema         : cleaning_service

 Target Server Type    : MySQL
 Target Server Version : 80037 (8.0.37)
 File Encoding         : 65001

 Date: 11/04/2026 16:38:38
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for checkin_record
-- ----------------------------
DROP TABLE IF EXISTS `checkin_record`;
CREATE TABLE `checkin_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `cleaner_id` bigint NOT NULL COMMENT '保洁员user_id',
  `checkin_time` datetime NOT NULL COMMENT '签到时间',
  `longitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '签到位置经度',
  `latitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '签到位置纬度',
  `distance_m` int NULL DEFAULT NULL COMMENT '与订单地址偏差距离（米）',
  `is_abnormal` tinyint NOT NULL DEFAULT 0 COMMENT '是否位置异常（偏差>500m）：1=是',
  `handled_by` bigint NULL DEFAULT NULL COMMENT '异常处理管理员user_id',
  `handle_remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '异常处理备注',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_cleaner_id`(`cleaner_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 40 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '保洁员签到打卡记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of checkin_record
-- ----------------------------
INSERT INTO `checkin_record` VALUES (1, 2, 7, '2026-03-20 20:47:41', 106.5269455, 29.4580025, 0, 0, NULL, NULL, '2026-03-20 20:47:41');
INSERT INTO `checkin_record` VALUES (2, 7, 7, '2026-03-21 13:41:11', 106.7819730, 29.7142590, 27900, 1, NULL, NULL, '2026-03-21 13:41:11');
INSERT INTO `checkin_record` VALUES (3, 10, 7, '2026-03-21 17:11:42', 106.5269455, 29.4580025, 11920, 1, NULL, NULL, '2026-03-21 17:11:42');
INSERT INTO `checkin_record` VALUES (4, 11, 7, '2026-03-22 15:00:07', 106.5269379, 29.4580082, 11920, 1, NULL, NULL, '2026-03-22 15:00:07');
INSERT INTO `checkin_record` VALUES (5, 12, 10, '2026-03-22 15:15:52', 106.5269455, 29.4580025, 11920, 1, NULL, NULL, '2026-03-22 15:15:52');
INSERT INTO `checkin_record` VALUES (6, 17, 7, '2026-03-22 17:49:10', 106.5269455, 29.4580025, 0, 0, NULL, NULL, '2026-03-22 17:49:10');
INSERT INTO `checkin_record` VALUES (7, 24, 7, '2026-03-23 14:58:55', 106.5269492, 29.4579978, 11920, 1, NULL, NULL, '2026-03-23 14:58:55');
INSERT INTO `checkin_record` VALUES (8, 19, 7, '2026-03-24 16:27:38', 106.5269411, 29.4580086, 16660, 1, NULL, NULL, '2026-03-24 16:27:38');
INSERT INTO `checkin_record` VALUES (9, 55, 13, '2026-03-27 16:07:53', 106.5269283, 29.4580346, 6860, 1, NULL, NULL, '2026-03-27 16:07:53');
INSERT INTO `checkin_record` VALUES (10, 56, 7, '2026-03-27 16:32:16', 106.5269177, 29.4580484, 11910, 1, NULL, NULL, '2026-03-27 16:32:16');
INSERT INTO `checkin_record` VALUES (11, 57, 11, '2026-03-27 16:46:04', 106.5269258, 29.4580379, 11910, 1, NULL, NULL, '2026-03-27 16:46:04');
INSERT INTO `checkin_record` VALUES (12, 59, 14, '2026-03-28 14:19:50', 106.5269302, 29.4580237, 6860, 1, 8, '', '2026-03-28 14:19:50');
INSERT INTO `checkin_record` VALUES (13, 70, 12, '2026-03-31 16:15:02', 106.5269592, 29.4579240, 200, 0, NULL, NULL, '2026-03-31 16:15:02');
INSERT INTO `checkin_record` VALUES (14, 72, 14, '2026-03-31 19:55:04', 106.5269226, 29.4580405, 180, 0, NULL, NULL, '2026-03-31 19:55:04');
INSERT INTO `checkin_record` VALUES (15, 84, 7, '2026-04-08 01:07:21', 106.5269265, 29.4580351, 180, 0, NULL, NULL, '2026-04-08 01:07:21');
INSERT INTO `checkin_record` VALUES (16, 85, 11, '2026-04-08 01:34:27', 106.5269389, 29.4580132, 190, 0, NULL, NULL, '2026-04-08 01:34:27');
INSERT INTO `checkin_record` VALUES (17, 86, 13, '2026-04-08 01:41:37', 106.5269435, 29.4580083, 190, 0, NULL, NULL, '2026-04-08 01:41:37');
INSERT INTO `checkin_record` VALUES (18, 87, 10, '2026-04-08 01:46:34', 106.5269389, 29.4580132, 190, 0, NULL, NULL, '2026-04-08 01:46:34');
INSERT INTO `checkin_record` VALUES (19, 88, 12, '2026-04-08 01:52:35', 106.5269304, 29.4580309, 180, 0, NULL, NULL, '2026-04-08 01:52:35');
INSERT INTO `checkin_record` VALUES (20, 89, 14, '2026-04-08 02:31:26', 106.5269302, 29.4580237, 190, 0, NULL, NULL, '2026-04-08 02:31:26');
INSERT INTO `checkin_record` VALUES (21, 91, 14, '2026-04-08 03:55:30', 106.5269265, 29.4580351, 180, 0, NULL, NULL, '2026-04-08 03:55:30');
INSERT INTO `checkin_record` VALUES (22, 92, 7, '2026-04-08 04:00:30', 106.5269457, 29.4579945, 190, 0, NULL, NULL, '2026-04-08 04:00:30');
INSERT INTO `checkin_record` VALUES (23, 94, 12, '2026-04-09 14:23:12', 106.5269337, 29.4580215, 4650, 0, NULL, NULL, '2026-04-09 14:23:12');
INSERT INTO `checkin_record` VALUES (24, 99, 7, '2026-04-09 21:51:07', 106.5223100, 29.4522100, 13710, 1, NULL, NULL, '2026-04-09 21:51:07');
INSERT INTO `checkin_record` VALUES (29, 101, 11, '2026-04-09 22:04:35', 106.5269490, 29.4579963, 13040, 1, 8, '正常', '2026-04-09 22:04:35');
INSERT INTO `checkin_record` VALUES (30, 100, 14, '2026-04-09 22:10:11', 106.5269415, 29.4579985, 4650, 0, NULL, NULL, '2026-04-09 22:10:11');
INSERT INTO `checkin_record` VALUES (31, 103, 12, '2026-04-09 22:17:30', 106.5269221, 29.4580393, 12560, 1, 8, '', '2026-04-09 22:17:30');
INSERT INTO `checkin_record` VALUES (37, 108, 14, '2026-04-10 12:24:49', 106.5269179, 29.4580508, 4650, 0, NULL, NULL, '2026-04-10 12:24:49');
INSERT INTO `checkin_record` VALUES (38, 111, 10, '2026-04-10 12:47:12', 106.5269385, 29.4580082, 4650, 0, NULL, NULL, '2026-04-10 12:47:12');
INSERT INTO `checkin_record` VALUES (39, 116, 10, '2026-04-10 22:46:41', 106.5269167, 29.4580523, 4650, 0, NULL, NULL, '2026-04-10 22:46:41');

-- ----------------------------
-- Table structure for cleaner_income
-- ----------------------------
DROP TABLE IF EXISTS `cleaner_income`;
CREATE TABLE `cleaner_income`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cleaner_id` bigint NOT NULL COMMENT '保洁员user_id',
  `order_id` bigint NOT NULL COMMENT '来源订单ID',
  `amount` decimal(8, 2) NOT NULL COMMENT '本单收入',
  `settle_month` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '结算月份（格式：2025-01）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=待结算 2=已结算',
  `settled_at` datetime NULL DEFAULT NULL COMMENT '实际结算时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_cleaner_settle`(`cleaner_id` ASC, `settle_month` ASC) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '保洁员收入明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cleaner_income
-- ----------------------------
INSERT INTO `cleaner_income` VALUES (1, 7, 17, 56.00, '2026-03', 1, NULL, '2026-03-22 17:49:13');
INSERT INTO `cleaner_income` VALUES (2, 7, 24, 96.00, '2026-03', 1, NULL, '2026-03-23 14:58:58');
INSERT INTO `cleaner_income` VALUES (3, 7, 19, 56.00, '2026-03', 1, NULL, '2026-03-24 16:27:40');
INSERT INTO `cleaner_income` VALUES (4, 13, 55, 56.00, '2026-03', 1, NULL, '2026-03-27 16:07:56');
INSERT INTO `cleaner_income` VALUES (5, 7, 56, 56.00, '2026-03', 1, NULL, '2026-03-27 16:32:20');
INSERT INTO `cleaner_income` VALUES (6, 11, 57, 64.00, '2026-03', 1, NULL, '2026-03-27 16:46:06');
INSERT INTO `cleaner_income` VALUES (7, 14, 59, 540.00, '2026-03', 1, NULL, '2026-03-28 14:19:53');
INSERT INTO `cleaner_income` VALUES (8, 12, 70, 159.20, '2026-03', 1, NULL, '2026-03-31 16:15:05');
INSERT INTO `cleaner_income` VALUES (9, 14, 72, 80.00, '2026-03', 1, NULL, '2026-03-31 19:55:32');
INSERT INTO `cleaner_income` VALUES (10, 7, 84, 132.00, '2026-04', 1, NULL, '2026-04-08 01:07:32');
INSERT INTO `cleaner_income` VALUES (11, 11, 85, 80.00, '2026-04', 1, NULL, '2026-04-08 01:34:59');
INSERT INTO `cleaner_income` VALUES (12, 13, 86, 64.00, '2026-04', 1, NULL, '2026-04-08 01:41:45');
INSERT INTO `cleaner_income` VALUES (13, 10, 87, 140.00, '2026-04', 1, NULL, '2026-04-08 01:46:42');
INSERT INTO `cleaner_income` VALUES (14, 12, 88, 240.00, '2026-04', 1, NULL, '2026-04-08 01:53:09');
INSERT INTO `cleaner_income` VALUES (15, 14, 89, 120.00, '2026-04', 1, NULL, '2026-04-08 02:31:33');
INSERT INTO `cleaner_income` VALUES (16, 14, 91, 159.20, '2026-04', 2, '2026-04-10 10:59:08', '2026-04-08 03:58:59');
INSERT INTO `cleaner_income` VALUES (17, 7, 92, 64.00, '2026-04', 2, '2026-04-10 10:59:08', '2026-04-08 04:00:57');
INSERT INTO `cleaner_income` VALUES (18, 12, 94, 159.20, '2026-04', 2, '2026-04-09 14:23:49', '2026-04-09 14:23:19');
INSERT INTO `cleaner_income` VALUES (19, 14, 100, 132.00, '2026-04', 1, NULL, '2026-04-09 22:10:19');
INSERT INTO `cleaner_income` VALUES (20, 12, 103, 159.20, '2026-04', 1, NULL, '2026-04-09 22:50:06');
INSERT INTO `cleaner_income` VALUES (21, 14, 108, 120.00, '2026-04', 2, '2026-04-10 13:38:44', '2026-04-10 12:24:55');
INSERT INTO `cleaner_income` VALUES (22, 10, 111, 42.00, '2026-04', 1, NULL, '2026-04-10 12:47:17');
INSERT INTO `cleaner_income` VALUES (23, 10, 116, 118.50, '2026-04', 2, '2026-04-10 22:47:01', '2026-04-10 22:46:47');

-- ----------------------------
-- Table structure for cleaner_profile
-- ----------------------------
DROP TABLE IF EXISTS `cleaner_profile`;
CREATE TABLE `cleaner_profile`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '关联user.id',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '真实姓名',
  `id_card` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '身份证号',
  `id_card_front` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '身份证正面URL',
  `id_card_back` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '身份证背面URL',
  `cert_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '资格证图片URL',
  `health_cert_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '健康证图片URL',
  `company_id` bigint NULL DEFAULT NULL COMMENT '所属公司ID，可为空（个人保洁员）',
  `service_area` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '服务区域描述',
  `longitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '常驻位置经度（用于派单距离计算）',
  `latitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '常驻位置纬度',
  `bio` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '个人简介',
  `skill_tags` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '擅长服务类型标签，逗号分隔',
  `avg_score` decimal(3, 2) NOT NULL DEFAULT 5.00 COMMENT '综合评分（1-5）',
  `order_count` int NOT NULL DEFAULT 0 COMMENT '累计接单数',
  `audit_status` tinyint NOT NULL DEFAULT 2 COMMENT '审核状态：1=通过 2=待审核 3=拒绝',
  `audit_remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拒绝原因',
  `audited_by` bigint NULL DEFAULT NULL COMMENT '审核管理员user_id',
  `audited_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_company_id`(`company_id` ASC) USING BTREE,
  INDEX `idx_audit_status`(`audit_status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '保洁员扩展信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cleaner_profile
-- ----------------------------
INSERT INTO `cleaner_profile` VALUES (1, 7, '测试保洁员', '500101199001011234', NULL, NULL, NULL, NULL, 2, '重庆市', 106.5390390, 29.5934040, '专业保洁5年经验', '家电清洗,油烟机清洗', 4.43, 0, 1, NULL, NULL, NULL, '2026-03-20 20:31:04', '2026-03-28 00:11:48');
INSERT INTO `cleaner_profile` VALUES (3, 10, '李保洁', '500101199005055678', NULL, NULL, NULL, NULL, NULL, '重庆市渝北区', 106.5269390, 29.4580130, '专业保洁3年经验，擅长深度清洁！', '', 4.84, 0, 1, NULL, NULL, '2026-03-21 15:44:07', '2026-03-21 15:44:07', '2026-03-21 15:44:07');
INSERT INTO `cleaner_profile` VALUES (4, 12, '陈志伟', '110101199308124317', 'http://localhost:8080/api/files/profile_7ba5cd51201148fdb15b4556ff5b6afa.jpg', 'http://localhost:8080/api/files/profile_7033c7c28a51415bae2d2e2b2d76fec6.jpg', NULL, NULL, NULL, '重庆市江北区、渝北区', 106.5269560, 29.4579280, '', '家庭保洁,深度清洁', 5.00, 0, 1, '', 8, '2026-03-22 23:06:42', '2026-03-22 23:01:29', '2026-03-22 23:01:29');
INSERT INTO `cleaner_profile` VALUES (5, 11, '王芳', '500101199205154521', NULL, NULL, NULL, NULL, NULL, '重庆市渝中区、南岸区', 106.5267910, 29.5753660, '', '家庭保洁,开荒保洁', 4.84, 0, 1, '', 8, '2026-03-22 23:44:21', '2026-03-22 23:42:28', '2026-03-22 23:42:28');
INSERT INTO `cleaner_profile` VALUES (6, 13, '陈晓燕', '500112199906154316', NULL, NULL, NULL, NULL, 2, '巴南', 106.5269060, 29.4580610, '', '日常保洁,地板打蜡', 5.00, 0, 1, '', 8, '2026-03-25 15:42:21', '2026-03-25 15:33:40', '2026-03-25 15:41:58');
INSERT INTO `cleaner_profile` VALUES (7, 14, '刘建国', '110101199001011234', NULL, NULL, NULL, NULL, 1, '朝阳区、东城区', 106.5269300, 29.4580240, '', '日常保洁,深度保洁,油烟机清洗', 4.75, 32, 1, NULL, NULL, NULL, '2026-03-25 15:40:32', '2026-03-25 15:40:32');
INSERT INTO `cleaner_profile` VALUES (8, 15, '赵芳芳', '110101199205153456', NULL, NULL, NULL, NULL, 1, '海淀区、西城区', NULL, NULL, NULL, '日常保洁,家电清洗', 4.90, 47, 1, NULL, NULL, NULL, '2026-03-25 15:40:32', '2026-03-25 15:40:32');
INSERT INTO `cleaner_profile` VALUES (9, 16, '孙小梅', '110101198808084567', NULL, NULL, NULL, NULL, 2, '丰台区、大兴区', NULL, NULL, NULL, '开荒保洁,玻璃清洗', 4.70, 18, 1, NULL, NULL, NULL, '2026-03-25 15:40:32', '2026-03-25 15:40:32');
INSERT INTO `cleaner_profile` VALUES (10, 17, '吴伟', '110101199503215678', NULL, NULL, NULL, NULL, 2, '朝阳区、通州区', NULL, NULL, NULL, '深度保洁,地板打蜡', 4.60, 25, 1, NULL, NULL, NULL, '2026-03-25 15:40:32', '2026-03-25 15:40:32');
INSERT INTO `cleaner_profile` VALUES (11, 18, '郑丽丽', '110101199112126789', NULL, NULL, NULL, NULL, 3, '海淀区、昌平区', NULL, NULL, NULL, '日常保洁,家电清洗,玻璃清洗', 4.95, 61, 1, NULL, NULL, NULL, '2026-03-25 15:40:32', '2026-03-25 15:40:32');
INSERT INTO `cleaner_profile` VALUES (12, 19, '李春花', '110101199007077890', NULL, NULL, NULL, NULL, NULL, '西城区、东城区', NULL, NULL, NULL, '日常保洁,深度保洁', 4.85, 40, 1, NULL, NULL, NULL, '2026-03-25 15:40:32', '2026-03-25 15:40:32');
INSERT INTO `cleaner_profile` VALUES (13, 20, '王大明', '110101198802021111', NULL, NULL, NULL, NULL, NULL, '朝阳区', NULL, NULL, NULL, '开荒保洁,地板打蜡', 4.50, 12, 1, NULL, NULL, NULL, '2026-03-25 15:40:32', '2026-03-25 15:40:32');
INSERT INTO `cleaner_profile` VALUES (14, 21, '张秀英', '110101199304152222', NULL, NULL, NULL, NULL, NULL, '海淀区、石景山区', NULL, NULL, NULL, '日常保洁,家电清洗,沙发清洗', 4.75, 28, 1, '', 8, '2026-03-25 15:42:24', '2026-03-25 15:40:32', '2026-03-25 15:40:32');
INSERT INTO `cleaner_profile` VALUES (15, 44, '王志', '500101199001011235', 'http://localhost:8080/api/files/profile_ed20da41df59487896e6150422c756d8.jpg', NULL, NULL, NULL, 4, '', 106.5269310, 29.4580220, '111', '日常保洁,深度保洁,油烟机清洗,开荒保洁,家电清洗,玻璃清洗,地板打蜡', 5.00, 0, 1, '', 8, '2026-04-08 02:14:18', '2026-04-08 02:11:48', '2026-04-08 02:11:48');

-- ----------------------------
-- Table structure for cleaner_schedule_override
-- ----------------------------
DROP TABLE IF EXISTS `cleaner_schedule_override`;
CREATE TABLE `cleaner_schedule_override`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cleaner_id` bigint NOT NULL COMMENT '保洁员user_id',
  `date` date NOT NULL COMMENT '特殊调整日期',
  `is_off` tinyint NOT NULL DEFAULT 0 COMMENT '是否全天不可接单：1=是',
  `start_time` time NULL DEFAULT NULL COMMENT '当日可工作开始时间（is_off=0时有效）',
  `end_time` time NULL DEFAULT NULL COMMENT '当日可工作结束时间',
  `remark` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注（如：请假）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_cleaner_date`(`cleaner_id` ASC, `date` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '保洁员档期特殊调整表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cleaner_schedule_override
-- ----------------------------
INSERT INTO `cleaner_schedule_override` VALUES (1, 7, '2026-03-29', 0, '12:58:00', '17:58:00', '下午可加单', '2026-03-22 17:58:25');
INSERT INTO `cleaner_schedule_override` VALUES (4, 12, '2026-04-12', 0, '12:53:00', '19:31:00', NULL, '2026-04-10 12:53:56');

-- ----------------------------
-- Table structure for cleaner_schedule_template
-- ----------------------------
DROP TABLE IF EXISTS `cleaner_schedule_template`;
CREATE TABLE `cleaner_schedule_template`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cleaner_id` bigint NOT NULL COMMENT '保洁员user_id',
  `day_of_week` tinyint NOT NULL COMMENT '星期几：1=周一 ... 7=周日',
  `start_time` time NOT NULL COMMENT '工作开始时间',
  `end_time` time NOT NULL COMMENT '工作结束时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_cleaner_id`(`cleaner_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_cleaner_week`(`cleaner_id` ASC, `day_of_week` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 217 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '保洁员每周固定档期模板' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cleaner_schedule_template
-- ----------------------------
INSERT INTO `cleaner_schedule_template` VALUES (155, 11, 1, '09:00:00', '22:00:00', '2026-04-08 01:34:02');
INSERT INTO `cleaner_schedule_template` VALUES (156, 11, 2, '09:00:00', '22:00:00', '2026-04-08 01:34:02');
INSERT INTO `cleaner_schedule_template` VALUES (157, 11, 3, '01:24:00', '20:00:00', '2026-04-08 01:34:02');
INSERT INTO `cleaner_schedule_template` VALUES (158, 11, 4, '09:00:00', '20:00:00', '2026-04-08 01:34:02');
INSERT INTO `cleaner_schedule_template` VALUES (159, 11, 5, '09:00:00', '20:00:00', '2026-04-08 01:34:02');
INSERT INTO `cleaner_schedule_template` VALUES (160, 11, 6, '09:00:00', '20:00:00', '2026-04-08 01:34:02');
INSERT INTO `cleaner_schedule_template` VALUES (167, 13, 1, '09:00:00', '20:00:00', '2026-04-08 01:41:08');
INSERT INTO `cleaner_schedule_template` VALUES (168, 13, 2, '09:00:00', '20:00:00', '2026-04-08 01:41:08');
INSERT INTO `cleaner_schedule_template` VALUES (169, 13, 3, '01:38:00', '20:00:00', '2026-04-08 01:41:08');
INSERT INTO `cleaner_schedule_template` VALUES (170, 13, 4, '09:00:00', '20:00:00', '2026-04-08 01:41:08');
INSERT INTO `cleaner_schedule_template` VALUES (171, 13, 5, '09:00:00', '20:00:00', '2026-04-08 01:41:08');
INSERT INTO `cleaner_schedule_template` VALUES (172, 13, 6, '09:00:00', '20:00:00', '2026-04-08 01:41:08');
INSERT INTO `cleaner_schedule_template` VALUES (179, 12, 1, '09:00:00', '22:00:00', '2026-04-08 01:52:13');
INSERT INTO `cleaner_schedule_template` VALUES (180, 12, 2, '09:00:00', '21:49:00', '2026-04-08 01:52:13');
INSERT INTO `cleaner_schedule_template` VALUES (181, 12, 3, '01:49:00', '20:00:00', '2026-04-08 01:52:13');
INSERT INTO `cleaner_schedule_template` VALUES (182, 12, 4, '09:00:00', '20:00:00', '2026-04-08 01:52:13');
INSERT INTO `cleaner_schedule_template` VALUES (183, 12, 5, '09:00:00', '20:00:00', '2026-04-08 01:52:13');
INSERT INTO `cleaner_schedule_template` VALUES (184, 12, 6, '09:00:00', '20:00:00', '2026-04-08 01:52:13');
INSERT INTO `cleaner_schedule_template` VALUES (185, 10, 1, '09:00:00', '22:00:00', '2026-04-08 01:57:00');
INSERT INTO `cleaner_schedule_template` VALUES (186, 10, 2, '09:00:00', '20:00:00', '2026-04-08 01:57:00');
INSERT INTO `cleaner_schedule_template` VALUES (187, 10, 3, '00:00:00', '22:00:00', '2026-04-08 01:57:00');
INSERT INTO `cleaner_schedule_template` VALUES (188, 10, 4, '09:00:00', '20:00:00', '2026-04-08 01:57:00');
INSERT INTO `cleaner_schedule_template` VALUES (189, 10, 5, '09:00:00', '20:00:00', '2026-04-08 01:57:00');
INSERT INTO `cleaner_schedule_template` VALUES (190, 10, 6, '09:00:00', '20:00:00', '2026-04-08 01:57:00');
INSERT INTO `cleaner_schedule_template` VALUES (204, 7, 1, '08:49:00', '23:00:00', '2026-04-09 21:48:41');
INSERT INTO `cleaner_schedule_template` VALUES (205, 7, 2, '08:49:00', '23:59:00', '2026-04-09 21:48:41');
INSERT INTO `cleaner_schedule_template` VALUES (206, 7, 3, '00:00:00', '22:00:00', '2026-04-09 21:48:41');
INSERT INTO `cleaner_schedule_template` VALUES (207, 7, 4, '08:49:00', '23:59:00', '2026-04-09 21:48:41');
INSERT INTO `cleaner_schedule_template` VALUES (208, 7, 5, '07:49:00', '20:49:00', '2026-04-09 21:48:41');
INSERT INTO `cleaner_schedule_template` VALUES (209, 7, 6, '09:49:00', '21:49:00', '2026-04-09 21:48:41');
INSERT INTO `cleaner_schedule_template` VALUES (210, 7, 7, '07:15:00', '20:15:00', '2026-04-09 21:48:41');
INSERT INTO `cleaner_schedule_template` VALUES (211, 14, 1, '09:00:00', '20:00:00', '2026-04-10 12:35:06');
INSERT INTO `cleaner_schedule_template` VALUES (212, 14, 2, '09:00:00', '22:00:00', '2026-04-10 12:35:06');
INSERT INTO `cleaner_schedule_template` VALUES (213, 14, 3, '00:00:00', '20:00:00', '2026-04-10 12:35:06');
INSERT INTO `cleaner_schedule_template` VALUES (214, 14, 4, '09:00:00', '20:00:00', '2026-04-10 12:35:06');
INSERT INTO `cleaner_schedule_template` VALUES (215, 14, 5, '09:00:00', '20:00:00', '2026-04-10 12:35:06');
INSERT INTO `cleaner_schedule_template` VALUES (216, 14, 6, '09:00:00', '20:00:00', '2026-04-10 12:35:06');

-- ----------------------------
-- Table structure for cleaner_time_lock
-- ----------------------------
DROP TABLE IF EXISTS `cleaner_time_lock`;
CREATE TABLE `cleaner_time_lock`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cleaner_id` bigint NOT NULL COMMENT '保洁员user_id',
  `order_id` bigint NOT NULL COMMENT '关联订单ID',
  `lock_start` datetime NOT NULL COMMENT '锁定开始时间（含通勤缓冲）',
  `lock_end` datetime NOT NULL COMMENT '锁定结束时间（含通勤缓冲）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_cleaner_id_time`(`cleaner_id` ASC, `lock_start` ASC, `lock_end` ASC) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 108 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '保洁员时段锁定表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cleaner_time_lock
-- ----------------------------
INSERT INTO `cleaner_time_lock` VALUES (2, 7, 3, '2026-03-22 07:30:17', '2026-03-22 10:30:17', '2026-03-20 19:59:08');
INSERT INTO `cleaner_time_lock` VALUES (3, 7, 2, '2026-03-24 23:30:00', '2026-03-25 04:30:00', '2026-03-20 19:59:09');
INSERT INTO `cleaner_time_lock` VALUES (6, 7, 7, '2026-03-21 14:07:39', '2026-03-21 17:07:39', '2026-03-21 13:38:19');
INSERT INTO `cleaner_time_lock` VALUES (8, 10, 9, '2026-03-21 18:07:06', '2026-03-21 23:07:06', '2026-03-21 15:58:53');
INSERT INTO `cleaner_time_lock` VALUES (9, 7, 10, '2026-03-21 17:15:56', '2026-03-21 20:15:56', '2026-03-21 17:11:34');
INSERT INTO `cleaner_time_lock` VALUES (10, 7, 11, '2026-03-22 14:59:11', '2026-03-22 18:59:11', '2026-03-22 14:59:59');
INSERT INTO `cleaner_time_lock` VALUES (11, 10, 12, '2026-03-22 15:29:49', '2026-03-22 18:29:49', '2026-03-22 15:15:43');
INSERT INTO `cleaner_time_lock` VALUES (14, 7, 19, '2026-03-24 16:41:37', '2026-03-24 19:41:37', '2026-03-22 17:49:57');
INSERT INTO `cleaner_time_lock` VALUES (19, 10, 23, '2026-03-23 11:30:00', '2026-03-23 14:30:00', '2026-03-22 21:08:30');
INSERT INTO `cleaner_time_lock` VALUES (20, 12, 15, '2026-03-21 16:23:42', '2026-03-21 19:23:42', '2026-03-22 23:07:51');
INSERT INTO `cleaner_time_lock` VALUES (21, 7, 24, '2026-03-23 14:30:00', '2026-03-23 19:30:00', '2026-03-23 14:44:06');
INSERT INTO `cleaner_time_lock` VALUES (22, 7, 25, '2026-03-23 19:30:00', '2026-03-23 22:30:00', '2026-03-23 14:58:46');
INSERT INTO `cleaner_time_lock` VALUES (23, 11, 30, '2026-03-25 13:30:00', '2026-03-25 16:30:00', '2026-03-24 16:38:14');
INSERT INTO `cleaner_time_lock` VALUES (24, 11, 29, '2026-03-25 09:30:00', '2026-03-25 12:30:00', '2026-03-24 16:38:16');
INSERT INTO `cleaner_time_lock` VALUES (29, 11, 32, '2026-03-26 09:00:00', '2026-03-26 11:30:00', '2026-03-24 19:17:08');
INSERT INTO `cleaner_time_lock` VALUES (30, 10, 33, '2026-03-26 12:30:00', '2026-03-26 15:30:00', '2026-03-24 19:17:39');
INSERT INTO `cleaner_time_lock` VALUES (32, 7, 27, '2026-03-25 09:30:00', '2026-03-25 12:30:00', '2026-03-24 21:30:53');
INSERT INTO `cleaner_time_lock` VALUES (35, 14, 28, '2026-03-25 09:30:00', '2026-03-25 12:30:00', '2026-03-25 17:28:20');
INSERT INTO `cleaner_time_lock` VALUES (36, 7, 31, '2026-03-26 08:30:00', '2026-03-26 11:30:00', '2026-03-25 17:29:26');
INSERT INTO `cleaner_time_lock` VALUES (38, 13, 35, '2026-03-26 16:00:00', '2026-03-26 18:00:00', '2026-03-25 18:04:09');
INSERT INTO `cleaner_time_lock` VALUES (39, 14, 41, '2026-03-27 09:30:00', '2026-03-27 12:30:00', '2026-03-25 18:05:39');
INSERT INTO `cleaner_time_lock` VALUES (40, 13, 34, '2026-03-26 13:30:00', '2026-03-26 16:00:00', '2026-03-25 18:05:49');
INSERT INTO `cleaner_time_lock` VALUES (41, 7, 48, '2026-03-29 13:30:00', '2026-03-29 16:30:00', '2026-03-26 19:51:05');
INSERT INTO `cleaner_time_lock` VALUES (42, 13, 51, '2026-03-28 08:30:00', '2026-03-28 13:30:00', '2026-03-26 20:12:28');
INSERT INTO `cleaner_time_lock` VALUES (43, 13, 49, '2026-03-30 14:30:00', '2026-03-30 19:30:00', '2026-03-26 20:36:18');
INSERT INTO `cleaner_time_lock` VALUES (44, 13, 46, '2026-03-27 08:30:00', '2026-03-27 11:30:00', '2026-03-26 20:51:16');
INSERT INTO `cleaner_time_lock` VALUES (46, 7, 54, '2026-03-31 09:30:00', '2026-03-31 12:30:00', '2026-03-27 15:41:14');
INSERT INTO `cleaner_time_lock` VALUES (47, 13, 55, '2026-03-27 16:30:22', '2026-03-27 19:30:22', '2026-03-27 16:07:45');
INSERT INTO `cleaner_time_lock` VALUES (48, 7, 56, '2026-03-27 17:01:28', '2026-03-27 20:01:28', '2026-03-27 16:32:10');
INSERT INTO `cleaner_time_lock` VALUES (49, 11, 57, '2026-03-27 17:12:21', '2026-03-27 20:12:21', '2026-03-27 16:45:58');
INSERT INTO `cleaner_time_lock` VALUES (50, 14, 59, '2026-03-28 14:47:59', '2026-03-28 17:47:59', '2026-03-28 14:19:26');
INSERT INTO `cleaner_time_lock` VALUES (51, 7, 47, '2026-03-28 09:30:00', '2026-03-28 13:30:00', '2026-03-30 19:17:47');
INSERT INTO `cleaner_time_lock` VALUES (52, 7, 62, '2026-04-02 09:30:00', '2026-04-02 14:30:00', '2026-03-30 22:37:23');
INSERT INTO `cleaner_time_lock` VALUES (53, 14, 60, '2026-03-31 08:30:00', '2026-03-31 12:30:00', '2026-03-30 22:37:31');
INSERT INTO `cleaner_time_lock` VALUES (54, 13, 63, '2026-04-03 13:30:00', '2026-04-03 16:30:00', '2026-03-30 22:41:00');
INSERT INTO `cleaner_time_lock` VALUES (55, 13, 61, '2026-04-01 09:30:00', '2026-04-01 12:30:00', '2026-03-30 22:41:01');
INSERT INTO `cleaner_time_lock` VALUES (56, 7, 64, '2026-03-31 16:30:00', '2026-03-31 19:30:00', '2026-03-31 12:42:29');
INSERT INTO `cleaner_time_lock` VALUES (57, 7, 65, '2026-04-01 13:30:00', '2026-04-01 17:30:00', '2026-03-31 14:53:02');
INSERT INTO `cleaner_time_lock` VALUES (58, 13, 69, '2026-03-31 16:06:50', '2026-03-31 19:06:50', '2026-03-31 15:37:31');
INSERT INTO `cleaner_time_lock` VALUES (60, 12, 70, '2026-03-31 16:30:00', '2026-03-31 19:30:00', '2026-03-31 15:51:53');
INSERT INTO `cleaner_time_lock` VALUES (61, 11, 71, '2026-03-31 17:18:29', '2026-03-31 19:58:29', '2026-03-31 17:24:38');
INSERT INTO `cleaner_time_lock` VALUES (63, 14, 72, '2026-03-31 18:51:14', '2026-03-31 21:31:14', '2026-03-31 19:01:21');
INSERT INTO `cleaner_time_lock` VALUES (64, 14, 67, '2026-04-03 09:40:00', '2026-04-03 12:20:00', '2026-03-31 19:09:59');
INSERT INTO `cleaner_time_lock` VALUES (65, 12, 68, '2026-04-04 08:40:00', '2026-04-04 11:20:00', '2026-03-31 20:06:51');
INSERT INTO `cleaner_time_lock` VALUES (66, 10, 66, '2026-04-02 13:40:00', '2026-04-02 18:20:00', '2026-03-31 20:07:09');
INSERT INTO `cleaner_time_lock` VALUES (67, 13, 75, '2026-04-09 09:40:00', '2026-04-09 13:20:00', '2026-04-07 14:02:26');
INSERT INTO `cleaner_time_lock` VALUES (68, 11, 74, '2026-04-08 13:40:00', '2026-04-08 16:20:00', '2026-04-07 14:02:37');
INSERT INTO `cleaner_time_lock` VALUES (69, 11, 76, '2026-04-10 08:40:00', '2026-04-10 12:20:00', '2026-04-07 14:02:38');
INSERT INTO `cleaner_time_lock` VALUES (70, 11, 77, '2026-04-11 08:40:00', '2026-04-11 12:20:00', '2026-04-07 14:02:39');
INSERT INTO `cleaner_time_lock` VALUES (71, 11, 73, '2026-04-07 14:40:00', '2026-04-07 17:20:00', '2026-04-07 14:02:40');
INSERT INTO `cleaner_time_lock` VALUES (72, 7, 81, '2026-04-11 14:40:00', '2026-04-11 17:20:00', '2026-04-07 14:06:30');
INSERT INTO `cleaner_time_lock` VALUES (74, 11, 85, '2026-04-08 01:17:02', '2026-04-08 03:57:02', '2026-04-08 01:34:07');
INSERT INTO `cleaner_time_lock` VALUES (75, 13, 86, '2026-04-08 01:23:23', '2026-04-08 04:03:23', '2026-04-08 01:41:13');
INSERT INTO `cleaner_time_lock` VALUES (76, 10, 87, '2026-04-08 01:27:57', '2026-04-08 04:07:57', '2026-04-08 01:45:55');
INSERT INTO `cleaner_time_lock` VALUES (77, 12, 88, '2026-04-08 01:33:41', '2026-04-08 05:13:41', '2026-04-08 01:52:18');
INSERT INTO `cleaner_time_lock` VALUES (82, 13, 90, '2026-04-08 06:40:00', '2026-04-08 09:20:00', '2026-04-08 02:07:33');
INSERT INTO `cleaner_time_lock` VALUES (83, 13, 84, '2026-04-08 09:37:46', '2026-04-08 12:17:46', '2026-04-08 02:59:14');
INSERT INTO `cleaner_time_lock` VALUES (84, 14, 91, '2026-04-08 03:42:23', '2026-04-08 06:22:23', '2026-04-08 03:55:23');
INSERT INTO `cleaner_time_lock` VALUES (85, 7, 92, '2026-04-08 03:51:42', '2026-04-08 06:31:42', '2026-04-08 04:00:22');
INSERT INTO `cleaner_time_lock` VALUES (86, 12, 94, '2026-04-09 14:04:27', '2026-04-09 16:44:27', '2026-04-09 14:22:03');
INSERT INTO `cleaner_time_lock` VALUES (87, 13, 96, '2026-04-11 08:40:00', '2026-04-11 12:20:00', '2026-04-09 14:35:36');
INSERT INTO `cleaner_time_lock` VALUES (88, 13, 80, '2026-04-10 14:40:00', '2026-04-10 19:20:00', '2026-04-09 14:35:38');
INSERT INTO `cleaner_time_lock` VALUES (89, 7, 97, '2026-04-12 13:40:00', '2026-04-12 18:20:00', '2026-04-09 14:39:57');
INSERT INTO `cleaner_time_lock` VALUES (90, 7, 98, '2026-04-13 09:40:00', '2026-04-13 12:20:00', '2026-04-09 14:39:58');
INSERT INTO `cleaner_time_lock` VALUES (91, 10, 95, '2026-04-10 08:40:00', '2026-04-10 12:20:00', '2026-04-09 14:41:01');
INSERT INTO `cleaner_time_lock` VALUES (92, 7, 99, '2026-04-09 21:29:10', '2026-04-10 00:09:10', '2026-04-09 21:48:46');
INSERT INTO `cleaner_time_lock` VALUES (93, 11, 101, '2026-04-09 21:46:24', '2026-04-10 00:26:24', '2026-04-09 22:04:29');
INSERT INTO `cleaner_time_lock` VALUES (94, 14, 100, '2026-04-09 21:50:23', '2026-04-10 00:30:23', '2026-04-09 22:05:15');
INSERT INTO `cleaner_time_lock` VALUES (95, 12, 103, '2026-04-09 22:00:46', '2026-04-10 00:40:46', '2026-04-09 22:17:17');
INSERT INTO `cleaner_time_lock` VALUES (96, 7, 107, '2026-04-13 14:40:00', '2026-04-13 18:20:00', '2026-04-09 23:30:50');
INSERT INTO `cleaner_time_lock` VALUES (97, 7, 104, '2026-04-10 08:40:00', '2026-04-10 13:20:00', '2026-04-09 23:30:51');
INSERT INTO `cleaner_time_lock` VALUES (98, 12, 105, '2026-04-11 14:40:00', '2026-04-11 18:20:00', '2026-04-10 12:22:42');
INSERT INTO `cleaner_time_lock` VALUES (99, 14, 108, '2026-04-10 12:09:16', '2026-04-10 14:49:16', '2026-04-10 12:24:30');
INSERT INTO `cleaner_time_lock` VALUES (100, 10, 111, '2026-04-10 12:28:33', '2026-04-10 15:08:33', '2026-04-10 12:46:02');
INSERT INTO `cleaner_time_lock` VALUES (101, 10, 112, '2026-04-10 16:22:17', '2026-04-10 19:02:17', '2026-04-10 12:46:33');
INSERT INTO `cleaner_time_lock` VALUES (104, 12, 110, '2026-04-10 14:45:53', '2026-04-10 17:25:53', '2026-04-10 13:02:33');
INSERT INTO `cleaner_time_lock` VALUES (105, 12, 106, '2026-04-12 14:40:00', '2026-04-12 19:20:00', '2026-04-10 13:03:57');
INSERT INTO `cleaner_time_lock` VALUES (106, 11, 114, '2026-04-10 13:24:05', '2026-04-10 16:04:05', '2026-04-10 13:40:06');
INSERT INTO `cleaner_time_lock` VALUES (107, 10, 116, '2026-04-10 22:39:27', '2026-04-11 01:19:27', '2026-04-10 22:43:14');

-- ----------------------------
-- Table structure for cleaning_company
-- ----------------------------
DROP TABLE IF EXISTS `cleaning_company`;
CREATE TABLE `cleaning_company`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公司名称',
  `license_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '营业执照号',
  `license_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '营业执照图片URL',
  `contact_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '公司地址',
  `status` tinyint NOT NULL DEFAULT 2 COMMENT '状态：1=正常 2=待审核 3=停用',
  `audit_remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核备注',
  `audited_by` bigint NULL DEFAULT NULL COMMENT '审核管理员user_id',
  `audited_at` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '保洁公司表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of cleaning_company
-- ----------------------------
INSERT INTO `cleaning_company` VALUES (1, '绿洁家政服务有限公司', '91110000XXXXXXX001', NULL, '张经理', '13800000001', '北京市朝阳区XX路1号', 1, '', NULL, NULL, '2026-03-25 15:18:35', '2026-03-25 15:18:35');
INSERT INTO `cleaning_company` VALUES (2, '净美居家服务公司', '91110000XXXXXXX002', NULL, '李经理', '13800000002', '北京市海淀区XX街2号', 1, NULL, NULL, NULL, '2026-03-25 15:18:35', '2026-03-25 15:18:35');
INSERT INTO `cleaning_company` VALUES (3, '优优保洁服务中心', '91110000XXXXXXX003', NULL, '王经理', '13800000003', '北京市丰台区XX大厦3楼', 1, NULL, NULL, NULL, '2026-03-25 15:18:35', '2026-03-25 15:18:35');
INSERT INTO `cleaning_company` VALUES (4, '幸运一号服务公司', '', NULL, '赵思远', '13833300004', '', 1, '', NULL, NULL, '2026-03-25 15:44:26', '2026-03-25 15:44:26');

-- ----------------------------
-- Table structure for complaint
-- ----------------------------
DROP TABLE IF EXISTS `complaint`;
CREATE TABLE `complaint`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `customer_id` bigint NOT NULL COMMENT '投诉顾客user_id',
  `cleaner_id` bigint NOT NULL COMMENT '被投诉保洁员user_id',
  `reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '投诉原因',
  `imgs` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '证明照片URLs，逗号分隔',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=待处理 2=处理中 3=已结案',
  `result` tinyint NULL DEFAULT NULL COMMENT '判定结果：1=全额退款 2=部分退款 3=驳回 4=免费重做',
  `refund_amount` decimal(8, 2) NULL DEFAULT NULL COMMENT '退款金额（部分退款时）',
  `admin_remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '管理员处理说明',
  `handled_by` bigint NULL DEFAULT NULL COMMENT '处理管理员user_id',
  `handled_at` datetime NULL DEFAULT NULL COMMENT '处理完成时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '投诉与售后表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of complaint
-- ----------------------------
INSERT INTO `complaint` VALUES (1, 10, 6, 7, '不干净不彻底', '', 3, 2, 4.00, '退部分', NULL, '2026-03-21 17:14:48', '2026-03-21 17:13:40', '2026-03-21 17:13:40');
INSERT INTO `complaint` VALUES (2, 11, 6, 7, '1', '', 3, 1, 9.00, '1', NULL, '2026-03-22 15:02:52', '2026-03-22 15:00:45', '2026-03-22 15:00:45');
INSERT INTO `complaint` VALUES (3, 12, 6, 10, '2', '', 3, 1, 70.00, '2', NULL, '2026-03-22 15:16:59', '2026-03-22 15:16:10', '2026-03-22 15:16:10');
INSERT INTO `complaint` VALUES (4, 13, 6, 7, '全额退款测试', NULL, 3, 1, NULL, 'Full refund approved', 8, '2026-03-22 17:07:40', '2026-03-22 16:53:55', '2026-03-22 17:05:04');
INSERT INTO `complaint` VALUES (5, 14, 6, 7, '驳回测试', NULL, 3, 2, NULL, 'Rejected', 8, '2026-03-22 17:07:40', '2026-03-22 16:53:55', '2026-03-22 16:53:55');
INSERT INTO `complaint` VALUES (6, 15, 6, 7, '免费重做测试', NULL, 3, 3, NULL, 'Free redo', 8, '2026-03-22 17:10:23', '2026-03-22 16:53:55', '2026-03-22 17:10:22');
INSERT INTO `complaint` VALUES (7, 55, 6, 13, '不干净', '', 3, 4, NULL, '111', 8, '2026-03-27 16:22:43', '2026-03-27 16:09:04', '2026-03-27 16:09:04');
INSERT INTO `complaint` VALUES (8, 72, 6, 14, '不干净', '', 3, 4, NULL, '退部分', 8, '2026-04-01 22:18:41', '2026-04-01 22:17:06', '2026-04-01 22:17:06');
INSERT INTO `complaint` VALUES (9, 70, 6, 12, '不好', '', 3, 4, NULL, '23', 8, '2026-04-01 22:39:22', '2026-04-01 22:38:49', '2026-04-01 22:38:49');
INSERT INTO `complaint` VALUES (10, 89, 6, 14, '不干净有死角', '', 3, 3, NULL, '11', 8, '2026-04-08 02:35:22', '2026-04-08 02:32:06', '2026-04-08 02:32:06');
INSERT INTO `complaint` VALUES (11, 88, 6, 12, '1', '', 3, 4, NULL, '2', 8, '2026-04-08 02:37:37', '2026-04-08 02:37:19', '2026-04-08 02:37:19');
INSERT INTO `complaint` VALUES (12, 87, 6, 10, '1', '', 3, 1, NULL, '0', 8, '2026-04-08 02:38:33', '2026-04-08 02:38:17', '2026-04-08 02:38:17');
INSERT INTO `complaint` VALUES (13, 86, 6, 13, '12', '', 3, 1, NULL, '80', 8, '2026-04-08 02:39:56', '2026-04-08 02:39:32', '2026-04-08 02:39:32');
INSERT INTO `complaint` VALUES (14, 85, 6, 11, '100', '', 3, 2, NULL, '100', 8, '2026-04-08 02:40:56', '2026-04-08 02:40:40', '2026-04-08 02:40:40');
INSERT INTO `complaint` VALUES (15, 84, 6, 7, '不好', '', 3, 3, NULL, '是', 8, '2026-04-08 02:58:00', '2026-04-08 02:56:33', '2026-04-08 02:56:33');

-- ----------------------------
-- Table structure for customer_address
-- ----------------------------
DROP TABLE IF EXISTS `customer_address`;
CREATE TABLE `customer_address`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '关联user.id',
  `label` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '地址标签，如：家、公司',
  `contact_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系人姓名',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '联系电话',
  `province` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '省',
  `city` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '市',
  `district` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '区',
  `detail` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '详细地址',
  `longitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '经度',
  `latitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '纬度',
  `is_default` tinyint NOT NULL DEFAULT 0 COMMENT '是否默认：1=是 0=否',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '顾客地址表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of customer_address
-- ----------------------------
INSERT INTO `customer_address` VALUES (1, 6, '家', '顾客', '13800000001', '重庆市', '市辖区', '巴南区', '重庆理工大学', 106.5257000, 29.4593000, 0, '2026-03-20 18:18:40');
INSERT INTO `customer_address` VALUES (2, 6, '公司', '顾客', '13800000001', '重庆市', '市辖区', '巴南区', '重庆理工大学花溪校区', 106.5257000, 29.4593000, 1, '2026-03-20 20:26:56');
INSERT INTO `customer_address` VALUES (3, 6, '', '1', '18300000001', '重庆市', '市辖区', '大渡口区', '金科', 106.5516000, 29.5630000, 0, '2026-03-22 14:59:00');
INSERT INTO `customer_address` VALUES (4, 6, '', '测试顾客', '13800000001', '重庆市', '市辖区', '江北区', '观音桥', 106.5516000, 29.5630000, 0, '2026-03-24 16:26:21');
INSERT INTO `customer_address` VALUES (5, 6, NULL, '测试用户', '13800000001', '重庆市', '重庆市', '渝中区', '解放碑步行街民权路1号', 106.5727000, 29.5593000, 0, '2026-03-24 17:19:17');
INSERT INTO `customer_address` VALUES (6, 6, NULL, '测试用户', '13800000001', '重庆市', '重庆市', '江北区', '观音桥北城天街5号', 106.5344000, 29.5751000, 0, '2026-03-24 17:19:17');
INSERT INTO `customer_address` VALUES (7, 6, NULL, '测试用户', '13800000001', '重庆市', '重庆市', '南岸区', '南坪万达广场B座', 106.5683000, 29.5081000, 0, '2026-03-24 17:19:17');
INSERT INTO `customer_address` VALUES (8, 6, NULL, '测试用户', '13800000001', '重庆市', '重庆市', '沙坪坝区', '三峡广场天虹商场旁', 106.4607000, 29.5552000, 0, '2026-03-24 17:19:17');
INSERT INTO `customer_address` VALUES (9, 6, NULL, '测试用户', '13800000001', '重庆市', '重庆市', '九龙坡区', '杨家坪直港大道21号', 106.4988000, 29.5203000, 0, '2026-03-24 17:19:17');
INSERT INTO `customer_address` VALUES (10, 45, '', '顾客2', '13833330008', '重庆市', '市辖区', '大渡口区', '松青路 1091号 7座 15-3', 106.4796890, 29.4654740, 0, '2026-04-09 12:52:47');
INSERT INTO `customer_address` VALUES (11, 45, '', '顾客2', '13833330008', '重庆市', '市辖区', '永川区', '人民广场', 105.9281120, 29.3550460, 0, '2026-04-09 22:03:58');

-- ----------------------------
-- Table structure for customer_profile
-- ----------------------------
DROP TABLE IF EXISTS `customer_profile`;
CREATE TABLE `customer_profile`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '关联user.id',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '顾客扩展信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of customer_profile
-- ----------------------------
INSERT INTO `customer_profile` VALUES (1, 22, '小美', '2026-03-25 15:40:32');
INSERT INTO `customer_profile` VALUES (2, 23, '张磊', '2026-03-25 15:40:32');

-- ----------------------------
-- Table structure for dispatch_record
-- ----------------------------
DROP TABLE IF EXISTS `dispatch_record`;
CREATE TABLE `dispatch_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `cleaner_id` bigint NOT NULL COMMENT '被派保洁员user_id',
  `dispatch_type` tinyint NOT NULL COMMENT '派单方式：1=系统自动 2=管理员手动 3=保洁员抢单',
  `score` decimal(6, 2) NULL DEFAULT NULL COMMENT '系统自动派单时的综合得分',
  `distance_km` decimal(6, 2) NULL DEFAULT NULL COMMENT '估算距离（km）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=待响应 2=已接单 3=已拒绝 4=已超时',
  `respond_at` datetime NULL DEFAULT NULL COMMENT '保洁员响应时间',
  `expire_at` datetime NOT NULL COMMENT '响应截止时间（推送后30min）',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '手动派单的管理员user_id',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_cleaner_id`(`cleaner_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 162 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '派单记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dispatch_record
-- ----------------------------
INSERT INTO `dispatch_record` VALUES (1, 1, 7, 3, NULL, NULL, 2, '2026-03-20 18:29:59', '2026-03-20 18:29:59', NULL, '2026-03-20 18:29:59');
INSERT INTO `dispatch_record` VALUES (2, 3, 7, 3, NULL, NULL, 2, '2026-03-20 19:59:07', '2026-03-20 19:59:07', NULL, '2026-03-20 19:59:08');
INSERT INTO `dispatch_record` VALUES (3, 2, 7, 3, NULL, NULL, 2, '2026-03-20 19:59:09', '2026-03-20 19:59:09', NULL, '2026-03-20 19:59:09');
INSERT INTO `dispatch_record` VALUES (4, 4, 7, 1, 4.50, 999.00, 2, '2026-03-20 20:39:41', '2026-03-20 21:01:28', NULL, '2026-03-20 20:31:28');
INSERT INTO `dispatch_record` VALUES (5, 5, 7, 1, 4.50, 0.00, 2, '2026-03-20 20:37:07', '2026-03-20 21:01:34', NULL, '2026-03-20 20:31:34');
INSERT INTO `dispatch_record` VALUES (6, 7, 7, 3, NULL, NULL, 2, '2026-03-21 13:38:19', '2026-03-21 13:38:19', NULL, '2026-03-21 13:38:19');
INSERT INTO `dispatch_record` VALUES (7, 8, 10, 3, NULL, NULL, 2, '2026-03-21 15:39:46', '2026-03-21 15:39:46', NULL, '2026-03-21 15:39:46');
INSERT INTO `dispatch_record` VALUES (8, 9, 7, 1, 3.67, 0.00, 3, '2026-03-21 15:52:06', '2026-03-21 16:17:30', NULL, '2026-03-21 15:47:30');
INSERT INTO `dispatch_record` VALUES (9, 9, 7, 1, 3.67, 0.00, 3, '2026-03-21 15:55:32', '2026-03-21 16:22:20', NULL, '2026-03-21 15:52:20');
INSERT INTO `dispatch_record` VALUES (10, 9, 10, 3, NULL, NULL, 2, '2026-03-21 15:58:53', '2026-03-21 15:58:53', NULL, '2026-03-21 15:58:53');
INSERT INTO `dispatch_record` VALUES (11, 10, 7, 1, 3.50, 0.00, 2, '2026-03-21 17:11:34', '2026-03-21 17:41:27', NULL, '2026-03-21 17:11:27');
INSERT INTO `dispatch_record` VALUES (12, 11, 7, 1, 3.56, 0.00, 2, '2026-03-22 14:59:59', '2026-03-22 15:29:25', NULL, '2026-03-22 14:59:25');
INSERT INTO `dispatch_record` VALUES (13, 12, 10, 3, NULL, NULL, 2, '2026-03-22 15:15:43', '2026-03-22 15:15:43', NULL, '2026-03-22 15:15:43');
INSERT INTO `dispatch_record` VALUES (14, 19, 7, 3, NULL, NULL, 2, '2026-03-22 17:49:57', '2026-03-22 17:49:57', NULL, '2026-03-22 17:49:57');
INSERT INTO `dispatch_record` VALUES (15, 20, 7, 1, 4.11, 0.00, 2, '2026-03-22 18:04:32', '2026-03-22 18:31:23', NULL, '2026-03-22 18:01:23');
INSERT INTO `dispatch_record` VALUES (16, 21, 7, 1, 4.11, 0.00, 2, '2026-03-22 18:01:54', '2026-03-22 18:31:29', NULL, '2026-03-22 18:01:29');
INSERT INTO `dispatch_record` VALUES (17, 22, 10, 3, NULL, NULL, 2, '2026-03-22 18:21:21', '2026-03-22 18:21:21', NULL, '2026-03-22 18:21:21');
INSERT INTO `dispatch_record` VALUES (18, 23, 7, 1, 4.11, 0.00, 3, '2026-03-22 21:06:53', '2026-03-22 21:36:10', NULL, '2026-03-22 21:06:10');
INSERT INTO `dispatch_record` VALUES (19, 23, 10, 3, NULL, NULL, 2, '2026-03-22 21:07:42', '2026-03-22 21:07:42', NULL, '2026-03-22 21:07:42');
INSERT INTO `dispatch_record` VALUES (20, 23, 10, 3, NULL, NULL, 2, '2026-03-22 21:08:30', '2026-03-22 21:08:30', NULL, '2026-03-22 21:08:30');
INSERT INTO `dispatch_record` VALUES (21, 15, 12, 3, NULL, NULL, 2, '2026-03-22 23:07:51', '2026-03-22 23:07:51', NULL, '2026-03-22 23:07:51');
INSERT INTO `dispatch_record` VALUES (22, 24, 7, 1, 4.11, 0.00, 2, '2026-03-23 14:44:06', '2026-03-23 15:13:40', NULL, '2026-03-23 14:43:40');
INSERT INTO `dispatch_record` VALUES (23, 25, 7, 1, 4.11, 0.00, 3, '2026-03-23 14:52:29', '2026-03-23 15:16:09', NULL, '2026-03-23 14:46:09');
INSERT INTO `dispatch_record` VALUES (24, 25, 7, 3, NULL, NULL, 2, '2026-03-23 14:58:46', '2026-03-23 14:58:46', NULL, '2026-03-23 14:58:46');
INSERT INTO `dispatch_record` VALUES (25, 27, 11, 1, 268.40, 12.02, 4, NULL, '2026-03-24 15:53:04', NULL, '2026-03-24 15:23:04');
INSERT INTO `dispatch_record` VALUES (26, 29, 11, 1, 268.40, 12.02, 2, '2026-03-24 16:38:16', '2026-03-24 16:56:52', NULL, '2026-03-24 16:26:52');
INSERT INTO `dispatch_record` VALUES (27, 30, 11, 1, 268.40, 12.02, 2, '2026-03-24 16:38:14', '2026-03-24 16:57:00', NULL, '2026-03-24 16:27:00');
INSERT INTO `dispatch_record` VALUES (28, 27, 11, 1, 268.40, 12.02, 3, '2026-03-24 16:38:21', '2026-03-24 16:57:10', NULL, '2026-03-24 16:27:10');
INSERT INTO `dispatch_record` VALUES (29, 28, 12, 1, 730.00, 0.00, 2, '2026-03-24 16:42:02', '2026-03-24 17:07:49', NULL, '2026-03-24 16:37:49');
INSERT INTO `dispatch_record` VALUES (30, 27, 12, 1, 261.59, 14.83, 2, '2026-03-24 16:42:23', '2026-03-24 17:10:51', NULL, '2026-03-24 16:40:51');
INSERT INTO `dispatch_record` VALUES (31, 28, 10, 1, 628.02, 0.00, 4, NULL, '2026-03-24 17:31:01', NULL, '2026-03-24 17:01:01');
INSERT INTO `dispatch_record` VALUES (37, 32, 12, 1, 289.24, 2.14, 4, NULL, '2026-03-24 18:03:32', NULL, '2026-03-24 17:33:32');
INSERT INTO `dispatch_record` VALUES (38, 34, 10, 1, 150.10, 21.65, 4, NULL, '2026-03-24 18:03:35', NULL, '2026-03-24 17:33:35');
INSERT INTO `dispatch_record` VALUES (39, 34, 12, 1, 180.86, 8.83, 2, '2026-03-24 19:16:37', '2026-03-24 19:44:41', NULL, '2026-03-24 19:14:41');
INSERT INTO `dispatch_record` VALUES (40, 35, 12, 1, 159.40, 6.97, 2, '2026-03-24 19:16:42', '2026-03-24 19:44:45', NULL, '2026-03-24 19:14:45');
INSERT INTO `dispatch_record` VALUES (41, 33, 11, 1, 165.07, 6.31, 3, '2026-03-24 19:17:10', '2026-03-24 19:44:48', NULL, '2026-03-24 19:14:48');
INSERT INTO `dispatch_record` VALUES (42, 31, 12, 1, 242.34, 2.08, 3, '2026-03-24 19:16:44', '2026-03-24 19:44:52', NULL, '2026-03-24 19:14:52');
INSERT INTO `dispatch_record` VALUES (43, 32, 11, 1, 239.24, 2.14, 2, '2026-03-24 19:17:08', '2026-03-24 19:44:55', NULL, '2026-03-24 19:14:55');
INSERT INTO `dispatch_record` VALUES (44, 31, 12, 1, 242.34, 2.08, 4, '2026-03-24 19:47:37', '2026-03-24 19:47:19', NULL, '2026-03-24 19:17:19');
INSERT INTO `dispatch_record` VALUES (45, 33, 10, 1, 148.35, 23.59, 2, '2026-03-24 19:17:39', '2026-03-24 19:47:22', NULL, '2026-03-24 19:17:22');
INSERT INTO `dispatch_record` VALUES (46, 31, 12, 1, 242.34, 2.08, 3, '2026-03-24 20:59:52', '2026-03-24 21:29:07', NULL, '2026-03-24 20:59:07');
INSERT INTO `dispatch_record` VALUES (47, 31, 12, 1, 259.31, 16.06, 3, '2026-03-24 21:31:18', '2026-03-24 21:31:42', NULL, '2026-03-24 21:01:42');
INSERT INTO `dispatch_record` VALUES (48, 34, 11, 1, 101.53, 7.46, 4, NULL, '2026-03-24 21:43:35', NULL, '2026-03-24 21:13:35');
INSERT INTO `dispatch_record` VALUES (49, 35, 10, 1, 106.06, 6.86, 4, NULL, '2026-03-24 21:43:39', NULL, '2026-03-24 21:13:39');
INSERT INTO `dispatch_record` VALUES (50, 28, 12, 1, 548.20, 0.00, 2, '2026-03-24 21:14:08', '2026-03-24 21:43:48', NULL, '2026-03-24 21:13:48');
INSERT INTO `dispatch_record` VALUES (51, 27, 7, 1, 533.48, 0.00, 2, '2026-03-24 21:30:53', '2026-03-24 21:48:13', NULL, '2026-03-24 21:18:13');
INSERT INTO `dispatch_record` VALUES (52, 28, 12, 1, 548.20, 0.00, 3, '2026-03-24 21:31:17', '2026-03-24 21:48:16', NULL, '2026-03-24 21:18:16');
INSERT INTO `dispatch_record` VALUES (53, 41, 10, 1, 106.06, 6.86, 3, '2026-03-24 22:42:58', '2026-03-24 23:12:45', NULL, '2026-03-24 22:42:45');
INSERT INTO `dispatch_record` VALUES (54, 34, 14, 3, NULL, NULL, 2, '2026-03-25 16:04:36', '2026-03-25 16:04:36', NULL, '2026-03-25 16:04:36');
INSERT INTO `dispatch_record` VALUES (55, 41, 14, 1, 125.74, 5.35, 4, NULL, '2026-03-25 16:39:07', NULL, '2026-03-25 16:09:07');
INSERT INTO `dispatch_record` VALUES (56, 35, 14, 1, 121.97, 5.35, 4, NULL, '2026-03-25 16:39:11', NULL, '2026-03-25 16:09:11');
INSERT INTO `dispatch_record` VALUES (57, 31, 7, 1, 195.82, 2.08, 4, NULL, '2026-03-25 16:39:15', NULL, '2026-03-25 16:09:15');
INSERT INTO `dispatch_record` VALUES (58, 41, 14, 1, 125.74, 5.35, 4, NULL, '2026-03-25 17:57:57', NULL, '2026-03-25 17:27:57');
INSERT INTO `dispatch_record` VALUES (59, 41, 12, 2, NULL, NULL, 2, '2026-03-25 17:28:02', '2026-03-25 17:28:02', 8, '2026-03-25 17:28:02');
INSERT INTO `dispatch_record` VALUES (60, 28, 14, 2, NULL, NULL, 2, '2026-03-25 17:28:20', '2026-03-25 17:28:20', 8, '2026-03-25 17:28:20');
INSERT INTO `dispatch_record` VALUES (61, 31, 7, 2, NULL, NULL, 2, '2026-03-25 17:29:26', '2026-03-25 17:29:26', 8, '2026-03-25 17:29:26');
INSERT INTO `dispatch_record` VALUES (62, 35, 14, 1, 121.97, 5.35, 4, NULL, '2026-03-25 17:59:49', NULL, '2026-03-25 17:29:49');
INSERT INTO `dispatch_record` VALUES (63, 35, 12, 2, NULL, NULL, 2, '2026-03-25 17:31:56', '2026-03-25 17:31:56', 8, '2026-03-25 17:31:56');
INSERT INTO `dispatch_record` VALUES (64, 35, 13, 3, NULL, NULL, 2, '2026-03-25 18:04:09', '2026-03-25 18:04:09', NULL, '2026-03-25 18:04:09');
INSERT INTO `dispatch_record` VALUES (65, 41, 7, 2, NULL, NULL, 3, '2026-03-25 18:05:14', '2026-03-25 18:35:04', 8, '2026-03-25 18:05:04');
INSERT INTO `dispatch_record` VALUES (66, 41, 14, 2, NULL, NULL, 2, '2026-03-25 18:05:39', '2026-03-25 18:35:25', 8, '2026-03-25 18:05:25');
INSERT INTO `dispatch_record` VALUES (67, 34, 13, 1, 548.20, 0.00, 2, '2026-03-25 18:05:49', '2026-03-25 18:35:28', NULL, '2026-03-25 18:05:28');
INSERT INTO `dispatch_record` VALUES (68, 46, 10, 1, 546.22, 0.00, 4, NULL, '2026-03-26 18:45:27', NULL, '2026-03-26 18:15:27');
INSERT INTO `dispatch_record` VALUES (69, 46, 13, 1, 558.85, 0.00, 3, '2026-03-26 20:12:35', '2026-03-26 20:20:06', NULL, '2026-03-26 19:50:06');
INSERT INTO `dispatch_record` VALUES (70, 48, 7, 1, 118.95, 4.85, 2, '2026-03-26 19:51:05', '2026-03-26 20:20:57', NULL, '2026-03-26 19:50:57');
INSERT INTO `dispatch_record` VALUES (71, 53, 13, 1, 548.20, 0.00, 3, '2026-03-26 20:12:33', '2026-03-26 20:41:57', NULL, '2026-03-26 20:11:57');
INSERT INTO `dispatch_record` VALUES (72, 51, 13, 1, 544.43, 0.00, 2, '2026-03-26 20:12:28', '2026-03-26 20:42:07', NULL, '2026-03-26 20:12:07');
INSERT INTO `dispatch_record` VALUES (73, 50, 13, 1, 542.43, 0.00, 3, '2026-03-26 20:12:38', '2026-03-26 20:42:11', NULL, '2026-03-26 20:12:11');
INSERT INTO `dispatch_record` VALUES (74, 49, 13, 3, NULL, NULL, 2, '2026-03-26 20:36:18', '2026-03-26 20:36:18', NULL, '2026-03-26 20:36:18');
INSERT INTO `dispatch_record` VALUES (75, 46, 13, 3, NULL, NULL, 2, '2026-03-26 20:51:16', '2026-03-26 20:51:16', NULL, '2026-03-26 20:51:16');
INSERT INTO `dispatch_record` VALUES (76, 53, 10, 2, NULL, NULL, 4, NULL, '2026-03-26 21:21:52', 8, '2026-03-26 20:51:52');
INSERT INTO `dispatch_record` VALUES (77, 55, 13, 1, 544.43, 0.00, 2, '2026-03-27 16:07:45', '2026-03-27 16:37:36', NULL, '2026-03-27 16:07:36');
INSERT INTO `dispatch_record` VALUES (78, 56, 7, 1, 532.94, 0.00, 2, '2026-03-27 16:32:10', '2026-03-27 17:02:03', NULL, '2026-03-27 16:32:03');
INSERT INTO `dispatch_record` VALUES (79, 57, 11, 1, 97.26, 12.02, 2, '2026-03-27 16:45:58', '2026-03-27 17:14:03', NULL, '2026-03-27 16:44:03');
INSERT INTO `dispatch_record` VALUES (80, 53, 13, 1, 86.87, 10.78, 4, NULL, '2026-03-27 17:22:22', NULL, '2026-03-27 16:52:22');
INSERT INTO `dispatch_record` VALUES (81, 53, 13, 2, NULL, NULL, 4, NULL, '2026-03-28 13:20:01', 8, '2026-03-28 12:50:01');
INSERT INTO `dispatch_record` VALUES (82, 59, 13, 1, 548.20, 0.00, 4, NULL, '2026-03-28 14:48:40', NULL, '2026-03-28 14:18:40');
INSERT INTO `dispatch_record` VALUES (83, 59, 14, 2, NULL, NULL, 2, '2026-03-28 14:19:26', '2026-03-28 14:49:01', 8, '2026-03-28 14:19:01');
INSERT INTO `dispatch_record` VALUES (84, 63, 10, 1, 117.15, 6.05, 4, NULL, '2026-03-30 15:08:15', NULL, '2026-03-30 14:38:15');
INSERT INTO `dispatch_record` VALUES (85, 62, 13, 1, 558.85, 0.00, 4, '2026-03-30 19:28:09', '2026-03-30 19:28:02', NULL, '2026-03-30 18:58:02');
INSERT INTO `dispatch_record` VALUES (86, 60, 13, 1, 548.20, 0.00, 4, '2026-03-30 19:28:09', '2026-03-30 19:28:07', NULL, '2026-03-30 18:58:07');
INSERT INTO `dispatch_record` VALUES (87, 62, 11, 2, NULL, NULL, 4, NULL, '2026-03-30 19:28:16', 8, '2026-03-30 18:58:16');
INSERT INTO `dispatch_record` VALUES (88, 63, 13, 1, 548.20, 0.00, 4, NULL, '2026-03-30 19:28:18', NULL, '2026-03-30 18:58:18');
INSERT INTO `dispatch_record` VALUES (89, 47, 7, 3, NULL, NULL, 2, '2026-03-30 19:17:47', '2026-03-30 19:17:47', NULL, '2026-03-30 19:17:47');
INSERT INTO `dispatch_record` VALUES (90, 62, 13, 1, 558.85, 0.00, 4, '2026-03-30 23:07:21', '2026-03-30 23:06:41', NULL, '2026-03-30 22:36:41');
INSERT INTO `dispatch_record` VALUES (91, 60, 13, 1, 548.20, 0.00, 4, '2026-03-30 23:07:21', '2026-03-30 23:06:50', NULL, '2026-03-30 22:36:50');
INSERT INTO `dispatch_record` VALUES (92, 60, 12, 2, NULL, NULL, 4, '2026-03-30 23:07:21', '2026-03-30 23:06:58', 8, '2026-03-30 22:36:58');
INSERT INTO `dispatch_record` VALUES (93, 62, 7, 2, NULL, NULL, 2, '2026-03-30 22:37:23', '2026-03-30 23:07:03', 8, '2026-03-30 22:37:03');
INSERT INTO `dispatch_record` VALUES (94, 60, 14, 2, NULL, NULL, 2, '2026-03-30 22:37:31', '2026-03-30 23:07:10', 8, '2026-03-30 22:37:10');
INSERT INTO `dispatch_record` VALUES (95, 61, 13, 1, 558.85, 0.00, 2, '2026-03-30 22:41:01', '2026-03-30 23:08:19', NULL, '2026-03-30 22:38:19');
INSERT INTO `dispatch_record` VALUES (96, 63, 13, 1, 548.20, 0.00, 2, '2026-03-30 22:41:00', '2026-03-30 23:08:28', NULL, '2026-03-30 22:38:28');
INSERT INTO `dispatch_record` VALUES (97, 64, 7, 1, 533.54, 0.00, 2, '2026-03-31 12:42:29', '2026-03-31 13:12:19', NULL, '2026-03-31 12:42:19');
INSERT INTO `dispatch_record` VALUES (98, 65, 7, 1, 189.57, 2.20, 2, '2026-03-31 14:53:02', '2026-03-31 15:22:10', NULL, '2026-03-31 14:52:10');
INSERT INTO `dispatch_record` VALUES (99, 69, 13, 1, 108.04, 6.86, 2, '2026-03-31 15:37:31', '2026-03-31 16:07:20', NULL, '2026-03-31 15:37:20');
INSERT INTO `dispatch_record` VALUES (100, 70, 12, 1, 90.44, 14.83, 2, '2026-03-31 15:50:56', '2026-03-31 16:20:50', NULL, '2026-03-31 15:50:50');
INSERT INTO `dispatch_record` VALUES (101, 71, 11, 1, 82.43, 12.81, 2, '2026-03-31 17:24:38', '2026-03-31 17:54:21', NULL, '2026-03-31 17:24:21');
INSERT INTO `dispatch_record` VALUES (102, 67, 11, 3, NULL, NULL, 2, '2026-03-31 17:26:40', '2026-03-31 17:26:40', NULL, '2026-03-31 17:26:40');
INSERT INTO `dispatch_record` VALUES (103, 72, 14, 1, 467.91, 0.18, 2, '2026-03-31 19:01:21', '2026-03-31 19:31:12', NULL, '2026-03-31 19:01:12');
INSERT INTO `dispatch_record` VALUES (104, 67, 14, 3, NULL, NULL, 2, '2026-03-31 19:09:59', '2026-03-31 19:09:59', NULL, '2026-03-31 19:09:59');
INSERT INTO `dispatch_record` VALUES (105, 66, 10, 1, 202.47, 2.20, 2, '2026-03-31 20:07:09', '2026-03-31 20:25:44', NULL, '2026-03-31 19:55:44');
INSERT INTO `dispatch_record` VALUES (106, 68, 12, 1, 96.80, 9.29, 2, '2026-03-31 20:06:51', '2026-03-31 20:26:08', NULL, '2026-03-31 19:56:08');
INSERT INTO `dispatch_record` VALUES (107, 66, 10, 1, 202.47, 2.20, 2, '2026-03-31 20:07:09', '2026-03-31 20:36:25', NULL, '2026-03-31 20:06:25');
INSERT INTO `dispatch_record` VALUES (108, 68, 12, 1, 96.80, 9.29, 2, '2026-03-31 20:06:51', '2026-03-31 20:36:28', NULL, '2026-03-31 20:06:28');
INSERT INTO `dispatch_record` VALUES (109, 73, 11, 1, 333.58, 0.74, 2, '2026-04-07 14:02:40', '2026-04-07 14:30:47', NULL, '2026-04-07 14:00:47');
INSERT INTO `dispatch_record` VALUES (110, 77, 11, 1, 109.11, 6.50, 2, '2026-04-07 14:02:39', '2026-04-07 14:31:27', NULL, '2026-04-07 14:01:27');
INSERT INTO `dispatch_record` VALUES (111, 74, 11, 1, 147.74, 3.66, 2, '2026-04-07 14:02:37', '2026-04-07 14:31:31', NULL, '2026-04-07 14:01:31');
INSERT INTO `dispatch_record` VALUES (112, 75, 13, 1, 82.90, 19.79, 2, '2026-04-07 14:02:26', '2026-04-07 14:31:35', NULL, '2026-04-07 14:01:35');
INSERT INTO `dispatch_record` VALUES (113, 76, 11, 1, 118.30, 5.32, 2, '2026-04-07 14:02:38', '2026-04-07 14:31:38', NULL, '2026-04-07 14:01:38');
INSERT INTO `dispatch_record` VALUES (114, 81, 7, 1, 125.36, 4.46, 2, '2026-04-07 14:06:30', '2026-04-07 14:35:36', NULL, '2026-04-07 14:05:36');
INSERT INTO `dispatch_record` VALUES (115, 78, 7, 2, NULL, NULL, 4, NULL, '2026-04-07 14:36:49', 8, '2026-04-07 14:06:49');
INSERT INTO `dispatch_record` VALUES (122, 80, 13, 1, 171.97, 3.04, 4, NULL, '2026-04-07 14:43:36', NULL, '2026-04-07 14:13:36');
INSERT INTO `dispatch_record` VALUES (123, 84, 7, 3, NULL, NULL, 2, '2026-04-08 01:00:56', '2026-04-08 01:00:56', NULL, '2026-04-08 01:00:56');
INSERT INTO `dispatch_record` VALUES (124, 85, 11, 3, NULL, NULL, 2, '2026-04-08 01:34:07', '2026-04-08 01:34:07', NULL, '2026-04-08 01:34:07');
INSERT INTO `dispatch_record` VALUES (125, 86, 13, 3, NULL, NULL, 2, '2026-04-08 01:41:13', '2026-04-08 01:41:13', NULL, '2026-04-08 01:41:13');
INSERT INTO `dispatch_record` VALUES (126, 87, 10, 3, NULL, NULL, 2, '2026-04-08 01:45:55', '2026-04-08 01:45:55', NULL, '2026-04-08 01:45:55');
INSERT INTO `dispatch_record` VALUES (127, 88, 12, 3, NULL, NULL, 2, '2026-04-08 01:52:18', '2026-04-08 01:52:18', NULL, '2026-04-08 01:52:18');
INSERT INTO `dispatch_record` VALUES (128, 89, 14, 3, NULL, NULL, 2, '2026-04-08 01:57:46', '2026-04-08 01:57:46', NULL, '2026-04-08 01:57:46');
INSERT INTO `dispatch_record` VALUES (129, 90, 13, 1, 468.16, 0.18, 2, '2026-04-08 01:59:24', '2026-04-08 02:28:52', NULL, '2026-04-08 01:58:52');
INSERT INTO `dispatch_record` VALUES (130, 84, 13, 1, 542.43, 0.00, 2, '2026-04-08 02:59:14', '2026-04-08 03:28:28', NULL, '2026-04-08 02:58:28');
INSERT INTO `dispatch_record` VALUES (131, 91, 14, 1, 462.62, 0.19, 2, '2026-04-08 03:55:23', '2026-04-08 04:24:57', NULL, '2026-04-08 03:54:57');
INSERT INTO `dispatch_record` VALUES (132, 92, 7, 1, 68.38, 13.55, 2, '2026-04-08 04:00:22', '2026-04-08 04:30:14', NULL, '2026-04-08 04:00:14');
INSERT INTO `dispatch_record` VALUES (133, 93, 12, 1, 132.92, 4.65, 4, NULL, '2026-04-09 13:23:24', NULL, '2026-04-09 12:53:24');
INSERT INTO `dispatch_record` VALUES (134, 80, 13, 1, 72.90, 19.25, 2, '2026-04-09 14:35:38', '2026-04-09 14:46:34', NULL, '2026-04-09 14:16:34');
INSERT INTO `dispatch_record` VALUES (135, 94, 12, 1, 132.92, 4.65, 2, '2026-04-09 14:22:03', '2026-04-09 14:50:51', NULL, '2026-04-09 14:20:51');
INSERT INTO `dispatch_record` VALUES (136, 96, 13, 1, 61.73, 27.90, 2, '2026-04-09 14:35:36', '2026-04-09 15:05:00', NULL, '2026-04-09 14:35:00');
INSERT INTO `dispatch_record` VALUES (137, 96, 13, 1, 61.73, 27.90, 2, '2026-04-09 14:35:36', '2026-04-09 15:05:12', NULL, '2026-04-09 14:35:12');
INSERT INTO `dispatch_record` VALUES (138, 95, 10, 1, 103.20, 7.37, 3, '2026-04-09 14:40:14', '2026-04-09 15:05:15', NULL, '2026-04-09 14:35:15');
INSERT INTO `dispatch_record` VALUES (139, 80, 13, 1, 69.12, 19.25, 2, '2026-04-09 14:35:38', '2026-04-09 15:05:18', NULL, '2026-04-09 14:35:18');
INSERT INTO `dispatch_record` VALUES (140, 98, 7, 2, NULL, NULL, 2, '2026-04-09 14:39:58', '2026-04-09 15:06:51', 8, '2026-04-09 14:36:51');
INSERT INTO `dispatch_record` VALUES (141, 97, 7, 1, 79.77, 9.83, 2, '2026-04-09 14:39:57', '2026-04-09 15:08:18', NULL, '2026-04-09 14:38:18');
INSERT INTO `dispatch_record` VALUES (142, 95, 10, 1, 103.20, 7.37, 2, '2026-04-09 14:41:01', '2026-04-09 15:10:23', NULL, '2026-04-09 14:40:23');
INSERT INTO `dispatch_record` VALUES (143, 99, 7, 3, NULL, NULL, 2, '2026-04-09 21:48:46', '2026-04-09 21:48:46', NULL, '2026-04-09 21:48:46');
INSERT INTO `dispatch_record` VALUES (144, 100, 14, 2, 131.19, 4.51, 2, '2026-04-09 22:05:15', '2026-04-09 22:31:55', 8, '2026-04-09 22:01:55');
INSERT INTO `dispatch_record` VALUES (145, 101, 11, 2, 327.56, 0.74, 2, '2026-04-09 22:04:29', '2026-04-09 22:32:54', 8, '2026-04-09 22:02:54');
INSERT INTO `dispatch_record` VALUES (146, 103, 13, 2, 79.30, 12.56, 4, NULL, '2026-04-09 22:45:13', 8, '2026-04-09 22:15:13');
INSERT INTO `dispatch_record` VALUES (147, 103, 12, 2, NULL, NULL, 2, '2026-04-09 22:17:17', '2026-04-09 22:45:23', 8, '2026-04-09 22:15:23');
INSERT INTO `dispatch_record` VALUES (148, 105, 11, 2, 183.83, 2.46, 4, NULL, '2026-04-09 23:41:30', 8, '2026-04-09 23:11:30');
INSERT INTO `dispatch_record` VALUES (149, 104, 7, 2, 76.35, 10.61, 2, '2026-04-09 23:30:51', '2026-04-09 23:58:25', 8, '2026-04-09 23:28:25');
INSERT INTO `dispatch_record` VALUES (150, 107, 7, 2, 226.19, 1.59, 2, '2026-04-09 23:30:50', '2026-04-09 23:58:29', 8, '2026-04-09 23:28:29');
INSERT INTO `dispatch_record` VALUES (151, 105, 11, 2, NULL, NULL, 4, NULL, '2026-04-10 12:44:39', 8, '2026-04-10 12:14:39');
INSERT INTO `dispatch_record` VALUES (152, 105, 12, 2, NULL, NULL, 2, '2026-04-10 12:22:42', '2026-04-10 12:52:36', 8, '2026-04-10 12:22:36');
INSERT INTO `dispatch_record` VALUES (153, 108, 14, 2, 539.18, 0.00, 2, '2026-04-10 12:24:30', '2026-04-10 12:53:59', 8, '2026-04-10 12:23:59');
INSERT INTO `dispatch_record` VALUES (154, 111, 10, 2, 131.96, 4.65, 2, '2026-04-10 12:46:02', '2026-04-10 13:14:01', 8, '2026-04-10 12:44:01');
INSERT INTO `dispatch_record` VALUES (155, 112, 10, 2, 132.21, 4.51, 2, '2026-04-10 12:46:33', '2026-04-10 13:16:16', 8, '2026-04-10 12:46:16');
INSERT INTO `dispatch_record` VALUES (156, 110, 12, 2, 77.65, 12.38, 2, '2026-04-10 12:52:36', '2026-04-10 13:20:58', 8, '2026-04-10 12:50:58');
INSERT INTO `dispatch_record` VALUES (157, 106, 12, 3, NULL, NULL, 2, '2026-04-10 13:00:21', '2026-04-10 13:00:21', NULL, '2026-04-10 13:00:21');
INSERT INTO `dispatch_record` VALUES (158, 110, 12, 3, NULL, NULL, 2, '2026-04-10 13:02:33', '2026-04-10 13:02:33', NULL, '2026-04-10 13:02:33');
INSERT INTO `dispatch_record` VALUES (159, 106, 12, 3, NULL, NULL, 2, '2026-04-10 13:03:57', '2026-04-10 13:03:57', NULL, '2026-04-10 13:03:57');
INSERT INTO `dispatch_record` VALUES (160, 114, 11, 2, 77.08, 13.04, 2, '2026-04-10 13:40:06', '2026-04-10 14:09:44', 8, '2026-04-10 13:39:44');
INSERT INTO `dispatch_record` VALUES (161, 116, 10, 2, 541.47, 0.00, 2, '2026-04-10 22:43:14', '2026-04-10 23:12:51', 8, '2026-04-10 22:42:51');

-- ----------------------------
-- Table structure for fee_detail
-- ----------------------------
DROP TABLE IF EXISTS `fee_detail`;
CREATE TABLE `fee_detail`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `service_fee` decimal(8, 2) NOT NULL COMMENT '基础服务费',
  `overtime_fee` decimal(8, 2) NOT NULL DEFAULT 0.00 COMMENT '超时费',
  `coupon_deduct` decimal(8, 2) NOT NULL DEFAULT 0.00 COMMENT '优惠券抵扣',
  `actual_fee` decimal(8, 2) NOT NULL COMMENT '实际应付总额',
  `deposit_fee` decimal(8, 2) NOT NULL DEFAULT 0.00 COMMENT '已付定金',
  `tail_fee` decimal(8, 2) NOT NULL DEFAULT 0.00 COMMENT '尾款金额',
  `commission_rate` decimal(5, 4) NOT NULL COMMENT '平台佣金比例（如0.2000=20%）',
  `commission_fee` decimal(8, 2) NOT NULL COMMENT '平台佣金金额',
  `cleaner_income` decimal(8, 2) NOT NULL COMMENT '保洁员实际收入',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 32 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单费用明细表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fee_detail
-- ----------------------------
INSERT INTO `fee_detail` VALUES (1, 2, 120.00, 0.00, 0.00, 120.00, 0.00, 120.00, 0.2000, 24.00, 96.00, '2026-03-20 20:54:11');
INSERT INTO `fee_detail` VALUES (2, 7, 200.00, 0.00, 0.00, 200.00, 0.00, 200.00, 0.2000, 40.00, 160.00, '2026-03-21 13:47:09');
INSERT INTO `fee_detail` VALUES (3, 10, 180.00, 0.00, 0.00, 180.00, 0.00, 180.00, 0.2000, 36.00, 144.00, '2026-03-21 17:12:10');
INSERT INTO `fee_detail` VALUES (4, 11, 100.00, 0.00, 0.00, 0.00, 0.00, 100.00, 0.2000, 0.00, 0.00, '2026-03-22 15:00:24');
INSERT INTO `fee_detail` VALUES (5, 12, 70.00, 0.00, 0.00, 0.00, 0.00, 70.00, 0.2000, 0.00, 0.00, '2026-03-22 15:15:55');
INSERT INTO `fee_detail` VALUES (6, 13, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.2000, 0.00, 0.00, '2026-03-22 16:53:55');
INSERT INTO `fee_detail` VALUES (7, 14, 100.00, 0.00, 0.00, 100.00, 0.00, 0.00, 0.2000, 20.00, 80.00, '2026-03-22 16:53:55');
INSERT INTO `fee_detail` VALUES (8, 15, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.2000, 0.00, 0.00, '2026-03-22 16:53:55');
INSERT INTO `fee_detail` VALUES (9, 17, 70.00, 0.00, 0.00, 70.00, 0.00, 70.00, 0.2000, 14.00, 56.00, '2026-03-22 17:49:13');
INSERT INTO `fee_detail` VALUES (10, 24, 120.00, 0.00, 0.00, 120.00, 0.00, 120.00, 0.2000, 24.00, 96.00, '2026-03-23 14:58:58');
INSERT INTO `fee_detail` VALUES (11, 19, 70.00, 0.00, 0.00, 70.00, 0.00, 70.00, 0.2000, 14.00, 56.00, '2026-03-24 16:27:40');
INSERT INTO `fee_detail` VALUES (12, 55, 70.00, 0.00, 0.00, 70.00, 14.00, 56.00, 0.2000, 14.00, 56.00, '2026-03-27 16:07:56');
INSERT INTO `fee_detail` VALUES (13, 56, 70.00, 0.00, 0.00, 70.00, 14.00, 56.00, 0.2000, 14.00, 56.00, '2026-03-27 16:32:20');
INSERT INTO `fee_detail` VALUES (14, 57, 80.00, 0.00, 0.00, 80.00, 16.00, 64.00, 0.2000, 16.00, 64.00, '2026-03-27 16:46:06');
INSERT INTO `fee_detail` VALUES (15, 59, 675.00, 0.00, 0.00, 675.00, 202.50, 472.50, 0.2000, 135.00, 540.00, '2026-03-28 14:19:53');
INSERT INTO `fee_detail` VALUES (16, 70, 176.00, 0.00, 0.00, 176.00, 59.70, 139.30, 0.2000, 35.20, 140.80, '2026-03-31 16:15:05');
INSERT INTO `fee_detail` VALUES (17, 72, 11.00, 0.00, 0.00, 11.00, 0.00, 100.00, 0.2000, 2.20, 8.80, '2026-03-31 19:55:32');
INSERT INTO `fee_detail` VALUES (18, 84, 0.00, 0.00, 0.00, 0.00, 49.50, 115.50, 0.2000, 0.00, 0.00, '2026-04-08 01:07:32');
INSERT INTO `fee_detail` VALUES (19, 85, 100.00, 0.00, 0.00, 100.00, 0.00, 100.00, 0.2000, 20.00, 80.00, '2026-04-08 01:34:59');
INSERT INTO `fee_detail` VALUES (20, 86, 0.00, 0.00, 0.00, 0.00, 0.00, 80.00, 0.2000, 0.00, 0.00, '2026-04-08 01:41:45');
INSERT INTO `fee_detail` VALUES (21, 87, 0.00, 52.50, 0.00, 0.00, 0.00, 175.00, 0.2000, 0.00, 0.00, '2026-04-08 01:46:42');
INSERT INTO `fee_detail` VALUES (22, 88, 298.00, 75.00, 0.00, 298.00, 0.00, 300.00, 0.2000, 59.60, 238.40, '2026-04-08 01:53:09');
INSERT INTO `fee_detail` VALUES (23, 89, 0.00, 0.00, 0.00, 0.00, 0.00, 150.00, 0.2000, 0.00, 0.00, '2026-04-08 02:31:33');
INSERT INTO `fee_detail` VALUES (24, 91, 199.00, 0.00, 0.00, 199.00, 0.00, 199.00, 0.2000, 39.80, 159.20, '2026-04-08 03:58:59');
INSERT INTO `fee_detail` VALUES (25, 92, 80.00, 0.00, 0.00, 80.00, 0.00, 80.00, 0.2000, 16.00, 64.00, '2026-04-08 04:00:57');
INSERT INTO `fee_detail` VALUES (26, 94, 199.00, 0.00, 0.00, 199.00, 0.00, 199.00, 0.2000, 39.80, 159.20, '2026-04-09 14:23:19');
INSERT INTO `fee_detail` VALUES (27, 100, 165.00, 0.00, 0.00, 165.00, 0.00, 165.00, 0.2000, 33.00, 132.00, '2026-04-09 22:10:19');
INSERT INTO `fee_detail` VALUES (28, 103, 199.00, 0.00, 0.00, 199.00, 0.00, 199.00, 0.2000, 39.80, 159.20, '2026-04-09 22:50:06');
INSERT INTO `fee_detail` VALUES (29, 108, 150.00, 0.00, 0.00, 150.00, 0.00, 150.00, 0.2000, 30.00, 120.00, '2026-04-10 12:24:55');
INSERT INTO `fee_detail` VALUES (30, 111, 52.50, 0.00, 0.00, 52.50, 0.00, 52.50, 0.2000, 10.50, 42.00, '2026-04-10 12:47:17');
INSERT INTO `fee_detail` VALUES (31, 116, 150.00, 0.00, 0.00, 150.00, 0.00, 150.00, 0.2100, 31.50, 118.50, '2026-04-10 22:46:47');

-- ----------------------------
-- Table structure for notification
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '接收用户user_id',
  `type` tinyint NOT NULL COMMENT '通知类型：1=下单成功 2=派单成功 3=保洁员上门 4=服务完成 5=新订单待接 6=审核结果 7=投诉通知 8=超时告警',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知标题',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知内容',
  `ref_id` bigint NULL DEFAULT NULL COMMENT '关联业务ID（如订单ID）',
  `is_read` tinyint NOT NULL DEFAULT 0 COMMENT '是否已读：0=未读 1=已读',
  `read_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_read`(`user_id` ASC, `is_read` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 535 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '站内消息通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification
-- ----------------------------
INSERT INTO `notification` VALUES (1, 6, 1, '订单已提交', '您的日常保洁订单 #CM202603211436557441 已提交，正在为您匹配保洁员', 8, 1, '2026-03-21 14:40:34', '2026-03-21 14:36:56');
INSERT INTO `notification` VALUES (2, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202603211436557441，请按时在家等候', 8, 1, '2026-03-21 15:45:48', '2026-03-21 15:39:46');
INSERT INTO `notification` VALUES (3, 6, 1, '订单已提交', '您的开荒保洁订单 #CM202603211546198464 已提交，正在为您匹配保洁员', 9, 1, '2026-03-21 16:55:17', '2026-03-21 15:46:20');
INSERT INTO `notification` VALUES (4, 6, 2, '派单成功', '已为您的订单 #CM202603211546198464 匹配到保洁员，等待保洁员确认接单', 9, 1, '2026-03-21 16:55:17', '2026-03-21 15:47:31');
INSERT INTO `notification` VALUES (5, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603211546198464，请在30分钟内确认接单', 9, 1, '2026-03-21 15:47:48', '2026-03-21 15:47:31');
INSERT INTO `notification` VALUES (6, 6, 2, '派单成功', '已为您的订单 #CM202603211546198464 匹配到保洁员，等待保洁员确认接单', 9, 1, '2026-03-21 16:55:17', '2026-03-21 15:52:20');
INSERT INTO `notification` VALUES (7, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603211546198464，请在30分钟内确认接单', 9, 1, '2026-03-21 17:12:14', '2026-03-21 15:52:20');
INSERT INTO `notification` VALUES (8, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202603211546198464，请按时在家等候', 9, 1, '2026-03-21 16:55:16', '2026-03-21 15:58:53');
INSERT INTO `notification` VALUES (9, 6, 1, '订单已提交', '您的地板打蜡订单 #CM202603211711163527 已提交，正在为您匹配保洁员', 10, 1, '2026-03-21 17:22:12', '2026-03-21 17:11:16');
INSERT INTO `notification` VALUES (10, 6, 2, '派单成功', '已为您的订单 #CM202603211711163527 匹配到保洁员，等待保洁员确认接单', 10, 1, '2026-03-21 17:22:11', '2026-03-21 17:11:27');
INSERT INTO `notification` VALUES (11, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603211711163527，请在30分钟内确认接单', 10, 1, '2026-03-21 17:12:13', '2026-03-21 17:11:27');
INSERT INTO `notification` VALUES (12, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202603211711163527 即将开始服务', 10, 1, '2026-03-21 17:22:11', '2026-03-21 17:11:42');
INSERT INTO `notification` VALUES (13, 6, 4, '服务已完成', '您的订单 #CM202603211711163527 保洁员已完工，请在48小时内确认并评价', 10, 1, '2026-03-21 17:22:10', '2026-03-21 17:12:10');
INSERT INTO `notification` VALUES (14, 10, 9, '出行提醒', '您有一个订单将于 2026-03-21 18:37 开始，请提前出发！地址：重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 9, 1, '2026-03-22 14:26:55', '2026-03-21 17:31:24');
INSERT INTO `notification` VALUES (15, 6, 1, '订单已提交', '您的深度保洁订单 #CM202603221459070506 已提交，正在为您匹配保洁员', 11, 1, '2026-03-22 15:14:33', '2026-03-22 14:59:07');
INSERT INTO `notification` VALUES (16, 6, 2, '派单成功', '已为您的订单 #CM202603221459070506 匹配到保洁员，等待保洁员确认接单', 11, 1, '2026-03-22 15:14:32', '2026-03-22 14:59:25');
INSERT INTO `notification` VALUES (17, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603221459070506，请在30分钟内确认接单', 11, 1, '2026-03-22 15:00:28', '2026-03-22 14:59:25');
INSERT INTO `notification` VALUES (18, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202603221459070506 即将开始服务', 11, 1, '2026-03-22 15:14:31', '2026-03-22 15:00:07');
INSERT INTO `notification` VALUES (19, 6, 4, '服务已完成', '您的订单 #CM202603221459070506 保洁员已完工，请在48小时内确认并评价', 11, 1, '2026-03-22 15:14:31', '2026-03-22 15:00:24');
INSERT INTO `notification` VALUES (20, 6, 1, '订单已提交', '您的日常保洁订单 #CM202603221515316932 已提交，正在为您匹配保洁员', 12, 1, '2026-03-22 15:19:17', '2026-03-22 15:15:32');
INSERT INTO `notification` VALUES (21, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202603221515316932，请按时在家等候', 12, 1, '2026-03-22 15:19:17', '2026-03-22 15:15:43');
INSERT INTO `notification` VALUES (22, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202603221515316932 即将开始服务', 12, 1, '2026-03-22 15:19:17', '2026-03-22 15:15:52');
INSERT INTO `notification` VALUES (23, 6, 4, '服务已完成', '您的订单 #CM202603221515316932 保洁员已完工，请在48小时内确认并评价', 12, 1, '2026-03-22 15:19:15', '2026-03-22 15:15:55');
INSERT INTO `notification` VALUES (24, 6, 7, '投诉已结案 - 全额退款', '您的订单 #TEST_R1_FULLREFUND 投诉已结案，平台已为您全额退款', 13, 1, '2026-03-22 17:48:45', '2026-03-22 17:07:40');
INSERT INTO `notification` VALUES (25, 7, 7, '投诉结案通知', '订单 #TEST_R1_FULLREFUND 投诉结案（全额退款），本单收入已清零', 13, 1, '2026-03-23 14:41:18', '2026-03-22 17:07:40');
INSERT INTO `notification` VALUES (26, 6, 7, '投诉已结案 - 驳回', '您的订单 #TEST_R2_REJECT 投诉申请已驳回，订单已完成', 14, 1, '2026-03-22 17:48:46', '2026-03-22 17:07:40');
INSERT INTO `notification` VALUES (27, 6, 7, '投诉已结案 - 免费重做', '您的订单 #TEST_R3_REDO 已安排免费重做，平台将重新为您派单', 15, 1, '2026-03-22 17:48:46', '2026-03-22 17:07:40');
INSERT INTO `notification` VALUES (28, 7, 7, '投诉结案通知', '订单 #TEST_R3_REDO 投诉结案（免费重做），本单收入已清零', 15, 1, '2026-03-23 14:41:18', '2026-03-22 17:07:40');
INSERT INTO `notification` VALUES (29, 6, 7, '投诉已结案 - 免费重做', '您的订单 #TEST_R3_REDO 已安排免费重做，平台将重新为您派单', 15, 1, '2026-03-22 17:48:45', '2026-03-22 17:10:23');
INSERT INTO `notification` VALUES (30, 7, 7, '投诉结案通知', '订单 #TEST_R3_REDO 投诉结案（免费重做），本单收入已清零', 15, 1, '2026-03-23 14:41:18', '2026-03-22 17:10:23');
INSERT INTO `notification` VALUES (31, 8, 7, '保洁员未到场告警', '订单 #TEST_NOSHOW 顾客报告保洁员未到场，请及时处理', 16, 0, NULL, '2026-03-22 17:10:43');
INSERT INTO `notification` VALUES (32, 7, 4, '顾客已确认完成', '顾客已确认订单 #TEST_CONFIRM 完成，收入已计入本月结算', 18, 1, '2026-03-23 14:41:18', '2026-03-22 17:11:08');
INSERT INTO `notification` VALUES (33, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #TEST_NOSHOW2 即将开始服务', 17, 1, '2026-03-23 14:43:26', '2026-03-22 17:49:10');
INSERT INTO `notification` VALUES (34, 6, 4, '服务已完成', '您的订单 #TEST_NOSHOW2 保洁员已完工，请在48小时内确认并评价', 17, 1, '2026-03-23 14:43:26', '2026-03-22 17:49:13');
INSERT INTO `notification` VALUES (35, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #TEST_POOL_DIST，请按时在家等候', 19, 1, '2026-03-23 14:43:26', '2026-03-22 17:49:57');
INSERT INTO `notification` VALUES (36, 6, 1, '订单已提交', '您的地板打蜡订单 #CM202603221759478661 已提交，正在为您匹配保洁员', 20, 1, '2026-03-23 14:43:26', '2026-03-22 17:59:47');
INSERT INTO `notification` VALUES (37, 6, 1, '订单已提交', '您的深度保洁订单 #CM202603221800203529 已提交，正在为您匹配保洁员', 21, 1, '2026-03-23 14:43:26', '2026-03-22 18:00:21');
INSERT INTO `notification` VALUES (38, 7, 4, '顾客已确认完成', '顾客已确认订单 #TEST_NOSHOW2 完成，收入已计入本月结算', 17, 1, '2026-03-23 14:41:18', '2026-03-22 18:00:45');
INSERT INTO `notification` VALUES (39, 6, 2, '派单成功', '已为您的订单 #CM202603221759478661 匹配到保洁员，等待保洁员确认接单', 20, 1, '2026-03-23 14:43:26', '2026-03-22 18:01:23');
INSERT INTO `notification` VALUES (40, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603221759478661，请在30分钟内确认接单', 20, 1, '2026-03-23 14:41:18', '2026-03-22 18:01:23');
INSERT INTO `notification` VALUES (41, 6, 2, '派单成功', '已为您的订单 #CM202603221800203529 匹配到保洁员，等待保洁员确认接单', 21, 1, '2026-03-23 14:43:26', '2026-03-22 18:01:29');
INSERT INTO `notification` VALUES (42, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603221800203529，请在30分钟内确认接单', 21, 1, '2026-03-23 14:41:18', '2026-03-22 18:01:29');
INSERT INTO `notification` VALUES (43, 6, 1, '订单已提交', '您的日常保洁订单 #CM202603221814455737 已提交，正在为您匹配保洁员', 22, 1, '2026-03-23 14:43:26', '2026-03-22 18:14:45');
INSERT INTO `notification` VALUES (44, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202603221814455737，请按时在家等候', 22, 1, '2026-03-23 14:43:26', '2026-03-22 18:21:21');
INSERT INTO `notification` VALUES (45, 6, 1, '订单已提交', '您的日常保洁订单 #CM202603222105382682 已提交，正在为您匹配保洁员', 23, 1, '2026-03-23 14:43:26', '2026-03-22 21:05:38');
INSERT INTO `notification` VALUES (46, 6, 2, '派单成功', '已为您的订单 #CM202603222105382682 匹配到保洁员，等待保洁员确认接单', 23, 1, '2026-03-23 14:43:26', '2026-03-22 21:06:10');
INSERT INTO `notification` VALUES (47, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603222105382682，请在30分钟内确认接单', 23, 1, '2026-03-23 14:41:18', '2026-03-22 21:06:10');
INSERT INTO `notification` VALUES (48, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202603222105382682，请按时在家等候', 23, 1, '2026-03-23 14:43:26', '2026-03-22 21:07:42');
INSERT INTO `notification` VALUES (49, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202603222105382682，请按时在家等候', 23, 1, '2026-03-23 14:43:26', '2026-03-22 21:08:30');
INSERT INTO `notification` VALUES (50, 12, 6, '审核未通过', '您的保洁员资质审核未通过，原因：1，请修改后重新提交', NULL, 1, '2026-03-24 21:31:35', '2026-03-22 23:05:59');
INSERT INTO `notification` VALUES (51, 12, 6, '审核通过', '恭喜您！您的保洁员资质审核已通过，现在可以开始接单了', NULL, 1, '2026-03-24 21:31:35', '2026-03-22 23:06:42');
INSERT INTO `notification` VALUES (52, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #TEST_R3_REDO，请按时在家等候', 15, 1, '2026-03-23 14:43:26', '2026-03-22 23:07:51');
INSERT INTO `notification` VALUES (53, 11, 6, '审核通过', '恭喜您！您的保洁员资质审核已通过，现在可以开始接单了', NULL, 1, '2026-03-31 18:59:50', '2026-03-22 23:44:21');
INSERT INTO `notification` VALUES (54, 6, 1, '订单已提交', '您的开荒保洁订单 #CM202603231442412875 已提交，正在为您匹配保洁员', 24, 1, '2026-03-23 14:43:26', '2026-03-23 14:42:41');
INSERT INTO `notification` VALUES (55, 6, 1, '订单已提交', '您的家电清洗订单 #CM202603231443180605 已提交，正在为您匹配保洁员', 25, 1, '2026-03-23 14:43:26', '2026-03-23 14:43:18');
INSERT INTO `notification` VALUES (56, 6, 2, '派单成功', '已为您的订单 #CM202603231442412875 匹配到保洁员，等待保洁员确认接单', 24, 1, '2026-03-23 15:01:45', '2026-03-23 14:43:40');
INSERT INTO `notification` VALUES (57, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603231442412875，请在30分钟内确认接单', 24, 1, '2026-03-23 14:54:26', '2026-03-23 14:43:40');
INSERT INTO `notification` VALUES (58, 6, 2, '派单成功', '已为您的订单 #CM202603231443180605 匹配到保洁员，等待保洁员确认接单', 25, 1, '2026-03-23 15:01:45', '2026-03-23 14:46:09');
INSERT INTO `notification` VALUES (59, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603231443180605，请在30分钟内确认接单', 25, 1, '2026-03-23 14:54:25', '2026-03-23 14:46:09');
INSERT INTO `notification` VALUES (60, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202603231443180605，请按时在家等候', 25, 1, '2026-03-23 15:01:45', '2026-03-23 14:58:46');
INSERT INTO `notification` VALUES (61, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202603231442412875 即将开始服务', 24, 1, '2026-03-23 15:01:45', '2026-03-23 14:58:55');
INSERT INTO `notification` VALUES (62, 6, 4, '服务已完成', '您的订单 #CM202603231442412875 保洁员已完工，请在48小时内确认并评价', 24, 1, '2026-03-23 15:01:45', '2026-03-23 14:58:58');
INSERT INTO `notification` VALUES (63, 7, 4, '顾客已确认完成', '顾客已确认订单 #CM202603231442412875 完成，收入已计入本月结算', 24, 1, '2026-03-24 21:30:33', '2026-03-23 14:59:23');
INSERT INTO `notification` VALUES (64, 7, 9, '出行提醒', '您有一个订单将于 2026-03-23 20:00 开始，请提前出发！地址：重庆市市辖区大渡口区金科 | 1 18300000001', 25, 1, '2026-03-24 21:30:33', '2026-03-23 18:57:35');
INSERT INTO `notification` VALUES (65, 6, 1, '订单已提交', '您的日常保洁订单 #CM202603241521044166 已提交，正在为您匹配保洁员', 26, 1, '2026-03-24 22:39:04', '2026-03-24 15:21:05');
INSERT INTO `notification` VALUES (66, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 0, NULL, '2026-03-24 15:21:15');
INSERT INTO `notification` VALUES (67, 6, 1, '订单已提交', '您的日常保洁订单 #CM202603241522544394 已提交，正在为您匹配保洁员', 27, 1, '2026-03-24 22:39:04', '2026-03-24 15:22:54');
INSERT INTO `notification` VALUES (68, 6, 2, '派单成功', '已为您的订单 #CM202603241522544394 匹配到保洁员，等待保洁员确认接单', 27, 1, '2026-03-24 22:39:04', '2026-03-24 15:23:04');
INSERT INTO `notification` VALUES (69, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603241522544394，请在30分钟内确认接单', 27, 1, '2026-03-31 18:59:50', '2026-03-24 15:23:04');
INSERT INTO `notification` VALUES (70, 8, 8, '派单失败，需手动处理', '订单 CM_TEST_NOCOORD 暂无合适保洁员，请手动派单', 28, 0, NULL, '2026-03-24 15:25:42');
INSERT INTO `notification` VALUES (71, 6, 1, '订单已提交', '您的日常保洁订单 #CM202603241540271294 已提交，正在为您匹配保洁员', 29, 1, '2026-03-24 22:39:04', '2026-03-24 15:40:27');
INSERT INTO `notification` VALUES (72, 7, 9, '出行提醒', '您有一个订单将于 2026-03-24 17:11 开始，请提前出发！地址：test-pool-dist', 19, 1, '2026-03-24 21:30:33', '2026-03-24 16:08:19');
INSERT INTO `notification` VALUES (73, 6, 1, '订单已提交', '您的玻璃清洗订单 #CM202603241626292857 已提交，正在为您匹配保洁员', 30, 1, '2026-03-24 22:39:04', '2026-03-24 16:26:30');
INSERT INTO `notification` VALUES (74, 6, 2, '派单成功', '已为您的订单 #CM202603241540271294 匹配到保洁员，等待保洁员确认接单', 29, 1, '2026-03-24 22:39:04', '2026-03-24 16:26:52');
INSERT INTO `notification` VALUES (75, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603241540271294，请在30分钟内确认接单', 29, 1, '2026-03-31 18:59:50', '2026-03-24 16:26:52');
INSERT INTO `notification` VALUES (76, 6, 2, '派单成功', '已为您的订单 #CM202603241626292857 匹配到保洁员，等待保洁员确认接单', 30, 1, '2026-03-24 22:39:04', '2026-03-24 16:27:00');
INSERT INTO `notification` VALUES (77, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603241626292857，请在30分钟内确认接单', 30, 1, '2026-03-24 16:34:38', '2026-03-24 16:27:00');
INSERT INTO `notification` VALUES (78, 6, 2, '派单成功', '已为您的订单 #CM202603241522544394 匹配到保洁员，等待保洁员确认接单', 27, 1, '2026-03-24 22:39:04', '2026-03-24 16:27:10');
INSERT INTO `notification` VALUES (79, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603241522544394，请在30分钟内确认接单', 27, 1, '2026-03-24 16:28:47', '2026-03-24 16:27:10');
INSERT INTO `notification` VALUES (80, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 0, NULL, '2026-03-24 16:27:13');
INSERT INTO `notification` VALUES (81, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #TEST_POOL_DIST 即将开始服务', 19, 1, '2026-03-24 22:39:04', '2026-03-24 16:27:38');
INSERT INTO `notification` VALUES (82, 6, 4, '服务已完成', '您的订单 #TEST_POOL_DIST 保洁员已完工，请在48小时内确认并评价', 19, 1, '2026-03-24 22:39:04', '2026-03-24 16:27:40');
INSERT INTO `notification` VALUES (83, 6, 2, '派单成功', '已为您的订单 #CM_TEST_NOCOORD 匹配到保洁员，等待保洁员确认接单', 28, 1, '2026-03-24 22:39:04', '2026-03-24 16:37:49');
INSERT INTO `notification` VALUES (84, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_NOCOORD，请在30分钟内确认接单', 28, 1, '2026-03-24 21:31:35', '2026-03-24 16:37:49');
INSERT INTO `notification` VALUES (85, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 0, NULL, '2026-03-24 16:39:06');
INSERT INTO `notification` VALUES (86, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 0, NULL, '2026-03-24 16:39:54');
INSERT INTO `notification` VALUES (87, 6, 2, '派单成功', '已为您的订单 #CM202603241522544394 匹配到保洁员，等待保洁员确认接单', 27, 1, '2026-03-24 22:39:04', '2026-03-24 16:40:51');
INSERT INTO `notification` VALUES (88, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603241522544394，请在30分钟内确认接单', 27, 1, '2026-03-24 21:31:35', '2026-03-24 16:40:51');
INSERT INTO `notification` VALUES (89, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 0, NULL, '2026-03-24 16:40:56');
INSERT INTO `notification` VALUES (90, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 0, NULL, '2026-03-24 17:00:57');
INSERT INTO `notification` VALUES (91, 6, 2, '派单成功', '已为您的订单 #CM_TEST_NOCOORD 匹配到保洁员，等待保洁员确认接单', 28, 1, '2026-03-24 22:39:04', '2026-03-24 17:01:01');
INSERT INTO `notification` VALUES (92, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_NOCOORD，请在30分钟内确认接单', 28, 1, '2026-04-09 14:41:09', '2026-03-24 17:01:01');
INSERT INTO `notification` VALUES (93, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 1, '2026-03-31 19:35:58', '2026-03-24 17:01:07');
INSERT INTO `notification` VALUES (94, 7, 4, '顾客已确认完成', '顾客已确认订单 #TEST_POOL_DIST 完成，收入已计入本月结算', 19, 1, '2026-03-24 21:30:33', '2026-03-24 17:08:01');
INSERT INTO `notification` VALUES (95, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 1, '2026-03-31 19:35:58', '2026-03-24 17:08:30');
INSERT INTO `notification` VALUES (96, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_003 匹配到保洁员，等待保洁员确认接单', 33, 1, '2026-03-24 22:39:04', '2026-03-24 17:20:13');
INSERT INTO `notification` VALUES (97, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_003，请在30分钟内确认接单', 33, 1, '2026-03-24 21:31:35', '2026-03-24 17:20:13');
INSERT INTO `notification` VALUES (98, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_002 匹配到保洁员，等待保洁员确认接单', 32, 1, '2026-03-24 22:39:04', '2026-03-24 17:20:18');
INSERT INTO `notification` VALUES (99, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_002，请在30分钟内确认接单', 32, 1, '2026-03-24 21:31:35', '2026-03-24 17:20:18');
INSERT INTO `notification` VALUES (100, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_001 匹配到保洁员，等待保洁员确认接单', 31, 1, '2026-03-24 22:39:04', '2026-03-24 17:20:21');
INSERT INTO `notification` VALUES (101, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_001，请在30分钟内确认接单', 31, 1, '2026-03-24 21:31:35', '2026-03-24 17:20:21');
INSERT INTO `notification` VALUES (102, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_005 匹配到保洁员，等待保洁员确认接单', 35, 1, '2026-03-24 22:39:04', '2026-03-24 17:20:23');
INSERT INTO `notification` VALUES (103, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_005，请在30分钟内确认接单', 35, 1, '2026-03-24 21:31:35', '2026-03-24 17:20:23');
INSERT INTO `notification` VALUES (104, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_004 匹配到保洁员，等待保洁员确认接单', 34, 1, '2026-03-24 22:39:04', '2026-03-24 17:20:27');
INSERT INTO `notification` VALUES (105, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_004，请在30分钟内确认接单', 34, 1, '2026-03-24 21:31:35', '2026-03-24 17:20:27');
INSERT INTO `notification` VALUES (106, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_002 匹配到保洁员，等待保洁员确认接单', 32, 1, '2026-03-24 22:39:04', '2026-03-24 17:33:32');
INSERT INTO `notification` VALUES (107, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_002，请在30分钟内确认接单', 32, 1, '2026-03-24 21:31:35', '2026-03-24 17:33:32');
INSERT INTO `notification` VALUES (108, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_004 匹配到保洁员，等待保洁员确认接单', 34, 1, '2026-03-24 22:39:04', '2026-03-24 17:33:35');
INSERT INTO `notification` VALUES (109, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_004，请在30分钟内确认接单', 34, 1, '2026-04-09 14:41:09', '2026-03-24 17:33:35');
INSERT INTO `notification` VALUES (110, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_004 匹配到保洁员，等待保洁员确认接单', 34, 1, '2026-03-24 22:39:04', '2026-03-24 19:14:41');
INSERT INTO `notification` VALUES (111, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_004，请在30分钟内确认接单', 34, 1, '2026-03-24 21:31:35', '2026-03-24 19:14:41');
INSERT INTO `notification` VALUES (112, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_005 匹配到保洁员，等待保洁员确认接单', 35, 1, '2026-03-24 22:39:04', '2026-03-24 19:14:45');
INSERT INTO `notification` VALUES (113, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_005，请在30分钟内确认接单', 35, 1, '2026-03-24 21:31:35', '2026-03-24 19:14:45');
INSERT INTO `notification` VALUES (114, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_003 匹配到保洁员，等待保洁员确认接单', 33, 1, '2026-03-24 22:39:04', '2026-03-24 19:14:48');
INSERT INTO `notification` VALUES (115, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_003，请在30分钟内确认接单', 33, 1, '2026-03-31 18:59:50', '2026-03-24 19:14:48');
INSERT INTO `notification` VALUES (116, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_001 匹配到保洁员，等待保洁员确认接单', 31, 1, '2026-03-24 22:39:04', '2026-03-24 19:14:52');
INSERT INTO `notification` VALUES (117, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_001，请在30分钟内确认接单', 31, 1, '2026-03-24 21:31:35', '2026-03-24 19:14:52');
INSERT INTO `notification` VALUES (118, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_002 匹配到保洁员，等待保洁员确认接单', 32, 1, '2026-03-24 22:39:04', '2026-03-24 19:14:55');
INSERT INTO `notification` VALUES (119, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_002，请在30分钟内确认接单', 32, 1, '2026-03-31 18:59:50', '2026-03-24 19:14:55');
INSERT INTO `notification` VALUES (120, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_001 匹配到保洁员，等待保洁员确认接单', 31, 1, '2026-03-24 22:39:04', '2026-03-24 19:17:19');
INSERT INTO `notification` VALUES (121, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_001，请在30分钟内确认接单', 31, 1, '2026-03-24 21:31:35', '2026-03-24 19:17:19');
INSERT INTO `notification` VALUES (122, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_003 匹配到保洁员，等待保洁员确认接单', 33, 1, '2026-03-24 22:39:04', '2026-03-24 19:17:22');
INSERT INTO `notification` VALUES (123, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_003，请在30分钟内确认接单', 33, 1, '2026-04-09 14:41:09', '2026-03-24 19:17:22');
INSERT INTO `notification` VALUES (124, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_001 匹配到保洁员，等待保洁员确认接单', 31, 1, '2026-03-24 22:39:04', '2026-03-24 20:59:07');
INSERT INTO `notification` VALUES (125, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_001，请在30分钟内确认接单', 31, 1, '2026-03-24 21:31:34', '2026-03-24 20:59:07');
INSERT INTO `notification` VALUES (126, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_001 匹配到保洁员，等待保洁员确认接单', 31, 1, '2026-03-24 22:39:04', '2026-03-24 21:01:42');
INSERT INTO `notification` VALUES (127, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_001，请在30分钟内确认接单', 31, 1, '2026-03-24 21:31:35', '2026-03-24 21:01:42');
INSERT INTO `notification` VALUES (128, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_004 匹配到保洁员，等待保洁员确认接单', 34, 1, '2026-03-24 22:39:04', '2026-03-24 21:13:35');
INSERT INTO `notification` VALUES (129, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_004，请在30分钟内确认接单', 34, 1, '2026-03-31 18:59:50', '2026-03-24 21:13:35');
INSERT INTO `notification` VALUES (130, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_005 匹配到保洁员，等待保洁员确认接单', 35, 1, '2026-03-24 22:39:04', '2026-03-24 21:13:39');
INSERT INTO `notification` VALUES (131, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_005，请在30分钟内确认接单', 35, 1, '2026-04-09 14:41:09', '2026-03-24 21:13:39');
INSERT INTO `notification` VALUES (132, 6, 2, '派单成功', '已为您的订单 #CM_TEST_NOCOORD 匹配到保洁员，等待保洁员确认接单', 28, 1, '2026-03-24 22:39:04', '2026-03-24 21:13:48');
INSERT INTO `notification` VALUES (133, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_NOCOORD，请在30分钟内确认接单', 28, 1, '2026-03-24 21:31:34', '2026-03-24 21:13:48');
INSERT INTO `notification` VALUES (134, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 1, '2026-03-31 19:35:58', '2026-03-24 21:18:09');
INSERT INTO `notification` VALUES (135, 6, 2, '派单成功', '已为您的订单 #CM202603241522544394 匹配到保洁员，等待保洁员确认接单', 27, 1, '2026-03-24 22:39:04', '2026-03-24 21:18:13');
INSERT INTO `notification` VALUES (136, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603241522544394，请在30分钟内确认接单', 27, 1, '2026-03-24 21:30:33', '2026-03-24 21:18:13');
INSERT INTO `notification` VALUES (137, 6, 2, '派单成功', '已为您的订单 #CM_TEST_NOCOORD 匹配到保洁员，等待保洁员确认接单', 28, 1, '2026-03-24 22:39:04', '2026-03-24 21:18:16');
INSERT INTO `notification` VALUES (138, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_NOCOORD，请在30分钟内确认接单', 28, 1, '2026-03-24 21:31:33', '2026-03-24 21:18:16');
INSERT INTO `notification` VALUES (139, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 1, '2026-03-31 19:35:58', '2026-03-24 21:18:17');
INSERT INTO `notification` VALUES (140, 6, 1, '订单已提交', '您的日常保洁订单 #CM202603242242269025 已提交，正在为您匹配保洁员', 41, 1, '2026-03-31 15:09:08', '2026-03-24 22:42:27');
INSERT INTO `notification` VALUES (141, 6, 2, '派单成功', '已为您的订单 #CM202603242242269025 匹配到保洁员，等待保洁员确认接单', 41, 1, '2026-03-31 15:09:08', '2026-03-24 22:42:45');
INSERT INTO `notification` VALUES (142, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603242242269025，请在30分钟内确认接单', 41, 1, '2026-04-09 14:41:09', '2026-03-24 22:42:45');
INSERT INTO `notification` VALUES (143, 13, 6, '审核通过', '恭喜您！您的保洁员资质审核已通过，现在可以开始接单了', NULL, 1, '2026-03-26 14:46:28', '2026-03-25 15:42:21');
INSERT INTO `notification` VALUES (144, 21, 6, '审核通过', '恭喜您！您的保洁员资质审核已通过，现在可以开始接单了', NULL, 0, NULL, '2026-03-25 15:42:24');
INSERT INTO `notification` VALUES (145, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM_TEST_2603_004，请按时在家等候', 34, 1, '2026-03-31 15:09:08', '2026-03-25 16:04:36');
INSERT INTO `notification` VALUES (146, 6, 2, '派单成功', '已为您的订单 #CM202603242242269025 匹配到保洁员，等待保洁员确认接单', 41, 1, '2026-03-31 15:09:08', '2026-03-25 16:09:07');
INSERT INTO `notification` VALUES (147, 14, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603242242269025，请在30分钟内确认接单', 41, 1, '2026-03-27 16:44:33', '2026-03-25 16:09:07');
INSERT INTO `notification` VALUES (148, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_005 匹配到保洁员，等待保洁员确认接单', 35, 1, '2026-03-31 15:09:08', '2026-03-25 16:09:11');
INSERT INTO `notification` VALUES (149, 14, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_005，请在30分钟内确认接单', 35, 1, '2026-03-27 16:44:33', '2026-03-25 16:09:11');
INSERT INTO `notification` VALUES (150, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_001 匹配到保洁员，等待保洁员确认接单', 31, 1, '2026-03-31 15:09:08', '2026-03-25 16:09:15');
INSERT INTO `notification` VALUES (151, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_001，请在30分钟内确认接单', 31, 1, '2026-03-30 22:17:18', '2026-03-25 16:09:15');
INSERT INTO `notification` VALUES (152, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 1, '2026-03-31 19:35:58', '2026-03-25 17:20:55');
INSERT INTO `notification` VALUES (153, 6, 2, '派单成功', '已为您的订单 #CM202603242242269025 匹配到保洁员，等待保洁员确认接单', 41, 1, '2026-03-31 15:09:08', '2026-03-25 17:27:57');
INSERT INTO `notification` VALUES (154, 14, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603242242269025，请在30分钟内确认接单', 41, 1, '2026-03-27 16:44:33', '2026-03-25 17:27:57');
INSERT INTO `notification` VALUES (155, 12, 5, '您有新订单已确认', '管理员为您分配了新订单 #CM202603242242269025，请准时上门服务', 41, 1, '2026-04-10 13:00:25', '2026-03-25 17:28:02');
INSERT INTO `notification` VALUES (156, 6, 2, '保洁员已确认接单', '已为您的订单 #CM202603242242269025 安排好保洁员，请按时在家等候', 41, 1, '2026-03-31 15:09:08', '2026-03-25 17:28:02');
INSERT INTO `notification` VALUES (157, 14, 5, '您有新订单已确认', '管理员为您分配了新订单 #CM_TEST_NOCOORD，请准时上门服务', 28, 1, '2026-03-27 16:44:33', '2026-03-25 17:28:20');
INSERT INTO `notification` VALUES (158, 6, 2, '保洁员已确认接单', '已为您的订单 #CM_TEST_NOCOORD 安排好保洁员，请按时在家等候', 28, 1, '2026-03-31 15:09:08', '2026-03-25 17:28:20');
INSERT INTO `notification` VALUES (159, 7, 5, '您有新订单已确认', '管理员为您分配了新订单 #CM_TEST_2603_001，请准时上门服务', 31, 1, '2026-03-30 22:17:18', '2026-03-25 17:29:26');
INSERT INTO `notification` VALUES (160, 6, 2, '保洁员已确认接单', '已为您的订单 #CM_TEST_2603_001 安排好保洁员，请按时在家等候', 31, 1, '2026-03-31 15:09:08', '2026-03-25 17:29:26');
INSERT INTO `notification` VALUES (161, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_005 匹配到保洁员，等待保洁员确认接单', 35, 1, '2026-03-31 15:09:08', '2026-03-25 17:29:49');
INSERT INTO `notification` VALUES (162, 14, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_005，请在30分钟内确认接单', 35, 1, '2026-03-27 16:44:33', '2026-03-25 17:29:49');
INSERT INTO `notification` VALUES (163, 12, 5, '您有新订单已确认', '管理员为您分配了新订单 #CM_TEST_2603_005，请准时上门服务', 35, 1, '2026-04-10 13:00:25', '2026-03-25 17:31:56');
INSERT INTO `notification` VALUES (164, 6, 2, '保洁员已确认接单', '已为您的订单 #CM_TEST_2603_005 安排好保洁员，请按时在家等候', 35, 1, '2026-03-31 15:09:08', '2026-03-25 17:31:56');
INSERT INTO `notification` VALUES (165, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 1, '2026-03-31 19:35:58', '2026-03-25 17:35:32');
INSERT INTO `notification` VALUES (166, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM_TEST_2603_005，请按时在家等候', 35, 1, '2026-03-31 15:09:08', '2026-03-25 18:04:09');
INSERT INTO `notification` VALUES (167, 7, 5, '您有新订单待确认', '管理员为您分配了新订单 #CM202603242242269025，请在30分钟内确认接单', 41, 1, '2026-03-30 22:17:18', '2026-03-25 18:05:04');
INSERT INTO `notification` VALUES (168, 6, 2, '订单已派单', '您的订单 #CM202603242242269025 已为您匹配保洁员，等待保洁员确认接单', 41, 1, '2026-03-31 15:09:08', '2026-03-25 18:05:04');
INSERT INTO `notification` VALUES (169, 14, 5, '您有新订单待确认', '管理员为您分配了新订单 #CM202603242242269025，请在30分钟内确认接单', 41, 1, '2026-03-27 16:44:33', '2026-03-25 18:05:25');
INSERT INTO `notification` VALUES (170, 6, 2, '订单已派单', '您的订单 #CM202603242242269025 已为您匹配保洁员，等待保洁员确认接单', 41, 1, '2026-03-31 15:09:08', '2026-03-25 18:05:25');
INSERT INTO `notification` VALUES (171, 6, 2, '派单成功', '已为您的订单 #CM_TEST_2603_004 匹配到保洁员，等待保洁员确认接单', 34, 1, '2026-03-31 15:09:08', '2026-03-25 18:05:28');
INSERT INTO `notification` VALUES (172, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM_TEST_2603_004，请在30分钟内确认接单', 34, 1, '2026-03-26 14:46:28', '2026-03-25 18:05:28');
INSERT INTO `notification` VALUES (173, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 1, '2026-03-31 19:35:58', '2026-03-26 14:46:59');
INSERT INTO `notification` VALUES (174, 8, 7, '保洁员未到场告警', '订单 #CM_TEST_2603_004 顾客报告保洁员未到场，请及时处理', 34, 1, '2026-03-31 19:35:58', '2026-03-26 14:48:01');
INSERT INTO `notification` VALUES (175, 13, 9, '出行提醒', '您有一个订单将于 2026-03-26 16:30 开始，请提前出发！地址：重庆市重庆市九龙坡区杨家坪直港大道21号 | 测试用户 13800000001', 35, 1, '2026-03-26 20:51:26', '2026-03-26 15:23:58');
INSERT INTO `notification` VALUES (176, 8, 8, '派单失败，需手动处理', '订单 JD_202603261556528841 暂无合适保洁员，请手动派单', 42, 1, '2026-03-31 19:35:58', '2026-03-26 15:56:53');
INSERT INTO `notification` VALUES (177, 8, 8, '派单失败，需手动处理', '订单 JD_202603261556528841 暂无合适保洁员，请手动派单', 42, 1, '2026-03-31 19:35:58', '2026-03-26 15:57:07');
INSERT INTO `notification` VALUES (178, 8, 8, '派单失败，需手动处理', '订单 JD_202603261556523373 暂无合适保洁员，请手动派单', 44, 1, '2026-03-31 19:35:58', '2026-03-26 15:57:13');
INSERT INTO `notification` VALUES (179, 8, 8, '派单失败，需手动处理', '订单 JD_202603261556528602 暂无合适保洁员，请手动派单', 45, 1, '2026-03-31 19:35:58', '2026-03-26 15:57:18');
INSERT INTO `notification` VALUES (180, 8, 8, '派单失败，需手动处理', '订单 JD_202603261556528602 暂无合适保洁员，请手动派单', 45, 1, '2026-03-31 19:35:58', '2026-03-26 18:10:38');
INSERT INTO `notification` VALUES (181, 22, 2, '派单成功', '已为您的订单 #JD_202603261814568002 匹配到保洁员，等待保洁员确认接单', 46, 0, NULL, '2026-03-26 18:15:27');
INSERT INTO `notification` VALUES (182, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603261814568002，请在30分钟内确认接单', 46, 1, '2026-04-09 14:41:09', '2026-03-26 18:15:27');
INSERT INTO `notification` VALUES (183, 22, 2, '派单成功', '已为您的订单 #JD_202603261814568002 匹配到保洁员，等待保洁员确认接单', 46, 0, NULL, '2026-03-26 19:50:06');
INSERT INTO `notification` VALUES (184, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603261814568002，请在30分钟内确认接单', 46, 1, '2026-03-26 20:51:26', '2026-03-26 19:50:06');
INSERT INTO `notification` VALUES (185, 19, 2, '派单成功', '已为您的订单 #JD_202603261814562102 匹配到保洁员，等待保洁员确认接单', 48, 0, NULL, '2026-03-26 19:50:57');
INSERT INTO `notification` VALUES (186, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603261814562102，请在30分钟内确认接单', 48, 1, '2026-03-30 22:17:18', '2026-03-26 19:50:57');
INSERT INTO `notification` VALUES (187, 27, 2, '派单成功', '已为您的订单 #JD_202603262011477106 匹配到保洁员，等待保洁员确认接单', 53, 0, NULL, '2026-03-26 20:11:57');
INSERT INTO `notification` VALUES (188, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603262011477106，请在30分钟内确认接单', 53, 1, '2026-03-26 20:51:26', '2026-03-26 20:11:57');
INSERT INTO `notification` VALUES (189, 8, 8, '派单失败，需手动处理', '订单 JD_202603262011478253 暂无合适保洁员，请手动派单', 52, 1, '2026-03-31 19:35:58', '2026-03-26 20:12:01');
INSERT INTO `notification` VALUES (190, 25, 2, '派单成功', '已为您的订单 #JD_202603262011468468 匹配到保洁员，等待保洁员确认接单', 51, 0, NULL, '2026-03-26 20:12:07');
INSERT INTO `notification` VALUES (191, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603262011468468，请在30分钟内确认接单', 51, 1, '2026-03-26 20:51:26', '2026-03-26 20:12:07');
INSERT INTO `notification` VALUES (192, 24, 2, '派单成功', '已为您的订单 #JD_202603262011461543 匹配到保洁员，等待保洁员确认接单', 50, 0, NULL, '2026-03-26 20:12:11');
INSERT INTO `notification` VALUES (193, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603262011461543，请在30分钟内确认接单', 50, 1, '2026-03-26 20:51:26', '2026-03-26 20:12:11');
INSERT INTO `notification` VALUES (194, 20, 2, '保洁员已接单', '保洁员已接受您的订单 #JD_202603261814562633，请按时在家等候', 49, 0, NULL, '2026-03-26 20:36:18');
INSERT INTO `notification` VALUES (195, 22, 2, '保洁员已接单', '保洁员已接受您的订单 #JD_202603261814568002，请按时在家等候', 46, 0, NULL, '2026-03-26 20:51:16');
INSERT INTO `notification` VALUES (196, 8, 8, '派单失败，需手动处理', '订单 JD_202603262011478253 暂无合适保洁员，请手动派单', 52, 1, '2026-03-31 19:35:58', '2026-03-26 20:51:36');
INSERT INTO `notification` VALUES (197, 10, 5, '您有新订单待确认', '管理员为您分配了新订单 #JD_202603262011477106，请在30分钟内确认接单', 53, 1, '2026-04-09 14:41:09', '2026-03-26 20:51:52');
INSERT INTO `notification` VALUES (198, 27, 2, '订单已派单', '您的订单 #JD_202603262011477106 已为您匹配保洁员，等待保洁员确认接单', 53, 0, NULL, '2026-03-26 20:51:52');
INSERT INTO `notification` VALUES (199, 8, 8, '派单失败，需手动处理', '订单 CM202603241521044166 暂无合适保洁员，请手动派单', 26, 1, '2026-03-31 19:35:58', '2026-03-26 20:53:30');
INSERT INTO `notification` VALUES (200, 7, 10, '顾客申请改期', '顾客申请将订单 #ROUTE_TEST_20260329 从 2026-03-29 16:30 改为 2026-03-31 10:00，请确认', 54, 1, '2026-03-30 22:17:18', '2026-03-27 15:40:57');
INSERT INTO `notification` VALUES (201, 6, 11, '改期申请已通过', '您的订单 #ROUTE_TEST_20260329 改期申请已通过，新预约时间为 2026-03-31 10:00', 54, 1, '2026-03-31 15:09:08', '2026-03-27 15:41:14');
INSERT INTO `notification` VALUES (202, 6, 1, '订单已提交', '您的日常保洁订单 #CM202603271605444945 已提交，正在为您匹配保洁员', 55, 1, '2026-03-31 15:09:08', '2026-03-27 16:05:44');
INSERT INTO `notification` VALUES (203, 6, 2, '派单成功', '已为您的订单 #CM202603271605444945 匹配到保洁员，等待保洁员确认接单', 55, 1, '2026-03-31 15:09:08', '2026-03-27 16:07:36');
INSERT INTO `notification` VALUES (204, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603271605444945，请在30分钟内确认接单', 55, 0, NULL, '2026-03-27 16:07:36');
INSERT INTO `notification` VALUES (205, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202603271605444945 即将开始服务', 55, 1, '2026-03-31 15:09:08', '2026-03-27 16:07:53');
INSERT INTO `notification` VALUES (206, 6, 4, '服务已���成', '您的订单 #CM202603271605444945 保洁员已完工，请在48小时内确认并评价', 55, 1, '2026-03-31 15:09:08', '2026-03-27 16:07:56');
INSERT INTO `notification` VALUES (207, 13, 4, '顾客已确认完成', '顾客已确认订单 #CM202603271605444945 完成，收入已计入本月结算', 55, 0, NULL, '2026-03-27 16:08:10');
INSERT INTO `notification` VALUES (208, 8, 7, '新投诉待处理', '订单 #CM202603271605444945 收到新投诉，请及时处理', 55, 1, '2026-03-31 19:35:58', '2026-03-27 16:09:04');
INSERT INTO `notification` VALUES (209, 6, 1, '订单已提交', '您的日常保洁订单 #CM202603271631395214 已提交，正在为您匹配保洁员', 56, 1, '2026-03-31 15:09:08', '2026-03-27 16:31:39');
INSERT INTO `notification` VALUES (210, 6, 2, '派单成功', '已为您的订单 #CM202603271631395214 匹配到保洁员，等待保洁员确认接单', 56, 1, '2026-03-31 15:09:08', '2026-03-27 16:32:03');
INSERT INTO `notification` VALUES (211, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603271631395214，请在30分钟内确认接单', 56, 1, '2026-03-30 22:17:18', '2026-03-27 16:32:03');
INSERT INTO `notification` VALUES (212, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202603271631395214 即将开始服务', 56, 1, '2026-03-31 15:09:08', '2026-03-27 16:32:16');
INSERT INTO `notification` VALUES (213, 6, 4, '服务已���成', '您的订单 #CM202603271631395214 保洁员已完工，请在48小时内确认并评价', 56, 1, '2026-03-31 15:09:08', '2026-03-27 16:32:20');
INSERT INTO `notification` VALUES (214, 7, 4, '顾客已确认完成', '顾客已确认订单 #CM202603271631395214 完成，收入已计入本月结算', 56, 1, '2026-03-30 22:17:18', '2026-03-27 16:33:08');
INSERT INTO `notification` VALUES (215, 6, 1, '订单已提交', '您的家电清洗订单 #CM202603271642308514 已提交，正在为您匹配保洁员', 57, 1, '2026-03-31 15:09:08', '2026-03-27 16:42:30');
INSERT INTO `notification` VALUES (216, 6, 2, '派单成功', '已为您的订单 #CM202603271642308514 匹配到保洁员，等待保洁员确认接单', 57, 1, '2026-03-31 15:09:08', '2026-03-27 16:44:03');
INSERT INTO `notification` VALUES (217, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603271642308514，请在30分钟内确认接单', 57, 1, '2026-03-31 18:59:50', '2026-03-27 16:44:03');
INSERT INTO `notification` VALUES (218, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202603271642308514 即将开始服务', 57, 1, '2026-03-31 15:09:08', '2026-03-27 16:46:04');
INSERT INTO `notification` VALUES (219, 6, 4, '服务已���成', '您的订单 #CM202603271642308514 保洁员已完工，请在48小时内确认并评价', 57, 1, '2026-03-31 15:09:08', '2026-03-27 16:46:06');
INSERT INTO `notification` VALUES (220, 11, 4, '顾客已确认完成', '顾客已确认订单 #CM202603271642308514 完成，收入已计入本月结算', 57, 1, '2026-03-31 18:59:50', '2026-03-27 16:46:25');
INSERT INTO `notification` VALUES (221, 27, 2, '派单成功', '已为您的订单 #JD_202603262011477106 匹配到保洁员，等待保洁员确认接单', 53, 0, NULL, '2026-03-27 16:52:22');
INSERT INTO `notification` VALUES (222, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603262011477106，请在30分钟内确认接单', 53, 0, NULL, '2026-03-27 16:52:22');
INSERT INTO `notification` VALUES (223, 13, 5, '您有新订单待确认', '管理员为您分配了新订单 #JD_202603262011477106，请在30分钟内确认接单', 53, 0, NULL, '2026-03-28 12:50:01');
INSERT INTO `notification` VALUES (224, 27, 2, '订单已派单', '您的订单 #JD_202603262011477106 已为您匹配保洁员，等待保洁员确认接单', 53, 0, NULL, '2026-03-28 12:50:01');
INSERT INTO `notification` VALUES (225, 6, 1, '订单已提交', '您的油烟机清洗订单 #CM202603281417290656 已提交，正在为您匹配保洁员', 58, 1, '2026-03-31 15:09:08', '2026-03-28 14:17:30');
INSERT INTO `notification` VALUES (226, 6, 1, '订单已提交', '您的地板打蜡订单 #CM202603281418149779 已提交，正在为您匹配保洁员', 59, 1, '2026-03-31 15:09:08', '2026-03-28 14:18:14');
INSERT INTO `notification` VALUES (227, 6, 2, '派单成功', '已为您的订单 #CM202603281418149779 匹配到保洁员，等待保洁员确认接单', 59, 1, '2026-03-31 15:09:08', '2026-03-28 14:18:40');
INSERT INTO `notification` VALUES (228, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603281418149779，请在30分钟内确认接单', 59, 0, NULL, '2026-03-28 14:18:40');
INSERT INTO `notification` VALUES (229, 14, 5, '您有新订单待确认', '管理员为您分配了新订单 #CM202603281418149779，请在30分钟内确认接单', 59, 1, '2026-03-31 19:10:17', '2026-03-28 14:19:01');
INSERT INTO `notification` VALUES (230, 6, 2, '订单已派单', '您的订单 #CM202603281418149779 已为您匹配保洁员，等待保洁员确认接单', 59, 1, '2026-03-31 15:09:08', '2026-03-28 14:19:01');
INSERT INTO `notification` VALUES (231, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202603281418149779 即将开始服务', 59, 1, '2026-03-31 15:09:08', '2026-03-28 14:19:50');
INSERT INTO `notification` VALUES (232, 6, 4, '服务已���成', '您的订单 #CM202603281418149779 保洁员已完工，请在48小时内确认并评价', 59, 1, '2026-03-31 15:09:08', '2026-03-28 14:19:53');
INSERT INTO `notification` VALUES (233, 14, 4, '顾客已确认完成', '顾客已确认订单 #CM202603281418149779 完成，收入已计入本月结算', 59, 1, '2026-03-31 19:10:17', '2026-03-28 14:20:07');
INSERT INTO `notification` VALUES (234, 31, 2, '派单成功', '已为您的订单 #JD_202603301438101070 匹配到保洁员，等待保洁员确认接单', 63, 0, NULL, '2026-03-30 14:38:15');
INSERT INTO `notification` VALUES (235, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603301438101070，请在30分钟内确认接单', 63, 1, '2026-04-09 14:41:09', '2026-03-30 14:38:15');
INSERT INTO `notification` VALUES (236, 30, 2, '派单成功', '已为您的订单 #JD_202603301438102820 匹配到保洁员，等待保洁员确认接单', 62, 0, NULL, '2026-03-30 18:58:02');
INSERT INTO `notification` VALUES (237, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603301438102820，请在30分钟内确认接单', 62, 0, NULL, '2026-03-30 18:58:02');
INSERT INTO `notification` VALUES (238, 28, 2, '派单成功', '已为您的订单 #JD_202603301438101831 匹配到保洁员，等待保洁员确认接单', 60, 0, NULL, '2026-03-30 18:58:07');
INSERT INTO `notification` VALUES (239, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603301438101831，请在30分钟内确认接单', 60, 0, NULL, '2026-03-30 18:58:07');
INSERT INTO `notification` VALUES (240, 11, 5, '您有新订单待确认', '管理员为您分配了新订单 #JD_202603301438102820，请在30分钟内确认接单', 62, 1, '2026-03-31 18:59:50', '2026-03-30 18:58:16');
INSERT INTO `notification` VALUES (241, 30, 2, '订单已派单', '您的订单 #JD_202603301438102820 已为您匹配保洁员，等待保洁员确认接单', 62, 0, NULL, '2026-03-30 18:58:16');
INSERT INTO `notification` VALUES (242, 31, 2, '派单成功', '已为您的订单 #JD_202603301438101070 匹配到保洁员，等待保洁员确认接单', 63, 0, NULL, '2026-03-30 18:58:18');
INSERT INTO `notification` VALUES (243, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603301438101070，请在30分钟内确认接单', 63, 0, NULL, '2026-03-30 18:58:18');
INSERT INTO `notification` VALUES (244, 23, 2, '保洁员已接单', '保洁员已接受您的订单 #JD_202603261814567439，请按时在家等候', 47, 0, NULL, '2026-03-30 19:17:47');
INSERT INTO `notification` VALUES (245, 30, 2, '派单成功', '已为您的订单 #JD_202603301438102820 匹配到保洁员，等待保洁员确认接单', 62, 0, NULL, '2026-03-30 22:36:41');
INSERT INTO `notification` VALUES (246, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603301438102820，请在30分钟内确认接单', 62, 0, NULL, '2026-03-30 22:36:41');
INSERT INTO `notification` VALUES (247, 28, 2, '派单成功', '已为您的订单 #JD_202603301438101831 匹配到保洁员，等待保洁员确认接单', 60, 0, NULL, '2026-03-30 22:36:50');
INSERT INTO `notification` VALUES (248, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603301438101831，请在30分钟内确认接单', 60, 0, NULL, '2026-03-30 22:36:50');
INSERT INTO `notification` VALUES (249, 12, 5, '您有新订单待确认', '管理员为您分配了新订单 #JD_202603301438101831，请在30分钟内确认接单', 60, 1, '2026-04-10 13:00:25', '2026-03-30 22:36:58');
INSERT INTO `notification` VALUES (250, 28, 2, '订单已派单', '您的订单 #JD_202603301438101831 已为您匹配保洁员，等待保洁员确认接单', 60, 0, NULL, '2026-03-30 22:36:58');
INSERT INTO `notification` VALUES (251, 7, 5, '您有新订单待确认', '管理员为您分配了新订单 #JD_202603301438102820，请在30分钟内确认接单', 62, 1, '2026-03-31 12:42:46', '2026-03-30 22:37:04');
INSERT INTO `notification` VALUES (252, 30, 2, '订单已派单', '您的订单 #JD_202603301438102820 已为您匹配保洁员，等待保洁员确认接单', 62, 0, NULL, '2026-03-30 22:37:04');
INSERT INTO `notification` VALUES (253, 14, 5, '您有新订单待确认', '管理员为您分配了新订单 #JD_202603301438101831，请在30分钟内确认接单', 60, 1, '2026-03-31 19:10:17', '2026-03-30 22:37:10');
INSERT INTO `notification` VALUES (254, 28, 2, '订单已派单', '您的订单 #JD_202603301438101831 已为您匹配保洁员，等待保洁员确认接单', 60, 0, NULL, '2026-03-30 22:37:10');
INSERT INTO `notification` VALUES (255, 29, 2, '派单成功', '已为您的订单 #JD_202603301438102875 匹配到保洁员，等待保洁员确认接单', 61, 0, NULL, '2026-03-30 22:38:19');
INSERT INTO `notification` VALUES (256, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603301438102875，请在30分钟内确认接单', 61, 0, NULL, '2026-03-30 22:38:19');
INSERT INTO `notification` VALUES (257, 31, 2, '派单成功', '已为您的订单 #JD_202603301438101070 匹配到保洁员，等待保洁员确认接单', 63, 0, NULL, '2026-03-30 22:38:28');
INSERT INTO `notification` VALUES (258, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603301438101070，请在30分钟内确认接单', 63, 0, NULL, '2026-03-30 22:38:28');
INSERT INTO `notification` VALUES (259, 6, 1, '订单已提交', '您的家电清洗订单 #CM202603311241373903 已提交，正在为您匹配保洁员', 64, 1, '2026-03-31 15:09:08', '2026-03-31 12:41:38');
INSERT INTO `notification` VALUES (260, 6, 2, '派单成功', '已为您的订单 #CM202603311241373903 匹配到保洁员，等待保洁员确认接单', 64, 1, '2026-03-31 15:09:08', '2026-03-31 12:42:19');
INSERT INTO `notification` VALUES (261, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603311241373903，请在30分钟内确认接单', 64, 1, '2026-03-31 12:42:46', '2026-03-31 12:42:19');
INSERT INTO `notification` VALUES (262, 32, 2, '派单成功', '已为您的订单 #JD_202603311452098424 匹配到保洁员，等待保洁员确认接单', 65, 0, NULL, '2026-03-31 14:52:10');
INSERT INTO `notification` VALUES (263, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603311452098424，请在30分钟内确认接单', 65, 1, '2026-03-31 15:28:58', '2026-03-31 14:52:10');
INSERT INTO `notification` VALUES (264, 6, 1, '订单已提交', '您的日常保洁订单 #CM202603311536599829 已提交，正在为您匹配保洁员', 69, 1, '2026-03-31 20:07:47', '2026-03-31 15:37:00');
INSERT INTO `notification` VALUES (265, 6, 2, '派单成功', '已为您的订单 #CM202603311536599829 匹配到保洁员，等待保洁员确认接单', 69, 1, '2026-03-31 20:07:47', '2026-03-31 15:37:20');
INSERT INTO `notification` VALUES (266, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603311536599829，请在30分钟内确认接单', 69, 0, NULL, '2026-03-31 15:37:20');
INSERT INTO `notification` VALUES (267, 13, 9, '出行提醒', '您有一个订单将于 2026-03-31 16:36 开始，请提前出发！地址：重庆市重庆市南岸区南坪万达广场B座 | 测试用户 13800000001', 69, 0, NULL, '2026-03-31 15:39:20');
INSERT INTO `notification` VALUES (268, 6, 1, '订单已提交', '您的油烟机清洗订单 #CM202603311539560663 已提交，正在为您匹配保洁员', 70, 1, '2026-03-31 20:07:47', '2026-03-31 15:39:57');
INSERT INTO `notification` VALUES (269, 8, 8, '派单失败，需手动处理', '订单 CM202603311539560663 暂无合适保洁员，请手动派单', 70, 1, '2026-03-31 19:35:58', '2026-03-31 15:40:13');
INSERT INTO `notification` VALUES (270, 8, 8, '派单失败，需手动处理', '订单 CM202603311539560663 暂无合适保洁员，请手动派单', 70, 1, '2026-03-31 19:35:58', '2026-03-31 15:40:14');
INSERT INTO `notification` VALUES (271, 6, 2, '派单成功', '已为您的订单 #CM202603311539560663 匹配到保洁员，等待保洁员确认接单', 70, 1, '2026-03-31 20:07:47', '2026-03-31 15:50:50');
INSERT INTO `notification` VALUES (272, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603311539560663，请在30分钟内确认接单', 70, 1, '2026-04-10 13:00:25', '2026-03-31 15:50:50');
INSERT INTO `notification` VALUES (273, 12, 10, '顾客申请改期', '顾客申请将订单 #CM202603311539560663 从 2026-03-31 18:39 改为 2026-03-31 17:00，请确认', 70, 1, '2026-04-10 13:00:25', '2026-03-31 15:51:33');
INSERT INTO `notification` VALUES (274, 6, 11, '改期申请已通过', '您的订单 #CM202603311539560663 改期申请已通过，新预约时间为 2026-03-31 17:00', 70, 1, '2026-03-31 20:07:47', '2026-03-31 15:51:53');
INSERT INTO `notification` VALUES (275, 7, 9, '出行提醒', '您有一个订单将于 2026-03-31 17:00 开始，请提前出发！地址：重庆市市辖区江北区观音桥 | 测试顾客 13800000001', 64, 1, '2026-03-31 17:16:56', '2026-03-31 15:59:20');
INSERT INTO `notification` VALUES (276, 12, 9, '出行提醒', '您有一个订单将于 2026-03-31 17:00 开始，请提前出发！地址：重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 70, 1, '2026-04-10 13:00:25', '2026-03-31 15:59:20');
INSERT INTO `notification` VALUES (277, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202603311539560663 即将开始服务', 70, 1, '2026-03-31 20:07:47', '2026-03-31 16:15:02');
INSERT INTO `notification` VALUES (278, 6, 4, '服务已���成', '您的订单 #CM202603311539560663 保洁员已完工，请在48小时内确认并评价', 70, 1, '2026-03-31 20:07:47', '2026-03-31 16:15:05');
INSERT INTO `notification` VALUES (279, 8, 7, '保洁员未到场告警', '订单 #CM202603311536599829 顾客报告保洁员未到场，请及时处理', 69, 1, '2026-03-31 19:35:58', '2026-03-31 17:23:12');
INSERT INTO `notification` VALUES (280, 6, 1, '订单已提交', '您的地板打蜡订单 #CM202603311723446114 已提交，正在为您匹配保洁员', 71, 1, '2026-03-31 20:07:47', '2026-03-31 17:23:45');
INSERT INTO `notification` VALUES (281, 6, 2, '派单成功', '已为您的订单 #CM202603311723446114 匹配到保洁员，等待保洁员确认接单', 71, 1, '2026-03-31 20:07:47', '2026-03-31 17:24:21');
INSERT INTO `notification` VALUES (282, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603311723446114，请在30分钟内确认接单', 71, 1, '2026-03-31 18:59:50', '2026-03-31 17:24:21');
INSERT INTO `notification` VALUES (283, 34, 2, '保洁员已接单', '保洁员已接受您的订单 #JD_202603311452109792，请按时在家等候', 67, 0, NULL, '2026-03-31 17:26:40');
INSERT INTO `notification` VALUES (284, 12, 4, '顾客已确认完成', '顾客已确认订单 #CM202603311539560663 完成，收入已计入本月结算', 70, 1, '2026-04-10 13:00:25', '2026-03-31 18:10:59');
INSERT INTO `notification` VALUES (285, 8, 7, '保洁员未到场告警', '订单 #CM202603311723446114 顾客报告保洁员未到场，请及时处理', 71, 1, '2026-03-31 19:35:58', '2026-03-31 18:11:11');
INSERT INTO `notification` VALUES (286, 8, 7, '保洁员未到场告警', '订单 #CM202603311241373903 顾客报告保洁员未到场，请及时处理', 64, 1, '2026-03-31 19:35:58', '2026-03-31 18:11:36');
INSERT INTO `notification` VALUES (287, 6, 1, '订单已提交', '您的玻璃清洗订单 #CM202603311858327903 已提交，正在为您匹配保洁员', 72, 1, '2026-03-31 20:07:47', '2026-03-31 18:58:32');
INSERT INTO `notification` VALUES (288, 8, 8, '派单失败，需手动处理', '订单 CM202603311858327903 暂无合适保洁员，请手动派单', 72, 1, '2026-03-31 19:35:58', '2026-03-31 18:58:43');
INSERT INTO `notification` VALUES (289, 6, 2, '派单成功', '已为您的订单 #CM202603311858327903 匹配到保洁员，等待保洁员确认接单', 72, 1, '2026-03-31 20:07:47', '2026-03-31 19:01:12');
INSERT INTO `notification` VALUES (290, 14, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202603311858327903，请在30分钟内确认接单', 72, 1, '2026-03-31 19:10:17', '2026-03-31 19:01:12');
INSERT INTO `notification` VALUES (291, 34, 2, '保洁员已接单', '保洁员已接受您的订单 #JD_202603311452109792，请按时在家等候', 67, 0, NULL, '2026-03-31 19:09:59');
INSERT INTO `notification` VALUES (292, 8, 8, '保洁员未到场告警', '订单 #TEST001 已自动取消，原因：保洁员超时未签到。请尽快核查。', 1, 1, '2026-03-31 19:35:58', '2026-03-31 19:25:13');
INSERT INTO `notification` VALUES (293, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202603311858327903 即将开始服务', 72, 1, '2026-03-31 20:07:47', '2026-03-31 19:55:04');
INSERT INTO `notification` VALUES (294, 6, 4, '服务已���成', '您的订单 #CM202603311858327903 保洁员已完工，请在48小时内确认并评价', 72, 1, '2026-03-31 20:07:47', '2026-03-31 19:55:32');
INSERT INTO `notification` VALUES (295, 33, 2, '派单成功', '已为您的订单 #JD_202603311452095990 匹配到保洁员，等待保洁员确认接单', 66, 0, NULL, '2026-03-31 19:55:44');
INSERT INTO `notification` VALUES (296, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603311452095990，请在30分钟内确认接单', 66, 1, '2026-04-09 14:41:09', '2026-03-31 19:55:44');
INSERT INTO `notification` VALUES (297, 35, 2, '派单成功', '已为您的订单 #JD_202603311452102347 匹配到保洁员，等待保洁员确认接单', 68, 0, NULL, '2026-03-31 19:56:08');
INSERT INTO `notification` VALUES (298, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603311452102347，请在30分钟内确认接单', 68, 1, '2026-04-10 13:00:25', '2026-03-31 19:56:08');
INSERT INTO `notification` VALUES (299, 33, 2, '派单成功', '已为您的订单 #JD_202603311452095990 匹配到保洁员，等待保洁员确认接单', 66, 0, NULL, '2026-03-31 20:06:25');
INSERT INTO `notification` VALUES (300, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603311452095990，请在30分钟内确认接单', 66, 1, '2026-04-09 14:41:09', '2026-03-31 20:06:25');
INSERT INTO `notification` VALUES (301, 35, 2, '派单成功', '已为您的订单 #JD_202603311452102347 匹配到保洁员，等待保洁员确认接单', 68, 0, NULL, '2026-03-31 20:06:28');
INSERT INTO `notification` VALUES (302, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202603311452102347，请在30分钟内确认接单', 68, 1, '2026-04-10 13:00:25', '2026-03-31 20:06:28');
INSERT INTO `notification` VALUES (303, 14, 4, '顾客已确认完成', '顾客已确认订单 #CM202603311858327903 完成，收入已计入本月结算', 72, 1, '2026-04-10 12:41:31', '2026-03-31 20:07:41');
INSERT INTO `notification` VALUES (304, 8, 8, '保洁员未到场告警', '订单 #JD_202603301438102875 已自动取消，原因：保洁员超时未签到。请尽快核查。', 61, 0, NULL, '2026-04-01 13:41:31');
INSERT INTO `notification` VALUES (305, 8, 8, '保洁员未到场告警', '订单 #JD_202603311452098424 已自动取消，原因：保洁员超时未签到。请尽快核查。', 65, 0, NULL, '2026-04-01 18:01:57');
INSERT INTO `notification` VALUES (306, 8, 7, '新投诉待处理', '订单 #CM202603311858327903 收到新投诉，请及时处理', 72, 0, NULL, '2026-04-01 22:17:06');
INSERT INTO `notification` VALUES (307, 6, 7, '投诉已结案 - 部分退款', '您的订单 #CM202603311858327903 投诉已结案，平台为您部分退款 ¥11', 72, 1, '2026-04-01 22:18:52', '2026-04-01 22:18:41');
INSERT INTO `notification` VALUES (308, 14, 7, '投诉结案通知', '订单 #CM202603311858327903 投诉结案（部分退款），收入已按比例调整', 72, 1, '2026-04-10 12:41:31', '2026-04-01 22:18:41');
INSERT INTO `notification` VALUES (309, 8, 7, '新投诉待处理', '订单 #CM202603311539560663 收到新投诉，请及时处理', 70, 0, NULL, '2026-04-01 22:38:49');
INSERT INTO `notification` VALUES (310, 6, 7, '投诉已结案 - 部分退款', '您的订单 #CM202603311539560663 投诉已结案，平台为您部分退款 ¥23', 70, 1, '2026-04-10 22:50:31', '2026-04-01 22:39:22');
INSERT INTO `notification` VALUES (311, 12, 7, '投诉结案通知', '订单 #CM202603311539560663 投诉结案（部分退款），收入已按比例调整', 70, 1, '2026-04-10 13:00:25', '2026-04-01 22:39:22');
INSERT INTO `notification` VALUES (312, 8, 8, '保洁员未到场告警', '订单 #JD_202603301438102820 已自动取消，原因：保洁员超时未签到。请尽快核查。', 62, 0, NULL, '2026-04-02 13:18:59');
INSERT INTO `notification` VALUES (313, 8, 8, '保洁员未到场告警', '订单 #JD_202603311452095990 已自动取消，原因：保洁员超时未签到。请尽快核查。', 66, 0, NULL, '2026-04-02 16:03:59');
INSERT INTO `notification` VALUES (314, 8, 8, '保洁员未到场告警', '订单 #JD_202603311452109792 已自动取消，原因：保洁员超时未签到。请尽快核查。', 67, 0, NULL, '2026-04-03 15:32:06');
INSERT INTO `notification` VALUES (315, 8, 8, '保洁员未到场告警', '订单 #JD_202603301438101070 已自动取消，原因：保洁员超时未签到。请尽快核查。', 63, 0, NULL, '2026-04-04 19:26:56');
INSERT INTO `notification` VALUES (316, 8, 8, '保洁员未到场告警', '订单 #JD_202603311452102347 已自动取消，原因：保洁员超时未签到。请尽快核查。', 68, 0, NULL, '2026-04-04 19:26:56');
INSERT INTO `notification` VALUES (317, 6, 1, '订单已提交', '您的家电清洗订单 #CM202604071400281075 已提交，正在为您匹配保洁员', 73, 1, '2026-04-10 22:50:31', '2026-04-07 14:00:29');
INSERT INTO `notification` VALUES (318, 6, 2, '派单成功', '已为您的订单 #CM202604071400281075 匹配到保洁员，等待保洁员确认接单', 73, 1, '2026-04-10 22:50:31', '2026-04-07 14:00:47');
INSERT INTO `notification` VALUES (319, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604071400281075，请在30分钟内确认接单', 73, 1, '2026-04-09 14:40:42', '2026-04-07 14:00:47');
INSERT INTO `notification` VALUES (320, 39, 2, '派单成功', '已为您的订单 #JD_202604071401237501 匹配到保洁员，等待保洁员确认接单', 77, 0, NULL, '2026-04-07 14:01:27');
INSERT INTO `notification` VALUES (321, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604071401237501，请在30分钟内确认接单', 77, 1, '2026-04-09 14:40:42', '2026-04-07 14:01:27');
INSERT INTO `notification` VALUES (322, 36, 2, '派单成功', '已为您的订单 #JD_202604071401221724 匹配到保洁员，等待保洁员确认接单', 74, 0, NULL, '2026-04-07 14:01:31');
INSERT INTO `notification` VALUES (323, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604071401221724，请在30分钟内确认接单', 74, 1, '2026-04-09 14:40:42', '2026-04-07 14:01:31');
INSERT INTO `notification` VALUES (324, 37, 2, '派单成功', '已为您的订单 #JD_202604071401225420 匹配到保洁员，等待保洁员确认接单', 75, 0, NULL, '2026-04-07 14:01:35');
INSERT INTO `notification` VALUES (325, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604071401225420，请在30分钟内确认接单', 75, 0, NULL, '2026-04-07 14:01:35');
INSERT INTO `notification` VALUES (326, 38, 2, '派单成功', '已为您的订单 #JD_202604071401234228 匹配到保洁员，等待保洁员确认接单', 76, 0, NULL, '2026-04-07 14:01:38');
INSERT INTO `notification` VALUES (327, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604071401234228，请在30分钟内确认接单', 76, 1, '2026-04-09 14:40:42', '2026-04-07 14:01:38');
INSERT INTO `notification` VALUES (328, 43, 2, '派单成功', '已为您的订单 #JD_202604071405319062 匹配到保洁员，等待保洁员确认接单', 81, 0, NULL, '2026-04-07 14:05:36');
INSERT INTO `notification` VALUES (329, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604071405319062，请在30分钟内确认接单', 81, 1, '2026-04-09 13:42:43', '2026-04-07 14:05:36');
INSERT INTO `notification` VALUES (330, 11, 9, '出行提醒', '您有一个订单将于 2026-04-07 15:00 开始，请提前出发！地址：重庆市重庆市江北区观音桥北城天街5号 | 测试用户 13800000001', 73, 1, '2026-04-09 14:40:42', '2026-04-07 14:06:08');
INSERT INTO `notification` VALUES (331, 7, 5, '您有新订单待确认', '管理员为您分配了新订单 #JD_202604071405318024，请在30分钟内确认接单', 78, 1, '2026-04-09 13:42:43', '2026-04-07 14:06:49');
INSERT INTO `notification` VALUES (332, 40, 2, '订单已派单', '您的订单 #JD_202604071405318024 已为您匹配保洁员，等待保洁员确认接单', 78, 0, NULL, '2026-04-07 14:06:49');
INSERT INTO `notification` VALUES (345, 42, 2, '派单成功', '已为您的订单 #JD_202604071405311315 匹配到保洁员，等待保洁员确认接单', 80, 0, NULL, '2026-04-07 14:13:36');
INSERT INTO `notification` VALUES (346, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604071405311315，请在30分钟内确认接单', 80, 0, NULL, '2026-04-07 14:13:36');
INSERT INTO `notification` VALUES (347, 8, 8, '保洁员未到场告警', '订单 #CM202604071400281075 已自动取消，原因：保洁员超时未签到。请尽快核查。', 73, 1, '2026-04-08 02:50:55', '2026-04-07 17:13:12');
INSERT INTO `notification` VALUES (348, 6, 1, '订单已提交', '您的油烟机清洗订单 #CM202604072336195877 已提交，正在为您匹配保洁员', 82, 1, '2026-04-10 22:50:31', '2026-04-07 23:36:20');
INSERT INTO `notification` VALUES (349, 6, 1, '订单已提交', '您的家电清洗订单 #CM202604072358422465 已提交，正在为您匹配保洁员', 83, 1, '2026-04-10 22:50:31', '2026-04-07 23:58:43');
INSERT INTO `notification` VALUES (350, 6, 1, '订单已提交', '您的地板打蜡订单 #CM202604080100409725 已提交，正在为您匹配保洁员', 84, 1, '2026-04-10 22:50:31', '2026-04-08 01:00:40');
INSERT INTO `notification` VALUES (351, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202604080100409725，请按时在家等候', 84, 1, '2026-04-10 22:50:31', '2026-04-08 01:00:56');
INSERT INTO `notification` VALUES (352, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202604080100409725 即将开始服务', 84, 1, '2026-04-10 22:50:31', '2026-04-08 01:07:21');
INSERT INTO `notification` VALUES (353, 6, 4, '服务已���成', '您的订单 #CM202604080100409725 保洁员已完工，请在48小时内确认并评价', 84, 1, '2026-04-10 22:50:31', '2026-04-08 01:07:32');
INSERT INTO `notification` VALUES (354, 7, 4, '顾客已确认完成', '顾客已确认订单 #CM202604080100409725 完成，收入已计入本月结算', 84, 1, '2026-04-09 13:42:43', '2026-04-08 01:10:03');
INSERT INTO `notification` VALUES (355, 6, 1, '订单已提交', '您的玻璃清洗订单 #CM202604080133138282 已提交，正在为您匹配保洁员', 85, 1, '2026-04-10 22:50:31', '2026-04-08 01:33:14');
INSERT INTO `notification` VALUES (356, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202604080133138282，请按时在家等候', 85, 1, '2026-04-10 22:50:31', '2026-04-08 01:34:07');
INSERT INTO `notification` VALUES (357, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202604080133138282 即将开始服务', 85, 1, '2026-04-10 22:50:31', '2026-04-08 01:34:27');
INSERT INTO `notification` VALUES (358, 6, 4, '服务已���成', '您的订单 #CM202604080133138282 保洁员已完工，请在48小时内确认并评价', 85, 1, '2026-04-10 22:50:31', '2026-04-08 01:34:59');
INSERT INTO `notification` VALUES (359, 11, 4, '顾客已确认完成', '顾客已确认订单 #CM202604080133138282 完成，收入已计入本月结算', 85, 1, '2026-04-09 14:40:42', '2026-04-08 01:36:10');
INSERT INTO `notification` VALUES (360, 6, 1, '订单已提交', '您的家电清洗订单 #CM202604080140340062 已提交，正在为您匹配保洁员', 86, 1, '2026-04-10 22:50:31', '2026-04-08 01:40:34');
INSERT INTO `notification` VALUES (361, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202604080140340062，请按时在家等候', 86, 1, '2026-04-10 22:50:31', '2026-04-08 01:41:13');
INSERT INTO `notification` VALUES (362, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202604080140340062 即将开始服务', 86, 1, '2026-04-10 22:50:31', '2026-04-08 01:41:37');
INSERT INTO `notification` VALUES (363, 6, 4, '服务已���成', '您的订单 #CM202604080140340062 保洁员已完工，请在48小时内确认并评价', 86, 1, '2026-04-10 22:50:31', '2026-04-08 01:41:45');
INSERT INTO `notification` VALUES (364, 13, 4, '顾客已确认完成', '顾客已确认订单 #CM202604080140340062 完成，收入已计入本月结算', 86, 0, NULL, '2026-04-08 01:44:46');
INSERT INTO `notification` VALUES (365, 6, 1, '订单已提交', '您的日常保洁订单 #CM202604080145262522 已提交，正在为您匹配保洁员', 87, 1, '2026-04-10 22:50:31', '2026-04-08 01:45:26');
INSERT INTO `notification` VALUES (366, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202604080145262522，请按时在家等候', 87, 1, '2026-04-10 22:50:31', '2026-04-08 01:45:55');
INSERT INTO `notification` VALUES (367, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202604080145262522 即将开始服务', 87, 1, '2026-04-10 22:50:31', '2026-04-08 01:46:34');
INSERT INTO `notification` VALUES (368, 6, 4, '服务已���成', '您的订单 #CM202604080145262522 保洁员已完工，请在48小时内确认并评价', 87, 1, '2026-04-10 22:50:31', '2026-04-08 01:46:42');
INSERT INTO `notification` VALUES (369, 10, 4, '顾客已确认完成', '顾客已确认订单 #CM202604080145262522 完成，收入已计入本月结算', 87, 1, '2026-04-09 14:41:09', '2026-04-08 01:47:12');
INSERT INTO `notification` VALUES (370, 6, 1, '订单已提交', '您的深度保洁订单 #CM202604080151505095 已提交，正在为您匹配保洁员', 88, 1, '2026-04-10 22:50:31', '2026-04-08 01:51:51');
INSERT INTO `notification` VALUES (371, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202604080151505095，请按时在家等候', 88, 1, '2026-04-10 22:50:31', '2026-04-08 01:52:18');
INSERT INTO `notification` VALUES (372, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202604080151505095 即将开始服务', 88, 1, '2026-04-10 22:50:31', '2026-04-08 01:52:35');
INSERT INTO `notification` VALUES (373, 6, 4, '服务已���成', '您的订单 #CM202604080151505095 保洁员已完工，请在48小时内确认并评价', 88, 1, '2026-04-10 22:50:31', '2026-04-08 01:53:09');
INSERT INTO `notification` VALUES (374, 12, 4, '顾客已确认完成', '顾客已确认订单 #CM202604080151505095 完成，收入已计入本月结算', 88, 1, '2026-04-10 13:00:25', '2026-04-08 01:53:32');
INSERT INTO `notification` VALUES (375, 6, 1, '订单已提交', '您的开荒保洁订单 #CM202604080156472072 已提交，正在为您匹配保洁员', 89, 1, '2026-04-10 22:50:31', '2026-04-08 01:56:47');
INSERT INTO `notification` VALUES (376, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202604080156472072，请按时在家等候', 89, 1, '2026-04-10 22:50:31', '2026-04-08 01:57:46');
INSERT INTO `notification` VALUES (377, 6, 1, '订单已提交', '您的玻璃清洗订单 #CM202604080158406948 已提交，正在为您匹配保洁员', 90, 1, '2026-04-10 22:50:31', '2026-04-08 01:58:41');
INSERT INTO `notification` VALUES (378, 6, 2, '派单成功', '已为您的订单 #CM202604080158406948 匹配到保洁员，等待保洁员确认接单', 90, 1, '2026-04-10 22:50:31', '2026-04-08 01:58:52');
INSERT INTO `notification` VALUES (379, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604080158406948，请在30分钟内确认接单', 90, 0, NULL, '2026-04-08 01:58:52');
INSERT INTO `notification` VALUES (380, 13, 10, '顾客申请改期', '顾客申请将订单 #CM202604080158406948 从 2026-04-08 06:00 改为 2026-04-08 10:59，请确认', 90, 0, NULL, '2026-04-08 01:59:59');
INSERT INTO `notification` VALUES (381, 6, 11, '改期申请已通过', '您的订单 #CM202604080158406948 改期申请已通过，新预约时间为 2026-04-08 10:59', 90, 1, '2026-04-10 22:50:31', '2026-04-08 02:00:23');
INSERT INTO `notification` VALUES (382, 13, 10, '顾客申请改期', '顾客申请将订单 #CM202604080158406948 从 2026-04-08 10:59 改为 2026-04-08 07:00，请确认', 90, 0, NULL, '2026-04-08 02:06:10');
INSERT INTO `notification` VALUES (383, 6, 11, '改期申请已通过', '您的订单 #CM202604080158406948 改期申请已通过，新预约时间为 2026-04-08 07:00', 90, 1, '2026-04-10 22:50:31', '2026-04-08 02:06:46');
INSERT INTO `notification` VALUES (384, 13, 10, '顾客申请改期', '顾客申请将订单 #CM202604080158406948 从 2026-04-08 07:00 改为 2026-04-08 04:00，请确认', 90, 0, NULL, '2026-04-08 02:07:06');
INSERT INTO `notification` VALUES (385, 6, 11, '改期申请被拒绝', '您的订单 #CM202604080158406948 改期申请被拒绝，原时间不变', 90, 1, '2026-04-10 22:50:31', '2026-04-08 02:07:33');
INSERT INTO `notification` VALUES (386, 44, 6, '审核通过', '恭喜您！您的保洁员资质审核已通过，现在可以开始接单了', NULL, 1, '2026-04-08 02:14:27', '2026-04-08 02:14:18');
INSERT INTO `notification` VALUES (387, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202604080156472072 即将开始服务', 89, 1, '2026-04-10 22:50:31', '2026-04-08 02:31:26');
INSERT INTO `notification` VALUES (388, 6, 4, '服务已���成', '您的订单 #CM202604080156472072 保洁员已完工，请在48小时内确认并评价', 89, 1, '2026-04-10 22:50:31', '2026-04-08 02:31:33');
INSERT INTO `notification` VALUES (389, 14, 4, '顾客已确认完成', '顾客已确认订单 #CM202604080156472072 完成，收入已计入本月结算', 89, 1, '2026-04-10 12:41:31', '2026-04-08 02:31:47');
INSERT INTO `notification` VALUES (390, 8, 7, '新投诉待处理', '订单 #CM202604080156472072 收到新投诉，请及时处理', 89, 0, NULL, '2026-04-08 02:32:06');
INSERT INTO `notification` VALUES (391, 6, 7, '投诉已结案 - 免费重做', '您的订单 #CM202604080156472072 已安排免费重做，平台将重新为您派单', 89, 1, '2026-04-10 22:50:31', '2026-04-08 02:35:22');
INSERT INTO `notification` VALUES (392, 14, 7, '投诉结案通知', '订单 #CM202604080156472072 投诉结案（免费重做），本单收入已清零', 89, 1, '2026-04-10 12:41:31', '2026-04-08 02:35:22');
INSERT INTO `notification` VALUES (393, 8, 7, '新投诉待处理', '订单 #CM202604080151505095 收到新投诉，请及时处理', 88, 0, NULL, '2026-04-08 02:37:19');
INSERT INTO `notification` VALUES (394, 6, 7, '投诉已结案 - 部分退款', '您的订单 #CM202604080151505095 投诉已结案，平台为您部分退款 ¥2', 88, 1, '2026-04-10 22:50:31', '2026-04-08 02:37:37');
INSERT INTO `notification` VALUES (395, 12, 7, '投诉结案通知', '订单 #CM202604080151505095 投诉结案（部分退款），收入已按比例调整', 88, 1, '2026-04-10 13:00:25', '2026-04-08 02:37:37');
INSERT INTO `notification` VALUES (396, 8, 7, '新投诉待处理', '订单 #CM202604080145262522 收到新投诉，请及时处理', 87, 0, NULL, '2026-04-08 02:38:17');
INSERT INTO `notification` VALUES (397, 6, 7, '投诉已结案 - 全额退款', '您的订单 #CM202604080145262522 投诉已结案，平台已为您全额退款', 87, 1, '2026-04-10 22:50:31', '2026-04-08 02:38:34');
INSERT INTO `notification` VALUES (398, 10, 7, '投诉结案通知', '订单 #CM202604080145262522 投诉结案（全额退款），本单收入已清零', 87, 1, '2026-04-09 14:41:09', '2026-04-08 02:38:34');
INSERT INTO `notification` VALUES (399, 8, 7, '新投诉待处理', '订单 #CM202604080140340062 收到新投诉，请及时处理', 86, 0, NULL, '2026-04-08 02:39:32');
INSERT INTO `notification` VALUES (400, 6, 7, '投诉已结案 - 全额退款', '您的订单 #CM202604080140340062 投诉已结案，平台已为您全额退款', 86, 1, '2026-04-10 22:50:31', '2026-04-08 02:39:56');
INSERT INTO `notification` VALUES (401, 13, 7, '投诉结案通知', '订单 #CM202604080140340062 投诉结案（全额退款），本单收入已清零', 86, 0, NULL, '2026-04-08 02:39:56');
INSERT INTO `notification` VALUES (402, 8, 7, '新投诉待处理', '订单 #CM202604080133138282 收到新投诉，请及时处理', 85, 0, NULL, '2026-04-08 02:40:40');
INSERT INTO `notification` VALUES (403, 6, 7, '投诉已结案 - 驳回', '您的订单 #CM202604080133138282 投诉申请已驳回，订单已完成', 85, 1, '2026-04-08 02:44:17', '2026-04-08 02:40:56');
INSERT INTO `notification` VALUES (404, 8, 7, '新投诉待处理', '订单 #CM202604080100409725 收到新投诉，请及时处理', 84, 0, NULL, '2026-04-08 02:56:33');
INSERT INTO `notification` VALUES (405, 6, 7, '投诉已结案 - 免费重做', '您的订单 #CM202604080100409725 已安排免费重做，平台将重新为您派单', 84, 1, '2026-04-10 22:50:31', '2026-04-08 02:58:00');
INSERT INTO `notification` VALUES (406, 7, 7, '投诉结案通知', '订单 #CM202604080100409725 投诉结案（免费重做），本单收入已清零', 84, 1, '2026-04-09 13:42:43', '2026-04-08 02:58:00');
INSERT INTO `notification` VALUES (407, 6, 2, '派单成功', '已为您的订单 #CM202604080100409725 匹配到保洁员，等待保洁员确认接单', 84, 1, '2026-04-10 22:50:31', '2026-04-08 02:58:28');
INSERT INTO `notification` VALUES (408, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604080100409725，请在30分钟内确认接单', 84, 0, NULL, '2026-04-08 02:58:28');
INSERT INTO `notification` VALUES (409, 6, 1, '订单已提交', '您的油烟机清洗订单 #CM202604080354390271 已提交，正在为您匹配保洁员', 91, 1, '2026-04-10 22:50:31', '2026-04-08 03:54:40');
INSERT INTO `notification` VALUES (410, 6, 2, '派单成功', '已为您的订单 #CM202604080354390271 匹配到保洁员，等待保洁员确认接单', 91, 1, '2026-04-10 22:50:31', '2026-04-08 03:54:57');
INSERT INTO `notification` VALUES (411, 14, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604080354390271，请在30分钟内确认接单', 91, 1, '2026-04-10 12:41:31', '2026-04-08 03:54:57');
INSERT INTO `notification` VALUES (412, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202604080354390271 即将开始服务', 91, 1, '2026-04-10 22:50:31', '2026-04-08 03:55:30');
INSERT INTO `notification` VALUES (413, 6, 4, '服务已���成', '您的订单 #CM202604080354390271 保洁员已完工，请在48小时内确认并评价', 91, 1, '2026-04-10 22:50:31', '2026-04-08 03:58:59');
INSERT INTO `notification` VALUES (414, 6, 1, '订单已提交', '您的家电清洗订单 #CM202604080400005933 已提交，正在为您匹配保洁员', 92, 1, '2026-04-10 22:50:31', '2026-04-08 04:00:01');
INSERT INTO `notification` VALUES (415, 6, 2, '派单成功', '已为您的订单 #CM202604080400005933 匹配到保洁员，等待保洁员确认接单', 92, 1, '2026-04-10 22:50:31', '2026-04-08 04:00:14');
INSERT INTO `notification` VALUES (416, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604080400005933，请在30分钟内确认接单', 92, 1, '2026-04-09 13:42:43', '2026-04-08 04:00:14');
INSERT INTO `notification` VALUES (417, 6, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202604080400005933 即将开始服务', 92, 1, '2026-04-10 22:50:31', '2026-04-08 04:00:30');
INSERT INTO `notification` VALUES (418, 6, 4, '服务已���成', '您的订单 #CM202604080400005933 保洁员已完工，请在48小时内确认并评价', 92, 1, '2026-04-10 22:50:31', '2026-04-08 04:00:57');
INSERT INTO `notification` VALUES (419, 8, 8, '保洁员未到场告警', '订单 #CM202604080100409725 已自动取消，原因：保洁员超时未签到。请尽快核查。', 84, 0, NULL, '2026-04-08 13:12:45');
INSERT INTO `notification` VALUES (420, 8, 8, '保洁员未到场告警', '订单 #CM202604080158406948 已自动取消，原因：保洁员超时未签到。请尽快核查。', 90, 0, NULL, '2026-04-08 13:12:45');
INSERT INTO `notification` VALUES (421, 8, 8, '保洁员未到场告警', '订单 #JD_202604071401221724 已自动取消，原因：保洁员超时未签到。请尽快核查。', 74, 0, NULL, '2026-04-08 16:12:46');
INSERT INTO `notification` VALUES (422, 8, 8, '保洁员未到场告警', '订单 #JD_202604071401225420 已自动取消，原因：保洁员超时未签到。请尽快核查。', 75, 0, NULL, '2026-04-09 12:09:38');
INSERT INTO `notification` VALUES (423, 45, 1, '订单已提交', '您的日常保洁订单 #CM202604091252569762 已提交，正在为您匹配保洁员', 93, 0, NULL, '2026-04-09 12:52:56');
INSERT INTO `notification` VALUES (424, 45, 2, '派单成功', '已为您的订单 #CM202604091252569762 匹配到保洁员，等待保洁员确认接单', 93, 0, NULL, '2026-04-09 12:53:24');
INSERT INTO `notification` VALUES (425, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604091252569762，请在30分钟内确认接单', 93, 1, '2026-04-10 13:00:25', '2026-04-09 12:53:24');
INSERT INTO `notification` VALUES (426, 42, 2, '派单成功', '已为您的订单 #JD_202604071405311315 匹配到保洁员，等待保洁员确认接单', 80, 0, NULL, '2026-04-09 14:16:34');
INSERT INTO `notification` VALUES (427, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604071405311315，请在30分钟内确认接单', 80, 0, NULL, '2026-04-09 14:16:34');
INSERT INTO `notification` VALUES (428, 45, 1, '订单已提交', '您的油烟机清洗订单 #CM202604091420364417 已提交，正在为您匹配保洁员', 94, 0, NULL, '2026-04-09 14:20:36');
INSERT INTO `notification` VALUES (429, 45, 2, '派单成功', '已为您的订单 #CM202604091420364417 匹配到保洁员，等待保洁员确认接单', 94, 0, NULL, '2026-04-09 14:20:51');
INSERT INTO `notification` VALUES (430, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604091420364417，请在30分钟内确认接单', 94, 1, '2026-04-10 13:00:25', '2026-04-09 14:20:51');
INSERT INTO `notification` VALUES (431, 45, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202604091420364417 即将开始服务', 94, 0, NULL, '2026-04-09 14:23:12');
INSERT INTO `notification` VALUES (432, 45, 4, '服务已���成', '您的订单 #CM202604091420364417 保洁员已完工，请在48小时内确认并评价', 94, 0, NULL, '2026-04-09 14:23:19');
INSERT INTO `notification` VALUES (433, 12, 4, '顾客已确认完成', '顾客已确认订单 #CM202604091420364417 完成，收入已计入本月结算', 94, 1, '2026-04-10 13:00:25', '2026-04-09 14:23:49');
INSERT INTO `notification` VALUES (434, 47, 2, '派单成功', '已为您的订单 #JD_202604091434545109 匹配到保洁员，等待保洁员确认接单', 96, 0, NULL, '2026-04-09 14:35:00');
INSERT INTO `notification` VALUES (435, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604091434545109，请在30分钟内确认接单', 96, 0, NULL, '2026-04-09 14:35:00');
INSERT INTO `notification` VALUES (436, 47, 2, '派单成功', '已为您的订单 #JD_202604091434545109 匹配到保洁员，等待保洁员确认接单', 96, 0, NULL, '2026-04-09 14:35:12');
INSERT INTO `notification` VALUES (437, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604091434545109，请在30分钟内确认接单', 96, 0, NULL, '2026-04-09 14:35:12');
INSERT INTO `notification` VALUES (438, 46, 2, '派单成功', '已为您的订单 #JD_202604091434547413 匹配到保洁员，等待保洁员确认接单', 95, 0, NULL, '2026-04-09 14:35:15');
INSERT INTO `notification` VALUES (439, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604091434547413，请在30分钟内确认接单', 95, 1, '2026-04-09 14:41:09', '2026-04-09 14:35:15');
INSERT INTO `notification` VALUES (440, 42, 2, '派单成功', '已为您的订单 #JD_202604071405311315 匹配到保洁员，等待保洁员确认接单', 80, 0, NULL, '2026-04-09 14:35:18');
INSERT INTO `notification` VALUES (441, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604071405311315，请在30分钟内确认接单', 80, 0, NULL, '2026-04-09 14:35:18');
INSERT INTO `notification` VALUES (442, 7, 5, '您有新订单待确认', '管理员为您分配了新订单 #JD_202604091434544225，请在30分钟内确认接单', 98, 0, NULL, '2026-04-09 14:36:51');
INSERT INTO `notification` VALUES (443, 49, 2, '订单已派单', '您的订单 #JD_202604091434544225 已为您匹配保洁员，等待保洁员确认接单', 98, 0, NULL, '2026-04-09 14:36:51');
INSERT INTO `notification` VALUES (444, 48, 2, '派单成功', '已为您的订单 #JD_202604091434542436 匹配到保洁员，等待保洁员确认接单', 97, 0, NULL, '2026-04-09 14:38:18');
INSERT INTO `notification` VALUES (445, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604091434542436，请在30分钟内确认接单', 97, 0, NULL, '2026-04-09 14:38:18');
INSERT INTO `notification` VALUES (446, 46, 2, '派单成功', '已为您的订单 #JD_202604091434547413 匹配到保洁员，等待保洁员确认接单', 95, 0, NULL, '2026-04-09 14:40:23');
INSERT INTO `notification` VALUES (447, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604091434547413，请在30分钟内确认接单', 95, 1, '2026-04-09 14:41:09', '2026-04-09 14:40:23');
INSERT INTO `notification` VALUES (448, 6, 1, '订单已提交', '您的日常保洁订单 #CM202604092136266222 已提交，正在为您匹配保洁员', 99, 1, '2026-04-10 22:50:31', '2026-04-09 21:36:26');
INSERT INTO `notification` VALUES (449, 8, 8, '派单失败，需手动处理', '订单 CM202604092136266222 暂无合适保洁员，请手动派单', 99, 0, NULL, '2026-04-09 21:36:54');
INSERT INTO `notification` VALUES (450, 8, 8, '派单失败，需手动处理', '订单 CM202604092136266222 暂无合适保洁员，请手动派单', 99, 0, NULL, '2026-04-09 21:45:47');
INSERT INTO `notification` VALUES (451, 8, 8, '派单失败，需手动处理', '订单 CM202604092136266222 暂无合适保洁员，请手动派单', 99, 0, NULL, '2026-04-09 21:45:52');
INSERT INTO `notification` VALUES (452, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202604092136266222，请按时在家等候', 99, 1, '2026-04-10 22:50:31', '2026-04-09 21:48:46');
INSERT INTO `notification` VALUES (454, 45, 1, '订单已提交', '您的地板打蜡订单 #CM202604092201331018 已提交，正在为您匹配保洁员', 100, 0, NULL, '2026-04-09 22:01:33');
INSERT INTO `notification` VALUES (455, 45, 2, '派单成功', '已为您的订单 #CM202604092201331018 匹配到保洁员，等待保洁员确认接单', 100, 0, NULL, '2026-04-09 22:01:55');
INSERT INTO `notification` VALUES (456, 14, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604092201331018，请在30分钟内确认接单', 100, 1, '2026-04-10 12:41:31', '2026-04-09 22:01:55');
INSERT INTO `notification` VALUES (457, 6, 1, '订单已提交', '您的家电清洗订单 #CM202604092202335963 已提交，正在为您匹配保洁员', 101, 1, '2026-04-10 22:50:31', '2026-04-09 22:02:34');
INSERT INTO `notification` VALUES (458, 6, 2, '派单成功', '已为您的订单 #CM202604092202335963 匹配到保洁员，等待保洁员确认接单', 101, 1, '2026-04-10 22:50:31', '2026-04-09 22:02:54');
INSERT INTO `notification` VALUES (459, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604092202335963，请在30分钟内确认接单', 101, 0, NULL, '2026-04-09 22:02:54');
INSERT INTO `notification` VALUES (460, 45, 1, '订单已提交', '您的玻璃清洗订单 #CM202604092204017083 已提交，正在为您匹配保洁员', 102, 0, NULL, '2026-04-09 22:04:01');
INSERT INTO `notification` VALUES (461, 8, 8, '派单失败，需手动处理', '订单 CM202604092204017083 暂无合适保洁员，请手动派单', 102, 1, '2026-04-09 22:11:06', '2026-04-09 22:04:11');
INSERT INTO `notification` VALUES (463, 45, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202604092201331018 即将开始服务', 100, 0, NULL, '2026-04-09 22:10:11');
INSERT INTO `notification` VALUES (464, 45, 4, '服务已���成', '您的订单 #CM202604092201331018 保洁员已完工，请在48小时内确认并评价', 100, 0, NULL, '2026-04-09 22:10:19');
INSERT INTO `notification` VALUES (465, 6, 1, '订单已提交', '您的油烟机清洗订单 #CM202604092214553004 已提交，正在为您匹配保洁员', 103, 1, '2026-04-10 22:50:31', '2026-04-09 22:14:56');
INSERT INTO `notification` VALUES (466, 6, 2, '派单成功', '已为您的订单 #CM202604092214553004 匹配到保洁员，等待保洁员确认接单', 103, 1, '2026-04-10 22:50:31', '2026-04-09 22:15:13');
INSERT INTO `notification` VALUES (467, 13, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604092214553004，请在30分钟内确认接单', 103, 0, NULL, '2026-04-09 22:15:13');
INSERT INTO `notification` VALUES (468, 12, 5, '您有新订单待确认', '管理员为您分配了新订单 #CM202604092214553004，请在30分钟内确认接单', 103, 1, '2026-04-10 13:00:25', '2026-04-09 22:15:23');
INSERT INTO `notification` VALUES (469, 6, 2, '订单已派单', '您的订单 #CM202604092214553004 已为您匹配保洁员，等待保洁员确认接单', 103, 1, '2026-04-10 22:50:31', '2026-04-09 22:15:23');
INSERT INTO `notification` VALUES (471, 6, 4, '服务已���成', '您的订单 #CM202604092214553004 保洁员已完工，请在48小时内确认并评价', 103, 1, '2026-04-10 22:50:31', '2026-04-09 22:50:06');
INSERT INTO `notification` VALUES (472, 51, 2, '派单成功', '已为您的订单 #JD_202604092311253574 匹配到保洁员，等待保洁员确认接单', 105, 0, NULL, '2026-04-09 23:11:30');
INSERT INTO `notification` VALUES (473, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604092311253574，请在30分钟内确认接单', 105, 0, NULL, '2026-04-09 23:11:30');
INSERT INTO `notification` VALUES (474, 8, 8, '派单失败，需手动处理', '订单 JD_202604092311250849 暂无合适保洁员，请手动派单', 106, 0, NULL, '2026-04-09 23:11:42');
INSERT INTO `notification` VALUES (475, 8, 8, '派单失败，需手动处理', '订单 JD_202604092311250849 暂无合适保洁员，请手动派单', 106, 1, '2026-04-09 23:28:20', '2026-04-09 23:11:59');
INSERT INTO `notification` VALUES (476, 8, 8, '派单失败，需手动处理', '订单 JD_202604092311250849 暂无合适保洁员，请手动派单', 106, 0, NULL, '2026-04-09 23:28:21');
INSERT INTO `notification` VALUES (477, 50, 2, '派单成功', '已为您的订单 #JD_202604092311257238 匹配到保洁员，等待保洁员确认接单', 104, 0, NULL, '2026-04-09 23:28:25');
INSERT INTO `notification` VALUES (478, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604092311257238，请在30分钟内确认接单', 104, 0, NULL, '2026-04-09 23:28:25');
INSERT INTO `notification` VALUES (479, 53, 2, '派单成功', '已为您的订单 #JD_202604092311251725 匹配到保洁员，等待保洁员确认接单', 107, 0, NULL, '2026-04-09 23:28:29');
INSERT INTO `notification` VALUES (480, 7, 5, '您有新订单待确认', '系统为您派送了一个新订单 #JD_202604092311251725，请在30分钟内确认接单', 107, 0, NULL, '2026-04-09 23:28:29');
INSERT INTO `notification` VALUES (481, 8, 8, '派单失败，需手动处理', '订单 JD_202604092311250849 暂无合适保洁员，请手动派单', 106, 1, '2026-04-09 23:32:17', '2026-04-09 23:30:32');
INSERT INTO `notification` VALUES (482, 8, 8, '保洁员未到场告警', '订单 #CM202604092136266222 已自动取消，原因：保洁员超时未签到。请尽快核查。', 99, 0, NULL, '2026-04-09 23:49:48');
INSERT INTO `notification` VALUES (483, 8, 8, '保洁员未到场告警', '订单 #CM202604092202335963 已自动取消，原因：保洁员超时未签到。请尽快核查。', 101, 0, NULL, '2026-04-10 00:19:48');
INSERT INTO `notification` VALUES (484, 8, 8, '保洁员未到场告警', '订单 #JD_202604071401234228 已自动取消，原因：保洁员超时未签到。请尽快核查。', 76, 0, NULL, '2026-04-10 11:14:08');
INSERT INTO `notification` VALUES (485, 8, 8, '保洁员未到场告警', '订单 #JD_202604091434547413 已自动取消，原因：保洁员超时未签到。请尽快核查。', 95, 0, NULL, '2026-04-10 11:14:08');
INSERT INTO `notification` VALUES (486, 8, 8, '保洁员未到场告警', '订单 #JD_202604092311257238 已自动取消，原因：保洁员超时未签到。请尽快核查。', 104, 0, NULL, '2026-04-10 11:14:08');
INSERT INTO `notification` VALUES (487, 11, 5, '您有新订单待确认', '管理员为您分配了新订单 #JD_202604092311253574，请在30分钟内确认接单', 105, 0, NULL, '2026-04-10 12:14:39');
INSERT INTO `notification` VALUES (488, 51, 2, '订单已派单', '您的订单 #JD_202604092311253574 已为您匹配保洁员，等待保洁员确认接单', 105, 0, NULL, '2026-04-10 12:14:39');
INSERT INTO `notification` VALUES (489, 8, 8, '派单失败，需手动处理', '订单 JD_202604092311250849 暂无合适保洁员，请手动派单', 106, 1, '2026-04-10 19:10:19', '2026-04-10 12:22:14');
INSERT INTO `notification` VALUES (490, 12, 5, '您有新订单待确认', '管理员为您分配了新订单 #JD_202604092311253574，请在30分钟内确认接单', 105, 1, '2026-04-10 13:00:25', '2026-04-10 12:22:36');
INSERT INTO `notification` VALUES (491, 51, 2, '订单已派单', '您的订单 #JD_202604092311253574 已为您匹配保洁员，等待保洁员确认接单', 105, 0, NULL, '2026-04-10 12:22:36');
INSERT INTO `notification` VALUES (492, 45, 1, '订单已提交', '您的地板打蜡订单 #CM202604101223459187 已提交，正在为您匹配保洁员', 108, 0, NULL, '2026-04-10 12:23:45');
INSERT INTO `notification` VALUES (493, 45, 2, '派单成功', '已为您的订单 #CM202604101223459187 匹配到保洁员，等待保洁员确认接单', 108, 0, NULL, '2026-04-10 12:23:59');
INSERT INTO `notification` VALUES (494, 14, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604101223459187，请在30分钟内确认接单', 108, 1, '2026-04-10 12:41:31', '2026-04-10 12:23:59');
INSERT INTO `notification` VALUES (495, 45, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202604101223459187 即将开始服务', 108, 0, NULL, '2026-04-10 12:24:49');
INSERT INTO `notification` VALUES (496, 45, 4, '服务已���成', '您的订单 #CM202604101223459187 保洁员已完工，请在48小时内确认并评价', 108, 0, NULL, '2026-04-10 12:24:55');
INSERT INTO `notification` VALUES (497, 6, 1, '订单已提交', '您的家电清洗订单 #CM202604101225562383 已提交，正在为您匹配保洁员', 109, 1, '2026-04-10 22:50:31', '2026-04-10 12:25:56');
INSERT INTO `notification` VALUES (498, 6, 1, '订单已提交', '您的家电清洗订单 #CM202604101234048603 已提交，正在为您匹配保洁员', 110, 1, '2026-04-10 22:50:31', '2026-04-10 12:34:05');
INSERT INTO `notification` VALUES (499, 45, 1, '订单已提交', '您的日常保洁订单 #CM202604101242402321 已提交，正在为您匹配保洁员', 111, 0, NULL, '2026-04-10 12:42:41');
INSERT INTO `notification` VALUES (500, 6, 1, '订单已提交', '您的家电清洗订单 #CM202604101243474500 已提交，正在为您匹配保洁员', 112, 1, '2026-04-10 22:50:31', '2026-04-10 12:43:47');
INSERT INTO `notification` VALUES (501, 45, 2, '派单成功', '已为您的订单 #CM202604101242402321 匹配到保洁员，等待保洁员确认接单', 111, 0, NULL, '2026-04-10 12:44:01');
INSERT INTO `notification` VALUES (502, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604101242402321，请在30分钟内确认接单', 111, 1, '2026-04-10 22:43:38', '2026-04-10 12:44:01');
INSERT INTO `notification` VALUES (503, 6, 2, '派单成功', '已为您的订单 #CM202604101243474500 匹配到保洁员，等待保洁员确认接单', 112, 1, '2026-04-10 22:50:31', '2026-04-10 12:46:16');
INSERT INTO `notification` VALUES (504, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604101243474500，请在30分钟内确认接单', 112, 1, '2026-04-10 22:43:38', '2026-04-10 12:46:16');
INSERT INTO `notification` VALUES (505, 45, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202604101242402321 即将开始服务', 111, 0, NULL, '2026-04-10 12:47:12');
INSERT INTO `notification` VALUES (506, 45, 4, '服务已���成', '您的订单 #CM202604101242402321 保洁员已完工，请在48小时内确认并评价', 111, 0, NULL, '2026-04-10 12:47:17');
INSERT INTO `notification` VALUES (507, 6, 2, '派单成功', '已为您的订单 #CM202604101234048603 匹配到保洁员，等待保洁员确认接单', 110, 1, '2026-04-10 22:50:31', '2026-04-10 12:50:58');
INSERT INTO `notification` VALUES (508, 12, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604101234048603，请在30分钟内确认接单', 110, 1, '2026-04-10 13:00:25', '2026-04-10 12:50:58');
INSERT INTO `notification` VALUES (509, 52, 2, '保洁员已接单', '保洁员已接受您的订单 #JD_202604092311250849，请按时在家等候', 106, 0, NULL, '2026-04-10 13:00:21');
INSERT INTO `notification` VALUES (510, 6, 2, '保洁员已接单', '保洁员已接受您的订单 #CM202604101234048603，请按时在家等候', 110, 1, '2026-04-10 22:50:31', '2026-04-10 13:02:33');
INSERT INTO `notification` VALUES (511, 52, 2, '保洁员已接单', '保洁员已接受您的订单 #JD_202604092311250849，请按时在家等候', 106, 0, NULL, '2026-04-10 13:03:57');
INSERT INTO `notification` VALUES (512, 6, 1, '订单已提交', '您的玻璃清洗订单 #CM202604101325443026 已提交，正在为您匹配保洁员', 113, 1, '2026-04-10 22:50:31', '2026-04-10 13:25:45');
INSERT INTO `notification` VALUES (513, 14, 4, '顾客已确认完成', '顾客已确认订单 #CM202604101223459187 完成，收入已计入本月结算', 108, 0, NULL, '2026-04-10 13:38:44');
INSERT INTO `notification` VALUES (514, 45, 1, '订单已提交', '您的油烟机清洗订单 #CM202604101339184161 已提交，正在为您匹配保洁员', 114, 0, NULL, '2026-04-10 13:39:18');
INSERT INTO `notification` VALUES (515, 45, 2, '派单成功', '已为您的订单 #CM202604101339184161 匹配到保洁员，等待保洁员确认接单', 114, 0, NULL, '2026-04-10 13:39:44');
INSERT INTO `notification` VALUES (516, 11, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604101339184161，请在30分钟内确认接单', 114, 0, NULL, '2026-04-10 13:39:44');
INSERT INTO `notification` VALUES (517, 13, 9, '出行提醒', '您有一个订单将于 2026-04-10 15:00 开始，请提前出发！地址：重庆市沙坪坝区大学城南路5208号', 80, 0, NULL, '2026-04-10 13:58:24');
INSERT INTO `notification` VALUES (518, 12, 9, '出行提醒', '您有一个订单将于 2026-04-10 15:05 开始，请提前出发！地址：重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 110, 0, NULL, '2026-04-10 13:58:24');
INSERT INTO `notification` VALUES (519, 8, 8, '保洁员未到场告警', '订单 #CM202604101339184161 已自动取消，原因：保洁员超时未签到。请尽快核查。', 114, 0, NULL, '2026-04-10 16:11:35');
INSERT INTO `notification` VALUES (520, 8, 8, '保洁员未到场告警', '订单 #JD_202604071405311315 已自动取消，原因：保洁员超时未签到。请尽快核查。', 80, 0, NULL, '2026-04-10 17:11:35');
INSERT INTO `notification` VALUES (521, 8, 8, '保洁员未到场告警', '订单 #CM202604101234048603 已自动取消，原因：保洁员超时未签到。请尽快核查。', 110, 0, NULL, '2026-04-10 17:11:35');
INSERT INTO `notification` VALUES (522, 8, 8, '保洁员未到场告警', '订单 #CM202604101243474500 已自动取消，原因：保洁员超时未签到。请尽快核查。', 112, 0, NULL, '2026-04-10 18:56:36');
INSERT INTO `notification` VALUES (523, 45, 1, '订单已提交', '您的玻璃清洗订单 #CM202604101915241358 已提交，正在为您匹配保洁员', 115, 0, NULL, '2026-04-10 19:15:24');
INSERT INTO `notification` VALUES (524, 8, 8, '派单失败，需手动处理', '订单 CM202604101915241358 暂无合适保洁员，请手动派单', 115, 0, NULL, '2026-04-10 19:21:49');
INSERT INTO `notification` VALUES (525, 45, 1, '订单已提交', '您的地板打蜡订单 #CM202604102237383281 已提交，正在为您匹配保洁员', 116, 0, NULL, '2026-04-10 22:37:38');
INSERT INTO `notification` VALUES (526, 45, 2, '派单成功', '已为您的订单 #CM202604102237383281 匹配到保洁员，等待保洁员确认接单', 116, 0, NULL, '2026-04-10 22:42:51');
INSERT INTO `notification` VALUES (527, 10, 5, '您有新订单待确认', '系统为您派送了一个新订单 #CM202604102237383281，请在30分钟内确认接单', 116, 1, '2026-04-10 22:43:38', '2026-04-10 22:42:51');
INSERT INTO `notification` VALUES (528, 45, 3, '保洁员已到达', '保洁员已到达您的服务地址，订单 #CM202604102237383281 即将开始服务', 116, 0, NULL, '2026-04-10 22:46:41');
INSERT INTO `notification` VALUES (529, 45, 4, '服务已���成', '您的订单 #CM202604102237383281 保洁员已完工，请在48小时内确认并评价', 116, 0, NULL, '2026-04-10 22:46:47');
INSERT INTO `notification` VALUES (530, 10, 4, '顾客已确认完成', '顾客已确认订单 #CM202604102237383281 完成，收入已计入本月结算', 116, 0, NULL, '2026-04-10 22:47:01');
INSERT INTO `notification` VALUES (531, 8, 8, '保洁员未到场告警', '订单 #JD_202604071401237501 已自动取消，原因：保洁员超时未签到。请尽快核查。', 77, 0, NULL, '2026-04-11 13:32:49');
INSERT INTO `notification` VALUES (532, 8, 8, '保洁员未到场告警', '订单 #JD_202604091434545109 已自动取消，原因：保洁员超时未签到。请尽快核查。', 96, 0, NULL, '2026-04-11 13:32:49');
INSERT INTO `notification` VALUES (533, 7, 9, '出行提醒', '您有一个订单将于 2026-04-11 15:00 开始，请提前出发！地址：重庆市渝中区解放碑商圈7366号', 81, 0, NULL, '2026-04-11 13:52:49');
INSERT INTO `notification` VALUES (534, 12, 9, '出行提醒', '您有一个订单将于 2026-04-11 15:00 开始，请提前出发！地址：重庆市南岸区南坪西路7022号', 105, 0, NULL, '2026-04-11 13:52:49');

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `operator_id` bigint NOT NULL COMMENT '操作人user_id',
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作模块（如：派单、审核、封禁）',
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作描述',
  `ref_id` bigint NULL DEFAULT NULL COMMENT '关联业务ID',
  `before_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '操作前数据快照（JSON）',
  `after_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '操作后数据快照（JSON）',
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作IP',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_operator_id`(`operator_id` ASC) USING BTREE,
  INDEX `idx_module`(`module` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 72 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of operation_log
-- ----------------------------
INSERT INTO `operation_log` VALUES (1, 8, '派单', '手动派单', 41, NULL, 'cleanerId=12', NULL, '2026-03-25 17:28:02');
INSERT INTO `operation_log` VALUES (2, 8, '派单', '手动派单', 28, NULL, 'cleanerId=14', NULL, '2026-03-25 17:28:20');
INSERT INTO `operation_log` VALUES (3, 8, '派单', '手动派单', 31, NULL, 'cleanerId=7', NULL, '2026-03-25 17:29:26');
INSERT INTO `operation_log` VALUES (4, 8, '派单', '手动派单', 35, NULL, 'cleanerId=12', NULL, '2026-03-25 17:31:56');
INSERT INTO `operation_log` VALUES (5, 8, '派单', '手动派单', 41, NULL, 'cleanerId=7', NULL, '2026-03-25 18:05:04');
INSERT INTO `operation_log` VALUES (6, 8, '派单', '手动派单', 41, NULL, 'cleanerId=14', NULL, '2026-03-25 18:05:25');
INSERT INTO `operation_log` VALUES (7, 8, '派单', '手动派单', 53, NULL, 'cleanerId=10', NULL, '2026-03-26 20:51:52');
INSERT INTO `operation_log` VALUES (8, 8, '派单', '手动派单', 53, NULL, 'cleanerId=13', NULL, '2026-03-28 12:50:01');
INSERT INTO `operation_log` VALUES (9, 8, '系统参数', '修改系统参数[auto_confirm_hours]: 48→12', 5, '48', '12', NULL, '2026-03-28 14:10:39');
INSERT INTO `operation_log` VALUES (10, 8, '系统参数', '修改系统参数[deposit_rate]: 0.20→0.3', 4, '0.20', '0.3', NULL, '2026-03-28 14:16:57');
INSERT INTO `operation_log` VALUES (11, 8, '派单', '手动派单', 59, NULL, 'cleanerId=14', NULL, '2026-03-28 14:19:01');
INSERT INTO `operation_log` VALUES (12, 8, '系统参数', '修改系统参数[cleaner_cancel_hours]: 4→2', 21, '4', '2', NULL, '2026-03-28 14:42:59');
INSERT INTO `operation_log` VALUES (13, 8, '系统参数', '修改系统参数[cleaner_cancel_hours]: 2→2.5', 21, '2', '2.5', NULL, '2026-03-28 14:43:04');
INSERT INTO `operation_log` VALUES (14, 8, '派单', '手动派单', 62, NULL, 'cleanerId=11', NULL, '2026-03-30 18:58:16');
INSERT INTO `operation_log` VALUES (15, 8, '派单', '手动派单', 60, NULL, 'cleanerId=12', NULL, '2026-03-30 22:36:58');
INSERT INTO `operation_log` VALUES (16, 8, '派单', '手动派单', 62, NULL, 'cleanerId=7', NULL, '2026-03-30 22:37:04');
INSERT INTO `operation_log` VALUES (17, 8, '派单', '手动派单', 60, NULL, 'cleanerId=14', NULL, '2026-03-30 22:37:10');
INSERT INTO `operation_log` VALUES (18, 8, '系统参数', '修改系统参数[commute_buffer_minutes]: 30→20', 2, '30', '20', NULL, '2026-03-31 15:50:35');
INSERT INTO `operation_log` VALUES (19, 8, '系统参数', '修改系统参数[cleaner_cancel_hours]: 2.5→1.2', 21, '2.5', '1.2', NULL, '2026-03-31 15:52:33');
INSERT INTO `operation_log` VALUES (20, 8, '系统参数', '修改系统参数[checkin_max_distance_m]: 500→2000', 6, '500', '2000', NULL, '2026-03-31 16:04:36');
INSERT INTO `operation_log` VALUES (21, 8, '系统参数', '修改系统参数[checkin_max_distance_m]: 2000→20000', 6, '2000', '20000', NULL, '2026-03-31 16:14:48');
INSERT INTO `operation_log` VALUES (22, 8, '系统参数', '修改系统参数[checkin_max_distance_m]: 20000→500', 6, '20000', '500', NULL, '2026-03-31 16:16:42');
INSERT INTO `operation_log` VALUES (23, 8, '系统参数', '修改系统参数[cleaner_cancel_hours]: 1.2→1.5', 21, '1.2', '1.5', NULL, '2026-03-31 17:34:33');
INSERT INTO `operation_log` VALUES (24, 8, '系统参数', '修改系统参数[dispatch_max_distance_km]: null→35', 22, NULL, '35', NULL, '2026-03-31 17:34:47');
INSERT INTO `operation_log` VALUES (25, 8, '系统参数', '修改系统参数[auto_confirm_hours]: 12→48', 5, '12', '48', NULL, '2026-04-01 22:11:00');
INSERT INTO `operation_log` VALUES (26, 8, '封禁', '顾客账号状态变更[userId=38]: 1→3（停用）', 38, NULL, NULL, NULL, '2026-04-07 14:02:04');
INSERT INTO `operation_log` VALUES (27, 8, '派单', '手动派单', 78, NULL, 'cleanerId=7', NULL, '2026-04-07 14:06:49');
INSERT INTO `operation_log` VALUES (28, 0, '派单', '自动派单[订单#JD_202604071405311315]: 派给保洁员id=13, 评分=172.0', 80, NULL, 'cleanerId=13', NULL, '2026-04-07 14:13:36');
INSERT INTO `operation_log` VALUES (29, 0, '派单', '自动派单[订单#CM202604080158406948]: 派给保洁员id=13, 评分=468.2', 90, NULL, 'cleanerId=13', NULL, '2026-04-08 01:58:52');
INSERT INTO `operation_log` VALUES (30, 8, '审核', '保洁员审核[id=15]: 通过', 15, NULL, NULL, NULL, '2026-04-08 02:14:18');
INSERT INTO `operation_log` VALUES (31, 8, '投诉处理', '投诉结案[complaintId=10, orderId=89]: 免费重做，备注：11', 89, NULL, NULL, NULL, '2026-04-08 02:35:22');
INSERT INTO `operation_log` VALUES (32, 8, '投诉处理', '投诉结案[complaintId=11, orderId=88]: 部分退款¥2，备注：2', 88, NULL, NULL, NULL, '2026-04-08 02:37:37');
INSERT INTO `operation_log` VALUES (33, 8, '投诉处理', '投诉结案[complaintId=12, orderId=87]: 全额退款，备注：0', 87, NULL, NULL, NULL, '2026-04-08 02:38:34');
INSERT INTO `operation_log` VALUES (34, 8, '投诉处理', '投诉结案[complaintId=13, orderId=86]: 全额退款，备注：80', 86, NULL, NULL, NULL, '2026-04-08 02:39:56');
INSERT INTO `operation_log` VALUES (35, 8, '投诉处理', '投诉结案[complaintId=14, orderId=85]: 驳回投诉，备注：100', 85, NULL, NULL, NULL, '2026-04-08 02:40:56');
INSERT INTO `operation_log` VALUES (36, 8, '投诉处理', '投诉结案[complaintId=15, orderId=84]: 免费重做，备注：是', 84, NULL, NULL, NULL, '2026-04-08 02:58:00');
INSERT INTO `operation_log` VALUES (37, 0, '派单', '自动派单[订单#CM202604080100409725]: 派给保洁员id=13, 评分=542.4', 84, NULL, 'cleanerId=13', NULL, '2026-04-08 02:58:28');
INSERT INTO `operation_log` VALUES (38, 0, '派单', '自动派单[订单#CM202604080354390271]: 派给保洁员id=14, 评分=462.6', 91, NULL, 'cleanerId=14', NULL, '2026-04-08 03:54:57');
INSERT INTO `operation_log` VALUES (39, 0, '派单', '自动派单[订单#CM202604080400005933]: 派给保洁员id=7, 评分=68.4', 92, NULL, 'cleanerId=7', NULL, '2026-04-08 04:00:14');
INSERT INTO `operation_log` VALUES (40, 0, '派单', '自动派单[订单#CM202604091252569762]: 派给保洁员id=12, 评分=132.9', 93, NULL, 'cleanerId=12', NULL, '2026-04-09 12:53:24');
INSERT INTO `operation_log` VALUES (41, 0, '派单', '自动派单[订单#JD_202604071405311315]: 派给保洁员id=13, 评分=72.9', 80, NULL, 'cleanerId=13', NULL, '2026-04-09 14:16:34');
INSERT INTO `operation_log` VALUES (42, 0, '派单', '自动派单[订单#CM202604091420364417]: 派给保洁员id=12, 评分=132.9', 94, NULL, 'cleanerId=12', NULL, '2026-04-09 14:20:51');
INSERT INTO `operation_log` VALUES (43, 8, '系统参数', '修改系统参数[checkin_max_distance_m]: 500→5000', 6, '500', '5000', '0:0:0:0:0:0:0:1', '2026-04-09 14:22:57');
INSERT INTO `operation_log` VALUES (44, 0, '派单', '自动派单[订单#JD_202604091434545109]: 派给保洁员id=13, 评分=61.7', 96, NULL, 'cleanerId=13', NULL, '2026-04-09 14:35:00');
INSERT INTO `operation_log` VALUES (45, 0, '派单', '自动派单[订单#JD_202604091434545109]: 派给保洁员id=13, 评分=61.7', 96, NULL, 'cleanerId=13', NULL, '2026-04-09 14:35:12');
INSERT INTO `operation_log` VALUES (46, 0, '派单', '自动派单[订单#JD_202604091434547413]: 派给保洁员id=10, 评分=103.2', 95, NULL, 'cleanerId=10', NULL, '2026-04-09 14:35:15');
INSERT INTO `operation_log` VALUES (47, 0, '派单', '自动派单[订单#JD_202604071405311315]: 派给保洁员id=13, 评分=69.1', 80, NULL, 'cleanerId=13', NULL, '2026-04-09 14:35:18');
INSERT INTO `operation_log` VALUES (48, 8, '派单', '手动派单', 98, NULL, 'cleanerId=7', NULL, '2026-04-09 14:36:51');
INSERT INTO `operation_log` VALUES (49, 8, '派单', '自动派单[订单#JD_202604091434542436]: 派给保洁员id=7, 评分=79.8', 97, NULL, 'cleanerId=7', NULL, '2026-04-09 14:38:18');
INSERT INTO `operation_log` VALUES (50, 8, '系统参数', '修改系统参数[checkin_max_distance_m]: 5000→4999', 6, '5000', '4999', '0:0:0:0:0:0:0:1', '2026-04-09 14:39:39');
INSERT INTO `operation_log` VALUES (51, 8, '派单', '自动派单[订单#JD_202604091434547413]: 派给保洁员id=10, 评分=103.2', 95, NULL, 'cleanerId=10', NULL, '2026-04-09 14:40:23');
INSERT INTO `operation_log` VALUES (52, 8, '系统参数', '修改系统参数[checkin_max_distance_m]: 4999→600', 6, '4999', '600', '0:0:0:0:0:0:0:1', '2026-04-09 21:50:46');
INSERT INTO `operation_log` VALUES (53, 8, '系统参数', '修改系统参数[checkin_max_distance_m]: 600→5000', 6, '600', '5000', '0:0:0:0:0:0:0:1', '2026-04-09 21:53:01');
INSERT INTO `operation_log` VALUES (54, 8, '派单', '自动派单[订单#CM202604092201331018]: 派给保洁员id=14, 评分=131.2', 100, NULL, 'cleanerId=14', NULL, '2026-04-09 22:01:55');
INSERT INTO `operation_log` VALUES (55, 8, '派单', '自动派单[订单#CM202604092202335963]: 派给保洁员id=11, 评分=327.6', 101, NULL, 'cleanerId=11', NULL, '2026-04-09 22:02:54');
INSERT INTO `operation_log` VALUES (56, 8, '派单', '自动派单[订单#CM202604092214553004]: 派给保洁员id=13, 评分=79.3', 103, NULL, 'cleanerId=13', NULL, '2026-04-09 22:15:13');
INSERT INTO `operation_log` VALUES (57, 8, '派单', '手动派单', 103, NULL, 'cleanerId=12', NULL, '2026-04-09 22:15:23');
INSERT INTO `operation_log` VALUES (58, 8, '派单', '自动派单[订单#JD_202604092311253574]: 派给保洁员id=11, 评分=183.8', 105, NULL, 'cleanerId=11', NULL, '2026-04-09 23:11:30');
INSERT INTO `operation_log` VALUES (59, 8, '派单', '自动派单[订单#JD_202604092311257238]: 派给保洁员id=7, 评分=76.3', 104, NULL, 'cleanerId=7', NULL, '2026-04-09 23:28:25');
INSERT INTO `operation_log` VALUES (60, 8, '派单', '自动派单[订单#JD_202604092311251725]: 派给保洁员id=7, 评分=226.2', 107, NULL, 'cleanerId=7', NULL, '2026-04-09 23:28:29');
INSERT INTO `operation_log` VALUES (61, 8, '派单', '手动派单', 105, NULL, 'cleanerId=11', NULL, '2026-04-10 12:14:39');
INSERT INTO `operation_log` VALUES (62, 8, '派单', '手动派单', 105, NULL, 'cleanerId=12', NULL, '2026-04-10 12:22:36');
INSERT INTO `operation_log` VALUES (63, 8, '派单', '自动派单[订单#CM202604101223459187]: 派给保洁员id=14, 评分=539.2', 108, NULL, 'cleanerId=14', NULL, '2026-04-10 12:23:59');
INSERT INTO `operation_log` VALUES (64, 8, '派单', '自动派单[订单#CM202604101242402321]: 派给保洁员id=10, 评分=132.0', 111, NULL, 'cleanerId=10', NULL, '2026-04-10 12:44:01');
INSERT INTO `operation_log` VALUES (65, 8, '派单', '自动派单[订单#CM202604101243474500]: 派给保洁员id=10, 评分=132.2', 112, NULL, 'cleanerId=10', NULL, '2026-04-10 12:46:16');
INSERT INTO `operation_log` VALUES (66, 8, '派单', '自动派单[订单#CM202604101234048603]: 派给保洁员id=12, 评分=77.6', 110, NULL, 'cleanerId=12', NULL, '2026-04-10 12:50:58');
INSERT INTO `operation_log` VALUES (67, 8, '派单', '自动派单[订单#CM202604101339184161]: 派给保洁员id=11, 评分=77.1', 114, NULL, 'cleanerId=11', NULL, '2026-04-10 13:39:44');
INSERT INTO `operation_log` VALUES (68, 8, '系统参数', '修改系统参数[deposit_rate]: 0.3→0.35', 4, '0.3', '0.35', '0:0:0:0:0:0:0:1', '2026-04-10 22:36:12');
INSERT INTO `operation_log` VALUES (69, 8, '系统参数', '修改系统参数[commission_rate]: 0.20→0.21', 1, '0.20', '0.21', '0:0:0:0:0:0:0:1', '2026-04-10 22:36:24');
INSERT INTO `operation_log` VALUES (70, 8, '派单', '自动派单[订单#CM202604102237383281]: 派给保洁员id=10, 评分=541.5', 116, NULL, 'cleanerId=10', NULL, '2026-04-10 22:42:51');
INSERT INTO `operation_log` VALUES (71, 8, '系统参数', '修改系统参数[commission_rate]: 0.21→0.23', 1, '0.21', '0.23', '0:0:0:0:0:0:0:1', '2026-04-10 22:49:46');

-- ----------------------------
-- Table structure for order_reschedule
-- ----------------------------
DROP TABLE IF EXISTS `order_reschedule`;
CREATE TABLE `order_reschedule`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL,
  `customer_id` bigint NOT NULL,
  `old_time` datetime NOT NULL COMMENT '原预约时间',
  `new_time` datetime NOT NULL COMMENT '申请改到的时间',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1=待审核 2=已通过 3=已拒绝',
  `handle_remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `handled_by` bigint NULL DEFAULT NULL,
  `handled_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '改期申请表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_reschedule
-- ----------------------------
INSERT INTO `order_reschedule` VALUES (1, 54, 6, '2026-03-29 16:30:00', '2026-03-31 10:00:00', 2, '', 7, '2026-03-27 15:41:14', '2026-03-27 15:40:57');
INSERT INTO `order_reschedule` VALUES (2, 70, 6, '2026-03-31 18:39:45', '2026-03-31 17:00:00', 2, '', 12, '2026-03-31 15:51:53', '2026-03-31 15:51:33');
INSERT INTO `order_reschedule` VALUES (3, 90, 6, '2026-04-08 06:00:00', '2026-04-08 10:59:42', 2, '', 13, '2026-04-08 02:00:23', '2026-04-08 01:59:59');
INSERT INTO `order_reschedule` VALUES (4, 90, 6, '2026-04-08 10:59:42', '2026-04-08 07:00:00', 2, '', 13, '2026-04-08 02:06:46', '2026-04-08 02:06:10');
INSERT INTO `order_reschedule` VALUES (5, 90, 6, '2026-04-08 07:00:00', '2026-04-08 04:00:00', 3, '', 13, '2026-04-08 02:07:33', '2026-04-08 02:07:06');

-- ----------------------------
-- Table structure for order_review
-- ----------------------------
DROP TABLE IF EXISTS `order_review`;
CREATE TABLE `order_review`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `customer_id` bigint NOT NULL COMMENT '评价顾客user_id',
  `cleaner_id` bigint NOT NULL COMMENT '被评保洁员user_id',
  `score_attitude` tinyint NOT NULL COMMENT '服务态度评分（1-5）',
  `score_quality` tinyint NOT NULL COMMENT '清洁效果评分（1-5）',
  `score_punctual` tinyint NOT NULL COMMENT '准时到达评分（1-5）',
  `avg_score` decimal(3, 2) NOT NULL COMMENT '综合评分（三项均值）',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文字评价',
  `imgs` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评价图片URLs，逗号分隔',
  `is_visible` tinyint NOT NULL DEFAULT 1 COMMENT '是否可见：1=可见 0=已屏蔽',
  `hide_reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '屏蔽原因',
  `hidden_by` bigint NULL DEFAULT NULL COMMENT '屏蔽操作管理员user_id',
  `reply_content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '保洁员回复内容',
  `replied_at` datetime NULL DEFAULT NULL COMMENT '回复时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_cleaner_id`(`cleaner_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单评价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_review
-- ----------------------------
INSERT INTO `order_review` VALUES (1, 7, 6, 7, 5, 3, 3, 3.67, '1', NULL, 1, NULL, NULL, NULL, NULL, '2026-03-21 13:59:35');
INSERT INTO `order_review` VALUES (2, 2, 6, 7, 5, 3, 2, 3.33, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-21 16:54:46');
INSERT INTO `order_review` VALUES (3, 10, 6, 7, 5, 1, 5, 3.67, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-21 17:31:46');
INSERT INTO `order_review` VALUES (4, 11, 6, 7, 5, 3, 5, 4.33, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-22 15:03:29');
INSERT INTO `order_review` VALUES (5, 12, 6, 10, 4, 5, 5, 4.67, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-22 15:23:07');
INSERT INTO `order_review` VALUES (6, 14, 6, 7, 5, 4, 5, 4.67, 'Good service', NULL, 1, NULL, NULL, NULL, NULL, '2026-03-22 17:11:55');
INSERT INTO `order_review` VALUES (7, 17, 6, 7, 5, 5, 5, 5.00, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-22 18:00:57');
INSERT INTO `order_review` VALUES (8, 24, 6, 7, 5, 4, 5, 4.67, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-23 14:59:30');
INSERT INTO `order_review` VALUES (9, 55, 6, 13, 5, 5, 5, 5.00, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-27 16:08:50');
INSERT INTO `order_review` VALUES (10, 56, 6, 7, 5, 5, 5, 5.00, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-27 16:34:02');
INSERT INTO `order_review` VALUES (11, 57, 6, 11, 5, 5, 4, 4.67, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-27 16:46:32');
INSERT INTO `order_review` VALUES (12, 59, 6, 14, 3, 5, 5, 4.33, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-28 14:20:13');
INSERT INTO `order_review` VALUES (13, 70, 6, 12, 5, 5, 5, 5.00, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-31 18:11:02');
INSERT INTO `order_review` VALUES (14, 72, 6, 14, 5, 5, 5, 5.00, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-31 20:07:44');
INSERT INTO `order_review` VALUES (15, 84, 6, 7, 5, 5, 5, 5.00, NULL, NULL, 1, NULL, NULL, '是的', '2026-04-09 14:15:54', '2026-04-08 01:10:13');
INSERT INTO `order_review` VALUES (16, 87, 6, 10, 5, 5, 5, 5.00, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-04-08 01:47:15');
INSERT INTO `order_review` VALUES (17, 88, 6, 12, 5, 5, 5, 5.00, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-04-08 01:53:37');
INSERT INTO `order_review` VALUES (18, 85, 6, 11, 5, 5, 5, 5.00, '222', NULL, 1, NULL, NULL, NULL, NULL, '2026-04-08 03:45:50');
INSERT INTO `order_review` VALUES (19, 94, 45, 12, 5, 5, 5, 5.00, '还不错', NULL, 1, NULL, NULL, '谢谢', '2026-04-09 14:24:23', '2026-04-09 14:23:55');
INSERT INTO `order_review` VALUES (20, 108, 45, 14, 5, 5, 5, 5.00, '温恩', NULL, 1, NULL, NULL, NULL, NULL, '2026-04-10 13:38:52');
INSERT INTO `order_review` VALUES (21, 92, 6, 7, 5, 5, 5, 5.00, '好看', NULL, 1, NULL, NULL, NULL, NULL, '2026-04-10 22:51:11');
INSERT INTO `order_review` VALUES (22, 91, 6, 14, 4, 5, 5, 4.67, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-04-10 22:53:52');

-- ----------------------------
-- Table structure for order_status_log
-- ----------------------------
DROP TABLE IF EXISTS `order_status_log`;
CREATE TABLE `order_status_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `from_status` tinyint NULL DEFAULT NULL COMMENT '流转前状态',
  `to_status` tinyint NOT NULL COMMENT '流转后状态',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人user_id（系统自动触发时为NULL）',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 563 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订单状态流转日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of order_status_log
-- ----------------------------
INSERT INTO `order_status_log` VALUES (1, 1, NULL, 1, 6, '顾客下单', '2026-03-20 18:19:04');
INSERT INTO `order_status_log` VALUES (2, 1, 1, 3, 7, '保洁员抢单', '2026-03-20 18:29:59');
INSERT INTO `order_status_log` VALUES (3, 2, NULL, 1, 6, '顾客下单', '2026-03-20 19:02:27');
INSERT INTO `order_status_log` VALUES (4, 3, NULL, 1, 6, '顾客下单', '2026-03-20 19:55:54');
INSERT INTO `order_status_log` VALUES (5, 1, 8, 8, 6, '顾客取消：', '2026-03-20 19:58:41');
INSERT INTO `order_status_log` VALUES (6, 3, 1, 3, 7, '保洁员抢单', '2026-03-20 19:59:08');
INSERT INTO `order_status_log` VALUES (7, 2, 1, 3, 7, '保洁员抢单', '2026-03-20 19:59:09');
INSERT INTO `order_status_log` VALUES (8, 4, NULL, 1, 6, '顾客下单', '2026-03-20 20:25:37');
INSERT INTO `order_status_log` VALUES (9, 5, NULL, 1, 6, '顾客下单', '2026-03-20 20:27:11');
INSERT INTO `order_status_log` VALUES (10, 4, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-20 20:31:28');
INSERT INTO `order_status_log` VALUES (11, 5, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-20 20:31:34');
INSERT INTO `order_status_log` VALUES (12, 5, 2, 3, 7, '保洁员确认接单', '2026-03-20 20:37:07');
INSERT INTO `order_status_log` VALUES (13, 4, 2, 3, 7, '保洁员确认接单', '2026-03-20 20:39:41');
INSERT INTO `order_status_log` VALUES (14, 2, 3, 4, 7, '保洁员签到打卡', '2026-03-20 20:47:41');
INSERT INTO `order_status_log` VALUES (15, 2, 4, 5, 7, '保洁员完工上报', '2026-03-20 20:54:11');
INSERT INTO `order_status_log` VALUES (16, 2, 5, 6, 6, '顾客确认完成', '2026-03-20 20:54:33');
INSERT INTO `order_status_log` VALUES (17, 6, NULL, 1, 6, '顾客下单', '2026-03-21 13:21:26');
INSERT INTO `order_status_log` VALUES (18, 7, NULL, 1, 6, '顾客下单', '2026-03-21 13:37:59');
INSERT INTO `order_status_log` VALUES (19, 7, 1, 3, 7, '保洁员抢单', '2026-03-21 13:38:19');
INSERT INTO `order_status_log` VALUES (20, 7, 3, 4, 7, '保洁员签到打卡', '2026-03-21 13:41:12');
INSERT INTO `order_status_log` VALUES (21, 4, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-21T09:00），系统自动取消', '2026-03-21 13:43:44');
INSERT INTO `order_status_log` VALUES (22, 5, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-21T06:00），系统自动取消', '2026-03-21 13:43:44');
INSERT INTO `order_status_log` VALUES (23, 7, 4, 5, 7, '保洁员完工上报', '2026-03-21 13:47:09');
INSERT INTO `order_status_log` VALUES (24, 7, 5, 6, 6, '顾客确认完成', '2026-03-21 13:56:47');
INSERT INTO `order_status_log` VALUES (25, 6, 8, 8, 6, '顾客取消：', '2026-03-21 13:59:47');
INSERT INTO `order_status_log` VALUES (26, 8, NULL, 1, 6, '顾客下单', '2026-03-21 14:36:56');
INSERT INTO `order_status_log` VALUES (27, 8, 1, 3, 10, '保洁员抢单', '2026-03-21 15:39:46');
INSERT INTO `order_status_log` VALUES (28, 8, 8, 8, 6, '顾客取消：', '2026-03-21 15:45:57');
INSERT INTO `order_status_log` VALUES (29, 9, NULL, 1, 6, '顾客下单', '2026-03-21 15:46:20');
INSERT INTO `order_status_log` VALUES (30, 9, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-21 15:47:31');
INSERT INTO `order_status_log` VALUES (31, 9, 2, 1, 7, '保洁员拒绝接单，退回待派单', '2026-03-21 15:52:06');
INSERT INTO `order_status_log` VALUES (32, 9, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-21 15:52:20');
INSERT INTO `order_status_log` VALUES (33, 9, 2, 1, 7, '保洁员拒绝接单，退回待派单', '2026-03-21 15:55:32');
INSERT INTO `order_status_log` VALUES (34, 9, 1, 3, 10, '保洁员抢单', '2026-03-21 15:58:53');
INSERT INTO `order_status_log` VALUES (35, 10, NULL, 1, 6, '顾客下单', '2026-03-21 17:11:16');
INSERT INTO `order_status_log` VALUES (36, 10, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-21 17:11:27');
INSERT INTO `order_status_log` VALUES (37, 10, 2, 3, 7, '保洁员确认接单', '2026-03-21 17:11:34');
INSERT INTO `order_status_log` VALUES (38, 10, 3, 4, 7, '保洁员签到打卡', '2026-03-21 17:11:42');
INSERT INTO `order_status_log` VALUES (39, 10, 4, 5, 7, '保洁员完工上报', '2026-03-21 17:12:10');
INSERT INTO `order_status_log` VALUES (40, 10, 5, 7, 6, '顾客拒绝确认完成，发起投诉', '2026-03-21 17:13:40');
INSERT INTO `order_status_log` VALUES (41, 3, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-22T08:00:17），系统自动取消', '2026-03-22 13:30:09');
INSERT INTO `order_status_log` VALUES (42, 9, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-21T18:37:06），系统自动取消', '2026-03-22 13:30:09');
INSERT INTO `order_status_log` VALUES (43, 11, NULL, 1, 6, '顾客下单', '2026-03-22 14:59:07');
INSERT INTO `order_status_log` VALUES (44, 11, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-22 14:59:25');
INSERT INTO `order_status_log` VALUES (45, 11, 2, 3, 7, '保洁员确认接单', '2026-03-22 14:59:59');
INSERT INTO `order_status_log` VALUES (46, 11, 3, 4, 7, '保洁员签到打卡', '2026-03-22 15:00:07');
INSERT INTO `order_status_log` VALUES (47, 11, 4, 5, 7, '保洁员完工上报', '2026-03-22 15:00:24');
INSERT INTO `order_status_log` VALUES (48, 11, 5, 7, 6, '顾客拒绝确认完成，发起投诉', '2026-03-22 15:00:45');
INSERT INTO `order_status_log` VALUES (49, 12, NULL, 1, 6, '顾客下单', '2026-03-22 15:15:32');
INSERT INTO `order_status_log` VALUES (50, 12, 1, 3, 10, '保洁员抢单', '2026-03-22 15:15:43');
INSERT INTO `order_status_log` VALUES (51, 12, 3, 4, 10, '保洁员签到打卡', '2026-03-22 15:15:52');
INSERT INTO `order_status_log` VALUES (52, 12, 4, 5, 10, '保洁员完工上报', '2026-03-22 15:15:55');
INSERT INTO `order_status_log` VALUES (53, 12, 5, 7, 6, '顾客拒绝确认完成，发起投诉', '2026-03-22 15:16:10');
INSERT INTO `order_status_log` VALUES (54, 13, 7, 6, 8, '投诉处理：全额退款，订单完成', '2026-03-22 17:07:40');
INSERT INTO `order_status_log` VALUES (55, 14, 7, 6, 8, '投诉处理：驳回，订单恢复完成', '2026-03-22 17:07:40');
INSERT INTO `order_status_log` VALUES (56, 15, 7, 1, 8, '投诉处理：免费重做，重新待派单', '2026-03-22 17:07:40');
INSERT INTO `order_status_log` VALUES (57, 15, 7, 1, 8, '投诉处理：免费重做，重新待派单', '2026-03-22 17:10:23');
INSERT INTO `order_status_log` VALUES (58, 16, 3, 8, 6, '顾客报告保洁员未到场', '2026-03-22 17:10:43');
INSERT INTO `order_status_log` VALUES (59, 18, 5, 6, 6, '顾客确认完成', '2026-03-22 17:11:08');
INSERT INTO `order_status_log` VALUES (60, 17, 3, 4, 7, '保洁员签到打卡', '2026-03-22 17:49:10');
INSERT INTO `order_status_log` VALUES (61, 17, 4, 5, 7, '保洁员完工上报', '2026-03-22 17:49:13');
INSERT INTO `order_status_log` VALUES (62, 19, 1, 3, 7, '保洁员抢单', '2026-03-22 17:49:57');
INSERT INTO `order_status_log` VALUES (63, 20, NULL, 1, 6, '顾客下单', '2026-03-22 17:59:47');
INSERT INTO `order_status_log` VALUES (64, 21, NULL, 1, 6, '顾客下单', '2026-03-22 18:00:21');
INSERT INTO `order_status_log` VALUES (65, 17, 5, 6, 6, '顾客确认完成', '2026-03-22 18:00:45');
INSERT INTO `order_status_log` VALUES (66, 20, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-22 18:01:23');
INSERT INTO `order_status_log` VALUES (67, 21, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-22 18:01:29');
INSERT INTO `order_status_log` VALUES (68, 21, 2, 3, 7, '保洁员确认接单', '2026-03-22 18:01:54');
INSERT INTO `order_status_log` VALUES (69, 21, 3, 8, 7, '保洁员取消：', '2026-03-22 18:04:25');
INSERT INTO `order_status_log` VALUES (70, 20, 2, 3, 7, '保洁员确认接单', '2026-03-22 18:04:32');
INSERT INTO `order_status_log` VALUES (71, 20, 3, 8, 7, '保洁员取消：', '2026-03-22 18:08:56');
INSERT INTO `order_status_log` VALUES (72, 22, NULL, 1, 6, '顾客下单', '2026-03-22 18:14:45');
INSERT INTO `order_status_log` VALUES (73, 22, 1, 3, 10, '保洁员抢单', '2026-03-22 18:21:21');
INSERT INTO `order_status_log` VALUES (74, 22, 3, 8, 10, '保洁员取消：', '2026-03-22 20:45:57');
INSERT INTO `order_status_log` VALUES (75, 23, NULL, 1, 6, '顾客下单', '2026-03-22 21:05:38');
INSERT INTO `order_status_log` VALUES (76, 23, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-22 21:06:10');
INSERT INTO `order_status_log` VALUES (77, 23, 2, 1, 7, '保洁员拒绝接单，退回待派单', '2026-03-22 21:06:53');
INSERT INTO `order_status_log` VALUES (78, 23, 1, 3, 10, '保洁员抢单', '2026-03-22 21:07:42');
INSERT INTO `order_status_log` VALUES (79, 23, 3, 1, 10, '保洁员取消，退回派单池：', '2026-03-22 21:08:18');
INSERT INTO `order_status_log` VALUES (80, 23, 1, 3, 10, '保洁员抢单', '2026-03-22 21:08:30');
INSERT INTO `order_status_log` VALUES (81, 15, 1, 3, 12, '保洁员抢单', '2026-03-22 23:07:51');
INSERT INTO `order_status_log` VALUES (82, 15, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-21T16:53:42），系统自动取消', '2026-03-22 23:15:53');
INSERT INTO `order_status_log` VALUES (83, 23, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-23T12:00），系统自动取消', '2026-03-23 14:17:23');
INSERT INTO `order_status_log` VALUES (84, 24, NULL, 1, 6, '顾客下单', '2026-03-23 14:42:41');
INSERT INTO `order_status_log` VALUES (85, 25, NULL, 1, 6, '顾客下单', '2026-03-23 14:43:18');
INSERT INTO `order_status_log` VALUES (86, 24, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-23 14:43:40');
INSERT INTO `order_status_log` VALUES (87, 24, 2, 3, 7, '保洁员确认接单', '2026-03-23 14:44:06');
INSERT INTO `order_status_log` VALUES (88, 25, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-23 14:46:09');
INSERT INTO `order_status_log` VALUES (89, 25, 2, 1, 7, '保洁员拒绝接单，退回待派单', '2026-03-23 14:52:29');
INSERT INTO `order_status_log` VALUES (90, 25, 1, 3, 7, '保洁员抢单', '2026-03-23 14:58:46');
INSERT INTO `order_status_log` VALUES (91, 24, 3, 4, 7, '保洁员签到打卡', '2026-03-23 14:58:55');
INSERT INTO `order_status_log` VALUES (92, 24, 4, 5, 7, '保洁员完工上报', '2026-03-23 14:58:58');
INSERT INTO `order_status_log` VALUES (93, 24, 5, 6, 6, '顾客确认完成', '2026-03-23 14:59:23');
INSERT INTO `order_status_log` VALUES (94, 25, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-23T20:00），系统自动取消', '2026-03-23 22:31:27');
INSERT INTO `order_status_log` VALUES (95, 26, NULL, 1, 6, '顾客下单', '2026-03-24 15:21:05');
INSERT INTO `order_status_log` VALUES (96, 27, NULL, 1, 6, '顾客下单', '2026-03-24 15:22:54');
INSERT INTO `order_status_log` VALUES (97, 27, 1, 2, NULL, '系统自动派单给保洁员11', '2026-03-24 15:23:04');
INSERT INTO `order_status_log` VALUES (98, 29, NULL, 1, 6, '顾客下单', '2026-03-24 15:40:27');
INSERT INTO `order_status_log` VALUES (99, 27, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-24 15:53:18');
INSERT INTO `order_status_log` VALUES (100, 30, NULL, 1, 6, '顾客下单', '2026-03-24 16:26:30');
INSERT INTO `order_status_log` VALUES (101, 29, 1, 2, NULL, '系统自动派单给保洁员11', '2026-03-24 16:26:52');
INSERT INTO `order_status_log` VALUES (102, 30, 1, 2, NULL, '系统自动派单给保洁员11', '2026-03-24 16:27:00');
INSERT INTO `order_status_log` VALUES (103, 27, 1, 2, NULL, '系统自动派单给保洁员11', '2026-03-24 16:27:10');
INSERT INTO `order_status_log` VALUES (104, 19, 3, 4, 7, '保洁员签到打卡', '2026-03-24 16:27:38');
INSERT INTO `order_status_log` VALUES (105, 19, 4, 5, 7, '保洁员完工上报', '2026-03-24 16:27:40');
INSERT INTO `order_status_log` VALUES (106, 28, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 16:37:49');
INSERT INTO `order_status_log` VALUES (107, 30, 2, 3, 11, '保洁员确认接单', '2026-03-24 16:38:14');
INSERT INTO `order_status_log` VALUES (108, 29, 2, 3, 11, '保洁员确认接单', '2026-03-24 16:38:16');
INSERT INTO `order_status_log` VALUES (109, 27, 2, 1, 11, '保洁员拒绝接单，退回待派单', '2026-03-24 16:38:21');
INSERT INTO `order_status_log` VALUES (110, 27, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 16:40:51');
INSERT INTO `order_status_log` VALUES (111, 28, 2, 3, 12, '保洁员确认接单', '2026-03-24 16:42:02');
INSERT INTO `order_status_log` VALUES (112, 28, 3, 1, 12, '保洁员取消，退回派单池', '2026-03-24 16:42:11');
INSERT INTO `order_status_log` VALUES (113, 27, 2, 3, 12, '保洁员确认接单', '2026-03-24 16:42:23');
INSERT INTO `order_status_log` VALUES (114, 28, 1, 2, NULL, '系统自动派单给保洁员10', '2026-03-24 17:01:01');
INSERT INTO `order_status_log` VALUES (115, 19, 5, 6, 6, '顾客确认完成', '2026-03-24 17:08:01');
INSERT INTO `order_status_log` VALUES (116, 33, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 17:20:13');
INSERT INTO `order_status_log` VALUES (117, 32, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 17:20:18');
INSERT INTO `order_status_log` VALUES (118, 31, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 17:20:21');
INSERT INTO `order_status_log` VALUES (119, 35, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 17:20:23');
INSERT INTO `order_status_log` VALUES (120, 34, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 17:20:27');
INSERT INTO `order_status_log` VALUES (121, 28, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-24 17:31:42');
INSERT INTO `order_status_log` VALUES (122, 32, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 17:33:32');
INSERT INTO `order_status_log` VALUES (123, 34, 1, 2, NULL, '系统自动派单给保洁员10', '2026-03-24 17:33:35');
INSERT INTO `order_status_log` VALUES (124, 32, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-24 18:04:15');
INSERT INTO `order_status_log` VALUES (125, 34, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-24 18:04:15');
INSERT INTO `order_status_log` VALUES (126, 34, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 19:14:41');
INSERT INTO `order_status_log` VALUES (127, 35, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 19:14:45');
INSERT INTO `order_status_log` VALUES (128, 33, 1, 2, NULL, '系统自动派单给保洁员11', '2026-03-24 19:14:48');
INSERT INTO `order_status_log` VALUES (129, 31, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 19:14:52');
INSERT INTO `order_status_log` VALUES (130, 32, 1, 2, NULL, '系统自动派单给保洁员11', '2026-03-24 19:14:55');
INSERT INTO `order_status_log` VALUES (131, 34, 2, 3, 12, '保洁员确认接单', '2026-03-24 19:16:37');
INSERT INTO `order_status_log` VALUES (132, 35, 2, 3, 12, '保洁员确认接单', '2026-03-24 19:16:42');
INSERT INTO `order_status_log` VALUES (133, 31, 2, 1, 12, '保洁员拒绝接单，退回待派单', '2026-03-24 19:16:44');
INSERT INTO `order_status_log` VALUES (134, 32, 2, 3, 11, '保洁员确认接单', '2026-03-24 19:17:08');
INSERT INTO `order_status_log` VALUES (135, 33, 2, 1, 11, '保洁员拒绝接单，退回待派单', '2026-03-24 19:17:10');
INSERT INTO `order_status_log` VALUES (136, 31, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 19:17:19');
INSERT INTO `order_status_log` VALUES (137, 33, 1, 2, NULL, '系统自动派单给保洁员10', '2026-03-24 19:17:22');
INSERT INTO `order_status_log` VALUES (138, 33, 2, 3, 10, '保洁员确认接单', '2026-03-24 19:17:39');
INSERT INTO `order_status_log` VALUES (139, 31, 2, 1, NULL, '派单30分钟超时，退回待派单池', '2026-03-24 19:47:37');
INSERT INTO `order_status_log` VALUES (140, 31, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 20:59:07');
INSERT INTO `order_status_log` VALUES (141, 31, 2, 1, 12, '保洁员拒绝接单，退回待派单', '2026-03-24 20:59:52');
INSERT INTO `order_status_log` VALUES (142, 34, 3, 1, 12, '保洁员取消，退回派单池', '2026-03-24 20:59:58');
INSERT INTO `order_status_log` VALUES (143, 35, 3, 1, 12, '保洁员取消，退回派单池', '2026-03-24 21:00:03');
INSERT INTO `order_status_log` VALUES (144, 27, 3, 1, 12, '保洁员取消，退回派单池', '2026-03-24 21:00:07');
INSERT INTO `order_status_log` VALUES (145, 31, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 21:01:42');
INSERT INTO `order_status_log` VALUES (146, 34, 1, 2, NULL, '系统自动派单给保洁员11', '2026-03-24 21:13:35');
INSERT INTO `order_status_log` VALUES (147, 35, 1, 2, NULL, '系统自动派单给保洁员10', '2026-03-24 21:13:39');
INSERT INTO `order_status_log` VALUES (148, 28, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 21:13:48');
INSERT INTO `order_status_log` VALUES (149, 28, 2, 3, 12, '保洁员确认接单', '2026-03-24 21:14:08');
INSERT INTO `order_status_log` VALUES (150, 28, 3, 1, 12, '保洁员取消，退回派单池', '2026-03-24 21:14:18');
INSERT INTO `order_status_log` VALUES (151, 27, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-24 21:18:13');
INSERT INTO `order_status_log` VALUES (152, 28, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-24 21:18:16');
INSERT INTO `order_status_log` VALUES (153, 27, 2, 3, 7, '保洁员确认接单', '2026-03-24 21:30:53');
INSERT INTO `order_status_log` VALUES (154, 28, 2, 1, 12, '保洁员拒绝接单，退回待派单', '2026-03-24 21:31:17');
INSERT INTO `order_status_log` VALUES (155, 31, 2, 1, 12, '保洁员拒绝接单，退回待派单', '2026-03-24 21:31:18');
INSERT INTO `order_status_log` VALUES (156, 34, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-24 21:43:54');
INSERT INTO `order_status_log` VALUES (157, 35, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-24 21:43:54');
INSERT INTO `order_status_log` VALUES (158, 41, NULL, 1, 6, '顾客下单', '2026-03-24 22:42:27');
INSERT INTO `order_status_log` VALUES (159, 41, 1, 2, NULL, '系统自动派单给保洁员10', '2026-03-24 22:42:45');
INSERT INTO `order_status_log` VALUES (160, 41, 2, 1, 10, '保洁员拒绝接单，退回待派单', '2026-03-24 22:42:58');
INSERT INTO `order_status_log` VALUES (161, 27, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-25T10:00），系统自动取消', '2026-03-25 14:25:17');
INSERT INTO `order_status_log` VALUES (162, 29, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-25T10:00），系统自动取消', '2026-03-25 14:25:17');
INSERT INTO `order_status_log` VALUES (163, 30, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-25T14:00），系统自动取消', '2026-03-25 16:00:30');
INSERT INTO `order_status_log` VALUES (164, 34, 1, 3, 14, '保洁员抢单', '2026-03-25 16:04:36');
INSERT INTO `order_status_log` VALUES (165, 41, 1, 2, NULL, '系统自动派单给保洁员14', '2026-03-25 16:09:07');
INSERT INTO `order_status_log` VALUES (166, 35, 1, 2, NULL, '系统自动派单给保洁员14', '2026-03-25 16:09:11');
INSERT INTO `order_status_log` VALUES (167, 31, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-25 16:09:15');
INSERT INTO `order_status_log` VALUES (168, 41, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-25 16:39:29');
INSERT INTO `order_status_log` VALUES (169, 35, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-25 16:39:29');
INSERT INTO `order_status_log` VALUES (170, 31, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-25 16:39:29');
INSERT INTO `order_status_log` VALUES (171, 41, 1, 2, NULL, '系统自动派单给保洁员14', '2026-03-25 17:27:57');
INSERT INTO `order_status_log` VALUES (172, 41, 2, 3, 8, '管理员手动派单', '2026-03-25 17:28:02');
INSERT INTO `order_status_log` VALUES (173, 28, 1, 3, 8, '管理员手动派单', '2026-03-25 17:28:20');
INSERT INTO `order_status_log` VALUES (174, 31, 1, 3, 8, '管理员手动派单', '2026-03-25 17:29:26');
INSERT INTO `order_status_log` VALUES (175, 35, 1, 2, NULL, '系统自动派单给保洁员14', '2026-03-25 17:29:49');
INSERT INTO `order_status_log` VALUES (176, 35, 2, 3, 8, '管理员手动派单', '2026-03-25 17:31:56');
INSERT INTO `order_status_log` VALUES (177, 28, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-25T10:00），系统自动取消', '2026-03-25 17:32:45');
INSERT INTO `order_status_log` VALUES (178, 41, 3, 1, 12, '保洁员取消，退回派单池', '2026-03-25 18:03:31');
INSERT INTO `order_status_log` VALUES (179, 35, 3, 1, 12, '保洁员取消，退回派单池', '2026-03-25 18:03:40');
INSERT INTO `order_status_log` VALUES (180, 35, 1, 3, 13, '保洁员抢单', '2026-03-25 18:04:09');
INSERT INTO `order_status_log` VALUES (181, 34, 3, 1, 14, '保洁员取消，退回派单池', '2026-03-25 18:04:33');
INSERT INTO `order_status_log` VALUES (182, 41, 1, 2, 8, '管理员手动派单', '2026-03-25 18:05:04');
INSERT INTO `order_status_log` VALUES (183, 41, 2, 1, 7, '保洁员拒绝接单，退回待派单', '2026-03-25 18:05:14');
INSERT INTO `order_status_log` VALUES (184, 41, 1, 2, 8, '管理员手动派单', '2026-03-25 18:05:25');
INSERT INTO `order_status_log` VALUES (185, 34, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-25 18:05:28');
INSERT INTO `order_status_log` VALUES (186, 41, 2, 3, 14, '保洁员确认接单', '2026-03-25 18:05:39');
INSERT INTO `order_status_log` VALUES (187, 34, 2, 3, 13, '保洁员确认接单', '2026-03-25 18:05:49');
INSERT INTO `order_status_log` VALUES (188, 31, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-26T09:00），系统自动取消', '2026-03-26 14:46:07');
INSERT INTO `order_status_log` VALUES (189, 32, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-26T09:30），系统自动取消', '2026-03-26 14:46:07');
INSERT INTO `order_status_log` VALUES (190, 34, 3, 8, 6, '顾客报告保洁员未到场', '2026-03-26 14:48:01');
INSERT INTO `order_status_log` VALUES (191, 33, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-26T13:00），系统自动取消', '2026-03-26 15:01:07');
INSERT INTO `order_status_log` VALUES (192, 42, NULL, 1, NULL, '外部平台导入', '2026-03-26 15:56:53');
INSERT INTO `order_status_log` VALUES (193, 43, NULL, 1, NULL, '外部平台导入', '2026-03-26 15:56:53');
INSERT INTO `order_status_log` VALUES (194, 44, NULL, 1, NULL, '外部平台导入', '2026-03-26 15:56:53');
INSERT INTO `order_status_log` VALUES (195, 45, NULL, 1, NULL, '外部平台导入', '2026-03-26 15:56:53');
INSERT INTO `order_status_log` VALUES (196, 46, NULL, 1, NULL, '外部平台导入', '2026-03-26 18:14:57');
INSERT INTO `order_status_log` VALUES (197, 47, NULL, 1, NULL, '外部平台导入', '2026-03-26 18:14:57');
INSERT INTO `order_status_log` VALUES (198, 48, NULL, 1, NULL, '外部平台导入', '2026-03-26 18:14:57');
INSERT INTO `order_status_log` VALUES (199, 49, NULL, 1, NULL, '外部平台导入', '2026-03-26 18:14:57');
INSERT INTO `order_status_log` VALUES (200, 46, 1, 2, NULL, '系统自动派单给保洁员10', '2026-03-26 18:15:27');
INSERT INTO `order_status_log` VALUES (201, 35, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-26T16:30），系统自动取消', '2026-03-26 18:30:16');
INSERT INTO `order_status_log` VALUES (202, 46, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-26 19:49:43');
INSERT INTO `order_status_log` VALUES (203, 46, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-26 19:50:06');
INSERT INTO `order_status_log` VALUES (204, 48, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-26 19:50:57');
INSERT INTO `order_status_log` VALUES (205, 48, 2, 3, 7, '保洁员确认接单', '2026-03-26 19:51:05');
INSERT INTO `order_status_log` VALUES (206, 50, NULL, 1, NULL, '外部平台导入', '2026-03-26 20:11:47');
INSERT INTO `order_status_log` VALUES (207, 51, NULL, 1, NULL, '外部平台导入', '2026-03-26 20:11:47');
INSERT INTO `order_status_log` VALUES (208, 52, NULL, 1, NULL, '外部平台导入', '2026-03-26 20:11:47');
INSERT INTO `order_status_log` VALUES (209, 53, NULL, 1, NULL, '外部平台导入', '2026-03-26 20:11:47');
INSERT INTO `order_status_log` VALUES (210, 53, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-26 20:11:57');
INSERT INTO `order_status_log` VALUES (211, 51, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-26 20:12:07');
INSERT INTO `order_status_log` VALUES (212, 50, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-26 20:12:11');
INSERT INTO `order_status_log` VALUES (213, 51, 2, 3, 13, '保洁员确认接单', '2026-03-26 20:12:28');
INSERT INTO `order_status_log` VALUES (214, 53, 2, 1, 13, '保洁员拒绝接单，退回待派单', '2026-03-26 20:12:33');
INSERT INTO `order_status_log` VALUES (215, 46, 2, 1, 13, '保洁员拒绝接单，退回待派单', '2026-03-26 20:12:35');
INSERT INTO `order_status_log` VALUES (216, 50, 2, 1, 13, '保洁员拒绝接单，退回待派单', '2026-03-26 20:12:38');
INSERT INTO `order_status_log` VALUES (217, 49, 1, 3, 13, '保洁员抢单', '2026-03-26 20:36:18');
INSERT INTO `order_status_log` VALUES (218, 46, 1, 3, 13, '保洁员抢单', '2026-03-26 20:51:16');
INSERT INTO `order_status_log` VALUES (219, 53, 1, 2, 8, '管理员手动派单', '2026-03-26 20:51:52');
INSERT INTO `order_status_log` VALUES (220, 54, 1, 3, 7, '测试接单', '2026-03-26 21:12:28');
INSERT INTO `order_status_log` VALUES (221, 53, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-26 21:22:12');
INSERT INTO `order_status_log` VALUES (222, 41, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-27T10:00），系统自动取消', '2026-03-27 14:26:18');
INSERT INTO `order_status_log` VALUES (223, 46, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-27T09:00），系统自动取消', '2026-03-27 14:26:18');
INSERT INTO `order_status_log` VALUES (224, 54, 3, 9, 6, '顾客申请改期', '2026-03-27 15:40:57');
INSERT INTO `order_status_log` VALUES (225, 54, 9, 3, 7, '保洁员同意改期', '2026-03-27 15:41:14');
INSERT INTO `order_status_log` VALUES (226, 55, NULL, 1, 6, '顾客下单', '2026-03-27 16:05:44');
INSERT INTO `order_status_log` VALUES (227, 55, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-27 16:07:36');
INSERT INTO `order_status_log` VALUES (228, 55, 2, 3, 13, '保洁员确认接单', '2026-03-27 16:07:45');
INSERT INTO `order_status_log` VALUES (229, 55, 3, 4, 13, '保洁员签到打卡', '2026-03-27 16:07:53');
INSERT INTO `order_status_log` VALUES (230, 55, 4, 5, 13, '保洁员完工上报', '2026-03-27 16:07:56');
INSERT INTO `order_status_log` VALUES (231, 55, 5, 6, 6, '顾客确认完成', '2026-03-27 16:08:10');
INSERT INTO `order_status_log` VALUES (232, 55, 6, 7, 6, '顾客完成后发起投诉', '2026-03-27 16:09:04');
INSERT INTO `order_status_log` VALUES (233, 56, NULL, 1, 6, '顾客下单', '2026-03-27 16:31:39');
INSERT INTO `order_status_log` VALUES (234, 56, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-27 16:32:03');
INSERT INTO `order_status_log` VALUES (235, 56, 2, 3, 7, '保洁员确认接单', '2026-03-27 16:32:10');
INSERT INTO `order_status_log` VALUES (236, 56, 3, 4, 7, '保洁员签到打卡', '2026-03-27 16:32:16');
INSERT INTO `order_status_log` VALUES (237, 56, 4, 5, 7, '保洁员完工上报', '2026-03-27 16:32:20');
INSERT INTO `order_status_log` VALUES (238, 56, 5, 6, 6, '顾客确认完成', '2026-03-27 16:33:08');
INSERT INTO `order_status_log` VALUES (239, 57, NULL, 1, 6, '顾客下单', '2026-03-27 16:42:30');
INSERT INTO `order_status_log` VALUES (240, 57, 1, 2, NULL, '系统自动派单给保洁员11', '2026-03-27 16:44:03');
INSERT INTO `order_status_log` VALUES (241, 57, 2, 3, 11, '保洁员确认接单', '2026-03-27 16:45:58');
INSERT INTO `order_status_log` VALUES (242, 57, 3, 4, 11, '保洁员签到打卡', '2026-03-27 16:46:04');
INSERT INTO `order_status_log` VALUES (243, 57, 4, 5, 11, '保洁员完工上报', '2026-03-27 16:46:06');
INSERT INTO `order_status_log` VALUES (244, 57, 5, 6, 6, '顾客确认完成', '2026-03-27 16:46:25');
INSERT INTO `order_status_log` VALUES (245, 53, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-27 16:52:22');
INSERT INTO `order_status_log` VALUES (246, 53, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-27 17:22:46');
INSERT INTO `order_status_log` VALUES (247, 51, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-28T09:00），系统自动取消', '2026-03-28 12:35:08');
INSERT INTO `order_status_log` VALUES (248, 53, 1, 2, 8, '管理员手动派单', '2026-03-28 12:50:01');
INSERT INTO `order_status_log` VALUES (249, 53, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-28 13:20:44');
INSERT INTO `order_status_log` VALUES (250, 58, NULL, 1, 6, '顾客下单', '2026-03-28 14:17:30');
INSERT INTO `order_status_log` VALUES (251, 58, 1, 8, 6, '顾客取消：', '2026-03-28 14:17:46');
INSERT INTO `order_status_log` VALUES (252, 59, NULL, 1, 6, '顾客下单', '2026-03-28 14:18:14');
INSERT INTO `order_status_log` VALUES (253, 59, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-28 14:18:40');
INSERT INTO `order_status_log` VALUES (254, 59, 2, 2, 8, '管理员手动派单', '2026-03-28 14:19:01');
INSERT INTO `order_status_log` VALUES (255, 59, 2, 3, 14, '保洁员确认接单', '2026-03-28 14:19:26');
INSERT INTO `order_status_log` VALUES (256, 59, 3, 4, 14, '保洁员签到打卡', '2026-03-28 14:19:50');
INSERT INTO `order_status_log` VALUES (257, 59, 4, 5, 14, '保洁员完工上报', '2026-03-28 14:19:53');
INSERT INTO `order_status_log` VALUES (258, 59, 5, 6, 6, '顾客确认完成', '2026-03-28 14:20:07');
INSERT INTO `order_status_log` VALUES (259, 48, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-29T14:00），系统自动取消', '2026-03-30 08:01:22');
INSERT INTO `order_status_log` VALUES (260, 60, NULL, 1, NULL, '外部平台导入', '2026-03-30 14:38:10');
INSERT INTO `order_status_log` VALUES (261, 61, NULL, 1, NULL, '外部平台导入', '2026-03-30 14:38:10');
INSERT INTO `order_status_log` VALUES (262, 62, NULL, 1, NULL, '外部平台导入', '2026-03-30 14:38:11');
INSERT INTO `order_status_log` VALUES (263, 63, NULL, 1, NULL, '外部平台导入', '2026-03-30 14:38:11');
INSERT INTO `order_status_log` VALUES (264, 63, 1, 2, NULL, '系统自动派单给保洁员10', '2026-03-30 14:38:15');
INSERT INTO `order_status_log` VALUES (265, 63, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-30 15:08:52');
INSERT INTO `order_status_log` VALUES (266, 49, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-30T15:00），系统自动取消', '2026-03-30 18:40:09');
INSERT INTO `order_status_log` VALUES (267, 62, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-30 18:58:02');
INSERT INTO `order_status_log` VALUES (268, 60, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-30 18:58:07');
INSERT INTO `order_status_log` VALUES (269, 62, 2, 2, 8, '管理员手动派单', '2026-03-30 18:58:16');
INSERT INTO `order_status_log` VALUES (270, 63, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-30 18:58:18');
INSERT INTO `order_status_log` VALUES (271, 47, 1, 3, 7, '保洁员抢单', '2026-03-30 19:17:47');
INSERT INTO `order_status_log` VALUES (272, 47, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-28T10:00），系统自动取消', '2026-03-30 19:25:09');
INSERT INTO `order_status_log` VALUES (273, 62, 2, 1, NULL, '派单30分钟超时，退回待派单池', '2026-03-30 19:28:09');
INSERT INTO `order_status_log` VALUES (274, 60, 2, 1, NULL, '派单30分钟超时，退回待派单池', '2026-03-30 19:28:09');
INSERT INTO `order_status_log` VALUES (275, 63, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-03-30 19:28:52');
INSERT INTO `order_status_log` VALUES (276, 26, 1, 8, NULL, '预约时间 2026-03-24T20:00 已过，无人接单，系统自动取消退款', '2026-03-30 22:16:14');
INSERT INTO `order_status_log` VALUES (277, 42, 1, 8, NULL, '预约时间 2026-03-27T01:00 已过，无人接单，系统自动取消退款', '2026-03-30 22:16:14');
INSERT INTO `order_status_log` VALUES (278, 43, 1, 8, NULL, '预约时间 2026-03-28T02:00 已过，无人接单，系统自动取消退款', '2026-03-30 22:16:14');
INSERT INTO `order_status_log` VALUES (279, 44, 1, 8, NULL, '预约时间 2026-03-29T06:00 已过，无人接单，系统自动取消退款', '2026-03-30 22:16:14');
INSERT INTO `order_status_log` VALUES (280, 45, 1, 8, NULL, '预约时间 2026-03-30T07:00 已过，无人接单，系统自动取消退款', '2026-03-30 22:16:14');
INSERT INTO `order_status_log` VALUES (281, 50, 1, 8, NULL, '预约时间 2026-03-27T15:00 已过，无人接单，系统自动取消退款', '2026-03-30 22:16:14');
INSERT INTO `order_status_log` VALUES (282, 52, 1, 8, NULL, '预约时间 2026-03-29T14:00 已过，无人接单，系统自动取消退款', '2026-03-30 22:16:14');
INSERT INTO `order_status_log` VALUES (283, 53, 1, 8, NULL, '预约时间 2026-03-30T10:00 已过，无人接单，系统自动取消退款', '2026-03-30 22:16:14');
INSERT INTO `order_status_log` VALUES (284, 62, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-30 22:36:41');
INSERT INTO `order_status_log` VALUES (285, 60, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-30 22:36:50');
INSERT INTO `order_status_log` VALUES (286, 60, 2, 2, 8, '管理员手动派单', '2026-03-30 22:36:58');
INSERT INTO `order_status_log` VALUES (287, 62, 2, 2, 8, '管理员手动派单', '2026-03-30 22:37:04');
INSERT INTO `order_status_log` VALUES (288, 60, 2, 2, 8, '管理员手动派单', '2026-03-30 22:37:10');
INSERT INTO `order_status_log` VALUES (289, 62, 2, 3, 7, '保洁员确认接单', '2026-03-30 22:37:23');
INSERT INTO `order_status_log` VALUES (290, 60, 2, 3, 14, '保洁员确认接单', '2026-03-30 22:37:31');
INSERT INTO `order_status_log` VALUES (291, 61, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-30 22:38:19');
INSERT INTO `order_status_log` VALUES (292, 63, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-30 22:38:28');
INSERT INTO `order_status_log` VALUES (293, 63, 2, 3, 13, '保洁员确认接单', '2026-03-30 22:41:00');
INSERT INTO `order_status_log` VALUES (294, 61, 2, 3, 13, '保洁员确认接单', '2026-03-30 22:41:01');
INSERT INTO `order_status_log` VALUES (295, 54, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-31T10:00），系统自动取消', '2026-03-31 12:34:18');
INSERT INTO `order_status_log` VALUES (296, 60, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-03-31T09:00），系统自动取消', '2026-03-31 12:34:18');
INSERT INTO `order_status_log` VALUES (297, 64, NULL, 1, 6, '顾客下单', '2026-03-31 12:41:38');
INSERT INTO `order_status_log` VALUES (298, 64, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-31 12:42:19');
INSERT INTO `order_status_log` VALUES (299, 64, 2, 3, 7, '保洁员确认接单', '2026-03-31 12:42:29');
INSERT INTO `order_status_log` VALUES (300, 65, NULL, 1, NULL, '外部平台导入', '2026-03-31 14:52:10');
INSERT INTO `order_status_log` VALUES (301, 66, NULL, 1, NULL, '外部平台导入', '2026-03-31 14:52:10');
INSERT INTO `order_status_log` VALUES (302, 65, 1, 2, NULL, '系统自动派单给保洁员7', '2026-03-31 14:52:10');
INSERT INTO `order_status_log` VALUES (303, 67, NULL, 1, NULL, '外部平台导入', '2026-03-31 14:52:10');
INSERT INTO `order_status_log` VALUES (304, 68, NULL, 1, NULL, '外部平台导入', '2026-03-31 14:52:10');
INSERT INTO `order_status_log` VALUES (305, 65, 2, 3, 7, '保洁员确认接单', '2026-03-31 14:53:02');
INSERT INTO `order_status_log` VALUES (306, 69, NULL, 1, 6, '顾客下单', '2026-03-31 15:36:59');
INSERT INTO `order_status_log` VALUES (307, 69, 1, 2, NULL, '系统自动派单给保洁员13', '2026-03-31 15:37:20');
INSERT INTO `order_status_log` VALUES (308, 69, 2, 3, 13, '保洁员确认接单', '2026-03-31 15:37:31');
INSERT INTO `order_status_log` VALUES (309, 70, NULL, 1, 6, '顾客下单', '2026-03-31 15:39:57');
INSERT INTO `order_status_log` VALUES (310, 70, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-31 15:50:50');
INSERT INTO `order_status_log` VALUES (311, 70, 2, 3, 12, '保洁员确认接单', '2026-03-31 15:50:56');
INSERT INTO `order_status_log` VALUES (312, 70, 3, 9, 6, '顾客申请改期', '2026-03-31 15:51:33');
INSERT INTO `order_status_log` VALUES (313, 70, 9, 3, 12, '保洁员同意改期', '2026-03-31 15:51:53');
INSERT INTO `order_status_log` VALUES (314, 70, 3, 4, 12, '保洁员签到打卡', '2026-03-31 16:15:02');
INSERT INTO `order_status_log` VALUES (315, 70, 4, 5, 12, '保洁员完工上报', '2026-03-31 16:15:05');
INSERT INTO `order_status_log` VALUES (316, 69, 3, 8, 6, '顾客报告保洁员未到场', '2026-03-31 17:23:12');
INSERT INTO `order_status_log` VALUES (317, 71, NULL, 1, 6, '顾客下单', '2026-03-31 17:23:45');
INSERT INTO `order_status_log` VALUES (318, 71, 1, 2, NULL, '系统自动派单给保洁员11', '2026-03-31 17:24:21');
INSERT INTO `order_status_log` VALUES (319, 71, 2, 3, 11, '保洁员确认接单', '2026-03-31 17:24:38');
INSERT INTO `order_status_log` VALUES (320, 67, 1, 3, 11, '保洁员抢单', '2026-03-31 17:26:40');
INSERT INTO `order_status_log` VALUES (321, 70, 5, 6, 6, '顾客确认完成', '2026-03-31 18:10:59');
INSERT INTO `order_status_log` VALUES (322, 71, 3, 8, 6, '顾客报告保洁员未到场', '2026-03-31 18:11:11');
INSERT INTO `order_status_log` VALUES (323, 64, 3, 8, 6, '顾客报告保洁员未到场', '2026-03-31 18:11:36');
INSERT INTO `order_status_log` VALUES (324, 72, NULL, 1, 6, '顾客下单', '2026-03-31 18:58:32');
INSERT INTO `order_status_log` VALUES (325, 67, 3, 1, 11, '保洁员取消，退回派单池', '2026-03-31 18:59:58');
INSERT INTO `order_status_log` VALUES (326, 72, 1, 2, NULL, '系统自动派单给保洁员14', '2026-03-31 19:01:12');
INSERT INTO `order_status_log` VALUES (327, 72, 2, 3, 14, '保洁员确认接单', '2026-03-31 19:01:21');
INSERT INTO `order_status_log` VALUES (328, 67, 1, 3, 14, '保洁员抢单', '2026-03-31 19:09:59');
INSERT INTO `order_status_log` VALUES (329, 72, 3, 4, 14, '保洁员签到打卡', '2026-03-31 19:55:04');
INSERT INTO `order_status_log` VALUES (330, 72, 4, 5, 14, '保洁员完工上报', '2026-03-31 19:55:32');
INSERT INTO `order_status_log` VALUES (331, 66, 1, 2, NULL, '系统自动派单给保洁员10', '2026-03-31 19:55:44');
INSERT INTO `order_status_log` VALUES (332, 68, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-31 19:56:08');
INSERT INTO `order_status_log` VALUES (333, 66, 1, 2, NULL, '系统自动派单给保洁员10', '2026-03-31 20:06:25');
INSERT INTO `order_status_log` VALUES (334, 68, 1, 2, NULL, '系统自动派单给保洁员12', '2026-03-31 20:06:28');
INSERT INTO `order_status_log` VALUES (335, 68, 2, 3, 12, '保洁员确认接单', '2026-03-31 20:06:51');
INSERT INTO `order_status_log` VALUES (336, 66, 2, 3, 10, '保洁员确认接单', '2026-03-31 20:07:09');
INSERT INTO `order_status_log` VALUES (337, 72, 5, 6, 6, '顾客确认完成', '2026-03-31 20:07:41');
INSERT INTO `order_status_log` VALUES (338, 61, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-01T10:00），系统自动取消', '2026-04-01 13:41:31');
INSERT INTO `order_status_log` VALUES (339, 65, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-01T14:00），系统自动取消', '2026-04-01 18:01:57');
INSERT INTO `order_status_log` VALUES (340, 72, 6, 7, 6, '顾客完成后发起投诉', '2026-04-01 22:17:06');
INSERT INTO `order_status_log` VALUES (341, 72, 7, 6, 8, '投诉处理：部分退款 ¥11，订单完成', '2026-04-01 22:18:41');
INSERT INTO `order_status_log` VALUES (342, 70, 6, 7, 6, '顾客完成后发起投诉', '2026-04-01 22:38:49');
INSERT INTO `order_status_log` VALUES (343, 70, 7, 6, 8, '投诉处理：部分退款 ¥23，订单完成', '2026-04-01 22:39:22');
INSERT INTO `order_status_log` VALUES (344, 62, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-02T10:00），系统自动取消', '2026-04-02 13:18:59');
INSERT INTO `order_status_log` VALUES (345, 66, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-02T14:00），系统自动取消', '2026-04-02 16:03:59');
INSERT INTO `order_status_log` VALUES (346, 67, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-03T10:00），系统自动取消', '2026-04-03 15:32:06');
INSERT INTO `order_status_log` VALUES (347, 63, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-03T14:00），系统自动取消', '2026-04-04 19:26:56');
INSERT INTO `order_status_log` VALUES (348, 68, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-04T09:00），系统自动取消', '2026-04-04 19:26:56');
INSERT INTO `order_status_log` VALUES (349, 73, NULL, 1, 6, '顾客下单', '2026-04-07 14:00:29');
INSERT INTO `order_status_log` VALUES (350, 73, 1, 2, NULL, '系统自动派单给保洁员11', '2026-04-07 14:00:47');
INSERT INTO `order_status_log` VALUES (351, 74, NULL, 1, NULL, '外部平台导入', '2026-04-07 14:01:23');
INSERT INTO `order_status_log` VALUES (352, 75, NULL, 1, NULL, '外部平台导入', '2026-04-07 14:01:23');
INSERT INTO `order_status_log` VALUES (353, 76, NULL, 1, NULL, '外部平台导入', '2026-04-07 14:01:23');
INSERT INTO `order_status_log` VALUES (354, 77, NULL, 1, NULL, '外部平台导入', '2026-04-07 14:01:23');
INSERT INTO `order_status_log` VALUES (355, 77, 1, 2, NULL, '系统自动派单给保洁员11', '2026-04-07 14:01:27');
INSERT INTO `order_status_log` VALUES (356, 74, 1, 2, NULL, '系统自动派单给保洁员11', '2026-04-07 14:01:31');
INSERT INTO `order_status_log` VALUES (357, 75, 1, 2, NULL, '系统自动派单给保洁员13', '2026-04-07 14:01:35');
INSERT INTO `order_status_log` VALUES (358, 76, 1, 2, NULL, '系统自动派单给保洁员11', '2026-04-07 14:01:38');
INSERT INTO `order_status_log` VALUES (359, 75, 2, 3, 13, '保洁员确认接单', '2026-04-07 14:02:26');
INSERT INTO `order_status_log` VALUES (360, 74, 2, 3, 11, '保洁员确认接单', '2026-04-07 14:02:37');
INSERT INTO `order_status_log` VALUES (361, 76, 2, 3, 11, '保洁员确认接单', '2026-04-07 14:02:38');
INSERT INTO `order_status_log` VALUES (362, 77, 2, 3, 11, '保洁员确认接单', '2026-04-07 14:02:39');
INSERT INTO `order_status_log` VALUES (363, 73, 2, 3, 11, '保洁员确认接单', '2026-04-07 14:02:40');
INSERT INTO `order_status_log` VALUES (364, 78, NULL, 1, NULL, '外部平台导入', '2026-04-07 14:05:31');
INSERT INTO `order_status_log` VALUES (365, 79, NULL, 1, NULL, '外部平台导入', '2026-04-07 14:05:31');
INSERT INTO `order_status_log` VALUES (366, 80, NULL, 1, NULL, '外部平台导入', '2026-04-07 14:05:31');
INSERT INTO `order_status_log` VALUES (367, 81, NULL, 1, NULL, '外部平台导入', '2026-04-07 14:05:32');
INSERT INTO `order_status_log` VALUES (368, 81, 1, 2, NULL, '系统自动派单给保洁员7', '2026-04-07 14:05:36');
INSERT INTO `order_status_log` VALUES (369, 81, 2, 3, 7, '保洁员确认接单', '2026-04-07 14:06:30');
INSERT INTO `order_status_log` VALUES (370, 78, 1, 2, 8, '管理员手动派单', '2026-04-07 14:06:49');
INSERT INTO `order_status_log` VALUES (377, 80, 1, 2, NULL, '系统自动派单给保洁员13', '2026-04-07 14:13:36');
INSERT INTO `order_status_log` VALUES (378, 78, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-04-07 14:37:11');
INSERT INTO `order_status_log` VALUES (379, 80, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-04-07 14:44:11');
INSERT INTO `order_status_log` VALUES (380, 73, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-07T15:00），系统自动取消', '2026-04-07 17:13:12');
INSERT INTO `order_status_log` VALUES (381, 82, NULL, 1, 6, '顾客下单', '2026-04-07 23:36:20');
INSERT INTO `order_status_log` VALUES (382, 83, NULL, 1, 6, '顾客下单', '2026-04-07 23:58:43');
INSERT INTO `order_status_log` VALUES (383, 83, 1, 8, NULL, '预约时间 2026-04-08T00:10:18 已过，无人接单，系统自动取消退款', '2026-04-08 00:25:39');
INSERT INTO `order_status_log` VALUES (384, 84, NULL, 1, 6, '顾客下单', '2026-04-08 01:00:40');
INSERT INTO `order_status_log` VALUES (385, 84, 1, 3, 7, '保洁员抢单', '2026-04-08 01:00:56');
INSERT INTO `order_status_log` VALUES (386, 84, 3, 4, 7, '保洁员签到打卡', '2026-04-08 01:07:21');
INSERT INTO `order_status_log` VALUES (387, 84, 4, 5, 7, '保洁员完工上报', '2026-04-08 01:07:32');
INSERT INTO `order_status_log` VALUES (388, 84, 5, 6, 6, '顾客确认完成', '2026-04-08 01:10:03');
INSERT INTO `order_status_log` VALUES (389, 85, NULL, 1, 6, '顾客下单', '2026-04-08 01:33:14');
INSERT INTO `order_status_log` VALUES (390, 85, 1, 3, 11, '保洁员抢单', '2026-04-08 01:34:07');
INSERT INTO `order_status_log` VALUES (391, 85, 3, 4, 11, '保洁员签到打卡', '2026-04-08 01:34:27');
INSERT INTO `order_status_log` VALUES (392, 85, 4, 5, 11, '保洁员完工上报', '2026-04-08 01:34:59');
INSERT INTO `order_status_log` VALUES (393, 85, 5, 6, 6, '顾客确认完成', '2026-04-08 01:36:10');
INSERT INTO `order_status_log` VALUES (394, 86, NULL, 1, 6, '顾客下单', '2026-04-08 01:40:34');
INSERT INTO `order_status_log` VALUES (395, 86, 1, 3, 13, '保洁员抢单', '2026-04-08 01:41:13');
INSERT INTO `order_status_log` VALUES (396, 86, 3, 4, 13, '保洁员签到打卡', '2026-04-08 01:41:37');
INSERT INTO `order_status_log` VALUES (397, 86, 4, 5, 13, '保洁员完工上报', '2026-04-08 01:41:45');
INSERT INTO `order_status_log` VALUES (398, 86, 5, 6, 6, '顾客确认完成', '2026-04-08 01:44:46');
INSERT INTO `order_status_log` VALUES (399, 87, NULL, 1, 6, '顾客下单', '2026-04-08 01:45:26');
INSERT INTO `order_status_log` VALUES (400, 87, 1, 3, 10, '保洁员抢单', '2026-04-08 01:45:55');
INSERT INTO `order_status_log` VALUES (401, 87, 3, 4, 10, '保洁员签到打卡', '2026-04-08 01:46:34');
INSERT INTO `order_status_log` VALUES (402, 87, 4, 5, 10, '保洁员完工上报', '2026-04-08 01:46:42');
INSERT INTO `order_status_log` VALUES (403, 87, 5, 6, 6, '顾客确认完成', '2026-04-08 01:47:12');
INSERT INTO `order_status_log` VALUES (404, 88, NULL, 1, 6, '顾客下单', '2026-04-08 01:51:51');
INSERT INTO `order_status_log` VALUES (405, 88, 1, 3, 12, '保洁员抢单', '2026-04-08 01:52:18');
INSERT INTO `order_status_log` VALUES (406, 88, 3, 4, 12, '保洁员签到打卡', '2026-04-08 01:52:35');
INSERT INTO `order_status_log` VALUES (407, 88, 4, 5, 12, '保洁员完工上报', '2026-04-08 01:53:09');
INSERT INTO `order_status_log` VALUES (408, 88, 5, 6, 6, '顾客确认完成', '2026-04-08 01:53:32');
INSERT INTO `order_status_log` VALUES (409, 89, NULL, 1, 6, '顾客下单', '2026-04-08 01:56:47');
INSERT INTO `order_status_log` VALUES (410, 89, 1, 3, 14, '保洁员抢单', '2026-04-08 01:57:46');
INSERT INTO `order_status_log` VALUES (411, 90, NULL, 1, 6, '顾客下单', '2026-04-08 01:58:41');
INSERT INTO `order_status_log` VALUES (412, 90, 1, 2, NULL, '系统自动派单给保洁员13', '2026-04-08 01:58:52');
INSERT INTO `order_status_log` VALUES (413, 90, 2, 3, 13, '保洁员确认接单', '2026-04-08 01:59:24');
INSERT INTO `order_status_log` VALUES (414, 90, 3, 9, 6, '顾客申请改期', '2026-04-08 01:59:59');
INSERT INTO `order_status_log` VALUES (415, 90, 9, 3, 13, '保洁员同意改期', '2026-04-08 02:00:23');
INSERT INTO `order_status_log` VALUES (416, 90, 3, 9, 6, '顾客申请改期', '2026-04-08 02:06:10');
INSERT INTO `order_status_log` VALUES (417, 90, 9, 3, 13, '保洁员同意改期', '2026-04-08 02:06:46');
INSERT INTO `order_status_log` VALUES (418, 90, 3, 9, 6, '顾客申请改期', '2026-04-08 02:07:06');
INSERT INTO `order_status_log` VALUES (419, 90, 9, 3, 13, '保洁员拒绝改期', '2026-04-08 02:07:33');
INSERT INTO `order_status_log` VALUES (420, 89, 3, 4, 14, '保洁员签到打卡', '2026-04-08 02:31:26');
INSERT INTO `order_status_log` VALUES (421, 89, 4, 5, 14, '保洁员完工上报', '2026-04-08 02:31:33');
INSERT INTO `order_status_log` VALUES (422, 89, 5, 6, 6, '顾客确认完成', '2026-04-08 02:31:47');
INSERT INTO `order_status_log` VALUES (423, 89, 6, 7, 6, '顾客完成后发起投诉', '2026-04-08 02:32:06');
INSERT INTO `order_status_log` VALUES (424, 89, 7, 1, 8, '投诉处理：免费重做，重新待派单', '2026-04-08 02:35:22');
INSERT INTO `order_status_log` VALUES (425, 89, 1, 8, NULL, '预约时间 2026-04-08T02:04:23 已过，无人接单，系统自动取消退款', '2026-04-08 02:35:38');
INSERT INTO `order_status_log` VALUES (426, 88, 6, 7, 6, '顾客完成后发起投诉', '2026-04-08 02:37:19');
INSERT INTO `order_status_log` VALUES (427, 88, 7, 6, 8, '投诉处理：部分退款 ¥2，订单完成', '2026-04-08 02:37:37');
INSERT INTO `order_status_log` VALUES (428, 87, 6, 7, 6, '顾客完成后发起投诉', '2026-04-08 02:38:17');
INSERT INTO `order_status_log` VALUES (429, 87, 7, 6, 8, '投诉处理：全额退款，订单完成', '2026-04-08 02:38:34');
INSERT INTO `order_status_log` VALUES (430, 86, 6, 7, 6, '顾客完成后发起投诉', '2026-04-08 02:39:32');
INSERT INTO `order_status_log` VALUES (431, 86, 7, 6, 8, '投诉处理：全额退款，订单完成', '2026-04-08 02:39:56');
INSERT INTO `order_status_log` VALUES (432, 85, 6, 7, 6, '顾客完成后发起投诉', '2026-04-08 02:40:40');
INSERT INTO `order_status_log` VALUES (433, 85, 7, 6, 8, '投诉处理：驳回，订单恢复完成', '2026-04-08 02:40:56');
INSERT INTO `order_status_log` VALUES (434, 84, 6, 7, 6, '顾客完成后发起投诉', '2026-04-08 02:56:33');
INSERT INTO `order_status_log` VALUES (435, 84, 7, 1, 8, '投诉处理：免费重做，重新待派单', '2026-04-08 02:58:00');
INSERT INTO `order_status_log` VALUES (436, 84, 1, 2, NULL, '系统自动派单给保洁员13', '2026-04-08 02:58:28');
INSERT INTO `order_status_log` VALUES (437, 84, 2, 3, 13, '保洁员确认接单', '2026-04-08 02:59:14');
INSERT INTO `order_status_log` VALUES (438, 91, NULL, 1, 6, '顾客下单', '2026-04-08 03:54:40');
INSERT INTO `order_status_log` VALUES (439, 91, 1, 2, NULL, '系统自动派单给保洁员14', '2026-04-08 03:54:57');
INSERT INTO `order_status_log` VALUES (440, 91, 2, 3, 14, '保洁员确认接单', '2026-04-08 03:55:23');
INSERT INTO `order_status_log` VALUES (441, 91, 3, 4, 14, '保洁员签到打卡', '2026-04-08 03:55:30');
INSERT INTO `order_status_log` VALUES (442, 91, 4, 5, 14, '保洁员完工上报', '2026-04-08 03:58:59');
INSERT INTO `order_status_log` VALUES (443, 92, NULL, 1, 6, '顾客下单', '2026-04-08 04:00:01');
INSERT INTO `order_status_log` VALUES (444, 92, 1, 2, NULL, '系统自动派单给保洁员7', '2026-04-08 04:00:14');
INSERT INTO `order_status_log` VALUES (445, 92, 2, 3, 7, '保洁员确认接单', '2026-04-08 04:00:22');
INSERT INTO `order_status_log` VALUES (446, 92, 3, 4, 7, '保洁员签到打卡', '2026-04-08 04:00:30');
INSERT INTO `order_status_log` VALUES (447, 92, 4, 5, 7, '保洁员完工上报', '2026-04-08 04:00:57');
INSERT INTO `order_status_log` VALUES (448, 82, 1, 8, NULL, '预约时间 2026-04-08T11:00 已过，无人接单，系统自动取消退款', '2026-04-08 13:12:45');
INSERT INTO `order_status_log` VALUES (449, 84, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-08T09:57:46），系统自动取消', '2026-04-08 13:12:45');
INSERT INTO `order_status_log` VALUES (450, 90, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-08T07:00），系统自动取消', '2026-04-08 13:12:45');
INSERT INTO `order_status_log` VALUES (451, 78, 1, 8, NULL, '预约时间 2026-04-08T14:00 已过，无人接单，系统自动取消退款', '2026-04-08 14:00:56');
INSERT INTO `order_status_log` VALUES (452, 74, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-08T14:00），系统自动取消', '2026-04-08 16:12:46');
INSERT INTO `order_status_log` VALUES (453, 75, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-09T10:00），系统自动取消', '2026-04-09 12:09:38');
INSERT INTO `order_status_log` VALUES (454, 93, NULL, 1, 45, '顾客下单', '2026-04-09 12:52:56');
INSERT INTO `order_status_log` VALUES (455, 93, 1, 2, NULL, '系统自动派单给保洁员12', '2026-04-09 12:53:24');
INSERT INTO `order_status_log` VALUES (456, 93, 2, 8, NULL, '预约时间 2026-04-09T12:59:21 已过，无人接单，系统自动取消退款', '2026-04-09 13:00:56');
INSERT INTO `order_status_log` VALUES (457, 79, 1, 8, NULL, '预约时间 2026-04-09T14:00 已过，无人接单，系统自动取消退款', '2026-04-09 14:00:56');
INSERT INTO `order_status_log` VALUES (458, 80, 1, 2, NULL, '系统自动派单给保洁员13', '2026-04-09 14:16:34');
INSERT INTO `order_status_log` VALUES (459, 94, NULL, 1, 45, '顾客下单', '2026-04-09 14:20:36');
INSERT INTO `order_status_log` VALUES (460, 94, 1, 2, NULL, '系统自动派单给保洁员12', '2026-04-09 14:20:51');
INSERT INTO `order_status_log` VALUES (461, 94, 2, 3, 12, '保洁员确认接单', '2026-04-09 14:22:03');
INSERT INTO `order_status_log` VALUES (462, 94, 3, 4, 12, '保洁员签到打卡', '2026-04-09 14:23:12');
INSERT INTO `order_status_log` VALUES (463, 94, 4, 5, 12, '保洁员完工上报', '2026-04-09 14:23:19');
INSERT INTO `order_status_log` VALUES (464, 94, 5, 6, 45, '顾客确认完成', '2026-04-09 14:23:49');
INSERT INTO `order_status_log` VALUES (465, 95, NULL, 1, NULL, '外部平台导入', '2026-04-09 14:34:54');
INSERT INTO `order_status_log` VALUES (466, 96, NULL, 1, NULL, '外部平台导入', '2026-04-09 14:34:55');
INSERT INTO `order_status_log` VALUES (467, 97, NULL, 1, NULL, '外部平台导入', '2026-04-09 14:34:55');
INSERT INTO `order_status_log` VALUES (468, 98, NULL, 1, NULL, '外部平台导入', '2026-04-09 14:34:55');
INSERT INTO `order_status_log` VALUES (469, 96, 1, 2, NULL, '系统自动派单给保洁员13', '2026-04-09 14:35:00');
INSERT INTO `order_status_log` VALUES (470, 96, 1, 2, NULL, '系统自动派单给保洁员13', '2026-04-09 14:35:12');
INSERT INTO `order_status_log` VALUES (471, 95, 1, 2, NULL, '系统自动派单给保洁员10', '2026-04-09 14:35:15');
INSERT INTO `order_status_log` VALUES (472, 80, 1, 2, NULL, '系统自动派单给保洁员13', '2026-04-09 14:35:18');
INSERT INTO `order_status_log` VALUES (473, 96, 2, 3, 13, '保洁员确认接单', '2026-04-09 14:35:36');
INSERT INTO `order_status_log` VALUES (474, 80, 2, 3, 13, '保洁员确认接单', '2026-04-09 14:35:38');
INSERT INTO `order_status_log` VALUES (475, 98, 1, 2, 8, '管理员手动派单', '2026-04-09 14:36:51');
INSERT INTO `order_status_log` VALUES (476, 97, 1, 2, NULL, '系统自动派单给保洁员7', '2026-04-09 14:38:18');
INSERT INTO `order_status_log` VALUES (477, 97, 2, 3, 7, '保洁员确认接单', '2026-04-09 14:39:57');
INSERT INTO `order_status_log` VALUES (478, 98, 2, 3, 7, '保洁员确认接单', '2026-04-09 14:39:58');
INSERT INTO `order_status_log` VALUES (479, 95, 2, 1, 10, '保洁员拒绝接单，退回待派单', '2026-04-09 14:40:14');
INSERT INTO `order_status_log` VALUES (480, 95, 1, 2, NULL, '系统自动派单给保洁员10', '2026-04-09 14:40:23');
INSERT INTO `order_status_log` VALUES (481, 95, 2, 3, 10, '保洁员确认接单', '2026-04-09 14:41:01');
INSERT INTO `order_status_log` VALUES (482, 99, NULL, 1, 6, '顾客下单', '2026-04-09 21:36:26');
INSERT INTO `order_status_log` VALUES (483, 99, 1, 3, 7, '保洁员抢单', '2026-04-09 21:48:46');
INSERT INTO `order_status_log` VALUES (484, 100, NULL, 1, 45, '顾客下单', '2026-04-09 22:01:33');
INSERT INTO `order_status_log` VALUES (485, 100, 1, 2, NULL, '系统自动派单给保洁员14', '2026-04-09 22:01:55');
INSERT INTO `order_status_log` VALUES (486, 101, NULL, 1, 6, '顾客下单', '2026-04-09 22:02:34');
INSERT INTO `order_status_log` VALUES (487, 101, 1, 2, NULL, '系统自动派单给保洁员11', '2026-04-09 22:02:54');
INSERT INTO `order_status_log` VALUES (488, 102, NULL, 1, 45, '顾客下单', '2026-04-09 22:04:01');
INSERT INTO `order_status_log` VALUES (489, 101, 2, 3, 11, '保洁员确认接单', '2026-04-09 22:04:29');
INSERT INTO `order_status_log` VALUES (490, 100, 2, 3, 14, '保洁员确认接单', '2026-04-09 22:05:15');
INSERT INTO `order_status_log` VALUES (491, 100, 3, 4, 14, '保洁员签到打卡', '2026-04-09 22:10:11');
INSERT INTO `order_status_log` VALUES (492, 100, 4, 5, 14, '保洁员完工上报', '2026-04-09 22:10:19');
INSERT INTO `order_status_log` VALUES (493, 102, 1, 8, NULL, '预约时间 2026-04-09T22:09:27 已过，无人接单，系统自动取消退款', '2026-04-09 22:13:20');
INSERT INTO `order_status_log` VALUES (494, 103, NULL, 1, 6, '顾客下单', '2026-04-09 22:14:56');
INSERT INTO `order_status_log` VALUES (495, 103, 1, 2, NULL, '系统自动派单给保洁员13', '2026-04-09 22:15:13');
INSERT INTO `order_status_log` VALUES (496, 103, 2, 2, 8, '管理员手动派单', '2026-04-09 22:15:23');
INSERT INTO `order_status_log` VALUES (497, 103, 2, 3, 12, '保洁员确认接单', '2026-04-09 22:17:17');
INSERT INTO `order_status_log` VALUES (498, 103, 3, 4, 12, '保洁员签到打卡', '2026-04-09 22:48:47');
INSERT INTO `order_status_log` VALUES (499, 103, 4, 5, 12, '保洁员完工上报', '2026-04-09 22:50:06');
INSERT INTO `order_status_log` VALUES (500, 104, NULL, 1, NULL, '外部平台导入', '2026-04-09 23:11:25');
INSERT INTO `order_status_log` VALUES (501, 105, NULL, 1, NULL, '外部平台导入', '2026-04-09 23:11:25');
INSERT INTO `order_status_log` VALUES (502, 106, NULL, 1, NULL, '外部平台导入', '2026-04-09 23:11:25');
INSERT INTO `order_status_log` VALUES (503, 107, NULL, 1, NULL, '外部平台导入', '2026-04-09 23:11:25');
INSERT INTO `order_status_log` VALUES (504, 105, 1, 2, NULL, '系统自动派单给保洁员11', '2026-04-09 23:11:30');
INSERT INTO `order_status_log` VALUES (505, 104, 1, 2, NULL, '系统自动派单给保洁员7', '2026-04-09 23:28:25');
INSERT INTO `order_status_log` VALUES (506, 107, 1, 2, NULL, '系统自动派单给保洁员7', '2026-04-09 23:28:29');
INSERT INTO `order_status_log` VALUES (507, 107, 2, 3, 7, '保洁员确认接单', '2026-04-09 23:30:50');
INSERT INTO `order_status_log` VALUES (508, 104, 2, 3, 7, '保洁员确认接单', '2026-04-09 23:30:51');
INSERT INTO `order_status_log` VALUES (509, 105, 2, 1, NULL, '派单30分钟超时，自动退回待派单池', '2026-04-09 23:41:48');
INSERT INTO `order_status_log` VALUES (510, 99, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-09T21:49:10），系统自动取消', '2026-04-09 23:49:48');
INSERT INTO `order_status_log` VALUES (511, 101, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-09T22:06:24），系统自动取消', '2026-04-10 00:19:48');
INSERT INTO `order_status_log` VALUES (512, 91, 5, 6, NULL, '超过48小时未确认，系统自动确认完成', '2026-04-10 10:59:08');
INSERT INTO `order_status_log` VALUES (513, 92, 5, 6, NULL, '超过48小时未确认，系统自动确认完成', '2026-04-10 10:59:08');
INSERT INTO `order_status_log` VALUES (514, 76, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-10T09:00），系统自动取消', '2026-04-10 11:14:08');
INSERT INTO `order_status_log` VALUES (515, 95, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-10T09:00），系统自动取消', '2026-04-10 11:14:08');
INSERT INTO `order_status_log` VALUES (516, 104, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-10T09:00），系统自动取消', '2026-04-10 11:14:08');
INSERT INTO `order_status_log` VALUES (517, 105, 1, 2, 8, '管理员手动派单', '2026-04-10 12:14:39');
INSERT INTO `order_status_log` VALUES (518, 105, 2, 2, 8, '管理员手动派单', '2026-04-10 12:22:36');
INSERT INTO `order_status_log` VALUES (519, 105, 2, 3, 12, '保洁员确认接单', '2026-04-10 12:22:42');
INSERT INTO `order_status_log` VALUES (520, 108, NULL, 1, 45, '顾客下单', '2026-04-10 12:23:45');
INSERT INTO `order_status_log` VALUES (521, 108, 1, 2, NULL, '系统自动派单给保洁员14', '2026-04-10 12:23:59');
INSERT INTO `order_status_log` VALUES (522, 108, 2, 3, 14, '保洁员确认接单', '2026-04-10 12:24:30');
INSERT INTO `order_status_log` VALUES (523, 108, 3, 4, 14, '保洁员签到打卡', '2026-04-10 12:24:49');
INSERT INTO `order_status_log` VALUES (524, 108, 4, 5, 14, '保洁员完工上报', '2026-04-10 12:24:55');
INSERT INTO `order_status_log` VALUES (525, 109, NULL, 1, 6, '顾客下单', '2026-04-10 12:25:56');
INSERT INTO `order_status_log` VALUES (526, 109, 1, 8, 6, '顾客取消：', '2026-04-10 12:33:42');
INSERT INTO `order_status_log` VALUES (527, 110, NULL, 1, 6, '顾客下单', '2026-04-10 12:34:05');
INSERT INTO `order_status_log` VALUES (528, 111, NULL, 1, 45, '顾客下单', '2026-04-10 12:42:41');
INSERT INTO `order_status_log` VALUES (529, 112, NULL, 1, 6, '顾客下单', '2026-04-10 12:43:47');
INSERT INTO `order_status_log` VALUES (530, 111, 1, 2, NULL, '系统自动派单给保洁员10', '2026-04-10 12:44:01');
INSERT INTO `order_status_log` VALUES (531, 111, 2, 3, 10, '保洁员确认接单', '2026-04-10 12:46:02');
INSERT INTO `order_status_log` VALUES (532, 112, 1, 2, NULL, '系统自动派单给保洁员10', '2026-04-10 12:46:16');
INSERT INTO `order_status_log` VALUES (533, 112, 2, 3, 10, '保洁员确认接单', '2026-04-10 12:46:33');
INSERT INTO `order_status_log` VALUES (534, 111, 3, 4, 10, '保洁员签到打卡', '2026-04-10 12:47:12');
INSERT INTO `order_status_log` VALUES (535, 111, 4, 5, 10, '保洁员完工上报', '2026-04-10 12:47:17');
INSERT INTO `order_status_log` VALUES (536, 110, 1, 2, NULL, '系统自动派单给保洁员12', '2026-04-10 12:50:58');
INSERT INTO `order_status_log` VALUES (537, 110, 2, 3, 12, '保洁员确认接单', '2026-04-10 12:52:36');
INSERT INTO `order_status_log` VALUES (538, 106, 1, 3, 12, '保洁员抢单', '2026-04-10 13:00:21');
INSERT INTO `order_status_log` VALUES (539, 110, 3, 1, 12, '保洁员取消，退回派单池', '2026-04-10 13:02:06');
INSERT INTO `order_status_log` VALUES (540, 110, 1, 3, 12, '保洁员抢单', '2026-04-10 13:02:33');
INSERT INTO `order_status_log` VALUES (541, 106, 3, 1, 12, '保洁员取消，退回派单池', '2026-04-10 13:02:56');
INSERT INTO `order_status_log` VALUES (542, 106, 1, 3, 12, '保洁员抢单', '2026-04-10 13:03:57');
INSERT INTO `order_status_log` VALUES (543, 113, NULL, 1, 6, '顾客下单', '2026-04-10 13:25:45');
INSERT INTO `order_status_log` VALUES (544, 108, 5, 6, 45, '顾客确认完成', '2026-04-10 13:38:44');
INSERT INTO `order_status_log` VALUES (545, 114, NULL, 1, 45, '顾客下单', '2026-04-10 13:39:18');
INSERT INTO `order_status_log` VALUES (546, 114, 1, 2, NULL, '系统自动派单给保洁员11', '2026-04-10 13:39:44');
INSERT INTO `order_status_log` VALUES (547, 114, 2, 3, 11, '保洁员确认接单', '2026-04-10 13:40:06');
INSERT INTO `order_status_log` VALUES (548, 113, 1, 8, NULL, '预约时间 2026-04-10T13:40:23 已过，无人接单，系统自动取消退款', '2026-04-10 13:43:23');
INSERT INTO `order_status_log` VALUES (549, 114, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-10T13:44:05），系统自动取消', '2026-04-10 16:11:35');
INSERT INTO `order_status_log` VALUES (550, 80, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-10T15:00），系统自动取消', '2026-04-10 17:11:35');
INSERT INTO `order_status_log` VALUES (551, 110, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-10T15:05:53），系统自动取消', '2026-04-10 17:11:35');
INSERT INTO `order_status_log` VALUES (552, 112, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-10T16:42:17），系统自动取消', '2026-04-10 18:56:36');
INSERT INTO `order_status_log` VALUES (553, 115, NULL, 1, 45, '顾客下单', '2026-04-10 19:15:24');
INSERT INTO `order_status_log` VALUES (554, 115, 1, 8, NULL, '预约时间 2026-04-10T19:22:11 已过，无人接单，系统自动取消退款', '2026-04-10 19:23:23');
INSERT INTO `order_status_log` VALUES (555, 116, NULL, 1, 45, '顾客下单', '2026-04-10 22:37:38');
INSERT INTO `order_status_log` VALUES (556, 116, 1, 2, NULL, '系统自动派单给保洁员10', '2026-04-10 22:42:51');
INSERT INTO `order_status_log` VALUES (557, 116, 2, 3, 10, '保洁员确认接单', '2026-04-10 22:43:14');
INSERT INTO `order_status_log` VALUES (558, 116, 3, 4, 10, '保洁员签到打卡', '2026-04-10 22:46:41');
INSERT INTO `order_status_log` VALUES (559, 116, 4, 5, 10, '保洁员完工上报', '2026-04-10 22:46:47');
INSERT INTO `order_status_log` VALUES (560, 116, 5, 6, 45, '顾客确认完成', '2026-04-10 22:47:01');
INSERT INTO `order_status_log` VALUES (561, 77, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-11T09:00），系统自动取消', '2026-04-11 13:32:49');
INSERT INTO `order_status_log` VALUES (562, 96, 3, 8, NULL, '保洁员超时未签到（预约时间 2026-04-11T09:00），系统自动取消', '2026-04-11 13:32:49');

-- ----------------------------
-- Table structure for payment_record
-- ----------------------------
DROP TABLE IF EXISTS `payment_record`;
CREATE TABLE `payment_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `pay_type` tinyint NOT NULL COMMENT '支付类型：1=定金 2=尾款 3=全额',
  `amount` decimal(8, 2) NOT NULL COMMENT '支付金额',
  `pay_method` tinyint NOT NULL DEFAULT 99 COMMENT '支付方式：1=微信 2=支付宝 99=模拟支付',
  `pay_status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=待支付 2=成功 3=失败',
  `pay_time` datetime NULL DEFAULT NULL COMMENT '支付成功时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '支付记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of payment_record
-- ----------------------------
INSERT INTO `payment_record` VALUES (1, 55, 1, 14.00, 99, 2, '2026-03-27 16:07:00', '2026-03-27 16:07:00');
INSERT INTO `payment_record` VALUES (2, 55, 2, 56.00, 99, 2, '2026-03-27 16:08:17', '2026-03-27 16:08:17');
INSERT INTO `payment_record` VALUES (3, 56, 1, 14.00, 99, 2, '2026-03-27 16:31:47', '2026-03-27 16:31:47');
INSERT INTO `payment_record` VALUES (4, 56, 2, 56.00, 99, 2, '2026-03-27 16:34:00', '2026-03-27 16:34:00');
INSERT INTO `payment_record` VALUES (5, 57, 1, 16.00, 99, 2, '2026-03-27 16:42:33', '2026-03-27 16:42:33');
INSERT INTO `payment_record` VALUES (6, 57, 2, 64.00, 99, 2, '2026-03-27 16:46:22', '2026-03-27 16:46:22');
INSERT INTO `payment_record` VALUES (7, 58, 1, 59.70, 99, 2, '2026-03-28 14:17:40', '2026-03-28 14:17:40');
INSERT INTO `payment_record` VALUES (8, 59, 1, 202.50, 99, 2, '2026-03-28 14:18:22', '2026-03-28 14:18:22');
INSERT INTO `payment_record` VALUES (9, 59, 2, 472.50, 99, 2, '2026-03-28 14:20:06', '2026-03-28 14:20:06');
INSERT INTO `payment_record` VALUES (10, 69, 1, 21.00, 99, 2, '2026-03-31 15:37:03', '2026-03-31 15:37:03');
INSERT INTO `payment_record` VALUES (11, 70, 1, 59.70, 99, 2, '2026-03-31 15:40:00', '2026-03-31 15:40:00');
INSERT INTO `payment_record` VALUES (12, 70, 2, 139.30, 99, 2, '2026-03-31 18:10:57', '2026-03-31 18:10:57');
INSERT INTO `payment_record` VALUES (13, 72, 3, 100.00, 99, 2, '2026-03-31 20:07:39', '2026-03-31 20:07:39');
INSERT INTO `payment_record` VALUES (14, 73, 1, 24.00, 99, 2, '2026-04-07 14:00:35', '2026-04-07 14:00:35');
INSERT INTO `payment_record` VALUES (15, 83, 1, 24.00, 99, 2, '2026-04-07 23:58:49', '2026-04-07 23:58:49');
INSERT INTO `payment_record` VALUES (16, 84, 1, 49.50, 99, 2, '2026-04-08 01:00:44', '2026-04-08 01:00:44');
INSERT INTO `payment_record` VALUES (17, 84, 2, 115.50, 99, 2, '2026-04-08 01:09:57', '2026-04-08 01:09:57');
INSERT INTO `payment_record` VALUES (18, 85, 3, 100.00, 99, 2, '2026-04-08 01:36:08', '2026-04-08 01:36:08');
INSERT INTO `payment_record` VALUES (19, 86, 3, 80.00, 99, 2, '2026-04-08 01:44:37', '2026-04-08 01:44:37');
INSERT INTO `payment_record` VALUES (20, 87, 3, 175.00, 99, 2, '2026-04-08 01:47:08', '2026-04-08 01:47:08');
INSERT INTO `payment_record` VALUES (21, 88, 3, 300.00, 99, 2, '2026-04-08 01:53:30', '2026-04-08 01:53:30');
INSERT INTO `payment_record` VALUES (22, 89, 3, 150.00, 99, 2, '2026-04-08 02:31:46', '2026-04-08 02:31:46');
INSERT INTO `payment_record` VALUES (23, 94, 3, 199.00, 99, 2, '2026-04-09 14:23:48', '2026-04-09 14:23:48');
INSERT INTO `payment_record` VALUES (24, 108, 3, 150.00, 99, 2, '2026-04-10 13:38:43', '2026-04-10 13:38:43');
INSERT INTO `payment_record` VALUES (25, 116, 3, 150.00, 99, 2, '2026-04-10 22:47:00', '2026-04-10 22:47:00');
INSERT INTO `payment_record` VALUES (26, 92, 3, 80.00, 99, 2, '2026-04-10 22:51:05', '2026-04-10 22:51:05');
INSERT INTO `payment_record` VALUES (27, 91, 3, 199.00, 99, 2, '2026-04-10 22:53:48', '2026-04-10 22:53:48');

-- ----------------------------
-- Table structure for service_order
-- ----------------------------
DROP TABLE IF EXISTS `service_order`;
CREATE TABLE `service_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '订单编号（系统生成，唯一）',
  `source` tinyint NOT NULL DEFAULT 1 COMMENT '订单来源：1=平台自有 2=外部导入 3=手动录入',
  `customer_id` bigint NOT NULL COMMENT '下单顾客user_id',
  `cleaner_id` bigint NULL DEFAULT NULL COMMENT '派单保洁员user_id',
  `service_type_id` bigint NOT NULL COMMENT '服务类型ID',
  `address_id` bigint NULL DEFAULT NULL COMMENT '服务地址ID（来自customer_address）',
  `address_snapshot` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '下单时地址快照（防止地址修改影响历史订单）',
  `longitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '服务地址经度',
  `latitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '服务地址纬度',
  `house_area` decimal(6, 1) NULL DEFAULT NULL COMMENT '房屋面积（㎡）',
  `plan_duration` int NULL DEFAULT NULL COMMENT '预约服务时长（分钟）',
  `actual_duration` int NULL DEFAULT NULL COMMENT '实际服务时长（分钟），完工时填写',
  `appoint_time` datetime NOT NULL COMMENT '预约上门时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '顾客备注',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '订单状态：1=待派单 2=已派单待确认 3=已接单 4=服务中 5=待确认完成 6=已完成 7=售后处理中 8=已取消',
  `cancel_reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '取消原因',
  `estimate_fee` decimal(8, 2) NULL DEFAULT NULL COMMENT '预估费用',
  `actual_fee` decimal(8, 2) NULL DEFAULT NULL COMMENT '实际费用（完工确认后）',
  `deposit_fee` decimal(8, 2) NULL DEFAULT NULL COMMENT '已付定金',
  `pay_status` tinyint NOT NULL DEFAULT 0 COMMENT '支付状态：0=未支付 1=已付定金 2=已全额支付',
  `auto_confirm_at` datetime NULL DEFAULT NULL COMMENT '48h自动确认时间',
  `completed_at` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no` ASC) USING BTREE,
  INDEX `idx_customer_id`(`customer_id` ASC) USING BTREE,
  INDEX `idx_cleaner_id`(`cleaner_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_appoint_time`(`appoint_time` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 117 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '服务订单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of service_order
-- ----------------------------
INSERT INTO `service_order` VALUES (1, 'CM202603201819049991', 1, 6, 7, 1, 1, '重庆市市辖区巴南区重庆理工大学 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 120, NULL, '2026-03-21 00:00:00', '', 8, '', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-20 18:19:04', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (2, 'CM202603201902268711', 1, 6, 7, 7, 1, '重庆市市辖区巴南区重庆理工大学 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 240, 120, '2026-03-25 00:00:00', '', 6, NULL, 240.00, 120.00, NULL, 0, '2026-03-22 20:54:11', '2026-03-20 20:54:33', '2026-03-20 19:02:27', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (3, 'CM202603201955533865', 1, 6, 7, 9, 1, '重庆市市辖区巴南区重庆理工大学 | 顾客 13800000001', 106.5257000, 29.4593000, 22.0, NULL, NULL, '2026-03-22 08:00:17', '', 8, '保洁员超时未签到，系统自动取消', 220.00, NULL, NULL, 0, NULL, NULL, '2026-03-20 19:55:54', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (4, 'CM202603202025361052', 1, 6, 7, 10, 1, '重庆市市辖区巴南区重庆理工大学 | 顾客 13800000001', 106.5257000, 29.4593000, 22.0, NULL, NULL, '2026-03-21 09:00:00', '', 8, '保洁员超时未签到，系统自动取消', 330.00, NULL, NULL, 0, NULL, NULL, '2026-03-20 20:25:37', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (5, 'CM202603202027116521', 1, 6, 7, 5, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 120, NULL, '2026-03-21 06:00:00', '', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-20 20:27:11', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (6, 'CM202603211321252767', 1, 6, NULL, 8, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, NULL, NULL, '2026-03-22 09:30:00', '', 8, '', 80.00, NULL, NULL, 0, NULL, NULL, '2026-03-21 13:21:26', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (7, 'CM202603211337587872', 1, 6, 7, 9, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, 20.0, NULL, 120, '2026-03-21 14:37:39', '', 6, NULL, 200.00, 200.00, NULL, 0, '2026-03-23 13:47:09', '2026-03-21 13:56:47', '2026-03-21 13:37:59', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (8, 'CM202603211436557441', 1, 6, 10, 5, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 120, NULL, '2026-03-21 16:36:42', '', 8, '', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-21 14:36:56', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (9, 'CM202603211546198464', 1, 6, 10, 7, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 240, NULL, '2026-03-21 18:37:06', '', 8, '保洁员超时未签到，系统自动取消', 240.00, NULL, NULL, 0, NULL, NULL, '2026-03-21 15:46:20', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (10, 'CM202603211711163527', 1, 6, 7, 10, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, 12.0, NULL, 120, '2026-03-21 17:45:56', '', 7, NULL, 180.00, 180.00, NULL, 0, '2026-03-23 17:12:10', NULL, '2026-03-21 17:11:16', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (11, 'CM202603221459070506', 1, 6, 7, 6, 3, '重庆市市辖区大渡口区金科 | 1 18300000001', 106.5516000, 29.5630000, NULL, 180, 120, '2026-03-22 15:29:11', '', 6, NULL, 150.00, 0.00, NULL, 0, '2026-03-24 15:00:24', NULL, '2026-03-22 14:59:07', '2026-03-22 14:59:07');
INSERT INTO `service_order` VALUES (12, 'CM202603221515316932', 1, 6, 10, 5, 3, '重庆市市辖区大渡口区金科 | 1 18300000001', 106.5516000, 29.5630000, NULL, 120, 120, '2026-03-22 15:59:49', '', 6, NULL, 70.00, 0.00, NULL, 0, '2026-03-24 15:15:55', NULL, '2026-03-22 15:15:32', '2026-03-22 15:15:32');
INSERT INTO `service_order` VALUES (13, 'TEST_R1_FULLREFUND', 1, 6, 7, 5, NULL, '测试-全额退款', NULL, NULL, NULL, NULL, NULL, '2026-03-21 16:53:42', NULL, 6, NULL, 100.00, 0.00, NULL, 0, NULL, NULL, '2026-03-22 16:53:42', '2026-03-22 16:53:42');
INSERT INTO `service_order` VALUES (14, 'TEST_R2_REJECT', 1, 6, 7, 5, NULL, '测试-驳回', NULL, NULL, NULL, NULL, NULL, '2026-03-21 16:53:42', NULL, 6, NULL, 100.00, 100.00, NULL, 0, NULL, NULL, '2026-03-22 16:53:42', '2026-03-22 16:53:42');
INSERT INTO `service_order` VALUES (15, 'TEST_R3_REDO', 1, 6, 12, 5, NULL, '测试-免费重做', NULL, NULL, NULL, NULL, NULL, '2026-03-21 16:53:42', NULL, 8, '保洁员超时未签到，系统自动取消', 100.00, 0.00, NULL, 0, NULL, NULL, '2026-03-22 16:53:42', '2026-03-22 17:10:22');
INSERT INTO `service_order` VALUES (16, 'TEST_NOSHOW', 1, 6, 7, 5, NULL, 'test-noshow', NULL, NULL, NULL, NULL, NULL, '2026-03-22 16:10:42', NULL, 8, '顾客报告保洁员未到场', 50.00, NULL, NULL, 0, NULL, NULL, '2026-03-22 17:10:42', '2026-03-22 17:10:42');
INSERT INTO `service_order` VALUES (17, 'TEST_NOSHOW2', 1, 6, 7, 5, NULL, 'test-noshow2', NULL, NULL, NULL, NULL, 120, '2026-03-22 17:20:43', NULL, 6, NULL, 50.00, 70.00, NULL, 0, '2026-03-24 17:49:13', '2026-03-22 18:00:45', '2026-03-22 17:10:43', '2026-03-22 17:10:43');
INSERT INTO `service_order` VALUES (18, 'TEST_CONFIRM', 1, 6, 7, 5, NULL, 'test-confirm', NULL, NULL, NULL, NULL, NULL, '2026-03-22 15:11:08', NULL, 6, NULL, 80.00, NULL, NULL, 0, NULL, '2026-03-22 17:11:08', '2026-03-22 17:11:08', '2026-03-22 17:11:08');
INSERT INTO `service_order` VALUES (19, 'TEST_POOL_DIST', 1, 6, 7, 5, NULL, 'test-pool-dist', 106.6016000, 29.5930000, NULL, NULL, 120, '2026-03-24 17:11:37', NULL, 6, NULL, 200.00, 70.00, NULL, 0, '2026-03-26 16:27:40', '2026-03-24 17:08:01', '2026-03-22 17:11:37', '2026-03-22 17:11:37');
INSERT INTO `service_order` VALUES (20, 'CM202603221759478661', 1, 6, 7, 10, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, 11.0, NULL, NULL, '2026-03-29 09:00:00', '', 8, '保洁员取消：', 165.00, NULL, NULL, 0, NULL, NULL, '2026-03-22 17:59:47', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (21, 'CM202603221800203529', 1, 6, 7, 6, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 180, NULL, '2026-03-29 10:00:00', '', 8, '保洁员取消：', 150.00, NULL, NULL, 0, NULL, NULL, '2026-03-22 18:00:21', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (22, 'CM202603221814455737', 1, 6, 10, 5, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 120, NULL, '2026-03-29 09:00:00', '', 8, '保洁员取消：', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-22 18:14:45', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (23, 'CM202603222105382682', 1, 6, 10, 5, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 120, NULL, '2026-03-23 12:00:00', '', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-22 21:05:38', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (24, 'CM202603231442412875', 1, 6, 7, 7, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 240, 120, '2026-03-23 15:00:00', '', 6, NULL, 240.00, 120.00, NULL, 0, '2026-03-25 14:58:58', '2026-03-23 14:59:23', '2026-03-23 14:42:41', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (25, 'CM202603231443180605', 1, 6, 7, 8, 3, '重庆市市辖区大渡口区金科 | 1 18300000001', 106.5516000, 29.5630000, NULL, NULL, NULL, '2026-03-23 20:00:00', '', 8, '保洁员超时未签到，系统自动取消', 80.00, NULL, NULL, 0, NULL, NULL, '2026-03-23 14:43:18', '2026-03-23 14:58:15');
INSERT INTO `service_order` VALUES (26, 'CM202603241521044166', 1, 6, NULL, 5, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 120, NULL, '2026-03-24 20:00:00', 'test', 8, '预约时间已过，无人接单，系统自动取消退款', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-24 15:21:05', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (27, 'CM202603241522544394', 1, 6, 7, 5, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 120, NULL, '2026-03-25 10:00:00', 'test', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-24 15:22:54', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (28, 'CM_TEST_NOCOORD', 3, 6, 14, 5, 1, '测试-无坐标地址', NULL, NULL, NULL, 120, NULL, '2026-03-25 10:00:00', NULL, 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-24 15:25:23', '2026-03-24 21:14:17');
INSERT INTO `service_order` VALUES (29, 'CM202603241540271294', 1, 6, 11, 5, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 120, NULL, '2026-03-25 10:00:00', '', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-24 15:40:27', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (30, 'CM202603241626292857', 1, 6, 11, 9, 4, '重庆市市辖区江北区观音桥 | 测试顾客 13800000001', 106.5516000, 29.5630000, 11.0, NULL, NULL, '2026-03-25 14:00:00', '', 8, '保洁员超时未签到，系统自动取消', 110.00, NULL, NULL, 0, NULL, NULL, '2026-03-24 16:26:30', '2026-03-24 16:37:35');
INSERT INTO `service_order` VALUES (31, 'CM_TEST_2603_001', 1, 6, 7, 5, 5, '重庆市重庆市渝中区解放碑步行街民权路1号 | 测试用户 13800000001', 106.5727000, 29.5593000, 80.0, 120, NULL, '2026-03-26 09:00:00', '渝中区-日常保洁', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-24 17:19:50', '2026-03-24 17:32:53');
INSERT INTO `service_order` VALUES (32, 'CM_TEST_2603_002', 1, 6, 11, 9, 6, '重庆市重庆市江北区观音桥北城天街5号 | 测试用户 13800000001', 106.5344000, 29.5751000, 120.0, 90, NULL, '2026-03-26 09:30:00', '江北区-玻璃清洗', 8, '保洁员超时未签到，系统自动取消', 110.00, NULL, NULL, 0, NULL, NULL, '2026-03-24 17:19:50', '2026-03-24 17:32:53');
INSERT INTO `service_order` VALUES (33, 'CM_TEST_2603_003', 1, 6, 10, 8, 7, '重庆市重庆市南岸区南坪万达广场B座 | 测试用户 13800000001', 106.5683000, 29.5081000, 100.0, 120, NULL, '2026-03-26 13:00:00', '南岸区-家电清洗', 8, '保洁员超时未签到，系统自动取消', 80.00, NULL, NULL, 0, NULL, NULL, '2026-03-24 17:19:50', '2026-03-24 17:32:53');
INSERT INTO `service_order` VALUES (34, 'CM_TEST_2603_004', 1, 6, 13, 5, 8, '重庆市重庆市沙坪坝区三峡广场天虹商场旁 | 测试用户 13800000001', 106.4607000, 29.5552000, 90.0, 90, NULL, '2026-03-26 14:00:00', '沙坪坝-日常保洁', 8, '顾客报告保洁员未到场', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-24 17:19:50', '2026-03-25 18:04:32');
INSERT INTO `service_order` VALUES (35, 'CM_TEST_2603_005', 1, 6, 13, 5, 9, '重庆市重庆市九龙坡区杨家坪直港大道21号 | 测试用户 13800000001', 106.4988000, 29.5203000, 60.0, 60, NULL, '2026-03-26 16:30:00', '九龙坡-日常保洁', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-24 17:19:50', '2026-03-25 18:03:40');
INSERT INTO `service_order` VALUES (41, 'CM202603242242269025', 1, 6, 14, 5, 9, '重庆市重庆市九龙坡区杨家坪直港大道21号 | 测试用户 13800000001', 106.4988000, 29.5203000, NULL, 120, NULL, '2026-03-27 10:00:00', '', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-24 22:42:27', '2026-03-25 18:03:31');
INSERT INTO `service_order` VALUES (42, 'JD_202603261556528841', 2, 22, NULL, 5, NULL, '重庆市渝北区金开大道西段106号', 106.5800000, 29.7200000, 80.0, 120, NULL, '2026-03-27 01:00:00', '[京东到家:JD2026001] 请带拖把', 8, '预约时间已过，无人接单，系统自动取消退款', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-26 15:56:53', '2026-03-26 15:56:53');
INSERT INTO `service_order` VALUES (43, 'JD_202603261556529127', 2, 23, NULL, 6, NULL, '重庆市江北区北滨一路88号', 106.5500000, 29.5800000, 120.0, 180, NULL, '2026-03-28 02:00:00', '[京东到家:JD2026002] 重点清洁厨房', 8, '预约时间已过，无人接单，系统自动取消退款', 150.00, NULL, NULL, 0, NULL, NULL, '2026-03-26 15:56:53', '2026-03-26 15:56:53');
INSERT INTO `service_order` VALUES (44, 'JD_202603261556523373', 2, 19, NULL, 5, NULL, '重庆市南岸区南坪西路5号', 106.5600000, 29.5200000, 60.0, 120, NULL, '2026-03-29 06:00:00', '[美团到家:MT2026001] ', 8, '预约时间已过，无人接单，系统自动取消退款', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-26 15:56:53', '2026-03-26 15:56:53');
INSERT INTO `service_order` VALUES (45, 'JD_202603261556528602', 2, 20, NULL, 7, NULL, '重庆市沙坪坝区大学城南路36号', 106.3300000, 29.6100000, 100.0, 240, NULL, '2026-03-30 07:00:00', '[美团到家:MT2026002] 新房，请仔细清洁', 8, '预约时间已过，无人接单，系统自动取消退款', 240.00, NULL, NULL, 0, NULL, NULL, '2026-03-26 15:56:53', '2026-03-26 15:56:53');
INSERT INTO `service_order` VALUES (46, 'JD_202603261814568002', 2, 22, 13, 5, NULL, '重庆市渝北区金开大道西段106号', 106.5800000, 29.7200000, 80.0, 120, NULL, '2026-03-27 09:00:00', '[京东到家:JD5558] 请带拖把', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-26 18:14:57', '2026-03-26 20:50:53');
INSERT INTO `service_order` VALUES (47, 'JD_202603261814567439', 2, 23, 7, 6, NULL, '重庆市江北区北滨一路88号', 106.5500000, 29.5800000, 120.0, 180, NULL, '2026-03-28 10:00:00', '[京东到家:JD8677] 重点清洁厨房', 8, '保洁员超时未签到，系统自动取消', 150.00, NULL, NULL, 0, NULL, NULL, '2026-03-26 18:14:57', '2026-03-26 18:14:57');
INSERT INTO `service_order` VALUES (48, 'JD_202603261814562102', 2, 19, 7, 5, NULL, '重庆市南岸区南坪西路5号', 106.5600000, 29.5200000, 60.0, 120, NULL, '2026-03-29 14:00:00', '[美团到家:MT5643] ', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-26 18:14:57', '2026-03-26 18:14:57');
INSERT INTO `service_order` VALUES (49, 'JD_202603261814562633', 2, 20, 13, 7, NULL, '重庆市沙坪坝区大学城南路36号', 106.3300000, 29.6100000, 100.0, 240, NULL, '2026-03-30 15:00:00', '[美团到家:MT9255] 新房，请仔细清洁', 8, '保洁员超时未签到，系统自动取消', 240.00, NULL, NULL, 0, NULL, NULL, '2026-03-26 18:14:57', '2026-03-26 18:14:57');
INSERT INTO `service_order` VALUES (50, 'JD_202603262011461543', 2, 24, NULL, 7, NULL, '重庆市江北区北滨一路8321号', 106.6213000, 29.5744000, 120.0, 240, NULL, '2026-03-27 15:00:00', '[美团到家:MT2532] 请带拖把', 8, '预约时间已过，无人接单，系统自动取消退款', 240.00, NULL, NULL, 0, NULL, NULL, '2026-03-26 20:11:47', '2026-03-26 20:50:53');
INSERT INTO `service_order` VALUES (51, 'JD_202603262011468468', 2, 25, 13, 7, NULL, '重庆市九龙坡区杨家坪步行街6136号', 106.5593000, 29.5453000, 150.0, 240, NULL, '2026-03-28 09:00:00', '[京东到家:JD6676] 宠物家庭请注意', 8, '保洁员超时未签到，系统自动取消', 240.00, NULL, NULL, 0, NULL, NULL, '2026-03-26 20:11:47', '2026-03-26 20:11:47');
INSERT INTO `service_order` VALUES (52, 'JD_202603262011478253', 2, 26, NULL, 6, NULL, '重庆市渝中区解放碑商圈9291号', 106.5511000, 29.5308000, 150.0, 180, NULL, '2026-03-29 14:00:00', '[美团到家:MT4977] 请带拖把', 8, '预约时间已过，无人接单，系统自动取消退款', 150.00, NULL, NULL, 0, NULL, NULL, '2026-03-26 20:11:47', '2026-03-26 20:11:47');
INSERT INTO `service_order` VALUES (53, 'JD_202603262011477106', 2, 27, 13, 7, NULL, '重庆市渝中区解放碑商圈6659号', 106.6352000, 29.6163000, 120.0, 240, NULL, '2026-03-30 10:00:00', '[美团到家:MT6779] 请带拖把', 8, '预约时间已过，无人接单，系统自动取消退款', 240.00, NULL, NULL, 0, NULL, NULL, '2026-03-26 20:11:47', '2026-03-26 20:50:53');
INSERT INTO `service_order` VALUES (54, 'ROUTE_TEST_20260329', 1, 6, 7, 5, NULL, '重庆市渝中区解放碑商圈XX路12号', 106.5900000, 29.5500000, 80.0, 120, NULL, '2026-03-31 10:00:00', '路线测试订单', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-26 21:11:29', '2026-03-27 15:41:13');
INSERT INTO `service_order` VALUES (55, 'CM202603271605444945', 1, 6, 13, 5, 7, '重庆市重庆市南岸区南坪万达广场B座 | 测试用户 13800000001', 106.5683000, 29.5081000, NULL, 120, 120, '2026-03-27 17:00:22', '', 7, NULL, 70.00, 70.00, 14.00, 2, '2026-03-29 16:07:56', '2026-03-27 16:08:10', '2026-03-27 16:05:44', '2026-03-27 16:05:44');
INSERT INTO `service_order` VALUES (56, 'CM202603271631395214', 1, 6, 7, 5, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 120, 120, '2026-03-27 17:31:28', '', 6, NULL, 70.00, 70.00, 14.00, 2, '2026-03-29 16:32:20', '2026-03-27 16:33:08', '2026-03-27 16:31:39', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (57, 'CM202603271642308514', 1, 6, 11, 8, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, NULL, 120, '2026-03-27 17:42:21', '', 6, NULL, 80.00, 80.00, 16.00, 2, '2026-03-29 16:46:06', '2026-03-27 16:46:25', '2026-03-27 16:42:30', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (58, 'CM202603281417290656', 1, 6, NULL, 17, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, NULL, NULL, '2026-03-28 16:17:16', '', 8, '', 199.00, NULL, 59.70, 1, NULL, NULL, '2026-03-28 14:17:30', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (59, 'CM202603281418149779', 1, 6, 14, 10, 7, '重庆市重庆市南岸区南坪万达广场B座 | 测试用户 13800000001', 106.5683000, 29.5081000, 45.0, NULL, 120, '2026-03-28 15:17:59', '', 6, NULL, 675.00, 675.00, 202.50, 2, '2026-03-30 14:19:53', '2026-03-28 14:20:07', '2026-03-28 14:18:14', '2026-03-28 14:18:14');
INSERT INTO `service_order` VALUES (60, 'JD_202603301438101831', 2, 28, 14, 6, NULL, '重庆市南岸区南坪西路4913号', 106.5308000, 29.5998000, 150.0, 180, NULL, '2026-03-31 09:00:00', '[美团到家:MT9164] ', 8, '保洁员超时未签到，系统自动取消', 150.00, NULL, NULL, 0, NULL, NULL, '2026-03-30 14:38:10', '2026-03-30 14:38:10');
INSERT INTO `service_order` VALUES (61, 'JD_202603301438102875', 2, 29, 13, 5, NULL, '重庆市南岸区南坪西路8897号', 106.5641000, 29.5201000, 80.0, 120, NULL, '2026-04-01 10:00:00', '[京东到家:JD4580] 宠物家庭请注意', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-30 14:38:10', '2026-03-30 14:38:10');
INSERT INTO `service_order` VALUES (62, 'JD_202603301438102820', 2, 30, 7, 7, NULL, '重庆市九龙坡区杨家坪步行街6549号', 106.4752000, 29.5766000, 120.0, 240, NULL, '2026-04-02 10:00:00', '[美团到家:MT1939] 请带拖把', 8, '保洁员超时未签到，系统自动取消', 240.00, NULL, NULL, 0, NULL, NULL, '2026-03-30 14:38:11', '2026-03-30 14:38:11');
INSERT INTO `service_order` VALUES (63, 'JD_202603301438101070', 2, 31, 13, 5, NULL, '重庆市渝北区金开大道西段9162号', 106.5776000, 29.7744000, 150.0, 120, NULL, '2026-04-03 14:00:00', '[京东到家:JD6677] ', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-30 14:38:11', '2026-03-30 14:38:11');
INSERT INTO `service_order` VALUES (64, 'CM202603311241373903', 1, 6, 7, 8, 4, '重庆市市辖区江北区观音桥 | 测试顾客 13800000001', 106.5516000, 29.5630000, NULL, NULL, NULL, '2026-03-31 17:00:00', '', 8, '顾客报告保洁员未到场', 80.00, NULL, NULL, 0, NULL, NULL, '2026-03-31 12:41:38', '2026-03-31 12:41:38');
INSERT INTO `service_order` VALUES (65, 'JD_202603311452098424', 2, 32, 7, 6, NULL, '重庆市南岸区南坪西路6448号', 106.5499000, 29.5827000, 80.0, 180, NULL, '2026-04-01 14:00:00', '[京东到家:JD8541] ', 8, '保洁员超时未签到，系统自动取消', 150.00, NULL, NULL, 0, NULL, NULL, '2026-03-31 14:52:10', '2026-03-31 14:52:10');
INSERT INTO `service_order` VALUES (66, 'JD_202603311452095990', 2, 33, 10, 7, NULL, '重庆市渝北区金开大道西段9184号', 106.5595000, 29.7287000, 60.0, 240, NULL, '2026-04-02 14:00:00', '[美团到家:MT8755] 请带拖把', 8, '保洁员超时未签到，系统自动取消', 240.00, NULL, NULL, 0, NULL, NULL, '2026-03-31 14:52:10', '2026-03-31 14:52:10');
INSERT INTO `service_order` VALUES (67, 'JD_202603311452109792', 2, 34, 14, 5, NULL, '重庆市江北区北滨一路1506号', 106.5098000, 29.5302000, 150.0, 120, NULL, '2026-04-03 10:00:00', '[京东到家:JD2622] 请带拖把', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-31 14:52:10', '2026-03-31 18:59:58');
INSERT INTO `service_order` VALUES (68, 'JD_202603311452102347', 2, 35, 12, 5, NULL, '重庆市九龙坡区杨家坪步行街8575号', 106.4382000, 29.4898000, 150.0, 120, NULL, '2026-04-04 09:00:00', '[京东到家:JD1908] 请带拖把', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-03-31 14:52:10', '2026-03-31 14:52:10');
INSERT INTO `service_order` VALUES (69, 'CM202603311536599829', 1, 6, 13, 5, 7, '重庆市重庆市南岸区南坪万达广场B座 | 测试用户 13800000001', 106.5683000, 29.5081000, NULL, 120, NULL, '2026-03-31 16:36:50', '', 8, '顾客报告保洁员未到场', 70.00, NULL, 21.00, 1, NULL, NULL, '2026-03-31 15:36:59', '2026-03-31 15:36:59');
INSERT INTO `service_order` VALUES (70, 'CM202603311539560663', 1, 6, 12, 17, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, NULL, 120, '2026-03-31 17:00:00', '', 6, NULL, 199.00, 176.00, 59.70, 2, '2026-04-02 16:15:05', '2026-03-31 18:10:59', '2026-03-31 15:39:57', '2026-03-31 16:13:05');
INSERT INTO `service_order` VALUES (71, 'CM202603311723446114', 1, 6, 11, 10, 6, '重庆市重庆市江北区观音桥北城天街5号 | 测试用户 13800000001', 106.5344000, 29.5751000, 11.0, NULL, NULL, '2026-03-31 17:38:29', '', 8, '顾客报告保洁员未到场', 165.00, NULL, NULL, 0, NULL, NULL, '2026-03-31 17:23:45', '2026-03-31 17:23:45');
INSERT INTO `service_order` VALUES (72, 'CM202603311858327903', 1, 6, 14, 9, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, 10.0, NULL, 120, '2026-03-31 19:11:14', '', 6, NULL, 100.00, 89.00, NULL, 2, '2026-04-02 19:55:32', '2026-03-31 20:07:41', '2026-03-31 18:58:32', '2026-04-01 22:38:25');
INSERT INTO `service_order` VALUES (73, 'CM202604071400281075', 1, 6, 11, 8, 6, '重庆市重庆市江北区观音桥北城天街5号 | 测试用户 13800000001', 106.5344000, 29.5751000, NULL, NULL, NULL, '2026-04-07 15:00:00', '', 8, '保洁员超时未签到，系统自动取消', 80.00, NULL, 24.00, 1, NULL, NULL, '2026-04-07 14:00:29', '2026-04-07 14:00:29');
INSERT INTO `service_order` VALUES (74, 'JD_202604071401221724', 2, 36, 11, 5, NULL, '重庆市九龙坡区杨家坪步行街1621号', 106.4919000, 29.5627000, 120.0, 120, NULL, '2026-04-08 14:00:00', '[京东到家:JD9812] 请带拖把', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-04-07 14:01:23', '2026-04-07 14:01:23');
INSERT INTO `service_order` VALUES (75, 'JD_202604071401225420', 2, 37, 13, 6, NULL, '重庆市沙坪坝区大学城南路5513号', 106.3740000, 29.5763000, 120.0, 180, NULL, '2026-04-09 10:00:00', '[京东到家:JD2753] 请带拖把', 8, '保洁员超时未签到，系统自动取消', 150.00, NULL, NULL, 0, NULL, NULL, '2026-04-07 14:01:23', '2026-04-07 14:01:23');
INSERT INTO `service_order` VALUES (76, 'JD_202604071401234228', 2, 38, 11, 6, NULL, '重庆市九龙坡区杨家坪步行街9663号', 106.5267000, 29.5275000, 100.0, 180, NULL, '2026-04-10 09:00:00', '[美团到家:MT9833] 重点清洁厨房', 8, '保洁员超时未签到，系统自动取消', 150.00, NULL, NULL, 0, NULL, NULL, '2026-04-07 14:01:23', '2026-04-07 14:01:23');
INSERT INTO `service_order` VALUES (77, 'JD_202604071401237501', 2, 39, 11, 6, NULL, '重庆市渝中区解放碑商圈3461号', 106.5940000, 29.5759000, 120.0, 180, NULL, '2026-04-11 09:00:00', '[京东到家:JD5681] 新房请仔细清洁', 8, '保洁员超时未签到，系统自动取消', 150.00, NULL, NULL, 0, NULL, NULL, '2026-04-07 14:01:23', '2026-04-07 14:01:23');
INSERT INTO `service_order` VALUES (78, 'JD_202604071405318024', 2, 40, 7, 7, NULL, '重庆市渝中区解放碑商圈2012号', 106.5512000, 29.6253000, 60.0, 240, NULL, '2026-04-08 14:00:00', '[美团到家:MT8114] 请带拖把', 8, '预约时间已过，无人接单，系统自动取消退款', 240.00, NULL, NULL, 0, NULL, NULL, '2026-04-07 14:05:31', '2026-04-07 14:05:31');
INSERT INTO `service_order` VALUES (79, 'JD_202604071405316556', 2, 41, NULL, 6, NULL, '重庆市渝北区金开大道西段3513号', 106.5781000, 29.7512000, 120.0, 180, NULL, '2026-04-09 14:00:00', '[京东到家:JD7803] 宠物家庭请注意', 8, '预约时间已过，无人接单，系统自动取消退款', 150.00, NULL, NULL, 0, NULL, NULL, '2026-04-07 14:05:31', '2026-04-07 14:05:31');
INSERT INTO `service_order` VALUES (80, 'JD_202604071405311315', 2, 42, 13, 7, NULL, '重庆市沙坪坝区大学城南路5208号', 106.3598000, 29.5519000, 60.0, 240, NULL, '2026-04-10 15:00:00', '[美团到家:MT4942] 请带拖把', 8, '保洁员超时未签到，系统自动取消', 240.00, NULL, NULL, 0, NULL, NULL, '2026-04-07 14:05:31', '2026-04-07 14:05:31');
INSERT INTO `service_order` VALUES (81, 'JD_202604071405319062', 2, 43, 7, 5, NULL, '重庆市渝中区解放碑商圈7366号', 106.5471000, 29.6169000, 90.0, 120, NULL, '2026-04-11 15:00:00', '[京东到家:JD5668] 新房请仔细清洁', 3, NULL, 70.00, NULL, NULL, 0, NULL, NULL, '2026-04-07 14:05:32', '2026-04-07 14:05:32');
INSERT INTO `service_order` VALUES (82, 'CM202604072336195877', 1, 6, NULL, 17, 4, '重庆市市辖区江北区观音桥 | 测试顾客 13800000001', 106.5516000, 29.5630000, NULL, NULL, NULL, '2026-04-08 11:00:00', '', 8, '预约时间已过，无人接单，系统自动取消退款', 199.00, NULL, NULL, 0, NULL, NULL, '2026-04-07 23:36:20', '2026-04-07 23:36:20');
INSERT INTO `service_order` VALUES (83, 'CM202604072358422465', 1, 6, NULL, 8, 5, '重庆市重庆市渝中区解放碑步行街民权路1号 | 测试用户 13800000001', 106.5727000, 29.5593000, NULL, NULL, NULL, '2026-04-08 00:10:18', '', 8, '预约时间已过，无人接单，系统自动取消退款', 80.00, NULL, 24.00, 1, NULL, NULL, '2026-04-07 23:58:43', '2026-04-07 23:58:43');
INSERT INTO `service_order` VALUES (84, 'CM202604080100409725', 1, 6, 13, 10, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, 11.0, NULL, 120, '2026-04-08 09:57:46', '', 8, '保洁员超时未签到，系统自动取消', 165.00, 0.00, 49.50, 2, NULL, NULL, '2026-04-08 01:00:40', '2026-04-08 02:57:59');
INSERT INTO `service_order` VALUES (85, 'CM202604080133138282', 1, 6, 11, 9, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, 10.0, NULL, 30, '2026-04-08 01:37:02', '', 6, NULL, 100.00, 100.00, NULL, 2, '2026-04-10 01:34:59', '2026-04-08 01:36:10', '2026-04-08 01:33:14', '2026-04-08 01:33:14');
INSERT INTO `service_order` VALUES (86, 'CM202604080140340062', 1, 6, 13, 8, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, NULL, 240, '2026-04-08 01:43:23', '', 6, NULL, 80.00, 0.00, NULL, 2, '2026-04-10 01:41:45', '2026-04-08 01:44:46', '2026-04-08 01:40:34', '2026-04-08 01:40:34');
INSERT INTO `service_order` VALUES (87, 'CM202604080145262522', 1, 6, 10, 5, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 120, 210, '2026-04-08 01:47:57', '', 6, NULL, 70.00, 0.00, NULL, 2, '2026-04-10 01:46:42', '2026-04-08 01:47:12', '2026-04-08 01:45:26', '2026-04-08 01:45:26');
INSERT INTO `service_order` VALUES (88, 'CM202604080151505095', 1, 6, 12, 6, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 180, 270, '2026-04-08 01:53:41', '', 6, NULL, 150.00, 298.00, NULL, 2, '2026-04-10 01:53:09', '2026-04-08 01:53:32', '2026-04-08 01:51:51', '2026-04-08 01:51:51');
INSERT INTO `service_order` VALUES (89, 'CM202604080156472072', 1, 6, NULL, 7, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, 240, 150, '2026-04-08 02:04:23', '', 8, '预约时间已过，无人接单，系统自动取消退款', 240.00, 0.00, NULL, 2, NULL, NULL, '2026-04-08 01:56:47', '2026-04-08 02:35:21');
INSERT INTO `service_order` VALUES (90, 'CM202604080158406948', 1, 6, 13, 9, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, 23.0, NULL, NULL, '2026-04-08 07:00:00', '', 8, '保洁员超时未签到，系统自动取消', 230.00, NULL, NULL, 0, NULL, NULL, '2026-04-08 01:58:41', '2026-04-08 02:07:33');
INSERT INTO `service_order` VALUES (91, 'CM202604080354390271', 1, 6, 14, 17, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, NULL, 120, '2026-04-08 04:02:23', '', 6, NULL, 199.00, 199.00, NULL, 2, '2026-04-10 03:58:59', '2026-04-10 10:59:08', '2026-04-08 03:54:40', '2026-04-08 03:54:40');
INSERT INTO `service_order` VALUES (92, 'CM202604080400005933', 1, 6, 7, 8, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, NULL, 120, '2026-04-08 04:11:42', '', 6, NULL, 80.00, 80.00, NULL, 2, '2026-04-10 04:00:57', '2026-04-10 10:59:08', '2026-04-08 04:00:01', '2026-04-08 04:00:01');
INSERT INTO `service_order` VALUES (93, 'CM202604091252569762', 1, 45, 12, 5, 10, '重庆市市辖区大渡口区松青路 1091号 7座 15-3 | 顾客2 13833330008', 106.4796890, 29.4654740, NULL, 120, NULL, '2026-04-09 12:59:21', '', 8, '预约时间已过，无人接单，系统自动取消退款', 70.00, NULL, NULL, 0, NULL, NULL, '2026-04-09 12:52:56', '2026-04-09 12:52:56');
INSERT INTO `service_order` VALUES (94, 'CM202604091420364417', 1, 45, 12, 17, 10, '重庆市市辖区大渡口区松青路 1091号 7座 15-3 | 顾客2 13833330008', 106.4796890, 29.4654740, NULL, NULL, 120, '2026-04-09 14:24:27', '', 6, NULL, 199.00, 199.00, NULL, 2, '2026-04-11 14:23:19', '2026-04-09 14:23:49', '2026-04-09 14:20:36', '2026-04-09 14:20:36');
INSERT INTO `service_order` VALUES (95, 'JD_202604091434547413', 2, 46, 10, 6, NULL, '重庆市渝中区解放碑商圈5707号', 106.5433000, 29.5227000, 100.0, 180, NULL, '2026-04-10 09:00:00', '[美团到家:MT4071] 新房请仔细清洁', 8, '保洁员超时未签到，系统自动取消', 150.00, NULL, NULL, 0, NULL, NULL, '2026-04-09 14:34:54', '2026-04-09 14:40:14');
INSERT INTO `service_order` VALUES (96, 'JD_202604091434545109', 2, 47, 13, 6, NULL, '重庆市沙坪坝区大学城南路7248号', 106.2800000, 29.5877000, 80.0, 180, NULL, '2026-04-11 09:00:00', '[京东到家:JD8240] 新房请仔细清洁', 8, '保洁员超时未签到，系统自动取消', 150.00, NULL, NULL, 0, NULL, NULL, '2026-04-09 14:34:55', '2026-04-09 14:34:55');
INSERT INTO `service_order` VALUES (97, 'JD_202604091434542436', 2, 48, 7, 7, NULL, '重庆市九龙坡区杨家坪步行街1723号', 106.4873000, 29.5454000, 150.0, 240, NULL, '2026-04-12 14:00:00', '[京东到家:JD7070] 请带拖把', 3, NULL, 240.00, NULL, NULL, 0, NULL, NULL, '2026-04-09 14:34:55', '2026-04-09 14:34:55');
INSERT INTO `service_order` VALUES (98, 'JD_202604091434544225', 2, 49, 7, 5, NULL, '重庆市渝中区解放碑商圈9654号', 106.5991000, 29.6118000, 80.0, 120, NULL, '2026-04-13 10:00:00', '[京东到家:JD7280] 请带拖把', 3, NULL, 70.00, NULL, NULL, 0, NULL, NULL, '2026-04-09 14:34:55', '2026-04-09 14:34:55');
INSERT INTO `service_order` VALUES (99, 'CM202604092136266222', 1, 6, 7, 5, 6, '重庆市重庆市江北区观音桥北城天街5号 | 测试用户 13800000001', 106.5344000, 29.5751000, NULL, 120, NULL, '2026-04-09 21:49:10', '1111', 8, '保洁员超时未签到，系统自动取消', 70.00, NULL, NULL, 0, NULL, NULL, '2026-04-09 21:36:26', '2026-04-09 21:36:26');
INSERT INTO `service_order` VALUES (100, 'CM202604092201331018', 1, 45, 14, 10, 10, '重庆市市辖区大渡口区松青路 1091号 7座 15-3 | 顾客2 13833330008', 106.4796890, 29.4654740, 11.0, NULL, 120, '2026-04-09 22:10:23', '', 5, NULL, 165.00, 165.00, NULL, 0, '2026-04-11 22:10:19', NULL, '2026-04-09 22:01:33', '2026-04-09 22:01:33');
INSERT INTO `service_order` VALUES (101, 'CM202604092202335963', 1, 6, 11, 8, 6, '重庆市重庆市江北区观音桥北城天街5号 | 测试用户 13800000001', 106.5344000, 29.5751000, NULL, NULL, NULL, '2026-04-09 22:06:24', '222', 8, '保洁员超时未签到，系统自动取消', 80.00, NULL, NULL, 0, NULL, NULL, '2026-04-09 22:02:34', '2026-04-09 22:02:34');
INSERT INTO `service_order` VALUES (102, 'CM202604092204017083', 1, 45, NULL, 9, 11, '重庆市市辖区永川区人民广场 | 顾客2 13833330008', 105.9281120, 29.3550460, 11.0, NULL, NULL, '2026-04-09 22:09:27', '', 8, '预约时间已过，无人接单，系统自动取消退款', 110.00, NULL, NULL, 0, NULL, NULL, '2026-04-09 22:04:01', '2026-04-09 22:04:01');
INSERT INTO `service_order` VALUES (103, 'CM202604092214553004', 1, 6, 12, 17, 8, '重庆市重庆市沙坪坝区三峡广场天虹商场旁 | 测试用户 13800000001', 106.4607000, 29.5552000, NULL, NULL, 120, '2026-04-09 22:20:46', '', 5, NULL, 199.00, 199.00, NULL, 0, '2026-04-11 22:50:06', NULL, '2026-04-09 22:14:56', '2026-04-09 22:48:47');
INSERT INTO `service_order` VALUES (104, 'JD_202604092311257238', 2, 50, 7, 7, NULL, '重庆市渝中区解放碑商圈4640号', 106.6378000, 29.6071000, 60.0, 240, NULL, '2026-04-10 09:00:00', '[京东到家:JD4132] 请带拖把', 8, '保洁员超时未签到，系统自动取消', 240.00, NULL, NULL, 0, NULL, NULL, '2026-04-09 23:11:25', '2026-04-09 23:11:25');
INSERT INTO `service_order` VALUES (105, 'JD_202604092311253574', 2, 51, 12, 6, NULL, '重庆市南岸区南坪西路7022号', 106.6039000, 29.5963000, 100.0, 180, NULL, '2026-04-11 15:00:00', '[京东到家:JD9165] 新房请仔细清洁', 3, NULL, 150.00, NULL, NULL, 0, NULL, NULL, '2026-04-09 23:11:25', '2026-04-09 23:11:25');
INSERT INTO `service_order` VALUES (106, 'JD_202604092311250849', 2, 52, 12, 7, NULL, '重庆市九龙坡区杨家坪步行街8763号', 106.4450000, 29.5107000, 100.0, 240, NULL, '2026-04-12 15:00:00', '[京东到家:JD8121] 请带拖把', 3, NULL, 240.00, NULL, NULL, 0, NULL, NULL, '2026-04-09 23:11:25', '2026-04-10 13:02:56');
INSERT INTO `service_order` VALUES (107, 'JD_202604092311251725', 2, 53, 7, 6, NULL, '重庆市渝中区解放碑商圈8286号', 106.5887000, 29.6007000, 80.0, 180, NULL, '2026-04-13 15:00:00', '[美团到家:MT2680] 请带拖把', 3, NULL, 150.00, NULL, NULL, 0, NULL, NULL, '2026-04-09 23:11:25', '2026-04-09 23:11:25');
INSERT INTO `service_order` VALUES (108, 'CM202604101223459187', 1, 45, 14, 10, 10, '重庆市市辖区大渡口区松青路 1091号 7座 15-3 | 顾客2 13833330008', 106.4796890, 29.4654740, 10.0, NULL, 120, '2026-04-10 12:29:16', '密码1234', 6, NULL, 150.00, 150.00, NULL, 2, '2026-04-12 12:24:55', '2026-04-10 13:38:44', '2026-04-10 12:23:45', '2026-04-10 12:23:45');
INSERT INTO `service_order` VALUES (109, 'CM202604101225562383', 1, 6, NULL, 8, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, NULL, NULL, '2026-04-10 14:04:37', '', 8, '', 80.00, NULL, NULL, 0, NULL, NULL, '2026-04-10 12:25:56', '2026-04-10 12:25:56');
INSERT INTO `service_order` VALUES (110, 'CM202604101234048603', 1, 6, 12, 8, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, NULL, NULL, '2026-04-10 15:05:53', '', 8, '保洁员超时未签到，系统自动取消', 80.00, NULL, NULL, 0, NULL, NULL, '2026-04-10 12:34:05', '2026-04-10 13:02:05');
INSERT INTO `service_order` VALUES (111, 'CM202604101242402321', 1, 45, 10, 5, 10, '重庆市市辖区大渡口区松青路 1091号 7座 15-3 | 顾客2 13833330008', 106.4796890, 29.4654740, NULL, 120, 90, '2026-04-10 12:48:33', '', 5, NULL, 70.00, 52.50, NULL, 0, '2026-04-12 12:47:17', NULL, '2026-04-10 12:42:41', '2026-04-10 12:42:41');
INSERT INTO `service_order` VALUES (112, 'CM202604101243474500', 1, 6, 10, 8, 2, '重庆市市辖区巴南区重庆理工大学花溪校区 | 顾客 13800000001', 106.5257000, 29.4593000, NULL, NULL, NULL, '2026-04-10 16:42:17', '', 8, '保洁员超时未签到，系统自动取消', 80.00, NULL, NULL, 0, NULL, NULL, '2026-04-10 12:43:47', '2026-04-10 12:43:47');
INSERT INTO `service_order` VALUES (113, 'CM202604101325443026', 1, 6, NULL, 9, 5, '重庆市重庆市渝中区解放碑步行街民权路1号 | 测试用户 13800000001', 106.5727000, 29.5593000, 10.0, NULL, NULL, '2026-04-10 13:40:23', '', 8, '预约时间已过，无人接单，系统自动取消退款', 100.00, NULL, NULL, 0, NULL, NULL, '2026-04-10 13:25:45', '2026-04-10 13:25:45');
INSERT INTO `service_order` VALUES (114, 'CM202604101339184161', 1, 45, 11, 17, 10, '重庆市市辖区大渡口区松青路 1091号 7座 15-3 | 顾客2 13833330008', 106.4796890, 29.4654740, NULL, NULL, NULL, '2026-04-10 13:44:05', '', 8, '保洁员超时未签到，系统自动取消', 199.00, NULL, NULL, 0, NULL, NULL, '2026-04-10 13:39:18', '2026-04-10 13:39:18');
INSERT INTO `service_order` VALUES (115, 'CM202604101915241358', 1, 45, NULL, 9, 10, '重庆市市辖区大渡口区松青路 1091号 7座 15-3 | 顾客2 13833330008', 106.4796890, 29.4654740, 22.0, NULL, NULL, '2026-04-10 19:22:11', '', 8, '预约时间已过，无人接单，系统自动取消退款', 264.00, NULL, NULL, 0, NULL, NULL, '2026-04-10 19:15:24', '2026-04-10 19:15:24');
INSERT INTO `service_order` VALUES (116, 'CM202604102237383281', 1, 45, 10, 10, 10, '重庆市市辖区大渡口区松青路 1091号 7座 15-3 | 顾客2 13833330008', 106.4796890, 29.4654740, 10.0, NULL, 60, '2026-04-10 22:59:27', '', 6, NULL, 150.00, 150.00, NULL, 2, '2026-04-12 22:46:47', '2026-04-10 22:47:01', '2026-04-10 22:37:38', '2026-04-10 22:37:38');

-- ----------------------------
-- Table structure for service_photo
-- ----------------------------
DROP TABLE IF EXISTS `service_photo`;
CREATE TABLE `service_photo`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `cleaner_id` bigint NOT NULL COMMENT '上传保洁员user_id',
  `phase` tinyint NOT NULL COMMENT '拍摄阶段：1=服务前 2=服务中 3=服务后',
  `img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '照片URL',
  `taken_at` datetime NOT NULL COMMENT '拍摄时间（时间戳）',
  `longitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '拍摄位置经度',
  `latitude` decimal(10, 7) NULL DEFAULT NULL COMMENT '拍摄位置纬度',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id_phase`(`order_id` ASC, `phase` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '服务过程照片表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of service_photo
-- ----------------------------
INSERT INTO `service_photo` VALUES (1, 7, 7, 1, 'http://localhost:8080/api/files/25e9d1b65a7a4240bc60a09f8c71e415.jpg', '2026-03-21 13:46:15', NULL, NULL, '2026-03-21 13:46:15');
INSERT INTO `service_photo` VALUES (2, 7, 7, 2, 'http://localhost:8080/api/files/7e61e938a6934cef86b24b229685faf9.jpg', '2026-03-21 13:46:23', NULL, NULL, '2026-03-21 13:46:23');
INSERT INTO `service_photo` VALUES (3, 7, 7, 3, 'http://localhost:8080/api/files/5818a409612c41299098e0285feb7c01.jpg', '2026-03-21 13:46:29', NULL, NULL, '2026-03-21 13:46:29');
INSERT INTO `service_photo` VALUES (4, 10, 7, 1, 'http://localhost:8080/api/files/0a44e240733943bda51db91f6624558a.jpg', '2026-03-21 17:11:50', NULL, NULL, '2026-03-21 17:11:50');
INSERT INTO `service_photo` VALUES (5, 10, 7, 2, 'http://localhost:8080/api/files/b9f19dfecdbd41e68065c27105923c57.jpg', '2026-03-21 17:11:58', NULL, NULL, '2026-03-21 17:11:58');
INSERT INTO `service_photo` VALUES (6, 10, 7, 3, 'http://localhost:8080/api/files/a0e666b76cee4afe93222e67e8de9b5b.jpg', '2026-03-21 17:12:05', NULL, NULL, '2026-03-21 17:12:05');
INSERT INTO `service_photo` VALUES (7, 72, 14, 1, 'http://localhost:8080/api/files/63346959709d46a499a66e6fad3b0c9c.jpg', '2026-03-31 19:55:17', NULL, NULL, '2026-03-31 19:55:17');
INSERT INTO `service_photo` VALUES (8, 72, 14, 2, 'http://localhost:8080/api/files/86ec31a5a7db4be1bc389fb8431d5da4.jpg', '2026-03-31 19:55:24', NULL, NULL, '2026-03-31 19:55:24');
INSERT INTO `service_photo` VALUES (9, 72, 14, 3, 'http://localhost:8080/api/files/96ea38e635b143c999a917df22ef079a.jpg', '2026-03-31 19:55:30', NULL, NULL, '2026-03-31 19:55:30');
INSERT INTO `service_photo` VALUES (10, 84, 7, 1, 'http://localhost:8080/api/files/c8075be7ec504ad19e9e81d2791c8fe3.jpg', '2026-04-08 01:07:30', NULL, NULL, '2026-04-08 01:07:30');
INSERT INTO `service_photo` VALUES (11, 85, 11, 1, 'http://localhost:8080/api/files/ec3ceaf86ecc495f81af7c7af0ee5a4a.jpg', '2026-04-08 01:34:55', NULL, NULL, '2026-04-08 01:34:55');

-- ----------------------------
-- Table structure for service_price_tier
-- ----------------------------
DROP TABLE IF EXISTS `service_price_tier`;
CREATE TABLE `service_price_tier`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `service_type_id` bigint NOT NULL COMMENT '关联service_type.id',
  `area_min` int NOT NULL COMMENT '面积下限（㎡，含）',
  `area_max` int NOT NULL COMMENT '面积上限（㎡，不含）',
  `unit_price` decimal(8, 2) NOT NULL COMMENT '该区间单价（元/㎡）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_service_type_id`(`service_type_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '面积阶梯定价表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of service_price_tier
-- ----------------------------
INSERT INTO `service_price_tier` VALUES (1, 9, 1, 20, 10.00);
INSERT INTO `service_price_tier` VALUES (2, 9, 21, 40, 12.00);

-- ----------------------------
-- Table structure for service_type
-- ----------------------------
DROP TABLE IF EXISTS `service_type`;
CREATE TABLE `service_type`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '服务名称',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '服务描述',
  `cover_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图URL',
  `price_mode` tinyint NOT NULL COMMENT '计价模式：1=按小时 2=按面积 3=固定套餐',
  `base_price` decimal(8, 2) NOT NULL COMMENT '基础单价（元/小时 或 元/㎡ 或 套餐价）',
  `min_duration` int NULL DEFAULT NULL COMMENT '最短服务时长（分钟），按小时计费时使用',
  `suggest_workers` int NOT NULL DEFAULT 1 COMMENT '建议保洁员人数',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序权重，越大越靠前',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：1=上架 2=下架',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '服务类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of service_type
-- ----------------------------
INSERT INTO `service_type` VALUES (5, '日常保洁', '日常家庭清洁，吸尘拖地、擦拭家具、卫生间清洁，让家焕然一新', NULL, 1, 35.00, 120, 1, 100, 1, '2026-03-20 19:01:01', '2026-03-20 19:01:01');
INSERT INTO `service_type` VALUES (6, '深度保洁', '全屋深度清洁，不留死角，包含橱柜内部、家电表面、墙壁等细节处理', NULL, 1, 50.00, 180, 2, 90, 1, '2026-03-20 19:01:01', '2026-03-20 19:01:01');
INSERT INTO `service_type` VALUES (7, '开荒保洁', '新房装修后首次清洁，去除建筑污渍、墙壁灰尘、门窗玻璃等全面清洁', NULL, 1, 60.00, 240, 2, 80, 1, '2026-03-20 19:01:01', '2026-03-20 19:01:01');
INSERT INTO `service_type` VALUES (8, '家电清洗', '空调、油烟机、洗衣机、冰箱等家电专业深度清洗，延长使用寿命', NULL, 3, 80.00, NULL, 1, 70, 1, '2026-03-20 19:01:01', '2026-03-20 19:01:01');
INSERT INTO `service_type` VALUES (9, '玻璃清洗', '门窗玻璃、阳台玻璃专业清洁，还原通透效果', '', 2, 10.00, NULL, 1, 60, 1, '2026-03-20 19:01:01', '2026-03-20 19:01:01');
INSERT INTO `service_type` VALUES (10, '地板打蜡', '木地板、复合地板专业养护打蜡，恢复光泽延长使用寿命', NULL, 2, 15.00, NULL, 1, 50, 1, '2026-03-20 19:01:01', '2026-03-20 19:01:01');
INSERT INTO `service_type` VALUES (17, '油烟机清洗', '专业拆解清洗，去除顽固油污，恢复排风效率', '', 3, 199.00, NULL, 1, 90, 1, '2026-03-27 23:20:32', '2026-03-27 23:20:32');

-- ----------------------------
-- Table structure for system_config
-- ----------------------------
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `config_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '参数键',
  `config_value` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '参数值',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '参数说明',
  `updated_by` bigint NULL DEFAULT NULL COMMENT '最后修改管理员user_id',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统参数配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of system_config
-- ----------------------------
INSERT INTO `system_config` VALUES (1, 'commission_rate', '0.23', '平台佣金比例，默认20%', 8, '2026-03-20 16:03:17');
INSERT INTO `system_config` VALUES (2, 'commute_buffer_minutes', '20', '派单通勤缓冲时间（分钟）', 8, '2026-03-20 16:03:17');
INSERT INTO `system_config` VALUES (3, 'dispatch_timeout_minutes', '30', '保洁员接单响应超时时间（分钟）', NULL, '2026-03-20 16:03:17');
INSERT INTO `system_config` VALUES (4, 'deposit_rate', '0.35', '定金比例，默认20%', 8, '2026-03-20 16:03:17');
INSERT INTO `system_config` VALUES (5, 'auto_confirm_hours', '48', '完工后自动确认等待时间（小时）', 8, '2026-03-20 16:03:17');
INSERT INTO `system_config` VALUES (6, 'checkin_max_distance_m', '5000', 'GPS签到允许最大偏差距离（米）', 8, '2026-03-20 16:03:17');
INSERT INTO `system_config` VALUES (8, 'refund_deadline_hours', '1', '退单截止时间(小时)', 8, '2026-03-28 12:49:49');
INSERT INTO `system_config` VALUES (21, 'cleaner_cancel_hours', '1.5', '保洁员取消截止时间（服务开始前N小时）', 8, '2026-03-28 14:42:48');
INSERT INTO `system_config` VALUES (22, 'dispatch_max_distance_km', '35', NULL, 8, '2026-03-31 17:34:47');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '手机号（登录账号）',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码（BCrypt加密）',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `role` tinyint NOT NULL COMMENT '角色：1=顾客 2=保洁员 3=平台管理员',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '账号状态：1=正常 2=待审核 3=停用 4=封禁',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_phone`(`phone` ASC) USING BTREE,
  INDEX `idx_role_status`(`role` ASC, `status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 54 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户账号表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (6, '13800000001', '{bcrypt}$2a$10$8xLtgkbjdRK9m5gDZlz8POVqGRLzChMmAWlWRspepN5TMXMcHRNza', '测试顾客', NULL, 1, 1, '2026-03-20 16:45:35', '2026-03-25 15:59:40');
INSERT INTO `user` VALUES (7, '13800000002', '{bcrypt}$2a$10$w1J2zBPHV8T8RbEky0UrJ.q6D/Kn5D17gXGG6bqzzWcpU2BRamnSG', '测试保洁员', NULL, 2, 1, '2026-03-20 16:45:35', '2026-03-25 15:59:40');
INSERT INTO `user` VALUES (8, '13800000003', '{bcrypt}$2a$10$6voEtKhn6WPfUEIgBp3u9ueWngOBRG4876x6SCR38J6YBvYyXOEKi', '平台管理员', NULL, 3, 1, '2026-03-20 16:45:35', '2026-03-25 15:59:40');
INSERT INTO `user` VALUES (10, '13800000004', '{bcrypt}$2a$10$lt8NdZ0kZ6aQ1By6Rt8w.eRW7KdnKRan7tHrWX74EyXBY0O0U5VFC', '测试保洁员2', NULL, 2, 1, '2026-03-21 15:39:29', '2026-03-25 15:59:40');
INSERT INTO `user` VALUES (11, '13800000005', '{bcrypt}$2a$10$1FrNZfTIbFkyMO.dCA6v9eViAbdQfYwL8qgETJDhPf26bhpiZe9pi', '王芳', NULL, 2, 1, '2026-03-22 22:52:57', '2026-03-25 15:59:40');
INSERT INTO `user` VALUES (12, '13900000001', '{bcrypt}$2a$10$jFHPxbCN0rZX55hZlohrquwusovx6z25ykLfffnhIdqsySfjJJ8dm', '陈志伟', NULL, 2, 1, '2026-03-22 23:01:29', '2026-03-25 15:59:40');
INSERT INTO `user` VALUES (13, '13833330001', '{noop}123456', '陈晓燕', NULL, 2, 1, '2026-03-25 15:33:40', '2026-03-25 15:54:38');
INSERT INTO `user` VALUES (14, '13833330002', '{noop}123456', '刘建国', NULL, 2, 1, '2026-03-25 15:40:32', '2026-03-25 15:54:38');
INSERT INTO `user` VALUES (15, '13833330003', '{noop}123456', '赵芳芳', NULL, 2, 1, '2026-03-25 15:40:32', '2026-03-25 15:54:38');
INSERT INTO `user` VALUES (16, '13833330004', '{noop}123456', '孙小梅', NULL, 2, 1, '2026-03-25 15:40:32', '2026-03-25 15:54:38');
INSERT INTO `user` VALUES (17, '13833330005', '{noop}123456', '吴伟', NULL, 2, 1, '2026-03-25 15:40:32', '2026-03-25 15:54:38');
INSERT INTO `user` VALUES (18, '13833330006', '{noop}123456', '郑丽丽', NULL, 2, 1, '2026-03-25 15:40:32', '2026-03-25 15:54:38');
INSERT INTO `user` VALUES (19, '13822220001', '{noop}123456', '李春花', NULL, 2, 1, '2026-03-25 15:40:32', '2026-03-25 15:54:38');
INSERT INTO `user` VALUES (20, '13822220002', '{noop}123456', '王大明', NULL, 2, 1, '2026-03-25 15:40:32', '2026-03-25 15:54:38');
INSERT INTO `user` VALUES (21, '13822220003', '{noop}123456', '张秀英', NULL, 2, 1, '2026-03-25 15:40:32', '2026-03-25 15:54:38');
INSERT INTO `user` VALUES (22, '13811110001', '{noop}123456', '小美', NULL, 1, 1, '2026-03-25 15:40:32', '2026-03-25 15:54:38');
INSERT INTO `user` VALUES (23, '13811110002', '{noop}123456', '张先生', NULL, 1, 1, '2026-03-25 15:40:32', '2026-03-25 15:54:38');
INSERT INTO `user` VALUES (24, '13838642233', '{bcrypt}$2a$10$IMX0nUUdMZIR6yFJw36WPujlU0iYfrG6N25/KK17MIR1NDlkEvTbS', '外部用户_2233', NULL, 1, 1, '2026-03-26 20:11:47', '2026-03-26 20:11:47');
INSERT INTO `user` VALUES (25, '13829955079', '{bcrypt}$2a$10$b.wCyKrEuf03WcyeMBe8suC1iPKyi0SSRsYPvRGgROnPQcREFVHQm', '外部用户_5079', NULL, 1, 1, '2026-03-26 20:11:47', '2026-03-26 20:11:47');
INSERT INTO `user` VALUES (26, '13814600320', '{bcrypt}$2a$10$b0i6ztAIRq555BlQrjvzy.AV6VpDRxio6.HhkApe9uRO94NbaCUfm', '外部用户_0320', NULL, 1, 1, '2026-03-26 20:11:47', '2026-03-26 20:11:47');
INSERT INTO `user` VALUES (27, '13831663231', '{bcrypt}$2a$10$PVsZ8txC1ew796GSWM9IPu9Pj8WuVGttttsmrOxHL8zx7b9StBZD2', '外部用户_3231', NULL, 1, 1, '2026-03-26 20:11:47', '2026-03-26 20:11:47');
INSERT INTO `user` VALUES (28, '13814875785', '{bcrypt}$2a$10$ygDCOxidrnrnDTyc4QVWNuU1bYVUoL2zvAJW6gJiNSDPcm8d.9ve2', '外部用户_5785', NULL, 1, 1, '2026-03-30 14:38:10', '2026-03-30 14:38:10');
INSERT INTO `user` VALUES (29, '13831979623', '{bcrypt}$2a$10$PYzY86NwcoOY2mFiHOe4GOHt4fQZEmy5nPDqUlX/2sEKaPS7Cr8qG', '外部用户_9623', NULL, 1, 1, '2026-03-30 14:38:10', '2026-03-30 14:38:10');
INSERT INTO `user` VALUES (30, '13870361234', '{bcrypt}$2a$10$2C8RayaTYqa1ledyj9RMa.MlGG36VguCtnm9BrC9xPC5LG2l/pPXS', '外部用户_1234', NULL, 1, 1, '2026-03-30 14:38:11', '2026-03-30 14:38:11');
INSERT INTO `user` VALUES (31, '13859339376', '{bcrypt}$2a$10$hoGdoVMDEuWpOrQOzNI9nOf/zpE/2jV2OpX5J3ochd67oCW/VyOxW', '外部用户_9376', NULL, 1, 1, '2026-03-30 14:38:11', '2026-03-30 14:38:11');
INSERT INTO `user` VALUES (32, '13824070887', '{bcrypt}$2a$10$pfA7SNIM2XZYtwZaRdessuvuAdt9KjuZyQYNyVuZaYjCIwHySrjgy', '外部用户_0887', NULL, 1, 1, '2026-03-31 14:52:10', '2026-03-31 14:52:10');
INSERT INTO `user` VALUES (33, '13866630245', '{bcrypt}$2a$10$Un/e/jVW4b7iG.gUEH8YHOVS3kcbpTrfYTqHSgulLTG0rFdEm/lpm', '外部用户_0245', NULL, 1, 3, '2026-03-31 14:52:10', '2026-03-31 14:52:10');
INSERT INTO `user` VALUES (34, '13849832215', '{bcrypt}$2a$10$uFT/Z0Dp.VTGDgit.AjBUO80VrHcF8HWC0.Lw6qZBaADowQmmOA8.', '外部用户_2215', NULL, 1, 1, '2026-03-31 14:52:10', '2026-03-31 14:52:10');
INSERT INTO `user` VALUES (35, '13821374865', '{bcrypt}$2a$10$owAofxAOi3rnlDwYlKx0yeo9Z0BI57Mo4KDIhcI4ZvY5sAgdQStmC', '外部用户_4865', NULL, 1, 1, '2026-03-31 14:52:10', '2026-03-31 14:52:10');
INSERT INTO `user` VALUES (36, '13818586235', '{bcrypt}$2a$10$P7vnOPGdk3R0SlbuqeLARultYcQa3GjAW.1M42u0w3sPyxmxMdHIy', '外部用户_6235', NULL, 1, 1, '2026-04-07 14:01:23', '2026-04-07 14:01:23');
INSERT INTO `user` VALUES (37, '13889473016', '{bcrypt}$2a$10$jZOlGW7qrCfiAxNxVUFSy.lt3miju7YLknO7HU4xnjbryrngrRWYK', '外部用户_3016', NULL, 1, 1, '2026-04-07 14:01:23', '2026-04-07 14:01:23');
INSERT INTO `user` VALUES (38, '13849980997', '{bcrypt}$2a$10$eoEHRSgVZ0g05Uu8EaZJoOi1ITzlnKvwPPm1rlWlEWqYd6j0589fu', '外部用户_0997', NULL, 1, 3, '2026-04-07 14:01:23', '2026-04-07 14:01:23');
INSERT INTO `user` VALUES (39, '13826816600', '{bcrypt}$2a$10$7UYRETG9WzOPfXso1l6Yp.C8ibg/E52PSMdMV3todw29PbJUR28hS', '外部用户_6600', NULL, 1, 1, '2026-04-07 14:01:23', '2026-04-07 14:01:23');
INSERT INTO `user` VALUES (40, '13821545968', '{bcrypt}$2a$10$ROxB7HdTL75TZTrOFCUIv.YHJTkikGx6Q1OwV79jNh1LXbM56iiPW', '外部用户_5968', NULL, 1, 1, '2026-04-07 14:05:31', '2026-04-07 14:05:31');
INSERT INTO `user` VALUES (41, '13868335067', '{bcrypt}$2a$10$FDaLijoNu4DKXBvXmxVAnO4Hn7jPN5Pl94mVIqjx3amBZjUm2S.ZO', '外部用户_5067', NULL, 1, 1, '2026-04-07 14:05:31', '2026-04-07 14:05:31');
INSERT INTO `user` VALUES (42, '13829718133', '{bcrypt}$2a$10$V5Wbi9ZQJjZOMFw8EAPsMuUb/eVl6/0aIg.HhbtxrnewhH52o4Vwa', '外部用户_8133', NULL, 1, 1, '2026-04-07 14:05:31', '2026-04-07 14:05:31');
INSERT INTO `user` VALUES (43, '13856199034', '{bcrypt}$2a$10$EMPsoNCzaOShg6C1eOD87eYseMt.jnruXjVQ2E4LC764pWamZa1uC', '外部用户_9034', NULL, 1, 1, '2026-04-07 14:05:32', '2026-04-07 14:05:32');
INSERT INTO `user` VALUES (44, '13833330007', '{bcrypt}$2a$10$U5RpIhtY7R2Sy0N.LdwWqubywuPFit2QxY45NN.w.1iMjU/lm2uzy', '王志', NULL, 2, 1, '2026-04-08 02:11:48', '2026-04-08 02:11:48');
INSERT INTO `user` VALUES (45, '13833330008', '{bcrypt}$2a$10$ELjmuLuAoGOf27YOjGeamOH.sQmdVZM/9gvsLU6vT9xiDhwXhKgI.', '顾客2', NULL, 1, 1, '2026-04-09 12:48:55', '2026-04-09 12:48:55');
INSERT INTO `user` VALUES (46, '13891787455', '{bcrypt}$2a$10$A5xLsIrQ/EoYCPuUzx3RDuZBNqbAprg1RDI76AH6if0fmnbQe4Ix2', '外部用户_7455', NULL, 1, 1, '2026-04-09 14:34:54', '2026-04-09 14:34:54');
INSERT INTO `user` VALUES (47, '13872717128', '{bcrypt}$2a$10$eBkJ3ByvSCIrTUMLHjYqDOAYS2C8kytVZ3JcF38ePkXQxrcpK9jwO', '外部用户_7128', NULL, 1, 1, '2026-04-09 14:34:55', '2026-04-09 14:34:55');
INSERT INTO `user` VALUES (48, '13888397534', '{bcrypt}$2a$10$GX8SQ7CUHAYCdNjUsShWGO3rdoBvSungo0CFBD8Mlijf5n5EQ1xzu', '外部用户_7534', NULL, 1, 1, '2026-04-09 14:34:55', '2026-04-09 14:34:55');
INSERT INTO `user` VALUES (49, '13811810269', '{bcrypt}$2a$10$Q3VrKse6X/IfbMAHyB33NuLNib/6LAb5J5ea4ievCjD74DX5dQJEe', '外部用户_0269', NULL, 1, 1, '2026-04-09 14:34:55', '2026-04-09 14:34:55');
INSERT INTO `user` VALUES (50, '13875561836', '{bcrypt}$2a$10$5.vvxDSOHFWrQinz4FUTl.uvTUsjJzZ66GSnDmz/7sawGp1Y3Q/Hu', '外部用户_1836', NULL, 1, 1, '2026-04-09 23:11:25', '2026-04-09 23:11:25');
INSERT INTO `user` VALUES (51, '13827886705', '{bcrypt}$2a$10$sQN5YUM2nDG.Bb7R.eet/uSEM4hcX6fRAFDLelvYTuS5vdGG9oBlS', '外部用户_6705', NULL, 1, 1, '2026-04-09 23:11:25', '2026-04-09 23:11:25');
INSERT INTO `user` VALUES (52, '13834174630', '{bcrypt}$2a$10$FaV7EKTpAd38TjWjOptOMOLepVmqm0aI4zstHh2SVzHd8Akrbjet6', '外部用户_4630', NULL, 1, 1, '2026-04-09 23:11:25', '2026-04-09 23:11:25');
INSERT INTO `user` VALUES (53, '13899241182', '{bcrypt}$2a$10$FtUn/.TmMCJ.Fn.VaM3rXeN89oOV/peGEz48D5xm5yrB9wdG.85ZO', '外部用户_1182', NULL, 1, 1, '2026-04-09 23:11:25', '2026-04-09 23:11:25');

SET FOREIGN_KEY_CHECKS = 1;
