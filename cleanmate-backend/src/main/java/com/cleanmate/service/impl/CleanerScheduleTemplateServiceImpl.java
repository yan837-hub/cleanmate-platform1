package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.CleanerScheduleOverride;
import com.cleanmate.entity.CleanerScheduleTemplate;
import com.cleanmate.entity.CleanerTimeLock;
import com.cleanmate.entity.SystemConfig;
import com.cleanmate.mapper.CleanerScheduleTemplateMapper;
import com.cleanmate.service.ICleanerScheduleOverrideService;
import com.cleanmate.service.ICleanerScheduleTemplateService;
import com.cleanmate.service.ICleanerTimeLockService;
import com.cleanmate.service.ISystemConfigService;
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
    @Lazy
    private final ISystemConfigService systemConfigService;

    /**
     * 判断保洁员在指定时段是否可接单：
     * 1. 查 override 表（当天特殊调整），有则以 override 为准
     * 2. 无 override 则查 template 表对应 dayOfWeek
     * 3. 同时查 cleaner_time_lock，判断是否已被占用
     * lockStart/lockEnd 含 30min 通勤缓冲，实际服务时间 = lockStart+30min ~ lockEnd-30min
     */
    @Override
    public AvailabilityResult checkAvailability(Long cleanerId, LocalDateTime lockStart, LocalDateTime lockEnd) {
        LocalDate date = lockStart.toLocalDate();

        SystemConfig bufferCfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "commute_buffer_minutes").one();
        long bufferMin = bufferCfg != null ? Long.parseLong(bufferCfg.getConfigValue()) : 30L;
        LocalTime serviceStart = lockStart.plusMinutes(bufferMin).toLocalTime();
        LocalTime serviceEnd   = lockEnd.minusMinutes(bufferMin).toLocalTime();

        // ① 查特殊调整（override 优先）
        CleanerScheduleOverride override = overrideService.lambdaQuery()
                .eq(CleanerScheduleOverride::getCleanerId, cleanerId)
                .eq(CleanerScheduleOverride::getDate, date)
                .one();

        if (override != null) {
            if (override.getIsOff() != null && override.getIsOff() == 1)
                return AvailabilityResult.SCHEDULE_NOT_COVER;
            if (override.getStartTime() != null && override.getEndTime() != null) {
                if (serviceStart.isBefore(override.getStartTime()) || serviceEnd.isAfter(override.getEndTime()))
                    return AvailabilityResult.SCHEDULE_NOT_COVER;
            }
        } else {
            // ② 查周模板
            int dayOfWeek = date.getDayOfWeek().getValue();
            CleanerScheduleTemplate template = this.lambdaQuery()
                    .eq(CleanerScheduleTemplate::getCleanerId, cleanerId)
                    .eq(CleanerScheduleTemplate::getDayOfWeek, dayOfWeek)
                    .one();
            if (template == null)
                return AvailabilityResult.SCHEDULE_NOT_COVER;
            if (serviceStart.isBefore(template.getStartTime()) || serviceEnd.isAfter(template.getEndTime()))
                return AvailabilityResult.SCHEDULE_NOT_COVER;
        }

        // ③ 查时段锁定
        boolean conflict = timeLockService.lambdaQuery()
                .eq(CleanerTimeLock::getCleanerId, cleanerId)
                .lt(CleanerTimeLock::getLockStart, lockEnd)
                .gt(CleanerTimeLock::getLockEnd, lockStart)
                .exists();
        return conflict ? AvailabilityResult.TIME_LOCK_CONFLICT : AvailabilityResult.OK;
    }

    @Override
    public boolean isCleanerAvailable(Long cleanerId, LocalDateTime lockStart, LocalDateTime lockEnd) {
        return checkAvailability(cleanerId, lockStart, lockEnd) == AvailabilityResult.OK;
    }
}
