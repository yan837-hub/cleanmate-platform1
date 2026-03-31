package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.CleanerScheduleOverride;
import com.cleanmate.entity.CleanerScheduleTemplate;
import com.cleanmate.entity.CleanerTimeLock;
import com.cleanmate.mapper.CleanerScheduleTemplateMapper;
import com.cleanmate.service.ICleanerScheduleOverrideService;
import com.cleanmate.service.ICleanerScheduleTemplateService;
import com.cleanmate.service.ICleanerTimeLockService;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class CleanerScheduleTemplateServiceImpl extends ServiceImpl<CleanerScheduleTemplateMapper, CleanerScheduleTemplate> implements ICleanerScheduleTemplateService {

    @Lazy
    private final ICleanerScheduleOverrideService overrideService;
    @Lazy
    private final ICleanerTimeLockService timeLockService;

    /**
     * 判断保洁员在指定时段是否可接单：
     * 1. 查 override 表（当天特殊调整），有则以 override 为准
     * 2. 无 override 则查 template 表对应 dayOfWeek
     * 3. 同时查 cleaner_time_lock，判断是否已被占用
     * lockStart/lockEnd 含 30min 通勤缓冲，实际服务时间 = lockStart+30min ~ lockEnd-30min
     */
    @Override
    public boolean isCleanerAvailable(Long cleanerId, LocalDateTime lockStart, LocalDateTime lockEnd) {
        LocalDate date = lockStart.toLocalDate();
        // 实际服务时间（去掉两端各30min的通勤缓冲）
        LocalTime serviceStart = lockStart.plusMinutes(30).toLocalTime();
        LocalTime serviceEnd   = lockEnd.minusMinutes(30).toLocalTime();

        // ① 查特殊调整（override 优先）
        CleanerScheduleOverride override = overrideService.lambdaQuery()
                .eq(CleanerScheduleOverride::getCleanerId, cleanerId)
                .eq(CleanerScheduleOverride::getDate, date)
                .one();

        if (override != null) {
            // 全天不可接单
            if (override.getIsOff() != null && override.getIsOff() == 1) return false;
            // 自定义时段：服务时间必须在 override 窗口内
            if (override.getStartTime() != null && override.getEndTime() != null) {
                if (serviceStart.isBefore(override.getStartTime()) || serviceEnd.isAfter(override.getEndTime())) {
                    return false;
                }
            }
        } else {
            // ② 查周模板
            int dayOfWeek = date.getDayOfWeek().getValue(); // 1=周一 … 7=周日
            CleanerScheduleTemplate template = this.lambdaQuery()
                    .eq(CleanerScheduleTemplate::getCleanerId, cleanerId)
                    .eq(CleanerScheduleTemplate::getDayOfWeek, dayOfWeek)
                    .one();
            // 该天无模板 = 不工作
            if (template == null) return false;
            // 服务时间必须在模板工作时间内
            if (serviceStart.isBefore(template.getStartTime()) || serviceEnd.isAfter(template.getEndTime())) {
                return false;
            }
        }

        // ③ 查时段锁定，无冲突才可用
        return !timeLockService.lambdaQuery()
                .eq(CleanerTimeLock::getCleanerId, cleanerId)
                .lt(CleanerTimeLock::getLockStart, lockEnd)
                .gt(CleanerTimeLock::getLockEnd, lockStart)
                .exists();
    }
}
