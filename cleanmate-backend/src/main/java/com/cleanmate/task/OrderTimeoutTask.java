package com.cleanmate.task;

import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.entity.User;
import com.cleanmate.enums.NotificationType;
import com.cleanmate.enums.OrderStatus;
import com.cleanmate.service.INotificationService;
import com.cleanmate.service.IServiceOrderService;
import com.cleanmate.service.IUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 订单超时处理定时任务
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OrderTimeoutTask {

    private final IServiceOrderService orderService;
    private final IUserService userService;
    private final INotificationService notificationService;

    /**
     * 每10分钟检查一次：距预约时间约1小时的已接单订单，推送出行提醒给保洁员
     */
    @Scheduled(fixedDelay = 10 * 60 * 1000)
    public void handleUpcomingReminder() {
        int count = orderService.sendUpcomingReminders();
        if (count > 0) log.info("[定时任务] 发送出行提醒 {} 条", count);
    }

    /**
     * 每15分钟检查一次：已接单但超时未签到（预约时间+2小时已过）的订单，自动取消并释放时段
     */
    @Scheduled(fixedDelay = 15 * 60 * 1000)
    public void handleCheckinTimeout() {
        LocalDateTime deadline = LocalDateTime.now().minusHours(2);

        List<ServiceOrder> overdueOrders = orderService.lambdaQuery()
                .eq(ServiceOrder::getStatus, OrderStatus.ACCEPTED.getCode())
                .le(ServiceOrder::getAppointTime, deadline)
                .list();

        if (overdueOrders.isEmpty()) return;

        log.warn("[定时任务] 发现 {} 个超时未签到订单，开始自动取消", overdueOrders.size());

        for (ServiceOrder order : overdueOrders) {
            try {
                order.setStatus(OrderStatus.CANCELLED.getCode());
                order.setCancelReason("保洁员超时未签到，系统自动取消");
                orderService.updateById(order);
                orderService.logStatusChange(
                        order.getId(),
                        OrderStatus.ACCEPTED.getCode(),
                        OrderStatus.CANCELLED.getCode(),
                        null,
                        "保洁员超时未签到（预约时间 " + order.getAppointTime() + "），系统自动取消"
                );

                // 通知管理员：保洁员超时未签到
                String msg = "订单 #" + order.getOrderNo() + " 已自动取消，原因：保洁员超时未签到。请尽快核查。";
                try {
                    userService.lambdaQuery().eq(User::getRole, 3).list()
                            .forEach(admin -> notificationService.sendNotification(
                                    admin.getId(),
                                    NotificationType.TIMEOUT_ALERT.getCode(),
                                    "保洁员未到场告警",
                                    msg,
                                    order.getId()));
                } catch (Exception ignored) {
                }

                log.info("[定时任务] 订单 {} 已自动取消（超时未签到）", order.getOrderNo());
            } catch (Exception e) {
                log.error("[定时任务] 自动取消订单 {} 失败", order.getOrderNo(), e);
            }
        }
    }

    /**
     * 每小时检查一次：待确认完成(status=5)且已超过48小时自动确认时间的订单，自动标记为已完成
     */
    @Scheduled(fixedDelay = 60 * 60 * 1000)
    public void handleAutoConfirm() {
        List<ServiceOrder> pendingConfirm = orderService.lambdaQuery()
                .eq(ServiceOrder::getStatus, OrderStatus.PENDING_COMPLETE_CONFIRM.getCode())
                .le(ServiceOrder::getAutoConfirmAt, LocalDateTime.now())
                .list();

        if (pendingConfirm.isEmpty()) return;

        log.info("[定时任务] 发现 {} 个待自动确认订单", pendingConfirm.size());

        for (ServiceOrder order : pendingConfirm) {
            try {
                order.setStatus(OrderStatus.COMPLETED.getCode());
                order.setCompletedAt(LocalDateTime.now());
                orderService.updateById(order);
                orderService.logStatusChange(
                        order.getId(),
                        OrderStatus.PENDING_COMPLETE_CONFIRM.getCode(),
                        OrderStatus.COMPLETED.getCode(),
                        null,
                        "顾客未在48小时内确认，系统自动完成"
                );
                log.info("[定时任务] 订单 {} 已自动确认完成", order.getOrderNo());
            } catch (Exception e) {
                log.error("[定时任务] 自动确认订单 {} 失败", order.getOrderNo(), e);
            }
        }
    }
}
