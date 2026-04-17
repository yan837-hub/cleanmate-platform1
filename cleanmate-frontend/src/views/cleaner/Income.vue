<template>
  <div>
    <!-- 月份选择 + 汇总 -->
    <el-card v-loading="loading">
      <template #header>
        <div style="display:flex; justify-content:space-between; align-items:center">
          <span style="font-size:16px; font-weight:600">收入明细</span>
          <el-date-picker
            v-model="selectedMonth"
            type="month"
            format="YYYY年MM月"
            value-format="YYYY-MM"
            :clearable="false"
            style="width:160px"
            @change="loadIncome"
          />
        </div>
      </template>

      <!-- 汇总卡片 -->
      <el-row :gutter="16" style="margin-bottom:24px">
        <el-col :span="8">
          <div class="stat-box" style="background:#f0f0ff">
            <div class="stat-num" style="color:#5b21b6">{{ summary.orderCount }}</div>
            <div class="stat-lbl">完成订单</div>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="stat-box" style="background:#f0fff4">
            <div class="stat-num" style="color:#059669">¥{{ summary.totalIncome }}</div>
            <div class="stat-lbl">我的收入</div>
          </div>
        </el-col>
        <el-col :span="8">
          <div class="stat-box" style="background:#fff7e6">
            <div class="stat-num" style="color:#f59e0b">¥{{ summary.totalCommission }}</div>
            <div class="stat-lbl">平台佣金（{{ commissionRateText }}）</div>
          </div>
        </el-col>
      </el-row>

      <!-- 明细表格 -->
      <el-table :data="items" stripe border>
        <el-table-column label="订单号" prop="orderNo" width="200" />
        <el-table-column label="服务类型" prop="serviceTypeName" width="120" />
        <el-table-column label="完成时间" width="170">
          <template #default="{ row }">{{ formatTime(row.completedAt) }}</template>
        </el-table-column>
        <el-table-column label="订单金额" width="140" align="right">
          <template #default="{ row }">
            <span>¥{{ row.actualFee ?? '-' }}</span>
            <el-tag v-if="row.refundOccurred" type="danger" size="small" style="margin-left:4px">退款</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="平台佣金" width="110" align="right">
          <template #default="{ row }">
            <span style="color:#f59e0b">¥{{ row.commissionFee ?? '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="我的收入" width="110" align="right">
          <template #default="{ row }">
            <span style="color:#059669; font-weight:700">¥{{ row.cleanerIncome ?? '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="结算状态" width="100" align="center">
          <template #default>
            <el-tag type="success" size="small">已结算</el-tag>
          </template>
        </el-table-column>
      </el-table>

      <el-empty v-if="!loading && items.length === 0" description="本月暂无收入记录" />

      <!-- 底部合计 -->
      <div v-if="items.length > 0" class="income-footer">
        <span>共 {{ summary.orderCount }} 笔订单</span>
        <span>订单总额：<b>¥{{ totalActualFee }}</b></span>
        <span>我的收入合计：<b style="color:#059669">¥{{ summary.totalIncome }}</b></span>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getCleanerIncome } from '@/api/order'
import { formatTime } from '@/utils/time'
import request from '@/utils/request'

const loading = ref(false)
const selectedMonth = ref(new Date().toISOString().slice(0, 7)) // 默认当月
const commissionRateText = ref('20%') // 默认值，加载后从系统配置覆盖

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
  } catch { /* 保持默认值 */ }
})
</script>

<style scoped>
.stat-box { border-radius: 8px; padding: 16px; text-align: center; }
.stat-num { font-size: 26px; font-weight: 700; }
.stat-lbl { font-size: 12px; color: #888; margin-top: 4px; }

.income-footer {
  display: flex;
  justify-content: flex-end;
  gap: 24px;
  margin-top: 16px;
  padding-top: 12px;
  border-top: 1px solid #f3f4f6;
  font-size: 14px;
  color: #606266;
}
</style>
