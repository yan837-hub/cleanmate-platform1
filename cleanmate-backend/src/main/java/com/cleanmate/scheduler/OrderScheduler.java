package com.cleanmate.scheduler;

import com.cleanmate.service.IServiceOrderService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 订单相关定时任务统一入口，业务逻辑均下沉至 IServiceOrderService
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OrderScheduler {

    private final IServiceOrderService orderService;

    /** 每10分钟：距预约约1小时的已接单订单，推送出行提醒给保洁员 */
    @Scheduled(fixedDelay = 10 * 60_000)
    public void handleUpcomingReminder() {
        int count = orderService.sendUpcomingReminders();
        if (count > 0) log.info("[定时任务] 发送出行提醒 {} 条", count);
    }

    /** 每15分钟：已接单但预约时间+2h未签到，自动取消并释放时段 */
    @Scheduled(fixedDelay = 15 * 60_000)
    public void handleCheckinTimeout() {
        int count = orderService.handleCheckinTimeout();
        if (count > 0) log.info("[定时任务] 超时未签到自动取消 {} 单", count);
    }

    /** 每5分钟：待派单或已派单但预约时间已过无人接单，自动取消 */
    @Scheduled(fixedDelay = 5 * 60_000)
    public void autoCancelExpiredUnacceptedOrders() {
        int count = orderService.autoCancelExpiredUnacceptedOrders();
        if (count > 0) log.info("[定时任务] 预约过期无人接单自动取消 {} 单", count);
    }

    /** 每5分钟：派单30min未响应，退回待派单池 */
    @Scheduled(fixedDelay = 5 * 60_000)
    public void handleDispatchTimeout() {
        int count = orderService.handleDispatchTimeout();
        if (count > 0) log.info("[定时任务] 派单超时退回 {} 条", count);
    }

    /** 每5分钟：待确认完成且超过48h，自动确认并结算 */
    @Scheduled(fixedDelay = 300_000)
    public void handleAutoConfirm() {
        int count = orderService.handleAutoConfirm();
        if (count > 0) log.info("[定时任务] 48h自动确认完成 {} 单", count);
    }
}
