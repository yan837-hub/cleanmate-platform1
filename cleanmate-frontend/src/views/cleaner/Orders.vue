<template>
  <div>
    <!-- 页面标题 -->
    <div class="page-header">
      <h2 class="page-title">我的订单</h2>
      <el-radio-group v-model="statusFilter" size="default" @change="loadOrders">
        <el-radio-button :value="null">全部</el-radio-button>
        <el-radio-button :value="3">已接单</el-radio-button>
        <el-radio-button :value="4">服务中</el-radio-button>
        <el-radio-button :value="5">待确认</el-radio-button>
        <el-radio-button :value="6">已完成</el-radio-button>
        <el-radio-button :value="7">售后中</el-radio-button>
      </el-radio-group>
    </div>

    <el-card shadow="never" class="table-card">
      <el-table :data="orders" v-loading="loading" stripe row-class-name="table-row">
        <el-table-column label="订单号" prop="orderNo" width="200" />
        <el-table-column label="服务类型" prop="serviceTypeName" width="130" />
        <el-table-column label="服务地址" prop="addressSnapshot" show-overflow-tooltip />
        <el-table-column label="预约时间" width="170">
          <template #default="{ row }">{{ formatTime(row.appointTime) }}</template>
        </el-table-column>
        <el-table-column label="预估金额" width="110" align="right">
          <template #default="{ row }">
            <span class="fee-text">¥{{ row.estimateFee }}</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="130" align="center">
          <template #default="{ row }">
            <el-tag :type="orderStatusType(row)" round>{{ orderStatusText(row) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="90" align="center">
          <template #default="{ row }">
            <el-button type="primary" link @click="$router.push(`/cleaner/orders/${row.id}`)">查看详情</el-button>
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
    </el-card>
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
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.page-title { font-size: 20px; font-weight: 700; color: #3A3734; margin: 0; }
.table-card { border-radius: var(--cm-radius-md); }
.fee-text { font-weight: 600; color: #3A3734; }
.pagination-wrap { margin-top: 20px; display: flex; justify-content: flex-end; }
</style>
