<template>
  <el-container class="app-container">
    <!-- 顶部导航 -->
    <el-header class="header">
      <div class="header-inner">
        <span class="brand">CleanMate</span>
        <el-menu mode="horizontal" :router="true" :default-active="$route.path" class="nav-menu" active-text-color="#0ea5e9">
          <el-menu-item index="/customer/home">首页</el-menu-item>
          <el-menu-item index="/customer/book">立即预约</el-menu-item>
          <el-menu-item index="/customer/orders">我的订单</el-menu-item>
          <el-menu-item index="/customer/profile">个人中心</el-menu-item>
        </el-menu>
        <div class="header-right">
          <el-badge :value="unreadCount || ''" :hidden="!unreadCount" type="danger" style="margin-right:16px">
            <el-button :icon="Bell" circle size="small" @click="$router.push('/customer/notifications')" />
          </el-badge>
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="32" :src="userStore.userInfo?.avatarUrl" style="background:#0ea5e9">
                {{ userStore.userInfo?.nickname?.charAt(0) }}
              </el-avatar>
              <span class="username">{{ userStore.userInfo?.nickname }}</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="notifications">消息中心</el-dropdown-item>
                <el-dropdown-item command="profile">个人信息</el-dropdown-item>
                <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </el-header>

    <!-- 主内容区 -->
    <el-main class="el-main-wrap">
      <div class="main-content">
        <router-view />
      </div>
    </el-main>
  </el-container>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox, ElMessage } from 'element-plus'
import { Bell } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { getUnreadCount } from '@/api/notification'

const router = useRouter()
const userStore = useUserStore()

const unreadCount = ref(0)

async function refreshUnread() {
  try {
    unreadCount.value = await getUnreadCount()
  } catch {}
}

let unreadTimer = null
onMounted(() => {
  refreshUnread()
  unreadTimer = setInterval(refreshUnread, 30000)
})
onUnmounted(() => clearInterval(unreadTimer))

function handleCommand(command) {
  if (command === 'notifications') {
    router.push('/customer/notifications')
  } else if (command === 'profile') {
    router.push('/customer/profile')
  } else if (command === 'logout') {
    ElMessageBox.confirm('确认退出登录？', '提示', { type: 'warning' }).then(() => {
      userStore.logout()
      ElMessage.success('已退出登录')
      router.push('/login')
    })
  }
}
</script>

<style scoped>
.app-container { min-height: 100vh; background: #f9fafb; }

.header {
  background: #fff;
  border-bottom: 1px solid #e4e4e7;
  padding: 0;
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 1px 3px rgba(0,0,0,.06);
}

.header-inner {
  max-width: 1440px;
  margin: 0 auto;
  height: 60px;
  display: flex;
  align-items: center;
  gap: 24px;
  padding: 0 32px;
  box-sizing: border-box;
}

.brand {
  font-size: 20px;
  font-weight: 700;
  color: #18181b;
  flex-shrink: 0;
  letter-spacing: -0.5px;
}

.nav-menu { flex: 1; border-bottom: none; }
.header-right { margin-left: auto; }

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}
.username { font-size: 14px; color: #3f3f46; }

/* 顾客端导航激活色：天蓝 */
:deep(.el-menu--horizontal > .el-menu-item.is-active) {
  border-bottom-color: #0ea5e9 !important;
  color: #0ea5e9 !important;
}
:deep(.el-menu--horizontal > .el-menu-item:not(.is-disabled):hover) {
  color: #0ea5e9 !important;
}
:deep(.el-menu--horizontal) {
  --el-menu-hover-bg-color: transparent;
}

.el-main-wrap {
  padding: 0 !important;
  background: #f9fafb;
}
.main-content {
  max-width: 1440px;
  margin: 0 auto;
  padding: 28px 40px 40px;
  box-sizing: border-box;
  min-height: calc(100vh - 60px);
}
</style>
