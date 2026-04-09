<template>
  <div class="dispatch-page">
    <!-- 左侧：待处理订单列表 -->
    <div class="left-panel">
      <div class="panel-header">
        <span class="panel-title">待处理订单</span>
        <el-button size="small" :icon="Refresh" @click="loadOrders" :loading="loadingOrders">刷新</el-button>
      </div>

      <el-scrollbar class="order-scroll">
        <div v-if="loadingOrders" class="loading-wrap">
          <el-skeleton :rows="4" animated />
        </div>
        <el-empty v-else-if="orders.length === 0" description="暂无待派单订单" :image-size="80" />
        <div
          v-for="order in orders"
          :key="order.id"
          class="order-card"
          :class="{ active: selectedOrder?.id === order.id }"
          @click="selectOrder(order)"
        >
          <div class="card-top">
            <span class="svc-name">{{ order.serviceTypeName }}</span>
            <el-tag :type="sourceTagType(order.source)" size="small" effect="light">
              {{ sourceLabel(order.source) }}
            </el-tag>
          </div>
          <div class="card-row">
            <el-icon><Clock /></el-icon>
            <span>{{ fmt(order.appointTime) }}</span>
          </div>
          <div class="card-row">
            <el-icon><Location /></el-icon>
            <span class="ellipsis">{{ order.addressSnapshot }}</span>
          </div>
          <div class="card-bottom">
            <span class="fee">¥{{ order.estimateFee }}</span>
            <el-tag :type="order.status === 1 ? 'warning' : 'danger'" size="small">
              {{ order.status === 1 ? '待派单' : '超时待处理' }}
            </el-tag>
          </div>
        </div>
      </el-scrollbar>

      <div v-if="total > pageSize" class="pagination-wrap">
        <el-pagination
          small
          background
          layout="prev, pager, next"
          :total="total"
          :page-size="pageSize"
          v-model:current-page="currentPage"
          @current-change="loadOrders"
        />
      </div>
    </div>

    <!-- 右侧：候选保洁员 -->
    <div class="right-panel">
      <!-- 未选中订单时的空状态 -->
      <div v-if="!selectedOrder" class="empty-hint">
        <el-empty description="请从左侧点击一个订单，查看候选保洁员" :image-size="80" />
      </div>

      <template v-else>
        <!-- 订单摘要 -->
        <div class="order-summary">
          <div class="summary-header">
            <span class="summary-title">{{ selectedOrder.serviceTypeName }}</span>
            <el-tag :type="selectedOrder.status === 1 ? 'warning' : 'danger'" size="small">
              {{ selectedOrder.status === 1 ? '待派单' : '超时待处理' }}
            </el-tag>
          </div>
          <div class="summary-row">
            <span><el-icon style="vertical-align:-2px"><Clock /></el-icon> {{ fmt(selectedOrder.appointTime) }}</span>
            <span>预估费用：<strong style="color:#ef4444">¥{{ selectedOrder.estimateFee }}</strong></span>
          </div>
          <div class="summary-addr">
            <el-icon style="vertical-align:-2px"><Location /></el-icon>
            {{ selectedOrder.addressSnapshot }}
          </div>
          <div class="summary-footer">
            <span class="summary-customer">顾客：{{ selectedOrder.customerNickname || '-' }}</span>
            <el-button
              size="small"
              type="info"
              plain
              :loading="autoDispatchLoading"
              @click="doAutoDispatch"
            >自动派单</el-button>
          </div>
        </div>

        <!-- 候选保洁员标题 -->
        <div class="candidate-header">
          <span class="panel-title">候选保洁员</span>
          <el-button size="small" :icon="Refresh" circle @click="loadCandidates" :loading="loadingCandidates" />
        </div>

        <!-- 候选列表 -->
        <el-scrollbar class="candidate-scroll">
          <div v-if="loadingCandidates" class="loading-wrap">
            <el-skeleton :rows="3" animated />
          </div>
          <el-empty
            v-else-if="candidates.length === 0"
            description="暂无合适保洁员，可尝试调整预约时间"
            :image-size="80"
          />
          <div v-for="c in candidates" :key="c.userId" class="cleaner-card">
            <div class="cleaner-main">
              <el-avatar :size="44" style="background:#5b21b6;flex-shrink:0;font-size:18px">
                {{ (c.realName || '?').charAt(0) }}
              </el-avatar>
              <div class="cleaner-info">
                <div class="cleaner-name-row">
                  <span class="cleaner-name">{{ c.realName }}</span>
                  <el-tag size="small" :type="c.companyName === '个人' ? 'info' : 'success'" effect="light">
                    {{ c.companyName }}
                  </el-tag>
                  <el-tag
                    size="small"
                    :type="c.timeFeasible ? 'success' : 'warning'"
                    effect="light"
                    style="margin-left:4px"
                  >{{ c.scheduleStatus }}</el-tag>
                </div>
                <div class="cleaner-meta">
                  <span class="meta-item"><el-icon><Star /></el-icon> {{ c.avgScore != null ? Number(c.avgScore).toFixed(1) : '-' }}</span>
                  <span class="meta-item"><el-icon><Location /></el-icon> {{ c.distanceKm != null ? c.distanceKm.toFixed(1) : '-' }} km</span>
                  <span class="meta-item"><el-icon><List /></el-icon> 今日 {{ c.todayOrderCount }} 单</span>
                </div>
                <div v-if="c.prevOrderAddress" class="prev-addr">
                  上一单：{{ c.prevOrderAddress }}
                </div>
              </div>
            </div>
            <el-button type="primary" size="small" @click="openConfirm(c)">指派</el-button>
          </div>
        </el-scrollbar>
      </template>
    </div>

    <!-- 确认指派弹窗 -->
    <el-dialog v-model="confirmVisible" title="确认指派" width="420px" :close-on-click-modal="false">
      <div class="confirm-body">
        <el-descriptions :column="1" border size="small">
          <el-descriptions-item label="保洁员">{{ confirmTarget?.realName }}</el-descriptions-item>
          <el-descriptions-item label="所属">{{ confirmTarget?.companyName }}</el-descriptions-item>
          <el-descriptions-item label="服务类型">{{ selectedOrder?.serviceTypeName }}</el-descriptions-item>
          <el-descriptions-item label="预约时间">{{ fmt(selectedOrder?.appointTime) }}</el-descriptions-item>
          <el-descriptions-item label="服务地址">{{ selectedOrder?.addressSnapshot }}</el-descriptions-item>
        </el-descriptions>
        <el-input
          v-model="dispatchRemark"
          placeholder="派单备注（可选）"
          style="margin-top:14px"
          maxlength="100"
          show-word-limit
        />
      </div>
      <template #footer>
        <el-button @click="confirmVisible = false">取消</el-button>
        <el-button type="primary" :loading="dispatching" @click="doManualDispatch">确认指派</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Refresh, Clock, Location, Star, List } from '@element-plus/icons-vue'
import { getPendingOrders, getDispatchCandidates, manualDispatch, autoDispatch } from '@/api/admin'

const route = useRoute()

// ── 左侧状态 ──────────────────────────────────────────
const orders      = ref([])
const total       = ref(0)
const currentPage = ref(1)
const pageSize    = 20
const loadingOrders = ref(false)
const selectedOrder = ref(null)
let pollTimer = null

// ── 右侧状态 ──────────────────────────────────────────
const candidates       = ref([])
const loadingCandidates = ref(false)
const autoDispatchLoading = ref(false)

// ── 弹窗状态 ──────────────────────────────────────────
const confirmVisible = ref(false)
const confirmTarget  = ref(null)
const dispatchRemark = ref('')
const dispatching    = ref(false)

// ── 工具函数 ──────────────────────────────────────────
function fmt(t) {
  if (!t) return '-'
  return String(t).replace('T', ' ').slice(0, 16)
}

function sourceLabel(source) {
  const map = { 1: '平台自有', 2: '外部导入', 3: '手动录入' }
  return map[source] ?? '未知'
}

function sourceTagType(source) {
  const map = { 1: 'success', 2: 'warning', 3: 'info' }
  return map[source] ?? ''
}

// ── 加载待处理订单 ──────────────────────────────────────
async function loadOrders() {
  loadingOrders.value = true
  try {
    const res = await getPendingOrders({ current: currentPage.value, size: pageSize })
    orders.value = res.records
    total.value  = res.total
    // 若当前选中订单已不在列表中（已被派出），清除选中
    if (selectedOrder.value && !res.records.find(o => o.id === selectedOrder.value.id)) {
      selectedOrder.value = null
      candidates.value = []
    }
  } catch {
    ElMessage.error('加载订单失败')
  } finally {
    loadingOrders.value = false
  }
}

// ── 点击订单卡片 ──────────────────────────────────────
async function selectOrder(order) {
  selectedOrder.value = order
  await loadCandidates()
}

// ── 加载候选保洁员 ──────────────────────────────────────
async function loadCandidates() {
  if (!selectedOrder.value) return
  loadingCandidates.value = true
  candidates.value = []
  try {
    candidates.value = await getDispatchCandidates(selectedOrder.value.id)
  } catch {
    ElMessage.error('加载候选保洁员失败')
  } finally {
    loadingCandidates.value = false
  }
}

// ── 触发自动派单 ──────────────────────────────────────
async function doAutoDispatch() {
  autoDispatchLoading.value = true
  try {
    const msg = await autoDispatch(selectedOrder.value.id)
    if (msg && msg.startsWith('暂无')) {
      ElMessage.warning(msg)
    } else {
      ElMessage.success(msg || '派单成功')
      await loadOrders()
    }
  } catch (e) {
    ElMessage.error(e?.message || '自动派单失败')
  } finally {
    autoDispatchLoading.value = false
  }
}

// ── 打开确认弹窗 ──────────────────────────────────────
function openConfirm(cleaner) {
  confirmTarget.value = cleaner
  dispatchRemark.value = ''
  confirmVisible.value = true
}

// ── 执行手动派单 ──────────────────────────────────────
async function doManualDispatch() {
  dispatching.value = true
  try {
    await manualDispatch({
      orderId:   selectedOrder.value.id,
      cleanerId: confirmTarget.value.userId,
      remark:    dispatchRemark.value || null,
    })
    ElMessage.success(`已指派给 ${confirmTarget.value.realName}，等待保洁员确认接单`)
    confirmVisible.value = false
    selectedOrder.value = null
    candidates.value = []
    await loadOrders()
  } catch (e) {
    ElMessage.error(e?.message || '派单失败')
  } finally {
    dispatching.value = false
  }
}

onMounted(async () => {
  await loadOrders()
  pollTimer = setInterval(loadOrders, 30000)
  // 从通知跳转过来时，自动选中对应订单
  const targetId = route.query.orderId ? Number(route.query.orderId) : null
  if (targetId) {
    const target = orders.value.find(o => o.id === targetId)
    if (target) selectOrder(target)
  }
})
onUnmounted(() => clearInterval(pollTimer))
</script>

<style scoped>
.dispatch-page {
  display: flex;
  gap: 16px;
  height: calc(100vh - 112px);
}

/* ── 左侧面板 ── */
.left-panel {
  width: 340px;
  flex-shrink: 0;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0,0,0,.08);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* ── 右侧面板 ── */
.right-panel {
  flex: 1;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0,0,0,.08);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* ── 公共 header ── */
.panel-header,
.candidate-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 16px;
  border-bottom: 1px solid #f0f0f0;
  flex-shrink: 0;
}

.panel-title {
  font-size: 15px;
  font-weight: 600;
  color: #1f2937;
}

/* ── 左侧订单列表 ── */
.order-scroll {
  flex: 1;
  overflow: hidden;
}

.loading-wrap {
  padding: 16px;
}

.order-card {
  margin: 8px 10px;
  padding: 12px 14px;
  border: 1px solid #e4e7ed;
  border-left: 4px solid #f59e0b;
  border-radius: 8px;
  cursor: pointer;
  transition: all .15s;
}

.order-card:hover {
  border-color: #a78bfa;
  background: #faf5ff;
}

.order-card.active {
  border-color: #7c3aed;
  border-left-color: #7c3aed;
  background: #f5f3ff;
}

.card-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.svc-name {
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
}

.card-row {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 4px;
}

.ellipsis {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 220px;
}

.card-bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
}

.fee {
  font-size: 16px;
  font-weight: 700;
  color: #ef4444;
}

.pagination-wrap {
  padding: 8px 10px;
  border-top: 1px solid #f0f0f0;
  flex-shrink: 0;
}

/* ── 右侧空状态 ── */
.empty-hint {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* ── 订单摘要 ── */
.order-summary {
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
  flex-shrink: 0;
  background: #fafaf9;
}

.summary-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.summary-title {
  font-size: 16px;
  font-weight: 700;
  color: #1f2937;
}

.summary-row {
  display: flex;
  gap: 24px;
  font-size: 13px;
  color: #4b5563;
  margin-bottom: 6px;
}

.summary-addr {
  font-size: 13px;
  color: #6b7280;
  margin-bottom: 8px;
}

.summary-footer {
  display: flex;
  align-items: center;
  gap: 12px;
}

.summary-customer {
  font-size: 13px;
  color: #6b7280;
}

/* ── 候选保洁员列表 ── */
.candidate-header {
  border-top: none;
}

.candidate-scroll {
  flex: 1;
  overflow: hidden;
}

.cleaner-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 8px 12px;
  padding: 14px 16px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  transition: border-color .15s;
}

.cleaner-card:hover {
  border-color: #a78bfa;
}

.cleaner-main {
  display: flex;
  gap: 12px;
  align-items: flex-start;
  flex: 1;
  min-width: 0;
}

.cleaner-info {
  flex: 1;
  min-width: 0;
}

.cleaner-name-row {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 6px;
  flex-wrap: wrap;
}

.cleaner-name {
  font-size: 15px;
  font-weight: 600;
  color: #1f2937;
}

.cleaner-meta {
  display: flex;
  gap: 16px;
  font-size: 13px;
  color: #6b7280;
  margin-bottom: 4px;
}
.meta-item { display: inline-flex; align-items: center; gap: 3px; }

.prev-addr {
  font-size: 12px;
  color: #9ca3af;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* ── 弹窗 ── */
.confirm-body {
  padding: 0 4px;
}
</style>
