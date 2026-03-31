<template>
  <div>
    <!-- 当前/即将上门订单（有数据时才显示，置顶） -->
    <template v-if="activeOrder">
      <div :class="['active-order-banner', activeOrder.status === 4 ? 'active-order-banner--inservice' : 'active-order-banner--upcoming']">
        <el-icon size="18"><component :is="activeOrder.status === 4 ? 'Tools' : 'Timer'" /></el-icon>
        <span>{{ activeOrder.status === 4 ? '保洁员正在为您服务中' : '保洁员即将上门' }}</span>
      </div>
      <el-card class="active-order-card" shadow="always" @click="$router.push(`/customer/orders/${activeOrder.id}`)">
        <div class="active-order-inner">
          <div class="active-order-info">
            <div class="active-order-header">
              <el-tag :type="activeOrder.status === 4 ? 'primary' : ''" size="small" round>
                {{ activeOrder.status === 4 ? '服务中' : '待上门' }}
              </el-tag>
              <span class="active-order-no">{{ activeOrder.orderNo }}</span>
            </div>
            <div class="active-order-row">
              <el-icon size="14" color="#71717a"><Calendar /></el-icon>
              <span>{{ formatTime(activeOrder.appointTime) }}</span>
            </div>
            <div class="active-order-row">
              <el-icon size="14" color="#71717a"><Location /></el-icon>
              <span class="active-order-addr">{{ activeOrder.addressSnapshot }}</span>
            </div>
            <div class="active-order-row">
              <el-icon size="14" color="#71717a"><Briefcase /></el-icon>
              <span>{{ activeOrder.serviceTypeName }}</span>
            </div>
          </div>
          <el-button type="primary" size="default" round style="flex-shrink:0">
            查看详情 →
          </el-button>
        </div>
      </el-card>
    </template>

    <!-- Banner -->
    <div class="welcome-banner" :style="{ marginTop: activeOrder ? '16px' : '0' }">
      <div class="b-ring b-ring-1"></div>
      <div class="b-ring b-ring-2"></div>
      <div class="b-ring b-ring-3"></div>
      <div class="banner-body">
        <div class="banner-greeting">您好，{{ userStore.userInfo?.nickname }}</div>
        <h2 class="banner-title">专业保洁，让家焕然一新</h2>
        <p class="banner-sub">一键预约，专业保洁员上门服务</p>
        <el-button size="large" round @click="$router.push('/customer/book')" class="banner-btn">
          立即预约
        </el-button>
      </div>
      <div class="banner-trust">
        <div class="trust-item">
          <span class="trust-num">10,000<sup>+</sup></span>
          <span class="trust-label">累计服务次数</span>
        </div>
        <div class="trust-divider"></div>
        <div class="trust-item">
          <span class="trust-num">98%</span>
          <span class="trust-label">客户满意度</span>
        </div>
        <div class="trust-divider"></div>
        <div class="trust-item">
          <span class="trust-num">200<sup>+</sup></span>
          <span class="trust-label">专业保洁员</span>
        </div>
      </div>
    </div>

    <!-- 统计卡片 -->
    <el-row :gutter="16" style="margin-top: 20px">
      <el-col :span="8" v-for="stat in statCards" :key="stat.label">
        <div class="stat-card">
          <div class="stat-icon-wrap" :style="{ background: stat.iconBg }">
            <el-icon :size="22" :color="stat.color"><component :is="stat.icon" /></el-icon>
          </div>
          <div class="stat-body">
            <div class="stat-value" :style="{ color: stat.color }">{{ stat.value }}</div>
            <div class="stat-label">{{ stat.label }}</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 热门服务 -->
    <div class="section-header">
      <span class="section-title">热门服务</span>
      <el-button type="primary" link @click="$router.push('/customer/book')">查看全部 →</el-button>
    </div>
    <el-row :gutter="16">
      <el-col :span="8" v-for="svc in services" :key="svc.name" style="margin-bottom: 16px">
        <div class="service-card" @click="$router.push('/customer/book')">
          <div class="service-icon" :style="{ background: svc.color }">{{ svc.name.slice(0, 1) }}</div>
          <div class="service-info">
            <div class="service-name">{{ svc.name }}</div>
            <div class="service-desc">{{ svc.desc }}</div>
            <div class="service-price">{{ svc.price }}</div>
          </div>
          <el-button size="small" round style="flex-shrink:0" @click.stop="$router.push('/customer/book')">预约</el-button>
        </div>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { formatTime } from '@/utils/time'
import { useUserStore } from '@/store/user'
import { getCustomerStats, getMyOrders } from '@/api/order'

const userStore = useUserStore()

const rawStats = ref({ total: 0, pending: 0, done: 0 })
const activeOrder = ref(null)

// 去掉硬编码好评率，改为 3 个真实统计项
const statCards = computed(() => [
  { label: '累计预约', value: rawStats.value.total,   icon: 'Calendar', color: '#0ea5e9', iconBg: 'rgba(14,165,233,.1)' },
  { label: '待服务',   value: rawStats.value.pending, icon: 'Clock',    color: '#06b6d4', iconBg: 'rgba(6,182,212,.1)'  },
  { label: '已完成',   value: rawStats.value.done,    icon: 'Check',    color: '#14b8a6', iconBg: 'rgba(20,184,166,.1)'  },
])

async function loadStats() {
  try {
    const data = await getCustomerStats()
    rawStats.value = { total: data.total, pending: data.pending, done: data.done }
  } catch {}
}

async function loadActiveOrder() {
  try {
    // 优先 status=4（服务中），其次 status=3（待上门）
    const res = await getMyOrders({ current: 1, size: 20 })
    const orders = res.records ?? res ?? []
    activeOrder.value =
      orders.find(o => o.status === 4) ||
      orders.find(o => o.status === 3) ||
      null
  } catch {}
}

let timer = null
onMounted(() => {
  loadStats()
  loadActiveOrder()
  timer = setInterval(loadActiveOrder, 30000)
})
onUnmounted(() => clearInterval(timer))

const services = [
  { name: '日常保洁', desc: '日常家庭清洁，让家焕然一新', price: '¥35/时', color: '#0ea5e9' },
  { name: '深度保洁', desc: '全屋深度清洁，不留死角',     price: '¥50/时', color: '#0284c7' },
  { name: '开荒保洁', desc: '新房装修后的首次清洁',       price: '¥60/时', color: '#06b6d4' },
  { name: '家电清洗', desc: '空调、油烟机等家电专业清洗', price: '¥80/台', color: '#0891b2' },
  { name: '玻璃清洗', desc: '门窗玻璃专业清洁',           price: '¥10/㎡', color: '#14b8a6' },
  { name: '地板打蜡', desc: '木地板养护打蜡服务',         price: '¥15/㎡', color: '#0d9488' },
]
</script>

<style scoped>
/* ── 当前/即将上门订单 ── */
.active-order-banner {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  border-radius: var(--cm-radius-md) var(--cm-radius-md) 0 0;
  font-size: 13px;
  font-weight: 600;
  color: #fff;
}
.active-order-banner--inservice {
  background: linear-gradient(90deg, #0ea5e9, #0284c7);
}
.active-order-banner--upcoming {
  background: linear-gradient(90deg, #14b8a6, #0d9488);
}
.active-order-card {
  cursor: pointer;
  border-radius: 0 0 var(--cm-radius-md) var(--cm-radius-md);
  border-top: none;
  transition: box-shadow .2s;
}
.active-order-card:hover { box-shadow: 0 6px 24px rgba(14,165,233,.18); }
.active-order-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}
.active-order-info { flex: 1; min-width: 0; }
.active-order-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}
.active-order-no { font-size: 12px; color: #9ca3af; }
.active-order-row {
  display: flex;
  align-items: flex-start;
  gap: 6px;
  font-size: 13px;
  color: #374151;
  margin-bottom: 5px;
}
.active-order-addr {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 420px;
}

/* ── Banner ── */
.welcome-banner {
  position: relative;
  overflow: hidden;
  background: linear-gradient(135deg, #0369a1 0%, var(--cm-primary) 100%);
  color: #fff;
  border-radius: var(--cm-radius-lg);
  padding: 36px 48px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 8px 32px rgba(3,105,161,.22);
  min-height: 180px;
}

/* 装饰圆环 */
.b-ring {
  position: absolute;
  border-radius: 50%;
  pointer-events: none;
}
.b-ring-1 {
  width: 260px; height: 260px;
  top: -90px; right: 340px;
  border: 1px solid rgba(255,255,255,.14);
}
.b-ring-2 {
  width: 340px; height: 340px;
  bottom: -180px; right: 100px;
  background: rgba(255,255,255,.05);
  border: 1px solid rgba(255,255,255,.08);
}
.b-ring-3 {
  width: 120px; height: 120px;
  top: 16px; right: 480px;
  background: rgba(255,255,255,.06);
}

.banner-body { position: relative; z-index: 1; }
.banner-greeting { font-size: 14px; opacity: .8; margin-bottom: 6px; }
.banner-title  { font-size: 28px; font-weight: 700; margin: 0 0 8px; letter-spacing: -0.5px; }
.banner-sub    { font-size: 14px; opacity: .75; margin-bottom: 24px; }
.banner-btn {
  background: rgba(255,255,255,.95);
  color: #0369a1;
  border: none;
  font-weight: 600;
  padding: 0 28px;
}
.banner-btn:hover { background: #fff; color: #0369a1; }

/* 右侧信任指标 */
.banner-trust {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  gap: 24px;
  background: rgba(255,255,255,.14);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255,255,255,.22);
  border-radius: var(--cm-radius-md);
  padding: 20px 28px;
  flex-shrink: 0;
}
.trust-item { text-align: center; }
.trust-num {
  display: block;
  font-size: 24px;
  font-weight: 700;
  line-height: 1.2;
}
.trust-num sup { font-size: 13px; vertical-align: super; font-weight: 600; }
.trust-label  { font-size: 12px; color: rgba(255,255,255,.72); margin-top: 3px; display: block; }
.trust-divider { width: 1px; height: 38px; background: rgba(255,255,255,.2); }

/* ── 统计卡片 ── */
.stat-card {
  display: flex;
  align-items: center;
  gap: 16px;
  background: #fff;
  border-radius: var(--cm-radius-md);
  padding: 20px 22px;
  border: 1px solid #e4e4e7;
  box-shadow: var(--cm-shadow-sm);
  transition: transform .2s, box-shadow .2s;
  cursor: default;
}
.stat-card:hover { transform: translateY(-2px); box-shadow: var(--cm-shadow-md); }
.stat-icon-wrap {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 48px; height: 48px;
  border-radius: 12px;
  flex-shrink: 0;
}
.stat-body { flex: 1; min-width: 0; }
.stat-value { font-size: 28px; font-weight: 700; line-height: 1.2; margin-bottom: 4px; }
.stat-label { font-size: 13px; color: #71717a; }

/* ── 板块标题 ── */
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 28px 0 14px;
}
.section-title {
  font-size: 17px;
  font-weight: 700;
  color: #18181b;
  display: flex;
  align-items: center;
  gap: 8px;
}
.section-title::before {
  content: '';
  display: inline-block;
  width: 3px; height: 16px;
  background: var(--cm-primary);
  border-radius: 2px;
}

/* ── 服务卡片 ── */
.service-card {
  display: flex;
  align-items: center;
  gap: 14px;
  background: #fff;
  border: 1px solid #e4e4e7;
  border-radius: var(--cm-radius-md);
  padding: 18px 20px;
  cursor: pointer;
  transition: all .2s;
}
.service-card:hover {
  border-color: var(--cm-primary);
  box-shadow: 0 4px 20px rgba(14,165,233,.14);
  transform: translateY(-2px);
}
.service-icon {
  width: 46px; height: 46px; border-radius: 12px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  color: #fff; font-size: 17px; font-weight: 700;
}
.service-info { flex: 1; min-width: 0; }
.service-name  { font-size: 14px; font-weight: 600; color: #18181b; margin-bottom: 3px; }
.service-desc  { font-size: 12px; color: #a1a1aa; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 5px; }
.service-price { font-size: 13px; color: #f43f5e; font-weight: 600; }
</style>