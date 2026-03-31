package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.OrderReview;
import com.cleanmate.mapper.OrderReviewMapper;
import com.cleanmate.service.IOrderReviewService;
import org.springframework.stereotype.Service;

@Service
public class OrderReviewServiceImpl extends ServiceImpl<OrderReviewMapper, OrderReview> implements IOrderReviewService {
}
