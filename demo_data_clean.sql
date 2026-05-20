-- ================================================================
-- CleanMate 答辩前数据清理脚本
-- 目标：删除白名单以外的所有用户及其关联数据
-- 保留白名单（共13个账号）：
--   6  13800000001 测试顾客
--   7  13800000002 测试保洁员
--   8  13800000003 平台管理员
--  10  13800000004 测试保洁员2
-- 1001 15900000001 系统管理员
-- 1002 15900000002 李晓梅
-- 1003 15900000003 王芳
-- 1004 15900000004 陈思雨
-- 1005 15900000005 张建国
-- 1006 15900000006 李明
-- 1007 15900000007 王秀英
-- 1008 15900000008 赵丽丽
-- 1009 15900000009 刘洋
-- ================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 执行前可先预览要删除的用户（确认无误后再跑完整脚本）:
-- SELECT id, phone, nickname, role FROM user
-- WHERE id NOT IN (6,7,8,10,1001,1002,1003,1004,1005,1006,1007,1008,1009) ORDER BY id;

-- ================================================================
-- Step 1：建临时表，锁定要删除的订单ID
-- （不再用 _del_user_ids 临时表，直接内联白名单，避免 MySQL 1137 错误）
-- ================================================================
DROP TEMPORARY TABLE IF EXISTS _del_order_ids;
CREATE TEMPORARY TABLE _del_order_ids AS
    SELECT id FROM service_order
    WHERE customer_id NOT IN (6, 7, 8, 10, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009)
       OR (cleaner_id IS NOT NULL
           AND cleaner_id NOT IN (6, 7, 8, 10, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009));

-- ================================================================
-- Step 2：删除与被清理用户订单相关的所有子表记录
-- ================================================================
DELETE FROM order_status_log  WHERE order_id IN (SELECT id FROM _del_order_ids);
DELETE FROM dispatch_record   WHERE order_id IN (SELECT id FROM _del_order_ids);
DELETE FROM checkin_record    WHERE order_id IN (SELECT id FROM _del_order_ids);
DELETE FROM fee_detail        WHERE order_id IN (SELECT id FROM _del_order_ids);
DELETE FROM payment_record    WHERE order_id IN (SELECT id FROM _del_order_ids);
DELETE FROM order_review      WHERE order_id IN (SELECT id FROM _del_order_ids);
DELETE FROM order_reschedule  WHERE order_id IN (SELECT id FROM _del_order_ids);
DELETE FROM complaint         WHERE order_id IN (SELECT id FROM _del_order_ids);
DELETE FROM service_photo     WHERE order_id IN (SELECT id FROM _del_order_ids);
DELETE FROM cleaner_income    WHERE order_id IN (SELECT id FROM _del_order_ids);
DELETE FROM cleaner_time_lock WHERE order_id IN (SELECT id FROM _del_order_ids);

-- ================================================================
-- Step 3：删除订单主记录
-- ================================================================
DELETE FROM service_order WHERE id IN (SELECT id FROM _del_order_ids);

-- ================================================================
-- Step 4：删除被清理用户的其他关联数据（非订单类，直接内联白名单）
-- ================================================================
DELETE FROM cleaner_profile           WHERE user_id     NOT IN (6, 7, 8, 10, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009);
DELETE FROM cleaner_schedule_template WHERE cleaner_id  NOT IN (6, 7, 8, 10, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009);
DELETE FROM cleaner_schedule_override WHERE cleaner_id  NOT IN (6, 7, 8, 10, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009);
DELETE FROM customer_address          WHERE user_id     NOT IN (6, 7, 8, 10, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009);
DELETE FROM notification              WHERE user_id     NOT IN (6, 7, 8, 10, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009);
DELETE FROM operation_log             WHERE operator_id NOT IN (6, 7, 8, 10, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009);

-- ================================================================
-- Step 5：删除用户本身
-- ================================================================
DELETE FROM user WHERE id NOT IN (6, 7, 8, 10, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009);

-- ================================================================
-- Step 6：清理临时表
-- ================================================================
DROP TEMPORARY TABLE IF EXISTS _del_order_ids;

SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
-- 验证结果（执行完后运行确认）
-- ================================================================
SELECT '=== 剩余用户 ===' AS info;
SELECT role, COUNT(*) AS cnt,
       CASE role WHEN 1 THEN '顾客' WHEN 2 THEN '保洁员' WHEN 3 THEN '管理员' END AS role_name
FROM user GROUP BY role;

SELECT '=== 剩余订单状态分布 ===' AS info;
SELECT status, COUNT(*) AS cnt FROM service_order GROUP BY status ORDER BY status;

SELECT '=== 确认只剩白名单用户 ===' AS info;
SELECT id, phone, nickname, role FROM user ORDER BY id;
