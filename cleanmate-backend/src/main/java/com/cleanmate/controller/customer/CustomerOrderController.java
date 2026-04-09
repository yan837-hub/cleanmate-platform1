package com.cleanmate.controller.customer;

import com.cleanmate.common.PageResult;
import com.cleanmate.common.Result;
import com.cleanmate.dto.order.CreateOrderDTO;
import com.cleanmate.entity.CleanerProfile;
import com.cleanmate.entity.Complaint;
import com.cleanmate.entity.FeeDetail;
import com.cleanmate.entity.OrderReview;
import com.cleanmate.entity.PaymentRecord;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.entity.SystemConfig;
import com.cleanmate.enums.OrderStatus;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.exception.ErrorCode;
import com.cleanmate.entity.User;
import com.cleanmate.enums.NotificationType;
import com.cleanmate.entity.OrderReschedule;
import com.cleanmate.entity.CleanerIncome;
import com.cleanmate.service.ICleanerIncomeService;
import com.cleanmate.service.ICleanerProfileService;
import com.cleanmate.service.ICleanerTimeLockService;
import com.cleanmate.service.IComplaintService;
import com.cleanmate.service.IFeeDetailService;
import com.cleanmate.service.INotificationService;
import com.cleanmate.service.IOrderRescheduleService;
import com.cleanmate.service.IOrderReviewService;
import com.cleanmate.service.IPaymentRecordService;
import com.cleanmate.service.IServiceOrderService;
import com.cleanmate.service.ISystemConfigService;
import com.cleanmate.service.IUserService;
import com.cleanmate.vo.order.OrderVO;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.math.BigDecimal;
import java.math.RoundingMode;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;

/**
 * 顾客端 - 订单控制器
 */
@RestController
@RequestMapping("/customer/orders")
@RequiredArgsConstructor
public class CustomerOrderController {

    private final IServiceOrderService orderService;
    private final IOrderReviewService reviewService;
    private final ICleanerProfileService cleanerProfileService;
    private final ICleanerTimeLockService cleanerTimeLockService;
    private final IComplaintService complaintService;
    private final INotificationService notificationService;
    private final IUserService userService;
    private final IOrderRescheduleService rescheduleService;
    private final IPaymentRecordService paymentRecordService;
    private final IFeeDetailService feeDetailService;
    private final ISystemConfigService systemConfigService;
    private final ICleanerIncomeService cleanerIncomeService;

    /** 提交预约订单 */
    @PostMapping
    public Result<Long> createOrder(@Valid @RequestBody CreateOrderDTO dto, Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        Long orderId = orderService.createOrder(dto, customerId);
        return Result.success("下单成功", orderId);
    }

    /** 我的订单列表 */
    @GetMapping
    public Result<PageResult<OrderVO>> listMyOrders(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Integer status,
            Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        return Result.success(orderService.listCustomerOrders(customerId, status, current, size));
    }

    /** 订单详情 */
    @GetMapping("/{orderId}")
    public Result<OrderVO> getOrderDetail(@PathVariable Long orderId, Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        OrderVO vo = orderService.getOrderVO(orderId);
        // 校验订单归属
        ServiceOrder order = orderService.getById(orderId);
        if (!order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        return Result.success(vo);
    }

    /** 取消订单 */
    @PutMapping("/{orderId}/cancel")
    public Result<Void> cancelOrder(@PathVariable Long orderId,
                                    @RequestParam(required = false, defaultValue = "") String reason,
                                    Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        // 待派单(1)、待确认(2)：随时可取消
        // 已接单(3)：距预约时间须大于2小时
        // 服务中及之后：不可取消
        int status = order.getStatus();
        if (!java.util.Arrays.asList(1, 2, 3).contains(status)) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }
        if (status == 3) {
            SystemConfig refundCfg = systemConfigService.lambdaQuery()
                    .eq(SystemConfig::getConfigKey, "refund_deadline_hours").one();
            long deadlineHours = refundCfg != null ? Long.parseLong(refundCfg.getConfigValue()) : 2L;
            long minutesLeft = java.time.Duration.between(
                    java.time.LocalDateTime.now(), order.getAppointTime()).toMinutes();
            if (minutesLeft < deadlineHours * 60) {
                throw new BusinessException(1003,
                        "距预约时间不足" + deadlineHours + "小时，无法取消，如需帮助请联系客服");
            }
        }
        int oldStatus = order.getStatus();
        order.setCancelReason(reason);
        order.setStatus(OrderStatus.CANCELLED.getCode());
        orderService.updateById(order);
        // 已派单(2)或已接单(3)时释放保洁员时段锁
        if ((oldStatus == 2 || oldStatus == 3) && order.getCleanerId() != null) {
            cleanerTimeLockService.lambdaUpdate()
                    .eq(com.cleanmate.entity.CleanerTimeLock::getOrderId, orderId).remove();
        }
        orderService.logStatusChange(orderId, oldStatus, OrderStatus.CANCELLED.getCode(), customerId, "顾客取消：" + reason);
        return Result.success();
    }

    /** 顾客首页统计：累计预约、待服务、已完成 */
    @GetMapping("/stats")
    public Result<java.util.Map<String, Object>> stats(Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        long total    = orderService.lambdaQuery().eq(com.cleanmate.entity.ServiceOrder::getCustomerId, customerId)
                .ne(com.cleanmate.entity.ServiceOrder::getStatus, 8).count();
        long pending  = orderService.lambdaQuery().eq(com.cleanmate.entity.ServiceOrder::getCustomerId, customerId)
                .in(com.cleanmate.entity.ServiceOrder::getStatus, java.util.List.of(1, 2, 3, 4, 9)).count();
        long done     = orderService.lambdaQuery().eq(com.cleanmate.entity.ServiceOrder::getCustomerId, customerId)
                .eq(com.cleanmate.entity.ServiceOrder::getStatus, 6).count();
        return Result.success(java.util.Map.of("total", total, "pending", pending, "done", done));
    }

    /** 顾客报告保洁员未到场（状态3，预约时间+30分钟后可操作 -> 8，并通知管理员） */
    @PutMapping("/{orderId}/report-absence")
    public Result<Void> reportAbsence(@PathVariable Long orderId, Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        if (!order.getStatus().equals(OrderStatus.ACCEPTED.getCode())) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }
        // 必须在预约时间+30分钟之后才能报告
        if (java.time.LocalDateTime.now().isBefore(order.getAppointTime().plusMinutes(30))) {
            throw new BusinessException("请在预约时间30分钟后再报告未到场");
        }
        int oldStatus = order.getStatus();
        order.setStatus(OrderStatus.CANCELLED.getCode());
        order.setCancelReason("顾客报告保洁员未到场");
        orderService.updateById(order);
        orderService.logStatusChange(orderId, oldStatus,
                OrderStatus.CANCELLED.getCode(), customerId, "顾客报告保洁员未到场");
        // 通知所有管理员
        String msg = "订单 #" + order.getOrderNo() + " 顾客报告保洁员未到场，请及时处理";
        userService.lambdaQuery().eq(User::getRole, 3).list()
                .forEach(admin -> notificationService.sendNotification(
                        admin.getId(),
                        NotificationType.COMPLAINT_NOTIFY.getCode(),
                        "保洁员未到场告警", msg, order.getId()));
        return Result.success();
    }

    /** 查询订单评价（已有则返回，未评价返回 null） */
    @GetMapping("/{orderId}/review")
    public Result<OrderReview> getReview(@PathVariable Long orderId, Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        OrderReview review = reviewService.lambdaQuery()
                .eq(OrderReview::getOrderId, orderId).one();
        return Result.success(review);
    }

    /** 提交评价（仅已完成订单，且未评价过） */
    @PostMapping("/{orderId}/review")
    public Result<Void> submitReview(@PathVariable Long orderId,
                                     @RequestBody java.util.Map<String, Object> body,
                                     Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        // 允许评价：status=6 正常完成，或 status=7 且投诉已结案（非免费重做）
        boolean canReview = order.getStatus().equals(OrderStatus.COMPLETED.getCode());
        if (!canReview && order.getStatus().equals(OrderStatus.AFTER_SALE.getCode())) {
            Complaint complaint = complaintService.lambdaQuery()
                    .eq(Complaint::getOrderId, orderId).one();
            canReview = complaint != null
                    && complaint.getStatus() == 3   // 已结案
                    && complaint.getResult() != null
                    && complaint.getResult() != 3;  // 非免费重做
        }
        if (!canReview) {
            throw new BusinessException("只有已完成或售后结案的订单才能评价");
        }
        boolean exists = reviewService.lambdaQuery().eq(OrderReview::getOrderId, orderId).exists();
        if (exists) throw new BusinessException("该订单已评价过");

        int attitude  = Integer.parseInt(body.getOrDefault("scoreAttitude", 5).toString());
        int quality   = Integer.parseInt(body.getOrDefault("scoreQuality",  5).toString());
        int punctual  = Integer.parseInt(body.getOrDefault("scorePunctual", 5).toString());
        String content = body.getOrDefault("content", "").toString();
        String imgs    = body.getOrDefault("imgs", "").toString();

        BigDecimal avg = BigDecimal.valueOf((attitude + quality + punctual) / 3.0)
                .setScale(2, RoundingMode.HALF_UP);

        OrderReview review = new OrderReview();
        review.setOrderId(orderId);
        review.setCustomerId(customerId);
        review.setCleanerId(order.getCleanerId());
        review.setScoreAttitude(attitude);
        review.setScoreQuality(quality);
        review.setScorePunctual(punctual);
        review.setAvgScore(avg);
        review.setContent(content.isBlank() ? null : content);
        review.setImgs(imgs.isBlank() ? null : imgs);
        review.setIsVisible(1);
        reviewService.save(review);

        // 更新保洁员综合评分
        if (order.getCleanerId() != null) {
            BigDecimal newAvg = reviewService.lambdaQuery()
                    .eq(OrderReview::getCleanerId, order.getCleanerId())
                    .list().stream()
                    .map(OrderReview::getAvgScore)
                    .reduce(BigDecimal.ZERO, BigDecimal::add)
                    .divide(BigDecimal.valueOf(
                            reviewService.lambdaQuery().eq(OrderReview::getCleanerId, order.getCleanerId()).count()),
                            2, RoundingMode.HALF_UP);
            CleanerProfile profile = cleanerProfileService.lambdaQuery()
                    .eq(CleanerProfile::getUserId, order.getCleanerId()).one();
            if (profile != null) {
                profile.setAvgScore(newAvg);
                cleanerProfileService.updateById(profile);
            }
        }
        return Result.success();
    }

    /**
     * 顾客发起投诉
     * 允许时机：
     *   1. status=5（待确认完成）：顾客拒绝确认，订单进入售后 status=7
     *   2. status=6（已完成）：完成后7天内发现问题，发起售后投诉
     */
    @PostMapping("/{orderId}/complaint")
    public Result<Void> submitComplaint(@PathVariable Long orderId,
                                        @RequestBody ComplaintDTO dto,
                                        Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }

        int status = order.getStatus();
        // status=5：待确认完成 -> 可发起投诉（拒绝确认）
        // status=6：已完成，7天内可发起售后
        if (status == OrderStatus.PENDING_COMPLETE_CONFIRM.getCode()) {
            // 订单进入售后处理中
            int oldStatus = order.getStatus();
            order.setStatus(OrderStatus.AFTER_SALE.getCode());
            orderService.updateById(order);
            orderService.logStatusChange(orderId, oldStatus,
                    OrderStatus.AFTER_SALE.getCode(), customerId, "顾客拒绝确认完成，发起投诉");
        } else if (status == OrderStatus.COMPLETED.getCode()) {
            // 已完成：7天内可投诉
            if (order.getCompletedAt() == null ||
                    java.time.LocalDateTime.now().isAfter(order.getCompletedAt().plusDays(7))) {
                throw new BusinessException("订单完成超过7天，无法发起投诉，请联系客服");
            }
            // 订单进入售后
            order.setStatus(OrderStatus.AFTER_SALE.getCode());
            orderService.updateById(order);
            orderService.logStatusChange(orderId, OrderStatus.COMPLETED.getCode(),
                    OrderStatus.AFTER_SALE.getCode(), customerId, "顾客完成后发起投诉");
        } else {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }

        // 检查是否已有投诉
        boolean exists = complaintService.lambdaQuery()
                .eq(Complaint::getOrderId, orderId).exists();
        if (exists) throw new BusinessException("该订单已存在投诉，请勿重复提交");

        Complaint complaint = new Complaint();
        complaint.setOrderId(orderId);
        complaint.setCustomerId(customerId);
        complaint.setCleanerId(order.getCleanerId());
        complaint.setReason(dto.getReason());
        complaint.setImgs(dto.getImgs());
        complaint.setStatus(1); // 待处理
        complaintService.save(complaint);

        // 通知所有管理员有新投诉
        String msg = "订单 #" + order.getOrderNo() + " 收到新投诉，请及时处理";
        userService.lambdaQuery().eq(User::getRole, 3).list().forEach(admin -> {
            com.cleanmate.entity.Notification n = new com.cleanmate.entity.Notification();
            n.setUserId(admin.getId());
            n.setType(NotificationType.COMPLAINT_NOTIFY.getCode());
            n.setTitle("新投诉待处理");
            n.setContent(msg);
            n.setRefId(order.getId());
            n.setIsRead(0);
            try { notificationService.save(n); } catch (Exception ignored) {}
        });
        return Result.success();
    }

    /** 查询当前订单的投诉（已存在则返回） */
    @GetMapping("/{orderId}/complaint")
    public Result<Complaint> getComplaint(@PathVariable Long orderId, Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        Complaint complaint = complaintService.lambdaQuery()
                .eq(Complaint::getOrderId, orderId).one();
        return Result.success(complaint);
    }

    // ─────────── 改期申请 ───────────

    /**
     * 顾客提交改期申请（仅 status=3 已接单时可操作）
     * - 距预约时间须 > 2小时
     * - 无待审核的改期申请（通过 order.status=9 隐含保证）
     */
    @PostMapping("/{orderId}/reschedule")
    public Result<Void> submitReschedule(@PathVariable Long orderId,
                                         @RequestBody java.util.Map<String, String> body,
                                         Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        // 仅 status=3（已接单）允许申请
        if (!order.getStatus().equals(OrderStatus.ACCEPTED.getCode())) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }
        // 距预约时间须 > 2小时
        long minutesLeft = java.time.Duration.between(LocalDateTime.now(), order.getAppointTime()).toMinutes();
        if (minutesLeft < 120) {
            throw new BusinessException("距服务时间不足2小时，无法申请改期");
        }
        // 解析新预约时间
        String newTimeStr = body.get("newAppointTime");
        if (newTimeStr == null || newTimeStr.isBlank()) {
            throw new BusinessException(ErrorCode.PARAM_ERROR);
        }
        LocalDateTime newTime = LocalDateTime.parse(newTimeStr.replace(" ", "T"));

        // 插入改期申请
        OrderReschedule record = new OrderReschedule();
        record.setOrderId(orderId);
        record.setCustomerId(customerId);
        record.setOldTime(order.getAppointTime());
        record.setNewTime(newTime);
        record.setStatus(1);
        rescheduleService.save(record);

        // 删除旧时段锁（避免档期校验误判）
        cleanerTimeLockService.lambdaUpdate()
                .eq(com.cleanmate.entity.CleanerTimeLock::getOrderId, orderId).remove();

        // 订单进入"改期审核中"状态
        orderService.lambdaUpdate()
                .eq(ServiceOrder::getId, orderId)
                .set(ServiceOrder::getStatus, OrderStatus.RESCHEDULING.getCode())
                .update();
        orderService.logStatusChange(orderId, OrderStatus.ACCEPTED.getCode(),
                OrderStatus.RESCHEDULING.getCode(), customerId, "顾客申请改期");

        // 通知保洁员
        if (order.getCleanerId() != null) {
            notificationService.sendNotification(
                    order.getCleanerId(),
                    NotificationType.RESCHEDULE_REQUEST.getCode(),
                    "顾客申请改期",
                    "顾客申请将订单 #" + order.getOrderNo() + " 从 " + order.getAppointTime().toString().replace("T", " ").substring(0, 16)
                            + " 改为 " + newTime.toString().replace("T", " ").substring(0, 16) + "，请确认",
                    orderId);
        }
        return Result.success();
    }

    /** 查询该订单最新一条改期申请（顾客查询结果用） */
    @GetMapping("/{orderId}/reschedule-status")
    public Result<OrderReschedule> getRescheduleStatus(@PathVariable Long orderId, Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        OrderReschedule latest = rescheduleService.lambdaQuery()
                .eq(OrderReschedule::getOrderId, orderId)
                .orderByDesc(OrderReschedule::getId)
                .last("LIMIT 1")
                .one();
        return Result.success(latest);
    }

    // ─────────── 模拟支付 ───────────

    /** 支付定金（status=1 且 pay_status=0） */
    @Transactional(rollbackFor = Exception.class)
    @PostMapping("/{orderId}/pay-deposit")
    public Result<java.util.Map<String, Object>> payDeposit(@PathVariable Long orderId, Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        if (!Integer.valueOf(1).equals(order.getStatus()) || !Integer.valueOf(0).equals(order.getPayStatus())) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }
        if (order.getEstimateFee() == null) {
            throw new BusinessException("订单尚未生成预估费用，无法支付定金");
        }

        // 从系统配置读取定金比例，默认 0.30
        BigDecimal depositRate = new BigDecimal("0.30");
        SystemConfig cfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "deposit_rate").one();
        if (cfg != null && cfg.getConfigValue() != null) {
            try { depositRate = new BigDecimal(cfg.getConfigValue()); } catch (Exception ignored) {}
        }

        BigDecimal depositFee = order.getEstimateFee()
                .multiply(depositRate)
                .setScale(2, RoundingMode.HALF_UP);

        // 插入支付记录
        PaymentRecord pr = new PaymentRecord();
        pr.setOrderId(orderId);
        pr.setPayType(1);
        pr.setAmount(depositFee);
        pr.setPayMethod(99);
        pr.setPayStatus(2);
        pr.setPayTime(LocalDateTime.now());
        paymentRecordService.save(pr);

        // 更新订单
        order.setDepositFee(depositFee);
        order.setPayStatus(1);
        orderService.updateById(order);

        return Result.success(java.util.Map.of("depositFee", depositFee, "message", "定金支付成功（模拟）"));
    }

    /** 支付尾款（status IN(5,6) 且 pay_status=1） */
    @Transactional(rollbackFor = Exception.class)
    @PostMapping("/{orderId}/pay-final")
    public Result<java.util.Map<String, Object>> payFinal(@PathVariable Long orderId, Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        if (!List.of(5, 6).contains(order.getStatus()) || !Integer.valueOf(1).equals(order.getPayStatus())) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }

        BigDecimal actualFee = order.getActualFee() != null ? order.getActualFee() : order.getEstimateFee();
        BigDecimal depositFee = order.getDepositFee() != null ? order.getDepositFee() : BigDecimal.ZERO;
        BigDecimal tailFee = actualFee.subtract(depositFee).setScale(2, RoundingMode.HALF_UP);

        PaymentRecord pr = new PaymentRecord();
        pr.setOrderId(orderId);
        pr.setPayType(2);
        pr.setAmount(tailFee);
        pr.setPayMethod(99);
        pr.setPayStatus(2);
        pr.setPayTime(LocalDateTime.now());
        paymentRecordService.save(pr);

        order.setPayStatus(2);
        orderService.updateById(order);

        // 更新 fee_detail
        FeeDetail fd = feeDetailService.lambdaQuery().eq(FeeDetail::getOrderId, orderId).one();
        if (fd != null) {
            fd.setDepositFee(depositFee);
            fd.setTailFee(tailFee);
            feeDetailService.updateById(fd);
        }

        return Result.success(java.util.Map.of("tailFee", tailFee, "message", "尾款支付成功（模拟）"));
    }

    /** 支付全额（status IN(5,6) 且 pay_status=0） */
    @Transactional(rollbackFor = Exception.class)
    @PostMapping("/{orderId}/pay-full")
    public Result<java.util.Map<String, Object>> payFull(@PathVariable Long orderId, Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        if (!List.of(5, 6).contains(order.getStatus()) || !Integer.valueOf(0).equals(order.getPayStatus())) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }

        BigDecimal actualFee = order.getActualFee() != null ? order.getActualFee() : order.getEstimateFee();

        PaymentRecord pr = new PaymentRecord();
        pr.setOrderId(orderId);
        pr.setPayType(3);
        pr.setAmount(actualFee);
        pr.setPayMethod(99);
        pr.setPayStatus(2);
        pr.setPayTime(LocalDateTime.now());
        paymentRecordService.save(pr);

        order.setPayStatus(2);
        orderService.updateById(order);

        return Result.success(java.util.Map.of("actualFee", actualFee, "message", "全额支付成功（模拟）"));
    }

    /** 查询该订单所有支付记录 */
    @GetMapping("/{orderId}/payment-records")
    public Result<List<PaymentRecord>> getPaymentRecords(@PathVariable Long orderId, Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        List<PaymentRecord> records = paymentRecordService.lambdaQuery()
                .eq(PaymentRecord::getOrderId, orderId)
                .orderByAsc(PaymentRecord::getPayTime)
                .list();
        return Result.success(records);
    }

    @Data
    static class ComplaintDTO {
        private String reason;
        /** 投诉凭证图片URLs，逗号分隔（选填） */
        private String imgs;
    }

    /** 顾客确认完成（状态 5 -> 6） */
    @PutMapping("/{orderId}/confirm")
    public Result<Void> confirmComplete(@PathVariable Long orderId, Authentication auth) {
        Long customerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !order.getCustomerId().equals(customerId)) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        if (!order.getStatus().equals(OrderStatus.PENDING_COMPLETE_CONFIRM.getCode())) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }
        order.setStatus(OrderStatus.COMPLETED.getCode());
        order.setCompletedAt(java.time.LocalDateTime.now());
        orderService.updateById(order);
        orderService.logStatusChange(orderId, OrderStatus.PENDING_COMPLETE_CONFIRM.getCode(),
                OrderStatus.COMPLETED.getCode(), customerId, "顾客确认完成");
        // 结算保洁员收入：待结算 → 已结算
        if (order.getCleanerId() != null) {
            cleanerIncomeService.lambdaUpdate()
                    .eq(CleanerIncome::getOrderId, orderId)
                    .set(CleanerIncome::getStatus, 2)
                    .set(CleanerIncome::getSettledAt, LocalDateTime.now())
                    .update();
        }
        // 通知保洁员：顾客已确认完成
        if (order.getCleanerId() != null) {
            notificationService.sendNotification(
                    order.getCleanerId(),
                    NotificationType.SERVICE_COMPLETED.getCode(),
                    "顾客已确认完成",
                    "顾客已确认订单 #" + order.getOrderNo() + " 完成，收入已计入本月结算",
                    orderId);
        }
        return Result.success();
    }
}
