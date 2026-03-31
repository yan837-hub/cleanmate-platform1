package com.cleanmate.enums;

import lombok.Getter;

/**
 * 用户角色枚举
 */
@Getter
public enum UserRole {

    CUSTOMER(1, "顾客"),
    CLEANER(2, "保洁员"),
    ADMIN(3, "平台管理员");

    private final Integer code;
    private final String desc;

    UserRole(Integer code, String desc) {
        this.code = code;
        this.desc = desc;
    }

    public static UserRole of(Integer code) {
        for (UserRole role : values()) {
            if (role.code.equals(code)) {
                return role;
            }
        }
        throw new IllegalArgumentException("未知角色代码: " + code);
    }

    public String getRoleName() {
        return "ROLE_" + this.name();
    }
}
