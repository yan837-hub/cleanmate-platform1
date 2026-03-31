package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 保洁员扩展信息表
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cleaner_profile")
public class CleanerProfile extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    private String realName;

    private String idCard;

    private String idCardFront;

    private String idCardBack;

    private String certImg;

    private String healthCertImg;

    /** 所属公司ID，null=个人保洁员 */
    private Long companyId;

    private String serviceArea;

    private BigDecimal longitude;

    private BigDecimal latitude;

    private String bio;

    /** 擅长服务类型标签，逗号分隔 */
    private String skillTags;

    /** 综合评分（1-5） */
    private BigDecimal avgScore;

    /** 累计接单数 */
    private Integer orderCount;

    /** 审核状态：1=通过 2=待审核 3=拒绝 */
    private Integer auditStatus;

    private String auditRemark;

    private Long auditedBy;

    private LocalDateTime auditedAt;

    /** 账号状态（非数据库字段，查询时从 user 表填充）：1=正常 2=待审核 3=禁用 */
    @TableField(exist = false)
    private Integer userStatus;

    /** 手机号（非数据库字段，查询时从 user 表填充） */
    @TableField(exist = false)
    private String phone;

    /** 公司名称（非数据库字段，查询时从 cleaning_company 表填充；无公司则为"个人"） */
    @TableField(exist = false)
    private String companyName;

    /** 所属公司状态（非数据库字段，1=正常 3=停用；无公司则为null） */
    @TableField(exist = false)
    private Integer companyStatus;
}
