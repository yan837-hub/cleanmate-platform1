package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 保洁员签到打卡记录
 */
@Data
@TableName("checkin_record")
public class CheckinRecord implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long orderId;

    private Long cleanerId;

    private LocalDateTime checkinTime;

    private BigDecimal longitude;

    private BigDecimal latitude;

    /** 与订单地址偏差距离（米） */
    private Integer distanceM;

    /** 是否位置异常（偏差>500m）：1=是 */
    private Integer isAbnormal;

    private Long handledBy;

    private String handleRemark;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
