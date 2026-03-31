package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 面积阶梯定价表
 */
@Data
@TableName("service_price_tier")
public class ServicePriceTier implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long serviceTypeId;

    /** 面积下限（㎡，含） */
    private Integer areaMin;

    /** 面积上限（㎡，不含） */
    private Integer areaMax;

    /** 该区间单价（元/㎡） */
    private BigDecimal unitPrice;
}
