<template>
  <div class="grab-wrap">
    <!-- 顶部栏 -->
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">抢单池</h2>
        <p class="page-sub" v-if="total > 0">
          当前 <b class="count-hl">{{ total }}</b> 个订单可抢，先到先得
        </p>
        <p class="page-sub" v-else>暂无待抢订单，系统每30秒自动刷新</p>
      </div>
      <div class="header-right">
        <div class="auto-refresh-tip">⟳ 每30秒自动刷新</div>
        <el-button :icon="Refresh" @click="loadPool" :loading="loading" type="primary" round size="default">
          立即刷新
        </el-button>
      </div>
    </div>

    <!-- 空状态 -->
    <div v-if="!loading && list.length === 0" class="empty-wrap">
      <el-empty description="暂无待抢订单，稍后刷新试试" :image-size="120" />
    </div>

    <!-- 订单列表 -->
    <div v-else class="order-list" v-loading="loading">
      <div v-for="order in list" :key="order.id" class="order-card">
        <div class="card-status-bar"></div>
        <div class="card-inner">
          <!-- 左：类型图标 -->
          <div class="card-icon">{{ svcEmoji(order.serviceTypeName) }}</div>

          <!-- 中：信息区 -->
          <div class="card-body">
            <div class="card-top-row">
              <span class="svc-type-badge">{{ order.serviceTypeName }}</span>
              <span class="order-no-text">{{ order.orderNo }}</span>
            </div>
            <div class="card-meta-row">
              <span class="meta-item">
                <el-icon size="13"><Clock /></el-icon>
                预约：{{ formatTime(order.appointTime) }}
              </span>
              <template v-if="order.planDuration">
                <span class="meta-sep">·</span>
                <span class="meta-item">
                  <el-icon size="13"><Timer /></el-icon>
                  时长：{{ order.planDuration }} 分钟
                </span>
              </template>
            </div>
            <div class="card-addr-row">
              <el-icon size="13" color="#2A6B47"><Location /></el-icon>
              <span>{{ order.addressSnapshot }}</span>
            </div>
            <div v-if="order.remark" class="card-remark-row">
              <el-icon size="13"><ChatDotRound /></el-icon>
              <span>{{ order.remark }}</span>
            </div>
          </div>

          <!-- 右：距离 + 收入 + 按钮 -->
          <div class="card-right">
            <div v-if="order.distanceKm != null" class="distance-badge">
              <el-icon size="12"><Location /></el-icon>
              {{ order.distanceKm }} km
            </div>
            <div class="income-block">
              <div class="income-label">预计到手</div>
              <div class="income-fee">¥{{ order.estimatedIncome ?? order.estimateFee ?? '--' }}</div>
              <div class="origin-fee" v-if="order.estimatedIncome != null">
                订单 ¥{{ order.estimateFee }}
              </div>
            </div>
            <button
              class="grab-action-btn"
              :disabled="grabbingId === order.id"
              @click="handleGrab(order)"
            >
              <span v-if="grabbingId === order.id">处理中...</span>
              <span v-else>立即抢单</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="pagination" v-if="total > pageSize">
      <el-pagination
        v-model:current-page="currentPage"
        :page-size="pageSize"
        :total="total"
        layout="prev, pager, next"
        background
        @current-change="loadPool"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Refresh, ShoppingBag, Clock, Timer, Location, ChatDotRound } from '@element-plus/icons-vue'
import { getGrabPool, grabOrder } from '@/api/order'
import { formatTime } from '@/utils/time'

const list = ref([])
const total = ref(0)
const currentPage = ref(1)
const pageSize = 10
const loading = ref(false)
const grabbingId = ref(null)

let timer = null

function svcEmoji(name) {
  if (!name) return '🧹'
  if (name.includes('日常')) return '🏠'
  if (name.includes('深度')) return '✨'
  if (name.includes('开荒')) return '🏗️'
  if (name.includes('家电') || name.includes('油烟')) return '🔌'
  if (name.includes('玻璃')) return '🪟'
  if (name.includes('地板')) return '🌿'
  return '🧹'
}

async function loadPool() {
  loading.value = true
  try {
    const res = await getGrabPool({ current: currentPage.value, size: pageSize })
    list.value = res.records
    total.value = res.total
  } finally {
    loading.value = false
  }
}

async function handleGrab(order) {
  try {
    await ElMessageBox.confirm(
      `确认抢单？\n服务：${order.serviceTypeName}\n预约时间：${formatTime(order.appointTime)}`,
      '抢单确认',
      { confirmButtonText: '确认抢单', cancelButtonText: '取消', type: 'warning' }
    )
  } catch { return }
  grabbingId.value = order.id
  try {
    await grabOrder(order.id)
    ElMessage.success('抢单成功，订单已进入我的订单')
    list.value = list.value.filter(o => o.id !== order.id)
    total.value--
  } catch (e) {
    ElMessage.error(e?.message || '抢单失败，请稍后重试')
    await loadPool()
  } finally {
    grabbingId.value = null
  }
}

onMounted(() => {
  loadPool()
  timer = setInterval(loadPool, 30000)
})

onUnmounted(() => {
  clearInterval(timer)
})
</script>

<style scoped>
.grab-wrap {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: calc(100vh - 60px - 68px);
}

/* ── 顶部栏 ── */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 16px;
  padding: 18px 24px;
}
.header-left {}
.page-title { font-size: 22px; font-weight: 800; color: #1C3D2A; margin: 0 0 4px; }
.page-sub { font-size: 13px; color: #6B7280; margin: 0; }
.count-hl { color: #2A6B47; font-size: 16px; font-weight: 800; }
.header-right { display: flex; align-items: center; gap: 12px; }
.auto-refresh-tip { font-size: 12px; color: #9CA3AF; }

/* ── 空状态 ── */
.empty-wrap {
  flex: 1;
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 360px;
}

/* ── 订单列表 ── */
.order-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.order-card {
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 16px;
  overflow: hidden;
  transition: transform .18s, box-shadow .18s;
  position: relative;
}
.order-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 28px rgba(0,0,0,.09);
  border-color: #6EE7A0;
}
.card-status-bar {
  height: 4px;
  background: linear-gradient(90deg, #2A6B47, #4ADE80);
}
.card-inner {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 20px 24px;
}

/* 类型图标 */
.card-icon {
  width: 56px; height: 56px; border-radius: 14px;
  background: #E6F4EE;
  display: flex; align-items: center; justify-content: center;
  font-size: 26px; flex-shrink: 0;
}

/* 信息区 */
.card-body { flex: 1; min-width: 0; }
.card-top-row {
  display: flex; align-items: center; gap: 10px; margin-bottom: 10px;
}
.svc-type-badge {
  font-size: 12px; font-weight: 700; color: #2A6B47;
  background: #DCFCE7; border-radius: 20px; padding: 3px 12px;
}
.order-no-text { font-size: 12px; color: #9CA3AF; }
.card-meta-row {
  display: flex; align-items: center; gap: 6px;
  flex-wrap: wrap; margin-bottom: 8px;
  font-size: 13px; color: #374151;
}
.meta-item { display: flex; align-items: center; gap: 4px; }
.meta-item .el-icon { color: #2A6B47; }
.meta-sep { color: #D1D5DB; }
.card-addr-row {
  display: flex; align-items: flex-start;
  gap: 5px; font-size: 13px; color: #4B5563; line-height: 1.5;
}
.card-remark-row {
  display: flex; align-items: flex-start;
  gap: 5px; font-size: 12px; color: #9CA3AF; margin-top: 6px;
}

/* 右侧 */
.card-right {
  display: flex; flex-direction: column;
  align-items: center; gap: 12px; flex-shrink: 0;
  min-width: 150px;
}
.distance-badge {
  display: flex; align-items: center; gap: 4px;
  font-size: 12px; color: #6B7280;
  background: #F3F4F6; padding: 4px 12px; border-radius: 20px;
}
.income-block { text-align: center; }
.income-label { font-size: 11px; color: #9CA3AF; margin-bottom: 4px; }
.income-fee { font-size: 28px; font-weight: 800; color: #D97706; white-space: nowrap; line-height: 1; }
.origin-fee { font-size: 11px; color: #9CA3AF; margin-top: 3px; }

.grab-action-btn {
  background: linear-gradient(135deg, #2A6B47, #1B4D32);
  color: #fff; border: none;
  border-radius: 50px;
  padding: 11px 0; width: 130px;
  font-size: 15px; font-weight: 700;
  cursor: pointer; transition: all .18s;
  box-shadow: 0 4px 14px rgba(42,107,71,.40);
}
.grab-action-btn:hover { box-shadow: 0 6px 20px rgba(42,107,71,.55); transform: scale(1.03); }
.grab-action-btn:disabled { opacity: .55; cursor: not-allowed; transform: none; }

/* ── 分页 ── */
.pagination { display: flex; justify-content: center; padding: 8px 0; }
</style>
