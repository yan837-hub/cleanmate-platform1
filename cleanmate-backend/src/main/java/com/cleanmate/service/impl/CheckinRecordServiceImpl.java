package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.CheckinRecord;
import com.cleanmate.mapper.CheckinRecordMapper;
import com.cleanmate.service.ICheckinRecordService;
import org.springframework.stereotype.Service;

@Service
public class CheckinRecordServiceImpl extends ServiceImpl<CheckinRecordMapper, CheckinRecord> implements ICheckinRecordService {
}
