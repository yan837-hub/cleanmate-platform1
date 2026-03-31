package com.cleanmate.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.cleanmate.common.PageResult;
import com.cleanmate.dto.order.CreateOrderDTO;
import com.cleanmate.dto.order.ExternalImportDTO;
import com.cleanmate.entity.ServiceOrder;
import com.cleanmate.vo.dispatch.CandidateVO;
import com.cleanmate.vo.order.OrderVO;

import java.util.List;
import java.util.Map;

public interface IServiceOrderService extends IService<ServiceOrder> {

    /** 顾客创建订单，返回订单ID */
    Long createOrder(CreateOrderDTO dto, Long customerId);

    /** 查询订单详情（含保洁员信息） */
    OrderVO getOrderVO(Long orderId);

    /** 顾客订单分页列表 */
    PageResult<OrderVO> listCustomerOrders(Long customerId, Integer status, long current, long size);

    /** 保洁员订单分页列表 */
    PageResult<OrderVO> listCleanerOrders(Long cleanerId, Integer status, long current, long size);

    /** 保洁员抢单（状态1->3，创建dispatch_record + time_lock） */
    void grabOrder(Long orderId, Long cleanerId);

    /** 保洁员签到打卡（状态3->4，写checkin_record） */
    void checkinOrder(Long orderId, Long cleanerId, Double longitude, Double latitude);

    /** 保洁员完工上报（状态4->5，计算费用，写fee_detail，设48h自动确认时间） */
    void reportComplete(Long orderId, Long cleanerId, Integer actualDuration);

    /** 自动派单：按距离+评分找最优保洁员，写dispatch_record，状态1->2，返回派单的保洁员ID；无可用保洁员时返回null */
    Long autoDispatch(Long orderId);

    /** 保洁员接单（状态2->3），创建time_lock */
    void acceptOrder(Long orderId, Long cleanerId);

    /** 保洁员拒单（状态回退到1），dispatch_record标记rejected */
    void rejectOrder(Long orderId, Long cleanerId);

    /** 记录订单状态变更日志 */
    void logStatusChange(Long orderId, Integer fromStatus, Integer toStatus, Long operatorId, String remark);

    /** 出行提醒：给2小时内即将上门的保洁员推送通知，返回本次发送数量 */
    int sendUpcomingReminders();

    /** 管理员手动派单：status→2（待确认），保洁员需在首页确认接单，写dispatch_record、通知、operation_log */
    void manualDispatchByAdmin(Long orderId, Long cleanerId, Long adminId, String remark);

    /** 获取订单的候选保洁员列表（复用自动派单筛选逻辑，按综合评分倒序） */
    List<CandidateVO> getDispatchCandidates(Long orderId);

    /**
     * 外部平台导入 / 管理员手动录入 通用创建订单
     * @param dto       入参
     * @param source    2=外部导入 3=手动录入
     * @param operatorId 操作人ID（手动录入传管理员ID，外部导入传null）
     * @return systemOrderNo + estimateFee
     */
    Map<String, Object> importOrder(ExternalImportDTO dto, int source, Long operatorId);
}
