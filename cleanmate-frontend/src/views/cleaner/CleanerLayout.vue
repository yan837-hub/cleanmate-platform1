<template>
  <el-container class="app-container">
    <el-header class="header">
      <div class="header-inner">
        <span class="brand">CleanMate <small>保洁员端</small></span>
        <el-menu mode="horizontal" :router="true" :default-active="$route.path" class="nav-menu" active-text-color="#10b981">
          <el-menu-item index="/cleaner/home">工作台</el-menu-item>
          <el-menu-item index="/cleaner/grab">抢单池</el-menu-item>
          <el-menu-item index="/cleaner/orders">
            <el-badge :value="pendingDispatchCount || ''" :hidden="!pendingDispatchCount" type="danger">
              我的订单
            </el-badge>
          </el-menu-item>
          <el-menu-item index="/cleaner/schedule">档期管理</el-menu-item>
          <el-menu-item index="/cleaner/income">收入明细</el-menu-item>
        </el-menu>
        <div class="header-right">
          <!-- 消息铃铛 -->
          <el-badge :value="unreadCount || ''" :hidden="!unreadCount" type="danger" style="margin-right:16px">
            <el-button :icon="Bell" circle size="small" @click="$router.push('/cleaner/notifications')" />
          </el-badge>
          <el-dropdown trigger="click" @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="32">{{ userStore.userInfo?.nickname?.charAt(0) }}</el-avatar>
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
// null 表示首次加载，不弹窗；之后用来检测是否有新消息
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
      // 首次加载：只记录基准值，不弹窗
      lastKnownCount = count
    } else if (count > lastKnownCount) {
      // 有新消息到来：弹出通知，展示最新一条内容
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
  max-width: 1440px; margin: 0 auto; height: 60px;
  display: flex; align-items: center; gap: 24px;
  padding: 0 32px; box-sizing: border-box;
}
.brand { font-size: 20px; font-weight: 700; color: #18181b; flex-shrink: 0; letter-spacing: -0.5px; }
.brand small { font-size: 13px; color: #10b981; font-weight: 500; margin-left: 2px; }
.nav-menu { flex: 1; border-bottom: none; }
.header-right { margin-left: auto; }
.user-info { display: flex; align-items: center; gap: 8px; cursor: pointer; }
.username { font-size: 14px; color: #3f3f46; }

/* 保洁员端导航激活色：翠绿 */
:deep(.el-menu--horizontal > .el-menu-item.is-active) {
  border-bottom-color: #10b981 !important;
  color: #10b981 !important;
}
:deep(.el-menu--horizontal > .el-menu-item:not(.is-disabled):hover) {
  color: #10b981 !important;
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
