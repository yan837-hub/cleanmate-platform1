package com.cleanmate.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cleanmate.common.PageResult;
import com.cleanmate.common.Result;
import com.cleanmate.dto.order.ExternalImportDTO;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.enums.OrderStatus;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.exception.ErrorCode;
import com.cleanmate.service.IServiceOrderService;
import com.cleanmate.vo.order.OrderVO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 管理员 - 订单管理控制器
 */
@RestController
@RequestMapping("/admin/orders")
@RequiredArgsConstructor
public class AdminOrderController {

    private final IServiceOrderService orderService;

    /**
     * 订单列表（支持按状态筛选、关键词搜索）
     */
    @GetMapping
    public Result<PageResult<OrderVO>> listOrders(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Integer source,
            @RequestParam(required = false) String keyword) {

        LambdaQueryWrapper<ServiceOrder> wrapper = new LambdaQueryWrapper<ServiceOrder>()
                .eq(status != null, ServiceOrder::getStatus, status)
                .eq(source != null, ServiceOrder::getSource, source)
                .and(keyword != null && !keyword.isBlank(), w ->
                        w.like(ServiceOrder::getOrderNo, keyword)
                         .or().like(ServiceOrder::getAddressSnapshot, keyword))
                .orderByDesc(ServiceOrder::getCreatedAt);

        Page<ServiceOrder> page = orderService.page(new Page<>(current, size), wrapper);
        List<OrderVO> vos = page.getRecords().stream()
                .map(o -> orderService.getOrderVO(o.getId()))
                .toList();
        return Result.success(PageResult.of(vos, page.getTotal(), page.getCurrent(), page.getSize()));
    }

    /**
     * 订单详情
     */
    @GetMapping("/{orderId}")
    public Result<OrderVO> getOrderDetail(@PathVariable Long orderId) {
        return Result.success(orderService.getOrderVO(orderId));
    }

    /**
     * 手动录入订单（source=3）
     */
    @PostMapping("/manual-create")
    public Result<Map<String, Object>> manualCreate(@RequestBody ExternalImportDTO dto,
                                                    Authentication auth) {
        Long adminId = (Long) auth.getPrincipal();
        return Result.success(orderService.importOrder(dto, 3, adminId));
    }

    /**
     * 超时无人接单的自动取消订单列表
     * 供管理员做供需分析，按预约时间倒序
     */
    @GetMapping("/expired-unaccepted")
    public Result<PageResult<OrderVO>> listExpiredUnaccepted(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size) {

        Page<ServiceOrder> page = orderService.page(
                new Page<>(current, size),
                new LambdaQueryWrapper<ServiceOrder>()
                        .eq(ServiceOrder::getStatus, OrderStatus.CANCELLED.getCode())
                        .like(ServiceOrder::getCancelReason, "无人接单")
                        .orderByDesc(ServiceOrder::getAppointTime)
        );
        List<OrderVO> vos = page.getRecords().stream()
                .map(o -> orderService.getOrderVO(o.getId()))
                .toList();
        return Result.success(PageResult.of(vos, page.getTotal(), page.getCurrent(), page.getSize()));
    }

    /**
     * 强制取消订单（管理员权限）
     */
    @PutMapping("/{orderId}/cancel")
    public Result<Void> cancelOrder(@PathVariable Long orderId,
                                    @RequestParam String reason,
                                    Authentication auth) {
        Long adminId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null) throw new BusinessException(ErrorCode.ORDER_NOT_EXIST);
        if (order.getStatus() >= OrderStatus.IN_SERVICE.getCode())
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);

        order.setCancelReason(reason);
        order.setStatus(OrderStatus.CANCELLED.getCode());
        orderService.updateById(order);
        orderService.logStatusChange(orderId, order.getStatus(),
                OrderStatus.CANCELLED.getCode(), adminId, "管理员强制取消：" + reason);
        return Result.success();
    }
}
