package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 支付记录表
 */
@Data
@TableName("payment_record")
public class PaymentRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long orderId;

    /** 支付类型：1=定金 2=尾款 3=全额 */
    private Integer payType;

    private BigDecimal amount;

    /** 支付方式：1=微信 2=支付宝 99=模拟支付 */
    private Integer payMethod;

    /** 状态：1=待支付 2=成功 3=失败 */
    private Integer payStatus;

    private LocalDateTime payTime;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
