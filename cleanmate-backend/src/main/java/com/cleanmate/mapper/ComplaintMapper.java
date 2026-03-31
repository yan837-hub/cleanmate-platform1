package com.cleanmate.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cleanmate.entity.Complaint;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface ComplaintMapper extends BaseMapper<Complaint> {

    /** 待处理投诉数（status=1） */
    @Select("SELECT COUNT(*) FROM complaint WHERE status = 1")
    long countPendingComplaints();

    /** 处理中投诉数（status=2） */
    @Select("SELECT COUNT(*) FROM complaint WHERE status = 2")
    long countProcessingComplaints();

    /** 已结案投诉数（status=3） */
    @Select("SELECT COUNT(*) FROM complaint WHERE status = 3")
    long countClosedComplaints();
}
