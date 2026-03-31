package com.cleanmate.controller.admin;

import com.cleanmate.common.PageResult;
import com.cleanmate.common.Result;
import com.cleanmate.service.IServiceTypeService;
import com.cleanmate.service.IServiceTypeService.ServiceTypeDTO;
import com.cleanmate.service.IServiceTypeService.ServiceTypeVO;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;


/**
 * 管理员 - 服务类型配置
 */
@RestController
@RequestMapping("/admin/service-types")
@RequiredArgsConstructor
public class AdminServiceTypeController {

    private final IServiceTypeService serviceTypeService;

    /** 分页列表（支持 status 筛选） */
    @GetMapping
    public Result<PageResult<ServiceTypeVO>> list(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Integer status) {
        return Result.success(serviceTypeService.adminPage(current, size, status));
    }

    /** 新增服务类型 */
    @PostMapping
    public Result<Void> create(@RequestBody ServiceTypeDTO dto) {
        serviceTypeService.adminCreate(dto);
        return Result.success();
    }

    /** 全量更新服务类型 */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody ServiceTypeDTO dto) {
        serviceTypeService.adminUpdate(id, dto);
        return Result.success();
    }

    /** 上架/下架 */
    @PutMapping("/{id}/status")
    public Result<String> updateStatus(@PathVariable Long id, @RequestBody StatusDTO body) {
        String warning = serviceTypeService.toggleStatus(id, body.getStatus());
        return warning != null
                ? Result.success(warning)   // 携带警告文字，HTTP 200 仍表示操作成功
                : Result.success();
    }

    @Data
    public static class StatusDTO {
        private Integer status;
    }
}
