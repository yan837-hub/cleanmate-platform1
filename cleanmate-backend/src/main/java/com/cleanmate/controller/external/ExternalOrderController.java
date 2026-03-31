package com.cleanmate.controller.external;

import com.cleanmate.common.Result;
import com.cleanmate.dto.order.ExternalImportDTO;
import com.cleanmate.service.IServiceOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

/**
 * 外部平台订单导入接口（不走 JWT，使用固定平台密钥验证）
 */
@RestController
@RequestMapping("/external/orders")
@RequiredArgsConstructor
public class ExternalOrderController {

    private static final String PLATFORM_KEY = "jd2home_mock_key";

    private final IServiceOrderService orderService;

    @PostMapping("/import")
    public Result<Map<String, Object>> importOrder(@RequestBody ExternalImportDTO dto,
                                                   HttpServletRequest request) {
        String key = request.getHeader("X-Platform-Key");
        if (!PLATFORM_KEY.equals(key)) {
            return Result.error(401, "无效的平台密钥");
        }
        return Result.success(orderService.importOrder(dto, 2, null));
    }
}