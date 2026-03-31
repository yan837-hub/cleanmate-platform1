package com.cleanmate.controller.admin;

import com.cleanmate.common.Result;
import com.cleanmate.mapper.CleanerProfileMapper;
import com.cleanmate.mapper.ComplaintMapper;
import com.cleanmate.mapper.ServiceOrderMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.*;

/**
 * 管理员 - 统计看板控制器
 */
@RestController
@RequestMapping("/admin/stats")
@RequiredArgsConstructor
public class AdminStatController {

    private final ServiceOrderMapper    orderMapper;
    private final CleanerProfileMapper  cleanerProfileMapper;
    private final ComplaintMapper       complaintMapper;

    // ─────────────────────────────────────────────────────────────
    // 1. 首页概览
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/overview")
    public Result<Map<String, Object>> overview() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("todayNewOrders",      orderMapper.countTodayOrders());
        data.put("todayCompletedOrders",orderMapper.countTodayCompleted());
        data.put("ongoingOrders",       orderMapper.countOngoingOrders());

        BigDecimal revenue = orderMapper.sumTodayIncome();
        data.put("todayRevenue",        revenue != null ? revenue : BigDecimal.ZERO);

        data.put("totalCleaners",       cleanerProfileMapper.countCertifiedCleaners());
        data.put("activeCleaners",      cleanerProfileMapper.countActiveCleaners());
        data.put("pendingAudit",        cleanerProfileMapper.countPendingAudit());
        data.put("pendingDispatch",     orderMapper.countPendingDispatch());
        data.put("pendingComplaints",   complaintMapper.countPendingComplaints());
        data.put("processingComplaints",complaintMapper.countProcessingComplaints());
        data.put("closedComplaints",    complaintMapper.countClosedComplaints());
        return Result.success(data);
    }

    // ─────────────────────────────────────────────────────────────
    // 2. 趋势折线图（近 N 天）
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/trend")
    public Result<List<Map<String, Object>>> trend(
            @RequestParam(defaultValue = "7") int days) {

        List<Map<String, Object>> rows = orderMapper.selectTrendData(days);
        return Result.success(fillTrendDates(rows, days));
    }

    // ─────────────────────────────────────────────────────────────
    // 3. 服务类型占比（最近30天）
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/service-type")
    public Result<List<Map<String, Object>>> serviceType() {
        List<Map<String, Object>> rows = orderMapper.selectServiceTypeStats30Days();

        long total = rows.stream()
                .mapToLong(m -> ((Number) m.get("count")).longValue())
                .sum();

        if (total > 0) {
            for (Map<String, Object> m : rows) {
                long cnt = ((Number) m.get("count")).longValue();
                BigDecimal pct = BigDecimal.valueOf(cnt)
                        .divide(BigDecimal.valueOf(total), 4, RoundingMode.HALF_UP);
                m.put("percentage", pct);
            }
        }
        return Result.success(rows);
    }

    // ─────────────────────────────────────────────────────────────
    // 4. 保洁员绩效排名
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/cleaner-rank")
    public Result<List<Map<String, Object>>> cleanerRank(
            @RequestParam(defaultValue = "10") int limit) {

        List<Map<String, Object>> list = cleanerProfileMapper.selectCleanerRank(limit);
        return Result.success(list);
    }

    // ─────────────────────────────────────────────────────────────
    // 旧接口兼容（order-trend，前端旧版使用）
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/order-trend")
    public Result<List<Map<String, Object>>> orderTrend(
            @RequestParam(defaultValue = "7") int days) {
        return trend(days);
    }

    // ─────────────────────────────────────────────────────────────
    // 私有工具：补齐缺失日期，保证前端折线连续
    // ─────────────────────────────────────────────────────────────
    private List<Map<String, Object>> fillTrendDates(
            List<Map<String, Object>> rows, int days) {

        Map<String, Map<String, Object>> byDate = new LinkedHashMap<>();
        for (Map<String, Object> row : rows) {
            byDate.put(String.valueOf(row.get("date")), row);
        }

        List<Map<String, Object>> result = new ArrayList<>();
        LocalDate today = LocalDate.now();

        for (int i = days - 1; i >= 0; i--) {
            LocalDate day    = today.minusDays(i);
            String isoKey    = day.toString();           // yyyy-MM-dd（数据库键）
            String display   = day.getMonthValue() + "/" + day.getDayOfMonth(); // M/d

            if (byDate.containsKey(isoKey)) {
                Map<String, Object> row = new LinkedHashMap<>(byDate.get(isoKey));
                row.put("date", display);
                result.add(row);
            } else {
                Map<String, Object> empty = new LinkedHashMap<>();
                empty.put("date",            display);
                empty.put("newOrders",       0);
                empty.put("completedOrders", 0);
                empty.put("revenue",         BigDecimal.ZERO);
                result.add(empty);
            }
        }
        return result;
    }
}
