/**
 * 全站统一订单状态映射
 * 所有端（顾客/保洁员/管理员）共享同一份状态文字和 Tag 类型
 */
export const ORDER_STATUS_MAP = {
  1: { text: '待派单',     type: 'info'    },
  2: { text: '待确认',     type: 'warning' },
  3: { text: '待上门',     type: ''        },
  4: { text: '服务中',     type: 'primary' },
  5: { text: '待确认完成', type: 'warning' },
  6: { text: '已完成',     type: 'success' },
  7: { text: '售后中',     type: 'danger'  },
  8: { text: '已取消',     type: 'info'    },
  9: { text: '改期审核中', type: 'warning' },
}

export function orderStatusText(order) {
  if (order.status === 7 && order.complaintStatus === 3) return '售后已结案'
  return ORDER_STATUS_MAP[order.status]?.text || order.statusDesc || '未知'
}

export function orderStatusType(order) {
  if (order.status === 7 && order.complaintStatus === 3) return 'success'
  return ORDER_STATUS_MAP[order.status]?.type ?? 'info'
}
