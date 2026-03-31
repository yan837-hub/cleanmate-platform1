package com.cleanmate.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.cleanmate.common.PageResult;
import com.cleanmate.entity.ServicePriceTier;
import com.cleanmate.entity.ServiceType;

import java.math.BigDecimal;
import java.util.List;

public interface IServiceTypeService extends IService<ServiceType> {

    /** 管理员分页查询（含 priceTiers） */
    PageResult<ServiceTypeVO> adminPage(long current, long size, Integer status);

    /** 新增服务类型（含面积阶梯） */
    void adminCreate(ServiceTypeDTO dto);

    /** 全量更新（priceTiers 全量替换） */
    void adminUpdate(Long id, ServiceTypeDTO dto);

    /**
     * 更新上架/下架状态
     * @return 下架时若有进行中订单返回警告文字，否则 null
     */
    String toggleStatus(Long id, Integer status);

    // ---- 内嵌 DTO / VO ----

    class PriceTierDTO {
        public Integer areaMin;
        public Integer areaMax;
        public BigDecimal unitPrice;
    }

    class ServiceTypeDTO {
        public String name;
        public String description;
        public String coverImg;
        public Integer priceMode;
        public BigDecimal basePrice;
        public Integer minDuration;
        public Integer suggestWorkers;
        public Integer sortOrder;
        public List<PriceTierDTO> priceTiers;
    }

    class ServiceTypeVO extends ServiceType {
        public List<ServicePriceTier> priceTiers;
    }
}
