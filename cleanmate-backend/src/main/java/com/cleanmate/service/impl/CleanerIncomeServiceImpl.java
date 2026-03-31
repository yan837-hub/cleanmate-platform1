package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.CleanerIncome;
import com.cleanmate.mapper.CleanerIncomeMapper;
import com.cleanmate.service.ICleanerIncomeService;
import org.springframework.stereotype.Service;

@Service
public class CleanerIncomeServiceImpl extends ServiceImpl<CleanerIncomeMapper, CleanerIncome> implements ICleanerIncomeService {
}
