package com.cleanmate.enums;

import lombok.Getter;

/**
 * 通知类型枚举
 */
@Getter
public enum NotificationType {

    ORDER_CREATED(1, "下单成功"),
    ORDER_DISPATCHED(2, "派单成功"),
    CLEANER_CHECKIN(3, "保洁员上门"),
    SERVICE_COMPLETED(4, "服务完成"),
    NEW_ORDER_GRAB(5, "新订单待接"),
    AUDIT_RESULT(6, "审核结果"),
    COMPLAINT_NOTIFY(7, "投诉通知"),
    TIMEOUT_ALERT(8, "超时告警"),
    ORDER_REMINDER(9, "出行提醒"),
    RESCHEDULE_REQUEST(10, "改期申请"),
    RESCHEDULE_RESULT(11, "改期结果");

    private final Integer code;
    private final String desc;

    NotificationType(Integer code, String desc) {
        this.code = code;
        this.desc = desc;
    }
}
