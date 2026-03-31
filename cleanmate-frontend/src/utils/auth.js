const TOKEN_KEY = 'cleanmate_token'
const USER_KEY = 'cleanmate_user'

export function getToken() {
  return localStorage.getItem(TOKEN_KEY)
}

export function setToken(token) {
  localStorage.setItem(TOKEN_KEY, token)
}

export function removeToken() {
  localStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(USER_KEY)
}

export function getUser() {
  const raw = localStorage.getItem(USER_KEY)
  return raw ? JSON.parse(raw) : null
}

export function setUser(user) {
  localStorage.setItem(USER_KEY, JSON.stringify(user))
}

export function isLoggedIn() {
  return !!getToken()
}

/** 角色常量 */
export const ROLE = {
  CUSTOMER: 1,
  CLEANER: 2,
  ADMIN: 3,
}

/** 根据角色获取首页路由 */
export function getHomeRoute(role) {
  const map = {
    [ROLE.CUSTOMER]: '/customer/home',
    [ROLE.CLEANER]: '/cleaner/home',
    [ROLE.ADMIN]: '/admin/dashboard',
  }
  return map[role] || '/login'
}
