package com.cleanmate.dto.dispatch;

import lombok.Data;

/**
 * 管理员手动派单请求体
 */
@Data
public class ManualDispatchDTO {

    private Long orderId;

    private Long cleanerId;

    /** 派单备注（可选） */
    private String remark;
}
