package com.cleanmate.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.cleanmate.entity.CleanerScheduleTemplate;

import java.time.LocalDateTime;

public interface ICleanerScheduleTemplateService extends IService<CleanerScheduleTemplate> {

    /**
     * 判断保洁员在指定时段是否可接单（供派单模块内部调用，不暴露为接口）
     * 优先级：override > template > 返回false
     * 同时检查 cleaner_time_lock 时段冲突
     *
     * @param cleanerId 保洁员user_id
     * @param lockStart 锁定开始时间（含通勤缓冲，= appointTime - 30min）
     * @param lockEnd   锁定结束时间（含通勤缓冲，= appointTime + planDuration + 30min）
     * @return true=可接单
     */
    boolean isCleanerAvailable(Long cleanerId, LocalDateTime lockStart, LocalDateTime lockEnd);
}
