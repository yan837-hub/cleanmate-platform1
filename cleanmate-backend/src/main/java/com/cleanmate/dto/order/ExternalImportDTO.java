package com.cleanmate.dto.order;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 外部平台订单导入 / 管理员手动录入 共用 DTO
 */
@Data
public class ExternalImportDTO {

    /** 外部平台订单号（导入时填写，手动录入可为空） */
    private String platformOrderNo;

    /** 外部平台名称（导入时填写，手动录入可为空） */
    private String platformName;

    /** 顾客手机号（必填，用于匹配或自动创建用户） */
    private String customerPhone;

    /** 服务类型名称（模糊匹配，必填） */
    private String serviceTypeName;

    /** 服务地址详情（必填） */
    private String addressDetail;

    private BigDecimal longitude;

    private BigDecimal latitude;

    private BigDecimal houseArea;

    /** 预约时间，格式 yyyy-MM-dd HH:mm:ss */
    private String appointTime;

    private String remark;
}