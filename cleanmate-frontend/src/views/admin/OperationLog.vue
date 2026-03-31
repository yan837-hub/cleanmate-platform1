<template>
  <div>
    <!-- 筛选栏 -->
    <el-card class="filter-card" shadow="never">
      <el-form inline :model="filters">
        <el-form-item label="模块">
          <el-select v-model="filters.module" placeholder="全部模块" clearable style="width:150px">
            <el-option v-for="m in moduleOptions" :key="m" :label="m" :value="m" />
          </el-select>
        </el-form-item>
        <el-form-item label="时间范围">
          <el-date-picker
            v-model="filters.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
            style="width:240px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card shadow="never" style="margin-top:16px">
      <el-table :data="tableData" v-loading="loading" stripe style="width:100%">
        <el-table-column label="时间" prop="createdAt" width="180" sortable>
          <template #default="{ row }">{{ formatTime(row.createdAt) }}</template>
        </el-table-column>
        <el-table-column label="操作人" width="160">
          <template #default="{ row }">
            <div>{{ row.operatorNickname }}</div>
            <div style="font-size:12px;color:#999">{{ row.operatorPhone }}</div>
          </template>
        </el-table-column>
        <el-table-column label="模块" prop="module" width="120">
          <template #default="{ row }">
            <el-tag size="small" :type="moduleTagType(row.module)">{{ row.module }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作内容" prop="action" min-width="220" show-overflow-tooltip />
        <el-table-column label="关联ID" prop="refId" width="100" align="center">
          <template #default="{ row }">{{ row.refId ?? '—' }}</template>
        </el-table-column>
        <el-table-column label="IP" prop="ip" width="140">
          <template #default="{ row }">{{ row.ip ?? '—' }}</template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="pagination.current"
        v-model:page-size="pagination.size"
        :total="pagination.total"
        :page-sizes="[20, 50, 100]"
        layout="total, sizes, prev, pager, next"
        style="margin-top:16px;justify-content:flex-end"
        @current-change="loadData"
        @size-change="handleSizeChange"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getOperationLogs } from '@/api/admin'

const moduleOptions = ['系统参数', '派单', '审核', '封禁', '投诉处理']

const filters = reactive({ module: '', dateRange: null })
const loading = ref(false)
const tableData = ref([])
const pagination = reactive({ current: 1, size: 20, total: 0 })

function moduleTagType(module) {
  const map = { '封禁': 'danger', '审核': 'warning', '派单': 'success', '投诉处理': 'info' }
  return map[module] ?? ''
}

function formatTime(val) {
  if (!val) return '—'
  return val.replace('T', ' ').slice(0, 19)
}

async function loadData() {
  loading.value = true
  try {
    const params = {
      current: pagination.current,
      size: pagination.size,
    }
    if (filters.module) params.module = filters.module
    if (filters.dateRange?.[0]) params.startDate = filters.dateRange[0]
    if (filters.dateRange?.[1]) params.endDate = filters.dateRange[1]

    const res = await getOperationLogs(params)
    tableData.value = res.records
    pagination.total = res.total
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  pagination.current = 1
  loadData()
}

function handleReset() {
  filters.module = ''
  filters.dateRange = null
  pagination.current = 1
  loadData()
}

function handleSizeChange() {
  pagination.current = 1
  loadData()
}

onMounted(loadData)
</script>

<style scoped>
.filter-card :deep(.el-card__body) { padding: 16px 16px 0; }
</style>
