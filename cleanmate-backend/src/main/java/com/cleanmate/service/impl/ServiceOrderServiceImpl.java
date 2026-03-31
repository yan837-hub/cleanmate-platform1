package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.common.PageResult;
import com.cleanmate.dto.order.CreateOrderDTO;
import com.cleanmate.dto.order.ExternalImportDTO;
import com.cleanmate.entity.*;
import com.cleanmate.enums.NotificationType;
import com.cleanmate.enums.OrderStatus;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.mapper.ServiceOrderMapper;
import com.cleanmate.service.*;
import com.cleanmate.vo.dispatch.CandidateVO;
import com.cleanmate.vo.order.OrderVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.cleanmate.exception.ErrorCode;
import com.cleanmate.utils.DistanceUtil;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import org.springframework.security.crypto.password.PasswordEncoder;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ServiceOrderServiceImpl extends ServiceImpl<ServiceOrderMapper, ServiceOrder>
        implements IServiceOrderService {

    private final IServiceTypeService serviceTypeService;
    private final IServicePriceTierService priceTierService;
    private final ICustomerAddressService addressService;
    private final IOrderStatusLogService statusLogService;
    private final IUserService userService;
    private final ICleanerProfileService cleanerProfileService;
    private final IDispatchRecordService dispatchRecordService;
    private final ICleanerTimeLockService cleanerTimeLockService;
    private final ICleanerScheduleTemplateService scheduleTemplateService;
    private final ICheckinRecordService checkinRecordService;
    private final IFeeDetailService feeDetailService;
    private final INotificationService notificationService;
    private final IComplaintService complaintService;
    private final ISystemConfigService systemConfigService;
    private final ICleanerIncomeService cleanerIncomeService;
    private final ICleaningCompanyService cleaningCompanyService;
    private final IOperationLogService operationLogService;
    private final PasswordEncoder passwordEncoder;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long createOrder(CreateOrderDTO dto, Long customerId) {
        // 1. 校验服务类型
        ServiceType serviceType = serviceTypeService.getById(dto.getServiceTypeId());
        if (serviceType == null || serviceType.getStatus() == 2) {
            throw new BusinessException("服务类型不存在或已下架");
        }

        // 2. 校验地址归属
        CustomerAddress address = addressService.getById(dto.getAddressId());
        if (address == null || !address.getUserId().equals(customerId)) {
            throw new BusinessException("地址不存在");
        }

        // 3. 按计价模式计算预估费用
        BigDecimal estimateFee = calculateFee(serviceType, dto.getPlanDuration(), dto.getHouseArea());

        // 4. 构建地址快照
        String snapshot = address.getProvince() + address.getCity() + address.getDistrict()
                + address.getDetail() + " | " + address.getContactName() + " " + address.getContactPhone();

        // 5. 生成订单号
        String orderNo = "CM" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", new Random().nextInt(10000));

        // 6. 保存订单
        ServiceOrder order = new ServiceOrder();
        order.setOrderNo(orderNo);
        order.setSource(1);
        order.setCustomerId(customerId);
        order.setServiceTypeId(dto.getServiceTypeId());
        order.setAddressId(dto.getAddressId());
        order.setAddressSnapshot(snapshot);
        order.setLongitude(address.getLongitude());
        order.setLatitude(address.getLatitude());
        order.setHouseArea(dto.getHouseArea());
        order.setPlanDuration(dto.getPlanDuration());
        order.setAppointTime(dto.getAppointTime());
        order.setRemark(dto.getRemark());
        order.setStatus(OrderStatus.PENDING_DISPATCH.getCode());
        order.setEstimateFee(estimateFee);
        order.setPayStatus(0);
        this.save(order);

        // 7. 记录状态日志
        logStatusChange(order.getId(), null, OrderStatus.PENDING_DISPATCH.getCode(), customerId, "顾客下单");

        // 8. 下单成功通知顾客
        notify(customerId, NotificationType.ORDER_CREATED.getCode(),
                "订单已提交",
                "您的" + serviceType.getName() + "订单 #" + order.getOrderNo() + " 已提交，正在为您匹配保洁员",
                order.getId());

        return order.getId();
    }

    @Override
    public OrderVO getOrderVO(Long orderId) {
        ServiceOrder order = this.getById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        return toVO(order);
    }

    @Override
    public PageResult<OrderVO> listCustomerOrders(Long customerId, Integer status, long current, long size) {
        LambdaQueryWrapper<ServiceOrder> wrapper = new LambdaQueryWrapper<ServiceOrder>()
                .eq(ServiceOrder::getCustomerId, customerId)
                .eq(status != null, ServiceOrder::getStatus, status)
                .orderByDesc(ServiceOrder::getCreatedAt);

        Page<ServiceOrder> page = this.page(new Page<>(current, size), wrapper);
        List<OrderVO> vos = page.getRecords().stream().map(this::toVO).collect(Collectors.toList());
        return PageResult.of(vos, page.getTotal(), page.getCurrent(), page.getSize());
    }

    @Override
    public void logStatusChange(Long orderId, Integer fromStatus, Integer toStatus, Long operatorId, String remark) {
        OrderStatusLog log = new OrderStatusLog();
        log.setOrderId(orderId);
        log.setFromStatus(fromStatus);
        log.setToStatus(toStatus);
        log.setOperatorId(operatorId);
        log.setRemark(remark);
        statusLogService.save(log);
    }

    @Override
    public PageResult<OrderVO> listCleanerOrders(Long cleanerId, Integer status, long current, long size) {
        LambdaQueryWrapper<ServiceOrder> wrapper = new LambdaQueryWrapper<ServiceOrder>()
                .eq(ServiceOrder::getCleanerId, cleanerId)
                .eq(status != null, ServiceOrder::getStatus, status)
                .orderByDesc(ServiceOrder::getCreatedAt);
        Page<ServiceOrder> page = this.page(new Page<>(current, size), wrapper);
        List<OrderVO> vos = page.getRecords().stream().map(this::toVO).collect(Collectors.toList());
        return PageResult.of(vos, page.getTotal(), page.getCurrent(), page.getSize());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void grabOrder(Long orderId, Long cleanerId) {
        ServiceOrder order = this.getById(orderId);
        if (order == null) throw new BusinessException(ErrorCode.ORDER_NOT_EXIST);
        if (!order.getStatus().equals(OrderStatus.PENDING_DISPATCH.getCode()))
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);

        // 校验账号状态
        User cleanerUser = userService.getById(cleanerId);
        if (cleanerUser == null || cleanerUser.getStatus() != 1)
            throw new BusinessException("账号已被禁用");
        // 校验保洁员档案审核状态
        CleanerProfile profile = cleanerProfileService.lambdaQuery()
                .eq(CleanerProfile::getUserId, cleanerId).one();
        if (profile == null || profile.getAuditStatus() != 1)
            throw new BusinessException("账号审核未通过，暂无法接单");

        // 检查保洁员档期可用性（模板/特殊调整/时段锁定 三合一校验）
        int planMin = order.getPlanDuration() != null ? order.getPlanDuration() : 120;
        LocalDateTime lockStart = order.getAppointTime().minusMinutes(30);
        LocalDateTime lockEnd = order.getAppointTime().plusMinutes(planMin + 30);
        if (!scheduleTemplateService.isCleanerAvailable(cleanerId, lockStart, lockEnd)) {
            throw new BusinessException(ErrorCode.CLEANER_NOT_AVAILABLE);
        }

        // 更新订单
        order.setCleanerId(cleanerId);
        order.setStatus(OrderStatus.ACCEPTED.getCode());
        this.updateById(order);

        // 写派单记录
        DispatchRecord dispatch = new DispatchRecord();
        dispatch.setOrderId(orderId);
        dispatch.setCleanerId(cleanerId);
        dispatch.setDispatchType(3);
        dispatch.setStatus(2);
        dispatch.setRespondAt(LocalDateTime.now());
        dispatch.setExpireAt(LocalDateTime.now());
        dispatchRecordService.save(dispatch);

        // 锁定时段
        CleanerTimeLock lock = new CleanerTimeLock();
        lock.setCleanerId(cleanerId);
        lock.setOrderId(orderId);
        lock.setLockStart(lockStart);
        lock.setLockEnd(lockEnd);
        cleanerTimeLockService.save(lock);

        logStatusChange(orderId, OrderStatus.PENDING_DISPATCH.getCode(), OrderStatus.ACCEPTED.getCode(), cleanerId, "保洁员抢单");

        // 通知顾客：保洁员已接单
        notify(order.getCustomerId(), NotificationType.ORDER_DISPATCHED.getCode(),
                "保洁员已接单",
                "保洁员已接受您的订单 #" + order.getOrderNo() + "，请按时在家等候",
                orderId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void checkinOrder(Long orderId, Long cleanerId, Double longitude, Double latitude) {
        ServiceOrder order = this.getById(orderId);
        if (order == null) throw new BusinessException(ErrorCode.ORDER_NOT_EXIST);
        if (!cleanerId.equals(order.getCleanerId())) throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        if (!order.getStatus().equals(OrderStatus.ACCEPTED.getCode()))
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);

        // 校验账号状态
        User checkinUser = userService.getById(cleanerId);
        if (checkinUser == null || checkinUser.getStatus() != 1)
            throw new BusinessException("账号已被禁用");

        // 签到时间窗口校验：预约时间前1小时 ~ 预约时间后2小时
        LocalDateTime appointTime = order.getAppointTime();
        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(appointTime.minusHours(1))) {
            throw new BusinessException(ErrorCode.CHECKIN_TOO_EARLY);
        }
        if (now.isAfter(appointTime.plusHours(2))) {
            throw new BusinessException(ErrorCode.CHECKIN_TOO_LATE);
        }

        // 计算与订单地址的距离，偏差上限从系统参数读取
        SystemConfig checkinCfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "checkin_max_distance_m").one();
        int maxCheckinDistM = checkinCfg != null ? Integer.parseInt(checkinCfg.getConfigValue()) : 500;

        int distanceM = 0;
        int isAbnormal = 0;
        if (order.getLongitude() != null && order.getLatitude() != null) {
            distanceM = com.cleanmate.utils.DistanceUtil.calculateMeters(
                    latitude, longitude,
                    order.getLatitude().doubleValue(), order.getLongitude().doubleValue());
            isAbnormal = distanceM > maxCheckinDistM ? 1 : 0;
            if (isAbnormal == 1) {
                throw new BusinessException(1004,
                        "签到失败：当前位置距服务地址偏差 " + distanceM + " 米，超出允许范围 " + maxCheckinDistM + " 米");
            }
        }

        CheckinRecord record = new CheckinRecord();
        record.setOrderId(orderId);
        record.setCleanerId(cleanerId);
        record.setCheckinTime(LocalDateTime.now());
        record.setLongitude(BigDecimal.valueOf(longitude));
        record.setLatitude(BigDecimal.valueOf(latitude));
        record.setDistanceM(distanceM);
        record.setIsAbnormal(isAbnormal);
        checkinRecordService.save(record);

        order.setStatus(OrderStatus.IN_SERVICE.getCode());
        this.updateById(order);
        logStatusChange(orderId, OrderStatus.ACCEPTED.getCode(), OrderStatus.IN_SERVICE.getCode(), cleanerId, "保洁员签到打卡");

        // 通知顾客：保洁员已到达
        notify(order.getCustomerId(), NotificationType.CLEANER_CHECKIN.getCode(),
                "保洁员已到达",
                "保洁员已到达您的服务地址，订单 #" + order.getOrderNo() + " 即将开始服务",
                orderId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void reportComplete(Long orderId, Long cleanerId, Integer actualDuration) {
        ServiceOrder order = this.getById(orderId);
        if (order == null) throw new BusinessException(ErrorCode.ORDER_NOT_EXIST);
        if (!cleanerId.equals(order.getCleanerId())) throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        if (!order.getStatus().equals(OrderStatus.IN_SERVICE.getCode()))
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);

        ServiceType serviceType = serviceTypeService.getById(order.getServiceTypeId());
        BigDecimal actualFee = computeActualFee(serviceType, actualDuration, order.getHouseArea());

        // 超时附加费（按小时计价时）
        BigDecimal overtimeFee = BigDecimal.ZERO;
        if (serviceType.getPriceMode() == 1 && order.getPlanDuration() != null
                && actualDuration > order.getPlanDuration()) {
            int overtimeMin = actualDuration - order.getPlanDuration();
            overtimeFee = serviceType.getBasePrice()
                    .multiply(BigDecimal.valueOf(overtimeMin))
                    .divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);
            actualFee = actualFee.add(overtimeFee);
        }

        // 从 system_config 读取佣金比例，默认 0.20
        SystemConfig cfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "commission_rate").one();
        BigDecimal commissionRate = cfg != null && cfg.getConfigValue() != null
                ? new BigDecimal(cfg.getConfigValue())
                : new BigDecimal("0.20");
        BigDecimal commissionFee = actualFee.multiply(commissionRate).setScale(2, RoundingMode.HALF_UP);
        BigDecimal cleanerIncome = actualFee.subtract(commissionFee);

        FeeDetail fee = new FeeDetail();
        fee.setOrderId(orderId);
        fee.setServiceFee(actualFee.subtract(overtimeFee));
        fee.setOvertimeFee(overtimeFee);
        fee.setCouponDeduct(BigDecimal.ZERO);
        fee.setActualFee(actualFee);
        fee.setDepositFee(BigDecimal.ZERO);
        fee.setTailFee(actualFee);
        fee.setCommissionRate(commissionRate);
        fee.setCommissionFee(commissionFee);
        fee.setCleanerIncome(cleanerIncome);
        feeDetailService.save(fee);

        // 写入保洁员收入流水
        CleanerIncome income = new CleanerIncome();
        income.setCleanerId(cleanerId);
        income.setOrderId(orderId);
        income.setAmount(cleanerIncome);
        income.setSettleMonth(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM")));
        income.setStatus(1); // 待结算
        cleanerIncomeService.save(income);

        order.setActualDuration(actualDuration);
        order.setActualFee(actualFee);
        order.setStatus(OrderStatus.PENDING_COMPLETE_CONFIRM.getCode());
        order.setAutoConfirmAt(LocalDateTime.now().plusHours(48));
        this.updateById(order);
        logStatusChange(orderId, OrderStatus.IN_SERVICE.getCode(),
                OrderStatus.PENDING_COMPLETE_CONFIRM.getCode(), cleanerId, "保洁员完工上报");

        // 通知顾客：服务已完成，请确认
        notify(order.getCustomerId(), NotificationType.SERVICE_COMPLETED.getCode(),
                "服务已���成",
                "您的订单 #" + order.getOrderNo() + " 保洁员已完工，请在48小时内确认并评价",
                orderId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long autoDispatch(Long orderId) {
        ServiceOrder order = this.getById(orderId);
        if (order == null) throw new BusinessException(ErrorCode.ORDER_NOT_EXIST);
        if (!order.getStatus().equals(OrderStatus.PENDING_DISPATCH.getCode()))
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);

        // 从系统参数读取派单配置（无记录时使用默认值）
        SystemConfig maxDistCfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "dispatch_max_distance_km").one();
        double maxDistKm = maxDistCfg != null ? Double.parseDouble(maxDistCfg.getConfigValue()) : 30.0;

        SystemConfig bufferCfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "commute_buffer_minutes").one();
        long commuteBufferMin = bufferCfg != null ? Long.parseLong(bufferCfg.getConfigValue()) : 30L;

        SystemConfig timeoutCfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "dispatch_timeout_minutes").one();
        long dispatchTimeoutMin = timeoutCfg != null ? Long.parseLong(timeoutCfg.getConfigValue()) : 30L;

        int planMin = order.getPlanDuration() != null ? order.getPlanDuration() : 120;
        // lockStart/lockEnd 含通勤缓冲，传给档期检查
        LocalDateTime lockStart = order.getAppointTime().minusMinutes(commuteBufferMin);
        LocalDateTime lockEnd   = order.getAppointTime().plusMinutes(planMin + commuteBufferMin);

        boolean orderHasLocation = order.getLatitude() != null && order.getLongitude() != null;
        double orderLat = orderHasLocation ? order.getLatitude().doubleValue()  : 0;
        double orderLon = orderHasLocation ? order.getLongitude().doubleValue() : 0;

        // ── 一、构建候选人池（三道过滤）─────────────────────────────────
        List<CleanerProfile> allCleaners = cleanerProfileService.lambdaQuery()
                .eq(CleanerProfile::getAuditStatus, 1).list();

        List<CandidateScore> candidates = new ArrayList<>();

        for (CleanerProfile cp : allCleaners) {
            // 过滤①：账号状态正常
            User u = userService.getById(cp.getUserId());
            if (u == null || u.getStatus() != 1) continue;

            // 过滤②：档期可用（模板 + 特殊调整 + 时段锁定三合一）
            if (!scheduleTemplateService.isCleanerAvailable(cp.getUserId(), lockStart, lockEnd)) continue;

            // 过滤②+：已派单待确认的订单也占用时段（尚未写time_lock，需单独检查）
            boolean pendingConflict = this.lambdaQuery()
                    .eq(ServiceOrder::getCleanerId, cp.getUserId())
                    .eq(ServiceOrder::getStatus, OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode())
                    .list()
                    .stream()
                    .anyMatch(pending -> {
                        int pPlan = pending.getPlanDuration() != null ? pending.getPlanDuration() : 120;
                        LocalDateTime pStart = pending.getAppointTime().minusMinutes(30);
                        LocalDateTime pEnd   = pending.getAppointTime().plusMinutes(pPlan + 30);
                        return pStart.isBefore(lockEnd) && pEnd.isAfter(lockStart);
                    });
            if (pendingConflict) continue;

            // 过滤③：距离过滤（双方都有坐标才计算；缺坐标则视为附近，不排除）
            double homeDistKm;
            if (orderHasLocation && cp.getLatitude() != null && cp.getLongitude() != null) {
                homeDistKm = DistanceUtil.calculateKm(
                        orderLat, orderLon,
                        cp.getLatitude().doubleValue(), cp.getLongitude().doubleValue());
                if (homeDistKm > maxDistKm) continue; // 超出配置距离上限则排除
            } else {
                homeDistKm = 0; // 坐标缺失时不排除，距离得分按最近处理
            }

            // ── 二、确定实际出发距离（优先用上一单位置）──────────────────
            // 取本单 appointTime 之前最近的已接单/服务中/待确认完成订单
            ServiceOrder prevOrder = this.lambdaQuery()
                    .eq(ServiceOrder::getCleanerId, cp.getUserId())
                    .in(ServiceOrder::getStatus, 3, 4, 5)
                    .lt(ServiceOrder::getAppointTime, order.getAppointTime())
                    .orderByDesc(ServiceOrder::getAppointTime)
                    .last("LIMIT 1").one();

            double distKm;
            boolean timeFeasible = true;

            if (prevOrder != null && prevOrder.getLongitude() != null && prevOrder.getLatitude() != null) {
                // 用上一单服务地址作为出发点
                distKm = DistanceUtil.calculateKm(
                        orderLat, orderLon,
                        prevOrder.getLatitude().doubleValue(), prevOrder.getLongitude().doubleValue());

                // ── 三、时间可行性检查 ──────────────────────────────────
                int prevPlan     = prevOrder.getPlanDuration() != null ? prevOrder.getPlanDuration() : 120;
                LocalDateTime prevEnd   = prevOrder.getAppointTime().plusMinutes(prevPlan);
                double commuteMins      = distKm / 30.0 * 60;          // 按 30km/h 估算通勤
                long gapMins            = Duration.between(prevEnd, order.getAppointTime()).toMinutes();
                // 间隔 < 通勤时间 + 缓冲分钟，则视为时间偏紧，评分降权
                timeFeasible = gapMins >= commuteMins + commuteBufferMin;
            } else {
                // 无上一单，用常驻位置距离
                distKm = homeDistKm;
            }

            // ── 四、综合评分：距离50% + 评分30% + 均衡20%，时间偏紧降权50%
            double distanceScore = 1000.0 / (distKm + 1) * 0.5;
            double ratingScore   = (cp.getAvgScore() != null ? cp.getAvgScore().doubleValue() : 3.0) * 20 * 0.3;
            // 均衡分：近30天接单数（含待确认/进行中）越少分越高，防止单子集中派给同一人
            // 公式用对数平滑，避免0单时均衡分过高掩盖距离优势
            long recentOrders    = this.lambdaQuery()
                    .eq(ServiceOrder::getCleanerId, cp.getUserId())
                    .in(ServiceOrder::getStatus, 2, 3, 4, 5, 6)
                    .ge(ServiceOrder::getAppointTime, LocalDateTime.now().minusDays(30))
                    .count();
            double balanceScore  = 100.0 / (Math.log(recentOrders + 2)) * 0.2;
            double totalScore    = (distanceScore + ratingScore + balanceScore) * (timeFeasible ? 1.0 : 0.5);

            candidates.add(new CandidateScore(cp.getUserId(), distKm, totalScore));
        }

        // ── 五、无候选人 → 通知所有管理员手动处理 ────────────────────────
        if (candidates.isEmpty()) {
            userService.lambdaQuery().eq(User::getRole, 3).list()
                    .forEach(admin -> notify(admin.getId(),
                            NotificationType.TIMEOUT_ALERT.getCode(),
                            "派单失败，需手动处理",
                            "订单 " + order.getOrderNo() + " 暂无合适保洁员，请手动派单",
                            orderId));
            return null;
        }

        // ── 六、取综合得分最高的候选人 ────────────────────────────────────
        CandidateScore best = candidates.stream()
                .max(Comparator.comparingDouble(c -> c.totalScore))
                .orElseThrow();

        // ── 七、写派单记录 ─────────────────────────────────────────────
        DispatchRecord dispatch = new DispatchRecord();
        dispatch.setOrderId(orderId);
        dispatch.setCleanerId(best.cleanerId);
        dispatch.setDispatchType(1); // 1=系统自动
        dispatch.setStatus(1);       // 1=待响应
        dispatch.setDistanceKm(new BigDecimal(String.valueOf(best.distanceKm)).setScale(2, RoundingMode.HALF_UP));
        dispatch.setScore(new BigDecimal(String.valueOf(best.totalScore)).setScale(2, RoundingMode.HALF_UP));
        dispatch.setExpireAt(LocalDateTime.now().plusMinutes(dispatchTimeoutMin));
        dispatchRecordService.save(dispatch);

        // ── 八、更新订单状态为"已派单待确认"，同时写入 cleanerId ──────
        order.setCleanerId(best.cleanerId);
        order.setStatus(OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode());
        this.updateById(order);

        logStatusChange(orderId, OrderStatus.PENDING_DISPATCH.getCode(),
                OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode(), null, "系统自动派单给保洁员" + best.cleanerId);

        // ── 九、通知顾客和保洁员 ──────────────────────────────────────
        notify(order.getCustomerId(), NotificationType.ORDER_DISPATCHED.getCode(),
                "派单成功",
                "已为您的订单 #" + order.getOrderNo() + " 匹配到保洁员，等待保洁员确认接单",
                orderId);
        notify(best.cleanerId, NotificationType.NEW_ORDER_GRAB.getCode(),
                "您有新订单待确认",
                "系统为您派送了一个新订单 #" + order.getOrderNo() + "，请在30分钟内确认接单",
                orderId);

        return best.cleanerId;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void acceptOrder(Long orderId, Long cleanerId) {
        ServiceOrder order = this.getById(orderId);
        if (order == null) throw new BusinessException(ErrorCode.ORDER_NOT_EXIST);
        if (!order.getStatus().equals(OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode()))
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        // 通过派单记录验证该保洁员是否是本次被派单的人（dispatch_record.status=1 待响应）
        boolean hasDispatch = dispatchRecordService.lambdaQuery()
                .eq(DispatchRecord::getOrderId, orderId)
                .eq(DispatchRecord::getCleanerId, cleanerId)
                .eq(DispatchRecord::getStatus, 1)
                .exists();
        if (!hasDispatch) throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);

        // 校验账号状态与审核状态
        User acceptUser = userService.getById(cleanerId);
        if (acceptUser == null || acceptUser.getStatus() != 1)
            throw new BusinessException("账号已被禁用");
        CleanerProfile acceptProfile = cleanerProfileService.lambdaQuery()
                .eq(CleanerProfile::getUserId, cleanerId).one();
        if (acceptProfile == null || acceptProfile.getAuditStatus() != 1)
            throw new BusinessException("账号审核未通过，暂无法接单");

        // 再次校验时段冲突
        int planMin = order.getPlanDuration() != null ? order.getPlanDuration() : 120;
        LocalDateTime lockStart = order.getAppointTime().minusMinutes(30);
        LocalDateTime lockEnd   = order.getAppointTime().plusMinutes(planMin + 30);
        boolean conflict = cleanerTimeLockService.lambdaQuery()
                .eq(CleanerTimeLock::getCleanerId, cleanerId)
                .lt(CleanerTimeLock::getLockStart, lockEnd)
                .gt(CleanerTimeLock::getLockEnd, lockStart)
                .exists();
        if (conflict) throw new BusinessException(ErrorCode.SCHEDULE_CONFLICT);

        // 更新 dispatch_record 为已接单
        dispatchRecordService.lambdaUpdate()
                .eq(DispatchRecord::getOrderId, orderId)
                .eq(DispatchRecord::getCleanerId, cleanerId)
                .eq(DispatchRecord::getStatus, 1)
                .set(DispatchRecord::getStatus, 2)
                .set(DispatchRecord::getRespondAt, LocalDateTime.now())
                .update();

        // 锁定时段
        CleanerTimeLock lock = new CleanerTimeLock();
        lock.setCleanerId(cleanerId);
        lock.setOrderId(orderId);
        lock.setLockStart(lockStart);
        lock.setLockEnd(lockEnd);
        cleanerTimeLockService.save(lock);

        // 确认接单后才写入 cleanerId（派单阶段不写，防止拒单/超时产生脏数据）
        order.setCleanerId(cleanerId);
        order.setStatus(OrderStatus.ACCEPTED.getCode());
        this.updateById(order);

        logStatusChange(orderId, OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode(),
                OrderStatus.ACCEPTED.getCode(), cleanerId, "保洁员确认接单");
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void rejectOrder(Long orderId, Long cleanerId) {
        ServiceOrder order = this.getById(orderId);
        if (order == null) throw new BusinessException(ErrorCode.ORDER_NOT_EXIST);
        if (!order.getStatus().equals(OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode()))
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        // 通过派单记录验证身份，与 acceptOrder 保持一致
        boolean hasDispatch = dispatchRecordService.lambdaQuery()
                .eq(DispatchRecord::getOrderId, orderId)
                .eq(DispatchRecord::getCleanerId, cleanerId)
                .eq(DispatchRecord::getStatus, 1)
                .exists();
        if (!hasDispatch) throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);

        // 标记 dispatch_record 为已拒绝
        dispatchRecordService.lambdaUpdate()
                .eq(DispatchRecord::getOrderId, orderId)
                .eq(DispatchRecord::getCleanerId, cleanerId)
                .eq(DispatchRecord::getStatus, 1)
                .set(DispatchRecord::getStatus, 3)
                .set(DispatchRecord::getRespondAt, LocalDateTime.now())
                .update();

        // 订单退回待派单，显式写 null 清除 cleanerId（updateById 默认忽略 null 字段，必须用 lambdaUpdate）
        this.lambdaUpdate()
                .eq(ServiceOrder::getId, orderId)
                .set(ServiceOrder::getCleanerId, null)
                .set(ServiceOrder::getStatus, OrderStatus.PENDING_DISPATCH.getCode())
                .update();

        logStatusChange(orderId, OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode(),
                OrderStatus.PENDING_DISPATCH.getCode(), cleanerId, "保洁员拒绝接单，退回待派单");
    }

    // ==================== 私有方法 ====================

    private BigDecimal computeActualFee(ServiceType serviceType, Integer durationMin, BigDecimal area) {
        switch (serviceType.getPriceMode()) {
            case 1: {
                BigDecimal hours = BigDecimal.valueOf(durationMin)
                        .divide(BigDecimal.valueOf(60), 2, RoundingMode.CEILING);
                return serviceType.getBasePrice().multiply(hours).setScale(2, RoundingMode.HALF_UP);
            }
            case 2: {
                if (area == null) return serviceType.getBasePrice();
                ServicePriceTier tier = priceTierService.lambdaQuery()
                        .eq(ServicePriceTier::getServiceTypeId, serviceType.getId())
                        .le(ServicePriceTier::getAreaMin, area.intValue())
                        .gt(ServicePriceTier::getAreaMax, area.intValue())
                        .last("LIMIT 1").one();
                BigDecimal unitPrice = tier != null ? tier.getUnitPrice() : serviceType.getBasePrice();
                return unitPrice.multiply(area).setScale(2, RoundingMode.HALF_UP);
            }
            default:
                return serviceType.getBasePrice();
        }
    }

    private BigDecimal calculateFee(ServiceType serviceType, Integer planDuration, BigDecimal houseArea) {
        switch (serviceType.getPriceMode()) {
            case 1: { // 按小时
                int duration = planDuration != null ? planDuration : serviceType.getMinDuration();
                BigDecimal hours = BigDecimal.valueOf(duration)
                        .divide(BigDecimal.valueOf(60), 2, RoundingMode.CEILING);
                return serviceType.getBasePrice().multiply(hours).setScale(2, RoundingMode.HALF_UP);
            }
            case 2: { // 按面积
                if (houseArea == null) {
                    throw new BusinessException("按面积计费需填写房屋面积");
                }
                int area = houseArea.intValue();
                ServicePriceTier tier = priceTierService.lambdaQuery()
                        .eq(ServicePriceTier::getServiceTypeId, serviceType.getId())
                        .le(ServicePriceTier::getAreaMin, area)
                        .gt(ServicePriceTier::getAreaMax, area)
                        .last("LIMIT 1")
                        .one();
                BigDecimal unitPrice = tier != null ? tier.getUnitPrice() : serviceType.getBasePrice();
                return unitPrice.multiply(houseArea).setScale(2, RoundingMode.HALF_UP);
            }
            case 3: // 固定套餐
            default:
                return serviceType.getBasePrice();
        }
    }

    /** 发送站内消息 */
    private void notify(Long userId, Integer type, String title, String content, Long refId) {
        try {
            Notification n = new Notification();
            n.setUserId(userId);
            n.setType(type);
            n.setTitle(title);
            n.setContent(content);
            n.setRefId(refId);
            n.setIsRead(0);
            notificationService.save(n);
        } catch (Exception ignored) {
            // 通知失败不影响主流程
        }
    }

    private OrderVO toVO(ServiceOrder order) {
        OrderVO vo = new OrderVO();
        vo.setId(order.getId());
        vo.setOrderNo(order.getOrderNo());
        vo.setStatus(order.getStatus());
        vo.setStatusDesc(OrderStatus.of(order.getStatus()).getDesc());
        vo.setSource(order.getSource());
        vo.setSourceLabel(switch (order.getSource() != null ? order.getSource() : 1) {
            case 2 -> "外部导入";
            case 3 -> "手动录入";
            default -> "平台自有";
        });
        vo.setServiceTypeId(order.getServiceTypeId());
        vo.setAddressSnapshot(order.getAddressSnapshot());
        vo.setLongitude(order.getLongitude());
        vo.setLatitude(order.getLatitude());
        vo.setAppointTime(order.getAppointTime());
        vo.setPlanDuration(order.getPlanDuration());
        vo.setActualDuration(order.getActualDuration());
        vo.setEstimateFee(order.getEstimateFee());
        vo.setActualFee(order.getActualFee());
        vo.setPayStatus(order.getPayStatus());
        vo.setRemark(order.getRemark());
        vo.setCancelReason(order.getCancelReason());
        vo.setCompletedAt(order.getCompletedAt());
        vo.setAutoConfirmAt(order.getAutoConfirmAt());
        vo.setCreatedAt(order.getCreatedAt());
        vo.setUpdatedAt(order.getUpdatedAt());

        // 顾客昵称
        if (order.getCustomerId() != null) {
            User customer = userService.getById(order.getCustomerId());
            if (customer != null) {
                vo.setCustomerNickname(customer.getNickname());
            }
        }

        // 服务类型名称
        ServiceType st = serviceTypeService.getById(order.getServiceTypeId());
        if (st != null) {
            vo.setServiceTypeName(st.getName());
            vo.setPriceMode(st.getPriceMode());
        }

        // 保洁员信息
        if (order.getCleanerId() != null) {
            User cleaner = userService.getById(order.getCleanerId());
            if (cleaner != null) {
                vo.setCleanerId(cleaner.getId());
                vo.setCleanerName(cleaner.getNickname());
                vo.setCleanerPhone(cleaner.getPhone());
                vo.setCleanerAvatar(cleaner.getAvatarUrl());
            }
            CleanerProfile profile = cleanerProfileService.lambdaQuery()
                    .eq(CleanerProfile::getUserId, order.getCleanerId()).one();
            if (profile != null) {
                vo.setCleanerAvgScore(profile.getAvgScore());
            }
        }

        // 投诉状态（status=7 时填充；结案后订单变为 status=6，也加载以便前端显示退款信息）
        if (order.getStatus() == 7 || order.getStatus() == 6) {
            Complaint complaint = complaintService.lambdaQuery()
                    .eq(Complaint::getOrderId, order.getId()).one();
            if (complaint != null) {
                vo.setComplaintStatus(complaint.getStatus());
                vo.setComplaintResult(complaint.getResult());
            }
        }

        return vo;
    }

    /**
     * 出行提醒：每10分钟扫描一次，找预约时间在 [now+50min, now+70min] 窗口内的已接单订单推送提醒。
     * 窗口宽度20分钟 < 任务间隔10分钟×2，同一订单最多被命中两次，
     * 通过检查 notification 表是否已发过来去重，避免重复推送。
     */
    @Override
    public int sendUpcomingReminders() {
        LocalDateTime now = LocalDateTime.now();
        // 提前1小时提醒，窗口 [now+50min, now+70min]
        LocalDateTime windowStart = now.plusMinutes(50);
        LocalDateTime windowEnd   = now.plusMinutes(70);

        List<ServiceOrder> orders = this.lambdaQuery()
                .eq(ServiceOrder::getStatus, OrderStatus.ACCEPTED.getCode())
                .ge(ServiceOrder::getAppointTime, windowStart)
                .le(ServiceOrder::getAppointTime, windowEnd)
                .list();

        int sent = 0;
        for (ServiceOrder order : orders) {
            if (order.getCleanerId() == null) continue;
            // 去重：该订单本类型通知是否已发过
            boolean alreadySent = notificationService.lambdaQuery()
                    .eq(com.cleanmate.entity.Notification::getUserId, order.getCleanerId())
                    .eq(com.cleanmate.entity.Notification::getType, NotificationType.ORDER_REMINDER.getCode())
                    .eq(com.cleanmate.entity.Notification::getRefId, order.getId())
                    .exists();
            if (alreadySent) continue;

            String content = String.format("您有一个订单将于 %s 开始，请提前出发！地址：%s",
                    order.getAppointTime().toString().replace("T", " ").substring(0, 16),
                    order.getAddressSnapshot());
            notify(order.getCleanerId(),
                    NotificationType.ORDER_REMINDER.getCode(),
                    "出行提醒", content, order.getId());
            sent++;
        }
        return sent;
    }

    @Override
    public List<CandidateVO> getDispatchCandidates(Long orderId) {
        ServiceOrder order = this.getById(orderId);
        if (order == null) throw new BusinessException(ErrorCode.ORDER_NOT_EXIST);

        int planMin = order.getPlanDuration() != null ? order.getPlanDuration() : 120;
        LocalDateTime lockStart = order.getAppointTime().minusMinutes(30);
        LocalDateTime lockEnd   = order.getAppointTime().plusMinutes(planMin + 30);
        boolean orderHasLoc = order.getLatitude() != null && order.getLongitude() != null;
        double orderLat = orderHasLoc ? order.getLatitude().doubleValue()  : 0;
        double orderLon = orderHasLoc ? order.getLongitude().doubleValue() : 0;

        List<CleanerProfile> allCleaners = cleanerProfileService.lambdaQuery()
                .eq(CleanerProfile::getAuditStatus, 1).list();

        List<CandidateEntry> entries = new ArrayList<>();

        for (CleanerProfile cp : allCleaners) {
            // 过滤①：账号状态
            User u = userService.getById(cp.getUserId());
            if (u == null || u.getStatus() != 1) continue;

            // 过滤②：档期可用（模板 + override + 时段锁定）
            if (!scheduleTemplateService.isCleanerAvailable(cp.getUserId(), lockStart, lockEnd)) continue;

            // 过滤②+：已派单待确认订单时段冲突
            boolean pendingConflict = this.lambdaQuery()
                    .eq(ServiceOrder::getCleanerId, cp.getUserId())
                    .eq(ServiceOrder::getStatus, OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode())
                    .list().stream()
                    .anyMatch(p -> {
                        int pp = p.getPlanDuration() != null ? p.getPlanDuration() : 120;
                        LocalDateTime pStart = p.getAppointTime().minusMinutes(30);
                        LocalDateTime pEnd   = p.getAppointTime().plusMinutes(pp + 30);
                        return pStart.isBefore(lockEnd) && pEnd.isAfter(lockStart);
                    });
            if (pendingConflict) continue;

            // 过滤③：距离（>30km排除）
            double homeDistKm = 0;
            if (orderHasLoc && cp.getLatitude() != null && cp.getLongitude() != null) {
                homeDistKm = DistanceUtil.calculateKm(orderLat, orderLon,
                        cp.getLatitude().doubleValue(), cp.getLongitude().doubleValue());
                if (homeDistKm > 30.0) continue;
            }

            // 确定出发距离和时间可行性
            ServiceOrder prevOrder = this.lambdaQuery()
                    .eq(ServiceOrder::getCleanerId, cp.getUserId())
                    .in(ServiceOrder::getStatus, 3, 4, 5)
                    .lt(ServiceOrder::getAppointTime, order.getAppointTime())
                    .orderByDesc(ServiceOrder::getAppointTime)
                    .last("LIMIT 1").one();

            double distKm = homeDistKm;
            boolean timeFeasible = true;
            String prevAddr = null;

            if (prevOrder != null && prevOrder.getLongitude() != null && prevOrder.getLatitude() != null) {
                distKm = DistanceUtil.calculateKm(orderLat, orderLon,
                        prevOrder.getLatitude().doubleValue(), prevOrder.getLongitude().doubleValue());
                prevAddr = prevOrder.getAddressSnapshot();
                int prevPlan = prevOrder.getPlanDuration() != null ? prevOrder.getPlanDuration() : 120;
                long gapMins = Duration.between(
                        prevOrder.getAppointTime().plusMinutes(prevPlan), order.getAppointTime()).toMinutes();
                timeFeasible = gapMins >= distKm / 30.0 * 60 + 30;
            }

            // 综合评分（与 autoDispatch 一致）
            double distScore   = 1000.0 / (distKm + 1) * 0.5;
            double ratingScore = (cp.getAvgScore() != null ? cp.getAvgScore().doubleValue() : 3.0) * 20 * 0.3;
            long recentOrders  = this.lambdaQuery()
                    .eq(ServiceOrder::getCleanerId, cp.getUserId())
                    .in(ServiceOrder::getStatus, 2, 3, 4, 5, 6)
                    .ge(ServiceOrder::getAppointTime, LocalDateTime.now().minusDays(30))
                    .count();
            double balanceScore = 100.0 / Math.log(recentOrders + 2) * 0.2;
            double totalScore   = (distScore + ratingScore + balanceScore) * (timeFeasible ? 1.0 : 0.5);

            // 今日接单数
            long todayCount = this.lambdaQuery()
                    .eq(ServiceOrder::getCleanerId, cp.getUserId())
                    .in(ServiceOrder::getStatus, 2, 3, 4, 5)
                    .ge(ServiceOrder::getAppointTime, LocalDateTime.now().toLocalDate().atStartOfDay())
                    .lt(ServiceOrder::getAppointTime, LocalDateTime.now().toLocalDate().plusDays(1).atStartOfDay())
                    .count();

            // 公司名称
            String companyName = "个人";
            if (cp.getCompanyId() != null) {
                com.cleanmate.entity.CleaningCompany company = cleaningCompanyService.getById(cp.getCompanyId());
                if (company != null) companyName = company.getName();
            }

            CandidateVO vo = new CandidateVO();
            vo.setUserId(cp.getUserId());
            vo.setRealName(cp.getRealName());
            vo.setPhone(u.getPhone());
            vo.setCompanyName(companyName);
            vo.setAvgScore(cp.getAvgScore());
            vo.setDistanceKm(Math.round(distKm * 10.0) / 10.0);
            vo.setTodayOrderCount((int) todayCount);
            vo.setPrevOrderAddress(prevAddr);
            vo.setTimeFeasible(timeFeasible);
            vo.setScheduleStatus(timeFeasible ? "有档期" : "时间紧张");

            entries.add(new CandidateEntry(vo, totalScore));
        }

        return entries.stream()
                .sorted(Comparator.comparingDouble((CandidateEntry e) -> e.score).reversed())
                .map(e -> e.vo)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void manualDispatchByAdmin(Long orderId, Long cleanerId, Long adminId, String remark) {
        // 1. 校验订单（status=1 待派单 或 status=2 已派单待确认均可手动干预）
        ServiceOrder order = this.getById(orderId);
        if (order == null) throw new BusinessException(ErrorCode.ORDER_NOT_EXIST);
        Integer prevStatus = order.getStatus();
        if (!prevStatus.equals(OrderStatus.PENDING_DISPATCH.getCode()) &&
            !prevStatus.equals(OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode())) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }

        // 读取派单超时配置
        SystemConfig manualTimeoutCfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "dispatch_timeout_minutes").one();
        long manualDispatchTimeoutMin = manualTimeoutCfg != null
                ? Long.parseLong(manualTimeoutCfg.getConfigValue()) : 30L;

        // 2. 校验保洁员档期可用
        int planMin = order.getPlanDuration() != null ? order.getPlanDuration() : 120;
        LocalDateTime lockStart = order.getAppointTime().minusMinutes(30);
        LocalDateTime lockEnd   = order.getAppointTime().plusMinutes(planMin + 30);
        if (!scheduleTemplateService.isCleanerAvailable(cleanerId, lockStart, lockEnd)) {
            throw new BusinessException(ErrorCode.CLEANER_NOT_AVAILABLE);
        }

        // 3. 插入 dispatch_record（手动派单，待保洁员响应）
        DispatchRecord dispatch = new DispatchRecord();
        dispatch.setOrderId(orderId);
        dispatch.setCleanerId(cleanerId);
        dispatch.setDispatchType(2); // 管理员手动
        dispatch.setStatus(1);       // 待响应（保洁员需确认）
        dispatch.setExpireAt(LocalDateTime.now().plusMinutes(manualDispatchTimeoutMin));
        dispatch.setOperatorId(adminId);
        dispatchRecordService.save(dispatch);

        // 4. 更新订单：status=2（已派单待确认），赋值 cleanerId（保洁员可在首页看到）
        order.setCleanerId(cleanerId);
        order.setStatus(OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode());
        this.updateById(order);

        // 5. 时段锁在保洁员确认接单时（acceptOrder）写入，此处不写

        // 6. 写状态变更日志
        String logRemark = "管理员手动派单" + (remark != null && !remark.isBlank() ? "：" + remark : "");
        logStatusChange(orderId, prevStatus, OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode(), adminId, logRemark);

        // 7. 通知保洁员确认，通知顾客等待
        notify(cleanerId, NotificationType.NEW_ORDER_GRAB.getCode(),
                "您有新订单待确认",
                "管理员为您分配了新订单 #" + order.getOrderNo() + "，请在30分钟内确认接单",
                orderId);
        notify(order.getCustomerId(), NotificationType.ORDER_DISPATCHED.getCode(),
                "订单已派单",
                "您的订单 #" + order.getOrderNo() + " 已为您匹配保洁员，等待保洁员确认接单",
                orderId);

        // 8. 写操作日志
        com.cleanmate.entity.OperationLog opLog = new com.cleanmate.entity.OperationLog();
        opLog.setOperatorId(adminId);
        opLog.setModule("派单");
        opLog.setAction("手动派单");
        opLog.setRefId(orderId);
        opLog.setAfterData("cleanerId=" + cleanerId + (remark != null ? ", remark=" + remark : ""));
        operationLogService.save(opLog);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> importOrder(ExternalImportDTO dto, int source, Long operatorId) {
        // 1. 模糊匹配服务类型
        ServiceType serviceType = serviceTypeService.lambdaQuery()
                .like(ServiceType::getName, dto.getServiceTypeName())
                .eq(ServiceType::getStatus, 1)
                .last("LIMIT 1").one();
        if (serviceType == null) throw new BusinessException("服务类型不存在");

        // 2. 查找或创建顾客
        User customer = userService.lambdaQuery()
                .eq(User::getPhone, dto.getCustomerPhone()).one();
        if (customer == null) {
            customer = new User();
            customer.setPhone(dto.getCustomerPhone());
            customer.setNickname("外部用户_" + dto.getCustomerPhone().substring(dto.getCustomerPhone().length() - 4));
            customer.setPassword(passwordEncoder.encode("jd_tmp_123456"));
            customer.setRole(1);
            customer.setStatus(1);
            userService.save(customer);
        }

        // 3. 计算预估费用（按小时计价时用 minDuration 兜底）
        Integer planDuration = serviceType.getPriceMode() == 1 ? serviceType.getMinDuration() : null;
        BigDecimal estimateFee = calculateFee(serviceType, planDuration, dto.getHouseArea());

        // 4. 构建 remark（携带来源平台信息）
        String platformPrefix = (dto.getPlatformName() != null && dto.getPlatformOrderNo() != null)
                ? "[" + dto.getPlatformName() + ":" + dto.getPlatformOrderNo() + "] " : "";
        String remark = platformPrefix + (dto.getRemark() != null ? dto.getRemark() : "");

        // 5. 解析预约时间
        LocalDateTime appointTime = LocalDateTime.parse(dto.getAppointTime(),
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        // 6. 生成订单号
        String prefix = source == 2 ? "JD_" : "MANUAL_";
        String orderNo = prefix + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", new Random().nextInt(10000));

        // 7. 保存订单
        ServiceOrder order = new ServiceOrder();
        order.setOrderNo(orderNo);
        order.setSource(source);
        order.setCustomerId(customer.getId());
        order.setServiceTypeId(serviceType.getId());
        order.setAddressSnapshot(dto.getAddressDetail());
        order.setLongitude(dto.getLongitude());
        order.setLatitude(dto.getLatitude());
        order.setHouseArea(dto.getHouseArea());
        order.setPlanDuration(planDuration);
        order.setAppointTime(appointTime);
        order.setRemark(remark);
        order.setStatus(OrderStatus.PENDING_DISPATCH.getCode());
        order.setEstimateFee(estimateFee);
        order.setPayStatus(0);
        this.save(order);

        // 8. 写状态日志
        String logRemark = source == 2 ? "外部平台导入" : "管理员手动录入";
        logStatusChange(order.getId(), null, OrderStatus.PENDING_DISPATCH.getCode(), operatorId, logRemark);

        // 9. 手动录入写操作日志
        if (source == 3 && operatorId != null) {
            OperationLog opLog = new OperationLog();
            opLog.setOperatorId(operatorId);
            opLog.setModule("订单");
            opLog.setAction("手动录入");
            opLog.setRefId(order.getId());
            opLog.setAfterData("orderNo=" + orderNo + ", customer=" + dto.getCustomerPhone());
            operationLogService.save(opLog);
        }

        // 10. 异步触发自动派单
        final Long orderId = order.getId();
        CompletableFuture.runAsync(() -> {
            try { autoDispatch(orderId); } catch (Exception ignored) {}
        });

        Map<String, Object> result = new HashMap<>();
        result.put("systemOrderNo", orderNo);
        result.put("estimateFee", estimateFee);
        result.put("message", "导入成功");
        return result;
    }

    /** 候选人条目（带评分，用于排序） */
    private static class CandidateEntry {
        final CandidateVO vo;
        final double score;
        CandidateEntry(CandidateVO vo, double score) { this.vo = vo; this.score = score; }
    }

    /** autoDispatch 内部用：保存候选保洁员的评分信息 */
    private static class CandidateScore {
        final Long   cleanerId;
        final double distanceKm;  // 实际用于计分的距离（上一单位置 或 常驻位置）
        final double totalScore;

        CandidateScore(Long cleanerId, double distanceKm, double totalScore) {
            this.cleanerId  = cleanerId;
            this.distanceKm = distanceKm;
            this.totalScore = totalScore;
        }
    }
}
