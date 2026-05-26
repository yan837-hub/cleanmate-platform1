-- ================================================================
-- CleanMate 答辩演示数据  defense_demo.sql
-- 可重复执行：每次先清空旧演示数据再重新写入
-- 日期基准：以执行当天 CURDATE() 为"今天"，自动适配
--
-- 保洁员位置：重庆理工大学巴南校区周边（106.5197, 29.3789）
-- 5分钟演示流程（见文末注释）
-- ================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ─────────────────────────────────────────────
-- 0. 日期变量
-- ─────────────────────────────────────────────
SET @today     = '2026-05-26';   -- 答辩日期固定，重复执行结果不漂移
SET @yesterday = DATE_SUB(@today, INTERVAL 1 DAY);
SET @tomorrow  = DATE_ADD(@today, INTERVAL 1 DAY);
SET @day2      = DATE_ADD(@today, INTERVAL 2 DAY);
SET @day3      = DATE_ADD(@today, INTERVAL 3 DAY);
SET @day3ago   = DATE_SUB(@today, INTERVAL 3 DAY);
SET @day6ago   = DATE_SUB(@today, INTERVAL 6 DAY);
SET @day7ago   = DATE_SUB(@today, INTERVAL 7 DAY);

-- ─────────────────────────────────────────────
-- 1. 清理旧演示数据（按外键依赖顺序）
-- ─────────────────────────────────────────────
DELETE FROM cleaner_income    WHERE order_id  >= 2001;
DELETE FROM payment_record    WHERE order_id  >= 2001;
DELETE FROM fee_detail        WHERE order_id  >= 2001;
DELETE FROM service_photo     WHERE order_id  >= 2001;
DELETE FROM order_status_log  WHERE order_id  >= 2001;
DELETE FROM order_reschedule  WHERE order_id  >= 2001;
DELETE FROM complaint         WHERE order_id  >= 2001;
DELETE FROM order_review      WHERE order_id  >= 2001;
DELETE FROM checkin_record    WHERE order_id  >= 2001;
DELETE FROM dispatch_record   WHERE order_id  >= 2001;
DELETE FROM cleaner_time_lock WHERE order_id  >= 2001;
DELETE FROM notification      WHERE ref_id    >= 2001 OR ref_id IS NULL;
DELETE FROM service_order     WHERE id        >= 2001;
-- 清理外部导入自动注册的临时用户（id > 2002，即演示预设账号之外）
DELETE FROM user              WHERE id        >  2002;
-- 重置自增，保证每次演示订单号从同一起点开始
ALTER TABLE service_order AUTO_INCREMENT = 2001;
ALTER TABLE user          AUTO_INCREMENT = 2003;
DELETE FROM customer_address          WHERE user_id   BETWEEN 1001 AND 1004;
DELETE FROM cleaner_schedule_override WHERE cleaner_id BETWEEN 1005 AND 2002;
DELETE FROM cleaner_schedule_template WHERE cleaner_id BETWEEN 1005 AND 2002;
DELETE FROM cleaner_profile           WHERE user_id   BETWEEN 1005 AND 2002;
DELETE FROM user                      WHERE id        BETWEEN 1001 AND 2002;

-- ─────────────────────────────────────────────
-- 2. 用户账号（密码统一 123456）
--    role: 1=顾客  2=保洁员  3=管理员
--    status: 1=正常  2=待审核
-- ─────────────────────────────────────────────
INSERT INTO `user` (id, phone, password, nickname, role, status) VALUES
(1001, '15900000001', '{noop}123456', '系统管理员', 3, 1),
(1002, '15900000002', '{noop}123456', '李晓梅',     1, 1),
(1003, '15900000003', '{noop}123456', '王芳',       1, 1),
(1004, '15900000004', '{noop}123456', '陈思雨',     1, 1),
(1005, '15900000005', '{noop}123456', '张建国',     2, 1),
(1006, '15900000006', '{noop}123456', '李明',       2, 1),
(1007, '15900000007', '{noop}123456', '王秀英',     2, 1),
(1008, '15900000008', '{noop}123456', '赵丽丽',     2, 1),   -- 超出派单半径，手动派单演示用
(1009, '15900000009', '{noop}123456', '刘洋',       2, 1),
(2001, '15900000010', '{noop}123456', '赵军',       2, 2),   -- 待审核
(2002, '15900000011', '{noop}123456', '林小燕',     2, 2);   -- 待审核

-- ─────────────────────────────────────────────
-- 3. 保洁员档案（重理工巴南 106.5197,29.3789 为中心）
--    距离参考：1°纬度≈111km  1°经度≈96km（29°N）
--
--  张建国  106.5380,29.3920  ≈ 2.3km   评分4.90  → 自动派单首选
--  李明    106.5560,29.4060  ≈ 4.6km   评分4.75  → 次选
--  王秀英  106.4910,29.3510  ≈ 4.1km   评分4.68  → 有时段冲突（演示冲突检测）
--  赵丽丽  106.7880,29.7210  ≈ 46km    评分3.80  → 超出30km，仅出现在手动派单列表
--  刘洋    106.5270,29.3720  ≈ 1.0km   评分4.20  → 近但分低
-- ─────────────────────────────────────────────
INSERT INTO `cleaner_profile`
  (user_id, real_name, id_card,
   id_card_front, id_card_back, cert_img, health_cert_img,
   service_area, longitude, latitude, bio, skill_tags,
   avg_score, order_count, audit_status, audited_by, audited_at)
VALUES
(1005, '张建国', '50011019850315001X',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Front',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Back',
 'https://placehold.co/400x250/2196F3/white?text=Cert',
 'https://placehold.co/400x250/FF9800/white?text=Health',
 '重庆市巴南区', 106.5380, 29.3920,
 '从业8年，专注深度清洁与开荒保洁，用户满意率98%，获平台年度优秀保洁员称号',
 '深度清洁,开荒保洁,厨卫专项', 4.90, 186, 1, 1001, '2026-01-10 09:00:00'),

(1006, '李明', '50010219880620001X',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Front',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Back',
 'https://placehold.co/400x250/2196F3/white?text=Cert',
 'https://placehold.co/400x250/FF9800/white?text=Health',
 '重庆市巴南区', 106.5560, 29.4060,
 '细心负责，擅长日常保洁和专项清洁，每次准时到达',
 '普通保洁,专项清洁', 4.75, 134, 1, 1001, '2026-01-10 09:00:00'),

(1007, '王秀英', '50010319920318001X',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Front',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Back',
 'https://placehold.co/400x250/2196F3/white?text=Cert',
 'https://placehold.co/400x250/FF9800/white?text=Health',
 '重庆市南岸区', 106.4910, 29.3510,
 '服务细致耐心，擅长全屋深度保洁，口碑良好',
 '普通保洁,深度清洁', 4.68, 98, 1, 1001, '2026-01-10 09:00:00'),

-- 赵丽丽：渝北区，距重理工巴南 ≈46km，超出30km派单半径
-- 自动派单不会选中她；仅在管理员手动派单列表出现（演示兜底）
(1008, '赵丽丽', '50010819950122001X',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Front',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Back',
 'https://placehold.co/400x250/2196F3/white?text=Cert',
 'https://placehold.co/400x250/FF9800/white?text=Health',
 '重庆市渝北区', 106.7880, 29.7210,
 '工作认真负责，擅长日常保洁，接单积极',
 '普通保洁', 3.80, 22, 1, 1001, '2026-01-10 09:00:00'),

(1009, '刘洋', '50010919980301001X',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Front',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Back',
 'https://placehold.co/400x250/2196F3/white?text=Cert',
 'https://placehold.co/400x250/FF9800/white?text=Health',
 '重庆市巴南区', 106.5270, 29.3720,
 '入行2年，勤快踏实，努力提升服务质量',
 '普通保洁', 4.20, 55, 1, 1001, '2026-01-10 09:00:00'),

-- 待审核保洁员（演示管理员审核功能）
(2001, '赵军', '50011019900512001X',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Front',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Back',
 'https://placehold.co/400x250/2196F3/white?text=Cert',
 'https://placehold.co/400x250/FF9800/white?text=Health',
 '重庆市巴南区', 106.5100, 29.3850,
 '3年保洁经验，擅长厨卫深度清洁',
 '厨卫专项,深度清洁', 5.00, 0, 2, NULL, NULL),

(2002, '林小燕', '50010119960715001X',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Front',
 'https://placehold.co/400x250/4CAF50/white?text=ID-Back',
 'https://placehold.co/400x250/2196F3/white?text=Cert',
 'https://placehold.co/400x250/FF9800/white?text=Health',
 '重庆市巴南区', 106.5320, 29.3880,
 '新手保洁员，认真负责，善于沟通',
 '普通保洁', 5.00, 0, 2, NULL, NULL);

-- ─────────────────────────────────────────────
-- 3.5 保洁员周档期模板（全周 08:00-20:00）
--   缺少此数据 → isCleanerAvailable 返回 SCHEDULE_NOT_COVER → 候选人列表为空
--   覆盖审核通过的5名保洁员（1005-1009），待审核2001/2002不参与派单无需配置
-- ─────────────────────────────────────────────
INSERT INTO `cleaner_schedule_template` (cleaner_id, day_of_week, start_time, end_time) VALUES
(1005,1,'08:00:00','20:00:00'),(1005,2,'08:00:00','20:00:00'),(1005,3,'08:00:00','20:00:00'),
(1005,4,'08:00:00','20:00:00'),(1005,5,'08:00:00','20:00:00'),(1005,6,'08:00:00','20:00:00'),(1005,7,'08:00:00','20:00:00'),
(1006,1,'08:00:00','20:00:00'),(1006,2,'08:00:00','20:00:00'),(1006,3,'08:00:00','20:00:00'),
(1006,4,'08:00:00','20:00:00'),(1006,5,'08:00:00','20:00:00'),(1006,6,'08:00:00','20:00:00'),(1006,7,'08:00:00','20:00:00'),
(1007,1,'08:00:00','20:00:00'),(1007,2,'08:00:00','20:00:00'),(1007,3,'08:00:00','20:00:00'),
(1007,4,'08:00:00','20:00:00'),(1007,5,'08:00:00','20:00:00'),(1007,6,'08:00:00','20:00:00'),(1007,7,'08:00:00','20:00:00'),
(1008,1,'08:00:00','20:00:00'),(1008,2,'08:00:00','20:00:00'),(1008,3,'08:00:00','20:00:00'),
(1008,4,'08:00:00','20:00:00'),(1008,5,'08:00:00','20:00:00'),(1008,6,'08:00:00','20:00:00'),(1008,7,'08:00:00','20:00:00'),
(1009,1,'08:00:00','20:00:00'),(1009,2,'08:00:00','20:00:00'),(1009,3,'08:00:00','20:00:00'),
(1009,4,'08:00:00','20:00:00'),(1009,5,'08:00:00','20:00:00'),(1009,6,'08:00:00','20:00:00'),(1009,7,'08:00:00','20:00:00');

-- ─────────────────────────────────────────────
-- 4. 顾客地址（均在重理工巴南校区附近）
-- ─────────────────────────────────────────────
INSERT INTO `customer_address`
  (id, user_id, label, contact_name, contact_phone,
   province, city, district, detail, longitude, latitude, is_default)
VALUES
(1001, 1002, '学校', '李晓梅', '15900000002',
 '重庆市','重庆市','巴南区','红光大道69号重庆理工大学花溪校区1栋101',
 106.5197, 29.3789, 1),
(1002, 1003, '家', '王芳', '15900000003',
 '重庆市','重庆市','巴南区','李家沱兴隆路88号3单元601',
 106.5260, 29.3750, 1),
(1003, 1004, '宿舍', '陈思雨', '15900000004',
 '重庆市','重庆市','巴南区','花溪街道大江路156号2单元502',
 106.5120, 29.3820, 1);

-- ─────────────────────────────────────────────
-- 5. 服务类型（幂等）
-- ─────────────────────────────────────────────
INSERT IGNORE INTO `service_type`
  (id, name, description, price_mode, base_price, min_duration, suggest_workers, sort_order, status)
VALUES
(1,'普通保洁','日常居家清扫、拖地、擦拭台面，适合日常维护保洁',   1, 60.00, 120,1,100,1),
(2,'深度清洁','全屋深度清洁，含厨房油污、卫生间水垢专项处理',      2,  2.50,NULL,2, 90,1),
(3,'开荒保洁','新房/装修后首次清洁，墙面地板全面处理，套餐计价',   3,680.00,NULL,2, 80,1),
(4,'专项清洁','单项重点清洁：空调清洗/油烟机/地毯/沙发等',         1, 80.00,  60,1, 70,1);

-- ─────────────────────────────────────────────
-- 6. 系统参数（只补不覆盖）
-- ─────────────────────────────────────────────
INSERT IGNORE INTO `system_config` (config_key, config_value, description) VALUES
('commission_rate',          '0.20', '平台佣金比例，默认20%'),
('commute_buffer_minutes',   '30',   '派单通勤缓冲时间（分钟）'),
('dispatch_timeout_minutes', '30',   '保洁员接单响应超时时间'),
('deposit_rate',             '0.20', '定金比例，默认20%'),
('auto_confirm_hours',       '48',   '完工后自动确认等待时间'),
('checkin_max_distance_m',   '500',  'GPS签到允许最大偏差距离'),
('refund_deadline_hours',    '1',    '退单截止时间（小时）'),
('cleaner_cancel_hours',     '2',    '保洁员取消截止时间（服务前N小时）'),
('dispatch_max_distance_km', '30',   '最大派单半径（km）');

-- ─────────────────────────────────────────────
-- 7. 服务订单（9种状态全覆盖 + 兜底派单演示）
--
--  2001  待派单        明天10:00  李晓梅   →  演示：自动派单成功（张建国被选中）
--  2002  已派单待确认  明天14:00  王芳     →  演示：保洁员端接单
--  2003  已接单        后天09:00  陈思雨   →  展示已接单状态
--  2004  服务中        今天09:00  李晓梅   →  已签到，演示服务进行中
--  2005  待确认完成    昨天14:00  王芳     →  演示：顾客确认并评价
--  2006  已完成        6天前      陈思雨   →  含评价记录，展示历史
--  2007  售后中        3天前      李晓梅   →  含投诉+异常签到，演示售后处理
--  2008  已取消        2天前      王芳     →  完整性展示
--  2009  改期审核中    3天后      陈思雨   →  演示改期审核
--  2010  待派单(兜底)  明天16:00  王芳     →  演示：附近全部忙碌→兜底手动派单
--  2011-2013  已接单辅助订单，专门产生明天15:00-18:30时段锁
-- ─────────────────────────────────────────────

-- 【2001】待派单 - 自动派单演示（明天10:00，张建国会被系统选中）
INSERT INTO `service_order`
  (id,order_no,source,customer_id,cleaner_id,service_type_id,
   address_id,address_snapshot,longitude,latitude,
   house_area,plan_duration,appoint_time,remark,
   status,estimate_fee,deposit_fee,pay_status,created_at)
VALUES
(2001,'CM20260521001',1,1002,NULL,1,
 1001,'重庆市巴南区红光大道69号重庆理工大学花溪校区1栋101',106.5197,29.3789,
 80.0,120,TIMESTAMP(@tomorrow,'10:00:00'),'麻烦带上工具，门锁密码1234',
 1,120.00,24.00,1,DATE_SUB(NOW(),INTERVAL 20 MINUTE));

-- 【2002】已派单待确认 - 保洁员端接单演示（明天14:00，系统刚派给张建国）
INSERT INTO `service_order`
  (id,order_no,source,customer_id,cleaner_id,service_type_id,
   address_id,address_snapshot,longitude,latitude,
   house_area,plan_duration,appoint_time,remark,
   status,estimate_fee,deposit_fee,pay_status,created_at)
VALUES
(2002,'CM20260521002',1,1003,1005,1,
 1002,'重庆市巴南区李家沱兴隆路88号3单元601',106.5260,29.3750,
 90.0,120,TIMESTAMP(@tomorrow,'14:00:00'),'家里有老人，请轻声操作',
 2,120.00,24.00,1,DATE_SUB(NOW(),INTERVAL 8 MINUTE));

-- 【2003】已接单（后天09:00，李明）
INSERT INTO `service_order`
  (id,order_no,source,customer_id,cleaner_id,service_type_id,
   address_id,address_snapshot,longitude,latitude,
   house_area,plan_duration,appoint_time,remark,
   status,estimate_fee,deposit_fee,pay_status,created_at)
VALUES
(2003,'CM20260521003',1,1004,1006,2,
 1003,'重庆市巴南区花溪街道大江路156号2单元502',106.5120,29.3820,
 100.0,150,TIMESTAMP(@day2,'09:00:00'),'重点清洁厨房和卫生间',
 3,250.00,50.00,1,DATE_SUB(NOW(),INTERVAL 2 HOUR));

-- 【2004】服务中（今天09:00，刘洋已签到）
INSERT INTO `service_order`
  (id,order_no,source,customer_id,cleaner_id,service_type_id,
   address_id,address_snapshot,longitude,latitude,
   house_area,plan_duration,appoint_time,remark,
   status,estimate_fee,deposit_fee,pay_status,created_at)
VALUES
(2004,'CM20260521004',1,1002,1009,4,
 1001,'重庆市巴南区红光大道69号重庆理工大学花溪校区1栋101',106.5197,29.3789,
 NULL,90,TIMESTAMP(@today,'09:00:00'),'空调清洗+油烟机深度清洁',
 4,160.00,32.00,1,DATE_SUB(NOW(),INTERVAL 3 HOUR));

-- 【2005】待确认完成（昨天14:00，王秀英已完工，48h后自动确认=明天14:00）
INSERT INTO `service_order`
  (id,order_no,source,customer_id,cleaner_id,service_type_id,
   address_id,address_snapshot,longitude,latitude,
   house_area,plan_duration,actual_duration,appoint_time,
   status,estimate_fee,actual_fee,deposit_fee,pay_status,
   auto_confirm_at,created_at)
VALUES
(2005,'CM20260521005',1,1003,1007,1,
 1002,'重庆市巴南区李家沱兴隆路88号3单元601',106.5260,29.3750,
 80.0,120,115,TIMESTAMP(@yesterday,'14:00:00'),
 5,120.00,120.00,24.00,1,
 TIMESTAMP(@tomorrow,'14:00:00'),
 DATE_SUB(NOW(),INTERVAL 26 HOUR));

-- 【2006】已完成（6天前，张建国，含评价）
INSERT INTO `service_order`
  (id,order_no,source,customer_id,cleaner_id,service_type_id,
   address_id,address_snapshot,longitude,latitude,
   house_area,plan_duration,actual_duration,appoint_time,remark,
   status,estimate_fee,actual_fee,deposit_fee,pay_status,
   completed_at,created_at)
VALUES
(2006,'CM20260515001',1,1004,1005,3,
 1003,'重庆市巴南区花溪街道大江路156号2单元502',106.5120,29.3820,
 120.0,240,270,TIMESTAMP(@day6ago,'10:00:00'),'新房刚装修完，全屋开荒',
 6,680.00,680.00,136.00,2,
 TIMESTAMP(@day6ago,'14:30:00'),
 TIMESTAMP(@day7ago,'20:00:00'));

-- 【2007】售后中（3天前，李明，含投诉+异常签到）
INSERT INTO `service_order`
  (id,order_no,source,customer_id,cleaner_id,service_type_id,
   address_id,address_snapshot,longitude,latitude,
   house_area,plan_duration,actual_duration,appoint_time,
   status,estimate_fee,actual_fee,deposit_fee,pay_status,
   completed_at,created_at)
VALUES
(2007,'CM20260518001',1,1002,1006,1,
 1001,'重庆市巴南区红光大道69号重庆理工大学花溪校区1栋101',106.5197,29.3789,
 70.0,120,110,TIMESTAMP(@day3ago,'10:00:00'),
 7,120.00,120.00,24.00,1,
 TIMESTAMP(@day3ago,'12:00:00'),
 TIMESTAMP(DATE_SUB(@today,INTERVAL 4 DAY),'15:00:00'));

-- 【2008】已取消（昨天14:00，王芳顾客主动取消）
INSERT INTO `service_order`
  (id,order_no,source,customer_id,cleaner_id,service_type_id,
   address_id,address_snapshot,longitude,latitude,
   house_area,plan_duration,appoint_time,
   status,cancel_reason,estimate_fee,deposit_fee,pay_status,created_at)
VALUES
(2008,'CM20260519001',1,1003,NULL,2,
 1002,'重庆市巴南区李家沱兴隆路88号3单元601',106.5260,29.3750,
 100.0,150,TIMESTAMP(@yesterday,'14:00:00'),
 8,'临时有事，顾客主动取消',250.00,0.00,0,
 DATE_SUB(NOW(),INTERVAL 50 HOUR));

-- 【2009】改期审核中（3天后10:00，陈思雨，王秀英）
INSERT INTO `service_order`
  (id,order_no,source,customer_id,cleaner_id,service_type_id,
   address_id,address_snapshot,longitude,latitude,
   house_area,plan_duration,appoint_time,remark,
   status,estimate_fee,deposit_fee,pay_status,created_at)
VALUES
(2009,'CM20260521009',1,1004,1007,4,
 1003,'重庆市巴南区花溪街道大江路156号2单元502',106.5120,29.3820,
 NULL,90,TIMESTAMP(@day3,'10:00:00'),'需要清洗2台空调',
 9,160.00,32.00,1,DATE_SUB(NOW(),INTERVAL 5 HOUR));

-- 【2010】待派单-兜底演示（明天16:00，附近4名保洁员均有时段冲突）
-- 自动派单找不到可用人员 → 系统提示失败 → 管理员手动指定（可选赵丽丽46km）
INSERT INTO `service_order`
  (id,order_no,source,customer_id,cleaner_id,service_type_id,
   address_id,address_snapshot,longitude,latitude,
   house_area,plan_duration,appoint_time,
   status,estimate_fee,deposit_fee,pay_status,created_at)
VALUES
(2010,'CM20260521010',1,1003,NULL,1,
 1002,'重庆市巴南区李家沱兴隆路88号3单元601',106.5260,29.3750,
 80.0,120,TIMESTAMP(@tomorrow,'16:00:00'),
 1,120.00,24.00,1,NOW());

-- 【2014】待派单-抢单演示（后天10:00，张建国无时段冲突，可成功抢单）
INSERT INTO `service_order`
  (id,order_no,source,customer_id,cleaner_id,service_type_id,
   address_id,address_snapshot,longitude,latitude,
   house_area,plan_duration,appoint_time,
   status,estimate_fee,deposit_fee,pay_status,created_at)
VALUES
(2014,'CM20260521014',1,1004,NULL,1,
 1003,'重庆市巴南区花溪街道大江路156号2单元502',106.5120,29.3820,
 80.0,120,TIMESTAMP(@day2,'10:00:00'),
 1,120.00,24.00,1,DATE_SUB(NOW(),INTERVAL 3 MINUTE));

-- 【2011-2013】辅助订单：产生明天下午时段锁，用于兜底演示
-- 2011: 李明  明天15:00  → lock 14:30-17:30
-- 2012: 王秀英 明天15:30 → lock 15:00-17:30
-- 2013: 刘洋  明天16:00  → lock 15:30-18:30
-- （张建国已被 order 2002 锁定 13:30-16:30，16:00 处于冲突区间）
INSERT INTO `service_order`
  (id,order_no,source,customer_id,cleaner_id,service_type_id,
   address_id,address_snapshot,longitude,latitude,
   house_area,plan_duration,appoint_time,
   status,estimate_fee,deposit_fee,pay_status,created_at)
VALUES
(2011,'CM20260521011',1,1004,1006,1,
 1003,'重庆市巴南区花溪街道大江路156号2单元502',106.5120,29.3820,
 80.0,120,TIMESTAMP(@tomorrow,'15:00:00'),
 3,120.00,24.00,1,DATE_SUB(NOW(),INTERVAL 1 HOUR)),
(2012,'CM20260521012',1,1002,1007,4,
 1001,'重庆市巴南区红光大道69号重庆理工大学花溪校区1栋101',106.5197,29.3789,
 NULL,90,TIMESTAMP(@tomorrow,'15:30:00'),
 3,160.00,32.00,1,DATE_SUB(NOW(),INTERVAL 50 MINUTE)),
(2013,'CM20260521013',1,1003,1009,1,
 1002,'重庆市巴南区李家沱兴隆路88号3单元601',106.5260,29.3750,
 80.0,120,TIMESTAMP(@tomorrow,'16:00:00'),
 3,120.00,24.00,1,DATE_SUB(NOW(),INTERVAL 40 MINUTE));

-- ─────────────────────────────────────────────
-- 8. 派单记录
--    status: 1=待响应  2=已接单  3=已拒绝  4=已超时
--    dispatch_type: 1=系统自动  2=管理员手动  3=抢单
-- ─────────────────────────────────────────────
INSERT INTO `dispatch_record`
  (order_id,cleaner_id,dispatch_type,score,distance_km,status,respond_at,expire_at,operator_id)
VALUES
-- 2002：自动派给张建国，30min内等待确认
(2002,1005,1,4.52,2.28, 1,NULL, DATE_ADD(NOW(),INTERVAL 22 MINUTE),NULL),
-- 2003：自动派给李明，已接单
(2003,1006,1,4.35,4.60, 2,DATE_SUB(NOW(),INTERVAL 90 MINUTE),DATE_SUB(NOW(),INTERVAL 60 MINUTE),NULL),
-- 2004：自动派给刘洋，已接单
(2004,1009,1,3.87,1.04, 2,TIMESTAMP(@today,'07:35:00'),TIMESTAMP(@today,'08:05:00'),NULL),
-- 2006：自动派给张建国，已接单（历史）
(2006,1005,1,4.52,2.28, 2,TIMESTAMP(@day7ago,'08:30:00'),TIMESTAMP(@day7ago,'09:00:00'),NULL),
-- 2007：自动派给李明，已接单（历史）
(2007,1006,1,4.35,4.60, 2,TIMESTAMP(DATE_SUB(@today,INTERVAL 4 DAY),'08:25:00'),TIMESTAMP(DATE_SUB(@today,INTERVAL 4 DAY),'09:00:00'),NULL),
-- 2009：自动派给王秀英，已接单
(2009,1007,1,4.28,4.14, 2,DATE_SUB(NOW(),INTERVAL 4 HOUR),DATE_SUB(NOW(),INTERVAL 3 HOUR),NULL),
-- 2011-2013辅助
(2011,1006,1,4.35,4.60, 2,DATE_SUB(NOW(),INTERVAL 55 MINUTE),DATE_SUB(NOW(),INTERVAL 25 MINUTE),NULL),
(2012,1007,1,4.28,4.14, 2,DATE_SUB(NOW(),INTERVAL 45 MINUTE),DATE_SUB(NOW(),INTERVAL 15 MINUTE),NULL),
(2013,1009,1,3.87,1.04, 2,DATE_SUB(NOW(),INTERVAL 35 MINUTE),DATE_SUB(NOW(),INTERVAL 5 MINUTE),NULL);

-- ─────────────────────────────────────────────
-- 9. 时段锁（cleaner_time_lock）
--    锁区间 = 预约时间 - 30min 缓冲  →  预约时间 + 服务时长 + 30min 缓冲
-- ─────────────────────────────────────────────
INSERT INTO `cleaner_time_lock` (cleaner_id,order_id,lock_start,lock_end) VALUES
-- 张建国 → order 2002（明天14:00，120min）→ 13:30-16:30
(1005,2002, TIMESTAMP(@tomorrow,'13:30:00'), TIMESTAMP(@tomorrow,'16:30:00')),
-- 李明   → order 2003（后天09:00，150min）→ 08:30-12:00
(1006,2003, TIMESTAMP(@day2,'08:30:00'),    TIMESTAMP(@day2,'12:00:00')),
-- 刘洋   → order 2004（今天09:00，90min）→ 08:30-11:00
(1009,2004, TIMESTAMP(@today,'08:30:00'),   TIMESTAMP(@today,'11:00:00')),
-- 王秀英 → order 2005（昨天14:00，历史锁）
(1007,2005, TIMESTAMP(@yesterday,'13:30:00'),TIMESTAMP(@yesterday,'16:30:00')),
-- 王秀英 → order 2009（day3 10:00，90min）→ 09:30-12:00
(1007,2009, TIMESTAMP(@day3,'09:30:00'),    TIMESTAMP(@day3,'12:00:00')),
-- ↓ 以下4条专为"兜底演示"创造明天16:00时段的全员冲突 ↓
-- 李明   → order 2011（明天15:00，120min）→ 14:30-17:30  ← 与16:00重叠
(1006,2011, TIMESTAMP(@tomorrow,'14:30:00'), TIMESTAMP(@tomorrow,'17:30:00')),
-- 王秀英 → order 2012（明天15:30，90min）→ 15:00-17:30  ← 与16:00重叠
(1007,2012, TIMESTAMP(@tomorrow,'15:00:00'), TIMESTAMP(@tomorrow,'17:30:00')),
-- 刘洋   → order 2013（明天16:00，120min）→ 15:30-18:30  ← 与16:00重叠
(1009,2013, TIMESTAMP(@tomorrow,'15:30:00'), TIMESTAMP(@tomorrow,'18:30:00'));
-- 张建国的 order2002 锁（13:30-16:30）已覆盖明天16:00，无需额外添加

-- ─────────────────────────────────────────────
-- 10. 签到记录
--     is_abnormal: 0=正常  1=异常（偏差>500m）
-- ─────────────────────────────────────────────
INSERT INTO `checkin_record`
  (order_id,cleaner_id,checkin_time,longitude,latitude,distance_m,is_abnormal)
VALUES
-- 2004 刘洋 今天09:05 正常签到（偏差30m）
(2004,1009, TIMESTAMP(@today,'09:05:00'),     106.5200,29.3792, 30,  0),
-- 2005 王秀英 昨天13:58 正常签到（偏差25m）
(2005,1007, TIMESTAMP(@yesterday,'13:58:00'), 106.5261,29.3748, 25,  0),
-- 2006 张建国 6天前09:58 正常签到
(2006,1005, TIMESTAMP(@day6ago,'09:58:00'),   106.5121,29.3819, 15,  0),
-- 2007 李明 3天前异常签到（偏差654m，超出500m阈值）→ 管理员异常签到页面可见
(2007,1006, TIMESTAMP(@day3ago,'09:52:00'),   106.5247,29.3829, 654, 1);

-- ─────────────────────────────────────────────
-- 11. 服务照片
-- ─────────────────────────────────────────────
INSERT INTO `service_photo`
  (order_id,cleaner_id,phase,img_url,taken_at,longitude,latitude)
VALUES
-- 2004 服务中：服务前照片
(2004,1009,1,'https://placehold.co/800x600/607D8B/white?text=Before',
 TIMESTAMP(@today,'09:08:00'), 106.5200,29.3792),
-- 2006 已完成：服务后照片
(2006,1005,3,'https://placehold.co/800x600/4CAF50/white?text=After',
 TIMESTAMP(@day6ago,'14:20:00'), 106.5121,29.3819);

-- ─────────────────────────────────────────────
-- 12. 订单评价（order 2006 已完成）
-- ─────────────────────────────────────────────
INSERT INTO `order_review`
  (order_id,customer_id,cleaner_id,
   score_attitude,score_quality,score_punctual,avg_score,
   content,is_visible)
VALUES
(2006,1004,1005, 5,5,5,5.00,
 '张师傅非常专业，开荒保洁做得很细致，厨房卫生间都焕然一新，强烈推荐！',1);

-- ─────────────────────────────────────────────
-- 13. 投诉（order 2007 售后中，status=1待处理）
-- ─────────────────────────────────────────────
INSERT INTO `complaint`
  (order_id,customer_id,cleaner_id,reason,status)
VALUES
(2007,1002,1006,
 '保洁师傅清洁不彻底，地角线和窗台明显有灰尘，地板也没拖干净，希望退还部分费用',1);

-- ─────────────────────────────────────────────
-- 14. 改期申请（order 2009，status=1待审核）
-- ─────────────────────────────────────────────
INSERT INTO `order_reschedule`
  (order_id,customer_id,old_time,new_time,status)
VALUES
(2009,1004,
 TIMESTAMP(@day3,'10:00:00'),
 TIMESTAMP(DATE_ADD(@day3,INTERVAL 1 DAY),'14:00:00'),
 1);

-- ─────────────────────────────────────────────
-- 15. 费用明细
-- ─────────────────────────────────────────────
INSERT INTO `fee_detail`
  (order_id,service_fee,overtime_fee,coupon_deduct,actual_fee,
   deposit_fee,tail_fee,commission_rate,commission_fee,cleaner_income)
VALUES
-- 2005 待确认完成（普通保洁120）
(2005,120.00,0.00,0.00,120.00,  24.00, 96.00, 0.2000,24.00, 96.00),
-- 2006 已完成（开荒保洁680）
(2006,680.00,0.00,0.00,680.00, 136.00,544.00, 0.2000,136.00,544.00),
-- 2007 售后中（普通保洁120）
(2007,120.00,0.00,0.00,120.00,  24.00, 96.00, 0.2000,24.00, 96.00);

-- ─────────────────────────────────────────────
-- 16. 支付记录（pay_method=99 模拟支付）
--     pay_type: 1=定金  2=尾款  3=全额
--     pay_status: 2=成功
-- ─────────────────────────────────────────────
INSERT INTO `payment_record`
  (order_id,pay_type,amount,pay_method,pay_status,pay_time)
VALUES
(2001,1, 24.00,99,2,DATE_SUB(NOW(),INTERVAL 20 MINUTE)),
(2002,1, 24.00,99,2,DATE_SUB(NOW(),INTERVAL 10 MINUTE)),
(2003,1, 50.00,99,2,DATE_SUB(NOW(),INTERVAL 2 HOUR)),
(2004,1, 32.00,99,2,DATE_SUB(NOW(),INTERVAL 3 HOUR)),
(2005,1, 24.00,99,2,TIMESTAMP(@yesterday,'10:00:00')),
(2006,1,136.00,99,2,TIMESTAMP(@day7ago,'10:30:00')),
(2006,2,544.00,99,2,TIMESTAMP(@day6ago,'15:00:00')),
(2007,1, 24.00,99,2,TIMESTAMP(DATE_SUB(@today,INTERVAL 4 DAY),'11:00:00')),
(2009,1, 32.00,99,2,DATE_SUB(NOW(),INTERVAL 5 HOUR)),
(2010,1, 24.00,99,2,DATE_SUB(NOW(),INTERVAL 5 MINUTE)),
(2011,1, 24.00,99,2,DATE_SUB(NOW(),INTERVAL 55 MINUTE)),
(2012,1, 32.00,99,2,DATE_SUB(NOW(),INTERVAL 50 MINUTE)),
(2013,1, 24.00,99,2,DATE_SUB(NOW(),INTERVAL 45 MINUTE)),
-- 2014 抢单演示专用
(2014,1, 24.00,99,2,DATE_SUB(NOW(),INTERVAL 3 MINUTE));

-- ─────────────────────────────────────────────
-- 17. 保洁员收入（order 2006 已完成）
-- ─────────────────────────────────────────────
INSERT INTO `cleaner_income`
  (cleaner_id,order_id,amount,settle_month,status)
VALUES
(1005,2006,544.00,DATE_FORMAT(@day6ago,'%Y-%m'),1);

-- ─────────────────────────────────────────────
-- 18. 订单状态流转日志
-- ─────────────────────────────────────────────
INSERT INTO `order_status_log`
  (order_id,from_status,to_status,operator_id,remark)
VALUES
(2001,NULL,1,1002,'顾客下单'),
(2002,NULL,1,1003,'顾客下单'),
(2002,1,  2,NULL,'系统自动派单→张建国'),
(2003,NULL,1,1004,'顾客下单'),
(2003,1,  2,NULL,'系统自动派单→李明'),
(2003,2,  3,1006,'保洁员接单'),
(2004,NULL,1,1002,'顾客下单'),
(2004,1,  2,NULL,'系统自动派单→刘洋'),
(2004,2,  3,1009,'保洁员接单'),
(2004,3,  4,1009,'保洁员GPS签到，服务开始'),
(2005,NULL,1,1003,'顾客下单'),
(2005,1,  2,NULL,'系统自动派单→王秀英'),
(2005,2,  3,1007,'保洁员接单'),
(2005,3,  4,1007,'保洁员GPS签到，服务开始'),
(2005,4,  5,1007,'保洁员标记完成，等待顾客确认'),
(2006,NULL,1,1004,'顾客下单'),
(2006,1,  2,NULL,'系统自动派单→张建国'),
(2006,2,  3,1005,'保洁员接单'),
(2006,3,  4,1005,'保洁员GPS签到'),
(2006,4,  5,1005,'保洁员标记完成'),
(2006,5,  6,1004,'顾客确认完成并评价'),
(2007,NULL,1,1002,'顾客下单'),
(2007,1,  2,NULL,'系统自动派单→李明'),
(2007,2,  3,1006,'保洁员接单'),
(2007,3,  4,1006,'保洁员GPS签到'),
(2007,4,  5,1006,'保洁员标记完成'),
(2007,5,  7,1002,'顾客发起投诉，进入售后处理'),
(2008,NULL,1,1003,'顾客下单'),
(2008,1,  8,1003,'顾客主动取消订单'),
(2009,NULL,1,1004,'顾客下单'),
(2009,1,  2,NULL,'系统自动派单→王秀英'),
(2009,2,  3,1007,'保洁员接单'),
(2009,3,  9,1004,'顾客申请改期，待管理员审核'),
(2010,NULL,1,1003,'顾客下单'),
(2011,NULL,1,1004,'顾客下单'),
(2011,1,  2,NULL,'系统自动派单→李明'),
(2011,2,  3,1006,'保洁员接单'),
(2012,NULL,1,1002,'顾客下单'),
(2012,1,  2,NULL,'系统自动派单→王秀英'),
(2012,2,  3,1007,'保洁员接单'),
(2013,NULL,1,1003,'顾客下单'),
(2013,1,  2,NULL,'系统自动派单→刘洋'),
(2013,2,  3,1009,'保洁员接单'),
(2014,NULL,1,1004,'顾客下单');

-- ─────────────────────────────────────────────
-- 19. 站内通知
-- ─────────────────────────────────────────────
INSERT INTO `notification`
  (user_id,type,title,content,ref_id,is_read)
VALUES
(1002,1,'下单成功','订单 CM20260521001 已提交，等待平台派单',2001,1),
(1002,7,'投诉已受理','您对订单 CM20260518001 的投诉已受理，管理员将在24小时内处理',2007,0),
(1003,4,'服务完成待确认','订单 CM20260521005 保洁服务已完成，请确认并评价（48小时后自动确认）',2005,0),
(1005,5,'新订单待接','您有新的派单，订单 CM20260521002，请在30分钟内确认接单',2002,0),
(1001,7,'新投诉待处理','顾客李晓梅对订单 CM20260518001 发起投诉，请及时处理',2007,0),
(1001,6,'新保洁员待审核','赵军 已提交入职申请，请审核资料',NULL,0),
(1001,6,'新保洁员待审核','林小燕 已提交入职申请，请审核资料',NULL,0);

SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
-- 5分钟答辩演示流程建议
-- ================================================================
-- 【账号速查】
--   管理员：15900000001 / 123456
--   顾客：  15900000002(李晓梅)  15900000003(王芳)  / 123456
--   保洁员：15900000005(张建国)  15900000006(李明)  / 123456
--
-- 【推荐5分钟流程】
--
-- ①【管理员端 ~2min】
--   1. 打开订单管理 → 展示9种状态全覆盖
--   2. 找到"2001-李晓梅-明天10:00-待派单" → 点击"自动派单"
--      → 系统自动选中张建国（2.3km，评分4.90，综合得分最高）
--   3. 找到"2010-王芳-明天16:00-待派单" → 点击"自动派单"
--      → 提示"无可用保洁员"（张建国/李明/王秀英/刘洋均有时段冲突）
--      → 切换到手动派单 → 列表中可看到赵丽丽（距离46km，超出30km半径）
--      → 体现：自动派单智能排序 + 兜底手动机制
--   4. 点击投诉管理 → 找到李晓梅的投诉 → 处理（驳回/退款）
--   5. 点击异常签到 → 可看到李明签到偏差654m的记录（红色异常标记）
--
-- ②【保洁员端 ~1.5min】
--   登录 15900000005（张建国）
--   1. 消息通知 → 看到"CM20260521002 新订单待接"
--   2. 点击接单 → 订单状态变为"已接单"
--
-- ③【顾客端 ~1.5min】
--   登录 15900000003（王芳）
--   1. 我的订单 → 找到"CM20260521005-昨天-待确认完成"
--   2. 点击确认完成 → 弹出评价页 → 打分提交 → 状态变"已完成"
--   （顺带展示：若不操作，明天14:00系统自动确认）
--
-- 【兜底派单说明话术】
--   "当明天16:00的订单触发自动派单时，系统检测到附近4名保洁员
--    的时段锁均与该时间窗口重叠，无法自动匹配；
--    此时系统降级到手动派单模式，管理员可在候选列表中手动指定
--    保洁员，包括距离较远的赵丽丽（46km），体现了系统的灵活兜底能力。"
-- ================================================================
