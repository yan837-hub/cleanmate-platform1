package com.cleanmate.controller.cleaner;

import com.cleanmate.common.Result;
import com.cleanmate.entity.CleanerScheduleOverride;
import com.cleanmate.entity.CleanerScheduleTemplate;
import com.cleanmate.entity.CleanerTimeLock;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.exception.ErrorCode;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.service.ICleanerScheduleOverrideService;
import com.cleanmate.service.ICleanerScheduleTemplateService;
import com.cleanmate.service.ICleanerTimeLockService;
import com.cleanmate.service.IServiceOrderService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 保洁员端 - 档期管理控制器
 * 路由前缀：/cleaner/schedule
 */
@RestController
@RequestMapping("/cleaner/schedule")
@RequiredArgsConstructor
public class CleanerScheduleController {

    private final ICleanerScheduleTemplateService templateService;
    private final ICleanerScheduleOverrideService overrideService;
    private final ICleanerTimeLockService timeLockService;
    private final IServiceOrderService orderService;

    // ───────────────────────── 周模板 ─────────────────────────

    /**
     * GET /cleaner/schedule/template
     * 返回当前保洁员周一到周日的时段设置（无设置的天返回 isWork:false）
     */
    @GetMapping("/template")
    public Result<List<TemplateDayVO>> getTemplate(Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();

        List<CleanerScheduleTemplate> records = templateService.lambdaQuery()
                .eq(CleanerScheduleTemplate::getCleanerId, cleanerId)
                .orderByAsc(CleanerScheduleTemplate::getDayOfWeek)
                .list();

        Map<Integer, CleanerScheduleTemplate> templateMap = records.stream()
                .collect(Collectors.toMap(CleanerScheduleTemplate::getDayOfWeek, t -> t));

        List<TemplateDayVO> result = new ArrayList<>();
        for (int day = 1; day <= 7; day++) {
            TemplateDayVO vo = new TemplateDayVO();
            vo.setDayOfWeek(day);
            CleanerScheduleTemplate t = templateMap.get(day);
            if (t != null) {
                vo.setIsWork(true);
                vo.setStartTime(t.getStartTime().toString()); // "09:00"
                vo.setEndTime(t.getEndTime().toString());
            } else {
                vo.setIsWork(false);
            }
            result.add(vo);
        }
        return Result.success(result);
    }

    /**
     * PUT /cleaner/schedule/template
     * 全量替换保存：isWork=false 的天删除记录，isWork=true 的天写入
     */
    @PutMapping("/template")
    @Transactional(rollbackFor = Exception.class)
    public Result<Void> saveTemplate(@RequestBody List<TemplateDayReq> days,
                                     Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();

        // 全量删除该保洁员现有模板
        templateService.lambdaUpdate()
                .eq(CleanerScheduleTemplate::getCleanerId, cleanerId)
                .remove();

        // 重新插入 isWork=true 的记录
        List<CleanerScheduleTemplate> toSave = days.stream()
                .filter(d -> Boolean.TRUE.equals(d.getIsWork()))
                .map(d -> {
                    if (d.getStartTime() == null || d.getEndTime() == null) {
                        throw new BusinessException(ErrorCode.PARAM_ERROR);
                    }
                    CleanerScheduleTemplate t = new CleanerScheduleTemplate();
                    t.setCleanerId(cleanerId);
                    t.setDayOfWeek(d.getDayOfWeek());
                    t.setStartTime(LocalTime.parse(d.getStartTime()));
                    t.setEndTime(LocalTime.parse(d.getEndTime()));
                    return t;
                })
                .collect(Collectors.toList());

        if (!toSave.isEmpty()) {
            templateService.saveBatch(toSave);
        }
        return Result.success();
    }

    // ───────────────────────── 特殊调整（Override） ─────────────────────────

    /**
     * GET /cleaner/schedule/overrides?month=2025-01
     * 返回某月所有特殊调整列表（month 不传则默认当月）
     */
    @GetMapping("/overrides")
    public Result<List<CleanerScheduleOverride>> getOverrides(
            @RequestParam(required = false) String month,
            Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();

        String targetMonth = (month != null && !month.isBlank())
                ? month
                : LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));

        LocalDate start = LocalDate.parse(targetMonth + "-01");
        LocalDate end   = start.plusMonths(1).minusDays(1);

        List<CleanerScheduleOverride> list = overrideService.lambdaQuery()
                .eq(CleanerScheduleOverride::getCleanerId, cleanerId)
                .ge(CleanerScheduleOverride::getDate, start)
                .le(CleanerScheduleOverride::getDate, end)
                .orderByAsc(CleanerScheduleOverride::getDate)
                .list();

        return Result.success(list);
    }

    /**
     * POST /cleaner/schedule/overrides
     * 新增或更新某天的特殊调整（同一保洁员同一日期存在则更新）
     * 入参：{date:"2025-01-15", isOff:1, remark:"请假"}
     *    或：{date:"2025-01-15", isOff:0, startTime:"14:00", endTime:"18:00", remark:""}
     */
    @PostMapping("/overrides")
    @Transactional(rollbackFor = Exception.class)
    public Result<Void> saveOverride(@RequestBody OverrideReq req,
                                     Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        if (req.getDate() == null) throw new BusinessException(ErrorCode.PARAM_ERROR);

        LocalDate date = LocalDate.parse(req.getDate());

        // isOff=0（自定义时段）时必须提供起止时间
        if (req.getIsOff() != null && req.getIsOff() == 0) {
            if (req.getStartTime() == null || req.getEndTime() == null) {
                throw new BusinessException(ErrorCode.PARAM_ERROR);
            }
        }

        // 查是否已有该日期的记录（有则更新，无则新增）
        CleanerScheduleOverride existing = overrideService.lambdaQuery()
                .eq(CleanerScheduleOverride::getCleanerId, cleanerId)
                .eq(CleanerScheduleOverride::getDate, date)
                .one();

        if (existing == null) {
            existing = new CleanerScheduleOverride();
            existing.setCleanerId(cleanerId);
            existing.setDate(date);
        }

        existing.setIsOff(req.getIsOff() != null ? req.getIsOff() : 1);
        existing.setRemark(req.getRemark());

        if (existing.getIsOff() == 0) {
            existing.setStartTime(LocalTime.parse(req.getStartTime()));
            existing.setEndTime(LocalTime.parse(req.getEndTime()));
        } else {
            // 全天不可接单，清空时间字段
            existing.setStartTime(null);
            existing.setEndTime(null);
        }

        if (existing.getId() == null) {
            overrideService.save(existing);
        } else {
            overrideService.updateById(existing);
        }
        return Result.success();
    }

    /**
     * DELETE /cleaner/schedule/overrides/{id}
     * 删除特殊调整（只能删除自己的记录）
     */
    @DeleteMapping("/overrides/{id}")
    public Result<Void> deleteOverride(@PathVariable Long id, Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        CleanerScheduleOverride override = overrideService.getById(id);
        if (override == null || !cleanerId.equals(override.getCleanerId())) {
            throw new BusinessException(ErrorCode.FORBIDDEN);
        }
        overrideService.removeById(id);
        return Result.success();
    }

    // ───────────────────────── 时段锁定日期（供日历角标） ─────────────────────────

    /**
     * GET /cleaner/schedule/locks?month=2025-01
     * 返回当月有效时段锁定列表（排除已完成/已取消订单，仅展示今天及未来）
     * 返回：[{date, startTime, endTime}, ...]，同一天可有多条
     */
    @GetMapping("/locks")
    public Result<List<LockSlotVO>> getLockedDates(
            @RequestParam(required = false) String month,
            Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();

        String targetMonth = (month != null && !month.isBlank())
                ? month
                : LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));

        LocalDate monthStart = LocalDate.parse(targetMonth + "-01");
        LocalDate monthEnd   = monthStart.plusMonths(1).minusDays(1);
        // 只展示今天及之后的锁定（过去的已完成单无需再显示）
        LocalDate today = LocalDate.now();
        LocalDate effectiveStart = monthStart.isBefore(today) ? today : monthStart;

        List<CleanerTimeLock> locks = timeLockService.lambdaQuery()
                .eq(CleanerTimeLock::getCleanerId, cleanerId)
                .ge(CleanerTimeLock::getLockStart, effectiveStart.atStartOfDay())
                .le(CleanerTimeLock::getLockStart, monthEnd.atTime(23, 59, 59))
                .orderByAsc(CleanerTimeLock::getLockStart)
                .list();

        List<LockSlotVO> result = locks.stream()
                .filter(l -> {
                    // 排除已完成(6)和已取消(8)订单的锁定
                    ServiceOrder order = orderService.getById(l.getOrderId());
                    return order != null && order.getStatus() != 6 && order.getStatus() != 8;
                })
                .map(l -> {
                    LockSlotVO vo = new LockSlotVO();
                    vo.setDate(l.getLockStart().toLocalDate().toString());
                    // lockStart/lockEnd 含30min缓冲，展示实际服务时段
                    vo.setStartTime(l.getLockStart().plusMinutes(30)
                            .toLocalTime().toString().substring(0, 5));
                    vo.setEndTime(l.getLockEnd().minusMinutes(30)
                            .toLocalTime().toString().substring(0, 5));
                    return vo;
                })
                .collect(Collectors.toList());

        return Result.success(result);
    }

    // ───────────────────────── 内部 VO / Request 类 ─────────────────────────

    /** 周模板返回 VO */
    @Data
    public static class TemplateDayVO {
        private Integer dayOfWeek;
        private Boolean isWork;
        private String startTime; // "09:00"
        private String endTime;   // "18:00"
    }

    /** 时段锁定 VO（供日历展示） */
    @Data
    public static class LockSlotVO {
        private String date;       // "2025-01-15"
        private String startTime;  // "09:00"（实际服务开始，去掉30min缓冲）
        private String endTime;    // "11:00"
    }

    /** 保存周模板入参 */
    @Data
    public static class TemplateDayReq {
        private Integer dayOfWeek;
        private Boolean isWork;
        private String startTime;
        private String endTime;
    }

    /** 保存特殊调整入参 */
    @Data
    public static class OverrideReq {
        private String date;       // "2025-01-15"
        private Integer isOff;     // 1=全天不可 0=自定义时段
        private String startTime;  // "14:00"（isOff=0 时必填）
        private String endTime;    // "18:00"（isOff=0 时必填）
        private String remark;
    }
}
