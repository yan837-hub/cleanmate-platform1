package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单评价表
 */
@Data
@TableName("order_review")
public class OrderReview implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long orderId;

    private Long customerId;

    private Long cleanerId;

    /** 服务态度评分（1-5） */
    private Integer scoreAttitude;

    /** 清洁效果评分（1-5） */
    private Integer scoreQuality;

    /** 准时到达评分（1-5） */
    private Integer scorePunctual;

    /** 综合评分（三项均值） */
    private BigDecimal avgScore;

    private String content;

    /** 评价图片URLs，逗号分隔 */
    private String imgs;

    /** 是否可见：1=可见 0=已屏蔽 */
    private Integer isVisible;

    private String hideReason;

    private Long hiddenBy;

    private String replyContent;

    private LocalDateTime repliedAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
