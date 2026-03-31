package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * 保洁员每周固定档期模板
 */
@Data
@TableName("cleaner_schedule_template")
public class CleanerScheduleTemplate implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long cleanerId;

    /** 星期几：1=周一 ... 7=周日 */
    private Integer dayOfWeek;

    private LocalTime startTime;

    private LocalTime endTime;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
