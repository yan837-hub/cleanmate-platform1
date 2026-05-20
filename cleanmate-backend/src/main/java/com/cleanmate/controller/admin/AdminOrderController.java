package com.cleanmate.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cleanmate.common.PageResult;
import com.cleanmate.common.Result;
import com.cleanmate.dto.order.ExternalImportDTO;
import com.cleanmate.entity.CheckinRecord;
import com.cleanmate.entity.CleanerProfile;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.enums.OrderStatus;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.exception.ErrorCode;
import com.cleanmate.service.ICheckinRecordService;
import com.cleanmate.service.ICleanerProfileService;
import com.cleanmate.service.IServiceOrderService;
import com.cleanmate.vo.order.OrderVO;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.LinkedHashMap;
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
    private final ICheckinRecordService checkinRecordService;
    private final ICleanerProfileService cleanerProfileService;

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
     * 异常签到列表（is_abnormal=1，支持 handled 过滤：0=未处理 1=已处理）
     * 返回字段：id, orderId, orderNo, serviceTypeName, addressSnapshot, appointTime,
     *           cleanerId, cleanerName, checkinTime, distanceM, handledBy, handleRemark
     */
    @GetMapping("/checkins/abnormal")
    public Result<List<Map<String, Object>>> listAbnormalCheckins(
            @RequestParam(required = false) Integer handled) {
        var query = checkinRecordService.lambdaQuery()
                .eq(CheckinRecord::getIsAbnormal, 1);
        if (handled != null) {
            if (handled == 0) query.isNull(CheckinRecord::getHandledBy);
            else              query.isNotNull(CheckinRecord::getHandledBy);
        }
        List<CheckinRecord> records = query.orderByDesc(CheckinRecord::getCheckinTime).list();

        List<Map<String, Object>> result = new ArrayList<>();
        for (CheckinRecord r : records) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("id",          r.getId());
            row.put("cleanerId",   r.getCleanerId());
            row.put("checkinTime", r.getCheckinTime());
            row.put("distanceM",   r.getDistanceM());
            row.put("handledBy",   r.getHandledBy());
            row.put("handleRemark", r.getHandleRemark());

            // 订单信息
            row.put("orderId", r.getOrderId());
            ServiceOrder order = orderService.getById(r.getOrderId());
            if (order != null) {
                row.put("orderNo",         order.getOrderNo());
                row.put("addressSnapshot", order.getAddressSnapshot());
                row.put("appointTime",     order.getAppointTime());
                // 服务类型名称通过 OrderVO 获取
                try {
                    var vo = orderService.getOrderVO(r.getOrderId());
                    row.put("serviceTypeName", vo != null ? vo.getServiceTypeName() : "--");
                } catch (Exception ignored) {
                    row.put("serviceTypeName", "--");
                }
            } else {
                row.put("orderNo", "--"); row.put("addressSnapshot", "--");
                row.put("appointTime", null); row.put("serviceTypeName", "--");
            }

            // 保洁员姓名
            CleanerProfile profile = cleanerProfileService.lambdaQuery()
                    .eq(CleanerProfile::getUserId, r.getCleanerId()).one();
            row.put("cleanerName", profile != null ? profile.getRealName() : "ID:" + r.getCleanerId());

            result.add(row);
        }
        return Result.success(result);
    }

    /**
     * 管理员标记异常签到已处理
     */
    @PutMapping("/checkins/{id}/handle")
    public Result<Void> handleAbnormalCheckin(@PathVariable Long id,
                                              @RequestBody HandleCheckinDTO dto,
                                              Authentication auth) {
        CheckinRecord record = checkinRecordService.getById(id);
        if (record == null) throw new BusinessException(ErrorCode.NOT_FOUND);
        Long adminId = (Long) auth.getPrincipal();
        checkinRecordService.lambdaUpdate()
                .eq(CheckinRecord::getId, id)
                .set(CheckinRecord::getHandledBy, adminId)
                .set(CheckinRecord::getHandleRemark, dto.getRemark())
                .update();
        return Result.success();
    }

    @Data
    static class HandleCheckinDTO {
        private String remark;
    }

}
