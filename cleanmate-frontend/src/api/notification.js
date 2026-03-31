import request from '@/utils/request'

export function getNotifications() {
  return request.get('/notifications')
}

export function getUnreadCount() {
  return request.get('/notifications/unread-count')
}

export function markAllRead() {
  return request.put('/notifications/read-all')
}

export function markRead(id) {
  return request.put(`/notifications/${id}/read`)
}
