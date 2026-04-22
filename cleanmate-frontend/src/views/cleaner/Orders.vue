<template>
  <div class="orders-wrap">
    <!-- 顶部标题 -->
    <div class="page-header">
      <div>
        <h2 class="page-title">我的订单</h2>
        <p class="page-sub">管理您所有的服务订单记录</p>
      </div>
    </div>

    <!-- 状态筛选标签栏 -->
    <div class="filter-bar">
      <button
        v-for="tab in statusTabs"
        :key="String(tab.value)"
        :class="['filter-tab', { 'filter-tab--active': statusFilter === tab.value }]"
        @click="statusFilter = tab.value; currentPage = 1; loadOrders()"
      >
        {{ tab.label }}
      </button>
    </div>

    <!-- 表格卡片 -->
    <div class="table-card">
      <el-table
        :data="orders"
        v-loading="loading"
        stripe
        style="width:100%"
        :header-cell-style="{ background: '#F3F6F3', color: '#374151', fontWeight: '600', fontSize: '13px' }"
        :row-style="{ cursor: 'pointer' }"
        @row-click="row => $router.push(`/cleaner/orders/${row.id}`)"
      >
        <el-table-column label="订单号" prop="orderNo" width="210">
          <template #default="{ row }">
            <span class="order-no-cell">{{ row.orderNo }}</span>
          </template>
        </el-table-column>
        <el-table-column label="服务类型" width="130">
          <template #default="{ row }">
            <span class="svc-type-cell">{{ row.serviceTypeName }}</span>
          </template>
        </el-table-column>
        <el-table-column label="服务地址" prop="addressSnapshot" show-overflow-tooltip>
          <template #default="{ row }">
            <span class="addr-cell">{{ row.addressSnapshot }}</span>
          </template>
        </el-table-column>
        <el-table-column label="预约时间" width="170">
          <template #default="{ row }">
            <span class="time-cell">{{ formatTime(row.appointTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="预估金额" width="120" align="right">
          <template #default="{ row }">
            <span class="fee-cell">¥{{ row.estimateFee }}</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="130" align="center">
          <template #default="{ row }">
            <span :class="['status-chip', `status-chip--${orderStatusType(row)}`]">
              {{ orderStatusText(row) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" align="center">
          <template #default="{ row }">
            <el-button
              type="primary" link
              @click.stop="$router.push(`/cleaner/orders/${row.id}`)"
            >
              查看详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrap">
        <el-pagination
          background
          layout="prev, pager, next, total"
          :total="total"
          :page-size="pageSize"
          v-model:current-page="currentPage"
          @current-change="loadOrders"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { formatTime } from '@/utils/time'
import { getCleanerOrders } from '@/api/order'
import { ElMessage } from 'element-plus'
import { orderStatusText, orderStatusType } from '@/utils/orderStatus'

const orders = ref([])
const loading = ref(false)
const total = ref(0)
const currentPage = ref(1)
const pageSize = ref(10)
const statusFilter = ref(null)

const statusTabs = [
  { label: '全部',   value: null },
  { label: '已接单', value: 3 },
  { label: '服务中', value: 4 },
  { label: '待确认', value: 5 },
  { label: '已完成', value: 6 },
  { label: '售后中', value: 7 },
]

async function loadOrders() {
  loading.value = true
  try {
    const res = await getCleanerOrders({
      current: currentPage.value,
      size: pageSize.value,
      status: statusFilter.value,
    })
    orders.value = res.records
    total.value = res.total
  } catch {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

onMounted(loadOrders)
</script>

<style scoped>
.orders-wrap {
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

/* ── 筛选标签栏 ── */
.filter-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 14px;
  padding: 12px 16px;
  flex-wrap: wrap;
}
.filter-tab {
  padding: 7px 18px;
  border-radius: 50px;
  font-size: 13px;
  font-weight: 500;
  color: #4B5563;
  background: #F3F6F3;
  border: 1.5px solid #E0EBE0;
  cursor: pointer;
  transition: all .18s;
}
.filter-tab:hover { border-color: #6EE7A0; color: #2A6B47; }
.filter-tab--active {
  background: #2A6B47;
  color: #fff;
  border-color: #2A6B47;
  font-weight: 700;
  box-shadow: 0 2px 8px rgba(42,107,71,.30);
}

/* ── 表格卡片 ── */
.table-card {
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 16px;
  padding: 0;
  overflow: hidden;
  flex: 1;
}

/* 状态芯片 */
.status-chip {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
}
.status-chip--success  { background: #DCFCE7; color: #15803D; }
.status-chip--warning  { background: #FEF3C7; color: #B45309; }
.status-chip--danger   { background: #FEE2E2; color: #B91C1C; }
.status-chip--info     { background: #F3F4F6; color: #374151; }
.status-chip--primary  { background: #EFF6FF; color: #1D4ED8; }

/* 单元格 */
.order-no-cell { font-size: 12px; color: #6B7280; font-family: monospace; }
.svc-type-cell { font-size: 13px; font-weight: 600; color: #2A6B47; }
.addr-cell { font-size: 13px; color: #374151; }
.time-cell { font-size: 13px; color: #4B5563; }
.fee-cell { font-size: 14px; font-weight: 700; color: #D97706; }

/* 分页 */
.pagination-wrap {
  display: flex;
  justify-content: flex-end;
  padding: 16px 20px;
  border-top: 1px solid #E5EDE5;
}
</style>
