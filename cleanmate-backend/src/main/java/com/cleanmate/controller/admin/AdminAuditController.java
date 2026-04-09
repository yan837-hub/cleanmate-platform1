package com.cleanmate.controller.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cleanmate.common.PageResult;
import com.cleanmate.common.Result;
import com.cleanmate.entity.CleanerProfile;
import com.cleanmate.entity.CleaningCompany;
import com.cleanmate.entity.Notification;
import com.cleanmate.entity.User;
import com.cleanmate.enums.NotificationType;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.exception.ErrorCode;
import com.cleanmate.entity.OperationLog;
import com.cleanmate.service.ICleanerProfileService;
import com.cleanmate.service.ICleaningCompanyService;
import com.cleanmate.service.INotificationService;
import com.cleanmate.service.IOperationLogService;
import com.cleanmate.service.IUserService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 管理员 - 资质审核 + 公司管理控制器
 */
@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminAuditController {

    private final ICleanerProfileService cleanerProfileService;
    private final ICleaningCompanyService companyService;
    private final IUserService userService;
    private final INotificationService notificationService;
    private final IOperationLogService operationLogService;

    // ============================================================
    // 保洁员管理
    // ============================================================

    /** 保洁员列表（分页，支持 auditStatus / keyword 筛选） */
    @GetMapping("/audit/cleaners")
    public Result<PageResult<CleanerProfile>> listCleaners(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Integer auditStatus,
            @RequestParam(required = false) String keyword) {

        var query = cleanerProfileService.lambdaQuery();
        if (auditStatus != null) {
            query.eq(CleanerProfile::getAuditStatus, auditStatus);
        }
        if (keyword != null && !keyword.isBlank()) {
            // 按姓名模糊搜索（手机号需要 join user 表，这里只做姓名）
            query.like(CleanerProfile::getRealName, keyword.trim());
        }
        query.orderByDesc(CleanerProfile::getCreatedAt);

        Page<CleanerProfile> page = query.page(new Page<>(current, size));

        // 批量填充 userStatus、phone、companyName
        List<Long> companyIds = page.getRecords().stream()
                .map(CleanerProfile::getCompanyId)
                .filter(id -> id != null)
                .distinct()
                .collect(Collectors.toList());
        Map<Long, CleaningCompany> companyMap = companyIds.isEmpty() ? Map.of()
                : companyService.listByIds(companyIds).stream()
                        .collect(Collectors.toMap(CleaningCompany::getId, c -> c));

        page.getRecords().forEach(cp -> {
            User u = userService.getById(cp.getUserId());
            if (u != null) {
                cp.setUserStatus(u.getStatus());
                cp.setPhone(u.getPhone());
            }
            if (cp.getCompanyId() != null) {
                CleaningCompany company = companyMap.get(cp.getCompanyId());
                cp.setCompanyName(company != null ? company.getName() : "未知公司");
                cp.setCompanyStatus(company != null ? company.getStatus() : null);
            } else {
                cp.setCompanyName("个人");
                cp.setCompanyStatus(null);
            }
        });

        return Result.success(PageResult.of(
                page.getRecords(), page.getTotal(), page.getCurrent(), page.getSize()));
    }

    /** 审核保洁员（1=通过 3=拒绝） */
    @PutMapping("/audit/cleaners/{id}")
    public Result<Void> auditCleaner(@PathVariable Long id,
                                     @RequestParam Integer auditStatus,
                                     @RequestParam(required = false) String remark,
                                     Authentication auth) {
        if (auditStatus != 1 && auditStatus != 3) {
            throw new BusinessException(ErrorCode.PARAM_ERROR);
        }
        CleanerProfile profile = cleanerProfileService.getById(id);
        if (profile == null) throw new BusinessException(ErrorCode.NOT_FOUND);
        if (profile.getAuditStatus() != 2) throw new BusinessException(ErrorCode.AUDIT_NOT_PENDING);

        Long adminId = (Long) auth.getPrincipal();
        profile.setAuditStatus(auditStatus);
        profile.setAuditRemark(remark);
        profile.setAuditedBy(adminId);
        profile.setAuditedAt(LocalDateTime.now());
        cleanerProfileService.updateById(profile);

        OperationLog opLog = new OperationLog();
        opLog.setOperatorId(adminId);
        opLog.setModule("审核");
        opLog.setAction("保洁员审核[id=" + id + "]: " + (auditStatus == 1 ? "通过" : "拒绝")
                + (remark != null && !remark.isBlank() ? "，备注：" + remark : ""));
        opLog.setRefId(id);
        operationLogService.save(opLog);

        String title = auditStatus == 1 ? "审核通过" : "审核未通过";
        String content = auditStatus == 1
                ? "恭喜您！您的保洁员资质审核已通过，现在可以开始接单了"
                : "您的保洁员资质审核未通过" + (remark != null && !remark.isBlank() ? "，原因：" + remark : "") + "，请修改后重新提交";
        sendNotification(profile.getUserId(), NotificationType.AUDIT_RESULT.getCode(), title, content);

        return Result.success();
    }

    /** 启用/禁用保洁员账号（修改 user.status） */
    @PutMapping("/audit/cleaners/{userId}/status")
    public Result<Void> toggleCleanerStatus(@PathVariable Long userId,
                                            @RequestParam Integer status,
                                            Authentication auth) {
        User user = userService.getById(userId);
        if (user == null) throw new BusinessException(ErrorCode.USER_NOT_EXIST);
        int oldStatus = user.getStatus();
        user.setStatus(status);
        userService.updateById(user);

        Long adminId = (Long) auth.getPrincipal();
        OperationLog opLog = new OperationLog();
        opLog.setOperatorId(adminId);
        opLog.setModule("封禁");
        opLog.setAction("保洁员账号状态变更[userId=" + userId + "]: " + oldStatus + "→" + status
                + (status == 3 ? "（停用）" : "（启用）"));
        opLog.setRefId(userId);
        operationLogService.save(opLog);

        return Result.success();
    }

    // ============================================================
    // 公司管理
    // ============================================================

    /** 公司列表（分页，支持 status 筛选和 keyword 搜索） */
    @GetMapping("/audit/companies")
    public Result<PageResult<CleaningCompany>> listCompanies(
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String keyword) {

        var query = companyService.lambdaQuery();
        if (status != null) {
            query.eq(CleaningCompany::getStatus, status);
        }
        if (keyword != null && !keyword.isBlank()) {
            query.like(CleaningCompany::getName, keyword.trim());
        }
        query.orderByDesc(CleaningCompany::getCreatedAt);

        Page<CleaningCompany> page = query.page(new Page<>(current, size));

        // 填充每家公司的保洁员数量（audit_status=1 通过的）
        page.getRecords().forEach(company -> {
            long count = cleanerProfileService.lambdaQuery()
                    .eq(CleanerProfile::getCompanyId, company.getId())
                    .eq(CleanerProfile::getAuditStatus, 1)
                    .count();
            company.setCleanerCount((int) count);
        });

        return Result.success(PageResult.of(
                page.getRecords(), page.getTotal(), page.getCurrent(), page.getSize()));
    }

    /** 新增公司（管理员直接创建，status=1 正常，无需审核） */
    @PostMapping("/companies")
    public Result<Void> createCompany(@RequestBody CompanyDTO dto, Authentication auth) {
        CleaningCompany company = new CleaningCompany();
        company.setName(dto.getName());
        company.setLicenseNo(dto.getLicenseNo());
        company.setLicenseImg(dto.getLicenseImg());
        company.setContactName(dto.getContactName());
        company.setContactPhone(dto.getContactPhone());
        company.setAddress(dto.getAddress());
        company.setAuditRemark(dto.getRemark());
        company.setStatus(1); // 管理员直接创建，默认正常状态
        companyService.save(company);
        return Result.success();
    }

    /** 编辑公司基本信息 */
    @PutMapping("/companies/{id}")
    public Result<Void> updateCompany(@PathVariable Long id,
                                      @RequestBody CompanyDTO dto) {
        CleaningCompany company = companyService.getById(id);
        if (company == null) throw new BusinessException(ErrorCode.NOT_FOUND);
        if (dto.getName()        != null) company.setName(dto.getName());
        if (dto.getLicenseNo()   != null) company.setLicenseNo(dto.getLicenseNo());
        if (dto.getLicenseImg()  != null) company.setLicenseImg(dto.getLicenseImg());
        if (dto.getContactName() != null) company.setContactName(dto.getContactName());
        if (dto.getContactPhone()!= null) company.setContactPhone(dto.getContactPhone());
        if (dto.getAddress()     != null) company.setAddress(dto.getAddress());
        if (dto.getRemark()      != null) company.setAuditRemark(dto.getRemark());
        companyService.updateById(company);
        return Result.success();
    }

    /** 启用/停用公司（status: 1=正常 3=停用） */
    @PutMapping("/audit/companies/{id}")
    public Result<Void> toggleCompanyStatus(@PathVariable Long id,
                                            @RequestParam Integer status,
                                            @RequestParam(required = false) String remark,
                                            Authentication auth) {
        CleaningCompany company = companyService.getById(id);
        if (company == null) throw new BusinessException(ErrorCode.NOT_FOUND);
        int oldStatus = company.getStatus() != null ? company.getStatus() : 1;
        company.setStatus(status);
        if (remark != null) company.setAuditRemark(remark);
        companyService.updateById(company);

        // 停用公司时：同步禁用该公司下所有正常状态的保洁员账号
        if (status == 3) {
            List<CleanerProfile> profiles = cleanerProfileService.lambdaQuery()
                    .eq(CleanerProfile::getCompanyId, id)
                    .list();
            profiles.forEach(cp -> {
                User u = userService.getById(cp.getUserId());
                if (u != null && u.getStatus() == 1) {
                    u.setStatus(3);
                    userService.updateById(u);
                }
            });
        }

        Long adminId = (Long) auth.getPrincipal();
        OperationLog opLog = new OperationLog();
        opLog.setOperatorId(adminId);
        opLog.setModule("封禁");
        opLog.setAction("保洁公司状态变更[id=" + id + ", " + company.getName() + "]: " + oldStatus + "→" + status
                + (status == 3 ? "（停用）" : "（启用）")
                + (remark != null && !remark.isBlank() ? "，备注：" + remark : ""));
        opLog.setRefId(id);
        operationLogService.save(opLog);

        return Result.success();
    }

    // ============================================================
    // 工具方法
    // ============================================================

    private void sendNotification(Long userId, Integer type, String title, String content) {
        try {
            Notification n = new Notification();
            n.setUserId(userId);
            n.setType(type);
            n.setTitle(title);
            n.setContent(content);
            n.setIsRead(0);
            notificationService.save(n);
        } catch (Exception ignored) {}
    }

    @Data
    public static class CompanyDTO {
        private String name;
        private String licenseNo;
        private String licenseImg;
        private String contactName;
        private String contactPhone;
        private String address;
        /** 管理员备注（复用 audit_remark 字段） */
        private String remark;
    }
}
