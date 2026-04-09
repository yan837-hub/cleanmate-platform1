import request from '@/utils/request'

export function getAddresses() {
  return request.get('/customer/addresses')
}

export function addAddress(data) {
  return request.post('/customer/addresses', data)
}

export function deleteAddress(id) {
  return request.delete(`/customer/addresses/${id}`)
}

export function setDefaultAddress(id) {
  return request.put(`/customer/addresses/${id}/default`)
}
