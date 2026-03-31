package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 投诉与售后表
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("complaint")
public class Complaint extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long orderId;

    private Long customerId;

    private Long cleanerId;

    private String reason;

    /** 证明照片URLs，逗号分隔 */
    private String imgs;

    /** 状态：1=待处理 2=处理中 3=已结案 */
    private Integer status;

    /** 判定结果：1=全额退款 2=驳回投诉 3=免费重做 4=部分退款 */
    private Integer result;

    /** 部分退款时的退款金额（result=4 时有值） */
    @TableField(exist = false)
    private java.math.BigDecimal refundAmount;

    private String adminRemark;

    private Long handledBy;

    private LocalDateTime handledAt;

    /** 关联订单金额（非数据库字段，由接口查询时填充，供管理员参考） */
    @TableField(exist = false)
    private java.math.BigDecimal orderActualFee;

    @TableField(exist = false)
    private java.math.BigDecimal orderEstimateFee;

    @TableField(exist = false)
    private String customerNickname;

    @TableField(exist = false)
    private String cleanerNickname;
}
