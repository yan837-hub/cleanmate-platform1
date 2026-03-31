package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * 保洁员档期特殊调整表（单日覆盖）
 */
@Data
@TableName("cleaner_schedule_override")
public class CleanerScheduleOverride implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long cleanerId;

    private LocalDate date;

    /** 是否全天不可接单：1=是 */
    private Integer isOff;

    private LocalTime startTime;

    private LocalTime endTime;

    private String remark;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
