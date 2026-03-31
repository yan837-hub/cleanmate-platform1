<template>
  <div class="stats-page">
    <!-- 时间筛选 -->
    <el-card style="margin-bottom:16px">
      <el-form inline>
        <el-form-item label="统计周期">
          <el-radio-group v-model="period" @change="loadAll">
            <el-radio-button value="7">近7天</el-radio-button>
            <el-radio-button value="30">近30天</el-radio-button>
            <el-radio-button value="90">近90天</el-radio-button>
          </el-radio-group>
        </el-form-item>
        <el-form-item>
          <el-button :loading="loading" @click="loadAll">刷新</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 核心指标卡 -->
    <el-row :gutter="16" style="margin-bottom:20px">
      <el-col :span="6" v-for="m in metrics" :key="m.label">
        <div class="metric-card" :style="{ borderTopColor: m.color }">
          <div class="mc-top">
            <span class="mc-label">{{ m.label }}</span>
            <el-icon :size="18" :color="m.color"><component :is="m.icon" /></el-icon>
          </div>
          <div class="mc-value" :style="{ color: m.color }">{{ m.value }}</div>
          <div class="mc-sub" v-if="m.delta !== null">较上周期
            <span :class="m.delta >= 0 ? 'up' : 'down'">
              {{ m.delta >= 0 ? '↑' : '↓' }}{{ Math.abs(m.delta) }}%
            </span>
          </div>
          <div class="mc-sub" v-else>当前周期数据</div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="16">
      <!-- 订单趋势表格 -->
      <el-col :span="14">
        <el-card>
          <template #header>
            <div style="display:flex;justify-content:space-between;align-items:center">
              <span class="sec-title">订单趋势明细</span>
              <el-tag type="info" size="small">近{{ period }}天</el-tag>
            </div>
          </template>
          <el-table :data="trendRows" v-loading="loading" size="small" stripe max-height="360">
            <el-table-column label="日期" prop="date" width="105" />
            <el-table-column label="新增" prop="created" width="70" align="right" />
            <el-table-column label="完成" prop="completed" width="70" align="right">
              <template #default="{ row }">
                <span style="color:#16a34a">{{ row.completed }}</span>
              </template>
            </el-table-column>
            <el-table-column label="取消" prop="cancelled" width="70" align="right">
              <template #default="{ row }">
                <span style="color:#ef4444">{{ row.cancelled }}</span>
              </template>
            </el-table-column>
            <el-table-column label="完成率" align="right">
              <template #default="{ row }">
                <el-progress
                  :percentage="row.created ? Math.round(row.completed / row.created * 100) : 0"
                  :stroke-width="8" :show-text="false" style="min-width:80px" />
                <span style="font-size:12px;color:#888;margin-left:6px">
                  {{ row.created ? Math.round(row.completed / row.created * 100) : 0 }}%
                </span>
              </template>
            </el-table-column>
            <el-table-column label="收入(¥)" prop="income" width="90" align="right">
              <template #default="{ row }">
                <span style="font-weight:600">{{ row.income }}</span>
              </template>
            </el-table-column>
          </el-table>
          <div class="trend-total">
            合计：新增 <b>{{ totalCreated }}</b> 单 &nbsp;|&nbsp;
            完成 <b>{{ totalCompleted }}</b> 单 &nbsp;|&nbsp;
            收入 <b>¥{{ totalIncome }}</b>
          </div>
        </el-card>
      </el-col>

      <!-- 服务类型分布 -->
      <el-col :span="10">
        <el-card style="margin-bottom:16px">
          <template #header><span class="sec-title">服务类型分布</span></template>
          <div v-for="item in serviceStats" :key="item.label" class="svc-row">
            <span class="svc-label">{{ item.label }}</span>
            <el-progress
              :percentage="item.pct" :stroke-width="10"
              :color="item.color" :show-text="false" class="svc-bar" />
            <span class="svc-pct">{{ item.pct }}%</span>
            <span class="svc-count">{{ item.count }}单</span>
          </div>
        </el-card>

        <el-card>
          <template #header><span class="sec-title">投诉处理统计</span></template>
          <el-row :gutter="8">
            <el-col :span="8" v-for="c in complaintStats" :key="c.label">
              <div class="complaint-mini" :style="{ background: c.bg }">
                <div class="cm-num" :style="{ color: c.color }">{{ c.value }}</div>
                <div class="cm-label">{{ c.label }}</div>
              </div>
            </el-col>
          </el-row>
          <div style="margin-top:12px">
            <div class="rate-row">
              <span>结案率</span>
              <el-progress :percentage="closeRate" :stroke-width="10" status="success" />
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { getOrderTrend, getOverview, getServiceTypeStats } from '@/api/admin'

const period  = ref('7')
const loading = ref(false)

// ── 核心指标 ──
const metrics = ref([
  { label: '总订单数',   value: 0,    icon: 'Document',    color: '#5b21b6', delta: null },
  { label: '完成率',     value: '0%', icon: 'CircleCheck', color: '#16a34a', delta: null },
  { label: '总收入(¥)',  value: '¥0', icon: 'Money',       color: '#d97706', delta: null },
  { label: '在线保洁员', value: 0,    icon: 'User',        color: '#2563eb', delta: null },
])

// ── 趋势表格 ──
const trendRows = ref([])

const totalCreated   = computed(() => trendRows.value.reduce((s, r) => s + (Number(r.created)   || 0), 0))
const totalCompleted = computed(() => trendRows.value.reduce((s, r) => s + (Number(r.completed) || 0), 0))
const totalIncome    = computed(() => {
  const sum = trendRows.value.reduce((s, r) => s + (Number(r.income) || 0), 0)
  return sum.toFixed(2).replace(/\.00$/, '')
})

// ── 服务类型 ──
const serviceStats = ref([
  { label: '日常保洁', pct: 0, count: 0, color: '#5b21b6' },
  { label: '深度保洁', pct: 0, count: 0, color: '#3b82f6' },
  { label: '开荒保洁', pct: 0, count: 0, color: '#22c55e' },
  { label: '家电清洗', pct: 0, count: 0, color: '#f59e0b' },
  { label: '玻璃清洗', pct: 0, count: 0, color: '#ef4444' },
  { label: '其他',     pct: 0, count: 0, color: '#9ca3af' },
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

async function loadAll() {
  loading.value = true
  try {
    const [trend, ov, svcData] = await Promise.all([
      getOrderTrend(Number(period.value)),
      getOverview(),
      getServiceTypeStats(),
    ])

    // 趋势表格：把后端字段名映射到模板期望的字段名
    trendRows.value = (trend ?? []).map(r => ({
      date:      r.date,
      created:   r.newOrders       ?? 0,
      completed: r.completedOrders ?? 0,
      cancelled: r.cancelledOrders ?? 0,
      income:    r.revenue         ?? 0,
    }))

    // 概览数据填入指标卡
    if (ov) {
      const created   = totalCreated.value
      const completed = totalCompleted.value
      const rate      = created > 0 ? Math.round(completed / created * 100) : 0

      metrics.value[0].value = created
      metrics.value[1].value = rate + '%'
      metrics.value[2].value = '¥' + totalIncome.value
      metrics.value[3].value = ov.activeCleaners ?? 0

      complaintStats.value[0].value = ov.pendingComplaints    ?? 0
      complaintStats.value[1].value = ov.processingComplaints ?? 0
      complaintStats.value[2].value = ov.closedComplaints     ?? 0
    }

    // 服务类型分布
    if (svcData?.length) {
      const colorMap = {
        '日常保洁': '#5b21b6',
        '深度保洁': '#3b82f6',
        '开荒保洁': '#22c55e',
        '家电清洗': '#f59e0b',
        '玻璃清洗': '#ef4444',
      }
      serviceStats.value = svcData.map((item, i) => ({
        label: item.serviceTypeName,
        pct:   Math.round((item.percentage ?? 0) * 100),
        count: item.count ?? 0,
        color: colorMap[item.serviceTypeName] ?? ['#9ca3af', '#06b6d4', '#ec4899'][i % 3],
      }))
    }
  } catch (e) {
    console.error('统计数据加载失败', e)
  } finally {
    loading.value = false
  }
}

onMounted(loadAll)
</script>

<style scoped>
.stats-page { max-width: 1200px; }
.sec-title  { font-size: 15px; font-weight: 600; }

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
.up   { color: #16a34a; font-weight: 600; }
.down { color: #ef4444; font-weight: 600; }

.trend-total { margin-top: 10px; font-size: 13px; color: #606266; text-align: right; }

.svc-row   { display: flex; align-items: center; gap: 8px; margin-bottom: 12px; }
.svc-label { width: 70px; font-size: 13px; color: #333; flex-shrink: 0; }
.svc-bar   { flex: 1; }
.svc-pct   { width: 38px; text-align: right; font-size: 12px; color: #888; flex-shrink: 0; }
.svc-count { width: 40px; text-align: right; font-size: 12px; color: #5b21b6; flex-shrink: 0; font-weight: 600; }

.complaint-mini { border-radius: 8px; padding: 12px 0; text-align: center; }
.cm-num   { font-size: 24px; font-weight: 700; }
.cm-label { font-size: 12px; color: #666; margin-top: 4px; }
.rate-row { display: flex; align-items: center; gap: 12px; font-size: 13px; color: #606266; }
.rate-row .el-progress { flex: 1; }
</style>
