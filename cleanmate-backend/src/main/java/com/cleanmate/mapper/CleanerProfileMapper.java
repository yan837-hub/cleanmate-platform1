package com.cleanmate.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cleanmate.entity.CleanerProfile;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface CleanerProfileMapper extends BaseMapper<CleanerProfile> {

    /** 已认证保洁员总数（audit_status=1） */
    @Select("SELECT COUNT(*) FROM cleaner_profile WHERE audit_status = 1")
    long countCertifiedCleaners();

    /** 待审核保洁员数（audit_status=2） */
    @Select("SELECT COUNT(*) FROM cleaner_profile WHERE audit_status = 2")
    long countPendingAudit();

    /**
     * 在线保洁员数：当前有进行中订单的保洁员（status=3已接单 或 status=4服务中）
     */
    @Select("""
        SELECT COUNT(DISTINCT cleaner_id)
        FROM service_order
        WHERE status IN (3, 4) AND cleaner_id IS NOT NULL
        """)
    long countActiveCleaners();

    /**
     * 保洁员综合绩效排名
     * 排序：平均评分降序 → 接单数降序
     */
    @Select("""
        SELECT
            cp.user_id                                          AS cleanerId,
            cp.real_name                                        AS realName,
            COALESCE(cc.name, '个人')                          AS companyName,
            COALESCE(cp.order_count, 0)                        AS orderCount,
            CAST(COALESCE(
                (SELECT COUNT(*) FROM service_order
                  WHERE cleaner_id = cp.user_id AND status = 6) * 1.0 /
                NULLIF(
                  (SELECT COUNT(*) FROM service_order
                    WHERE cleaner_id = cp.user_id AND status >= 3), 0),
            0) AS DECIMAL(4,2))                                AS completionRate,
            COALESCE(cp.avg_score, 0.00)                       AS avgScore,
            (SELECT COUNT(*) FROM complaint
              WHERE cleaner_id = cp.user_id)                   AS complaintCount,
            CAST(COALESCE(
                (SELECT SUM(amount) FROM cleaner_income
                  WHERE cleaner_id = cp.user_id
                    AND settle_month = DATE_FORMAT(NOW(), '%Y-%m')),
            0) AS DECIMAL(12,2))                               AS monthIncome
        FROM cleaner_profile cp
        LEFT JOIN cleaning_company cc ON cp.company_id = cc.id
        WHERE cp.audit_status = 1
        ORDER BY COALESCE(cp.avg_score, 0) DESC,
                 COALESCE(cp.order_count, 0) DESC
        LIMIT #{limit}
        """)
    List<Map<String, Object>> selectCleanerRank(@Param("limit") int limit);
}
