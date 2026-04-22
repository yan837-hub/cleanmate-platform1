<template>
  <div class="dashboard">

    <!-- ① 概览卡片（6张） -->
    <el-row :gutter="16" style="align-items:stretch">
      <el-col :span="4" v-for="card in overviewCards" :key="card.label" style="display:flex">
        <div class="stat-card" :style="{ borderTopColor: card.color }"
             :class="{ clickable: card.route }"
             @click="card.route && $router.push(card.route)">
          <div class="stat-icon" :style="{ background: card.bgColor }">
            <el-icon :size="20" :color="card.color"><component :is="card.icon" /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value" :style="{ color: card.color }">{{ card.value }}</div>
            <div class="stat-label">{{ card.label }}</div>
          </div>
          <el-badge v-if="card.badge" :value="card.badge" class="card-badge" type="danger" />
        </div>
      </el-col>
    </el-row>

    <!-- ② 待办快捷操作 -->
    <el-row :gutter="16" style="margin-top:16px">
      <el-col :span="8" v-for="todo in todoCards" :key="todo.label">
        <div class="todo-card" :style="{ borderLeftColor: todo.color }">
          <div class="todo-left">
            <div class="todo-icon" :style="{ background: todo.bgColor }">
              <el-icon :size="18" :color="todo.color"><component :is="todo.icon" /></el-icon>
            </div>
            <div>
              <div class="todo-label">{{ todo.label }}</div>
              <div class="todo-count">
                <span v-if="todo.count > 0" class="todo-count-num" :style="{ color: todo.color }">{{ todo.count }} 条待处理</span>
                <span v-else class="todo-count-none">暂无待处理</span>
              </div>
            </div>
          </div>
          <el-button
            :type="todo.count > 0 ? 'primary' : 'default'"
            size="small"
            :disabled="todo.count === 0"
            @click="$router.push(todo.route)"
          >立即处理</el-button>
        </div>
      </el-col>
    </el-row>

    <!-- ③ 图表区 -->
    <el-row :gutter="16" style="margin-top:20px">

      <!-- 折线图：订单趋势 -->
      <el-col :span="15">
        <el-card>
          <template #header>
            <div class="chart-header">
              <span class="card-title">订单趋势</span>
              <el-radio-group v-model="trendDays" size="small" @change="loadTrend">
                <el-radio-button :value="7">近7天</el-radio-button>
                <el-radio-button :value="30">近30天</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div ref="lineChartRef" style="height:280px" v-loading="trendLoading" />
        </el-card>
      </el-col>

      <!-- 饼图：服务类型 -->
      <el-col :span="9">
        <el-card>
          <template #header>
            <span class="card-title">服务类型分布（近30天）</span>
          </template>
          <div ref="pieChartRef" style="height:280px" v-loading="pieLoading" />
        </el-card>
      </el-col>

    </el-row>

    <!-- ③ 绩效排名表格 -->
    <el-card style="margin-top:20px">
      <template #header>
        <div class="chart-header">
          <span class="card-title">保洁员绩效排名</span>
          <el-button type="primary" link @click="$router.push('/admin/audit/cleaners')">查看全部 →</el-button>
        </div>
      </template>
      <el-table :data="rankList" v-loading="rankLoading" size="small">
        <el-table-column label="排名" width="60" align="center">
          <template #default="{ $index }">
            <span :class="['rank-badge', `rank-${$index + 1}`]">{{ $index + 1 }}</span>
          </template>
        </el-table-column>

        <el-table-column label="姓名" width="90">
          <template #default="{ row }">
            <el-button type="primary" link
              @click="$router.push(`/admin/audit/cleaners?id=${row.cleanerId}`)">
              {{ row.realName }}
            </el-button>
          </template>
        </el-table-column>

        <el-table-column label="公司" prop="companyName" min-width="100" show-overflow-tooltip />
        <el-table-column label="接单数" prop="orderCount" width="80" align="center" sortable />

        <el-table-column label="完成率" width="90" align="center" sortable
                         :sort-method="(a,b) => a.completionRate - b.completionRate">
          <template #default="{ row }">
            <span :class="completionClass(row.completionRate)">
              {{ formatPct(row.completionRate) }}
            </span>
          </template>
        </el-table-column>

        <el-table-column label="平均评分" width="90" align="center" sortable
                         :sort-method="(a,b) => a.avgScore - b.avgScore">
          <template #default="{ row }">
            <span style="color:#d97706;font-weight:600">
              {{ Number(row.avgScore).toFixed(1) }}
            </span>
          </template>
        </el-table-column>

        <el-table-column label="投诉次数" prop="complaintCount" width="90" align="center" sortable>
          <template #default="{ row }">
            <el-tag :type="row.complaintCount > 0 ? 'danger' : 'success'" size="small">
              {{ row.complaintCount }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column label="本月收入" width="100" align="right" sortable
                         :sort-method="(a,b) => a.monthIncome - b.monthIncome">
          <template #default="{ row }">
            ¥{{ Number(row.monthIncome).toFixed(2) }}
          </template>
        </el-table-column>
      </el-table>
    </el-card>

  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import * as echarts from 'echarts'
import {
  getOverview,
  getStatsTrend,
  getServiceTypeStats,
  getCleanerRank,
} from '@/api/admin'

const router = useRouter()

// ────────────────────────────────────────────────
// 概览卡片
// ────────────────────────────────────────────────
const overviewCards = ref([
  { label: '今日新增订单', value: 0,    icon: 'Document',    color: '#2563eb', bgColor: '#eff6ff', route: '/admin/orders' },
  { label: '今日完成',     value: 0,    icon: 'CircleCheck', color: '#16a34a', bgColor: '#f0fdf4', route: null },
  { label: '进行中',       value: 0,    icon: 'Loading',     color: '#d97706', bgColor: '#fffbeb', route: '/admin/orders' },
  { label: '今日收入',     value: '¥0', icon: 'Money',       color: '#7c3aed', bgColor: '#f5f3ff', route: null },
  { label: '保洁员总数',   value: 0,    icon: 'User',        color: '#0891b2', bgColor: '#ecfeff', route: '/admin/audit/cleaners' },
  { label: '待审核',       value: 0,    icon: 'Bell',        color: '#dc2626', bgColor: '#fef2f2', route: '/admin/audit/cleaners', badge: null },
])

const todoCards = ref([
  { label: '保洁员资质审核', count: 0, icon: 'UserFilled',   color: '#dc2626', bgColor: '#fef2f2', route: '/admin/audit/cleaners?tab=pending' },
  { label: '待派单订单',     count: 0, icon: 'List',         color: '#d97706', bgColor: '#fffbeb', route: '/admin/dispatch' },
  { label: '待处理投诉',     count: 0, icon: 'ChatDotRound', color: '#dc2626', bgColor: '#fef2f2', route: '/admin/complaints' },
])

// ────────────────────────────────────────────────
// ECharts 实例
// ────────────────────────────────────────────────
const lineChartRef = ref(null)
const pieChartRef  = ref(null)
let lineChart = null
let pieChart  = null

// ────────────────────────────────────────────────
// 趋势折线图
// ────────────────────────────────────────────────
const trendDays    = ref(7)
const trendLoading = ref(false)

async function loadTrend() {
  trendLoading.value = true
  try {
    const data = await getStatsTrend(trendDays.value)
    if (!data?.length) return
    const dates     = data.map(d => d.date)
    const newOrders = data.map(d => d.newOrders ?? 0)
    const completed = data.map(d => d.completedOrders ?? 0)

    lineChart?.setOption({
      tooltip: { trigger: 'axis', backgroundColor: '#FFFFFF', borderColor: '#F0F0EB', textStyle: { color: '#4A4A4A' } },
      legend: { data: ['新增订单', '完成订单'], top: 0, right: 0, textStyle: { color: '#9CA3AF', fontSize: 12 } },
      grid:   { top: 40, left: 48, right: 20, bottom: 30 },
      xAxis:  { type: 'category', data: dates, axisLine: { lineStyle: { color: '#F0F0EB' } }, axisLabel: { color: '#9CA3AF', fontSize: 11 } },
      yAxis:  { type: 'value',    minInterval: 1, splitLine: { lineStyle: { color: '#F0F0EB' } }, axisLabel: { color: '#9CA3AF', fontSize: 11 } },
      series: [
        {
          name: '新增订单', type: 'line', data: newOrders,
          smooth: true, symbol: 'circle', symbolSize: 6,
          lineStyle: { color: '#3b82f6', width: 2 },
          itemStyle: { color: '#3b82f6' },
          areaStyle: { color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [{ offset: 0, color: 'rgba(59,130,246,.18)' }, { offset: 1, color: 'rgba(59,130,246,0)' }] } },
        },
        {
          name: '完成订单', type: 'line', data: completed,
          smooth: true, symbol: 'circle', symbolSize: 6,
          lineStyle: { color: '#10b981', width: 2 },
          itemStyle: { color: '#10b981' },
          areaStyle: { color: { type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [{ offset: 0, color: 'rgba(16,185,129,.18)' }, { offset: 1, color: 'rgba(16,185,129,0)' }] } },
        },
      ],
    })
  } finally {
    trendLoading.value = false
  }
}

// ────────────────────────────────────────────────
// 饼图：服务类型
// ────────────────────────────────────────────────
const pieLoading = ref(false)
const PIE_COLORS = ['#7c3aed', '#60a5fa', '#34d399', '#fbbf24', '#f87171', '#22d3ee', '#f472b6', '#818cf8']

async function loadPie() {
  pieLoading.value = true
  try {
    const data = await getServiceTypeStats()
    if (!data?.length) return
    const seriesData = data.map((item, i) => ({
      name:  item.serviceTypeName,
      value: item.count,
      itemStyle: { color: PIE_COLORS[i % PIE_COLORS.length] },
    }))

    pieChart?.setOption({
      tooltip: {
        trigger: 'item',
        formatter: '{b}: {c}单 ({d}%)',
        backgroundColor: '#FFFFFF',
        borderColor: '#F0F0EB',
        textStyle: { color: '#4A4A4A' },
      },
      legend: { orient: 'vertical', right: 10, top: 'center', textStyle: { fontSize: 12, color: '#9CA3AF' } },
      series: [{
        type: 'pie',
        radius: ['42%', '68%'],
        center: ['38%', '50%'],
        avoidLabelOverlap: true,
        label: { show: false },
        emphasis: { label: { show: true, fontSize: 13, fontWeight: 'bold' } },
        data: seriesData,
      }],
    })
  } finally {
    pieLoading.value = false
  }
}

// ────────────────────────────────────────────────
// 绩效排名
// ────────────────────────────────────────────────
const rankList    = ref([])
const rankLoading = ref(false)

async function loadRank() {
  rankLoading.value = true
  try {
    rankList.value = (await getCleanerRank(10)) ?? []
  } finally {
    rankLoading.value = false
  }
}

// ────────────────────────────────────────────────
// 辅助
// ────────────────────────────────────────────────
function completionClass(rate) {
  const r = Number(rate)
  if (r >= 0.9) return 'rate-good'
  if (r < 0.7)  return 'rate-bad'
  return 'rate-mid'
}

function formatPct(rate) {
  return (Number(rate) * 100).toFixed(1) + '%'
}

// ────────────────────────────────────────────────
// 生命周期
// ────────────────────────────────────────────────
let resizeOb = null

onMounted(async () => {
  // 初始化 ECharts（需等 DOM 渲染完毕）
  await nextTick()
  lineChart = echarts.init(lineChartRef.value, null, { renderer: 'canvas' })
  pieChart  = echarts.init(pieChartRef.value,  null, { renderer: 'canvas' })

  // 自适应窗口
  resizeOb = new ResizeObserver(() => {
    lineChart?.resize()
    pieChart?.resize()
  })
  resizeOb.observe(lineChartRef.value)
  resizeOb.observe(pieChartRef.value)

  // 并行加载四个接口
  await Promise.allSettled([
    loadOverview(),
    loadTrend(),
    loadPie(),
    loadRank(),
  ])
})

onUnmounted(() => {
  resizeOb?.disconnect()
  lineChart?.dispose()
  pieChart?.dispose()
})

async function loadOverview() {
  try {
    const d = await getOverview()
    if (!d) return
    overviewCards.value[0].value = d.todayNewOrders      ?? 0
    overviewCards.value[1].value = d.todayCompletedOrders ?? 0
    overviewCards.value[2].value = d.ongoingOrders        ?? 0
    overviewCards.value[3].value = '¥' + Number(d.todayRevenue ?? 0).toFixed(2)
    overviewCards.value[4].value = d.totalCleaners         ?? 0
    overviewCards.value[5].value = d.pendingAudit          ?? 0
    overviewCards.value[5].badge = d.pendingAudit > 0 ? d.pendingAudit : null
    todoCards.value[0].count = d.pendingAudit      ?? 0
    todoCards.value[1].count = d.pendingDispatch   ?? 0
    todoCards.value[2].count = d.pendingComplaints ?? 0
  } catch { /* 保持默认值 */ }
}
</script>

<style scoped>
.dashboard { max-width: 1400px; }

/* 概览卡片 */
.stat-card {
  background: #FFFFFF;
  border-radius: 10px;
  border: 1px solid #F0F0EB;
  border-top: 3px solid;
  padding: 16px 18px;
  display: flex;
  align-items: center;
  gap: 12px;
  box-shadow: 0 1px 4px rgba(74,74,74,.05);
  position: relative;
  transition: transform .15s, box-shadow .15s;
  width: 100%;
  box-sizing: border-box;
}
.stat-card.clickable { cursor: pointer; }
.stat-card.clickable:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(74,74,74,.1);
}
.stat-icon {
  width: 42px; height: 42px;
  border-radius: 8px;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.stat-info { flex: 1; min-width: 0; }
.stat-value { font-size: 24px; font-weight: 700; line-height: 1.2; }
.stat-label { font-size: 11px; color: #9CA3AF; margin-top: 3px; letter-spacing: 0.2px; }
.card-badge { position: absolute; top: 10px; right: 12px; }

/* 图表标题栏 */
.card-title { font-size: 14px; font-weight: 600; color: #4A4A4A; }
.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

/* 排名角标 */
.rank-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 22px; height: 22px;
  border-radius: 50%;
  font-size: 12px;
  font-weight: 700;
  background: #F0F0EB;
  color: #9CA3AF;
}
.rank-badge.rank-1 { background: #eab308; color: #fff; }
.rank-badge.rank-2 { background: #94a3b8; color: #fff; }
.rank-badge.rank-3 { background: #f97316; color: #fff; }

/* 完成率颜色 */
.rate-good { color: #16a34a; font-weight: 600; }
.rate-mid  { color: #f59e0b; font-weight: 600; }
.rate-bad  { color: #dc2626; font-weight: 600; }

/* 待办快捷操作卡片 */
.todo-card {
  background: #FFFFFF;
  border-radius: 10px;
  border: 1px solid #F0F0EB;
  border-left: 3px solid;
  padding: 14px 18px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 1px 4px rgba(74,74,74,.05);
}
.todo-left {
  display: flex;
  align-items: center;
  gap: 12px;
}
.todo-icon {
  width: 38px; height: 38px;
  border-radius: 8px;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.todo-label { font-size: 13px; font-weight: 600; color: #4A4A4A; }
.todo-count-num  { font-size: 12px; margin-top: 2px; font-weight: 600; }
.todo-count-none { font-size: 12px; margin-top: 2px; color: #D1D5DB; }
</style>
