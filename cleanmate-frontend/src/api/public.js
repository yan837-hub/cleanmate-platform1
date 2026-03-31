import request from '@/utils/request'

/** 获取正常状态公司列表（无需登录），供保洁员注册时选择 */
export function getPublicCompanyList() {
  return request.get('/public/companies/list')
}
