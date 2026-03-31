package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.CleaningCompany;
import com.cleanmate.mapper.CleaningCompanyMapper;
import com.cleanmate.service.ICleaningCompanyService;
import org.springframework.stereotype.Service;

@Service
public class CleaningCompanyServiceImpl extends ServiceImpl<CleaningCompanyMapper, CleaningCompany> implements ICleaningCompanyService {
}
