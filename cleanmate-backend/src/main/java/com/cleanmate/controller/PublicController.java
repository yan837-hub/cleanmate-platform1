package com.cleanmate.controller;

import com.cleanmate.common.Result;
import com.cleanmate.entity.CleaningCompany;
import com.cleanmate.entity.SystemConfig;
import com.cleanmate.service.ICleaningCompanyService;
import com.cleanmate.service.ISystemConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 公开接口（无需登录）
 */
@RestController
@RequestMapping("/public")
@RequiredArgsConstructor
public class PublicController {

    private final ICleaningCompanyService companyService;
    private final ISystemConfigService    systemConfigService;

    /**
     * 获取正常状态公司列表，供保洁员注册时选择
     * 返回：[{id, name}]
     */
    @GetMapping("/companies/list")
    public Result<List<Map<String, Object>>> companyList() {
        List<CleaningCompany> list = companyService.lambdaQuery()
                .eq(CleaningCompany::getStatus, 1)
                .select(CleaningCompany::getId, CleaningCompany::getName)
                .orderByAsc(CleaningCompany::getName)
                .list();
        List<Map<String, Object>> result = list.stream()
                .map(c -> Map.<String, Object>of("id", c.getId(), "name", c.getName()))
                .collect(Collectors.toList());
        return Result.success(result);
    }

    /**
     * 按 key 批量读取系统配置（供前端非管理员页面使用）
     * 示例：GET /public/config?keys=cleaner_cancel_hours,refund_deadline_hours
     */
    @GetMapping("/config")
    public Result<Map<String, String>> getConfigs(@RequestParam String keys) {
        List<String> keyList = Arrays.asList(keys.split(","));
        Map<String, String> result = systemConfigService.lambdaQuery()
                .in(SystemConfig::getConfigKey, keyList)
                .list()
                .stream()
                .collect(Collectors.toMap(SystemConfig::getConfigKey, SystemConfig::getConfigValue));
        return Result.success(result);
    }
}
