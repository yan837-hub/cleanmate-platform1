package com.cleanmate.controller;

import com.cleanmate.common.Result;
import com.cleanmate.entity.ServiceType;
import com.cleanmate.service.IServiceTypeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 服务类型控制器（公开接口，无需登录）
 */
@RestController
@RequestMapping("/service-types")
@RequiredArgsConstructor
public class ServiceTypeController {

    private final IServiceTypeService serviceTypeService;

    /** 获取所有上架服务类型 */
    @GetMapping
    public Result<List<ServiceType>> listServiceTypes() {
        List<ServiceType> list = serviceTypeService.lambdaQuery()
                .eq(ServiceType::getStatus, 1)
                .orderByDesc(ServiceType::getSortOrder)
                .list();
        return Result.success(list);
    }

    /** 获取服务类型详情 */
    @GetMapping("/{id}")
    public Result<ServiceType> getServiceType(@PathVariable Long id) {
        return Result.success(serviceTypeService.getById(id));
    }
}
