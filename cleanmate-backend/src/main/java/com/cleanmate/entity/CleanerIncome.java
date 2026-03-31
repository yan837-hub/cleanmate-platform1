package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 保洁员收入明细表
 */
@Data
@TableName("cleaner_income")
public class CleanerIncome implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long cleanerId;

    private Long orderId;

    private BigDecimal amount;

    /** 结算月份（格式：2025-01） */
    private String settleMonth;

    /** 状态：1=待结算 2=已结算 */
    private Integer status;

    private LocalDateTime settledAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
