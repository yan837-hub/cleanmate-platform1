package com.cleanmate.vo.auth;

import lombok.Builder;
import lombok.Data;

/**
 * 登录响应 VO
 */
@Data
@Builder
public class LoginVO {

    private Long userId;
    private String phone;
    private String nickname;
    private String avatarUrl;
    private Integer role;
    private String token;
    private Long expiresIn;
}
