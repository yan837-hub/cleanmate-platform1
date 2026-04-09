import request from '@/utils/request'

// 顾客首页统计
export function getCustomerStats() {
  return request.get('/customer/orders/stats')
}

// 顾客下单
export function createOrder(data) {
  return request.post('/customer/orders', data)
}

// 顾客订单列表
export function getMyOrders(params) {
  return request.get('/customer/orders', { params })
}

// 订单详情（顾客/保洁员通用，后端按角色鉴权）
export function getOrderDetail(orderId) {
  return request.get(`/customer/orders/${orderId}`)
}

// 顾客取消订单
export function cancelOrder(orderId, reason) {
  return request.put(`/customer/orders/${orderId}/cancel`, null, { params: { reason } })
}

// 保洁员主动取消已接单（距预约>4小时）
export function cleanerCancelOrder(orderId, reason) {
  return request.put(`/cleaner/orders/${orderId}/cancel`, null, { params: { reason } })
}

// 顾客确认完成
export function confirmComplete(orderId) {
  return request.put(`/customer/orders/${orderId}/confirm`)
}

// 顾客报告保洁员未到场（新路径，旧路径 no-show 已兼容）
export function reportNoShow(orderId) {
  return request.put(`/customer/orders/${orderId}/report-absence`)
}

// 查询订单评价
export function getOrderReview(orderId) {
  return request.get(`/customer/orders/${orderId}/review`)
}

// 提交评价
export function submitReview(orderId, data) {
  return request.post(`/customer/orders/${orderId}/review`, data)
}

// 保洁员：工作台统计
export function getCleanerStats() {
  return request.get('/cleaner/orders/stats')
}

// 保洁员：我的订单
export function getCleanerOrders(params) {
  return request.get('/cleaner/orders', { params })
}

// 保洁员：抢单池
export function getGrabPool(params) {
  return request.get('/cleaner/orders/pool', { params })
}

// 保洁员：抢单
export function grabOrder(orderId) {
  return request.post(`/cleaner/orders/${orderId}/grab`)
}

// 保洁员：签到
export function checkin(orderId, longitude, latitude) {
  return request.post(`/cleaner/orders/${orderId}/checkin`, null, {
    params: { longitude, latitude },
  })
}

// 保洁员：完工上报
export function reportComplete(orderId, actualDuration) {
  return request.put(`/cleaner/orders/${orderId}/complete`, null, {
    params: { actualDuration },
  })
}

// 保洁员：订单详情
export function getCleanerOrderDetail(orderId) {
  return request.get(`/cleaner/orders/${orderId}`)
}

// 保洁员：相邻订单路线提示
export function getRouteHint(orderId) {
  return request.get(`/cleaner/orders/${orderId}/route-hint`)
}

// 保洁员：上传照片
export function uploadPhoto(orderId, file, phase) {
  const form = new FormData()
  form.append('file', file)
  form.append('phase', phase)
  return request.post(`/cleaner/orders/${orderId}/photos`, form, {
    headers: { 'Content-Type': 'multipart/form-data' },
  })
}

// 保洁员：获取订单照片列表
export function getOrderPhotos(orderId) {
  return request.get(`/cleaner/orders/${orderId}/photos`)
}

// 保洁员：我的评价列表
export function getMyReviews(params) {
  return request.get('/cleaner/orders/reviews', { params })
}

// 保洁员：回复评价
export function replyReview(reviewId, replyContent) {
  return request.put(`/cleaner/orders/reviews/${reviewId}/reply`, { replyContent })
}

// 保洁员：接单（系统/管理员派单）
export function acceptOrder(orderId) {
  return request.post(`/cleaner/orders/${orderId}/accept`)
}

// 保洁员：拒单
export function rejectOrder(orderId) {
  return request.post(`/cleaner/orders/${orderId}/reject`)
}

// 保洁员：档期查询
export function getSchedule(params) {
  return request.get('/cleaner/orders/schedule', { params })
}

// 保洁员：收入明细
export function getCleanerIncome(params) {
  return request.get('/cleaner/orders/income', { params })
}

// 顾客发起投诉（status=5拒绝确认 或 status=6完成后7天内）
export function submitComplaint(orderId, data) {
  return request.post(`/customer/orders/${orderId}/complaint`, data)
}

// 查询订单投诉（已存在则返回）
export function getOrderComplaint(orderId) {
  return request.get(`/customer/orders/${orderId}/complaint`)
}

// ─────────── 改期申请 ───────────

// 顾客：提交改期申请（仅 status=3）
export function submitReschedule(orderId, newAppointTime) {
  return request.post(`/customer/orders/${orderId}/reschedule`, { newAppointTime })
}

// 顾客：查询该订单最新改期申请状态
export function getRescheduleStatus(orderId) {
  return request.get(`/customer/orders/${orderId}/reschedule-status`)
}

// 保洁员：查询待处理改期申请列表（可传 orderId 精确查询）
export function getCleanerReschedules(orderId) {
  return request.get('/cleaner/reschedules', { params: orderId ? { orderId } : {} })
}

// 保洁员：处理改期申请（approve: true=同意, false=拒绝）
export function handleReschedule(id, approve, remark = '') {
  return request.put(`/cleaner/reschedules/${id}/handle`, { approve, remark })
}

// ─────────── 保洁员个人资料 ───────────

// 获取保洁员自己的资质档案
export function getMyCleanerProfile() {
  return request.get('/cleaner/profile/me')
}

// 提交/更新保洁员资质资料
export function updateMyCleanerProfile(data) {
  return request.put('/cleaner/profile/me', data)
}

// ─────────── 保洁员档期管理 ───────────

// 获取周模板（7天配置）
export function getScheduleTemplate() {
  return request.get('/cleaner/schedule/template')
}

// 全量保存周模板
export function saveScheduleTemplate(data) {
  return request.put('/cleaner/schedule/template', data)
}

// 获取某月特殊调整列表（month: "2025-01"）
export function getScheduleOverrides(month) {
  return request.get('/cleaner/schedule/overrides', { params: { month } })
}

// 新增或更新某天特殊调整
export function saveScheduleOverride(data) {
  return request.post('/cleaner/schedule/overrides', data)
}

// 删除特殊调整
export function deleteScheduleOverride(id) {
  return request.delete(`/cleaner/schedule/overrides/${id}`)
}

// 获取某月有时段锁定的日期列表（month: "2025-01"）
export function getScheduleLockedDates(month) {
  return request.get('/cleaner/schedule/locks', { params: { month } })
}

// ─────────── 模拟支付 ───────────

// 支付定金（status=1, pay_status=0）
export function payDeposit(orderId) {
  return request.post(`/customer/orders/${orderId}/pay-deposit`)
}

// 支付尾款（status IN(5,6), pay_status=1）
export function payFinal(orderId) {
  return request.post(`/customer/orders/${orderId}/pay-final`)
}

// 支付全额（status IN(5,6), pay_status=0）
export function payFull(orderId) {
  return request.post(`/customer/orders/${orderId}/pay-full`)
}
