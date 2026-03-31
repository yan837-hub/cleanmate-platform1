package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 改期申请表
 */
@Data
@TableName("order_reschedule")
public class OrderReschedule implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long orderId;

    private Long customerId;

    /** 原预约时间 */
    private LocalDateTime oldTime;

    /** 申请改到的时间 */
    private LocalDateTime newTime;

    /**
     * 状态：1=待审核 2=已通过 3=已拒绝
     */
    private Integer status;

    private String handleRemark;

    private Long handledBy;

    private LocalDateTime handledAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
