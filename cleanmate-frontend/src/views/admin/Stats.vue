<template>
  <div class="stats-page">

    <!-- 筛选栏 -->
    <div class="filter-bar">
      <div class="filter-left">
        <span class="filter-label">统计周期</span>
        <el-radio-group v-model="period" @change="loadAll">
          <el-radio-button value="7">近7天</el-radio-button>
          <el-radio-button value="30">近30天</el-radio-button>
          <el-radio-button value="90">近90天</el-radio-button>
        </el-radio-group>
      </div>
      <el-button :loading="loading" @click="loadAll" size="small">刷新</el-button>
    </div>

    <!-- 核心指标卡 -->
    <el-row :gutter="16" style="margin-bottom:20px">
      <el-col :span="6" v-for="m in metrics" :key="m.label">
        <div class="metric-card" :style="{ borderTopColor: m.color }">
          <div class="mc-top">
            <span class="mc-label">{{ m.label }}</span>
            <el-icon :size="18" :color="m.color"><component :is="m.icon" /></el-icon>
          </div>
          <div class="mc-value" :style="{ color: m.color }">{{ m.value }}</div>
          <div class="mc-sub">当前周期数据</div>
        </div>
      </el-col>
    </el-row>

    <!-- 第一行：订单趋势柱线图 + 服务类型环图 -->
    <el-row :gutter="16" style="margin-bottom:16px">
      <el-col :span="15">
        <el-card>
          <template #header>
            <div class="chart-header">
              <span class="sec-title">订单趋势</span>
              <el-tag type="info" size="small">近{{ period }}天</el-tag>
            </div>
          </template>
          <div ref="trendChartRef" style="height:280px" />
        </el-card>
      </el-col>
      <el-col :span="9">
        <el-card>
          <template #header>
            <span class="sec-title">服务类型分布（近30天）</span>
          </template>
          <div ref="pieChartRef" style="height:280px" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 第二行：平台收入趋势 + 投诉处理统计 -->
    <el-row :gutter="16" style="align-items:stretch">
      <el-col :span="15" style="display:flex;flex-direction:column">
        <el-card class="revenue-card">
          <template #header>
            <div class="chart-header">
              <span class="sec-title">平台收入趋势</span>
              <el-tag type="info" size="small">近{{ period }}天</el-tag>
            </div>
          </template>
          <div ref="revenueChartRef" class="revenue-chart" />
        </el-card>
      </el-col>

      <el-col :span="9">
        <el-card>
          <template #header><span class="sec-title">投诉处理统计</span></template>

          <el-row :gutter="8" style="margin-bottom:16px">
            <el-col :span="8" v-for="c in complaintStats" :key="c.label">
              <div class="complaint-mini" :style="{ background: c.bg }">
                <div class="cm-num" :style="{ color: c.color }">{{ c.value }}</div>
                <div class="cm-label">{{ c.label }}</div>
              </div>
            </el-col>
          </el-row>

          <div class="rate-row">
            <span style="white-space:nowrap">结案率</span>
            <el-progress :percentage="closeRate" :stroke-width="10" status="success" />
          </div>

          <div class="complaint-rate-box">
            <div class="cr-label">平台投诉率（期内）</div>
            <div class="cr-value" :class="overallComplaintRate > 10 ? 'cr-bad' : 'cr-ok'">
              {{ overallComplaintRate }}%
            </div>
            <div class="cr-sub">投诉总数 / 订单总数 × 100</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import { getOrderTrend, getOverview, getServiceTypeStats } from '@/api/admin'

const period  = ref('7')
const loading = ref(false)

// ── 核心指标 ──
const metrics = ref([
  { label: '总订单数',   value: 0,    icon: 'Document',    color: '#5b21b6' },
  { label: '完成率',     value: '0%', icon: 'CircleCheck', color: '#16a34a' },
  { label: '总收入(¥)',  value: '¥0', icon: 'Money',       color: '#d97706' },
  { label: '在线保洁员', value: 0,    icon: 'User',        color: '#2563eb' },
])

// ── 投诉统计 ──
const complaintStats = ref([
  { label: '待处理', value: 0, color: '#ef4444', bg: '#fef2f2' },
  { label: '处理中', value: 0, color: '#f59e0b', bg: '#fffbeb' },
  { label: '已结案', value: 0, color: '#16a34a', bg: '#f0fdf4' },
])

const closeRate = computed(() => {
  const total = complaintStats.value.reduce((s, c) => s + c.value, 0)
  return total ? Math.round(complaintStats.value[2].value / total * 100) : 0
})

const totalCreated = ref(0)
const overallComplaintRate = computed(() => {
  const total = complaintStats.value.reduce((s, c) => s + c.value, 0)
  return totalCreated.value > 0
    ? (total / totalCreated.value * 100).toFixed(1)
    : '0.0'
})

// ── ECharts 实例 ──
const trendChartRef   = ref(null)
const pieChartRef     = ref(null)
const revenueChartRef = ref(null)
let trendChart   = null
let pieChart     = null
let revenueChart = null

const PIE_COLORS = [
  '#7c3aed','#60a5fa','#34d399','#fbbf24','#f87171',
  '#22d3ee','#f472b6','#818cf8','#fb923c','#a3e635',
]

function drawTrend(rows) {
  if (!trendChart || !rows?.length) return
  const dates     = rows.map(r => r.date)
  const newOrders = rows.map(r => r.newOrders       ?? 0)
  const completed = rows.map(r => r.completedOrders  ?? 0)
  const cancelled = rows.map(r => r.cancelledOrders  ?? 0)

  trendChart.setOption({
    tooltip: {
      trigger: 'axis',
      backgroundColor: '#fff', borderColor: '#f0f0eb',
      textStyle: { color: '#4A4A4A' },
    },
    legend: {
      data: ['新增订单', '取消订单', '完成订单'],
      top: 0, right: 0,
      textStyle: { color: '#9CA3AF', fontSize: 12 },
    },
    grid: { top: 40, left: 48, right: 16, bottom: 30 },
    xAxis: {
      type: 'category', data: dates,
      axisLine: { lineStyle: { color: '#F0F0EB' } },
      axisLabel: { color: '#9CA3AF', fontSize: 11 },
    },
    yAxis: {
      type: 'value', minInterval: 1,
      splitLine: { lineStyle: { color: '#F0F0EB' } },
      axisLabel: { color: '#9CA3AF', fontSize: 11 },
    },
    series: [
      {
        name: '新增订单', type: 'bar', data: newOrders,
        barMaxWidth: 24,
        itemStyle: { color: '#3b82f6', borderRadius: [4, 4, 0, 0] },
      },
      {
        name: '取消订单', type: 'bar', data: cancelled,
        barMaxWidth: 24,
        itemStyle: { color: '#fca5a5', borderRadius: [4, 4, 0, 0] },
      },
      {
        name: '完成订单', type: 'line', data: completed,
        smooth: true, symbol: 'circle', symbolSize: 6,
        lineStyle: { color: '#10b981', width: 2 },
        itemStyle: { color: '#10b981' },
        areaStyle: {
          color: {
            type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(16,185,129,.18)' },
              { offset: 1, color: 'rgba(16,185,129,0)' },
            ],
          },
        },
      },
    ],
  })
}

function drawPie(data) {
  if (!pieChart || !data?.length) return
  const seriesData = data.map((item, i) => ({
    name:  item.serviceTypeName,
    value: item.count,
    itemStyle: { color: PIE_COLORS[i % PIE_COLORS.length] },
  }))

  pieChart.setOption({
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c}单 ({d}%)',
      backgroundColor: '#fff', borderColor: '#f0f0eb',
      textStyle: { color: '#4A4A4A' },
    },
    legend: {
      orient: 'vertical', right: 0, top: 'center',
      textStyle: { fontSize: 11, color: '#9CA3AF' },
    },
    series: [{
      type: 'pie',
      radius: ['42%', '68%'],
      center: ['38%', '50%'],
      avoidLabelOverlap: true,
      label: {
        show: true,
        position: 'outside',
        formatter: '{d}%',
        fontSize: 11,
        color: '#606266',
      },
      labelLine: { show: true, length: 8, length2: 6 },
      data: seriesData,
    }],
  })
}

function drawRevenue(rows) {
  if (!revenueChart || !rows?.length) return
  const dates    = rows.map(r => r.date)
  const revenues = rows.map(r => Number(r.revenue ?? 0).toFixed(2))
  const avgPrices = rows.map(r => {
    const n = r.newOrders ?? 0
    const v = Number(r.revenue ?? 0)
    return n > 0 ? Number((v / n).toFixed(2)) : 0
  })

  revenueChart.setOption({
    tooltip: {
      trigger: 'axis',
      backgroundColor: '#fff', borderColor: '#f0f0eb',
      textStyle: { color: '#4A4A4A' },
      formatter: (params) => {
        const date = params[0].axisValue
        const rev  = params.find(p => p.seriesName === '日收入')
        const avg  = params.find(p => p.seriesName === '客单价')
        return `${date}<br/>日收入：¥${rev?.value ?? 0}<br/>客单价：¥${avg?.value ?? 0}`
      },
    },
    legend: {
      data: ['日收入', '客单价'],
      top: 0, right: 0,
      textStyle: { color: '#9CA3AF', fontSize: 12 },
    },
    grid: { top: 40, left: 58, right: 58, bottom: 30 },
    xAxis: {
      type: 'category', data: dates,
      axisLine: { lineStyle: { color: '#F0F0EB' } },
      axisLabel: { color: '#9CA3AF', fontSize: 11 },
    },
    yAxis: [
      {
        type: 'value',
        splitLine: { lineStyle: { color: '#F0F0EB' } },
        axisLabel: { color: '#9CA3AF', fontSize: 11, formatter: '¥{value}' },
      },
      {
        type: 'value',
        splitLine: { show: false },
        axisLabel: { color: '#9CA3AF', fontSize: 11, formatter: '¥{value}' },
      },
    ],
    series: [
      {
        name: '日收入', type: 'bar', yAxisIndex: 0, data: revenues,
        barMaxWidth: 28,
        itemStyle: { color: '#a78bfa', borderRadius: [4, 4, 0, 0] },
        areaStyle: undefined,
      },
      {
        name: '客单价', type: 'line', yAxisIndex: 1, data: avgPrices,
        smooth: true, symbol: 'circle', symbolSize: 6,
        lineStyle: { color: '#f59e0b', width: 2 },
        itemStyle: { color: '#f59e0b' },
        areaStyle: {
          color: {
            type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(245,158,11,.15)' },
              { offset: 1, color: 'rgba(245,158,11,0)' },
            ],
          },
        },
      },
    ],
  })
}

// ── 数据加载 ──
async function loadAll() {
  loading.value = true
  try {
    const [trend, ov, svcData] = await Promise.all([
      getOrderTrend(Number(period.value)),
      getOverview(),
      getServiceTypeStats(),
    ])

    const rows      = trend ?? []
    const created   = rows.reduce((s, r) => s + (r.newOrders       ?? 0), 0)
    const completed = rows.reduce((s, r) => s + (r.completedOrders  ?? 0), 0)
    const income    = rows.reduce((s, r) => s + (Number(r.revenue)  ?? 0), 0)
    const rate      = created > 0 ? Math.round(completed / created * 100) : 0

    metrics.value[0].value = created
    metrics.value[1].value = rate + '%'
    metrics.value[2].value = '¥' + income.toFixed(2).replace(/\.00$/, '')
    metrics.value[3].value = ov?.activeCleaners ?? 0

    totalCreated.value = created

    if (ov) {
      complaintStats.value[0].value = ov.pendingComplaints     ?? 0
      complaintStats.value[1].value = ov.processingComplaints  ?? 0
      complaintStats.value[2].value = ov.closedComplaints      ?? 0
    }

    drawTrend(rows)
    drawPie(svcData ?? [])
    drawRevenue(rows)

  } catch (e) {
    // ignore
  } finally {
    loading.value = false
  }
}

// ── 生命周期 ──
let resizeOb = null

onMounted(async () => {
  await nextTick()
  trendChart   = echarts.init(trendChartRef.value,   null, { renderer: 'canvas' })
  pieChart     = echarts.init(pieChartRef.value,     null, { renderer: 'canvas' })
  revenueChart = echarts.init(revenueChartRef.value, null, { renderer: 'canvas' })

  resizeOb = new ResizeObserver(() => {
    trendChart?.resize()
    pieChart?.resize()
    revenueChart?.resize()
  })
  resizeOb.observe(trendChartRef.value)
  resizeOb.observe(pieChartRef.value)
  resizeOb.observe(revenueChartRef.value)

  await loadAll()
})

onUnmounted(() => {
  resizeOb?.disconnect()
  trendChart?.dispose()
  pieChart?.dispose()
  revenueChart?.dispose()
})
</script>

<style scoped>
.stats-page { max-width: 1400px; }
.sec-title  { font-size: 14px; font-weight: 600; color: #4A4A4A; }
.chart-header { display: flex; justify-content: space-between; align-items: center; }

.filter-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #fff;
  border: 1px solid #f0f0eb;
  border-radius: 10px;
  padding: 12px 18px;
  margin-bottom: 16px;
  box-shadow: 0 1px 4px rgba(74,74,74,.05);
}
.filter-left  { display: flex; align-items: center; gap: 12px; }
.filter-label { font-size: 13px; color: #606266; }

.metric-card {
  background: #fff;
  border-radius: 10px;
  border-top: 3px solid;
  padding: 16px 18px;
  box-shadow: 0 1px 6px rgba(0,0,0,.06);
}
.mc-top   { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.mc-label { font-size: 13px; color: #909399; }
.mc-value { font-size: 28px; font-weight: 700; margin-bottom: 6px; }
.mc-sub   { font-size: 12px; color: #aaa; }

.complaint-mini { border-radius: 8px; padding: 12px 0; text-align: center; }
.cm-num   { font-size: 22px; font-weight: 700; }
.cm-label { font-size: 12px; color: #666; margin-top: 4px; }

.rate-row { display: flex; align-items: center; gap: 12px; font-size: 13px; color: #606266; }
.rate-row .el-progress { flex: 1; }

.complaint-rate-box {
  margin-top: 16px;
  padding-top: 14px;
  border-top: 1px solid #f0f0eb;
}
.cr-label { font-size: 12px; color: #909399; margin-bottom: 4px; }
.cr-value { font-size: 26px; font-weight: 700; }
.cr-sub   { font-size: 11px; color: #bbb; margin-top: 4px; }
.cr-ok  { color: #16a34a; }
.cr-bad { color: #ef4444; }

/* 收入卡撑满行高，图表填满卡片剩余空间 */
.revenue-card {
  flex: 1;
  display: flex;
  flex-direction: column;
}
.revenue-card :deep(.el-card__body) {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding-bottom: 16px;
}
.revenue-chart {
  flex: 1;
  min-height: 200px;
}
</style>
