import { createRouter, createWebHistory } from 'vue-router'
import { getToken, getUser, getHomeRoute } from '@/utils/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    // 根路由重定向
    { path: '/', redirect: '/login' },

    // 认证页
    {
      path: '/login',
      name: 'Login',
      component: () => import('@/views/auth/Login.vue'),
      meta: { public: true },
    },
    {
      path: '/register',
      name: 'Register',
      component: () => import('@/views/auth/Register.vue'),
      meta: { public: true },
    },

    // 顾客端
    {
      path: '/customer',
      component: () => import('@/views/customer/CustomerLayout.vue'),
      meta: { role: 1 },
      children: [
        { path: '', redirect: '/customer/home' },
        { path: 'home', name: 'CustomerHome', component: () => import('@/views/customer/Home.vue') },
        { path: 'orders', name: 'CustomerOrders', component: () => import('@/views/customer/Orders.vue') },
        { path: 'orders/:id', name: 'CustomerOrderDetail', component: () => import('@/views/customer/OrderDetail.vue') },
        { path: 'book', name: 'CustomerBook', component: () => import('@/views/customer/Book.vue') },
        { path: 'profile', name: 'CustomerProfile', component: () => import('@/views/customer/Profile.vue') },
        { path: 'notifications', name: 'CustomerNotifications', component: () => import('@/views/shared/NotificationCenter.vue') },
      ],
    },

    // 保洁员端
    {
      path: '/cleaner',
      component: () => import('@/views/cleaner/CleanerLayout.vue'),
      meta: { role: 2 },
      children: [
        { path: '', redirect: '/cleaner/home' },
        { path: 'home', name: 'CleanerHome', component: () => import('@/views/cleaner/Home.vue') },
        { path: 'orders', name: 'CleanerOrders', component: () => import('@/views/cleaner/Orders.vue') },
        { path: 'orders/:id', name: 'CleanerOrderDetail', component: () => import('@/views/cleaner/OrderDetail.vue') },
        { path: 'grab', name: 'CleanerGrab', component: () => import('@/views/cleaner/GrabPool.vue') },
        { path: 'schedule', name: 'CleanerSchedule', component: () => import('@/views/cleaner/Schedule.vue') },
        { path: 'income', name: 'CleanerIncome', component: () => import('@/views/cleaner/Income.vue') },
        { path: 'profile', name: 'CleanerProfile', component: () => import('@/views/cleaner/Profile.vue') },
        { path: 'reviews', name: 'CleanerReviews', component: () => import('@/views/cleaner/Reviews.vue') },
        { path: 'notifications', name: 'CleanerNotifications', component: () => import('@/views/shared/NotificationCenter.vue') },
      ],
    },

    // 管理员后台
    {
      path: '/admin',
      component: () => import('@/views/admin/AdminLayout.vue'),
      meta: { role: 3 },
      children: [
        { path: '', redirect: '/admin/dashboard' },
        { path: 'dashboard', name: 'AdminDashboard', component: () => import('@/views/admin/Dashboard.vue') },
        { path: 'orders', name: 'AdminOrders', component: () => import('@/views/admin/Orders.vue') },
        { path: 'dispatch', name: 'AdminDispatch', component: () => import('@/views/admin/Dispatch.vue') },
        { path: 'customers', name: 'AdminCustomers', component: () => import('@/views/admin/Customers.vue'), meta: { title: '顾客管理' } },
        { path: 'audit/cleaners', name: 'AdminAuditCleaners', component: () => import('@/views/admin/AuditCleaners.vue') },
        { path: 'audit/companies', name: 'AdminAuditCompanies', component: () => import('@/views/admin/AuditCompanies.vue') },
        { path: 'complaints', name: 'AdminComplaints', component: () => import('@/views/admin/Complaints.vue') },
        { path: 'stats', name: 'AdminStats', component: () => import('@/views/admin/Stats.vue') },
        { path: 'service-types', name: 'AdminServiceTypes', component: () => import('@/views/admin/ServiceTypes.vue') },
        { path: 'settings', name: 'AdminSettings', component: () => import('@/views/admin/SystemConfig.vue'), meta: { title: '系统参数配置' } },
        { path: 'operation-logs', name: 'AdminOperationLog', component: () => import('@/views/admin/OperationLog.vue'), meta: { title: '操作日志' } },
        { path: 'abnormal-checkins', name: 'AdminAbnormalCheckins', component: () => import('@/views/admin/AbnormalCheckins.vue'), meta: { title: '异常管理' } },
      ],
    },

    // 404
    { path: '/:pathMatch(.*)*', redirect: '/login' },
  ],
})

// 全局路由守卫
router.beforeEach((to, from, next) => {
  const token = getToken()
  const user = getUser()

  // 公开页面直接放行
  if (to.meta.public) {
    // 已登录则跳转到对应首页
    if (token && user) {
      return next(getHomeRoute(user.role))
    }
    return next()
  }

  // 未登录 -> 登录页
  if (!token) {
    return next('/login')
  }

  // 角色权限校验
  if (to.meta.role && user?.role !== to.meta.role) {
    return next(getHomeRoute(user?.role))
  }

  next()
})

export default router
