package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 服务订单表
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("service_order")
public class ServiceOrder extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 订单编号（唯一） */
    private String orderNo;

    /** 订单来源：1=平台自有 2=外部导入 3=手动录入 */
    private Integer source;

    private Long customerId;

    private Long cleanerId;

    private Long serviceTypeId;

    private Long addressId;

    /** 下单时地址快照 */
    private String addressSnapshot;

    private BigDecimal longitude;

    private BigDecimal latitude;

    private BigDecimal houseArea;

    /** 预约服务时长（分钟） */
    private Integer planDuration;

    /** 实际服务时长（分钟） */
    private Integer actualDuration;

    /** 预约上门时间 */
    private LocalDateTime appointTime;

    private String remark;

    /**
     * 订单状态：
     * 1=待派单 2=已派单待确认 3=已接单
     * 4=服务中 5=待确认完成 6=已完成
     * 7=售后处理中 8=已取消
     */
    private Integer status;

    private String cancelReason;

    private BigDecimal estimateFee;

    private BigDecimal actualFee;

    private BigDecimal depositFee;

    /** 支付状态：0=未支付 1=已付定金 2=已全额支付 */
    private Integer payStatus;

    /** 48h自动确认时间 */
    private LocalDateTime autoConfirmAt;

    private LocalDateTime completedAt;
}
