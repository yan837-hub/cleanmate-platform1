package com.cleanmate.service;

import com.cleanmate.entity.CleanerIncome;
import com.cleanmate.entity.DispatchRecord;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.enums.OrderStatus;
import com.cleanmate.service.ICleanerIncomeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 定时任务：
 * 1. 派单30min超时 → dispatch_record 标记超时，订单退回待派单
 * 2. 48h 自动确认完成
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ScheduledTaskService {

    private final IServiceOrderService orderService;
    private final IDispatchRecordService dispatchRecordService;
    private final ICleanerIncomeService cleanerIncomeService;

    /**
     * 每分钟检查：派单30min未响应 → 超时处理
     */
    @Scheduled(fixedDelay = 60_000)
    @Transactional(rollbackFor = Exception.class)
    public void handleDispatchTimeout() {
        List<DispatchRecord> expired = dispatchRecordService.lambdaQuery()
                .eq(DispatchRecord::getStatus, 1)           // 待响应
                .lt(DispatchRecord::getExpireAt, LocalDateTime.now())
                .list();

        for (DispatchRecord record : expired) {
            // 标记派单记录为超时
            record.setStatus(4);
            record.setRespondAt(LocalDateTime.now());
            dispatchRecordService.updateById(record);

            // 订单退回待派单，清除保洁员
            ServiceOrder order = orderService.getById(record.getOrderId());
            if (order != null && order.getStatus().equals(OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode())) {
                order.setCleanerId(null);
                order.setStatus(OrderStatus.PENDING_DISPATCH.getCode());
                orderService.updateById(order);
                orderService.logStatusChange(record.getOrderId(),
                        OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode(),
                        OrderStatus.PENDING_DISPATCH.getCode(),
                        null, "派单30分钟超时，退回待派单池");
                log.info("订单[{}]派单超时，退回待派单池", record.getOrderId());
            }
        }
    }

    /**
     * 每5分钟检查：待确认完成且超过48h → 自动确认
     */
    @Scheduled(fixedDelay = 300_000)
    @Transactional(rollbackFor = Exception.class)
    public void handleAutoConfirm() {
        List<ServiceOrder> toConfirm = orderService.lambdaQuery()
                .eq(ServiceOrder::getStatus, OrderStatus.PENDING_COMPLETE_CONFIRM.getCode())
                .isNotNull(ServiceOrder::getAutoConfirmAt)
                .lt(ServiceOrder::getAutoConfirmAt, LocalDateTime.now())
                .list();

        for (ServiceOrder order : toConfirm) {
            order.setStatus(OrderStatus.COMPLETED.getCode());
            order.setCompletedAt(LocalDateTime.now());
            orderService.updateById(order);
            orderService.logStatusChange(order.getId(),
                    OrderStatus.PENDING_COMPLETE_CONFIRM.getCode(),
                    OrderStatus.COMPLETED.getCode(),
                    null, "超过48小时未确认，系统自动确认完成");
            // 结算保洁员收入：待结算 → 已结算
            if (order.getCleanerId() != null) {
                cleanerIncomeService.lambdaUpdate()
                        .eq(CleanerIncome::getOrderId, order.getId())
                        .set(CleanerIncome::getStatus, 2)
                        .set(CleanerIncome::getSettledAt, LocalDateTime.now())
                        .update();
            }
            log.info("订单[{}]48h自动确认完成", order.getId());
        }
    }
}
