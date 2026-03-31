package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.CustomerProfile;
import com.cleanmate.mapper.CustomerProfileMapper;
import com.cleanmate.service.ICustomerProfileService;
import org.springframework.stereotype.Service;

@Service
public class CustomerProfileServiceImpl extends ServiceImpl<CustomerProfileMapper, CustomerProfile> implements ICustomerProfileService {
}
