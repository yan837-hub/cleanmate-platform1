package com.cleanmate.controller.cleaner;

import com.cleanmate.common.Result;
import com.cleanmate.entity.CleanerTimeLock;
import com.cleanmate.entity.OrderReschedule;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.enums.NotificationType;
import com.cleanmate.enums.OrderStatus;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.exception.ErrorCode;
import com.cleanmate.entity.SystemConfig;
import com.cleanmate.service.ICleanerScheduleTemplateService;
import com.cleanmate.service.ICleanerTimeLockService;
import com.cleanmate.service.INotificationService;
import com.cleanmate.service.IOrderRescheduleService;
import com.cleanmate.service.IServiceOrderService;
import com.cleanmate.service.ISystemConfigService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 保洁员端 - 改期申请处理
 */
@RestController
@RequestMapping("/cleaner/reschedules")
@RequiredArgsConstructor
public class CleanerRescheduleController {

    private final IOrderRescheduleService rescheduleService;
    private final IServiceOrderService orderService;
    private final ICleanerTimeLockService cleanerTimeLockService;
    private final ICleanerScheduleTemplateService scheduleTemplateService;
    private final INotificationService notificationService;
    private final ISystemConfigService systemConfigService;

    /**
     * 查询当前保洁员待处理的改期申请列表
     * 可选 orderId 参数，用于在订单详情页精确查询
     */
    @GetMapping
    public Result<List<RescheduleVO>> listPending(
            @RequestParam(required = false) Long orderId,
            Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();

        // 查找该保洁员名下所有 status=9 的订单 ID
        List<Long> orderIds = orderId != null
                ? List.of(orderId)
                : orderService.lambdaQuery()
                        .eq(ServiceOrder::getCleanerId, cleanerId)
                        .eq(ServiceOrder::getStatus, OrderStatus.RESCHEDULING.getCode())
                        .list()
                        .stream().map(ServiceOrder::getId).toList();

        if (orderIds.isEmpty()) return Result.success(List.of());

        // 查 status=1 的改期申请
        List<OrderReschedule> records = rescheduleService.lambdaQuery()
                .in(OrderReschedule::getOrderId, orderIds)
                .eq(OrderReschedule::getStatus, 1)
                .orderByDesc(OrderReschedule::getId)
                .list();

        List<RescheduleVO> vos = records.stream().map(r -> {
            RescheduleVO vo = new RescheduleVO();
            vo.setId(r.getId());
            vo.setOrderId(r.getOrderId());
            vo.setOldTime(r.getOldTime());
            vo.setNewTime(r.getNewTime());
            vo.setCreatedAt(r.getCreatedAt());
            ServiceOrder order = orderService.getById(r.getOrderId());
            if (order != null) vo.setOrderNo(order.getOrderNo());
            return vo;
        }).toList();

        return Result.success(vos);
    }

    /**
     * 处理改期申请
     * 通过时：
     *   a. 校验新时间保洁员是否有档期
     *   b. 更新 appointTime，status → 3
     *   c. 删除（提交申请时已删）→ 创建新 time_lock
     *   d. 改期记录 status → 2
     *   e. 通知顾客
     * 拒绝时：
     *   a. 按原 appointTime 重建 time_lock
     *   b. 订单 status → 3
     *   c. 改期记录 status → 3
     *   d. 通知顾客
     */
    @PutMapping("/{id}/handle")
    public Result<Void> handle(@PathVariable Long id,
                               @RequestBody HandleDTO dto,
                               Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();

        OrderReschedule record = rescheduleService.getById(id);
        if (record == null || record.getStatus() != 1) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }

        ServiceOrder order = orderService.getById(record.getOrderId());
        if (order == null || !cleanerId.equals(order.getCleanerId())) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        if (!order.getStatus().equals(OrderStatus.RESCHEDULING.getCode())) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }

        int planMin = order.getPlanDuration() != null ? order.getPlanDuration() : 120;
        SystemConfig bufferCfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "commute_buffer_minutes").one();
        long bufferMin = bufferCfg != null ? Long.parseLong(bufferCfg.getConfigValue()) : 30L;

        if (Boolean.TRUE.equals(dto.getApprove())) {
            // ── 通过 ──
            LocalDateTime newTime = record.getNewTime();
            LocalDateTime newLockStart = newTime.minusMinutes(bufferMin);
            LocalDateTime newLockEnd   = newTime.plusMinutes(planMin + bufferMin);

            // 校验新时间档期（旧锁在提交申请时已删，无误判）
            if (!scheduleTemplateService.isCleanerAvailable(cleanerId, newLockStart, newLockEnd)) {
                throw new BusinessException("新时间段存在档期冲突，无法通过改期申请");
            }

            // 创建新时段锁
            CleanerTimeLock newLock = new CleanerTimeLock();
            newLock.setCleanerId(cleanerId);
            newLock.setOrderId(order.getId());
            newLock.setLockStart(newLockStart);
            newLock.setLockEnd(newLockEnd);
            cleanerTimeLockService.save(newLock);

            // 更新订单：新预约时间 + 回到已接单状态
            orderService.lambdaUpdate()
                    .eq(ServiceOrder::getId, order.getId())
                    .set(ServiceOrder::getAppointTime, newTime)
                    .set(ServiceOrder::getStatus, OrderStatus.ACCEPTED.getCode())
                    .update();
            orderService.logStatusChange(order.getId(), OrderStatus.RESCHEDULING.getCode(),
                    OrderStatus.ACCEPTED.getCode(), cleanerId, "保洁员同意改期");

            // 改期记录已通过
            rescheduleService.lambdaUpdate()
                    .eq(OrderReschedule::getId, id)
                    .set(OrderReschedule::getStatus, 2)
                    .set(OrderReschedule::getHandledBy, cleanerId)
                    .set(OrderReschedule::getHandledAt, LocalDateTime.now())
                    .set(OrderReschedule::getHandleRemark, dto.getRemark())
                    .update();

            // 通知顾客
            notificationService.sendNotification(
                    order.getCustomerId(),
                    NotificationType.RESCHEDULE_RESULT.getCode(),
                    "改期申请已通过",
                    "您的订单 #" + order.getOrderNo() + " 改期申请已通过，新预约时间为 "
                            + newTime.toString().replace("T", " ").substring(0, 16),
                    order.getId());

        } else {
            // ── 拒绝 ──
            // 用订单中保存的原 appointTime 重建时段锁
            LocalDateTime oldTime = order.getAppointTime();
            CleanerTimeLock oldLock = new CleanerTimeLock();
            oldLock.setCleanerId(cleanerId);
            oldLock.setOrderId(order.getId());
            oldLock.setLockStart(oldTime.minusMinutes(bufferMin));
            oldLock.setLockEnd(oldTime.plusMinutes(planMin + bufferMin));
            cleanerTimeLockService.save(oldLock);

            // 订单恢复已接单
            orderService.lambdaUpdate()
                    .eq(ServiceOrder::getId, order.getId())
                    .set(ServiceOrder::getStatus, OrderStatus.ACCEPTED.getCode())
                    .update();
            orderService.logStatusChange(order.getId(), OrderStatus.RESCHEDULING.getCode(),
                    OrderStatus.ACCEPTED.getCode(), cleanerId, "保洁员拒绝改期");

            // 改期记录已拒绝
            rescheduleService.lambdaUpdate()
                    .eq(OrderReschedule::getId, id)
                    .set(OrderReschedule::getStatus, 3)
                    .set(OrderReschedule::getHandledBy, cleanerId)
                    .set(OrderReschedule::getHandledAt, LocalDateTime.now())
                    .set(OrderReschedule::getHandleRemark, dto.getRemark())
                    .update();

            // 通知顾客
            String remark = (dto.getRemark() != null && !dto.getRemark().isBlank())
                    ? "：" + dto.getRemark() : "";
            notificationService.sendNotification(
                    order.getCustomerId(),
                    NotificationType.RESCHEDULE_RESULT.getCode(),
                    "改期申请被拒绝",
                    "您的订单 #" + order.getOrderNo() + " 改期申请被拒绝" + remark + "，原时间不变",
                    order.getId());
        }

        return Result.success();
    }

    @Data
    static class HandleDTO {
        private Boolean approve;
        private String remark;
    }

    @Data
    static class RescheduleVO {
        private Long id;
        private Long orderId;
        private String orderNo;
        private LocalDateTime oldTime;
        private LocalDateTime newTime;
        private LocalDateTime createdAt;
    }
}
