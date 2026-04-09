import request from '@/utils/request'

// 看板概览
export function getOverview() {
  return request.get('/admin/stats/overview')
}

// 订单趋势（近 N 天）
export function getStatsTrend(days = 7) {
  return request.get('/admin/stats/trend', { params: { days } })
}

// 服务类型占比
export function getServiceTypeStats() {
  return request.get('/admin/stats/service-type')
}

// 保洁员绩效排名
export function getCleanerRank(limit = 10) {
  return request.get('/admin/stats/cleaner-rank', { params: { limit } })
}

// 订单趋势（旧名，兼容保留）
export function getOrderTrend(days = 7) {
  return getStatsTrend(days)
}

// 待审核保洁员列表
export function getPendingCleaners(params) {
  return request.get('/admin/audit/cleaners', { params })
}

// 审核保洁员
export function auditCleaner(id, auditStatus, remark) {
  return request.put(`/admin/audit/cleaners/${id}`, null, {
    params: { auditStatus, remark },
  })
}

// 禁用/启用保洁员（status: 1=启用 3=禁用）
export function toggleCleanerStatus(userId, status) {
  return request.put(`/admin/audit/cleaners/${userId}/status`, null, {
    params: { status },
  })
}

// 待处理订单池（status=1 待派单 + status=2 超时待处理）
export function getPendingOrders(params) {
  return request.get('/admin/dispatch/pending', { params })
}

// 自动派单
export function autoDispatch(orderId) {
  return request.post(`/admin/dispatch/auto/${orderId}`)
}

// 获取订单候选保洁员列表
export function getDispatchCandidates(orderId) {
  return request.get(`/admin/dispatch/candidates/${orderId}`)
}

// 手动指派（JSON body）
export function manualDispatch(data) {
  return request.post('/admin/dispatch/manual', data)
}

// 管理员：订单列表
export function getAdminOrders(params) {
  return request.get('/admin/orders', { params })
}

// 管理员：订单详情
export function getAdminOrderDetail(orderId) {
  return request.get(`/admin/orders/${orderId}`)
}

// 投诉列表
export function getComplaints(params) {
  return request.get('/admin/complaints', { params })
}

// 处理投诉
export function handleComplaint(id, data) {
  return request.put(`/admin/complaints/${id}`, data)
}

// 公司列表（管理员端，带分页和筛选）
export function getAdminCompanies(params) {
  return request.get('/admin/audit/companies', { params })
}

// 新增公司
export function createCompany(data) {
  return request.post('/admin/companies', data)
}

// 编辑公司基本信息
export function updateCompany(id, data) {
  return request.put(`/admin/companies/${id}`, data)
}

// 启用/停用公司
export function toggleCompanyStatus(id, status, remark) {
  return request.put(`/admin/audit/companies/${id}`, null, {
    params: { status, remark },
  })
}

// 超时无人接单的自动取消订单列表
export function getExpiredUnacceptedOrders(params) {
  return request.get('/admin/orders/expired-unaccepted', { params })
}

// 异常通知（管理员）
export function getAdminNotifications(params) {
  return request.get('/admin/notifications', { params })
}

export function markAdminNotificationRead(id) {
  return request.put(`/admin/notifications/${id}/read`)
}

// 管理员手动录入订单（source=3）
export function manualCreateOrder(data) {
  return request.post('/admin/orders/manual-create', data)
}

// 模拟外部平台导入订单（source=2，使用平台密钥）
export function importExternalOrder(data) {
  return request.post('/external/orders/import', data, {
    headers: { 'X-Platform-Key': 'jd2home_mock_key' },
  })
}

// ---- 顾客管理 ----

// 顾客列表
export function getAdminCustomers(params) {
  return request.get('/admin/customers', { params })
}

// 启用/停用顾客
export function toggleCustomerStatus(userId, status) {
  return request.put(`/admin/customers/${userId}/status`, null, { params: { status } })
}

// ---- 服务类型管理 ----

// 服务类型分页列表
export function getServiceTypes(params) {
  return request.get('/admin/service-types', { params })
}

// 新增服务类型
export function createServiceType(data) {
  return request.post('/admin/service-types', data)
}

// 编辑服务类型
export function updateServiceType(id, data) {
  return request.put(`/admin/service-types/${id}`, data)
}

// 上架/下架
export function updateServiceTypeStatus(id, status) {
  return request.put(`/admin/service-types/${id}/status`, { status })
}

// ---- 操作日志 ----

export function getOperationLogs(params) {
  return request.get('/admin/operation-logs', { params })
}
