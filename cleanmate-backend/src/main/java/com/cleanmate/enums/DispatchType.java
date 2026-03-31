package com.cleanmate.enums;

import lombok.Getter;

/**
 * 派单方式枚举
 */
@Getter
public enum DispatchType {

    AUTO(1, "系统自动"),
    MANUAL(2, "管理员手动"),
    GRAB(3, "保洁员抢单");

    private final Integer code;
    private final String desc;

    DispatchType(Integer code, String desc) {
        this.code = code;
        this.desc = desc;
    }
}
