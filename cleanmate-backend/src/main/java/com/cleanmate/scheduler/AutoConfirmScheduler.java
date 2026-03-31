package com.cleanmate.scheduler;

import com.cleanmate.entity.DispatchRecord;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.enums.OrderStatus;
import com.cleanmate.service.IDispatchRecordService;
import com.cleanmate.service.IServiceOrderService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 48小时自动确认完成调度器
 * 每小时扫描一次处于"待确认完成"状态且已过期的订单
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AutoConfirmScheduler {

    private final IServiceOrderService orderService;
    private final IDispatchRecordService dispatchRecordService;

    @Scheduled(fixedRate = 3600_000) // 每小时执行一次
    public void autoConfirm() {
        List<ServiceOrder> orders = orderService.lambdaQuery()
                .eq(ServiceOrder::getStatus, OrderStatus.PENDING_COMPLETE_CONFIRM.getCode())
                .le(ServiceOrder::getAutoConfirmAt, LocalDateTime.now())
                .list();

        if (orders.isEmpty()) return;

        for (ServiceOrder order : orders) {
            order.setStatus(OrderStatus.COMPLETED.getCode());
            order.setCompletedAt(LocalDateTime.now());
            orderService.updateById(order);
            orderService.logStatusChange(order.getId(),
                    OrderStatus.PENDING_COMPLETE_CONFIRM.getCode(),
                    OrderStatus.COMPLETED.getCode(),
                    null, "系统48h自动确认完成");
        }
        log.info("自动确认完成订单 {} 单", orders.size());
    }

    /**
     * 预约时间已过但仍未接单 → 自动取消并退款
     * 每5分钟扫描：PENDING_DISPATCH(1) 或 DISPATCHED_PENDING_CONFIRM(2) 且 appointTime <= now
     */
    @Scheduled(fixedRate = 5 * 60_000)
    public void autoCancelUnacceptedExpiredOrders() {
        LocalDateTime now = LocalDateTime.now();

        List<ServiceOrder> expired = orderService.lambdaQuery()
                .in(ServiceOrder::getStatus,
                        OrderStatus.PENDING_DISPATCH.getCode(),
                        OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode())
                .le(ServiceOrder::getAppointTime, now)
                .list();

        if (expired.isEmpty()) return;

        log.warn("[定时任务] 发现 {} 个预约时间已过但未接单的订单，自动取消退款", expired.size());

        for (ServiceOrder order : expired) {
            try {
                int oldStatus = order.getStatus();
                order.setStatus(OrderStatus.CANCELLED.getCode());
                order.setCancelReason("预约时间已过，无人接单，系统自动取消退款");
                orderService.updateById(order);

                // 若已派单未确认，同步将派单记录标记为已取消
                if (OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode().equals(oldStatus)) {
                    dispatchRecordService.lambdaUpdate()
                            .eq(DispatchRecord::getOrderId, order.getId())
                            .eq(DispatchRecord::getStatus, 1) // 待响应
                            .set(DispatchRecord::getStatus, 4) // 超时/取消
                            .update();
                }

                orderService.logStatusChange(order.getId(), oldStatus,
                        OrderStatus.CANCELLED.getCode(), null,
                        "预约时间 " + order.getAppointTime() + " 已过，无人接单，系统自动取消退款");
                log.info("[定时任务] 订单 {} 已自动取消（预约时间已过无人接单）", order.getOrderNo());
            } catch (Exception e) {
                log.error("[定时任务] 自动取消订单 {} 失败", order.getOrderNo(), e);
            }
        }
    }

    /**
     * 30分钟派单超时：每分钟扫描一次
     * 派单待确认(状态2)超过 expireAt 未响应 → 退回待派单(状态1)
     */
    @Scheduled(fixedRate = 60_000)
    public void autoRejectExpiredDispatch() {
        // 找出所有超时未响应的派单记录（status=1 且 expireAt < now）
        List<DispatchRecord> expired = dispatchRecordService.lambdaQuery()
                .eq(DispatchRecord::getStatus, 1)
                .le(DispatchRecord::getExpireAt, LocalDateTime.now())
                .list();

        if (expired.isEmpty()) return;

        for (DispatchRecord dr : expired) {
            ServiceOrder order = orderService.getById(dr.getOrderId());
            if (order == null || !OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode().equals(order.getStatus())) {
                // 订单状态已变更，只标记派单记录为超时
                dispatchRecordService.lambdaUpdate()
                        .eq(DispatchRecord::getId, dr.getId())
                        .set(DispatchRecord::getStatus, 4) // 4=超时
                        .update();
                continue;
            }

            // 退回待派单
            order.setCleanerId(null);
            order.setStatus(OrderStatus.PENDING_DISPATCH.getCode());
            orderService.updateById(order);

            dispatchRecordService.lambdaUpdate()
                    .eq(DispatchRecord::getId, dr.getId())
                    .set(DispatchRecord::getStatus, 4)
                    .update();

            orderService.logStatusChange(order.getId(),
                    OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode(),
                    OrderStatus.PENDING_DISPATCH.getCode(),
                    null, "派单30分钟超时，自动退回待派单池");
        }
        log.info("派单超时自动退回 {} 单", expired.size());
    }
}
