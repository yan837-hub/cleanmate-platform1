/**
 * 全站统一时间格式化工具
 */
export function formatTime(t) {
  return t ? String(t).replace('T', ' ').substring(0, 16) : '-'
}
