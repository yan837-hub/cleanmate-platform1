package com.cleanmate.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 保洁公司表
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cleaning_company")
public class CleaningCompany extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    private String licenseNo;

    private String licenseImg;

    private String contactName;

    private String contactPhone;

    private String address;

    /** 状态：1=正常 2=待审核 3=停用 */
    private Integer status;

    private String auditRemark;

    /** 审核管理员user_id */
    private Long auditedBy;

    private LocalDateTime auditedAt;

    /** 旗下保洁员数（非数据库字段，查询时填充） */
    @TableField(exist = false)
    private Integer cleanerCount;
}
