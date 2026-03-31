package com.cleanmate.dto.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

/**
 * 注册请求 DTO
 */
@Data
public class RegisterDTO {

    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    @NotBlank(message = "密码不能为空")
    private String password;

    private String nickname;

    /** 保洁员注册时填写的真实姓名（role=2 时必填，同步存入 cleaner_profile.real_name） */
    private String realName;

    /** 注册角色：1=顾客 2=保洁员 */
    @NotNull(message = "角色不能为空")
    private Integer role;

    /** 保洁员所属公司ID（role=2 且选择公司保洁员时传入，null=个人保洁员） */
    private Long companyId;
}
