package com.cleanmate.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cleanmate.common.PageResult;
import com.cleanmate.common.Result;
import com.cleanmate.entity.Complaint;
import com.cleanmate.entity.FeeDetail;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.entity.User;
import com.cleanmate.enums.NotificationType;
import com.cleanmate.enums.OrderStatus;
import com.cleanmate.service.*;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 管理员 - 投诉处理控制器
 * complaint.result 枚举：1=全额退款  2=驳回  3=免费重做
 */
@RestController
@RequestMapping("/admin/complaints")
@RequiredArgsConstructor
public class AdminComplaintController {

    private final IComplaintService       complaintService;
    private final IServiceOrderService    orderService;
    private final IFeeDetailService       feeDetailService;
    private final ICleanerTimeLockService cleanerTimeLockService;
    private final INotificationService    notificationService;
    private final IUserService            userService;

    /** 投诉列表（分页，含顾客/保洁员昵称和订单金额） */
    @GetMapping
    public Result<PageResult<Complaint>> list(
            @RequestParam(defaultValue = "1")  Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String keyword) {

        LambdaQueryWrapper<Complaint> wrapper = new LambdaQueryWrapper<>();
        if (status != null) wrapper.eq(Complaint::getStatus, status);
        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w
                    .like(Complaint::getReason, keyword)
                    .or().eq(Complaint::getOrderId,
                            keyword.matches("\\d+") ? Long.parseLong(keyword) : -1L));
        }
        wrapper.orderByDesc(Complaint::getCreatedAt);
        Page<Complaint> page = complaintService.page(new Page<>(current, size), wrapper);

        page.getRecords().forEach(c -> {
            ServiceOrder o = orderService.getById(c.getOrderId());
            if (o != null) {
                c.setOrderActualFee(o.getActualFee());
                c.setOrderEstimateFee(o.getEstimateFee());
            }
            if (c.getCustomerId() != null) {
                User u = userService.getById(c.getCustomerId());
                if (u != null) c.setCustomerNickname(u.getNickname());
            }
            if (c.getCleanerId() != null) {
                User u = userService.getById(c.getCleanerId());
                if (u != null) c.setCleanerNickname(u.getNickname());
            }
        });
        return Result.success(PageResult.of(page));
    }

    /**
     * 处理投诉
     * dto.status: 2=处理中  3=已结案
     * dto.result: 1=全额退款  2=驳回投诉  3=免费重做  4=部分退款（需传 refundAmount）
     */
    @PutMapping("/{id}")
    public Result<Void> handle(@PathVariable Long id,
                               @RequestBody HandleDTO dto,
                               Authentication auth) {
        Complaint complaint = complaintService.getById(id);
        if (complaint == null) return Result.error(404, "投诉记录不存在");
        if (complaint.getStatus() == 3) return Result.error("该投诉已结案，无法重复处理");

        Long adminId = (Long) auth.getPrincipal();

        complaint.setStatus(dto.getStatus());
        if (dto.getResult()      != null) complaint.setResult(dto.getResult());
        if (dto.getAdminRemark() != null) complaint.setAdminRemark(dto.getAdminRemark());
        if (dto.getRefundAmount() != null) complaint.setRefundAmount(dto.getRefundAmount());

        if (dto.getStatus() == 3 && complaint.getResult() != null) {
            complaint.setHandledBy(adminId);
            complaint.setHandledAt(LocalDateTime.now());
            processOrderOnClose(complaint, adminId);
        }

        complaintService.updateById(complaint);
        return Result.success();
    }

    /**
     * 结案时联动订单、fee_detail 并发送站内通知
     * result=1 全额退款：fee归零，order.status→6
     * result=2 驳回投诉：fee不变，order.status→6
     * result=3 免费重做：fee归零，清除保洁员，释放time_lock，order.status→1
     * result=4 部分退款：fee=refundAmount，order.status→6
     */
    private void processOrderOnClose(Complaint complaint, Long adminId) {
        ServiceOrder order = orderService.getById(complaint.getOrderId());
        if (order == null || order.getStatus() != 7) return;

        int oldStatus = order.getStatus();

        switch (complaint.getResult()) {
            case 1 -> {
                order.setActualFee(BigDecimal.ZERO);
                order.setStatus(OrderStatus.COMPLETED.getCode());
                syncFeeDetail(order.getId(), BigDecimal.ZERO);
                orderService.updateById(order);
                orderService.logStatusChange(order.getId(), oldStatus,
                        OrderStatus.COMPLETED.getCode(), adminId, "投诉处理：全额退款，订单完成");
                notify(complaint.getCustomerId(), "投诉已结案 - 全额退款",
                        "您的订单 #" + order.getOrderNo() + " 投诉已结案，平台已为您全额退款", order.getId());
                if (complaint.getCleanerId() != null) {
                    notify(complaint.getCleanerId(), "投诉结案通知",
                            "订单 #" + order.getOrderNo() + " 投诉结案（全额退款），本单收入已清零", order.getId());
                }
            }
            case 2 -> {
                order.setStatus(OrderStatus.COMPLETED.getCode());
                orderService.updateById(order);
                orderService.logStatusChange(order.getId(), oldStatus,
                        OrderStatus.COMPLETED.getCode(), adminId, "投诉处理：驳回，订单恢复完成");
                notify(complaint.getCustomerId(), "投诉已结案 - 驳回",
                        "您的订单 #" + order.getOrderNo() + " 投诉申请已驳回，订单已完成", order.getId());
            }
            case 4 -> {
                BigDecimal refund = complaint.getRefundAmount() != null
                        ? complaint.getRefundAmount() : BigDecimal.ZERO;
                order.setActualFee(refund);
                order.setStatus(OrderStatus.COMPLETED.getCode());
                syncFeeDetail(order.getId(), refund);
                orderService.updateById(order);
                orderService.logStatusChange(order.getId(), oldStatus,
                        OrderStatus.COMPLETED.getCode(), adminId,
                        "投诉处理：部分退款 ¥" + refund + "，订单完成");
                notify(complaint.getCustomerId(), "投诉已结案 - 部分退款",
                        "您的订单 #" + order.getOrderNo() + " 投诉已结案，平台为您部分退款 ¥" + refund,
                        order.getId());
                if (complaint.getCleanerId() != null) {
                    notify(complaint.getCleanerId(), "投诉结案通知",
                            "订单 #" + order.getOrderNo() + " 投诉结案（部分退款），收入已按比例调整",
                            order.getId());
                }
            }
            case 3 -> {
                Long oldCleanerId = order.getCleanerId();
                syncFeeDetail(order.getId(), BigDecimal.ZERO);
                // 使用 lambdaUpdate 显式将 cleaner_id / completed_at / auto_confirm_at 置 null
                orderService.lambdaUpdate()
                        .eq(ServiceOrder::getId, order.getId())
                        .set(ServiceOrder::getActualFee, BigDecimal.ZERO)
                        .set(ServiceOrder::getStatus, OrderStatus.PENDING_DISPATCH.getCode())
                        .set(ServiceOrder::getCleanerId, null)
                        .set(ServiceOrder::getCompletedAt, null)
                        .set(ServiceOrder::getAutoConfirmAt, null)
                        .update();
                cleanerTimeLockService.lambdaUpdate()
                        .eq(com.cleanmate.entity.CleanerTimeLock::getOrderId, order.getId())
                        .remove();
                orderService.logStatusChange(order.getId(), oldStatus,
                        OrderStatus.PENDING_DISPATCH.getCode(), adminId, "投诉处理：免费重做，重新待派单");
                notify(complaint.getCustomerId(), "投诉已结案 - 免费重做",
                        "您的订单 #" + order.getOrderNo() + " 已安排免费重做，平台将重新为您派单", order.getId());
                if (oldCleanerId != null) {
                    notify(oldCleanerId, "投诉结案通知",
                            "订单 #" + order.getOrderNo() + " 投诉结案（免费重做），本单收入已清零", order.getId());
                }
            }
        }
    }

    private void syncFeeDetail(Long orderId, BigDecimal newActualFee) {
        FeeDetail fd = feeDetailService.lambdaQuery()
                .eq(FeeDetail::getOrderId, orderId).one();
        if (fd == null) return;
        fd.setActualFee(newActualFee);
        fd.setServiceFee(newActualFee);
        BigDecimal rate = fd.getCommissionRate() != null ? fd.getCommissionRate() : new BigDecimal("0.20");
        BigDecimal commission = newActualFee.multiply(rate).setScale(2, java.math.RoundingMode.HALF_UP);
        fd.setCommissionFee(commission);
        fd.setCleanerIncome(newActualFee.subtract(commission));
        feeDetailService.updateById(fd);
    }

    private void notify(Long userId, String title, String content, Long refId) {
        try {
            notificationService.sendNotification(userId,
                    NotificationType.COMPLAINT_NOTIFY.getCode(), title, content, refId);
        } catch (Exception ignored) {}
    }

    /** 手动同步结案状态（处理异常订单） */
    @PostMapping("/{id}/sync-order")
    public Result<Void> syncOrderStatus(@PathVariable Long id, Authentication auth) {
        Complaint complaint = complaintService.getById(id);
        if (complaint == null) return Result.error(404, "投诉不存在");
        if (complaint.getStatus() != 3) return Result.error("投诉尚未结案");
        ServiceOrder order = orderService.getById(complaint.getOrderId());
        if (order == null) return Result.error("关联订单不存在");
        if (order.getStatus() != 7) return Result.success();
        processOrderOnClose(complaint, (Long) auth.getPrincipal());
        return Result.success();
    }

    @Data
    static class HandleDTO {
        /** 2=处理中  3=已结案 */
        private Integer status;
        /** 1=全额退款  2=驳回投诉  3=免费重做  4=部分退款 */
        private Integer result;
        private String adminRemark;
        /** result=4 时必填：退款金额 */
        private BigDecimal refundAmount;
    }
}
