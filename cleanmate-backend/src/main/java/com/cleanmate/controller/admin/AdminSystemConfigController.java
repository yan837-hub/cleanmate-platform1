package com.cleanmate.controller.admin;

import com.cleanmate.common.Result;
import com.cleanmate.entity.OperationLog;
import com.cleanmate.entity.SystemConfig;
import com.cleanmate.service.IOperationLogService;
import com.cleanmate.service.ISystemConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 管理员 - 系统参数配置
 */
@RestController
@RequestMapping("/admin/system-config")
@RequiredArgsConstructor
public class AdminSystemConfigController {

    private final ISystemConfigService  configService;
    private final IOperationLogService  operationLogService;

    /** 获取全部系统参数列表（含 id / key / value / description / updatedAt） */
    @GetMapping
    public Result<List<SystemConfig>> getAll() {
        return Result.success(
                configService.lambdaQuery()
                        .orderByAsc(SystemConfig::getConfigKey)
                        .list());
    }

    /** 更新单个参数，并写 operation_log */
    @PutMapping("/{key}")
    public Result<Void> updateOne(@PathVariable String key,
                                  @RequestBody UpdateValueDTO dto,
                                  Authentication auth) {
        SystemConfig cfg = configService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, key)
                .one();

        String oldValue = cfg != null ? cfg.getConfigValue() : null;
        if (cfg == null) {
            cfg = new SystemConfig();
            cfg.setConfigKey(key);
        }
        String newValue = dto.configValue();

        if (oldValue != null && oldValue.equals(newValue)) {
            return Result.success(); // 值未变，直接返回
        }

        Long adminId = (Long) auth.getPrincipal();
        cfg.setConfigValue(newValue);
        cfg.setUpdatedBy(adminId);
        configService.saveOrUpdate(cfg); // 新记录用 INSERT，已有记录用 UPDATE

        // 写操作日志（saveOrUpdate 后 cfg.getId() 已有值）
        OperationLog log = new OperationLog();
        log.setOperatorId(adminId);
        log.setModule("系统参数");
        log.setAction("修改系统参数[" + key + "]: " + oldValue + "→" + newValue);
        log.setRefId(cfg.getId() != null ? cfg.getId().longValue() : null);
        log.setBeforeData(oldValue);
        log.setAfterData(newValue);
        operationLogService.save(log);

        return Result.success();
    }

    public record UpdateValueDTO(String configValue) {}
}
