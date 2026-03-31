import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { getUser, setUser, setToken, removeToken, ROLE } from '@/utils/auth'

export const useUserStore = defineStore('user', () => {
  const userInfo = ref(getUser())

  const isLoggedIn = computed(() => !!userInfo.value)
  const role = computed(() => userInfo.value?.role)
  const userId = computed(() => userInfo.value?.userId)
  const isCustomer = computed(() => role.value === ROLE.CUSTOMER)
  const isCleaner = computed(() => role.value === ROLE.CLEANER)
  const isAdmin = computed(() => role.value === ROLE.ADMIN)

  function login(data) {
    setToken(data.token)
    setUser(data)
    userInfo.value = data
  }

  function logout() {
    removeToken()
    userInfo.value = null
  }

  return {
    userInfo,
    isLoggedIn,
    role,
    userId,
    isCustomer,
    isCleaner,
    isAdmin,
    login,
    logout,
  }
})
