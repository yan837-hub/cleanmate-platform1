package com.cleanmate.controller.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cleanmate.common.PageResult;
import com.cleanmate.common.Result;
import com.cleanmate.entity.OperationLog;
import com.cleanmate.entity.User;
import com.cleanmate.service.IOperationLogService;
import com.cleanmate.service.IUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 管理员 - 操作日志查看
 */
@RestController
@RequestMapping("/admin/operation-logs")
@RequiredArgsConstructor
public class AdminOperationLogController {

    private final IOperationLogService operationLogService;
    private final IUserService         userService;

    @GetMapping
    public Result<PageResult<Map<String, Object>>> list(
            @RequestParam(defaultValue = "1")  long current,
            @RequestParam(defaultValue = "20") long size,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) Long operatorId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {

        var query = operationLogService.lambdaQuery();
        if (module != null && !module.isBlank()) {
            query.like(OperationLog::getModule, module.trim());
        }
        if (operatorId != null) {
            query.eq(OperationLog::getOperatorId, operatorId);
        }
        if (startDate != null) {
            query.ge(OperationLog::getCreatedAt, startDate.atStartOfDay());
        }
        if (endDate != null) {
            query.lt(OperationLog::getCreatedAt, endDate.plusDays(1).atStartOfDay());
        }
        query.orderByDesc(OperationLog::getCreatedAt);

        Page<OperationLog> page = query.page(new Page<>(current, size));
        List<OperationLog> logs = page.getRecords();

        // 批量查操作人信息
        List<Long> operatorIds = logs.stream()
                .map(OperationLog::getOperatorId)
                .filter(id -> id != null)
                .distinct()
                .collect(Collectors.toList());

        Map<Long, User> userMap = operatorIds.isEmpty() ? Map.of()
                : userService.lambdaQuery()
                        .in(User::getId, operatorIds)
                        .list()
                        .stream()
                        .collect(Collectors.toMap(User::getId, u -> u));

        List<Map<String, Object>> records = logs.stream().map(log -> {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id",        log.getId());
            row.put("module",    log.getModule());
            row.put("action",    log.getAction());
            row.put("refId",     log.getRefId());
            row.put("ip",        log.getIp());
            row.put("createdAt", log.getCreatedAt());

            User op = log.getOperatorId() != null ? userMap.get(log.getOperatorId()) : null;
            boolean isSystem = Long.valueOf(0L).equals(log.getOperatorId());
            row.put("operatorNickname", isSystem ? "系统自动" : (op != null ? op.getNickname() : "—"));
            row.put("operatorPhone",    isSystem ? "—"       : (op != null ? op.getPhone()    : "—"));

            return row;
        }).collect(Collectors.toList());

        return Result.success(PageResult.of(records, page.getTotal(), page.getCurrent(), page.getSize()));
    }
}
