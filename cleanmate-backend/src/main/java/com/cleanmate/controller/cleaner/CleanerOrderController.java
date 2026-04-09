package com.cleanmate.controller.cleaner;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cleanmate.common.PageResult;
import com.cleanmate.common.Result;
import com.cleanmate.entity.CleanerTimeLock;
import com.cleanmate.entity.FeeDetail;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.entity.ServicePhoto;
import com.cleanmate.entity.ServiceType;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.exception.ErrorCode;
import com.cleanmate.entity.CleanerProfile;
import com.cleanmate.service.ICleanerProfileService;
import com.cleanmate.service.ICleanerTimeLockService;
import com.cleanmate.service.IDispatchRecordService;
import com.cleanmate.service.IFeeDetailService;
import com.cleanmate.service.IServiceOrderService;
import com.cleanmate.service.IServicePhotoService;
import com.cleanmate.service.IServiceTypeService;
import com.cleanmate.service.IOrderReviewService;
import com.cleanmate.entity.OrderReview;
import com.cleanmate.service.ISystemConfigService;
import com.cleanmate.entity.SystemConfig;
import com.cleanmate.utils.DistanceUtil;
import com.cleanmate.vo.order.OrderVO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 保洁员端 - 订单控制器
 */
@RestController
@RequestMapping("/cleaner/orders")
@RequiredArgsConstructor
public class CleanerOrderController {

    private final IServiceOrderService orderService;
    private final IServicePhotoService servicePhotoService;
    private final ICleanerTimeLockService cleanerTimeLockService;
    private final IFeeDetailService feeDetailService;
    private final IServiceTypeService serviceTypeService;
    private final IDispatchRecordService dispatchRecordService;
    private final ICleanerProfileService cleanerProfileService;
    private final IOrderReviewService orderReviewService;
    private final ISystemConfigService systemConfigService;

    @Value("${upload.path}")
    private String uploadPath;

    @Value("${upload.url-prefix}")
    private String urlPrefix;

    /** 工作台统计 */
    @GetMapping("/stats")
    public Result<java.util.Map<String, Object>> stats(Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        java.time.LocalDate today = java.time.LocalDate.now();
        java.time.LocalDateTime startOfDay = today.atStartOfDay();
        java.time.LocalDateTime endOfDay   = today.atTime(23, 59, 59);
        java.time.LocalDateTime monthStart = today.withDayOfMonth(1).atStartOfDay();

        // 今日订单（预约时间在今天，非取消）
        long todayOrders = orderService.lambdaQuery()
                .eq(ServiceOrder::getCleanerId, cleanerId)
                .ge(ServiceOrder::getAppointTime, startOfDay)
                .le(ServiceOrder::getAppointTime, endOfDay)
                .ne(ServiceOrder::getStatus, 8)
                .count();

        // 待接单（管理员派单待确认，状态=2）
        long pendingDispatch = orderService.lambdaQuery()
                .eq(ServiceOrder::getCleanerId, cleanerId)
                .eq(ServiceOrder::getStatus, 2)
                .count();

        // 本月完成
        long monthlyCompleted = orderService.lambdaQuery()
                .eq(ServiceOrder::getCleanerId, cleanerId)
                .eq(ServiceOrder::getStatus, 6)
                .ge(ServiceOrder::getCompletedAt, monthStart)
                .count();

        // 本月收入
        java.math.BigDecimal monthlyIncome = orderService.lambdaQuery()
                .eq(ServiceOrder::getCleanerId, cleanerId)
                .eq(ServiceOrder::getStatus, 6)
                .ge(ServiceOrder::getCompletedAt, monthStart)
                .list()
                .stream()
                .filter(o -> o.getActualFee() != null)
                .map(ServiceOrder::getActualFee)
                .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add);

        return Result.success(java.util.Map.of(
                "todayOrders",      todayOrders,
                "pendingDispatch",  pendingDispatch,
                "monthlyCompleted", monthlyCompleted,
                "monthlyIncome",    monthlyIncome
        ));
    }

    /**
     * 抢单池列表（status=1 待派单）
     * - 按距离升序排序（需要保洁员已填写位置信息）
     * - 返回字段：距离(km)、预计收入 = estimateFee × (1-commissionRate)
     */
    @GetMapping("/pool")
    public Result<PageResult<OrderVO>> grabPool(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();

        // 获取保洁员位置
        CleanerProfile profile = cleanerProfileService.lambdaQuery()
                .eq(CleanerProfile::getUserId, cleanerId).one();
        final double cleanerLat = (profile != null && profile.getLatitude()  != null) ? profile.getLatitude().doubleValue()  : 0;
        final double cleanerLon = (profile != null && profile.getLongitude() != null) ? profile.getLongitude().doubleValue() : 0;
        final boolean hasLocation = profile != null && profile.getLatitude() != null && profile.getLongitude() != null;

        // 读取佣金比例
        SystemConfig cfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "commission_rate").one();
        java.math.BigDecimal commissionRate = (cfg != null && cfg.getConfigValue() != null)
                ? new java.math.BigDecimal(cfg.getConfigValue())
                : new java.math.BigDecimal("0.20");
        final java.math.BigDecimal cleanerRate = java.math.BigDecimal.ONE.subtract(commissionRate);

        // 查询所有 status=1 的订单（不分页，按距离排序后再截取）
        // 过滤掉当前保洁员自身关联的订单（防御性处理）
        List<ServiceOrder> all = orderService.lambdaQuery()
                .eq(ServiceOrder::getStatus, 1)
                .list()
                .stream()
                .filter(o -> o.getCleanerId() == null || !cleanerId.equals(o.getCleanerId()))
                .collect(java.util.stream.Collectors.toList());

        // 计算距离并排序
        List<OrderVO> vos = all.stream()
                .map(o -> {
                    OrderVO vo = orderService.getOrderVO(o.getId());
                    if (hasLocation && o.getLatitude() != null && o.getLongitude() != null) {
                        double dist = DistanceUtil.calculateKm(
                                cleanerLat, cleanerLon,
                                o.getLatitude().doubleValue(), o.getLongitude().doubleValue());
                        vo.setDistanceKm(Math.round(dist * 10.0) / 10.0);
                    }
                    if (o.getEstimateFee() != null) {
                        vo.setEstimatedIncome(o.getEstimateFee()
                                .multiply(cleanerRate)
                                .setScale(2, java.math.RoundingMode.HALF_UP));
                    }
                    return vo;
                })
                .sorted(java.util.Comparator.comparingDouble(
                        v -> v.getDistanceKm() != null ? v.getDistanceKm() : Double.MAX_VALUE))
                .collect(java.util.stream.Collectors.toList());

        // 手动分页
        long total = vos.size();
        int fromIdx = (int) ((current - 1) * size);
        int toIdx   = (int) Math.min(fromIdx + size, total);
        List<OrderVO> pageData = fromIdx < total ? vos.subList(fromIdx, toIdx) : List.of();

        return Result.success(PageResult.of(pageData, total, current, size));
    }

    /** 抢单（抢单池模式：状态1->3） */
    @PostMapping("/{orderId}/grab")
    public Result<Void> grabOrder(@PathVariable Long orderId, Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        orderService.grabOrder(orderId, cleanerId);
        return Result.success();
    }

    /** 接单（系统/管理员派单模式：状态2->3） */
    @PostMapping("/{orderId}/accept")
    public Result<Void> acceptOrder(@PathVariable Long orderId, Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        orderService.acceptOrder(orderId, cleanerId);
        return Result.success();
    }

    /** 拒单（状态2->1，退回待派单池） */
    @PostMapping("/{orderId}/reject")
    public Result<Void> rejectOrder(@PathVariable Long orderId, Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        orderService.rejectOrder(orderId, cleanerId);
        return Result.success();
    }

    /**
     * 保洁员主动取消已接单（状态3）
     * 规则：距预约时间必须 > 4小时，否则不允许取消
     */
    @PutMapping("/{orderId}/cancel")
    public Result<Void> cancelOrder(@PathVariable Long orderId,
                                    @RequestParam(required = false, defaultValue = "") String reason,
                                    Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null || !cleanerId.equals(order.getCleanerId())) {
            throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        }
        // 仅允许已接单(3)状态取消
        if (order.getStatus() != 3) {
            throw new BusinessException(ErrorCode.ORDER_STATUS_ERROR);
        }
        // 距预约时间须大于配置的保洁员取消截止时间
        SystemConfig cancelCfg = systemConfigService.lambdaQuery()
                .eq(SystemConfig::getConfigKey, "cleaner_cancel_hours").one();
        double cancelDeadlineHours = cancelCfg != null ? Double.parseDouble(cancelCfg.getConfigValue()) : 4.0;
        long minutesLeft = java.time.Duration.between(
                LocalDateTime.now(), order.getAppointTime()).toMinutes();
        if (minutesLeft < cancelDeadlineHours * 60) {
            throw new BusinessException(1003,
                    "距预约时间不足" + cancelDeadlineHours + "小时，无法取消，如需帮助请联系平台");
        }
        // 退回待派单池：显式更新 status/cleanerId/cancelReason 三字段
        // （不用 updateById 避免 MyBatisPlus 跳过 null 字段的问题）
        orderService.lambdaUpdate()
                .eq(ServiceOrder::getId, orderId)
                .set(ServiceOrder::getStatus, com.cleanmate.enums.OrderStatus.PENDING_DISPATCH.getCode())
                .set(ServiceOrder::getCleanerId, null)
                .set(ServiceOrder::getCancelReason, null)
                .update();
        // 释放时段锁
        cleanerTimeLockService.lambdaUpdate()
                .eq(CleanerTimeLock::getOrderId, orderId).remove();
        orderService.logStatusChange(orderId, 3,
                com.cleanmate.enums.OrderStatus.PENDING_DISPATCH.getCode(), cleanerId,
                "保洁员取消，退回派单池" + (reason.isBlank() ? "" : "：" + reason));
        return Result.success();
    }

    /** 我的订单列表 */
    @GetMapping
    public Result<PageResult<OrderVO>> listMyOrders(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Integer status,
            Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        return Result.success(orderService.listCleanerOrders(cleanerId, status, current, size));
    }

    /** 订单详情 */
    @GetMapping("/{orderId}")
    public Result<OrderVO> getOrderDetail(@PathVariable Long orderId, Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        ServiceOrder order = orderService.getById(orderId);
        if (order == null) throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        // 正常归属：order.cleanerId 匹配
        // 免费重做后 cleanerId 被清空，通过 dispatch_record 检查历史接单记录
        boolean owned = cleanerId.equals(order.getCleanerId())
                || dispatchRecordService.lambdaQuery()
                        .eq(com.cleanmate.entity.DispatchRecord::getOrderId, orderId)
                        .eq(com.cleanmate.entity.DispatchRecord::getCleanerId, cleanerId)
                        .exists();
        if (!owned) throw new BusinessException(ErrorCode.ORDER_NOT_BELONG_TO_USER);
        OrderVO vo = orderService.getOrderVO(orderId);
        return Result.success(vo);
    }

    /** 签到打卡 */
    @PostMapping("/{orderId}/checkin")
    public Result<Void> checkin(@PathVariable Long orderId,
                                @RequestParam Double longitude,
                                @RequestParam Double latitude,
                                Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        orderService.checkinOrder(orderId, cleanerId, longitude, latitude);
        return Result.success();
    }

    /** 完工上报（状态4->5） */
    @PutMapping("/{orderId}/complete")
    public Result<Void> reportComplete(@PathVariable Long orderId,
                                       @RequestParam Integer actualDuration,
                                       Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        orderService.reportComplete(orderId, cleanerId, actualDuration);
        return Result.success();
    }

    /** 上传服务照片 */
    @PostMapping("/{orderId}/photos")
    public Result<String> uploadPhoto(@PathVariable Long orderId,
                                      @RequestParam("file") MultipartFile file,
                                      @RequestParam Integer phase,
                                      Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        String originalName = file.getOriginalFilename();
        if (originalName == null || !originalName.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif|webp)$")) {
            throw new BusinessException(ErrorCode.FILE_TYPE_NOT_SUPPORT);
        }
        String ext = originalName.substring(originalName.lastIndexOf("."));
        String filename = UUID.randomUUID().toString().replace("-", "") + ext;

        Path dir = Paths.get(uploadPath).toAbsolutePath().normalize();
        try {
            if (!Files.exists(dir)) Files.createDirectories(dir);
            try (InputStream in = file.getInputStream()) {
                Files.copy(in, dir.resolve(filename), StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException e) {
            throw new BusinessException(ErrorCode.FILE_UPLOAD_ERROR);
        }

        String imgUrl = urlPrefix + filename;

        ServicePhoto photo = new ServicePhoto();
        photo.setOrderId(orderId);
        photo.setCleanerId(cleanerId);
        photo.setPhase(phase);
        photo.setImgUrl(imgUrl);
        photo.setTakenAt(LocalDateTime.now());
        servicePhotoService.save(photo);

        return Result.success(imgUrl);
    }

    /** 我的评价列表（顾客对我的评价，按时间倒序分页） */
    @GetMapping("/reviews")
    public Result<com.cleanmate.common.PageResult<OrderReview>> getMyReviews(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        com.baomidou.mybatisplus.extension.plugins.pagination.Page<OrderReview> page =
                orderReviewService.lambdaQuery()
                        .eq(OrderReview::getCleanerId, cleanerId)
                        .eq(OrderReview::getIsVisible, 1)
                        .orderByDesc(OrderReview::getCreatedAt)
                        .page(new com.baomidou.mybatisplus.extension.plugins.pagination.Page<>(current, size));
        return Result.success(com.cleanmate.common.PageResult.of(
                page.getRecords(), page.getTotal(), page.getCurrent(), page.getSize()));
    }

    /** 获取订单照片列表 */
    @GetMapping("/{orderId}/photos")
    public Result<List<ServicePhoto>> getPhotos(@PathVariable Long orderId, Authentication auth) {
        List<ServicePhoto> photos = servicePhotoService.lambdaQuery()
                .eq(ServicePhoto::getOrderId, orderId)
                .orderByAsc(ServicePhoto::getPhase)
                .orderByAsc(ServicePhoto::getTakenAt)
                .list();
        return Result.success(photos);
    }

    /**
     * 收入明细：按月查询已完成订单的收入记录
     */
    @GetMapping("/income")
    public Result<java.util.Map<String, Object>> getIncome(
            @RequestParam(required = false) String month,
            Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();

        // 默认当月
        String targetMonth = (month != null && !month.isBlank())
                ? month
                : java.time.LocalDate.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM"));
        java.time.LocalDate monthDate = java.time.LocalDate.parse(targetMonth + "-01");
        LocalDateTime start = monthDate.atStartOfDay();
        LocalDateTime end   = monthDate.plusMonths(1).atStartOfDay();

        // 查本月已完成的订单
        List<ServiceOrder> orders = orderService.lambdaQuery()
                .eq(ServiceOrder::getCleanerId, cleanerId)
                .eq(ServiceOrder::getStatus, 6)
                .ge(ServiceOrder::getCompletedAt, start)
                .lt(ServiceOrder::getCompletedAt, end)
                .orderByDesc(ServiceOrder::getCompletedAt)
                .list();

        java.math.BigDecimal totalIncome      = java.math.BigDecimal.ZERO;
        java.math.BigDecimal totalCommission  = java.math.BigDecimal.ZERO;

        List<IncomeItemVO> items = new java.util.ArrayList<>();
        for (ServiceOrder order : orders) {
            IncomeItemVO item = new IncomeItemVO();
            item.setOrderId(order.getId());
            item.setOrderNo(order.getOrderNo());
            item.setCompletedAt(order.getCompletedAt());
            item.setEstimateFee(order.getEstimateFee());
            item.setActualFee(order.getActualFee());
            // 实际金额 < 预估金额则视为发生过退款
            if (order.getActualFee() != null && order.getEstimateFee() != null
                    && order.getActualFee().compareTo(order.getEstimateFee()) < 0) {
                item.setRefundOccurred(true);
            }

            ServiceType st = serviceTypeService.getById(order.getServiceTypeId());
            if (st != null) item.setServiceTypeName(st.getName());

            FeeDetail fee = feeDetailService.lambdaQuery()
                    .eq(FeeDetail::getOrderId, order.getId())
                    .one();
            if (fee != null) {
                item.setCleanerIncome(fee.getCleanerIncome());
                item.setCommissionFee(fee.getCommissionFee());
                item.setCommissionRate(fee.getCommissionRate());
                if (fee.getCleanerIncome() != null)
                    totalIncome = totalIncome.add(fee.getCleanerIncome());
                if (fee.getCommissionFee() != null)
                    totalCommission = totalCommission.add(fee.getCommissionFee());
            } else if (order.getActualFee() != null) {
                // fallback：无 fee_detail 记录时按 80% 估算
                java.math.BigDecimal income = order.getActualFee()
                        .multiply(new java.math.BigDecimal("0.80"))
                        .setScale(2, java.math.RoundingMode.HALF_UP);
                item.setCleanerIncome(income);
                item.setCommissionFee(order.getActualFee().subtract(income));
                item.setCommissionRate(new java.math.BigDecimal("0.20"));
                totalIncome     = totalIncome.add(income);
                totalCommission = totalCommission.add(order.getActualFee().subtract(income));
            }
            items.add(item);
        }

        return Result.success(java.util.Map.of(
                "month",           targetMonth,
                "orderCount",      items.size(),
                "totalIncome",     totalIncome,
                "totalCommission", totalCommission,
                "items",           items
        ));
    }

    /**
     * 档期查询：返回指定日期范围内的时段锁定列表（含关联订单信息）
     * 前端传 startDate/endDate（yyyy-MM-dd），默认查当月
     */
    @GetMapping("/schedule")
    public Result<List<ScheduleItemVO>> getSchedule(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();

        LocalDate start = startDate != null ? startDate : LocalDate.now().withDayOfMonth(1);
        LocalDate end   = endDate   != null ? endDate   : start.plusMonths(1).minusDays(1);

        List<CleanerTimeLock> locks = cleanerTimeLockService.lambdaQuery()
                .eq(CleanerTimeLock::getCleanerId, cleanerId)
                .ge(CleanerTimeLock::getLockStart, start.atStartOfDay())
                .le(CleanerTimeLock::getLockEnd,   end.atTime(23, 59, 59))
                .orderByAsc(CleanerTimeLock::getLockStart)
                .list();

        List<ScheduleItemVO> result = locks.stream()
                .map(lock -> {
                    ScheduleItemVO item = new ScheduleItemVO();
                    item.setLockId(lock.getId());
                    item.setOrderId(lock.getOrderId());
                    item.setLockStart(lock.getLockStart());
                    item.setLockEnd(lock.getLockEnd());
                    ServiceOrder order = orderService.getById(lock.getOrderId());
                    if (order != null) {
                        item.setOrderNo(order.getOrderNo());
                        item.setStatus(order.getStatus());
                        item.setAddressSnapshot(order.getAddressSnapshot());
                        item.setAppointTime(order.getAppointTime());
                    }
                    return item;
                })
                // 已取消(8)和售后(7)的订单不占档期
                .filter(item -> item.getStatus() != null && item.getStatus() != 7 && item.getStatus() != 8)
                .toList();

        return Result.success(result);
    }

    /** 收入条目 VO */
    @lombok.Data
    public static class IncomeItemVO {
        private Long orderId;
        private String orderNo;
        private String serviceTypeName;
        private LocalDateTime completedAt;
        private java.math.BigDecimal estimateFee;
        private java.math.BigDecimal actualFee;
        private java.math.BigDecimal cleanerIncome;
        private java.math.BigDecimal commissionFee;
        private java.math.BigDecimal commissionRate;
        /** 是否发生过退款（实际金额 < 预估金额） */
        private boolean refundOccurred;
    }

    /** 档期条目 VO（内部类，避免创建额外文件） */
    @lombok.Data
    public static class ScheduleItemVO {
        private Long lockId;
        private Long orderId;
        private String orderNo;
        private Integer status;
        private String addressSnapshot;
        private LocalDateTime appointTime;
        private LocalDateTime lockStart;
        private LocalDateTime lockEnd;
    }

    @Value("${amap.key}")
    private String amapKey;

    /**
     * 相邻订单路线提示
     * 查找本单预约时间之前、同一保洁员最近一笔进行中订单，
     * 若两单时间间隔 ≤ 120 分钟则认为相邻，返回距离/预计行程/静态地图URL。
     */
    @GetMapping("/{id}/route-hint")
    public Result<java.util.Map<String, Object>> routeHint(@PathVariable Long id,
                                                           Authentication auth) {
        Long cleanerId = (Long) auth.getPrincipal();
        ServiceOrder current = orderService.getById(id);
        if (current == null) throw new BusinessException(ErrorCode.ORDER_NOT_EXIST);

        java.util.Map<String, Object> empty = new java.util.HashMap<>();
        empty.put("hasPrevOrder", false);

        // 经纬度缺失则无法计算
        if (current.getLongitude() == null || current.getLatitude() == null) {
            return Result.success(empty);
        }

        // 查找本单预约时间之前、状态在(3,4,5)中的最近一笔订单
        ServiceOrder prev = orderService.lambdaQuery()
                .eq(ServiceOrder::getCleanerId, cleanerId)
                .in(ServiceOrder::getStatus, 3, 4, 5)
                .lt(ServiceOrder::getAppointTime, current.getAppointTime())
                .ne(ServiceOrder::getId, id)
                .orderByDesc(ServiceOrder::getAppointTime)
                .last("LIMIT 1")
                .one();

        if (prev == null || prev.getLongitude() == null || prev.getLatitude() == null) {
            return Result.success(empty);
        }

        // 判断时间间隔：本单开始 - 上一单结束(appointTime + planDuration)
        int prevDuration = prev.getPlanDuration() != null ? prev.getPlanDuration() : 120;
        LocalDateTime prevEnd = prev.getAppointTime().plusMinutes(prevDuration);
        long gapMinutes = java.time.Duration.between(prevEnd, current.getAppointTime()).toMinutes();

        if (gapMinutes < 0 || gapMinutes > 120) {
            return Result.success(empty);
        }

        double prevLng = prev.getLongitude().doubleValue();
        double prevLat = prev.getLatitude().doubleValue();
        double curLng  = current.getLongitude().doubleValue();
        double curLat  = current.getLatitude().doubleValue();

        double distanceKm      = DistanceUtil.calculateKm(prevLat, prevLng, curLat, curLng);
        int    estimatedMinutes = (int) (distanceKm / 30.0 * 60);

        String mapUrl = "https://uri.amap.com/navigation?from="
                + prevLng + "," + prevLat
                + "&to=" + curLng + "," + curLat
                + "&mode=driving&callnative=0";

        // 调高德驾车路径规划 API 拿真实路线坐标串，失败则降级为无路线
        String polyline = fetchDrivingPolyline(prevLng, prevLat, curLng, curLat);
        String pathsParam = (polyline != null && !polyline.isEmpty())
                ? "&paths=4,0x3366FF,1,,:" + polyline
                : "";

        String staticMapUrl = "https://restapi.amap.com/v3/staticmap"
                + "?markers=mid,0xFF0000,A:" + prevLng + "," + prevLat
                + "|mid,0x0000FF,B:" + curLng + "," + curLat
                + pathsParam
                + "&size=600*280"
                + "&key=" + amapKey;

        java.util.Map<String, Object> result = new java.util.HashMap<>();
        result.put("hasPrevOrder",      true);
        result.put("prevOrderId",       prev.getId());
        result.put("prevOrderAddress",  prev.getAddressSnapshot());
        result.put("prevLng",           prevLng);
        result.put("prevLat",           prevLat);
        result.put("currentAddress",    current.getAddressSnapshot());
        result.put("currentLng",        curLng);
        result.put("currentLat",        curLat);
        result.put("distanceKm",        distanceKm);
        result.put("estimatedMinutes",  estimatedMinutes);
        result.put("mapUrl",            mapUrl);
        result.put("staticMapUrl",      staticMapUrl);
        return Result.success(result);
    }

    /**
     * 调高德驾车路径规划 API，返回路线坐标串（lng,lat;lng,lat;...）
     * 失败时返回 null，由调用方降级处理。
     */
    private String fetchDrivingPolyline(double oLng, double oLat, double dLng, double dLat) {
        try {
            String url = "https://restapi.amap.com/v3/direction/driving"
                    + "?origin=" + oLng + "," + oLat
                    + "&destination=" + dLng + "," + dLat
                    + "&output=json&key=" + amapKey;

            java.net.http.HttpClient client = java.net.http.HttpClient.newHttpClient();
            java.net.http.HttpRequest req = java.net.http.HttpRequest.newBuilder()
                    .uri(java.net.URI.create(url)).GET().build();
            java.net.http.HttpResponse<String> resp =
                    client.send(req, java.net.http.HttpResponse.BodyHandlers.ofString());

            com.fasterxml.jackson.databind.ObjectMapper mapper =
                    new com.fasterxml.jackson.databind.ObjectMapper();
            com.fasterxml.jackson.databind.JsonNode root = mapper.readTree(resp.body());
            com.fasterxml.jackson.databind.JsonNode steps =
                    root.path("route").path("paths").get(0).path("steps");

            StringBuilder sb = new StringBuilder();
            for (com.fasterxml.jackson.databind.JsonNode step : steps) {
                String seg = step.path("polyline").asText();
                if (!seg.isEmpty()) {
                    if (sb.length() > 0) sb.append(";");
                    sb.append(seg);
                }
            }
            return sb.toString();
        } catch (Exception e) {
            return null;
        }
    }
}
