package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.CleanerScheduleOverride;
import com.cleanmate.mapper.CleanerScheduleOverrideMapper;
import com.cleanmate.service.ICleanerScheduleOverrideService;
import org.springframework.stereotype.Service;

@Service
public class CleanerScheduleOverrideServiceImpl extends ServiceImpl<CleanerScheduleOverrideMapper, CleanerScheduleOverride> implements ICleanerScheduleOverrideService {
}
