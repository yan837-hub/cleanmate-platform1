<template>
  <div class="home-wrap">

    <!-- 账号状态提示条 -->
    <div v-if="accountAlert" :class="['account-alert', 'account-alert--' + accountAlert.type]">
      <div class="account-alert-left">
        <el-icon size="16"><component :is="accountAlert.icon" /></el-icon>
        <div>
          <div class="account-alert-title">{{ accountAlert.title }}</div>
          <div class="account-alert-desc">{{ accountAlert.description }}</div>
        </div>
      </div>
      <el-button
        v-if="accountAlert.type === 'warning' || accountAlert.type === 'error-audit'"
        size="small"
        round
        @click="$router.push('/cleaner/profile')"
        style="flex-shrink:0"
      >
        {{ accountAlert.type === 'error-audit' ? '重新提交资料' : '去完善资料 →' }}
      </el-button>
    </div>

    <!-- 待接单通知横幅 -->
    <template v-if="pendingDispatchOrders.length > 0">
      <div class="dispatch-banner">
        <el-icon size="16" color="#fff"><Bell /></el-icon>
        <span>您有 {{ pendingDispatchOrders.length }} 个待确认派单，请在30分钟内处理！</span>
      </div>
      <div v-for="order in pendingDispatchOrders" :key="order.id" class="dispatch-card">
        <div class="dispatch-card-inner">
          <div class="dispatch-info">
            <div class="dispatch-order-no">订单号：{{ order.orderNo }}</div>
            <div class="dispatch-row"><span class="dispatch-label">服务类型</span><span>{{ order.serviceTypeName }}</span></div>
            <div class="dispatch-row"><span class="dispatch-label">预约时间</span><span>{{ formatTime(order.appointTime) }}</span></div>
            <div class="dispatch-row"><span class="dispatch-label">服务地址</span><span class="dispatch-address">{{ order.addressSnapshot }}</span></div>
            <div class="dispatch-row"><span class="dispatch-label">预估金额</span><span class="dispatch-fee">¥{{ order.estimateFee }}</span></div>
          </div>
          <div class="dispatch-actions">
            <el-button type="primary" size="default" round :disabled="!canOperate" :loading="actionLoadingId === order.id + '_accept'" @click="doAccept(order.id)">确认接单</el-button>
            <el-button plain size="default" round :disabled="!canOperate" :loading="actionLoadingId === order.id + '_reject'" @click="doReject(order.id)">拒绝</el-button>
          </div>
        </div>
      </div>
    </template>

    <!-- 改期待处理横幅 -->
    <template v-if="pendingRescheduleOrders.length > 0">
      <div class="reschedule-banner">
        <el-icon size="16" color="#fff"><Edit /></el-icon>
        <span>您有 {{ pendingRescheduleOrders.length }} 个改期申请待处理，请及时确认！</span>
        <el-button size="small" round style="margin-left:auto;flex-shrink:0" @click="$router.push('/cleaner/orders')">去处理 →</el-button>
      </div>
    </template>

    <!-- 4 统计卡片 -->
    <div class="stat-row" v-loading="statsLoading">
      <div
        v-for="stat in statCards"
        :key="stat.label"
        class="stat-card"
        :class="{ 'stat-card--clickable': stat.route }"
        @click="stat.route && $router.push(stat.route)"
      >
        <div class="stat-head">
          <span class="stat-label">{{ stat.label }}</span>
          <el-icon :size="22" :color="stat.iconColor"><component :is="stat.icon" /></el-icon>
        </div>
        <div class="stat-value">{{ stat.value }}</div>
      </div>
    </div>

    <!-- 主内容双栏 -->
    <div class="main-grid">

      <!-- 左：实时接单大厅 -->
      <div class="panel pool-panel" v-loading="poolLoading">
        <div class="panel-header">
          <span class="panel-title">实时接单大厅</span>
          <button class="refresh-btn" @click="loadGrabPool">
            <el-icon size="13"><Refresh /></el-icon> 刷新列表
          </button>
        </div>

        <div v-if="!poolLoading && poolList.length === 0" class="panel-empty">
          <el-empty description="暂无待抢订单" :image-size="64" />
        </div>

        <div v-for="order in poolList" :key="order.id" class="pool-item">
          <div class="pool-item-icon">{{ svcEmoji(order.serviceTypeName) }}</div>
          <div class="pool-item-info">
            <div class="pool-item-top">
              <span class="pool-fee">¥{{ order.estimateFee }}</span>
              <span class="pool-svc-tag">{{ order.serviceTypeName }}</span>
            </div>
            <div class="pool-item-meta">
              <span v-if="order.distanceKm != null">
                <el-icon size="11"><Location /></el-icon> {{ order.distanceKm }}km
              </span>
              <span>
                <el-icon size="11"><Clock /></el-icon> 预约 {{ formatShortTime(order.appointTime) }}
              </span>
            </div>
          </div>
          <button
            class="grab-btn"
            :class="{ 'grab-btn--disabled': !canOperate }"
            :disabled="!canOperate"
            @click="doGrab(order.id)"
          >抢单</button>
        </div>
      </div>

      <!-- 右：今日日程 -->
      <div class="panel schedule-panel">
        <div class="panel-header">
          <span class="panel-title">今日日程</span>
          <span class="schedule-count" v-if="todayTimeline.length > 0">{{ todayTimeline.length }} 单</span>
        </div>

        <div v-if="todayTimeline.length === 0 && !todayLoading" class="panel-empty">
          <el-empty description="今日暂无服务订单" :image-size="64" />
        </div>

        <div class="timeline" v-loading="todayLoading">
          <div
            v-for="(order, i) in todayTimeline"
            :key="order.id"
            class="tl-item"
            :class="{
              'tl-item--inservice': order.status === 4,
              'tl-item--upcoming':  order.status === 3,
            }"
          >
            <!-- 时间轴左侧 -->
            <div class="tl-axis">
              <div class="tl-dot" :class="{
                'tl-dot--inservice': order.status === 4,
                'tl-dot--upcoming':  order.status === 3,
              }">
                <el-icon v-if="order.status === 4" size="10" color="#fff"><VideoPlay /></el-icon>
              </div>
              <div v-if="i < todayTimeline.length - 1" class="tl-line"></div>
            </div>

            <!-- 内容 -->
            <div class="tl-body">
              <div class="tl-time">{{ formatTimeRange(order) }}</div>

              <!-- 服务中：高亮卡片 -->
              <div v-if="order.status === 4" class="tl-card tl-card--inservice">
                <div class="tl-card-badge">进行中</div>
                <div class="tl-card-title">{{ order.serviceTypeName }}</div>
                <div class="tl-card-addr">{{ order.addressSnapshot }}</div>
                <button class="nav-btn" @click="$router.push(`/cleaner/orders/${order.id}`)">
                  ↗ 去完工上报
                </button>
              </div>

              <!-- 待上门：普通条目 -->
              <div v-else class="tl-upcoming">
                <span class="tl-upcoming-title">{{ order.serviceTypeName }}</span>
                <span class="tl-upcoming-addr">{{ order.addressSnapshot }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { formatTime } from '@/utils/time'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Bell, Edit, Warning, CircleClose, OfficeBuilding, Refresh, Location, Clock, VideoPlay } from '@element-plus/icons-vue'
import { getCleanerStats, getCleanerOrders, getGrabPool, grabOrder, acceptOrder, rejectOrder } from '@/api/order'
import { getUserInfo } from '@/api/auth'

const statsLoading = ref(false)
const todayLoading  = ref(false)
const poolLoading   = ref(false)
const actionLoadingId = ref(null)

const stats = ref({ todayOrders: 0, pendingDispatch: 0, monthlyCompleted: 0, monthlyIncome: 0 })
const inServiceOrders         = ref([])
const upcomingOrders          = ref([])
const pendingDispatchOrders   = ref([])
const pendingRescheduleOrders = ref([])
const poolList                = ref([])

const accountAlert = ref(null)
const canOperate   = ref(true)

// 今日日程：服务中置顶，然后待上门，按时间排序
const todayTimeline = computed(() => {
  return [...inServiceOrders.value, ...upcomingOrders.value]
    .sort((a, b) => new Date(a.appointTime) - new Date(b.appointTime))
})

const statCards = computed(() => [
  { label: '今日订单',  value: stats.value.todayOrders,                    icon: 'Calendar', iconColor: '#8FA888', route: '/cleaner/orders' },
  { label: '待接单',    value: stats.value.pendingDispatch,                 icon: 'Pointer',  iconColor: '#C4A882', route: '/cleaner/grab'   },
  { label: '本周好评',  value: stats.value.weeklyRating   ?? '—',           icon: 'Star',     iconColor: '#D4B87A', route: null             },
  { label: '本月完成',  value: (stats.value.monthlyCompleted ?? 0) + ' 单', icon: 'CircleCheck', iconColor: '#A8B8C4', route: '/cleaner/orders' },
])

// ── 辅助函数 ──
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

function formatShortTime(t) {
  if (!t) return ''
  const d = new Date(t)
  const now = new Date()
  const isToday = d.toDateString() === now.toDateString()
  const hm = String(d.getHours()).padStart(2,'0') + ':' + String(d.getMinutes()).padStart(2,'0')
  return isToday ? `今天 ${hm}` : `明天 ${hm}`
}

function formatTimeRange(order) {
  if (!order.appointTime) return ''
  const start = new Date(order.appointTime)
  const hm = t => String(t.getHours()).padStart(2,'0') + ':' + String(t.getMinutes()).padStart(2,'0')
  if (!order.planDuration) return hm(start)
  const end = new Date(start.getTime() + order.planDuration * 60000)
  return hm(start) + ' - ' + hm(end)
}

// ── 数据加载 ──
async function loadAccountStatus() {
  try {
    const info = await getUserInfo()
    const { auditStatus, status: userStatus } = info
    if (userStatus === 3) {
      canOperate.value = false
      accountAlert.value = { type: 'error',       icon: CircleClose,    title: '账号已被禁用', description: '账号已被禁用，请联系平台客服' }
    } else if (auditStatus === 3) {
      canOperate.value = false
      accountAlert.value = { type: 'error-audit', icon: CircleClose,    title: '审核未通过',   description: `审核未通过${info.auditRemark ? '：' + info.auditRemark : ''}，请修改后重新提交` }
    } else if (auditStatus === 2 || auditStatus == null) {
      canOperate.value = false
      accountAlert.value = { type: 'warning',     icon: Warning,        title: '账号审核中',   description: '正在审核中，审核通过后可接单。请先完善真实姓名和身份证信息。' }
    } else if (info.companyName) {
      canOperate.value = true
      accountAlert.value = { type: 'company',     icon: OfficeBuilding, title: '公司保洁员',   description: `您隶属于「${info.companyName}」` }
    } else {
      canOperate.value = true
      accountAlert.value = null
    }
  } catch {}
}

async function loadStats() {
  statsLoading.value = true
  try { stats.value = await getCleanerStats() } catch {}
  finally { statsLoading.value = false }
}

async function loadTodayOrders() {
  todayLoading.value = true
  try {
    const res = await getCleanerOrders({ current: 1, size: 20 })
    const all = res.records ?? []
    const today = new Date().toDateString()
    inServiceOrders.value         = all.filter(o => o.status === 4 && new Date(o.appointTime).toDateString() === today)
    upcomingOrders.value          = all.filter(o => o.status === 3 && new Date(o.appointTime).toDateString() === today)
    pendingDispatchOrders.value   = all.filter(o => o.status === 2)
    pendingRescheduleOrders.value = all.filter(o => o.status === 9)
  } catch { ElMessage.error('加载订单数据失败') }
  finally { todayLoading.value = false }
}

async function loadGrabPool() {
  poolLoading.value = true
  try {
    const res = await getGrabPool({ current: 1, size: 6 })
    poolList.value = res.records ?? res ?? []
  } catch {}
  finally { poolLoading.value = false }
}

async function doGrab(orderId) {
  if (!canOperate.value) return
  try {
    await grabOrder(orderId)
    ElMessage.success('抢单成功！请按时上门服务')
    await Promise.all([loadStats(), loadGrabPool(), loadTodayOrders()])
  } catch (e) {
    ElMessage.error(e?.message || '抢单失败')
  }
}

async function doAccept(orderId) {
  actionLoadingId.value = orderId + '_accept'
  try {
    await acceptOrder(orderId)
    ElMessage.success('接单成功！请按时上门服务')
    await Promise.all([loadStats(), loadTodayOrders()])
  } catch (e) {
    ElMessage.error(e?.message || '接单失败')
  } finally { actionLoadingId.value = null }
}

async function doReject(orderId) {
  try {
    await ElMessageBox.confirm('确认拒绝此派单？订单将退回待派单池', '拒绝接单', { type: 'warning' })
  } catch { return }
  actionLoadingId.value = orderId + '_reject'
  try {
    await rejectOrder(orderId)
    ElMessage.info('已拒绝，订单已退回')
    await Promise.all([loadStats(), loadTodayOrders()])
  } catch (e) {
    ElMessage.error(e?.message || '操作失败')
  } finally { actionLoadingId.value = null }
}

let timer = null
onMounted(() => {
  loadAccountStatus()
  loadStats()
  loadTodayOrders()
  loadGrabPool()
  timer = setInterval(() => { loadStats(); loadTodayOrders(); loadGrabPool() }, 30000)
})
onUnmounted(() => clearInterval(timer))
</script>

<style scoped>
.home-wrap { padding-bottom: 40px; }

/* ── 账号提示条 ── */
.account-alert {
  display: flex; align-items: center; justify-content: space-between;
  gap: 12px; padding: 11px 16px; border-radius: 10px;
  margin-bottom: 16px; font-size: 13px;
}
.account-alert--warning    { background: #FDF8EE; border: 1px solid #E8D8B0; color: #7A6030; }
.account-alert--error,
.account-alert--error-audit { background: #FDF2F2; border: 1px solid #E8C0C0; color: #8A3030; }
.account-alert--company    { background: #EDF4ED; border: 1px solid #C8D4C4; color: #4A6A44; }
.account-alert-left { display: flex; align-items: flex-start; gap: 10px; }
.account-alert-title { font-weight: 600; margin-bottom: 2px; }
.account-alert-desc  { opacity: .85; line-height: 1.5; }

/* ── 待接单横幅 ── */
.dispatch-banner {
  background: linear-gradient(90deg, #C4A882, #B89068);
  border-radius: 10px; padding: 12px 18px; margin-bottom: 12px;
  display: flex; align-items: center; gap: 10px;
  color: #fff; font-size: 14px; font-weight: 600;
}
.dispatch-card {
  background: #fff; border: 1.5px solid #E8D8B0;
  border-radius: 12px; padding: 18px 20px; margin-bottom: 12px;
}
.dispatch-card-inner { display: flex; justify-content: space-between; align-items: center; gap: 16px; }
.dispatch-info { flex: 1; }
.dispatch-order-no { font-size: 12px; color: #B8B0A8; margin-bottom: 8px; font-weight: 500; }
.dispatch-row { display: flex; gap: 10px; font-size: 13px; margin-bottom: 4px; align-items: flex-start; }
.dispatch-label { color: #8A857E; flex-shrink: 0; width: 60px; }
.dispatch-address { color: #3A3734; }
.dispatch-fee { color: #3A3734; font-weight: 700; font-size: 16px; }
.dispatch-actions { display: flex; flex-direction: column; gap: 8px; flex-shrink: 0; }

/* ── 改期横幅 ── */
.reschedule-banner {
  background: linear-gradient(90deg, #A8B8C4, #8090A0);
  border-radius: 10px; padding: 12px 18px; margin-bottom: 16px;
  display: flex; align-items: center; gap: 10px;
  color: #fff; font-size: 14px; font-weight: 600;
}

/* ── 统计卡片行 ── */
.stat-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 20px;
}
.stat-card {
  background: #fff;
  border: 1px solid #EDE8DF;
  border-radius: 16px;
  padding: 20px 22px 18px;
  cursor: default;
  transition: transform .2s, box-shadow .2s;
}
.stat-card--clickable { cursor: pointer; }
.stat-card--clickable:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,.08); }
.stat-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
}
.stat-label { font-size: 13px; color: #8A857E; }
.stat-value { font-size: 32px; font-weight: 700; color: #3A3734; line-height: 1; letter-spacing: -1px; }

/* ── 主内容双栏 ── */
.main-grid {
  display: grid;
  grid-template-columns: 3fr 2fr;
  gap: 16px;
}

.panel {
  background: #fff;
  border: 1px solid #EDE8DF;
  border-radius: 16px;
  padding: 20px;
}
.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
.panel-title {
  font-size: 15px;
  font-weight: 700;
  color: #3A3734;
}
.refresh-btn {
  display: flex; align-items: center; gap: 4px;
  background: none; border: none; cursor: pointer;
  font-size: 13px; color: #8A857E;
  padding: 4px 8px; border-radius: 6px;
  transition: color .15s, background .15s;
}
.refresh-btn:hover { color: #8FA888; background: #EDF4ED; }
.schedule-count {
  font-size: 12px; color: #8A857E;
  background: #F5F2EE; border-radius: 20px; padding: 2px 10px;
}
.panel-empty { padding: 20px 0; }

/* ── 抢单池 ── */
.pool-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 14px 16px;
  background: #FAFAF8;
  border: 1px solid #EDE8DF;
  border-radius: 12px;
  margin-bottom: 10px;
  transition: border-color .18s, box-shadow .18s;
}
.pool-item:last-child { margin-bottom: 0; }
.pool-item:hover { border-color: #C8D4C4; box-shadow: 0 3px 12px rgba(0,0,0,.06); }

.pool-item-icon {
  width: 42px; height: 42px; border-radius: 10px;
  background: #EDF4ED; display: flex; align-items: center;
  justify-content: center; font-size: 20px; flex-shrink: 0;
}
.pool-item-info { flex: 1; min-width: 0; }
.pool-item-top { display: flex; align-items: center; gap: 8px; margin-bottom: 5px; }
.pool-fee { font-size: 18px; font-weight: 700; color: #3A3734; }
.pool-svc-tag {
  font-size: 11px; color: #7A9076;
  background: #EDF4ED; border-radius: 20px; padding: 2px 8px;
}
.pool-item-meta {
  display: flex; align-items: center; gap: 12px;
  font-size: 12px; color: #8A857E;
}
.pool-item-meta span { display: flex; align-items: center; gap: 3px; }

.grab-btn {
  flex-shrink: 0;
  background: #8FA888;
  color: #fff;
  border: none;
  border-radius: 50px;
  padding: 8px 22px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: background .18s, box-shadow .18s;
  box-shadow: 0 3px 10px rgba(143,168,136,.3);
}
.grab-btn:hover { background: #7A9A72; box-shadow: 0 4px 14px rgba(143,168,136,.4); }
.grab-btn--disabled { opacity: .45; cursor: not-allowed; }

/* ── 今日日程时间轴 ── */
.timeline { padding-top: 4px; }

.tl-item {
  display: flex;
  gap: 14px;
  min-height: 60px;
}

.tl-axis {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex-shrink: 0;
  padding-top: 3px;
}
.tl-dot {
  width: 22px; height: 22px; border-radius: 50%;
  background: #EDE8DF; border: 2px solid #D8D2CA;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.tl-dot--inservice {
  background: #8FA888; border-color: #8FA888;
}
.tl-dot--upcoming {
  background: #fff; border-color: #C8D4C4;
}
.tl-line {
  width: 1.5px;
  flex: 1;
  background: #EDE8DF;
  margin: 4px 0 4px;
  min-height: 16px;
}

.tl-body { flex: 1; min-width: 0; padding-bottom: 18px; }
.tl-time { font-size: 12px; color: #8A857E; margin-bottom: 6px; font-variant-numeric: tabular-nums; }

/* 服务中卡片 */
.tl-card {
  border-radius: 10px;
  padding: 12px 14px;
}
.tl-card--inservice {
  background: linear-gradient(135deg, #EDF4ED, #E8F0E8);
  border: 1px solid #C8D4C4;
}
.tl-card-badge {
  display: inline-block;
  font-size: 10px; font-weight: 700;
  color: #4A6A44; background: #C8D4C4;
  border-radius: 20px; padding: 2px 8px;
  margin-bottom: 6px; letter-spacing: 0.3px;
}
.tl-card-title { font-size: 14px; font-weight: 600; color: #3A3734; margin-bottom: 4px; }
.tl-card-addr  { font-size: 12px; color: #7A9076; margin-bottom: 10px; }
.nav-btn {
  background: #fff; border: 1px solid #C8D4C4;
  color: #5A5450; border-radius: 50px;
  padding: 6px 0; width: 100%;
  font-size: 13px; font-weight: 500; cursor: pointer;
  transition: all .18s; text-align: center;
  display: block;
}
.nav-btn:hover { background: #8FA888; color: #fff; border-color: #8FA888; }

/* 待上门条目 */
.tl-upcoming { padding: 2px 0 0; }
.tl-upcoming-title { font-size: 14px; font-weight: 500; color: #3A3734; display: block; margin-bottom: 3px; }
.tl-upcoming-addr  { font-size: 12px; color: #8A857E; display: block; }
</style>
