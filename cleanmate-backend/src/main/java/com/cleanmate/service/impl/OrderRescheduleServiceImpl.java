package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.OrderReschedule;
import com.cleanmate.mapper.OrderRescheduleMapper;
import com.cleanmate.service.IOrderRescheduleService;
import org.springframework.stereotype.Service;

@Service
public class OrderRescheduleServiceImpl extends ServiceImpl<OrderRescheduleMapper, OrderReschedule>
        implements IOrderRescheduleService {
}
