package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.ServicePriceTier;
import com.cleanmate.mapper.ServicePriceTierMapper;
import com.cleanmate.service.IServicePriceTierService;
import org.springframework.stereotype.Service;

@Service
public class ServicePriceTierServiceImpl extends ServiceImpl<ServicePriceTierMapper, ServicePriceTier> implements IServicePriceTierService {
}
