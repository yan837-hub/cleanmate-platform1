package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.entity.ServicePhoto;
import com.cleanmate.mapper.ServicePhotoMapper;
import com.cleanmate.service.IServicePhotoService;
import org.springframework.stereotype.Service;

@Service
public class ServicePhotoServiceImpl extends ServiceImpl<ServicePhotoMapper, ServicePhoto> implements IServicePhotoService {
}
