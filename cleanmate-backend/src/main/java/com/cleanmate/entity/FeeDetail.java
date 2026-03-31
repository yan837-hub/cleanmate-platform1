package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单费用明细表
 */
@Data
@TableName("fee_detail")
public class FeeDetail implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long orderId;

    private BigDecimal serviceFee;

    private BigDecimal overtimeFee;

    private BigDecimal couponDeduct;

    private BigDecimal actualFee;

    private BigDecimal depositFee;

    private BigDecimal tailFee;

    /** 平台佣金比例（如0.2000=20%） */
    private BigDecimal commissionRate;

    private BigDecimal commissionFee;

    /** 保洁员实际收入 */
    private BigDecimal cleanerIncome;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
