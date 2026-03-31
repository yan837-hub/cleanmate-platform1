package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 站内消息通知表
 */
@Data
@TableName("notification")
public class Notification implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    /**
     * 通知类型：1=下单成功 2=派单成功 3=保洁员上门
     * 4=服务完成 5=新订单待接 6=审核结果 7=投诉通知 8=超时告警
     */
    private Integer type;

    private String title;

    private String content;

    /** 关联业务ID（如订单ID） */
    private Long refId;

    /** 是否已读：0=未读 1=已读 */
    private Integer isRead;

    private LocalDateTime readAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
