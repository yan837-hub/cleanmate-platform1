package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.FeeDetail;
import com.cleanmate.mapper.FeeDetailMapper;
import com.cleanmate.service.IFeeDetailService;
import org.springframework.stereotype.Service;

@Service
public class FeeDetailServiceImpl extends ServiceImpl<FeeDetailMapper, FeeDetail> implements IFeeDetailService {
}
