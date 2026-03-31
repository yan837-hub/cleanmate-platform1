package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 用户账号表（顾客 + 保洁员 + 管理员统一账号）
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("user")
public class User extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 手机号（登录账号） */
    private String phone;

    /** 密码（BCrypt加密） */
    private String password;

    private String nickname;

    private String avatarUrl;

    /** 角色：1=顾客 2=保洁员 3=平台管理员 */
    private Integer role;

    /** 账号状态：1=正常 2=待审核 3=停用 4=封禁 */
    private Integer status;
}
