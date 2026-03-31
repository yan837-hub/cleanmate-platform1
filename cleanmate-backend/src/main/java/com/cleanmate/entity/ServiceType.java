package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;

/**
 * 服务类型表
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("service_type")
public class ServiceType extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    private String description;

    private String coverImg;

    /** 计价模式：1=按小时 2=按面积 3=固定套餐 */
    private Integer priceMode;

    /** 基础单价 */
    private BigDecimal basePrice;

    /** 最短服务时长（分钟） */
    private Integer minDuration;

    /** 建议保洁员人数 */
    private Integer suggestWorkers;

    private Integer sortOrder;

    /** 状态：1=上架 2=下架 */
    private Integer status;
}
