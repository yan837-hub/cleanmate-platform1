package com.cleanmate.controller.admin;

import com.cleanmate.common.Result;
import com.cleanmate.entity.Notification;
import com.cleanmate.service.INotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 管理后台消息/告警通知接口
 */
@RestController
@RequestMapping("/admin/notifications")
@RequiredArgsConstructor
public class AdminNotificationController {

    private final INotificationService notificationService;

    /**
     * 管理员查询通知（可选 type/isRead 过滤）
     */
    @GetMapping
    public Result<List<Notification>> list(@RequestParam(required = false) Integer type,
                                           @RequestParam(required = false) Integer isRead) {
        var query = notificationService.lambdaQuery();
        if (type != null) {
            query.eq(Notification::getType, type);
        }
        if (isRead != null) {
            query.eq(Notification::getIsRead, isRead);
        }
        var list = query.orderByDesc(Notification::getCreatedAt).last("LIMIT 200").list();
        return Result.success(list);
    }

    /**
     * 管理员标记通知已读
     */
    @PutMapping("/{id}/read")
    public Result<Void> markRead(@PathVariable Long id) {
        notificationService.lambdaUpdate()
                .eq(Notification::getId, id)
                .set(Notification::getIsRead, 1)
                .set(Notification::getReadAt, LocalDateTime.now())
                .update();
        return Result.success();
    }
}
