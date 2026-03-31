package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.OrderStatusLog;
import com.cleanmate.mapper.OrderStatusLogMapper;
import com.cleanmate.service.IOrderStatusLogService;
import org.springframework.stereotype.Service;

@Service
public class OrderStatusLogServiceImpl extends ServiceImpl<OrderStatusLogMapper, OrderStatusLog> implements IOrderStatusLogService {
}
