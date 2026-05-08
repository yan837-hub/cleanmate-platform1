-- ============================================================
-- 派单调度演示数据
-- 用途：5.3.2 截图 —— 候选列表同时出现「有档期」和「时间紧张」标签
-- 目标订单：ORDER1001（2026-04-27 09:00，渝中区解放碑）
-- ============================================================

USE cleaning_service;

-- ============================================================
-- 场景一：「时间紧张」
-- 给张建国（user_id=1005）插一笔早班订单
--   预约时间：2026-04-27 07:00，时长 60 分钟 → 08:00 结束
--   服务地址：渝北区北部（经纬度约 106.65, 29.72），距渝中区约 20 km
--   时段锁：06:30 ~ 08:30（07:00 - 30min 缓冲 ~ 07:00 + 60 + 30 缓冲）
--
-- 派单算法评估 ORDER1001 时：
--   prevOrder 结束 = 08:00，gap = 60 min
--   通勤估算 = 20km / 30km/h × 60 = 40 min + 30 缓冲 = 70 min
--   60 < 70 → timeFeasible = false → 标签「时间紧张」(橙色)
--
-- 时段锁冲突检测（ORDER1001 lockStart=08:30）：
--   lock_end(08:30) > lockStart(08:30) → 严格大于 → FALSE → 不冲突
--   张建国通过过滤，出现在候选列表但标注「时间紧张」
-- ============================================================

-- 早班订单（已接单状态，让 prevOrder 查询能命中）
INSERT IGNORE INTO service_order (
    id, order_no, source, customer_id, cleaner_id, service_type_id,
    address_id, address_snapshot, longitude, latitude,
    house_area, plan_duration, actual_duration,
    appoint_time, remark, status,
    estimate_fee, actual_fee, deposit_fee, pay_status,
    auto_confirm_at, completed_at, created_at, updated_at
) VALUES (
    3001, 'CM20260427301', 1, 1003, 1005, 1001,
    NULL, '重庆市渝北区龙溪街道XX路88号', 106.6500, 29.7200,
    NULL, 60, NULL,
    '2026-04-27 07:00:00', NULL, 3,
    45.00, NULL, NULL, 1,
    NULL, NULL, '2026-04-26 20:00:00', '2026-04-26 20:00:00'
);

-- 对应时段锁：06:30 ~ 08:30
INSERT IGNORE INTO cleaner_time_lock (cleaner_id, order_id, lock_start, lock_end, created_at)
VALUES (1005, 3001, '2026-04-27 06:30:00', '2026-04-27 08:30:00', NOW());

-- ============================================================
-- 场景二：「已派单待确认 → 超时可重新派单」演示
-- ORDER1001 自动派单后进入 status=2，expireAt 设为过去（模拟超时）
-- 管理员在列表看到 status=2 的订单，可点「自动派单」或手动覆盖
--
-- 操作方式：先对 ORDER1001 执行一次自动派单，然后把 dispatch_record
-- 的 expire_at 手动改到过去，即可演示超时退回 + 再次派单场景
--
-- 如需立即演示，执行下面注释的 UPDATE（派单后再手动执行）：
-- UPDATE dispatch_record
--   SET expire_at = '2026-04-26 00:00:00'
--  WHERE order_id = 1001 AND status = 1
--  ORDER BY id DESC LIMIT 1;
-- ============================================================

-- ============================================================
-- 验证（执行后可用下面 SELECT 确认数据正确）
-- ============================================================
-- SELECT id, order_no, cleaner_id, status, appoint_time, longitude, latitude
--   FROM service_order WHERE id = 3001;
-- SELECT * FROM cleaner_time_lock WHERE cleaner_id = 1005 ORDER BY id DESC LIMIT 3;
