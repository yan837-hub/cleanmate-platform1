package com.cleanmate.exception;

import lombok.Getter;

/**
 * 业务错误码枚举
 */
@Getter
public enum ErrorCode {

    // 通用
    SUCCESS(200, "操作成功"),
    PARAM_ERROR(400, "参数错误"),
    UNAUTHORIZED(401, "请先登录"),
    FORBIDDEN(403, "无权限访问"),
    NOT_FOUND(404, "资源不存在"),
    SERVER_ERROR(500, "服务器内部错误"),

    // 用户相关
    USER_NOT_EXIST(1001, "用户不存在"),
    USER_ALREADY_EXIST(1002, "手机号已注册"),
    PASSWORD_ERROR(1003, "密码错误"),
    ACCOUNT_DISABLED(1004, "账号已停用"),
    ACCOUNT_PENDING(1005, "账号待审核"),

    // 订单相关
    ORDER_NOT_EXIST(2001, "订单不存在"),
    ORDER_STATUS_ERROR(2002, "订单状态异常，无法执行此操作"),
    ORDER_NOT_BELONG_TO_USER(2003, "无权操作此订单"),

    // 档期相关
    SCHEDULE_CONFLICT(3001, "时段冲突，保洁员该时段已有订单"),
    CLEANER_NOT_AVAILABLE(3002, "保洁员在该时段不可用"),

    // 派单相关
    DISPATCH_EXPIRED(4001, "抢单已超时"),
    DISPATCH_ALREADY_HANDLED(4002, "该派单记录已处理"),

    // 审核相关
    AUDIT_NOT_PENDING(5001, "该记录不在待审核状态"),

    // 文件相关
    FILE_UPLOAD_ERROR(6001, "文件上传失败"),
    FILE_TYPE_NOT_SUPPORT(6002, "不支持的文件类型"),

    // 签到相关
    CHECKIN_TOO_EARLY(7001, "签到过早，请在预约时间前1小时内签到"),
    CHECKIN_TOO_LATE(7002, "签到超时，已超过预约时间2小时");

    private final Integer code;
    private final String message;

    ErrorCode(Integer code, String message) {
        this.code = code;
        this.message = message;
    }
}
