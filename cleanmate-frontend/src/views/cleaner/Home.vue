<template>
  <div>
    <!-- 审核/账号状态提示条 -->
    <div v-if="accountAlert" :class="['account-alert', 'account-alert--' + accountAlert.type]">
      <div class="account-alert-left">
        <el-icon size="18"><component :is="accountAlert.icon" /></el-icon>
        <div>
          <div class="account-alert-title">{{ accountAlert.title }}</div>
          <div class="account-alert-desc">{{ accountAlert.description }}</div>
        </div>
      </div>
      <el-button
        v-if="accountAlert.type === 'warning' || accountAlert.type === 'error-audit'"
        size="small"
        @click="$router.push('/cleaner/profile')"
        style="flex-shrink:0"
      >
        {{ accountAlert.type === 'error-audit' ? '重新提交资料' : '去完善资料 →' }}
      </el-button>
    </div>

    <!-- 待接单通知横幅 -->
    <template v-if="pendingDispatchOrders.length > 0">
      <div class="dispatch-banner">
        <div class="dispatch-banner-title">
          <el-icon size="20" color="#fff"><Bell /></el-icon>
          <span>您有 {{ pendingDispatchOrders.length }} 个待确认派单，请在30分钟内处理！</span>
        </div>
      </div>

      <el-card
        v-for="order in pendingDispatchOrders"
        :key="order.id"
        class="dispatch-card"
        shadow="always"
      >
        <div class="dispatch-card-inner">
          <div class="dispatch-info">
            <div class="dispatch-order-no">订单号：{{ order.orderNo }}</div>
            <div class="dispatch-row">
              <span class="dispatch-label">服务类型</span>
              <span>{{ order.serviceTypeName }}</span>
            </div>
            <div class="dispatch-row">
              <span class="dispatch-label">预约时间</span>
              <span>{{ formatTime(order.appointTime) }}</span>
            </div>
            <div class="dispatch-row">
              <span class="dispatch-label">服务地址</span>
              <span class="dispatch-address">{{ order.addressSnapshot }}</span>
            </div>
            <div class="dispatch-row">
              <span class="dispatch-label">预估金额</span>
              <span class="dispatch-fee">¥{{ order.estimateFee }}</span>
            </div>
          </div>
          <div class="dispatch-actions">
            <el-button
              type="primary"
              size="large"
              :disabled="!canOperate"
              :loading="actionLoadingId === order.id + '_accept'"
              @click="doAccept(order.id)"
            >
              确认接单
            </el-button>
            <el-button
              type="danger"
              plain
              size="large"
              :disabled="!canOperate"
              :loading="actionLoadingId === order.id + '_reject'"
              @click="doReject(order.id)"
            >
              拒绝
            </el-button>
          </div>
        </div>
      </el-card>
    </template>

    <!-- 改期待处理横幅 -->
    <template v-if="pendingRescheduleOrders.length > 0">
      <div class="reschedule-banner">
        <el-icon size="18" color="#fff"><Edit /></el-icon>
        <span>您有 {{ pendingRescheduleOrders.length }} 个改期申请待处理，请及时确认！</span>
      </div>
      <el-card
        v-for="order in pendingRescheduleOrders"
        :key="order.id"
        class="dispatch-card"
        shadow="always"
        style="border-left:4px solid #f59e0b"
      >
        <div class="dispatch-card-inner">
          <div class="dispatch-info">
            <div class="dispatch-order-no">订单号：{{ order.orderNo }}</div>
            <div class="dispatch-row">
              <span class="dispatch-label">服务类型</span>
              <span>{{ order.serviceTypeName }}</span>
            </div>
            <div class="dispatch-row">
              <span class="dispatch-label">原预约时间</span>
              <span>{{ formatTime(order.appointTime) }}</span>
            </div>
            <div class="dispatch-row">
              <span class="dispatch-label">服务地址</span>
              <span class="dispatch-address">{{ order.addressSnapshot }}</span>
            </div>
          </div>
          <div class="dispatch-actions">
            <el-button
              type="primary"
              size="large"
              @click="$router.push(`/cleaner/orders/${order.id}`)"
            >
              查看详情
            </el-button>
          </div>
        </div>
      </el-card>
    </template>

    <!-- 统计卡片 -->
    <el-row :gutter="20" style="margin-top: 8px" v-loading="statsLoading">
      <el-col :span="6" v-for="stat in statCards" :key="stat.label">
        <div class="stat-card" :style="{ background: stat.bg }">
          <div class="stat-icon-wrap" :style="{ background: stat.iconBg }">
            <el-icon :size="22" :color="stat.color"><component :is="stat.icon" /></el-icon>
          </div>
          <div class="stat-value" :style="{ color: stat.color }">{{ stat.value }}</div>
          <div class="stat-label">{{ stat.label }}</div>
        </div>
      </el-col>
    </el-row>

    <!-- 今日订单 + 快捷操作 -->
    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="17">
        <el-card v-loading="todayLoading" class="today-card">
          <template #header>
            <div style="display:flex;justify-content:space-between;align-items:center">
              <span style="font-weight:600;font-size:15px">今日待服务订单</span>
              <el-tag size="small" type="info" round>{{ inServiceOrders.length + upcomingOrders.length }} 单</el-tag>
            </div>
          </template>

          <el-empty
            v-if="!todayLoading && inServiceOrders.length === 0 && upcomingOrders.length === 0"
            description="暂无待服务订单"
            :image-size="80"
          />

          <!-- 服务中（status=4）：置顶，高亮显示 -->
          <template v-if="inServiceOrders.length > 0">
            <div class="today-section-label today-section-label--inservice">
              <el-icon size="12"><Tools /></el-icon> 服务中
            </div>
            <div v-for="order in inServiceOrders" :key="order.id" class="today-order-item today-order-item--inservice">
              <div class="today-order-left">
                <el-tag type="primary" size="small" round>服务中</el-tag>
                <span class="today-order-time">{{ formatTime(order.appointTime) }}</span>
                <span class="today-order-type">{{ order.serviceTypeName }}</span>
              </div>
              <div class="today-order-right">
                <span class="today-order-addr">{{ order.addressSnapshot }}</span>
                <el-button
                  type="primary"
                  size="small"
                  @click="$router.push(`/cleaner/orders/${order.id}`)"
                >
                  去完工上报 →
                </el-button>
              </div>
            </div>
          </template>

          <!-- 待上门（status=3）：普通展示 -->
          <template v-if="upcomingOrders.length > 0">
            <div v-if="inServiceOrders.length > 0" class="today-section-label today-section-label--upcoming">
              <el-icon size="12"><Timer /></el-icon> 待上门
            </div>
            <div v-for="order in upcomingOrders" :key="order.id" class="today-order-item">
              <div class="today-order-left">
                <el-tag size="small" round>待上门</el-tag>
                <span class="today-order-time">{{ formatTime(order.appointTime) }}</span>
                <span class="today-order-type">{{ order.serviceTypeName }}</span>
              </div>
              <div class="today-order-right">
                <span class="today-order-addr">{{ order.addressSnapshot }}</span>
                <el-button
                  type="primary"
                  link
                  size="small"
                  @click="$router.push(`/cleaner/orders/${order.id}`)"
                >
                  查看详情 →
                </el-button>
              </div>
            </div>
          </template>
        </el-card>
      </el-col>

      <el-col :span="7">
        <el-card class="quick-card">
          <template #header>
            <span style="font-weight:600;font-size:15px">快捷操作</span>
          </template>
          <div class="quick-actions">
            <el-tooltip
              :disabled="canOperate"
              content="账号审核通过后才能接单"
              placement="left"
            >
              <div
                :class="['quick-btn', 'primary', !canOperate && 'quick-btn--disabled']"
                @click="canOperate && $router.push('/cleaner/grab')"
              >
                <el-icon size="18"><ShoppingBag /></el-icon>
                <span>去抢单</span>
              </div>
            </el-tooltip>
            <div class="quick-btn" @click="$router.push('/cleaner/orders')">
              <el-icon size="18"><List /></el-icon>
              <span>我的订单</span>
            </div>
            <div class="quick-btn" @click="$router.push('/cleaner/schedule')">
              <el-icon size="18"><Calendar /></el-icon>
              <span>管理档期</span>
            </div>
            <div class="quick-btn" @click="$router.push('/cleaner/income')">
              <el-icon size="18"><Wallet /></el-icon>
              <span>查看收入</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { formatTime } from '@/utils/time'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ShoppingBag, List, Calendar, Wallet, Warning, CircleClose, Bell, OfficeBuilding, Edit, Tools, Timer } from '@element-plus/icons-vue'
import { getCleanerStats, getCleanerOrders, acceptOrder, rejectOrder } from '@/api/order'
import { getUserInfo } from '@/api/auth'

const statsLoading = ref(false)
const todayLoading = ref(false)
const actionLoadingId = ref(null)

const stats = ref({ todayOrders: 0, pendingDispatch: 0, monthlyCompleted: 0, monthlyIncome: 0 })
const inServiceOrders = ref([])   // status=4
const upcomingOrders = ref([])    // status=3
const pendingDispatchOrders = ref([])
const pendingRescheduleOrders = ref([])

const accountAlert = ref(null)
// 只有账号正常（status!=3）且审核通过（auditStatus==1）才能操作
const canOperate = ref(true)

async function loadAccountStatus() {
  try {
    const info = await getUserInfo()
    const { auditStatus, status: userStatus } = info

    if (userStatus === 3) {
      canOperate.value = false
      accountAlert.value = {
        type: 'error',
        icon: CircleClose,
        title: '账号已被禁用',
        description: '账号已被禁用，请联系平台客服',
      }
    } else if (auditStatus === 3) {
      canOperate.value = false
      accountAlert.value = {
        type: 'error-audit',
        icon: CircleClose,
        title: '审核未通过',
        description: `审核未通过${info.auditRemark ? '：' + info.auditRemark : ''}，请修改后重新提交资料`,
      }
    } else if (auditStatus === 2 || auditStatus == null) {
      canOperate.value = false
      accountAlert.value = {
        type: 'warning',
        icon: Warning,
        title: '账号审核中',
        description: '您的账号正在审核中，审核通过后可接单。请先完善您的真实姓名和身份证信息。',
      }
    } else if (info.companyName) {
      canOperate.value = true
      accountAlert.value = {
        type: 'company',
        icon: OfficeBuilding,
        title: '公司保洁员',
        description: `您隶属于「${info.companyName}」，如有问题请联系公司负责人`,
      }
    } else {
      canOperate.value = true
      accountAlert.value = null
    }
  } catch {
    // 获取状态失败不影响主流程
  }
}

const statCards = computed(() => [
  { label: '今日订单', value: stats.value.todayOrders,       icon: 'Calendar', color: '#10b981', bg: '#fff', iconBg: 'rgba(16,185,129,.1)' },
  { label: '待接单',   value: stats.value.pendingDispatch,   icon: 'Bell',     color: '#f59e0b', bg: '#fff', iconBg: 'rgba(245,158,11,.1)' },
  { label: '本月完成', value: stats.value.monthlyCompleted,  icon: 'Check',    color: '#14b8a6', bg: '#fff', iconBg: 'rgba(20,184,166,.1)' },
  { label: '本月收入', value: '¥' + (stats.value.monthlyIncome ?? 0), icon: 'Wallet', color: '#0ea5e9', bg: '#fff', iconBg: 'rgba(14,165,233,.1)' },
])

async function loadStats() {
  statsLoading.value = true
  try {
    stats.value = await getCleanerStats()
  } catch {
    // ignore
  } finally {
    statsLoading.value = false
  }
}

async function loadTodayOrders() {
  todayLoading.value = true
  try {
    const res = await getCleanerOrders({ current: 1, size: 20 })
    const allOrders = res.records ?? []
    const today = new Date().toDateString()

    // status=4 和 3 按今日日期过滤，status=9 单独展示，不在 today 列表
    inServiceOrders.value = allOrders.filter(o =>
      o.status === 4 && new Date(o.appointTime).toDateString() === today
    )
    upcomingOrders.value = allOrders.filter(o =>
      o.status === 3 && new Date(o.appointTime).toDateString() === today
    )
    pendingDispatchOrders.value = allOrders.filter(o => o.status === 2)
    pendingRescheduleOrders.value = allOrders.filter(o => o.status === 9)
  } catch {
    ElMessage.error('加载订单数据失败')
  } finally {
    todayLoading.value = false
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
  } finally {
    actionLoadingId.value = null
  }
}

async function doReject(orderId) {
  await ElMessageBox.confirm('确认拒绝此派单？订单将退回待派单池', '拒绝接单', { type: 'warning' })
  actionLoadingId.value = orderId + '_reject'
  try {
    await rejectOrder(orderId)
    ElMessage.info('已拒绝，订单已退回')
    await Promise.all([loadStats(), loadTodayOrders()])
  } catch (e) {
    ElMessage.error(e?.message || '操作失败')
  } finally {
    actionLoadingId.value = null
  }
}

let timer = null
onMounted(() => {
  loadAccountStatus()
  loadStats()
  loadTodayOrders()
  timer = setInterval(() => {
    loadStats()
    loadTodayOrders()
  }, 30000)
})
onUnmounted(() => clearInterval(timer))
</script>

<style scoped>
/* 改期待处理横幅 */
.reschedule-banner {
  background: linear-gradient(135deg, #3b82f6, var(--cm-primary));
  border-radius: var(--cm-radius-md);
  padding: 12px 20px;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 10px;
  color: #fff;
  font-size: 14px;
  font-weight: 600;
}

/* 待接单横幅 */
.dispatch-banner {
  background: linear-gradient(135deg, var(--cm-warning), #d97706);
  border-radius: var(--cm-radius-md);
  padding: 14px 20px;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  box-shadow: 0 2px 8px rgba(245,158,11,.3);
}
.dispatch-banner-title {
  display: flex;
  align-items: center;
  gap: 10px;
  color: #fff;
  font-size: 15px;
  font-weight: 600;
}

/* 派单卡片 */
.dispatch-card {
  margin-bottom: 12px;
  border: 2px solid #fbbf24;
  border-radius: var(--cm-radius-md);
}
.dispatch-card-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}
.dispatch-info { flex: 1; }
.dispatch-order-no {
  font-weight: 700;
  font-size: 13px;
  color: #6b7280;
  margin-bottom: 8px;
}
.dispatch-row {
  display: flex;
  gap: 10px;
  font-size: 14px;
  margin-bottom: 4px;
  align-items: flex-start;
}
.dispatch-label {
  color: #9ca3af;
  flex-shrink: 0;
  width: 60px;
}
.dispatch-address { color: #374151; }
.dispatch-fee { color: #ef4444; font-weight: 700; font-size: 16px; }
.dispatch-actions {
  display: flex;
  flex-direction: column;
  gap: 10px;
  flex-shrink: 0;
}

/* 统计卡片 */
.stat-card {
  border-radius: var(--cm-radius-md);
  padding: 22px 16px 18px;
  text-align: center;
  cursor: default;
  border: 1px solid #e4e4e7;
  box-shadow: var(--cm-shadow-sm);
  transition: transform .2s, box-shadow .2s;
}
.stat-card:hover { transform: translateY(-3px); box-shadow: var(--cm-shadow-md); }
.stat-icon-wrap {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  margin-bottom: 12px;
}
.stat-value { font-size: 30px; font-weight: 700; margin-bottom: 6px; }
.stat-label { font-size: 13px; color: #71717a; }

/* 今日订单 */
.today-card :deep(.el-card__body) { padding: 0 20px; }

/* 分段标签 */
.today-section-label {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 11px;
  font-weight: 600;
  padding: 6px 0 4px;
  border-bottom: 1px solid #f3f4f6;
}
.today-section-label--inservice { color: #0ea5e9; }
.today-section-label--upcoming  { color: #6b7280; margin-top: 4px; }

.today-order-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 13px 0;
  border-bottom: 1px solid #f3f4f6;
  gap: 12px;
}
.today-order-item:last-child { border-bottom: none; }

/* 服务中条目：左侧蓝色竖线强调 */
.today-order-item--inservice {
  background: #f0f9ff;
  border-radius: 6px;
  padding: 13px 10px;
  border-left: 3px solid #0ea5e9;
  border-bottom: 1px solid #e0f2fe;
  margin-bottom: 2px;
}
.today-order-item--inservice:last-child { border-bottom: 1px solid #e0f2fe; }

.today-order-left {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-shrink: 0;
}
.today-order-time { font-size: 13px; color: #6b7280; }
.today-order-type { font-size: 14px; font-weight: 500; color: #111; }
.today-order-right {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
}
.today-order-addr {
  font-size: 13px;
  color: #6b7280;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 280px;
}

/* 快捷操作 */
.quick-card :deep(.el-card__body) { padding: 12px 16px; }
.quick-actions { display: flex; flex-direction: column; gap: 10px; }
.quick-btn {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 16px;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  color: #374151;
  background: #fff;
  transition: all .18s;
}
.quick-btn:hover { border-color: var(--cm-success); color: var(--cm-success); background: #f0fdf4; transform: translateX(2px); }
.quick-btn.primary { background: var(--cm-success); color: #fff; border-color: var(--cm-success); }
.quick-btn.primary:hover { background: #059669; border-color: #059669; color: #fff; }
.quick-btn--disabled {
  opacity: .45;
  cursor: not-allowed;
  pointer-events: none;
}

/* 账号状态提示条 */
.account-alert {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 12px 16px;
  border-radius: 8px;
  margin-bottom: 16px;
  font-size: 13px;
}
.account-alert--warning  { background: #fffbeb; border: 1px solid #fcd34d; color: #92400e; }
.account-alert--error,
.account-alert--error-audit { background: #fef2f2; border: 1px solid #fca5a5; color: #991b1b; }
.account-alert--company  { background: #eff6ff; border: 1px solid #93c5fd; color: #1e40af; }
.account-alert-left { display: flex; align-items: flex-start; gap: 10px; }
.account-alert-title { font-weight: 600; margin-bottom: 2px; }
.account-alert-desc  { color: inherit; opacity: .85; line-height: 1.5; }
</style>