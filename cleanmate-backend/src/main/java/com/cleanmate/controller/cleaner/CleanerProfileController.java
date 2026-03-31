package com.cleanmate.controller.cleaner;

import com.cleanmate.common.Result;
import com.cleanmate.entity.CleanerProfile;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.exception.ErrorCode;
import com.cleanmate.service.ICleanerProfileService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

/**
 * 保洁员 - 个人资料管理
 */
@RestController
@RequestMapping("/cleaner/profile")
@RequiredArgsConstructor
public class CleanerProfileController {

    private final ICleanerProfileService cleanerProfileService;

    @Value("${upload.path}")
    private String uploadPath;

    @Value("${upload.url-prefix}")
    private String urlPrefix;

    /** 获取当前保洁员资料（不存在时自动补建，兼容历史注册异常数据） */
    @GetMapping("/me")
    public Result<CleanerProfile> getMyProfile(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        CleanerProfile profile = cleanerProfileService.lambdaQuery()
                .eq(CleanerProfile::getUserId, userId).one();
        if (profile == null) {
            profile = new CleanerProfile();
            profile.setUserId(userId);
            profile.setRealName("");
            profile.setIdCard("");
            profile.setAuditStatus(2);
            cleanerProfileService.save(profile);
        }
        return Result.success(profile);
    }

    /**
     * 提交/更新资料
     * - audit_status=3（已拒绝）时重置为 audit_status=2（待审核）
     * - audit_status=1（已通过）时更新其他信息但不重置审核状态
     */
    @PutMapping("/me")
    public Result<Void> updateMyProfile(@RequestBody ProfileUpdateDTO dto, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        CleanerProfile profile = cleanerProfileService.lambdaQuery()
                .eq(CleanerProfile::getUserId, userId).one();
        if (profile == null) throw new BusinessException(ErrorCode.NOT_FOUND);

        if (dto.getRealName()      != null) profile.setRealName(dto.getRealName());
        if (dto.getIdCard()        != null) profile.setIdCard(dto.getIdCard());
        if (dto.getIdCardFront()   != null) profile.setIdCardFront(dto.getIdCardFront());
        if (dto.getIdCardBack()    != null) profile.setIdCardBack(dto.getIdCardBack());
        if (dto.getCertImg()       != null) profile.setCertImg(dto.getCertImg());
        if (dto.getHealthCertImg() != null) profile.setHealthCertImg(dto.getHealthCertImg());
        if (dto.getServiceArea()   != null) profile.setServiceArea(dto.getServiceArea());
        if (dto.getSkillTags()     != null) profile.setSkillTags(dto.getSkillTags());
        if (dto.getBio()           != null) profile.setBio(dto.getBio());
        if (dto.getLongitude()     != null) profile.setLongitude(new BigDecimal(dto.getLongitude().toString()));
        if (dto.getLatitude()      != null) profile.setLatitude(new BigDecimal(dto.getLatitude().toString()));

        // 审核拒绝后重新提交：重置为待审核，清除拒绝备注
        if (Integer.valueOf(3).equals(profile.getAuditStatus())) {
            profile.setAuditStatus(2);
            profile.setAuditRemark(null);
        }

        cleanerProfileService.updateById(profile);
        return Result.success();
    }

    /**
     * 上传证件/资质图片
     * 支持 idCardFront / idCardBack / certImg / healthCertImg 四类
     * 返回可访问的图片 URL
     */
    @PostMapping("/upload")
    public Result<String> uploadImage(@RequestParam("file") MultipartFile file,
                                      Authentication auth) {
        String originalName = file.getOriginalFilename();
        if (originalName == null || !originalName.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif|webp)$")) {
            throw new BusinessException(ErrorCode.FILE_TYPE_NOT_SUPPORT);
        }
        String ext = originalName.substring(originalName.lastIndexOf("."));
        String filename = "profile_" + UUID.randomUUID().toString().replace("-", "") + ext;

        Path dir = Paths.get(uploadPath).toAbsolutePath().normalize();
        try {
            if (!Files.exists(dir)) Files.createDirectories(dir);
            try (InputStream in = file.getInputStream()) {
                Files.copy(in, dir.resolve(filename), StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException e) {
            throw new BusinessException(ErrorCode.FILE_UPLOAD_ERROR);
        }

        return Result.success(urlPrefix + filename);
    }

    @Data
    public static class ProfileUpdateDTO {
        /** 真实姓名 */
        private String realName;
        /** 身份证号 */
        private String idCard;
        /** 身份证正面图片 URL */
        private String idCardFront;
        /** 身份证背面图片 URL */
        private String idCardBack;
        /** 保洁资格证图片 URL */
        private String certImg;
        /** 健康证图片 URL */
        private String healthCertImg;
        /** 服务区域描述 */
        private String serviceArea;
        /** 擅长服务标签，逗号分隔 */
        private String skillTags;
        /** 个人简介 */
        private String bio;
        /** 常驻位置经度 */
        private Double longitude;
        /** 常驻位置纬度 */
        private Double latitude;
    }
}
