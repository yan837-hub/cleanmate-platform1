import request from '@/utils/request'

export function getServiceTypes() {
  return request.get('/service-types')
}

