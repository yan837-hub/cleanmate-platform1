package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.CleanerProfile;
import com.cleanmate.mapper.CleanerProfileMapper;
import com.cleanmate.service.ICleanerProfileService;
import org.springframework.stereotype.Service;

@Service
public class CleanerProfileServiceImpl extends ServiceImpl<CleanerProfileMapper, CleanerProfile> implements ICleanerProfileService {
}
