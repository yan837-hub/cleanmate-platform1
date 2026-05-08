-- ============================================================
-- 5.3.2 派单调度 —— 全场景演示数据
-- 今日基准：2026-04-27（周一）
-- ============================================================
-- 执行此文件后可截图的场景：
--
--  图5-38/39  点击 ORDER1001（待派单，明日09:00）
--             候选列表同时出现绿色「有档期」和橙色「时间紧张」
--
--  图5-40     对 ORDER1001 点「自动派单」→ 派单成功提示
--
--  图（无候选）点击 ORDER3002（待派单，夜间20:00）
--             候选列表为空，提示"暂无合适保洁员"
--
--  图（阻止）  点击 ORDER3003（已派单待确认，expireAt 未过）
--             点「自动派单」→ 报错"当前派单仍在响应期内"
--
--  图（覆盖）  同 ORDER3003，从候选列表点「指派」其他人
--             弹出「覆盖确认」警告弹窗
--
--  图5-41     ORDER3004（已派单待确认，expireAt 已过）
--             调度器1分钟内自动退回 status=1
--             管理员再次点「自动派单」→ 成功（超时退回后重新派单）
--
--  图5-42     对任意待派单订单，点候选列表中保洁员的「指派」
--             弹出手动指派确认弹窗（含备注输入）
-- ============================================================

USE cleaning_service;

-- ============================================================
-- ORDER3001：张建国早班订单
-- 目的：让张建国在 ORDER1001 候选列表中显示「时间紧张」（橙色）
-- 逻辑：
--   此单 07:00 开始，时长60分钟，08:00 结束
--   服务地址在渝北区北部（距渝中区约 20 km）
--   时段锁：06:30 ~ 08:30
--   ORDER1001 的 lockStart=08:30，lock_end(08:30) > lockStart(08:30) 严格大于 → FALSE
--   → 张建国通过时段锁过滤，但：
--     gap = 09:00 - 08:00 = 60 min
--     通勤 = 20km / 30km/h × 60 + 30缓冲 = 70 min
--     60 < 70 → timeFeasible=false → 标签「时间紧张」
-- ============================================================
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

INSERT IGNORE INTO cleaner_time_lock (cleaner_id, order_id, lock_start, lock_end, created_at)
VALUES (1005, 3001, '2026-04-27 06:30:00', '2026-04-27 08:30:00', NOW());

-- ============================================================
-- ORDER3002：无候选人演示订单
-- 目的：让候选列表为空，触发"暂无合适保洁员"提示
-- 逻辑：
--   预约 2026-04-28 20:00，时长120分钟
--   lockEnd = 20:00 + 120 + 30缓冲 = 22:30
--   serviceEnd = 22:00，超出所有保洁员模板 18:00 → 全部被档期过滤
-- ============================================================
INSERT IGNORE INTO service_order (
    id, order_no, source, customer_id, cleaner_id, service_type_id,
    address_id, address_snapshot, longitude, latitude,
    house_area, plan_duration, actual_duration,
    appoint_time, remark, status,
    estimate_fee, actual_fee, deposit_fee, pay_status,
    auto_confirm_at, completed_at, created_at, updated_at
) VALUES (
    3002, 'CM20260427302', 1, 1002, NULL, 1001,
    1001, '重庆市渝中区解放碑XX路1号6楼', 106.5516, 29.5559,
    NULL, 120, NULL,
    '2026-04-28 20:00:00', '夜间深度清洁', 1,
    90.00, NULL, NULL, 0,
    NULL, NULL, '2026-04-27 08:00:00', '2026-04-27 08:00:00'
);

-- ============================================================
-- ORDER3003：已派单待确认（expireAt 未过）
-- 目的①：点「自动派单」→ 报错"当前派单仍在响应期内"
-- 目的②：点候选列表「指派」→ 弹出「覆盖确认」警告弹窗
-- 注：expireAt 设为当前时间 + 2小时，截图需在2小时内完成
-- ============================================================
INSERT IGNORE INTO service_order (
    id, order_no, source, customer_id, cleaner_id, service_type_id,
    address_id, address_snapshot, longitude, latitude,
    house_area, plan_duration, actual_duration,
    appoint_time, remark, status,
    estimate_fee, actual_fee, deposit_fee, pay_status,
    auto_confirm_at, completed_at, created_at, updated_at
) VALUES (
    3003, 'CM20260427303', 1, 1003, 1006, 1001,
    1003, '重庆市南岸区南坪XX路5号18楼', 106.5711, 29.5205,
    NULL, 120, NULL,
    '2026-04-28 10:00:00', NULL, 2,
    90.00, NULL, NULL, 0,
    NULL, NULL, '2026-04-27 07:30:00', '2026-04-27 07:30:00'
);

INSERT IGNORE INTO dispatch_record
    (order_id, cleaner_id, dispatch_type, score, distance_km, status, respond_at, expire_at, operator_id, created_at)
VALUES
    (3003, 1006, 1, 88.50, 2.10, 1, NULL,
     DATE_ADD(NOW(), INTERVAL 2 HOUR),
     NULL, NOW());

-- ============================================================
-- ORDER3004：已派单待确认（expireAt 已过）
-- 目的：演示超时自动退回 → 重新派单
-- 逻辑：
--   dispatch_record.expireAt = 过去时间
--   后端调度器每分钟扫描，发现超时后：
--     → dispatch_record.status = 4（已超时）
--     → order.status 退回 1（待派单），cleaner_id 清空
--   管理员刷新左侧列表后可看到此订单变回「待派单」
--   再次点「自动派单」即可演示"超时退回后重新派单"
-- ============================================================
INSERT IGNORE INTO service_order (
    id, order_no, source, customer_id, cleaner_id, service_type_id,
    address_id, address_snapshot, longitude, latitude,
    house_area, plan_duration, actual_duration,
    appoint_time, remark, status,
    estimate_fee, actual_fee, deposit_fee, pay_status,
    auto_confirm_at, completed_at, created_at, updated_at
) VALUES (
    3004, 'CM20260427304', 1, 1004, 1007, 1001,
    1004, '重庆市沙坪坝区三峡广场XX路33号', 106.4625, 29.5428,
    NULL, 120, NULL,
    '2026-04-28 14:00:00', NULL, 2,
    90.00, NULL, NULL, 0,
    NULL, NULL, '2026-04-27 07:00:00', '2026-04-27 07:00:00'
);

INSERT IGNORE INTO dispatch_record
    (order_id, cleaner_id, dispatch_type, score, distance_km, status, respond_at, expire_at, operator_id, created_at)
VALUES
    (3004, 1007, 1, 74.20, 4.80, 1, NULL,
     '2026-04-27 07:30:00',
     NULL, '2026-04-27 07:00:00');

-- ============================================================
-- 演示顺序建议
-- ============================================================
-- 1. 执行本文件
-- 2. 点 ORDER1001 → 截图候选列表（有档期 + 时间紧张）         → 图5-38/39
-- 3. 对 ORDER1001 点「自动派单」→ 截图成功提示                → 图5-40
-- 4. 点 ORDER3002 → 截图候选列表为空                         → 图（无候选）
-- 5. 点 ORDER3003 → 点「自动派单」→ 截图报错提示              → 图（阻止）
-- 6. 点 ORDER3003 → 候选列表点「指派」→ 截图覆盖确认弹窗      → 图（覆盖）
-- 7. 等约1分钟 ORDER3004 被调度器退回 status=1 后
--    点 ORDER3004 → 点「自动派单」→ 截图成功                  → 图5-41
-- 8. 对任意 status=1 订单候选列表点「指派」→ 截图确认弹窗      → 图5-42
-- ============================================================
