package com.cleanmate.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cleanmate.entity.ServiceOrder;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface ServiceOrderMapper extends BaseMapper<ServiceOrder> {

    /**
     * 今日新增订单数
     */
    @Select("SELECT COUNT(*) FROM service_order WHERE DATE(created_at) = CURDATE()")
    long countTodayOrders();

    /**
     * 今日完成订单数
     */
    @Select("SELECT COUNT(*) FROM service_order WHERE status = 6 AND DATE(completed_at) = CURDATE()")
    long countTodayCompleted();

    /**
     * 今日完成收入（actual_fee 优先，无则 estimate_fee）
     */
    @Select("""
        SELECT COALESCE(SUM(COALESCE(actual_fee, estimate_fee, 0)), 0)
        FROM service_order
        WHERE status = 6 AND DATE(completed_at) = CURDATE()
        """)
    java.math.BigDecimal sumTodayIncome();

    /**
     * 待派单数量
     */
    @Select("SELECT COUNT(*) FROM service_order WHERE status = 1")
    long countPendingDispatch();

    /**
     * 进行中订单数（status=3已接单 或 4=服务中）
     */
    @Select("SELECT COUNT(*) FROM service_order WHERE status IN (3, 4)")
    long countOngoingOrders();

    /**
     * 近 N 天每日趋势：新增数、完成数、收入
     * 字段名与前端协议一致：newOrders / completedOrders / revenue
     */
    @Select("""
        SELECT
            DATE(created_at)                                                          AS date,
            COUNT(*)                                                                  AS newOrders,
            SUM(CASE WHEN status = 6 THEN 1 ELSE 0 END)                              AS completedOrders,
            SUM(CASE WHEN status = 8 THEN 1 ELSE 0 END)                              AS cancelledOrders,
            CAST(COALESCE(SUM(CASE WHEN status = 6
                THEN COALESCE(actual_fee, estimate_fee, 0) END), 0) AS DECIMAL(12,2)) AS revenue
        FROM service_order
        WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL #{days} DAY)
        GROUP BY DATE(created_at)
        ORDER BY DATE(created_at) ASC
        """)
    List<Map<String, Object>> selectTrendData(@Param("days") int days);

    /**
     * 最近30天各服务类型订单占比
     * 字段名：serviceTypeName / count
     */
    @Select("""
        SELECT st.name AS serviceTypeName, COUNT(so.id) AS count
        FROM service_order so
        JOIN service_type st ON so.service_type_id = st.id
        WHERE so.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
        GROUP BY so.service_type_id, st.name
        ORDER BY count DESC
        """)
    List<Map<String, Object>> selectServiceTypeStats30Days();
}
