package com.cleanmate.scheduler;

import com.cleanmate.entity.CleanerIncome;
import com.cleanmate.entity.DispatchRecord;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.enums.OrderStatus;
import com.cleanmate.service.ICleanerIncomeService;
import com.cleanmate.service.IDispatchRecordService;
import com.cleanmate.service.IServiceOrderService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 自动确认完成调度器
 * 超时未确认订单自动结算，扫描周期从 system_config 读取
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AutoConfirmScheduler {

    private final IServiceOrderService orderService;
    private final IDispatchRecordService dispatchRecordService;
    private final ICleanerIncomeService cleanerIncomeService;

    @Scheduled(fixedRate = 3600_000) // 每小时执行一次
    public void autoConfirm() {
        List<ServiceOrder> orders = orderService.lambdaQuery()
                .eq(ServiceOrder::getStatus, OrderStatus.PENDING_COMPLETE_CONFIRM.getCode())
                .le(ServiceOrder::getAutoConfirmAt, LocalDateTime.now())
                .list();

        if (orders.isEmpty()) return;

        for (ServiceOrder order : orders) {
            try {
                order.setStatus(OrderStatus.COMPLETED.getCode());
                order.setCompletedAt(LocalDateTime.now());
                order.setPayStatus(2); // 系统强制结算，模拟支付完成
                orderService.updateById(order);
                orderService.logStatusChange(order.getId(),
                        OrderStatus.PENDING_COMPLETE_CONFIRM.getCode(),
                        OrderStatus.COMPLETED.getCode(),
                        null, "系统超时自动确认完成并结算");

                // 结算保洁员收入：待结算 → 已结算
                if (order.getCleanerId() != null) {
                    cleanerIncomeService.lambdaUpdate()
                            .eq(CleanerIncome::getOrderId, order.getId())
                            .set(CleanerIncome::getStatus, 2)
                            .set(CleanerIncome::getSettledAt, LocalDateTime.now())
                            .update();
                }
            } catch (Exception e) {
                log.error("[定时任务] 自动确认完成订单 {} 失败", order.getOrderNo(), e);
            }
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
                            .eq(DispatchRecord::getStatus, 1)
                            .set(DispatchRecord::getStatus, 4)
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
     * 派单超时：每分钟扫描
     * 派单待确认(状态2)超过 expireAt 未响应 → 退回待派单(状态1)
     */
    @Scheduled(fixedRate = 60_000)
    public void autoRejectExpiredDispatch() {
        List<DispatchRecord> expired = dispatchRecordService.lambdaQuery()
                .eq(DispatchRecord::getStatus, 1)
                .le(DispatchRecord::getExpireAt, LocalDateTime.now())
                .list();

        if (expired.isEmpty()) return;

        for (DispatchRecord dr : expired) {
            ServiceOrder order = orderService.getById(dr.getOrderId());
            if (order == null || !OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode().equals(order.getStatus())) {
                dispatchRecordService.lambdaUpdate()
                        .eq(DispatchRecord::getId, dr.getId())
                        .set(DispatchRecord::getStatus, 4)
                        .update();
                continue;
            }

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
                    null, "派单超时，自动退回待派单池");
        }
        log.info("派单超时自动退回完成");
    }
}
