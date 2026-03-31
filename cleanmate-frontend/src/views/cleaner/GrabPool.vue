<template>
  <div>
    <!-- 页面标题栏 -->
    <div class="page-header">
      <div>
        <h2 class="page-title">抢单池</h2>
        <p class="page-sub" v-if="total > 0">共 <b>{{ total }}</b> 个可抢订单，先到先得</p>
        <p class="page-sub" v-else>暂无待抢订单，稍后刷新试试</p>
      </div>
      <el-button :icon="Refresh" @click="loadPool" :loading="loading" round>刷新列表</el-button>
    </div>

    <el-empty v-if="!loading && list.length === 0" description="暂无待抢订单" :image-size="100" style="margin-top:40px;background:#fff;border-radius:12px;padding:48px 0" />

    <div v-else class="order-list" v-loading="loading">
      <el-card
        v-for="order in list"
        :key="order.id"
        shadow="hover"
        class="order-card"
      >
        <div class="card-inner">
          <!-- 左：标题 + 信息 -->
          <div class="card-left">
            <div class="card-top">
              <el-tag type="warning" size="small" round>待派单</el-tag>
              <span class="order-no">{{ order.orderNo }}</span>
            </div>
            <div class="card-meta">
              <div class="meta-item">
                <el-icon><ShoppingBag /></el-icon>
                <span>{{ order.serviceTypeName }}</span>
              </div>
              <div class="meta-sep">|</div>
              <div class="meta-item">
                <el-icon><Clock /></el-icon>
                <span>预约：{{ formatTime(order.appointTime) }}</span>
              </div>
              <template v-if="order.planDuration">
                <div class="meta-sep">|</div>
                <div class="meta-item">
                  <el-icon><Timer /></el-icon>
                  <span>时长：{{ order.planDuration }} 分钟</span>
                </div>
              </template>
            </div>
            <div class="card-addr">
              <el-icon><Location /></el-icon>
              <span>{{ order.addressSnapshot }}</span>
            </div>
            <div class="card-remark" v-if="order.remark">
              <el-icon><ChatDotRound /></el-icon>
              <span>{{ order.remark }}</span>
            </div>
          </div>

          <!-- 右：距离 + 收入 + 按钮 -->
          <div class="card-right">
            <div v-if="order.distanceKm != null" class="distance-badge">
              📍 {{ order.distanceKm }} km
            </div>
            <div class="income-wrap">
              <div class="income-label">预计到手</div>
              <div class="income-fee">
                ¥ {{ order.estimatedIncome ?? order.estimateFee ?? '--' }}
              </div>
              <div class="origin-fee" v-if="order.estimatedIncome != null">
                订单金额 ¥{{ order.estimateFee }}
              </div>
            </div>
            <el-button
              type="primary"
              size="large"
              round
              :loading="grabbingId === order.id"
              @click="handleGrab(order)"
              style="width: 130px"
            >
              立即抢单
            </el-button>
          </div>
        </div>
      </el-card>
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
  await ElMessageBox.confirm(
    `确认抢单？\n服务：${order.serviceTypeName}\n预约时间：${formatTime(order.appointTime)}`,
    '抢单确认',
    { confirmButtonText: '确认抢单', cancelButtonText: '取消', type: 'warning' }
  )
  grabbingId.value = order.id
  try {
    await grabOrder(order.id)
    ElMessage.success('抢单成功，订单已进入我的订单')
    list.value = list.value.filter(o => o.id !== order.id)
    total.value--
  } catch (e) {
    // 时段冲突或已被抢，刷新列表
    await loadPool()
  } finally {
    grabbingId.value = null
  }
}


onMounted(() => {
  loadPool()
  // 每30秒自动刷新
  timer = setInterval(loadPool, 30000)
})

onUnmounted(() => {
  clearInterval(timer)
})
</script>

<style scoped>
/* 页面标题 */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.page-title { font-size: 20px; font-weight: 700; color: #111; margin: 0 0 4px; }
.page-sub { font-size: 13px; color: #6b7280; margin: 0; }
.page-sub b { color: #059669; }

/* 单列全宽列表 */
.order-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.order-card {
  border-left: 4px solid #f59e0b;
  border-radius: 10px;
  transition: transform .18s, box-shadow .18s;
}
.order-card:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,.1); }

/* 卡片内部横向布局 */
.card-inner {
  display: flex;
  align-items: center;
  gap: 24px;
}
.card-left { flex: 1; min-width: 0; }
.card-right {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  flex-shrink: 0;
}

.card-top {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}
.order-no { font-size: 12px; color: #9ca3af; }

/* 横向 meta 信息行 */
.card-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  margin-bottom: 10px;
}
.meta-item {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 14px;
  color: #374151;
}
.meta-item .el-icon { color: #5b21b6; font-size: 15px; }
.meta-sep { color: #d1d5db; font-size: 12px; }

.card-addr {
  display: flex;
  align-items: flex-start;
  gap: 6px;
  font-size: 13px;
  color: #6b7280;
  line-height: 1.5;
}
.card-addr .el-icon { color: #5b21b6; flex-shrink: 0; margin-top: 2px; }

.card-remark {
  display: flex;
  align-items: flex-start;
  gap: 6px;
  font-size: 13px;
  color: #9ca3af;
  margin-top: 6px;
}
.card-remark .el-icon { flex-shrink: 0; margin-top: 2px; }

.distance-badge {
  font-size: 13px;
  color: #6b7280;
  background: #f3f4f6;
  padding: 2px 10px;
  border-radius: 12px;
}
.income-wrap {
  text-align: center;
}
.income-label {
  font-size: 11px;
  color: #9ca3af;
  margin-bottom: 2px;
}
.income-fee {
  font-size: 26px;
  font-weight: 700;
  color: #059669;
  white-space: nowrap;
}
.origin-fee {
  font-size: 11px;
  color: #9ca3af;
  margin-top: 2px;
}

.pagination {
  margin-top: 28px;
  display: flex;
  justify-content: center;
}
</style>
