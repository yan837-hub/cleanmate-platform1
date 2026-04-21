<template>
  <el-container class="app-container">
    <el-header class="header">
      <div class="header-inner">
        <div class="brand">
          <span class="brand-text">CleanMate</span>
          <span class="brand-badge">保洁员端</span>
        </div>
        <el-menu mode="horizontal" :router="true" :default-active="$route.path" class="nav-menu">
          <el-menu-item index="/cleaner/home">工作台</el-menu-item>
          <el-menu-item index="/cleaner/grab">接单大厅</el-menu-item>
          <el-menu-item index="/cleaner/orders">
            <el-badge :value="pendingDispatchCount || ''" :hidden="!pendingDispatchCount" type="danger">
              我的订单
            </el-badge>
          </el-menu-item>
          <el-menu-item index="/cleaner/schedule">档期管理</el-menu-item>
          <el-menu-item index="/cleaner/income">收入明细</el-menu-item>
          <el-menu-item index="/cleaner/reviews">我的评价</el-menu-item>
        </el-menu>
        <div class="header-right">
          <el-badge :value="unreadCount || ''" :hidden="!unreadCount" type="danger" style="margin-right:16px">
            <el-button :icon="Bell" circle size="small" @click="$router.push('/cleaner/notifications')" />
          </el-badge>
          <el-dropdown trigger="click" @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="32" style="background:#C8D4C4;color:#4A6A44;font-weight:600">
                {{ userStore.userInfo?.nickname?.charAt(0) }}
              </el-avatar>
              <span class="username">{{ userStore.userInfo?.nickname }}</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="notifications">消息中心</el-dropdown-item>
                <el-dropdown-item command="profile">个人资料</el-dropdown-item>
                <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </el-header>

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
import { ElMessageBox, ElMessage, ElNotification } from 'element-plus'
import { Bell } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { getCleanerStats } from '@/api/order'
import { getUnreadCount, getNotifications } from '@/api/notification'

const router = useRouter()
const userStore = useUserStore()

const pendingDispatchCount = ref(0)
const unreadCount = ref(0)
let lastKnownCount = null

async function refreshBadge() {
  try {
    const data = await getCleanerStats()
    pendingDispatchCount.value = data.pendingDispatch ?? 0
  } catch {}
}

async function refreshUnread() {
  try {
    const count = await getUnreadCount()
    if (lastKnownCount === null) {
      lastKnownCount = count
    } else if (count > lastKnownCount) {
      try {
        const msgs = await getNotifications()
        const latest = msgs.find(m => m.isRead === 0)
        ElNotification({
          title: latest?.title ?? '您有新消息',
          message: latest?.content ?? '点击查看消息中心',
          type: 'info',
          duration: 6000,
          onClick: () => router.push('/cleaner/notifications'),
        })
      } catch {
        ElNotification({ title: '您有新消息', message: '点击查看消息中心', type: 'info', duration: 6000 })
      }
      lastKnownCount = count
    } else {
      lastKnownCount = count
    }
    unreadCount.value = count
  } catch {}
}

let badgeTimer = null
onMounted(() => {
  refreshBadge()
  refreshUnread()
  badgeTimer = setInterval(() => {
    refreshBadge()
    refreshUnread()
  }, 30000)
})
onUnmounted(() => clearInterval(badgeTimer))

function handleCommand(command) {
  if (command === 'notifications') {
    router.push('/cleaner/notifications')
  } else if (command === 'profile') {
    router.push('/cleaner/profile')
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
.app-container {
  min-height: 100vh;
  background: #F8F7F4;

  /* Element Plus 主色覆盖为莫兰迪鼠尾草绿 */
  --el-color-primary:         #8FA888;
  --el-color-primary-dark-2:  #7A9A72;
  --el-color-primary-light-3: #B8CCBA;
  --el-color-primary-light-5: #C8D8C8;
  --el-color-primary-light-7: #DAE6DA;
  --el-color-primary-light-8: #E4EEE4;
  --el-color-primary-light-9: #EDF4ED;
}

.header {
  background: #FEFEFE;
  border-bottom: 1px solid #EDE8DF;
  padding: 0;
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 1px 4px rgba(58,55,52,.05);
}

.header-inner {
  max-width: 1440px; margin: 0 auto; height: 60px;
  display: flex; align-items: center; gap: 24px;
  padding: 0 32px; box-sizing: border-box;
}

.brand {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}
.brand-text {
  font-size: 20px;
  font-weight: 700;
  color: #3A3734;
  letter-spacing: -0.5px;
}
.brand-badge {
  font-size: 11px;
  font-weight: 600;
  color: #8FA888;
  background: #EDF4ED;
  border-radius: 4px;
  padding: 2px 7px;
  line-height: 1.5;
}

.nav-menu { flex: 1; border-bottom: none; background: transparent !important; }
.header-right { margin-left: auto; display: flex; align-items: center; }

.user-info { display: flex; align-items: center; gap: 10px; cursor: pointer; }
.username { font-size: 15px; color: #5A5450; }

/* 保洁员端导航激活色：莫兰迪鼠尾草绿 */
:deep(.el-menu--horizontal > .el-menu-item.is-active) {
  border-bottom-color: #8FA888 !important;
  color: #8FA888 !important;
}
:deep(.el-menu--horizontal > .el-menu-item:not(.is-disabled):hover) {
  color: #8FA888 !important;
}
:deep(.el-menu--horizontal) {
  --el-menu-hover-bg-color: transparent;
  --el-menu-bg-color: transparent;
}
:deep(.el-menu--horizontal > .el-menu-item) {
  color: #5A5450;
  font-size: 15px !important;
}

.el-main-wrap {
  padding: 0 !important;
  background: #F8F7F4;
}
.main-content {
  max-width: 1440px;
  margin: 0 auto;
  padding: 28px 40px 40px;
  box-sizing: border-box;
  min-height: calc(100vh - 60px);
}
</style>
