package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 顾客扩展信息表
 */
@Data
@TableName("customer_profile")
public class CustomerProfile implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 关联user.id */
    private Long userId;

    private String realName;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
