package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 服务过程照片表
 */
@Data
@TableName("service_photo")
public class ServicePhoto implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long orderId;

    private Long cleanerId;

    /** 拍摄阶段：1=服务前 2=服务中 3=服务后 */
    private Integer phase;

    private String imgUrl;

    private LocalDateTime takenAt;

    private BigDecimal longitude;

    private BigDecimal latitude;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
