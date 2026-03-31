package com.cleanmate.vo.order;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单响应 VO
 */
@Data
public class OrderVO {

    private Long id;
    private String orderNo;
    private Integer status;
    private String statusDesc;
    private Integer source;
    private String sourceLabel;

    // 顾客信息
    private String customerNickname;

    // 服务信息
    private Long serviceTypeId;
    private String serviceTypeName;
    private Integer priceMode;

    // 地址信息
    private String addressSnapshot;
    private BigDecimal longitude;
    private BigDecimal latitude;

    // 时间信息
    private LocalDateTime appointTime;
    private Integer planDuration;
    private Integer actualDuration;

    // 费用信息
    private BigDecimal estimateFee;
    private BigDecimal actualFee;
    private Integer payStatus;

    // 保洁员信息（已派单后展示）
    private Long cleanerId;
    private String cleanerName;
    private String cleanerPhone;
    private String cleanerAvatar;
    private BigDecimal cleanerAvgScore;

    private String remark;
    private String cancelReason;
    private LocalDateTime completedAt;
    private LocalDateTime autoConfirmAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /** 投诉状态（仅 status=7 时填充）：1=待处理 2=处理中 3=已结案 */
    private Integer complaintStatus;
    /** 投诉判定结果：1=全额退款 2=驳回 3=免费重做 */
    private Integer complaintResult;

    /** 抢单池专用：保洁员与订单地址的距离（公里） */
    private Double distanceKm;
    /** 抢单池专用：预计保洁员收入（estimateFee × (1-commissionRate)） */
    private java.math.BigDecimal estimatedIncome;
}
