package com.cleanmate.task;

import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.entity.SystemConfig;
import com.cleanmate.enums.NotificationType;
import com.cleanmate.enums.OrderStatus;
import com.cleanmate.service.INotificationService;
import com.cleanmate.entity.Notification;
import com.cleanmate.service.IServiceOrderService;
import com.cleanmate.service.ISystemConfigService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 定时任务：扫描"待确认完成"订单，超过 auto_confirm_hours 后自动确认
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OrderAutoConfirmTask {

    private final IServiceOrderService   orderService;
    private final ISystemConfigService   configService;
    private final INotificationService   notificationService;

    /**
     * 每10分钟执行一次
     */
    @Scheduled(fixedDelay = 10 * 60 * 1000)
    public void autoConfirm() {
        // 读取等待时长配置，默认 24 小时
        SystemConfig cfg = configService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "auto_confirm_hours").one();
        long waitHours = cfg != null ? Long.parseLong(cfg.getConfigValue()) : 24L;

        LocalDateTime deadline = LocalDateTime.now().minusHours(waitHours);

        // 查找所有"待确认完成(5)"且完工时间已超过等待时长的订单
        List<ServiceOrder> orders = orderService.lambdaQuery()
                .eq(ServiceOrder::getStatus, OrderStatus.PENDING_COMPLETE_CONFIRM.getCode())
                .le(ServiceOrder::getCompletedAt, deadline)
                .list();

        if (orders.isEmpty()) return;

        log.info("[自动确认] 本次扫描到 {} 笔超时待确认订单", orders.size());

        for (ServiceOrder order : orders) {
            try {
                orderService.lambdaUpdate()
                        .eq(ServiceOrder::getId, order.getId())
                        .set(ServiceOrder::getStatus, OrderStatus.COMPLETED.getCode())
                        .update();

                orderService.logStatusChange(
                        order.getId(),
                        OrderStatus.PENDING_COMPLETE_CONFIRM.getCode(),
                        OrderStatus.COMPLETED.getCode(),
                        null,
                        "系统自动确认完成（超时 " + waitHours + " 小时未确认）"
                );

                // 通知顾客
                sendNotice(order.getCustomerId(),
                        "订单已自动确认",
                        "您的订单 #" + order.getOrderNo() + " 已超时自动确认完成，如有问题请联系客服");

                log.info("[自动确认] 订单 {} 已自动确认完成", order.getOrderNo());
            } catch (Exception e) {
                log.error("[自动确认] 订单 {} 处理失败: {}", order.getOrderNo(), e.getMessage());
            }
        }
    }

    private void sendNotice(Long userId, String title, String content) {
        try {
            Notification n = new Notification();
            n.setUserId(userId);
            n.setType(NotificationType.SERVICE_COMPLETED.getCode());
            n.setTitle(title);
            n.setContent(content);
            n.setIsRead(0);
            notificationService.save(n);
        } catch (Exception ignored) {}
    }
}
