package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.DispatchRecord;
import com.cleanmate.mapper.DispatchRecordMapper;
import com.cleanmate.service.IDispatchRecordService;
import org.springframework.stereotype.Service;

@Service
public class DispatchRecordServiceImpl extends ServiceImpl<DispatchRecordMapper, DispatchRecord> implements IDispatchRecordService {
}
