package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.CustomerAddress;
import com.cleanmate.mapper.CustomerAddressMapper;
import com.cleanmate.service.ICustomerAddressService;
import org.springframework.stereotype.Service;

@Service
public class CustomerAddressServiceImpl extends ServiceImpl<CustomerAddressMapper, CustomerAddress> implements ICustomerAddressService {
}
