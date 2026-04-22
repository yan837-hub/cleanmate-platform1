<template>
  <el-container class="app-container">
    <!-- 顶部导航 -->
    <el-header class="header">
      <div class="header-inner">
        <span class="brand">CleanMate</span>
        <el-menu mode="horizontal" :router="true" :default-active="$route.path" class="nav-menu">
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
              <el-avatar :size="32" :src="userStore.userInfo?.avatarUrl" style="background:#A3BDA9;color:#2D4A33">
                {{ userStore.userInfo?.nickname?.charAt(0) }}
              </el-avatar>
              <span class="username">{{ userStore.userInfo?.nickname }}</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
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
import { ElMessageBox, ElMessage, ElNotification } from 'element-plus'
import { Bell } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { getUnreadCount, getNotifications } from '@/api/notification'

const router = useRouter()
const userStore = useUserStore()

const unreadCount = ref(0)
let lastKnownCount = null

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
          onClick: () => router.push('/customer/notifications'),
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

let unreadTimer = null
onMounted(() => {
  refreshUnread()
  unreadTimer = setInterval(refreshUnread, 30000)
})
onUnmounted(() => clearInterval(unreadTimer))

function handleCommand(command) {
  if (command === 'logout') {
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

  /* Element Plus 主色覆盖为墨绿，作用于所有顾客端子页面 */
  --el-color-primary:         #2D4A33;
  --el-color-primary-dark-2:  #1F3324;
  --el-color-primary-light-3: #4A6B52;
  --el-color-primary-light-5: #6B8C73;
  --el-color-primary-light-7: #A3BDA9;
  --el-color-primary-light-8: #C8D8CB;
  --el-color-primary-light-9: #E8F0EA;
}

.header {
  background: #FEFEFE;
  border-bottom: 1px solid #EDE8DF;
  padding: 0;
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 1px 4px rgba(58,55,52,.06);
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
  color: #2D4A33;
  flex-shrink: 0;
  letter-spacing: -0.5px;
}

.nav-menu { flex: 1; border-bottom: none; background: transparent !important; }
.header-right { margin-left: auto; }

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}
.username { font-size: 15px; color: #5A5450; }

/* 顾客端导航激活色：墨绿 */
:deep(.el-menu--horizontal > .el-menu-item.is-active) {
  border-bottom-color: #2D4A33 !important;
  color: #2D4A33 !important;
}
:deep(.el-menu--horizontal > .el-menu-item:not(.is-disabled):hover) {
  color: #2D4A33 !important;
}
:deep(.el-menu--horizontal) {
  --el-menu-hover-bg-color: transparent;
  --el-menu-bg-color: transparent;
}
:deep(.el-menu--horizontal > .el-menu-item) {
  color: #5A5450;
  font-size: 15px !important;
}
:deep(.el-avatar) {
  background: #A3BDA9 !important;
  color: #2D4A33 !important;
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
