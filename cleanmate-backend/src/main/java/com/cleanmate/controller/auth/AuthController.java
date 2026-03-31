package com.cleanmate.controller.auth;

import com.cleanmate.common.Result;
import com.cleanmate.dto.auth.LoginDTO;
import com.cleanmate.dto.auth.RegisterDTO;
import com.cleanmate.entity.CleanerProfile;
import com.cleanmate.entity.User;
import com.cleanmate.enums.UserRole;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.exception.ErrorCode;
import com.cleanmate.entity.CleaningCompany;
import com.cleanmate.service.ICleanerProfileService;
import com.cleanmate.service.ICleaningCompanyService;
import com.cleanmate.service.IUserService;
import com.cleanmate.utils.JwtUtil;
import com.cleanmate.vo.auth.LoginVO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 认证控制器：注册 / 登录
 */
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final IUserService userService;
    private final ICleanerProfileService cleanerProfileService;
    private final ICleaningCompanyService companyService;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;

    /**
     * 注册（顾客 / 保洁员）
     */
    @Transactional
    @PostMapping("/register")
    public Result<Void> register(@Valid @RequestBody RegisterDTO dto) {
        // 检查手机号是否已注册
        long count = userService.lambdaQuery()
                .eq(User::getPhone, dto.getPhone())
                .count();
        if (count > 0) {
            throw new BusinessException(ErrorCode.USER_ALREADY_EXIST);
        }

        User user = new User();
        user.setPhone(dto.getPhone());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        // 保洁员用真实姓名作为昵称；顾客用昵称，未填则用手机号
        if (UserRole.CLEANER.getCode().equals(dto.getRole()) && dto.getRealName() != null && !dto.getRealName().isBlank()) {
            user.setNickname(dto.getRealName());
        } else {
            user.setNickname(dto.getNickname() != null ? dto.getNickname() : dto.getPhone());
        }
        user.setRole(dto.getRole());
        // 所有用户注册后 status=1 可正常登录；保洁员通过 audit_status 控制接单资格
        user.setStatus(1);
        userService.save(user);

        // 保洁员注册：自动创建档案，audit_status=2（待审核）
        if (dto.getRole().equals(UserRole.CLEANER.getCode())) {
            // 若传入 companyId，校验公司存在且状态为正常
            if (dto.getCompanyId() != null) {
                CleaningCompany company = companyService.getById(dto.getCompanyId());
                if (company == null || company.getStatus() != 1) {
                    throw new BusinessException(400, "所选公司不存在或已停用");
                }
            }
            CleanerProfile profile = new CleanerProfile();
            profile.setUserId(user.getId());
            // 注册时预填真实姓名，减少后续补填步骤
            profile.setRealName(dto.getRealName() != null ? dto.getRealName() : "");
            profile.setIdCard("");
            profile.setAuditStatus(2);
            profile.setCompanyId(dto.getCompanyId());
            cleanerProfileService.save(profile);
        }

        return Result.success("注册成功", null);
    }

    /**
     * 登录
     */
    @PostMapping("/login")
    public Result<LoginVO> login(@Valid @RequestBody LoginDTO dto) {
        User user = userService.lambdaQuery()
                .eq(User::getPhone, dto.getPhone())
                .one();

        if (user == null) {
            throw new BusinessException(ErrorCode.USER_NOT_EXIST);
        }
        if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new BusinessException(ErrorCode.PASSWORD_ERROR);
        }
        if (user.getStatus() == 3 || user.getStatus() == 4) {
            // 保洁员：检查是否因所属公司停用而被禁用
            if (UserRole.CLEANER.getCode().equals(user.getRole())) {
                CleanerProfile profile = cleanerProfileService.lambdaQuery()
                        .eq(CleanerProfile::getUserId, user.getId()).one();
                if (profile != null && profile.getCompanyId() != null) {
                    CleaningCompany company = companyService.getById(profile.getCompanyId());
                    if (company != null && company.getStatus() == 3) {
                        throw new BusinessException(400,
                                "您的账号因所属公司「" + company.getName() + "」暂停运营已被停用，如有疑问请联系平台");
                    }
                }
            }
            throw new BusinessException(ErrorCode.ACCOUNT_DISABLED);
        }
        if (user.getStatus() == 2) {
            throw new BusinessException(ErrorCode.ACCOUNT_PENDING);
        }

        String token = jwtUtil.generateToken(user.getId(), user.getRole(), user.getPhone());
        LoginVO vo = LoginVO.builder()
                .userId(user.getId())
                .phone(user.getPhone())
                .nickname(user.getNickname())
                .avatarUrl(user.getAvatarUrl())
                .role(user.getRole())
                .token(token)
                .expiresIn(86400L)
                .build();

        return Result.success(vo);
    }

    /** 获取当前登录用户信息 */
    @GetMapping("/me")
    public Result<Map<String, Object>> getMe(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        User user = userService.getById(userId);
        if (user == null) throw new BusinessException(ErrorCode.USER_NOT_EXIST);
        Map<String, Object> data = new HashMap<>();
        data.put("userId",    user.getId());
        data.put("nickname",  user.getNickname() != null ? user.getNickname() : "");
        data.put("phone",     user.getPhone());
        data.put("role",      user.getRole());
        data.put("status",    user.getStatus());
        data.put("createdAt", user.getCreatedAt() != null ? user.getCreatedAt().toString() : "");
        // 保洁员额外返回审核状态和公司信息
        if (UserRole.CLEANER.getCode().equals(user.getRole())) {
            CleanerProfile profile = cleanerProfileService.lambdaQuery()
                    .eq(CleanerProfile::getUserId, userId).one();
            data.put("auditStatus", profile != null ? profile.getAuditStatus() : 2);
            data.put("auditRemark", profile != null ? profile.getAuditRemark() : null);
            if (profile != null && profile.getCompanyId() != null) {
                CleaningCompany company = companyService.getById(profile.getCompanyId());
                data.put("companyId",   company != null ? company.getId()   : null);
                data.put("companyName", company != null ? company.getName() : null);
                data.put("companyStatus", company != null ? company.getStatus() : null);
            }
        }
        return Result.success(data);
    }

    /** 修改密码 */
    @PutMapping("/password")
    public Result<Void> changePassword(@RequestBody Map<String, String> body, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        User user = userService.getById(userId);
        if (user == null) throw new BusinessException(ErrorCode.USER_NOT_EXIST);

        String oldPwd = body.get("oldPassword");
        String newPwd = body.get("newPassword");
        if (oldPwd == null || !passwordEncoder.matches(oldPwd, user.getPassword())) {
            throw new BusinessException(ErrorCode.PASSWORD_ERROR);
        }
        if (newPwd == null || newPwd.length() < 6) {
            throw new BusinessException("新密码不能少于6位");
        }
        user.setPassword(passwordEncoder.encode(newPwd));
        userService.updateById(user);
        return Result.success();
    }
}
