package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 派单记录表
 */
@Data
@TableName("dispatch_record")
public class DispatchRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long orderId;

    private Long cleanerId;

    /** 派单方式：1=系统自动 2=管理员手动 3=保洁员抢单 */
    private Integer dispatchType;

    /** 系统自动派单时的综合得分 */
    private BigDecimal score;

    /** 估算距离（km） */
    private BigDecimal distanceKm;

    /** 状态：1=待响应 2=已接单 3=已拒绝 4=已超时 */
    private Integer status;

    private LocalDateTime respondAt;

    /** 响应截止时间（推送后30min） */
    private LocalDateTime expireAt;

    /** 手动派单的管理员user_id */
    private Long operatorId;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
