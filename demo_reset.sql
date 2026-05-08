-- ============================================================
-- 答辩前执行此脚本（约10秒），把所有演示状态一键归位
-- 使用方法：在 Navicat / MySQL Workbench 中直接运行全文
-- ============================================================

USE cleaning_service;

-- ============================================================
-- 第一步：清除截图过程中产生的投诉记录
-- ============================================================
DELETE FROM complaint WHERE order_id IN (1011, 1012, 1013);

-- ============================================================
-- 第二步：刷新投诉演示专用订单的状态和日期
-- 用 ON DUPLICATE KEY UPDATE 保证无论之前如何操作都能归位
-- ============================================================

-- 场景一：待确认完成（王芳，15900000003，可发起投诉）
INSERT INTO service_order (
    id, order_no, source, customer_id, cleaner_id, service_type_id,
    address_id, address_snapshot, longitude, latitude,
    house_area, plan_duration, actual_duration,
    appoint_time, remark, status,
    estimate_fee, actual_fee, deposit_fee, pay_status,
    auto_confirm_at, completed_at, created_at, updated_at
) VALUES (
    1011, 'CM20260426101', 1, 1003, 1006, 1001,
    1003, '重庆市南岸区南坪XX路5号18楼', 106.5711, 29.5205,
    NULL, 120, 130,
    DATE_SUB(NOW(), INTERVAL 1 DAY), '窗户需要重点擦拭', 5,
    90.00, 97.50, NULL, 1,
    DATE_ADD(NOW(), INTERVAL 2 DAY), NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()
) ON DUPLICATE KEY UPDATE
    status            = 5,
    completed_at      = NULL,
    auto_confirm_at   = DATE_ADD(NOW(), INTERVAL 2 DAY),
    updated_at        = NOW();

-- 场景二：已完成3天内（李晓梅，15900000002，7天内可投诉）
INSERT INTO service_order (
    id, order_no, source, customer_id, cleaner_id, service_type_id,
    address_id, address_snapshot, longitude, latitude,
    house_area, plan_duration, actual_duration,
    appoint_time, remark, status,
    estimate_fee, actual_fee, deposit_fee, pay_status,
    auto_confirm_at, completed_at, created_at, updated_at
) VALUES (
    1012, 'CM20260423101', 1, 1002, 1007, 1001,
    1001, '重庆市渝中区解放碑XX路1号6楼', 106.5516, 29.5559,
    NULL, 120, 118,
    DATE_SUB(NOW(), INTERVAL 3 DAY), NULL, 6,
    90.00, 88.50, NULL, 2,
    NULL, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)
) ON DUPLICATE KEY UPDATE
    status       = 6,
    completed_at = DATE_SUB(NOW(), INTERVAL 3 DAY),
    updated_at   = NOW();

-- 场景三：已完成10天（陈思雨，15900000004，超时拦截）
INSERT INTO service_order (
    id, order_no, source, customer_id, cleaner_id, service_type_id,
    address_id, address_snapshot, longitude, latitude,
    house_area, plan_duration, actual_duration,
    appoint_time, remark, status,
    estimate_fee, actual_fee, deposit_fee, pay_status,
    auto_confirm_at, completed_at, created_at, updated_at
) VALUES (
    1013, 'CM20260416101', 1, 1004, 1008, 1001,
    1004, '重庆市沙坪坝区三峡广场XX路33号', 106.4625, 29.5428,
    NULL, 120, 120,
    DATE_SUB(NOW(), INTERVAL 10 DAY), NULL, 6,
    90.00, 90.00, NULL, 2,
    NULL, DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY)
) ON DUPLICATE KEY UPDATE
    status       = 6,
    completed_at = DATE_SUB(NOW(), INTERVAL 10 DAY),
    updated_at   = NOW();

-- ============================================================
-- 第三步：重置截图过程中被确认/修改的其他订单
-- ============================================================

-- 1007 恢复为待确认完成（如截图时已确认完工）
UPDATE service_order
SET status = 5, completed_at = NULL, updated_at = NOW()
WHERE id = 1007 AND status != 5;

-- 1001/1002/1003 恢复为待派单（如截图时已手动派单）
UPDATE service_order
SET status = 1, cleaner_id = NULL, updated_at = NOW()
WHERE id IN (1001, 1002, 1003) AND status != 1;

-- ============================================================
-- 完成，可以开始答辩演示
-- ============================================================
SELECT '答辩数据已就绪' AS result;
