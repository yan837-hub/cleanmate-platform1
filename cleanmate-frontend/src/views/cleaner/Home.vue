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
        <el-icon size="18" color="#fff"><Bell /></el-icon>
        <span>您有 <b>{{ pendingDispatchOrders.length }}</b> 个待确认派单，请在30分钟内处理！</span>
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
        :class="['stat-card--' + stat.colorKey, { 'stat-card--clickable': stat.route }]"
        @click="stat.route && $router.push(stat.route)"
      >
        <div class="stat-icon-wrap">
          <el-icon :size="26" :color="stat.iconColor"><component :is="stat.icon" /></el-icon>
        </div>
        <div class="stat-main">
          <div class="stat-value">{{ stat.value }}</div>
          <div class="stat-label">{{ stat.label }}</div>
        </div>
        <div class="stat-arrow" v-if="stat.route">›</div>
      </div>
    </div>

    <!-- 主内容双栏 -->
    <div class="main-grid">

      <!-- 左：实时抢单池 -->
      <div class="panel pool-panel" v-loading="poolLoading">
        <div class="panel-header">
          <div class="panel-header-left">
            <span class="panel-dot panel-dot--green"></span>
            <span class="panel-title">实时抢单池</span>
            <span class="pool-badge" v-if="poolList.length > 0">{{ poolList.length }} 单可抢</span>
          </div>
          <button class="refresh-btn" @click="loadGrabPool">
            <el-icon size="13"><Refresh /></el-icon> 刷新
          </button>
        </div>

        <div v-if="!poolLoading && poolList.length === 0" class="panel-empty">
          <el-empty description="暂无待抢订单，稍后刷新试试" :image-size="72" />
        </div>

        <div class="pool-list">
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

        <div class="panel-footer">
          <button class="view-all-btn" @click="$router.push('/cleaner/grab')">
            查看全部可抢订单 →
          </button>
        </div>
      </div>

      <!-- 右：今日日程 -->
      <div class="panel schedule-panel">
        <div class="panel-header">
          <div class="panel-header-left">
            <span class="panel-dot panel-dot--orange"></span>
            <span class="panel-title">今日日程</span>
          </div>
          <span class="schedule-count-badge" v-if="todayTimeline.length > 0">{{ todayTimeline.length }} 单</span>
        </div>

        <div v-if="todayTimeline.length === 0 && !todayLoading" class="panel-empty">
          <el-empty description="今日暂无服务订单" :image-size="72" />
        </div>

        <div class="timeline" v-loading="todayLoading">
          <div
            v-for="(order, i) in todayTimeline"
            :key="order.id"
            class="tl-item"
          >
            <div class="tl-axis">
              <div class="tl-dot" :class="{
                'tl-dot--inservice': order.status === 4,
                'tl-dot--upcoming':  order.status === 3,
              }">
                <el-icon v-if="order.status === 4" size="10" color="#fff"><VideoPlay /></el-icon>
              </div>
              <div v-if="i < todayTimeline.length - 1" class="tl-line"></div>
            </div>
            <div class="tl-body">
              <div class="tl-time">{{ formatTimeRange(order) }}</div>
              <div v-if="order.status === 4" class="tl-card tl-card--inservice">
                <div class="tl-card-badge">进行中</div>
                <div class="tl-card-title">{{ order.serviceTypeName }}</div>
                <div class="tl-card-addr">{{ order.addressSnapshot }}</div>
                <button class="nav-btn" @click="$router.push(`/cleaner/orders/${order.id}`)">
                  ↗ 去完工上报
                </button>
              </div>
              <div v-else class="tl-upcoming">
                <span class="tl-upcoming-title">{{ order.serviceTypeName }}</span>
                <span class="tl-upcoming-addr">{{ order.addressSnapshot }}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="panel-footer">
          <button class="view-all-btn" @click="$router.push('/cleaner/orders')">
            查看全部订单 →
          </button>
        </div>
      </div>
    </div>

    <!-- 底部快捷操作区 -->
    <div class="quick-section">
      <div class="quick-section-header">
        <span class="quick-section-title">快捷操作</span>
        <span class="quick-section-sub">快速跳转常用功能</span>
      </div>
      <div class="quick-grid">
        <div class="quick-card" @click="$router.push('/cleaner/grab')">
          <div class="quick-icon quick-icon--green">🏃</div>
          <div class="quick-label">去抢单</div>
          <div class="quick-desc">实时查看可抢订单</div>
        </div>
        <div class="quick-card" @click="$router.push('/cleaner/schedule')">
          <div class="quick-icon quick-icon--orange">📅</div>
          <div class="quick-label">管档期</div>
          <div class="quick-desc">设置可服务时段</div>
        </div>
        <div class="quick-card" @click="$router.push('/cleaner/income')">
          <div class="quick-icon quick-icon--amber">💰</div>
          <div class="quick-label">看收入</div>
          <div class="quick-desc">本月收入明细</div>
        </div>
        <div class="quick-card" @click="$router.push('/cleaner/reviews')">
          <div class="quick-icon quick-icon--yellow">⭐</div>
          <div class="quick-label">我的评价</div>
          <div class="quick-desc">查看顾客好评</div>
        </div>
        <div class="quick-card" @click="$router.push('/cleaner/orders')">
          <div class="quick-icon quick-icon--blue">📋</div>
          <div class="quick-label">我的订单</div>
          <div class="quick-desc">管理历史订单</div>
        </div>
        <div class="quick-card" @click="$router.push('/cleaner/profile')">
          <div class="quick-icon quick-icon--teal">👤</div>
          <div class="quick-label">我的资料</div>
          <div class="quick-desc">完善认证信息</div>
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

const todayTimeline = computed(() => {
  return [...inServiceOrders.value, ...upcomingOrders.value]
    .sort((a, b) => new Date(a.appointTime) - new Date(b.appointTime))
})

const statCards = computed(() => [
  { label: '今日订单',  value: stats.value.todayOrders,                    icon: 'Calendar',    iconColor: '#2A6B47', colorKey: 'green',  route: '/cleaner/orders' },
  { label: '待接单',    value: stats.value.pendingDispatch,                 icon: 'Pointer',     iconColor: '#D97706', colorKey: 'orange', route: '/cleaner/grab'   },
  { label: '本周好评',  value: stats.value.weeklyRating   ?? '—',           icon: 'Star',        iconColor: '#F59E0B', colorKey: 'yellow', route: null             },
  { label: '本月完成',  value: (stats.value.monthlyCompleted ?? 0) + ' 单', icon: 'CircleCheck', iconColor: '#3B82F6', colorKey: 'blue',   route: '/cleaner/orders' },
])

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
.home-wrap {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding-bottom: 8px;
}

/* ── 账号提示条 ── */
.account-alert {
  display: flex; align-items: center; justify-content: space-between;
  gap: 12px; padding: 12px 18px; border-radius: 12px; font-size: 13px;
}
.account-alert--warning     { background: #FFFBEB; border: 1.5px solid #FCD34D; color: #78350F; }
.account-alert--error,
.account-alert--error-audit { background: #FEF2F2; border: 1.5px solid #FCA5A5; color: #991B1B; }
.account-alert--company     { background: #E6F4EE; border: 1.5px solid #6EE7A0; color: #14532D; }
.account-alert-left { display: flex; align-items: flex-start; gap: 10px; }
.account-alert-title { font-weight: 600; margin-bottom: 2px; }
.account-alert-desc  { opacity: .88; line-height: 1.5; }

/* ── 待接单横幅 ── */
.dispatch-banner {
  background: linear-gradient(90deg, #D97706, #B45309);
  border-radius: 12px; padding: 14px 22px;
  display: flex; align-items: center; gap: 10px;
  color: #fff; font-size: 14px; font-weight: 600;
  box-shadow: 0 4px 14px rgba(217,119,6,.30);
}
.dispatch-banner b { font-size: 17px; }
.dispatch-card {
  background: #fff; border: 2px solid #FDE68A;
  border-radius: 14px; padding: 18px 22px;
  box-shadow: 0 2px 10px rgba(217,119,6,.10);
}
.dispatch-card-inner { display: flex; justify-content: space-between; align-items: center; gap: 16px; }
.dispatch-info { flex: 1; }
.dispatch-order-no { font-size: 12px; color: #9CA3AF; margin-bottom: 8px; }
.dispatch-row { display: flex; gap: 10px; font-size: 13px; margin-bottom: 5px; align-items: flex-start; }
.dispatch-label { color: #6B7280; flex-shrink: 0; width: 60px; }
.dispatch-address { color: #1C3D2A; }
.dispatch-fee { color: #D97706; font-weight: 700; font-size: 18px; }
.dispatch-actions { display: flex; flex-direction: column; gap: 8px; flex-shrink: 0; }

/* ── 改期横幅 ── */
.reschedule-banner {
  background: linear-gradient(90deg, #2563EB, #1D4ED8);
  border-radius: 12px; padding: 13px 22px;
  display: flex; align-items: center; gap: 10px;
  color: #fff; font-size: 14px; font-weight: 600;
}

/* ── 统计卡片 ── */
.stat-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
}
.stat-card {
  background: #fff;
  border: 1.5px solid #E5E7EB;
  border-radius: 16px;
  padding: 20px 22px;
  display: flex;
  align-items: center;
  gap: 16px;
  cursor: default;
  transition: transform .18s, box-shadow .18s;
  position: relative;
  overflow: hidden;
}
.stat-card::before {
  content: '';
  position: absolute;
  left: 0; top: 0; bottom: 0;
  width: 5px;
  border-radius: 16px 0 0 16px;
}
.stat-card--green::before  { background: #2A6B47; }
.stat-card--orange::before { background: #D97706; }
.stat-card--yellow::before { background: #F59E0B; }
.stat-card--blue::before   { background: #3B82F6; }
.stat-card--clickable { cursor: pointer; }
.stat-card--clickable:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,.10); }

.stat-icon-wrap {
  width: 54px; height: 54px; border-radius: 14px;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.stat-card--green .stat-icon-wrap  { background: #DCFCE7; }
.stat-card--orange .stat-icon-wrap { background: #FEF3C7; }
.stat-card--yellow .stat-icon-wrap { background: #FFFBEB; }
.stat-card--blue .stat-icon-wrap   { background: #EFF6FF; }

.stat-main { flex: 1; }
.stat-value { font-size: 32px; font-weight: 800; color: #1C3D2A; line-height: 1; letter-spacing: -1px; margin-bottom: 6px; }
.stat-label { font-size: 13px; color: #6B7280; font-weight: 500; }
.stat-arrow { font-size: 22px; color: #D1D5DB; font-weight: 300; }

/* ── 主双栏 ── */
.main-grid {
  display: grid;
  grid-template-columns: 3fr 2fr;
  gap: 16px;
  min-height: 420px;
}
.panel {
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 16px;
  padding: 20px 22px;
  display: flex;
  flex-direction: column;
}
.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  flex-shrink: 0;
}
.panel-header-left { display: flex; align-items: center; gap: 8px; }
.panel-dot {
  width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0;
}
.panel-dot--green  { background: #2A6B47; box-shadow: 0 0 0 3px #DCFCE7; }
.panel-dot--orange { background: #D97706; box-shadow: 0 0 0 3px #FEF3C7; }
.panel-title { font-size: 16px; font-weight: 700; color: #1C3D2A; }
.pool-badge {
  font-size: 11px; color: #fff;
  background: #2A6B47; border-radius: 20px; padding: 2px 10px; font-weight: 700;
}
.refresh-btn {
  display: flex; align-items: center; gap: 4px;
  background: #F0F5F0; border: none; cursor: pointer;
  font-size: 13px; color: #4A6B5A;
  padding: 6px 12px; border-radius: 8px; transition: all .15s;
}
.refresh-btn:hover { background: #DCFCE7; color: #2A6B47; }
.schedule-count-badge {
  font-size: 12px; color: #D97706;
  background: #FEF3C7; border-radius: 20px; padding: 3px 12px; font-weight: 700;
}
.panel-empty {
  flex: 1; display: flex; align-items: center; justify-content: center;
}
.panel-footer {
  margin-top: 14px;
  padding-top: 12px;
  border-top: 1px solid #E5EDE5;
  flex-shrink: 0;
}
.view-all-btn {
  background: none; border: none; cursor: pointer;
  font-size: 13px; color: #2A6B47; font-weight: 600;
  padding: 0; transition: color .15s;
}
.view-all-btn:hover { color: #1B4D32; }

/* ── 抢单池列表 ── */
.pool-list {
  flex: 1;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.pool-item {
  display: flex; align-items: center; gap: 14px;
  padding: 14px 16px;
  background: #FAFBFA;
  border: 1.5px solid #E0EBE0;
  border-radius: 12px;
  transition: border-color .18s, box-shadow .18s;
}
.pool-item:hover { border-color: #6EE7A0; box-shadow: 0 3px 12px rgba(42,107,71,.10); }
.pool-item-icon {
  width: 44px; height: 44px; border-radius: 10px;
  background: #E6F4EE; display: flex; align-items: center;
  justify-content: center; font-size: 20px; flex-shrink: 0;
}
.pool-item-info { flex: 1; min-width: 0; }
.pool-item-top { display: flex; align-items: center; gap: 8px; margin-bottom: 5px; }
.pool-fee { font-size: 20px; font-weight: 800; color: #D97706; }
.pool-svc-tag {
  font-size: 11px; color: #2A6B47;
  background: #DCFCE7; border-radius: 20px; padding: 2px 9px; font-weight: 600;
}
.pool-item-meta {
  display: flex; align-items: center; gap: 12px;
  font-size: 12px; color: #6B7280;
}
.pool-item-meta span { display: flex; align-items: center; gap: 3px; }
.grab-btn {
  flex-shrink: 0;
  background: #2A6B47; color: #fff;
  border: none; border-radius: 50px;
  padding: 9px 22px; font-size: 14px; font-weight: 700;
  cursor: pointer; transition: background .18s, box-shadow .18s;
  box-shadow: 0 3px 10px rgba(42,107,71,.35);
}
.grab-btn:hover { background: #1B4D32; box-shadow: 0 4px 14px rgba(42,107,71,.45); }
.grab-btn--disabled { opacity: .45; cursor: not-allowed; }

/* ── 时间轴 ── */
.timeline { flex: 1; overflow-y: auto; padding-top: 4px; }
.tl-item { display: flex; gap: 14px; min-height: 60px; }
.tl-axis {
  display: flex; flex-direction: column;
  align-items: center; flex-shrink: 0; padding-top: 3px;
}
.tl-dot {
  width: 22px; height: 22px; border-radius: 50%;
  background: #E5E7EB; border: 2px solid #D1D5DB;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.tl-dot--inservice { background: #2A6B47; border-color: #2A6B47; }
.tl-dot--upcoming  { background: #fff; border-color: #6EE7A0; }
.tl-line { width: 2px; flex: 1; background: #E5E7EB; margin: 4px 0; min-height: 16px; }
.tl-body { flex: 1; min-width: 0; padding-bottom: 18px; }
.tl-time { font-size: 12px; color: #6B7280; margin-bottom: 6px; font-variant-numeric: tabular-nums; }
.tl-card { border-radius: 12px; padding: 12px 14px; }
.tl-card--inservice {
  background: linear-gradient(135deg, #E6F4EE, #D1FAE5);
  border: 1.5px solid #6EE7A0;
}
.tl-card-badge {
  display: inline-block; font-size: 10px; font-weight: 700;
  color: #fff; background: #2A6B47;
  border-radius: 20px; padding: 2px 9px; margin-bottom: 6px;
}
.tl-card-title { font-size: 14px; font-weight: 600; color: #1C3D2A; margin-bottom: 4px; }
.tl-card-addr  { font-size: 12px; color: #4A6B5A; margin-bottom: 10px; }
.nav-btn {
  background: #2A6B47; border: none; color: #fff;
  border-radius: 50px; padding: 7px 0; width: 100%;
  font-size: 13px; font-weight: 600; cursor: pointer;
  transition: all .18s; text-align: center; display: block;
}
.nav-btn:hover { background: #1B4D32; }
.tl-upcoming { padding: 2px 0 0; }
.tl-upcoming-title { font-size: 14px; font-weight: 500; color: #1C3D2A; display: block; margin-bottom: 3px; }
.tl-upcoming-addr  { font-size: 12px; color: #6B7280; display: block; }

/* ── 快捷操作区 ── */
.quick-section {
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 16px;
  padding: 20px 22px;
}
.quick-section-header {
  display: flex; align-items: center; gap: 10px; margin-bottom: 16px;
}
.quick-section-title { font-size: 16px; font-weight: 700; color: #1C3D2A; }
.quick-section-sub   { font-size: 13px; color: #9CA3AF; }
.quick-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 12px;
}
.quick-card {
  display: flex; flex-direction: column; align-items: center;
  gap: 6px; padding: 18px 8px;
  background: #FAFBFA; border: 1.5px solid #E5EDE5;
  border-radius: 14px; cursor: pointer;
  transition: all .18s; text-align: center;
}
.quick-card:hover {
  border-color: #6EE7A0; background: #E6F4EE;
  transform: translateY(-3px);
  box-shadow: 0 6px 16px rgba(42,107,71,.12);
}
.quick-icon {
  font-size: 26px;
  width: 52px; height: 52px; border-radius: 14px;
  display: flex; align-items: center; justify-content: center;
}
.quick-icon--green  { background: #DCFCE7; }
.quick-icon--orange { background: #FFEDD5; }
.quick-icon--amber  { background: #FEF3C7; }
.quick-icon--yellow { background: #FFFBEB; }
.quick-icon--blue   { background: #EFF6FF; }
.quick-icon--teal   { background: #ECFDF5; }
.quick-label { font-size: 13px; font-weight: 700; color: #1C3D2A; }
.quick-desc  { font-size: 11px; color: #6B7280; line-height: 1.4; }
</style>
