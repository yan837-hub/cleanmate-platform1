<template>
  <el-card>
    <template #header>
      <div style="display:flex;justify-content:space-between;align-items:center">
        <span style="font-size:16px;font-weight:600">消息中心</span>
        <el-button v-if="hasUnread" link type="primary" @click="doReadAll">全部已读</el-button>
      </div>
    </template>

    <div v-loading="loading">
      <el-empty v-if="!loading && list.length === 0" description="暂无消息" :image-size="80" />

      <div v-for="item in list" :key="item.id" class="notif-item" :class="{ unread: item.isRead === 0 }" @click="doRead(item)">
        <div class="notif-dot" v-if="item.isRead === 0"></div>
        <div class="notif-body">
          <div class="notif-title">{{ item.title }}</div>
          <div class="notif-content">{{ item.content }}</div>
          <div class="notif-time">{{ formatTime(item.createdAt) }}</div>
        </div>
      </div>
    </div>
  </el-card>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getNotifications, markAllRead, markRead } from '@/api/notification'

const loading = ref(false)
const list = ref([])

const hasUnread = computed(() => list.value.some(n => n.isRead === 0))

async function load() {
  loading.value = true
  try {
    list.value = await getNotifications()
  } catch {
    ElMessage.error('加载消息失败')
  } finally {
    loading.value = false
  }
}

async function doReadAll() {
  await markAllRead()
  list.value.forEach(n => { n.isRead = 1 })
}

async function doRead(item) {
  if (item.isRead === 0) {
    item.isRead = 1
    await markRead(item.id).catch(() => {})
  }
}

function formatTime(t) {
  if (!t) return ''
  const s = String(t).replace('T', ' ').substring(0, 16)
  // 转为 "今天 HH:mm" 或完整日期
  const d = new Date(t)
  const now = new Date()
  if (d.toDateString() === now.toDateString()) {
    return '今天 ' + String(d.getHours()).padStart(2, '0') + ':' + String(d.getMinutes()).padStart(2, '0')
  }
  return s
}

onMounted(load)
</script>

<style scoped>
.notif-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 14px 4px;
  border-bottom: 1px solid #EDE8DF;
  cursor: pointer;
  transition: background 0.15s;
  border-radius: 4px;
}
.notif-item:last-child { border-bottom: none; }
.notif-item:hover { background: #F5F2EE; }
.notif-item.unread { background: #EEF7F0; border-left: 3px solid #2D4A33; padding-left: 13px; }
.notif-item.unread:hover { background: #D8E6DB; }

.notif-dot {
  width: 8px; height: 8px; border-radius: 50%;
  background: #2D4A33; flex-shrink: 0; margin-top: 6px;
}

.notif-body { flex: 1; min-width: 0; }
.notif-title { font-size: 14px; font-weight: 600; color: #1a1a1a; margin-bottom: 4px; }
.notif-item.unread .notif-title { color: #2D4A33; }
.notif-content { font-size: 13px; color: #5A5450; margin-bottom: 6px; line-height: 1.5; }
.notif-time { font-size: 12px; color: #B8B0A8; }
</style>
