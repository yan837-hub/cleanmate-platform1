package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.CleanerTimeLock;
import com.cleanmate.mapper.CleanerTimeLockMapper;
import com.cleanmate.service.ICleanerTimeLockService;
import org.springframework.stereotype.Service;

@Service
public class CleanerTimeLockServiceImpl extends ServiceImpl<CleanerTimeLockMapper, CleanerTimeLock> implements ICleanerTimeLockService {
}
