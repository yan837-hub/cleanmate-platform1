package com.cleanmate.dto.order;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 顾客下单请求 DTO
 */
@Data
public class CreateOrderDTO {

    @NotNull(message = "请选择服务类型")
    private Long serviceTypeId;

    @NotNull(message = "请选择服务地址")
    private Long addressId;

    @NotNull(message = "请选择预约时间")
    @Future(message = "预约时间必须是未来时间")
    private LocalDateTime appointTime;

    /** 预约时长（分钟），按小时计费时必填 */
    private Integer planDuration;

    /** 房屋面积（㎡），按面积计费时必填 */
    private BigDecimal houseArea;

    private String remark;
}
