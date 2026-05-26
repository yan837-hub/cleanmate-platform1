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
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.cleanmate.exception.ErrorCode;
import com.cleanmate.utils.DistanceUtil;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;
import org.springframework.security.crypto.password.PasswordEncoder;

@Slf4j
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

    private long getCommuteBufferMin() {
        SystemConfig cfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "commute_buffer_minutes").one();
        return cfg != null ? Long.parseLong(cfg.getConfigValue()) : 30L;
    }

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
            throw new BusinessException("手慢了！该订单已被其他保洁员接单");

        // 乐观锁：原子更新 status=1→3，并发抢单时只有一人成功
        boolean grabbed = this.lambdaUpdate()
                .eq(ServiceOrder::getId, orderId)
                .eq(ServiceOrder::getStatus, OrderStatus.PENDING_DISPATCH.getCode())
                .set(ServiceOrder::getCleanerId, cleanerId)
                .set(ServiceOrder::getStatus, OrderStatus.ACCEPTED.getCode())
                .update();
        if (!grabbed) throw new BusinessException("手慢了！该订单已被其他保洁员接单");
        order = this.getById(orderId);

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
        long bufferMin = getCommuteBufferMin();
        LocalDateTime lockStart = order.getAppointTime().minusMinutes(bufferMin);
        LocalDateTime lockEnd = order.getAppointTime().plusMinutes(planMin + bufferMin);
        ICleanerScheduleTemplateService.AvailabilityResult avail =
                scheduleTemplateService.checkAvailability(cleanerId, lockStart, lockEnd);
        if (avail == ICleanerScheduleTemplateService.AvailabilityResult.TIME_LOCK_CONFLICT) {
            throw new BusinessException("该时段已有订单，存在时间冲突，无法抢单");
        } else if (avail == ICleanerScheduleTemplateService.AvailabilityResult.SCHEDULE_NOT_COVER) {
            String need = order.getAppointTime().toLocalTime().toString().substring(0, 5)
                    + " ~ " + order.getAppointTime().plusMinutes(planMin).toLocalTime().toString().substring(0, 5);
            throw new BusinessException("该订单服务时段为 " + need + "，与您的工作档期不符，可前往档期管理调整后再抢单");
        }

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

        // 签到时间窗口校验：预约时间前15分钟 ~ 预约时间 + 服务时长（清洁结束时刻）
        LocalDateTime appointTime = order.getAppointTime();
        LocalDateTime now = LocalDateTime.now();
        int durationMinutes = order.getPlanDuration() != null ? order.getPlanDuration() : 60;
        if (now.isBefore(appointTime.minusMinutes(15))) {
            throw new BusinessException(ErrorCode.CHECKIN_TOO_EARLY);
        }
        if (now.isAfter(appointTime.plusMinutes(durationMinutes))) {
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
        }

        // 无论是否异常，签到均放行，订单正常推进
        CheckinRecord record = new CheckinRecord();
        record.setOrderId(orderId);
        record.setCleanerId(cleanerId);
        record.setCheckinTime(LocalDateTime.now());
        record.setLongitude(BigDecimal.valueOf(longitude));
        record.setLatitude(BigDecimal.valueOf(latitude));
        record.setDistanceM(distanceM);
        record.setIsAbnormal(isAbnormal);
        checkinRecordService.save(record);

        // 位置异常时通知管理员后置审查（不阻断流程）
        if (isAbnormal == 1) {
            String alertMsg = "订单 #" + order.getOrderNo() + " 保洁员签到位置偏差 " + distanceM + " 米，已放行签到，请前往【异常签到】页面核查。";
            try {
                userService.lambdaQuery().eq(User::getRole, 3).list()
                        .forEach(admin -> notificationService.sendNotification(
                                admin.getId(),
                                NotificationType.ABNORMAL_CHECKIN.getCode(),
                                "保洁员签到位置异常",
                                alertMsg,
                                orderId));
            } catch (Exception ignored) {
            }
        }

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
        SystemConfig autoConfirmCfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "auto_confirm_hours").one();
        long autoConfirmHours = autoConfirmCfg != null ? Long.parseLong(autoConfirmCfg.getConfigValue()) : 48L;
        order.setAutoConfirmAt(LocalDateTime.now().plusHours(autoConfirmHours));
        this.updateById(order);
        logStatusChange(orderId, OrderStatus.IN_SERVICE.getCode(),
                OrderStatus.PENDING_COMPLETE_CONFIRM.getCode(), cleanerId, "保洁员完工上报");

        // 通知顾客：服务已完成，请确认
        notify(order.getCustomerId(), NotificationType.SERVICE_COMPLETED.getCode(),
                "服务已完成",
                "您的订单 #" + order.getOrderNo() + " 保洁员已完工，请在48小时内确认并评价",
                orderId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long autoDispatch(Long orderId, Long operatorId) {
        ServiceOrder order = this.getById(orderId);
        if (order == null) throw new BusinessException(ErrorCode.ORDER_NOT_EXIST);
        if (!order.getStatus().equals(OrderStatus.PENDING_DISPATCH.getCode()) &&
            !order.getStatus().equals(OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode())) {
            throw new BusinessException("订单状态为【" + OrderStatus.of(order.getStatus()).getDesc() + "】，无法派单");
        }
        // 若已派单但保洁员超时未确认，先校验是否真的已超时，再退回待派单重新派
        if (order.getStatus().equals(OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode())) {
            DispatchRecord latestDispatch = dispatchRecordService.lambdaQuery()
                    .eq(DispatchRecord::getOrderId, orderId)
                    .eq(DispatchRecord::getStatus, 1)
                    .orderByDesc(DispatchRecord::getId)
                    .last("LIMIT 1").one();
            if (latestDispatch != null && latestDispatch.getExpireAt().isAfter(LocalDateTime.now())) {
                throw new BusinessException("当前派单仍在响应期内，请等待保洁员确认或超时后再重新派单");
            }
            order.setStatus(OrderStatus.PENDING_DISPATCH.getCode());
            order.setCleanerId(null);
            this.updateById(order);
        }

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
                        LocalDateTime pStart = pending.getAppointTime().minusMinutes(commuteBufferMin);
                        LocalDateTime pEnd   = pending.getAppointTime().plusMinutes(pPlan + commuteBufferMin);
                        return pStart.isBefore(lockEnd) && pEnd.isAfter(lockStart);
                    });
            if (pendingConflict) continue;

            // ── 二、查上一单（过滤③和出发距离共用）──────────────────────
            // 取本单 appointTime 之前最近的已接单/服务中/待确认完成订单
            ServiceOrder prevOrder = this.lambdaQuery()
                    .eq(ServiceOrder::getCleanerId, cp.getUserId())
                    .in(ServiceOrder::getStatus, 3, 4, 5)
                    .lt(ServiceOrder::getAppointTime, order.getAppointTime())
                    .orderByDesc(ServiceOrder::getAppointTime)
                    .last("LIMIT 1").one();

            // 过滤③：距离过滤——常驻位置或上一单位置任一在服务半径内则保留
            double homeDistKm;
            if (orderHasLocation && cp.getLatitude() != null && cp.getLongitude() != null) {
                homeDistKm = DistanceUtil.calculateKm(
                        orderLat, orderLon,
                        cp.getLatitude().doubleValue(), cp.getLongitude().doubleValue());
            } else {
                homeDistKm = 0; // 坐标缺失时不排除，距离得分按最近处理
            }

            if (homeDistKm > maxDistKm) {
                // 常驻超出半径，仅当同一天的上一单在范围内时才保留
                boolean sameDayPrevInRange = prevOrder != null
                        && prevOrder.getAppointTime().toLocalDate().equals(order.getAppointTime().toLocalDate())
                        && prevOrder.getLatitude() != null && prevOrder.getLongitude() != null
                        && orderHasLocation
                        && DistanceUtil.calculateKm(orderLat, orderLon,
                                prevOrder.getLatitude().doubleValue(),
                                prevOrder.getLongitude().doubleValue()) <= maxDistKm;
                if (!sameDayPrevInRange) continue;
            }

            double distKm;
            boolean timeFeasible = true;

            boolean sameDay = prevOrder != null &&
                    prevOrder.getAppointTime().toLocalDate().equals(order.getAppointTime().toLocalDate());
            if (sameDay && prevOrder.getLongitude() != null && prevOrder.getLatitude() != null
                    && orderHasLocation) {
                double prevDistKm = DistanceUtil.calculateKm(
                        orderLat, orderLon,
                        prevOrder.getLatitude().doubleValue(), prevOrder.getLongitude().doubleValue());
                if (prevDistKm <= maxDistKm) {
                    distKm = prevDistKm;
                    int prevPlan          = prevOrder.getPlanDuration() != null ? prevOrder.getPlanDuration() : 120;
                    LocalDateTime prevEnd = prevOrder.getAppointTime().plusMinutes(prevPlan);
                    double commuteMins    = distKm / 30.0 * 60;
                    long gapMins          = Duration.between(prevEnd, order.getAppointTime()).toMinutes();
                    timeFeasible = gapMins >= commuteMins + commuteBufferMin;
                } else {
                    distKm = homeDistKm;
                }
            } else {
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
        dispatch.setDispatchType(operatorId != null ? 2 : 1); // 1=系统自动 2=手动派单
        dispatch.setOperatorId(operatorId);
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

        // 写操作日志（operatorId=0 表示系统自动触发，有管理员操作时记录真实ID）
        OperationLog autoLog = new OperationLog();
        autoLog.setOperatorId(operatorId != null ? operatorId : 0L);
        autoLog.setModule("派单");
        autoLog.setAction("自动派单[订单#" + order.getOrderNo() + "]: 派给保洁员id=" + best.cleanerId
                + ", 评分=" + String.format("%.1f", best.totalScore));
        autoLog.setRefId(orderId);
        autoLog.setAfterData("cleanerId=" + best.cleanerId);
        operationLogService.save(autoLog);

        return best.cleanerId;
    }

    @Override
    public List<CandidateVO> getDispatchCandidates(Long orderId) {
        ServiceOrder order = this.getById(orderId);
        if (order == null) throw new BusinessException(ErrorCode.ORDER_NOT_EXIST);

        SystemConfig maxDistCfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "dispatch_max_distance_km").one();
        double maxDistKm = maxDistCfg != null ? Double.parseDouble(maxDistCfg.getConfigValue()) : 30.0;

        int planMin = order.getPlanDuration() != null ? order.getPlanDuration() : 120;
        long bufferMin = getCommuteBufferMin();
        LocalDateTime lockStart = order.getAppointTime().minusMinutes(bufferMin);
        LocalDateTime lockEnd   = order.getAppointTime().plusMinutes(planMin + bufferMin);
        boolean orderHasLoc = order.getLatitude() != null && order.getLongitude() != null;
        double orderLat = orderHasLoc ? order.getLatitude().doubleValue()  : 0;
        double orderLon = orderHasLoc ? order.getLongitude().doubleValue() : 0;

        List<CleanerProfile> allCleaners = cleanerProfileService.lambdaQuery()
                .eq(CleanerProfile::getAuditStatus, 1).list();

        List<CandidateEntry> withinRange  = new ArrayList<>();
        List<CandidateEntry> outsideRange = new ArrayList<>();

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
                        LocalDateTime pStart = p.getAppointTime().minusMinutes(bufferMin);
                        LocalDateTime pEnd   = p.getAppointTime().plusMinutes(pp + bufferMin);
                        return pStart.isBefore(lockEnd) && pEnd.isAfter(lockStart);
                    });
            if (pendingConflict) continue;

            // 距离计算：>30km 标记为兜底候选，不直接排除（30km内无人时作为备选展示给管理员）
            double homeDistKm = 0;
            if (orderHasLoc && cp.getLatitude() != null && cp.getLongitude() != null) {
                homeDistKm = DistanceUtil.calculateKm(orderLat, orderLon,
                        cp.getLatitude().doubleValue(), cp.getLongitude().doubleValue());
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

            String prevOrderTime = null;
            boolean sameDay = prevOrder != null &&
                    prevOrder.getAppointTime().toLocalDate().equals(order.getAppointTime().toLocalDate());
            if (sameDay && prevOrder.getLongitude() != null && prevOrder.getLatitude() != null) {
                distKm = DistanceUtil.calculateKm(orderLat, orderLon,
                        prevOrder.getLatitude().doubleValue(), prevOrder.getLongitude().doubleValue());
                prevAddr = prevOrder.getAddressSnapshot();
                prevOrderTime = prevOrder.getAppointTime()
                        .format(java.time.format.DateTimeFormatter.ofPattern("MM-dd HH:mm"));
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
            vo.setPrevOrderTime(prevOrderTime);
            vo.setTimeFeasible(timeFeasible);
            vo.setScheduleStatus(timeFeasible ? "有档期" : "时间紧张");
            vo.setTotalScore(Math.round(totalScore * 10.0) / 10.0);

            // 超范围以实际出发距离（distKm）为准：有上一单用上一单距离，无则用常驻距离
            boolean effectiveBeyond = distKm > maxDistKm;
            vo.setDistanceFallback(effectiveBeyond);
            if (effectiveBeyond) {
                outsideRange.add(new CandidateEntry(vo, totalScore));
            } else {
                withinRange.add(new CandidateEntry(vo, totalScore));
            }
        }

        // 30km内有候选时返回正常列表，否则返回所有档期可用的兜底候选
        List<CandidateEntry> result = withinRange.isEmpty() ? outsideRange : withinRange;
        return result.stream()
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
        long bufferMin = getCommuteBufferMin();
        LocalDateTime lockStart = order.getAppointTime().minusMinutes(bufferMin);
        LocalDateTime lockEnd   = order.getAppointTime().plusMinutes(planMin + bufferMin);
        ICleanerScheduleTemplateService.AvailabilityResult avail =
                scheduleTemplateService.checkAvailability(cleanerId, lockStart, lockEnd);
        if (avail == ICleanerScheduleTemplateService.AvailabilityResult.TIME_LOCK_CONFLICT) {
            throw new BusinessException("该保洁员该时段已有订单，存在时间冲突");
        } else if (avail == ICleanerScheduleTemplateService.AvailabilityResult.SCHEDULE_NOT_COVER) {
            String need = order.getAppointTime().toLocalTime().toString().substring(0, 5)
                    + " ~ " + order.getAppointTime().plusMinutes(planMin).toLocalTime().toString().substring(0, 5);
            throw new BusinessException("该保洁员工作档期不覆盖该订单时段（" + need + "），请选择其他保洁员或调整时间");
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

        // 5. 时段锁在保洁员确认接单时写入，此处不写

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
        long bufferMin = getCommuteBufferMin();
        LocalDateTime lockStart = order.getAppointTime().minusMinutes(bufferMin);
        LocalDateTime lockEnd   = order.getAppointTime().plusMinutes(planMin + bufferMin);
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

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int handleDispatchTimeout() {
        List<DispatchRecord> expired = dispatchRecordService.lambdaQuery()
                .eq(DispatchRecord::getStatus, 1)
                .lt(DispatchRecord::getExpireAt, LocalDateTime.now())
                .list();
        if (expired.isEmpty()) return 0;

        int count = 0;
        for (DispatchRecord dr : expired) {
            try {
                // 先标记 dispatch_record 为已超时
                dispatchRecordService.lambdaUpdate()
                        .eq(DispatchRecord::getId, dr.getId())
                        .set(DispatchRecord::getStatus, 4)
                        .set(DispatchRecord::getRespondAt, LocalDateTime.now())
                        .update();

                ServiceOrder order = this.getById(dr.getOrderId());
                if (order == null || !order.getStatus().equals(OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode())) {
                    continue;
                }

                // 订单退回待派单，清除 cleanerId
                this.lambdaUpdate()
                        .eq(ServiceOrder::getId, order.getId())
                        .set(ServiceOrder::getCleanerId, null)
                        .set(ServiceOrder::getStatus, OrderStatus.PENDING_DISPATCH.getCode())
                        .update();

                logStatusChange(order.getId(),
                        OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode(),
                        OrderStatus.PENDING_DISPATCH.getCode(),
                        null,
                        "保洁员 " + dr.getCleanerId() + " 超时未确认（截止 " + dr.getExpireAt() + "），自动退回待派单");
                count++;
            } catch (Exception e) {
                log.error("[定时任务] 处理派单超时记录 {} 失败", dr.getId(), e);
            }
        }
        return count;
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
        BigDecimal basePrice = serviceType.getBasePrice();
        String name = serviceType.getName();
        switch (serviceType.getPriceMode()) {
            case 1: { // 按小时
                if (basePrice == null) throw new BusinessException("服务类型[" + name + "]未配置基础单价");
                int duration = planDuration != null ? planDuration
                        : (serviceType.getMinDuration() != null ? serviceType.getMinDuration() : 60);
                BigDecimal hours = BigDecimal.valueOf(duration)
                        .divide(BigDecimal.valueOf(60), 2, RoundingMode.CEILING);
                return basePrice.multiply(hours).setScale(2, RoundingMode.HALF_UP);
            }
            case 2: { // 按面积
                if (houseArea == null) throw new BusinessException("按面积计费需填写房屋面积");
                int area = houseArea.intValue();
                ServicePriceTier tier = priceTierService.lambdaQuery()
                        .eq(ServicePriceTier::getServiceTypeId, serviceType.getId())
                        .le(ServicePriceTier::getAreaMin, area)
                        .gt(ServicePriceTier::getAreaMax, area)
                        .last("LIMIT 1")
                        .one();
                BigDecimal unitPrice = tier != null ? tier.getUnitPrice() : basePrice;
                if (unitPrice == null) throw new BusinessException("服务类型[" + name + "]未配置单价");
                return unitPrice.multiply(houseArea).setScale(2, RoundingMode.HALF_UP);
            }
            case 3: // 固定套餐
            default:
                return basePrice != null ? basePrice : BigDecimal.ZERO;
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
                    .eq(Complaint::getOrderId, order.getId())
                    .orderByDesc(Complaint::getId)
                    .last("LIMIT 1").one();
            if (complaint != null) {
                vo.setComplaintStatus(complaint.getStatus());
                vo.setComplaintResult(complaint.getResult());
                // 部分退款：退款金额 = estimateFee - actualFee（后端已将 actualFee 设为实付金额）
                if (complaint.getResult() != null && complaint.getResult() == 4
                        && vo.getEstimateFee() != null && vo.getActualFee() != null) {
                    vo.setRefundAmount(vo.getEstimateFee().subtract(vo.getActualFee())
                            .max(java.math.BigDecimal.ZERO)
                            .setScale(2, java.math.RoundingMode.HALF_UP));
                }
            }
        }

        // 定金比例（从 system_config 读取，供前端展示用）
        SystemConfig depositCfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "deposit_rate").one();
        BigDecimal depositRate = depositCfg != null
                ? new BigDecimal(depositCfg.getConfigValue())
                : new BigDecimal("0.30");
        vo.setDepositRate(depositRate);

        // 是否曾发生派单超时退回
        vo.setHadDispatchTimeout(dispatchRecordService.lambdaQuery()
                .eq(DispatchRecord::getOrderId, order.getId())
                .eq(DispatchRecord::getStatus, 4)
                .exists());

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
    @Transactional(rollbackFor = Exception.class)
    public int handleCheckinTimeout() {
        LocalDateTime deadline = LocalDateTime.now().minusHours(2);

        List<ServiceOrder> overdueOrders = this.lambdaQuery()
                .eq(ServiceOrder::getStatus, OrderStatus.ACCEPTED.getCode())
                .le(ServiceOrder::getAppointTime, deadline)
                .list();

        if (overdueOrders.isEmpty()) return 0;

        log.warn("[定时任务] 发现 {} 个超时未签到订单，开始自动取消", overdueOrders.size());

        int count = 0;
        for (ServiceOrder order : overdueOrders) {
            try {
                order.setStatus(OrderStatus.CANCELLED.getCode());
                order.setCancelReason("保洁员超时未签到，系统自动取消");
                this.updateById(order);
                cleanerTimeLockService.lambdaUpdate()
                        .eq(CleanerTimeLock::getOrderId, order.getId()).remove();
                logStatusChange(order.getId(),
                        OrderStatus.ACCEPTED.getCode(),
                        OrderStatus.CANCELLED.getCode(),
                        null,
                        "保洁员超时未签到（预约时间 " + order.getAppointTime() + "），系统自动取消");

                String msg = "订单 #" + order.getOrderNo() + " 已自动取消，原因：保洁员超时未签到。请尽快核查。";
                try {
                    userService.lambdaQuery().eq(User::getRole, 3).list()
                            .forEach(admin -> notificationService.sendNotification(
                                    admin.getId(),
                                    NotificationType.TIMEOUT_ALERT.getCode(),
                                    "保洁员未到场告警",
                                    msg,
                                    order.getId()));
                } catch (Exception ignored) {
                }

                log.info("[定时任务] 订单 {} 已自动取消（超时未签到）", order.getOrderNo());
                count++;
            } catch (Exception e) {
                log.error("[定时任务] 自动取消订单 {} 失败", order.getOrderNo(), e);
            }
        }
        return count;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int autoCancelExpiredUnacceptedOrders() {
        LocalDateTime now = LocalDateTime.now();

        List<ServiceOrder> expired = this.lambdaQuery()
                .in(ServiceOrder::getStatus,
                        OrderStatus.PENDING_DISPATCH.getCode(),
                        OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode())
                .le(ServiceOrder::getAppointTime, now)
                .list();

        if (expired.isEmpty()) return 0;

        log.warn("[定时任务] 发现 {} 个预约时间已过但未接单的订单，自动取消", expired.size());

        int count = 0;
        for (ServiceOrder order : expired) {
            try {
                int oldStatus = order.getStatus();
                order.setStatus(OrderStatus.CANCELLED.getCode());
                order.setCancelReason("预约时间已过，无人接单，系统自动取消退款");
                this.updateById(order);

                if (OrderStatus.DISPATCHED_PENDING_CONFIRM.getCode().equals(oldStatus)) {
                    dispatchRecordService.lambdaUpdate()
                            .eq(DispatchRecord::getOrderId, order.getId())
                            .eq(DispatchRecord::getStatus, 1)
                            .set(DispatchRecord::getStatus, 4)
                            .update();
                }

                logStatusChange(order.getId(), oldStatus,
                        OrderStatus.CANCELLED.getCode(), null,
                        "预约时间 " + order.getAppointTime() + " 已过，无人接单，系统自动取消退款");
                log.info("[定时任务] 订单 {} 已自动取消（预约时间已过无人接单）", order.getOrderNo());
                count++;
            } catch (Exception e) {
                log.error("[定时任务] 自动取消订单 {} 失败", order.getOrderNo(), e);
            }
        }
        return count;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int handleAutoConfirm() {
        List<ServiceOrder> toConfirm = this.lambdaQuery()
                .eq(ServiceOrder::getStatus, OrderStatus.PENDING_COMPLETE_CONFIRM.getCode())
                .isNotNull(ServiceOrder::getAutoConfirmAt)
                .lt(ServiceOrder::getAutoConfirmAt, LocalDateTime.now())
                .list();

        if (toConfirm.isEmpty()) return 0;

        int count = 0;
        for (ServiceOrder order : toConfirm) {
            order.setStatus(OrderStatus.COMPLETED.getCode());
            order.setCompletedAt(LocalDateTime.now());
            order.setPayStatus(2);
            this.updateById(order);
            logStatusChange(order.getId(),
                    OrderStatus.PENDING_COMPLETE_CONFIRM.getCode(),
                    OrderStatus.COMPLETED.getCode(),
                    null, "超过48小时未确认，系统自动确认完成");
            if (order.getCleanerId() != null) {
                cleanerIncomeService.lambdaUpdate()
                        .eq(CleanerIncome::getOrderId, order.getId())
                        .set(CleanerIncome::getStatus, 2)
                        .set(CleanerIncome::getSettledAt, LocalDateTime.now())
                        .update();
                notificationService.sendNotification(
                        order.getCleanerId(),
                        NotificationType.SERVICE_COMPLETED.getCode(),
                        "订单已自动确认",
                        "订单 #" + order.getOrderNo() + " 已超过48小时系统自动确认完成，收入已计入本月结算",
                        order.getId());
            }
            notificationService.sendNotification(
                    order.getCustomerId(),
                    NotificationType.SERVICE_COMPLETED.getCode(),
                    "订单已自动确认",
                    "您的订单 #" + order.getOrderNo() + " 已超过48小时自动确认完成，如有疑问请联系客服",
                    order.getId());
            log.info("[定时任务] 订单 {} 48h自动确认完成", order.getId());
            count++;
        }
        return count;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> importOrder(ExternalImportDTO dto, int source, Long operatorId) {
        // 1. 精确匹配服务类型
        ServiceType serviceType = serviceTypeService.lambdaQuery()
                .eq(ServiceType::getName, dto.getServiceTypeName())
                .eq(ServiceType::getStatus, 1)
                .last("LIMIT 1").one();
        if (serviceType == null) throw new BusinessException("服务类型不存在");

        // 2. 查找顾客；外部平台导入时自动创建顾客账号
        User customer = userService.lambdaQuery()
                .eq(User::getPhone, dto.getCustomerPhone()).one();
        if (customer == null) {
            customer = new User();
            customer.setPhone(dto.getCustomerPhone());
            String phone = dto.getCustomerPhone();
            customer.setNickname(source == 2
                    ? "外部用户_" + phone.substring(phone.length() - 4)
                    : "用户_" + phone.substring(phone.length() - 4));
            customer.setPassword(passwordEncoder.encode("123456"));
            customer.setRole(1);
            customer.setStatus(1);
            userService.save(customer);
        }

        // 3. 计算预估费用；所有计价模式均写入 planDuration 供签到窗口和档期校验使用
        Integer planDuration = serviceType.getMinDuration() != null ? serviceType.getMinDuration() : 120;
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
            try { autoDispatch(orderId, null); } catch (Exception ignored) {}
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
