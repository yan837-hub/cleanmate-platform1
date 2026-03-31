package com.cleanmate.vo.dispatch;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 候选保洁员 VO（管理员手动派单用）
 */
@Data
public class CandidateVO {

    private Long userId;

    private String realName;

    private String phone;

    /** 所属公司名，个人保洁员为"个人" */
    private String companyName;

    /** 综合评分 */
    private BigDecimal avgScore;

    /** 距离（km），来自上一单位置或常驻位置 */
    private Double distanceKm;

    /** 今日已接单数 */
    private Integer todayOrderCount;

    /** 上一单地址快照，无则为null */
    private String prevOrderAddress;

    /** 时间可行性：true=时间充裕，false=时间偏紧 */
    private Boolean timeFeasible;

    /** "有档期" / "时间紧张" */
    private String scheduleStatus;
}
