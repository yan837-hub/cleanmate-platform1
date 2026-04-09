import axios from 'axios'
import { getToken, removeToken } from './auth'
import router from '@/router'

const request = axios.create({
  baseURL: '/api',
  timeout: 10000,
})

// 请求拦截器：自动携带 token
request.interceptors.request.use(
  (config) => {
    const token = getToken()
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// 响应拦截器：统一处理错误
request.interceptors.response.use(
  (response) => {
    const res = response.data
    // 直接返回 data 字段，业务层无需再 .data
    if (res.code === 200) {
      return res.data
    }
    // 401：未登录，跳转登录页
    if (res.code === 401) {
      removeToken()
      router.push('/login')
      return Promise.reject(new Error(res.message))
    }
    // 其他业务错误：只 reject，由调用方 catch 决定如何提示，避免双重弹框
    return Promise.reject(new Error(res.message))
  },
  (error) => {
    const status = error.response?.status
    if (status === 401) {
      removeToken()
      router.push('/login')
      return Promise.reject(error)
    }
    // HTTP 错误：把状态码对应的描述挂到 error.message，由调用方 catch 统一展示
    if (status === 403) {
      error.message = '无权限访问'
    } else if (status === 500) {
      const serverMsg = error.response?.data?.message
      error.message = serverMsg || '服务器内部错误'
    }
    return Promise.reject(error)
  }
)

export default request
