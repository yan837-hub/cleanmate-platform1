package com.cleanmate.controller;

import com.cleanmate.common.Result;
import com.cleanmate.entity.Notification;
import com.cleanmate.service.INotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 消息通知控制器（顾客 + 保洁员通用，按 userId 隔离）
 */
@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final INotificationService notificationService;

    /** 查询消息列表（最近50条，按时间倒序） */
    @GetMapping
    public Result<List<Notification>> list(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        List<Notification> list = notificationService.lambdaQuery()
                .eq(Notification::getUserId, userId)
                .orderByDesc(Notification::getCreatedAt)
                .last("LIMIT 50")
                .list();
        return Result.success(list);
    }

    /** 未读数量（用于 badge） */
    @GetMapping("/unread-count")
    public Result<Long> unreadCount(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        long count = notificationService.lambdaQuery()
                .eq(Notification::getUserId, userId)
                .eq(Notification::getIsRead, 0)
                .count();
        return Result.success(count);
    }

    /** 全部标记已读 */
    @PutMapping("/read-all")
    public Result<Void> readAll(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        notificationService.lambdaUpdate()
                .eq(Notification::getUserId, userId)
                .eq(Notification::getIsRead, 0)
                .set(Notification::getIsRead, 1)
                .set(Notification::getReadAt, LocalDateTime.now())
                .update();
        return Result.success();
    }

    /** 单条标记已读 */
    @PutMapping("/{id}/read")
    public Result<Void> markRead(@PathVariable Long id, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        notificationService.lambdaUpdate()
                .eq(Notification::getId, id)
                .eq(Notification::getUserId, userId)
                .set(Notification::getIsRead, 1)
                .set(Notification::getReadAt, LocalDateTime.now())
                .update();
        return Result.success();
    }
}
