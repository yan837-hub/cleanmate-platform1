package com.cleanmate.enums;

import lombok.Getter;

/**
 * 订单状态枚举
 */
@Getter
public enum OrderStatus {

    PENDING_DISPATCH(1, "待派单"),
    DISPATCHED_PENDING_CONFIRM(2, "已派单待确认"),
    ACCEPTED(3, "已接单"),
    IN_SERVICE(4, "服务中"),
    PENDING_COMPLETE_CONFIRM(5, "待确认完成"),
    COMPLETED(6, "已完成"),
    AFTER_SALE(7, "售后处理中"),
    CANCELLED(8, "已取消"),
    RESCHEDULING(9, "改期审核中");

    private final Integer code;
    private final String desc;

    OrderStatus(Integer code, String desc) {
        this.code = code;
        this.desc = desc;
    }

    public static OrderStatus of(Integer code) {
        for (OrderStatus status : values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        throw new IllegalArgumentException("未知订单状态: " + code);
    }
}
