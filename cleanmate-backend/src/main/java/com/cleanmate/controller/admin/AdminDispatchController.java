package com.cleanmate.controller.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cleanmate.common.PageResult;
import com.cleanmate.common.Result;
import com.cleanmate.dto.dispatch.ManualDispatchDTO;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.enums.OrderStatus;
import com.cleanmate.service.IServiceOrderService;
import com.cleanmate.vo.dispatch.CandidateVO;
import com.cleanmate.vo.order.OrderVO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 管理员 - 派单调度控制器
 */
@RestController
@RequestMapping("/admin/dispatch")
@RequiredArgsConstructor
public class AdminDispatchController {

    private final IServiceOrderService orderService;

    /**
     * 待处理订单池：status=1（待派单）+ status=2（已派单待确认）
     * 按 createdAt 倒序，分页
     */
    @GetMapping("/pending")
    public Result<PageResult<OrderVO>> pendingOrders(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "20") long size) {
        Page<ServiceOrder> page = orderService.lambdaQuery()
                .in(ServiceOrder::getStatus,
                        OrderStatus.PENDING_DISPATCH.getCode(),
                        OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode())
                .orderByDesc(ServiceOrder::getCreatedAt)
                .page(new Page<>(current, size));
        List<OrderVO> vos = page.getRecords().stream()
                .map(o -> orderService.getOrderVO(o.getId()))
                .toList();
        return Result.success(PageResult.of(vos, page.getTotal(), page.getCurrent(), page.getSize()));
    }

    /**
     * 获取订单的候选保洁员列表（按综合评分倒序）
     */
    @GetMapping("/candidates/{orderId}")
    public Result<List<CandidateVO>> candidates(@PathVariable Long orderId) {
        return Result.success(orderService.getDispatchCandidates(orderId));
    }

    /**
     * 触发自动派单
     */
    @PostMapping("/auto/{orderId}")
    public Result<String> autoDispatch(@PathVariable Long orderId) {
        Long cleanerId = orderService.autoDispatch(orderId);
        if (cleanerId == null) {
            return Result.success("暂无可用保洁员，订单继续等待");
        }
        return Result.success("派单成功，已通知保洁员 " + cleanerId + " 确认接单");
    }

    /**
     * 手动指派：管理员直接接单（status → 3），写 timeLock、通知、operation_log
     */
    @PostMapping("/manual")
    public Result<Void> manualDispatch(@RequestBody ManualDispatchDTO dto, Authentication auth) {
        Long adminId = (Long) auth.getPrincipal();
        orderService.manualDispatchByAdmin(dto.getOrderId(), dto.getCleanerId(), adminId, dto.getRemark());
        return Result.success();
    }
}
