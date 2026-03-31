package com.cleanmate.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cleanmate.common.PageResult;
import com.cleanmate.common.Result;
import com.cleanmate.entity.CustomerProfile;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.entity.User;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.exception.ErrorCode;
import com.cleanmate.mapper.ServiceOrderMapper;
import com.cleanmate.service.ICustomerProfileService;
import com.cleanmate.service.IUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 管理员 - 顾客管理
 */
@RestController
@RequestMapping("/admin/customers")
@RequiredArgsConstructor
public class AdminCustomerController {

    private final IUserService            userService;
    private final ICustomerProfileService customerProfileService;
    private final ServiceOrderMapper      orderMapper;

    /** 顾客列表（分页，支持 status 筛选 / keyword 搜索手机号或昵称） */
    @GetMapping
    public Result<PageResult<Map<String, Object>>> listCustomers(
            @RequestParam(defaultValue = "1")  long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false)    Integer status,
            @RequestParam(required = false)    String keyword) {

        var query = userService.lambdaQuery().eq(User::getRole, 1);
        if (status != null)                    query.eq(User::getStatus, status);
        if (keyword != null && !keyword.isBlank()) {
            query.and(q -> q.like(User::getPhone, keyword.trim())
                            .or().like(User::getNickname, keyword.trim()));
        }
        query.orderByDesc(User::getId);

        Page<User> page = query.page(new Page<>(current, size));
        List<User> users = page.getRecords();

        // 批量查 customer_profile（realName）
        List<Long> userIds = users.stream().map(User::getId).collect(Collectors.toList());
        Map<Long, CustomerProfile> profileMap = userIds.isEmpty() ? Map.of()
                : customerProfileService.lambdaQuery()
                        .in(CustomerProfile::getUserId, userIds).list()
                        .stream().collect(Collectors.toMap(CustomerProfile::getUserId, p -> p));

        List<Map<String, Object>> records = users.stream().map(u -> {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id",        u.getId());
            row.put("phone",     u.getPhone());
            row.put("nickname",  u.getNickname());
            row.put("avatarUrl", u.getAvatarUrl());
            row.put("status",    u.getStatus());
            row.put("createdAt", u.getCreatedAt());

            CustomerProfile cp = profileMap.get(u.getId());
            row.put("realName", cp != null ? cp.getRealName() : null);

            long cnt = orderMapper.selectCount(
                    new LambdaQueryWrapper<ServiceOrder>()
                            .eq(ServiceOrder::getCustomerId, u.getId()));
            row.put("orderCount", cnt);

            return row;
        }).collect(Collectors.toList());

        return Result.success(PageResult.of(records, page.getTotal(), page.getCurrent(), page.getSize()));
    }

    /** 启用 / 停用顾客账号（status: 1=正常 3=停用） */
    @PutMapping("/{userId}/status")
    public Result<Void> toggleStatus(@PathVariable Long userId,
                                     @RequestParam Integer status) {
        if (status != 1 && status != 3) throw new BusinessException(ErrorCode.PARAM_ERROR);
        User user = userService.getById(userId);
        if (user == null || user.getRole() != 1) throw new BusinessException(ErrorCode.USER_NOT_EXIST);
        user.setStatus(status);
        userService.updateById(user);
        return Result.success();
    }
}
