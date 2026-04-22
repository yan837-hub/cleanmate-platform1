<template>
  <el-container class="admin-container">
    <!-- 侧边栏 -->
    <el-aside width="220px" class="sidebar">
      <div class="sidebar-logo">
        <span>CleanMate</span>
        <small>管理后台</small>
      </div>
      <el-menu
        :router="true"
        :default-active="$route.path"
        :default-openeds="['order-mgr', 'user-mgr']"
        background-color="#FAFAF5"
        text-color="#9CA3AF"
        active-text-color="#2D4A33"
      >
        <el-menu-item index="/admin/dashboard">
          <el-icon><DataAnalysis /></el-icon>
          <span>数据概览</span>
        </el-menu-item>

        <el-sub-menu index="order-mgr">
          <template #title>
            <el-icon><List /></el-icon>
            <span>订单管理</span>
          </template>
          <el-menu-item index="/admin/orders">全部订单</el-menu-item>
          <el-menu-item index="/admin/dispatch">派单调度</el-menu-item>
        </el-sub-menu>

        <el-sub-menu index="user-mgr">
          <template #title>
            <el-icon><User /></el-icon>
            <span>用户管理</span>
          </template>
          <el-menu-item index="/admin/customers">顾客管理</el-menu-item>
          <el-menu-item index="/admin/audit/cleaners">保洁员管理</el-menu-item>
          <el-menu-item index="/admin/audit/companies">公司管理</el-menu-item>
        </el-sub-menu>

        <el-sub-menu index="service-mgr">
          <template #title>
            <el-icon><Tickets /></el-icon>
            <span>服务管理</span>
          </template>
          <el-menu-item index="/admin/complaints">投诉处理</el-menu-item>
          <el-menu-item index="/admin/reviews">评价管理</el-menu-item>
          <el-menu-item index="/admin/service-types">服务类型配置</el-menu-item>
        </el-sub-menu>

        <el-menu-item index="/admin/stats">
          <el-icon><TrendCharts /></el-icon>
          <span>数据统计</span>
        </el-menu-item>

        <el-sub-menu index="ops-mgr">
          <template #title>
            <el-icon><Tools /></el-icon>
            <span>运维管理</span>
          </template>
          <el-menu-item index="/admin/settings">系统参数配置</el-menu-item>
          <el-menu-item index="/admin/operation-logs">操作日志</el-menu-item>
          <el-menu-item index="/admin/abnormal-checkins">异常管理</el-menu-item>
        </el-sub-menu>
      </el-menu>
    </el-aside>

    <!-- 右侧内容 -->
    <el-container style="flex-direction: column; height: 100vh; overflow: hidden;">
      <el-header class="admin-header">
        <span class="page-title">{{ $route.meta.title || '管理后台' }}</span>
        <el-dropdown @command="handleCommand">
          <span class="user-info">
            <el-avatar :size="30" style="background:#7BA888">
              {{ userStore.userInfo?.nickname?.charAt(0) }}
            </el-avatar>
            <span>{{ userStore.userInfo?.nickname }}</span>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="logout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </el-header>

      <el-main class="admin-main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { ElMessageBox, ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'
import { User, Tickets, Tools } from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()

function handleCommand(command) {
  if (command === 'logout') {
    ElMessageBox.confirm('确认退出？', '提示', { type: 'warning' }).then(() => {
      userStore.logout()
      ElMessage.success('已退出登录')
      router.push('/login')
    })
  }
}
</script>

<style scoped>
.admin-container {
  height: 100vh;
  overflow: hidden;
}

.sidebar {
  background: #FAFAF5;
  border-right: 1px solid #F0F0EB;
  display: flex;
  flex-direction: column;
  height: 100vh;
  overflow-y: auto;
  position: sticky;
  top: 0;
  flex-shrink: 0;
}

.sidebar-logo {
  padding: 20px 24px;
  color: #4A4A4A;
  font-size: 18px;
  font-weight: 700;
  border-bottom: 1px solid #F0F0EB;
  display: flex;
  flex-direction: column;
  letter-spacing: -0.3px;
  font-family: -apple-system, BlinkMacSystemFont, 'PingFang SC', 'Microsoft YaHei', 'Segoe UI', sans-serif;
}

.sidebar-logo small {
  font-size: 12px;
  color: #9CA3AF;
  font-weight: 400;
  margin-top: 3px;
  letter-spacing: 0.2px;
}

/* 侧边栏菜单 */
:deep(.el-menu) {
  border-right: none !important;
  padding: 8px !important;
}
:deep(.el-menu-item) {
  border-radius: 7px !important;
  margin: 2px 0 !important;
  height: 42px !important;
  line-height: 42px !important;
  font-size: 14px !important;
}
:deep(.el-menu-item.is-active) {
  background-color: #C8D4C4 !important;
  color: #2D4A33 !important;
  font-weight: 600;
  border-left: 2px solid #56896A;
}
:deep(.el-menu-item:hover) {
  background-color: #E4EDDF !important;
  color: #2D4A33 !important;
}
:deep(.el-sub-menu__title) {
  border-radius: 7px !important;
  margin: 2px 0 !important;
  height: 42px !important;
  line-height: 42px !important;
  font-size: 14px !important;
  color: #9CA3AF !important;
}
:deep(.el-sub-menu__title:hover) {
  background-color: #E4EDDF !important;
  color: #2D4A33 !important;
}
:deep(.el-menu--inline) {
  background-color: #FAFAF5 !important;
}
:deep(.el-menu--inline .el-menu-item) {
  padding-left: 48px !important;
  font-size: 13px !important;
  color: #9CA3AF !important;
}

.admin-header {
  background: #FFFFFF;
  border-bottom: 1px solid #F0F0EB;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  box-shadow: 0 1px 4px rgba(74, 74, 74, 0.04);
}

.page-title {
  font-size: 16px;
  font-weight: 600;
  color: #4A4A4A;
  font-family: -apple-system, BlinkMacSystemFont, 'PingFang SC', 'Microsoft YaHei', 'Segoe UI', sans-serif;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-size: 14px;
  color: #9CA3AF;
  font-family: -apple-system, BlinkMacSystemFont, 'PingFang SC', 'Microsoft YaHei', 'Segoe UI', sans-serif;
}

.admin-main {
  background: #FAFAF5;
  padding: 24px;
  overflow-y: auto;
  height: calc(100vh - 60px);
}
</style>
