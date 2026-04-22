<template>
  <div class="home-wrap">

    <!-- 当前/即将上门订单（有数据时才显示，置顶） -->
    <template v-if="activeOrder">
      <div :class="['active-order-banner', activeOrder.status === 4 ? 'active-order-banner--inservice' : 'active-order-banner--upcoming']">
        <el-icon size="18"><component :is="activeOrder.status === 4 ? 'Tools' : 'Timer'" /></el-icon>
        <span>{{ activeOrder.status === 4 ? '保洁员正在为您服务中' : '保洁员即将上门' }}</span>
      </div>
      <el-card class="active-order-card" shadow="never" @click="$router.push(`/customer/orders/${activeOrder.id}`)">
        <div class="active-order-inner">
          <div class="active-order-info">
            <div class="active-order-header">
              <el-tag size="small" round class="aoc-tag">
                {{ activeOrder.status === 4 ? '服务中' : '待上门' }}
              </el-tag>
              <span class="active-order-no">{{ activeOrder.orderNo }}</span>
            </div>
            <div class="active-order-row">
              <el-icon size="14" color="#A8A09A"><Calendar /></el-icon>
              <span>{{ formatTime(activeOrder.appointTime) }}</span>
            </div>
            <div class="active-order-row">
              <el-icon size="14" color="#A8A09A"><Location /></el-icon>
              <span class="active-order-addr">{{ activeOrder.addressSnapshot }}</span>
            </div>
            <div class="active-order-row">
              <el-icon size="14" color="#A8A09A"><Briefcase /></el-icon>
              <span>{{ activeOrder.serviceTypeName }}</span>
            </div>
          </div>
          <el-button size="default" round class="aoc-detail-btn">查看详情 →</el-button>
        </div>
      </el-card>
    </template>

    <!-- Hero Banner -->
    <div class="hero-banner" :style="{ marginTop: activeOrder ? '20px' : '0' }">
      <p class="hero-greeting">您好，{{ userStore.userInfo?.nickname }}</p>
      <h1 class="hero-title">让居家生活，重回纯净与自然</h1>
      <el-button class="hero-btn" round @click="$router.push('/customer/book')">立即预约</el-button>
    </div>

    <!-- 信任指标行 -->
    <div class="trust-row">
      <div class="trust-item" v-for="(item, i) in trustIndicators" :key="i">
        <span class="trust-num">{{ item.num }}<sup v-if="item.sup">{{ item.sup }}</sup></span>
        <span class="trust-label">{{ item.label }}</span>
      </div>
    </div>

    <!-- 我的订单统计 -->
    <el-row :gutter="16" style="margin-top: 24px">
      <el-col :span="8" v-for="stat in statCards" :key="stat.label">
        <div
          class="stat-card"
          :class="{ 'stat-card--clickable': stat.route }"
          @click="stat.route && $router.push(stat.route)"
        >
          <div class="stat-icon-wrap" :style="{ background: stat.iconBg }">
            <el-icon :size="20" :color="stat.iconColor"><component :is="stat.icon" /></el-icon>
          </div>
          <div class="stat-body">
            <div class="stat-value" :style="{ color: stat.color }">{{ stat.value }}</div>
            <div class="stat-label">{{ stat.label }}</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 保洁服务分类 -->
    <div class="section-header">
      <span class="section-title">保洁服务</span>
      <el-button link class="see-all-btn" @click="$router.push('/customer/book')">立即预约 →</el-button>
    </div>
    <div class="services-grid">
      <div
        class="svc-card"
        v-for="svc in services"
        :key="svc.name"
        @click="$router.push('/customer/book')"
      >
        <div class="svc-img" :style="imgFailed[svc.id] || !svc.coverImg ? { background: svc.bg } : {}">
          <img
            v-if="svc.coverImg && !imgFailed[svc.id]"
            :src="svc.coverImg"
            class="svc-cover-img"
            @error="imgFailed[svc.id] = true"
          />
          <span v-else class="svc-emoji">{{ svc.icon }}</span>
        </div>
        <div class="svc-body">
          <div class="svc-top-row">
            <span class="svc-name">{{ svc.name }}</span>
          </div>
<div class="svc-footer">
            <div>
              <span class="svc-price">{{ svc.price }}</span>
              <span class="svc-unit">起</span>
            </div>
            <button class="svc-book-btn" @click.stop="$router.push('/customer/book')">→</button>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { formatTime } from '@/utils/time'
import { useUserStore } from '@/store/user'
import { getCustomerStats, getMyOrders } from '@/api/order'
import { getServiceTypes } from '@/api/service'
import { trustIndicators, services as serviceConfig } from '@/config/homeConfig'

const userStore = useUserStore()

const rawStats = ref({ total: 0, pending: 0, done: 0 })
const activeOrder = ref(null)
const serviceTypes = ref([])
const imgFailed = ref({})

const services = computed(() => {
  return serviceTypes.value.map((st, index) => {
    const config = serviceConfig[index] || {}
    let priceText = ''
    if (st.priceMode === 1) {
      priceText = `¥${st.basePrice}/小时`
    } else if (st.priceMode === 2) {
      priceText = `¥${st.basePrice}/㎡`
    } else {
      priceText = `¥${st.basePrice}`
    }
    return {
      id: st.id,
      name: st.name,
      desc: st.description || config.desc || '',
      price: priceText,
      icon: config.icon || '🏠',
      bg: config.bg || 'linear-gradient(135deg, #E8F0EA 0%, #D8E6DB 100%)',
      coverImg: st.coverImg || '',
    }
  })
})

const statCards = computed(() => [
  { label: '累计预约', value: rawStats.value.total,   icon: 'Calendar', color: '#2D4A33', iconBg: 'rgba(45,74,51,.12)', iconColor: '#2D4A33', route: '/customer/orders' },
  { label: '待服务',   value: rawStats.value.pending, icon: 'Clock',    color: '#D97706', iconBg: 'rgba(217,119,6,.10)', iconColor: '#D97706', route: '/customer/orders' },
  { label: '已完成',   value: rawStats.value.done,    icon: 'Check',    color: '#2D4A33', iconBg: 'rgba(45,74,51,.12)', iconColor: '#2D4A33', route: '/customer/orders' },
])

async function loadStats() {
  try {
    const data = await getCustomerStats()
    rawStats.value = { total: data.total, pending: data.pending, done: data.done }
  } catch {}
}

async function loadActiveOrder() {
  try {
    const res = await getMyOrders({ current: 1, size: 20 })
    const orders = res.records ?? res ?? []
    activeOrder.value =
      orders.find(o => o.status === 4) ||
      orders.find(o => o.status === 3) ||
      null
  } catch {}
}

async function loadServiceTypes() {
  try {
    serviceTypes.value = await getServiceTypes()
  } catch {}
}

let timer = null
onMounted(() => {
  loadStats()
  loadActiveOrder()
  loadServiceTypes()
  timer = setInterval(loadActiveOrder, 30000)
})
onUnmounted(() => clearInterval(timer))
</script>

<style scoped>
.home-wrap { padding-bottom: 48px; }

/* ── 当前订单横幅 ── */
.active-order-banner {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  border-radius: 14px 14px 0 0;
  font-size: 13px;
  font-weight: 600;
  color: #fff;
}
.active-order-banner--inservice { background: linear-gradient(90deg, #2D4A33, #1F3324); }
.active-order-banner--upcoming  { background: linear-gradient(90deg, #C4A882, #A88A68); }

.active-order-card {
  cursor: pointer;
  border-radius: 0 0 14px 14px !important;
  border-top: none !important;
  border-color: #E8E2D8 !important;
  background: #fff !important;
  transition: box-shadow .2s;
}
.active-order-card:hover { box-shadow: 0 6px 20px rgba(0,0,0,.08) !important; }
.active-order-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}
.active-order-info { flex: 1; min-width: 0; }
.active-order-header { display: flex; align-items: center; gap: 10px; margin-bottom: 10px; }
.active-order-no { font-size: 12px; color: #B8B0A8; }
.active-order-row {
  display: flex;
  align-items: flex-start;
  gap: 6px;
  font-size: 13px;
  color: #5A5450;
  margin-bottom: 5px;
}
.active-order-addr { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 420px; }
:deep(.aoc-tag) {
  background: #E8F0EA !important;
  color: #2D4A33 !important;
  border-color: #A3BDA9 !important;
}
.aoc-detail-btn {
  flex-shrink: 0;
  background: #F8F7F4 !important;
  border-color: #E8E2D8 !important;
  color: #5A5450 !important;
  font-size: 13px !important;
}

/* ── Hero Banner ── */
.hero-banner {
  text-align: center;
  padding: 52px 24px 48px;
}
.hero-greeting {
  font-size: 14px;
  color: #8A857E;
  margin-bottom: 14px;
}
.hero-title {
  font-size: 34px;
  font-weight: 700;
  color: #3A3734;
  line-height: 1.3;
  margin-bottom: 28px;
  letter-spacing: -0.5px;
}
.hero-btn {
  background: #2D4A33 !important;
  color: #fff !important;
  border-color: #2D4A33 !important;
  padding: 0 36px !important;
  height: 44px !important;
  font-size: 15px !important;
  font-weight: 600 !important;
  box-shadow: 0 4px 14px rgba(45,74,51,.35) !important;
  transition: background .2s, box-shadow .2s !important;
}
.hero-btn:hover {
  background: #1F3324 !important;
  box-shadow: 0 6px 18px rgba(45,74,51,.45) !important;
}

/* ── 信任指标行 ── */
.trust-row {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 56px;
  padding: 22px 0 6px;
}
.trust-item { text-align: center; }
.trust-num {
  display: block;
  font-size: 22px;
  font-weight: 700;
  color: #3A3734;
  line-height: 1.2;
}
.trust-num sup { font-size: 12px; vertical-align: super; }
.trust-label { font-size: 12px; color: #8A857E; margin-top: 3px; display: block; }

/* ── 统计卡片 ── */
.stat-card {
  display: flex;
  align-items: center;
  gap: 14px;
  background: #fff;
  border-radius: 14px;
  padding: 20px 22px;
  border: 1px solid #EDE8DF;
  transition: transform .2s, box-shadow .2s;
  cursor: default;
}
.stat-card--clickable { cursor: pointer; }
.stat-card--clickable:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,.08); }
.stat-icon-wrap {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 44px; height: 44px;
  border-radius: 12px;
  flex-shrink: 0;
}
.stat-body { flex: 1; min-width: 0; }
.stat-value { font-size: 26px; font-weight: 700; line-height: 1.2; margin-bottom: 3px; }
.stat-label { font-size: 12px; color: #8A857E; }

/* ── 板块标题 ── */
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 32px 0 16px;
}
.section-title {
  font-size: 17px;
  font-weight: 700;
  color: #3A3734;
  display: flex;
  align-items: center;
  gap: 8px;
}
.section-title::before {
  content: '';
  display: inline-block;
  width: 3px; height: 16px;
  background: #2D4A33;
  border-radius: 2px;
}
.see-all-btn { color: #2D4A33 !important; font-size: 13px !important; }

/* ── 服务卡片网格 ── */
.services-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}
.svc-card {
  background: #fff;
  border-radius: 16px;
  border: 1px solid #EDE8DF;
  overflow: hidden;
  cursor: pointer;
  transition: transform .22s, box-shadow .22s, border-color .22s;
}
.svc-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 28px rgba(0,0,0,.09);
  border-color: #A3BDA9;
}
.svc-img {
  position: relative;
  height: 136px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.svc-cover-img { width: 100%; height: 100%; object-fit: cover; display: block; }
.svc-emoji { font-size: 48px; line-height: 1; }
.svc-body { padding: 14px 16px 16px; }
.svc-top-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.svc-name { font-size: 15px; font-weight: 600; color: #3A3734; }
.svc-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.svc-price { font-size: 18px; font-weight: 700; color: #2D4A33; }
.svc-unit { font-size: 12px; color: #B8B0A8; font-weight: 400; margin-left: 2px; }
.svc-book-btn {
  width: 32px; height: 32px;
  border-radius: 50%;
  border: 1.5px solid #E8E2D8;
  background: #F8F7F4;
  color: #8A857E;
  font-size: 15px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all .2s;
  line-height: 1;
}
.svc-book-btn:hover {
  background: #2D4A33;
  color: #fff;
  border-color: #2D4A33;
}
</style>
