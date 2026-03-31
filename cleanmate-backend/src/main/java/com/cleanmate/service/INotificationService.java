package com.cleanmate.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.cleanmate.entity.Notification;

public interface INotificationService extends IService<Notification> {

    /** 发送站内通知 */
    void sendNotification(Long userId, Integer type, String title, String content, Long refId);
}
