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
        :default-openeds="['user-mgr', 'order-mgr', 'settings-mgr']"
        background-color="#1e293b"
        text-color="#94a3b8"
        active-text-color="#ffffff"
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

        <el-menu-item index="/admin/complaints">
          <el-icon><ChatDotRound /></el-icon>
          <span>投诉处理</span>
        </el-menu-item>

        <el-menu-item index="/admin/stats">
          <el-icon><TrendCharts /></el-icon>
          <span>数据统计</span>
        </el-menu-item>

        <el-sub-menu index="settings-mgr">
          <template #title>
            <el-icon><Setting /></el-icon>
            <span>系统设置</span>
          </template>
          <el-menu-item index="/admin/service-types">服务类型配置</el-menu-item>
          <el-menu-item index="/admin/settings">系统参数配置</el-menu-item>
        </el-sub-menu>

        <el-menu-item index="/admin/operation-logs">
          <el-icon><Document /></el-icon>
          <span>操作日志</span>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <!-- 右侧内容 -->
    <el-container>
      <el-header class="admin-header">
        <span class="page-title">{{ $route.meta.title || '管理后台' }}</span>
        <el-dropdown @command="handleCommand">
          <span class="user-info">
            <el-avatar :size="30" style="background:#3f3f46">
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
import { User, SetUp, Setting, Document } from '@element-plus/icons-vue'

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
.admin-container { min-height: 100vh; }

.sidebar {
  background: #1e293b;
  display: flex;
  flex-direction: column;
}

.sidebar-logo {
  padding: 20px 24px;
  color: #fff;
  font-size: 18px;
  font-weight: 700;
  border-bottom: 1px solid rgba(255,255,255,0.08);
  display: flex;
  flex-direction: column;
  letter-spacing: -0.3px;
}

.sidebar-logo small {
  font-size: 12px;
  color: #64748b;
  font-weight: 400;
  margin-top: 3px;
}

/* 管理端侧边栏活跃项高亮 */
:deep(.el-menu-item.is-active) {
  background-color: rgba(14,165,233,.15) !important;
  border-radius: 6px;
  color: #fff !important;
  border-left: 2px solid #0ea5e9;
}
:deep(.el-menu-item:hover) {
  background-color: rgba(255,255,255,.06) !important;
  border-radius: 6px;
}
:deep(.el-sub-menu__title:hover) {
  background-color: rgba(255,255,255,.06) !important;
}

.admin-header {
  background: #fff;
  border-bottom: 1px solid #e4e4e7;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  box-shadow: 0 1px 3px rgba(0,0,0,.04);
}

.page-title { font-size: 15px; font-weight: 600; color: #18181b; }

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-size: 14px;
  color: #3f3f46;
}

.admin-main { background: #f9fafb; padding: 24px; }
</style>
