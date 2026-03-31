package com.cleanmate.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.cleanmate.entity.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper extends BaseMapper<User> {
}
