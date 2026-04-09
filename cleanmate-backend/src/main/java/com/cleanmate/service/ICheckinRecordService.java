package com.cleanmate.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.cleanmate.entity.CheckinRecord;

public interface ICheckinRecordService extends IService<CheckinRecord> {

    /** 以独立事务保存异常签到记录（主事务回滚不影响此记录） */
    void saveAbnormalRecord(CheckinRecord record);
}
