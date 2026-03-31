package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 保洁员时段锁定表（已接单时间段，防止冲突）
 */
@Data
@TableName("cleaner_time_lock")
public class CleanerTimeLock implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long cleanerId;

    private Long orderId;

    /** 锁定开始时间（含通勤缓冲） */
    private LocalDateTime lockStart;

    /** 锁定结束时间（含通勤缓冲） */
    private LocalDateTime lockEnd;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
