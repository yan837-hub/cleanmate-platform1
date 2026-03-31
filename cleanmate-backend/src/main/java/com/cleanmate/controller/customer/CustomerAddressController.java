package com.cleanmate.controller.customer;

import com.cleanmate.common.Result;
import com.cleanmate.dto.address.AddressDTO;
import com.cleanmate.entity.CustomerAddress;
import com.cleanmate.exception.BusinessException;
import com.cleanmate.service.ICustomerAddressService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 顾客端 - 地址管理控制器
 */
@RestController
@RequestMapping("/customer/addresses")
@RequiredArgsConstructor
public class CustomerAddressController {

    private final ICustomerAddressService addressService;
    private final com.cleanmate.utils.GeocodingUtil geocodingUtil;

    /** 获取我的地址列表 */
    @GetMapping
    public Result<List<CustomerAddress>> listAddresses(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        List<CustomerAddress> list = addressService.lambdaQuery()
                .eq(CustomerAddress::getUserId, userId)
                .orderByDesc(CustomerAddress::getIsDefault)
                .list();
        return Result.success(list);
    }

    /** 新增地址 */
    @PostMapping
    public Result<Long> addAddress(@Valid @RequestBody AddressDTO dto, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();

        // 如果设为默认，先把其他地址默认取消
        if (Integer.valueOf(1).equals(dto.getIsDefault())) {
            addressService.lambdaUpdate()
                    .eq(CustomerAddress::getUserId, userId)
                    .set(CustomerAddress::getIsDefault, 0)
                    .update();
        }

        CustomerAddress address = new CustomerAddress();
        address.setUserId(userId);
        address.setLabel(dto.getLabel());
        address.setContactName(dto.getContactName());
        address.setContactPhone(dto.getContactPhone());
        address.setProvince(dto.getProvince());
        address.setCity(dto.getCity());
        address.setDistrict(dto.getDistrict());
        address.setDetail(dto.getDetail());
        fillCoords(address, dto);
        address.setIsDefault(dto.getIsDefault() != null ? dto.getIsDefault() : 0);
        addressService.save(address);

        return Result.success("地址添加成功", address.getId());
    }

    /** 修改地址 */
    @PutMapping("/{id}")
    public Result<Void> updateAddress(@PathVariable Long id,
                                      @Valid @RequestBody AddressDTO dto,
                                      Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        CustomerAddress address = addressService.getById(id);
        if (address == null || !address.getUserId().equals(userId)) {
            throw new BusinessException("地址不存在");
        }

        if (Integer.valueOf(1).equals(dto.getIsDefault())) {
            addressService.lambdaUpdate()
                    .eq(CustomerAddress::getUserId, userId)
                    .set(CustomerAddress::getIsDefault, 0)
                    .update();
        }

        address.setLabel(dto.getLabel());
        address.setContactName(dto.getContactName());
        address.setContactPhone(dto.getContactPhone());
        address.setProvince(dto.getProvince());
        address.setCity(dto.getCity());
        address.setDistrict(dto.getDistrict());
        address.setDetail(dto.getDetail());
        fillCoords(address, dto);
        if (dto.getIsDefault() != null) address.setIsDefault(dto.getIsDefault());
        addressService.updateById(address);
        return Result.success();
    }

    /** 删除地址 */
    @DeleteMapping("/{id}")
    public Result<Void> deleteAddress(@PathVariable Long id, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        CustomerAddress address = addressService.getById(id);
        if (address == null || !address.getUserId().equals(userId)) {
            throw new BusinessException("地址不存在");
        }
        addressService.removeById(id);
        return Result.success();
    }

    // ========== 坐标填充（优先高德API，失败则按城市兜底） ==========
    private static final java.util.Map<String, double[]> CITY_COORDS = java.util.Map.ofEntries(
        java.util.Map.entry("重庆市", new double[]{106.5516, 29.5630}),
        java.util.Map.entry("北京市", new double[]{116.4074, 39.9042}),
        java.util.Map.entry("上海市", new double[]{121.4737, 31.2304}),
        java.util.Map.entry("广州市", new double[]{113.2644, 23.1291}),
        java.util.Map.entry("深圳市", new double[]{114.0579, 22.5431}),
        java.util.Map.entry("成都市", new double[]{104.0668, 30.5728}),
        java.util.Map.entry("武汉市", new double[]{114.3054, 30.5928}),
        java.util.Map.entry("西安市", new double[]{108.9398, 34.3416}),
        java.util.Map.entry("杭州市", new double[]{120.1551, 30.2741}),
        java.util.Map.entry("南京市", new double[]{118.7969, 32.0603})
    );

    private void fillCoords(CustomerAddress address, AddressDTO dto) {
        // 前端已传坐标则直接使用
        if (dto.getLongitude() != null && dto.getLatitude() != null) {
            address.setLongitude(dto.getLongitude());
            address.setLatitude(dto.getLatitude());
            return;
        }
        // 调高德 API 解析完整地址
        String fullAddr = dto.getProvince() + dto.getCity() + dto.getDistrict() + dto.getDetail();
        java.math.BigDecimal[] coords = geocodingUtil.geocode(fullAddr);
        if (coords != null) {
            address.setLongitude(coords[0]);
            address.setLatitude(coords[1]);
            return;
        }
        // 高德失败 → 按城市名兜底
        double[] c = CITY_COORDS.getOrDefault(dto.getCity(), new double[]{106.5516, 29.5630});
        address.setLongitude(java.math.BigDecimal.valueOf(c[0]));
        address.setLatitude(java.math.BigDecimal.valueOf(c[1]));
    }

    /** 设为默认地址 */
    @PutMapping("/{id}/default")
    public Result<Void> setDefault(@PathVariable Long id, Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        CustomerAddress address = addressService.getById(id);
        if (address == null || !address.getUserId().equals(userId)) {
            throw new BusinessException("地址不存在");
        }
        addressService.lambdaUpdate()
                .eq(CustomerAddress::getUserId, userId)
                .set(CustomerAddress::getIsDefault, 0)
                .update();
        address.setIsDefault(1);
        addressService.updateById(address);
        return Result.success();
    }
}
