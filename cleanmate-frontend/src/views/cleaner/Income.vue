<template>
  <div class="income-wrap">
    <!-- 顶部：标题 + 月份选择 -->
    <div class="page-header">
      <div>
        <h2 class="page-title">收入明细</h2>
        <p class="page-sub">查看您的服务收入与佣金明细</p>
      </div>
      <el-date-picker
        v-model="selectedMonth"
        type="month"
        format="YYYY年MM月"
        value-format="YYYY-MM"
        :clearable="false"
        style="width:170px"
        @change="loadIncome"
      />
    </div>

    <!-- 三张汇总卡片 -->
    <div class="stat-row" v-loading="loading">
      <div class="stat-card stat-card--green">
        <div class="stat-card-icon">📦</div>
        <div class="stat-card-body">
          <div class="stat-card-value">{{ summary.orderCount }}</div>
          <div class="stat-card-label">完成订单</div>
        </div>
        <div class="stat-card-sub">单</div>
      </div>
      <div class="stat-card stat-card--orange">
        <div class="stat-card-icon">💰</div>
        <div class="stat-card-body">
          <div class="stat-card-value">¥{{ summary.totalIncome }}</div>
          <div class="stat-card-label">我的收入</div>
        </div>
        <div class="stat-card-sub">本月到手</div>
      </div>
      <div class="stat-card stat-card--gray">
        <div class="stat-card-icon">📊</div>
        <div class="stat-card-body">
          <div class="stat-card-value">¥{{ summary.totalCommission }}</div>
          <div class="stat-card-label">平台佣金</div>
        </div>
        <div class="stat-card-sub">{{ commissionRateText }}</div>
      </div>
    </div>

    <!-- 明细表格 -->
    <div class="table-card" v-loading="loading">
      <div class="table-header">
        <span class="table-title">收入明细列表</span>
        <span v-if="items.length > 0" class="table-summary">
          共 <b>{{ summary.orderCount }}</b> 笔 · 订单总额
          <b>¥{{ totalActualFee }}</b> · 我的收入合计
          <b class="income-hl">¥{{ summary.totalIncome }}</b>
        </span>
      </div>

      <el-table
        :data="items"
        stripe
        style="width:100%"
        :header-cell-style="{ background: '#F3F6F3', color: '#374151', fontWeight: '600', fontSize: '13px' }"
      >
        <el-table-column label="订单号" prop="orderNo" width="210">
          <template #default="{ row }">
            <span class="order-no-mono">{{ row.orderNo }}</span>
          </template>
        </el-table-column>
        <el-table-column label="服务类型" prop="serviceTypeName" width="130">
          <template #default="{ row }">
            <span class="svc-badge">{{ row.serviceTypeName }}</span>
          </template>
        </el-table-column>
        <el-table-column label="完成时间" min-width="160">
          <template #default="{ row }">
            <span class="time-text">{{ formatTime(row.completedAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="订单金额" width="140" align="right">
          <template #default="{ row }">
            <span class="actual-fee">¥{{ row.actualFee ?? '-' }}</span>
            <el-tag v-if="row.refundOccurred" type="danger" size="small" style="margin-left:4px">退款</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="平台佣金" width="120" align="right">
          <template #default="{ row }">
            <span class="commission-fee">¥{{ row.commissionFee ?? '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="我的收入" width="130" align="right">
          <template #default="{ row }">
            <span class="cleaner-income">¥{{ row.cleanerIncome ?? '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="结算状态" width="110" align="center">
          <template #default>
            <span class="settled-chip">已结算</span>
          </template>
        </el-table-column>
      </el-table>

      <el-empty v-if="!loading && items.length === 0" description="本月暂无收入记录" style="padding: 48px 0" />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getCleanerIncome } from '@/api/order'
import { formatTime } from '@/utils/time'
import request from '@/utils/request'

const loading = ref(false)
const selectedMonth = ref(new Date().toISOString().slice(0, 7))
const commissionRateText = ref('20%')

const summary = ref({ orderCount: 0, totalIncome: 0, totalCommission: 0 })
const items = ref([])

const totalActualFee = computed(() =>
  items.value.reduce((sum, r) => sum + parseFloat(r.actualFee || 0), 0).toFixed(2)
)

async function loadIncome() {
  loading.value = true
  try {
    const res = await getCleanerIncome({ month: selectedMonth.value })
    summary.value = {
      orderCount:      res.orderCount ?? 0,
      totalIncome:     (res.totalIncome ?? 0).toFixed ? Number(res.totalIncome).toFixed(2) : res.totalIncome,
      totalCommission: (res.totalCommission ?? 0).toFixed ? Number(res.totalCommission).toFixed(2) : res.totalCommission,
    }
    items.value = res.items ?? []
  } catch {
    ElMessage.error('加载收入数据失败')
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  loadIncome()
  try {
    const cfg = await request.get('/public/config', { params: { keys: 'commission_rate' } })
    if (cfg?.commission_rate) {
      commissionRateText.value = (parseFloat(cfg.commission_rate) * 100).toFixed(0) + '%'
    }
  } catch {}
})
</script>

<style scoped>
.income-wrap {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: calc(100vh - 60px - 68px);
}

/* ── 顶部 ── */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 16px;
  padding: 18px 24px;
}
.page-title { font-size: 22px; font-weight: 800; color: #1C3D2A; margin: 0 0 4px; }
.page-sub { font-size: 13px; color: #6B7280; margin: 0; }

/* ── 汇总卡片 ── */
.stat-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}
.stat-card {
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 16px;
  padding: 22px 24px;
  display: flex;
  align-items: center;
  gap: 18px;
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
.stat-card--gray::before   { background: #6B7280; }
.stat-card-icon {
  font-size: 36px;
  width: 64px; height: 64px;
  border-radius: 16px;
  display: flex; align-items: center; justify-content: center;
}
.stat-card--green .stat-card-icon  { background: #DCFCE7; }
.stat-card--orange .stat-card-icon { background: #FEF3C7; }
.stat-card--gray .stat-card-icon   { background: #F3F4F6; }
.stat-card-body { flex: 1; }
.stat-card-value {
  font-size: 32px; font-weight: 800; color: #1C3D2A;
  line-height: 1; letter-spacing: -1px; margin-bottom: 6px;
}
.stat-card--orange .stat-card-value { color: #D97706; }
.stat-card-label { font-size: 14px; color: #6B7280; font-weight: 500; }
.stat-card-sub {
  font-size: 12px; color: #9CA3AF;
  background: #F3F4F6; border-radius: 8px;
  padding: 4px 10px; white-space: nowrap;
}

/* ── 表格卡片 ── */
.table-card {
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 16px;
  overflow: hidden;
  flex: 1;
}
.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #E5EDE5;
}
.table-title { font-size: 15px; font-weight: 700; color: #1C3D2A; }
.table-summary { font-size: 13px; color: #6B7280; }
.income-hl { color: #2A6B47; }

/* 表格内容 */
.order-no-mono { font-size: 12px; color: #6B7280; font-family: monospace; }
.svc-badge {
  font-size: 11px; font-weight: 700; color: #2A6B47;
  background: #DCFCE7; border-radius: 20px; padding: 2px 9px;
}
.time-text { font-size: 13px; color: #4B5563; }
.actual-fee { font-size: 14px; font-weight: 600; color: #374151; }
.commission-fee { font-size: 13px; color: #9CA3AF; }
.cleaner-income { font-size: 15px; font-weight: 800; color: #D97706; }
.settled-chip {
  display: inline-block;
  font-size: 11px; font-weight: 700;
  color: #15803D; background: #DCFCE7;
  border-radius: 20px; padding: 3px 10px;
}
</style>
