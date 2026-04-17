package com.cleanmate.controller.admin;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.cleanmate.common.PageResult;
import com.cleanmate.common.Result;
import com.cleanmate.entity.OrderReview;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.entity.User;
import com.cleanmate.service.IOrderReviewService;
import com.cleanmate.service.IServiceOrderService;
import com.cleanmate.service.IUserService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/admin/reviews")
@RequiredArgsConstructor
public class AdminReviewController {

    private final IOrderReviewService reviewService;
    private final IUserService        userService;
    private final IServiceOrderService orderService;

    /** 评价列表（分页，含顾客/保洁员昵称和订单号） */
    @GetMapping
    public Result<PageResult<OrderReview>> list(
            @RequestParam(defaultValue = "1")  Long current,
            @RequestParam(defaultValue = "10") Long size,
            @RequestParam(required = false) Integer isVisible,
            @RequestParam(required = false) String keyword) {

        LambdaQueryWrapper<OrderReview> wrapper = new LambdaQueryWrapper<>();
        if (isVisible != null) wrapper.eq(OrderReview::getIsVisible, isVisible);
        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w
                    .like(OrderReview::getContent, keyword)
                    .or().eq(OrderReview::getOrderId,
                            keyword.matches("\\d+") ? Long.parseLong(keyword) : -1L));
        }
        wrapper.orderByDesc(OrderReview::getCreatedAt);

        Page<OrderReview> page = reviewService.page(new Page<>(current, size), wrapper);
        page.getRecords().forEach(r -> {
            if (r.getCustomerId() != null) {
                User u = userService.getById(r.getCustomerId());
                if (u != null) r.setCustomerNickname(u.getNickname());
            }
            if (r.getCleanerId() != null) {
                User u = userService.getById(r.getCleanerId());
                if (u != null) r.setCleanerNickname(u.getNickname());
            }
            if (r.getOrderId() != null) {
                ServiceOrder o = orderService.getById(r.getOrderId());
                if (o != null) r.setOrderNo(o.getOrderNo());
            }
        });

        return Result.success(PageResult.of(page));
    }

    /** 屏蔽评价 */
    @PutMapping("/{id}/hide")
    public Result<Void> hide(@PathVariable Long id,
                             @RequestBody HideDTO dto,
                             Authentication auth) {
        OrderReview review = reviewService.getById(id);
        if (review == null) return Result.error(404, "评价不存在");
        review.setIsVisible(0);
        review.setHideReason(dto.getHideReason());
        review.setHiddenBy((Long) auth.getPrincipal());
        reviewService.updateById(review);
        return Result.success();
    }

    /** 恢复显示 */
    @PutMapping("/{id}/show")
    public Result<Void> show(@PathVariable Long id) {
        OrderReview review = reviewService.getById(id);
        if (review == null) return Result.error(404, "评价不存在");
        review.setIsVisible(1);
        review.setHideReason(null);
        review.setHiddenBy(null);
        reviewService.updateById(review);
        return Result.success();
    }

    @Data
    static class HideDTO {
        private String hideReason;
    }
}
