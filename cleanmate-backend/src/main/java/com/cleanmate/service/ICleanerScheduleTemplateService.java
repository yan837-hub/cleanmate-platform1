package com.cleanmate.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.cleanmate.entity.CleanerScheduleTemplate;

import java.time.LocalDateTime;

public interface ICleanerScheduleTemplateService extends IService<CleanerScheduleTemplate> {

    /** 档期检查结果 */
    enum AvailabilityResult {
        /** 可接单 */
        OK,
        /** 工作档期（周模板/特殊调整）不覆盖该时段 */
        SCHEDULE_NOT_COVER,
        /** 该时段已有订单（时间锁冲突） */
        TIME_LOCK_CONFLICT
    }

    /**
     * 检查保洁员档期，返回具体失败原因。
     * 优先级：override > template，再查 time_lock。
     */
    AvailabilityResult checkAvailability(Long cleanerId, LocalDateTime lockStart, LocalDateTime lockEnd);

    /** 便捷方法：仅返回 true/false，内部调用 checkAvailability */
    boolean isCleanerAvailable(Long cleanerId, LocalDateTime lockStart, LocalDateTime lockEnd);
}
