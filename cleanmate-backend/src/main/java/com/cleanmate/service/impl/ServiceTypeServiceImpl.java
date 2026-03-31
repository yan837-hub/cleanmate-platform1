package com.cleanmate.service.impl;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.cleanmate.common.PageResult;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.entity.ServicePriceTier;
import com.cleanmate.entity.ServiceType;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.exception.ErrorCode;
import com.cleanmate.mapper.ServiceOrderMapper;
import com.cleanmate.mapper.ServicePriceTierMapper;
import com.cleanmate.mapper.ServiceTypeMapper;
import com.cleanmate.service.IServiceTypeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ServiceTypeServiceImpl extends ServiceImpl<ServiceTypeMapper, ServiceType>
        implements IServiceTypeService {

    private final ServicePriceTierMapper priceTierMapper;
    private final ServiceOrderMapper serviceOrderMapper;

    @Override
    public PageResult<ServiceTypeVO> adminPage(long current, long size, Integer status) {
        var query = lambdaQuery();
        if (status != null) {
            query.eq(ServiceType::getStatus, status);
        }
        query.orderByAsc(ServiceType::getSortOrder).orderByDesc(ServiceType::getId);
        Page<ServiceType> page = query.page(new Page<>(current, size));

        // 批量查阶梯，减少 N+1
        List<Long> ids = page.getRecords().stream().map(ServiceType::getId).toList();
        Map<Long, List<ServicePriceTier>> tierMap = ids.isEmpty() ? Map.of()
                : priceTierMapper.selectList(
                        com.baomidou.mybatisplus.core.toolkit.Wrappers.<ServicePriceTier>lambdaQuery()
                                .in(ServicePriceTier::getServiceTypeId, ids)
                                .orderByAsc(ServicePriceTier::getAreaMin)
                  ).stream()
                  .collect(Collectors.groupingBy(ServicePriceTier::getServiceTypeId));

        List<ServiceTypeVO> voList = page.getRecords().stream().map(st -> {
            ServiceTypeVO vo = new ServiceTypeVO();
            // 复制字段
            vo.setId(st.getId());
            vo.setName(st.getName());
            vo.setDescription(st.getDescription());
            vo.setCoverImg(st.getCoverImg());
            vo.setPriceMode(st.getPriceMode());
            vo.setBasePrice(st.getBasePrice());
            vo.setMinDuration(st.getMinDuration());
            vo.setSuggestWorkers(st.getSuggestWorkers());
            vo.setSortOrder(st.getSortOrder());
            vo.setStatus(st.getStatus());
            vo.priceTiers = tierMap.getOrDefault(st.getId(), List.of());
            return vo;
        }).toList();

        return PageResult.of(voList, page.getTotal(), page.getCurrent(), page.getSize());
    }

    @Override
    @Transactional
    public void adminCreate(ServiceTypeDTO dto) {
        if (dto.name == null || dto.name.isBlank()) {
            throw new BusinessException(ErrorCode.PARAM_ERROR);
        }
        if (dto.priceMode == 2 && (dto.priceTiers == null || dto.priceTiers.isEmpty())) {
            throw new BusinessException(ErrorCode.PARAM_ERROR);
        }

        ServiceType st = new ServiceType();
        fillEntity(st, dto);
        st.setStatus(1); // 新建默认上架
        save(st);

        saveTiers(st.getId(), dto);
    }

    @Override
    @Transactional
    public void adminUpdate(Long id, ServiceTypeDTO dto) {
        ServiceType st = getById(id);
        if (st == null) throw new BusinessException(ErrorCode.NOT_FOUND);

        fillEntity(st, dto);
        updateById(st);

        // 全量替换阶梯
        com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ServicePriceTier> del =
                com.baomidou.mybatisplus.core.toolkit.Wrappers.<ServicePriceTier>lambdaQuery()
                        .eq(ServicePriceTier::getServiceTypeId, id);
        priceTierMapper.delete(del);
        saveTiers(id, dto);
    }

    @Override
    @Transactional
    public String toggleStatus(Long id, Integer status) {
        ServiceType st = getById(id);
        if (st == null) throw new BusinessException(ErrorCode.NOT_FOUND);

        String warning = null;
        // 下架时检查进行中订单（status 1=待派单 2=已派单待确认 3=已接单）
        if (status == 2) {
            long ongoingCount = serviceOrderMapper.selectCount(
                    com.baomidou.mybatisplus.core.toolkit.Wrappers.<ServiceOrder>lambdaQuery()
                            .eq(ServiceOrder::getServiceTypeId, id)
                            .in(ServiceOrder::getStatus, Arrays.asList(1, 2, 3))
            );
            if (ongoingCount > 0) {
                warning = "该服务类型有进行中的订单，下架后不影响已有订单";
            }
        }

        st.setStatus(status);
        updateById(st);
        return warning;
    }

    // ---- 私有方法 ----

    private void fillEntity(ServiceType st, ServiceTypeDTO dto) {
        if (dto.name        != null) st.setName(dto.name);
        if (dto.description != null) st.setDescription(dto.description);
        if (dto.coverImg    != null) st.setCoverImg(dto.coverImg);
        if (dto.priceMode   != null) st.setPriceMode(dto.priceMode);
        if (dto.basePrice   != null) st.setBasePrice(dto.basePrice);
        if (dto.minDuration != null) st.setMinDuration(dto.minDuration);
        if (dto.suggestWorkers != null) st.setSuggestWorkers(dto.suggestWorkers);
        if (dto.sortOrder   != null) st.setSortOrder(dto.sortOrder);
    }

    private void saveTiers(Long serviceTypeId, ServiceTypeDTO dto) {
        if (dto.priceTiers == null || dto.priceTiers.isEmpty()) return;
        for (PriceTierDTO t : dto.priceTiers) {
            ServicePriceTier tier = new ServicePriceTier();
            tier.setServiceTypeId(serviceTypeId);
            tier.setAreaMin(t.areaMin);
            tier.setAreaMax(t.areaMax);
            tier.setUnitPrice(t.unitPrice);
            priceTierMapper.insert(tier);
        }
    }
}
