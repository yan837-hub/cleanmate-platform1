<template>
  <div>
    <!-- 搜索栏 -->
    <el-card style="margin-bottom:16px">
      <el-form :inline="true" :model="query" @submit.prevent="onSearch">
        <el-form-item label="关键词">
          <el-input v-model="query.keyword" placeholder="手机号 / 昵称" clearable style="width:200px" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="query.status" clearable placeholder="全部" style="width:110px">
            <el-option label="正常"  :value="1" />
            <el-option label="停用"  :value="3" />
            <el-option label="封禁"  :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="onSearch">搜索</el-button>
          <el-button @click="onReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 表格 -->
    <el-card>
      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column prop="id" label="ID" width="80" />

        <el-table-column label="用户信息" min-width="160">
          <template #default="{ row }">
            <div style="display:flex;align-items:center;gap:8px">
              <el-avatar :size="32" :src="row.avatarUrl" style="flex-shrink:0;background:#5b21b6">
                {{ row.nickname?.charAt(0) }}
              </el-avatar>
              <div>
                <div style="font-weight:600;font-size:13px">{{ row.nickname || '—' }}</div>
                <div style="font-size:12px;color:#9ca3af">{{ row.realName || '' }}</div>
              </div>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="phone" label="手机号" width="130" />

        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)" size="small">{{ statusLabel(row.status) }}</el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="orderCount" label="累计订单" width="90" align="center" />

        <el-table-column label="注册时间" width="160">
          <template #default="{ row }">{{ formatDate(row.createdAt) }}</template>
        </el-table-column>

        <el-table-column label="操作" width="120" align="center" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.status === 1"
              type="danger" link size="small"
              @click="toggleStatus(row, 3)"
            >停用</el-button>
            <el-button
              v-else
              type="success" link size="small"
              @click="toggleStatus(row, 1)"
            >启用</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        style="margin-top:16px;justify-content:flex-end;display:flex"
        v-model:current-page="query.current"
        v-model:page-size="query.size"
        :total="total"
        :page-sizes="[10, 20, 50]"
        layout="total, sizes, prev, pager, next"
        @change="loadList"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getAdminCustomers, toggleCustomerStatus } from '@/api/admin'

const loading = ref(false)
const list    = ref([])
const total   = ref(0)

const query = reactive({ current: 1, size: 10, keyword: '', status: null })

async function loadList() {
  loading.value = true
  try {
    const params = { current: query.current, size: query.size }
    if (query.keyword) params.keyword = query.keyword
    if (query.status  != null) params.status = query.status
    const res = await getAdminCustomers(params)
    list.value  = res?.records ?? []
    total.value = res?.total   ?? 0
  } finally {
    loading.value = false
  }
}

function onSearch() { query.current = 1; loadList() }
function onReset()  { query.keyword = ''; query.status = null; query.current = 1; loadList() }

async function toggleStatus(row, status) {
  const label = status === 3 ? '停用' : '启用'
  await ElMessageBox.confirm(`确认${label}顾客「${row.nickname || row.phone}」？`, '提示', { type: 'warning' })
  await toggleCustomerStatus(row.id, status)
  ElMessage.success(`已${label}`)
  loadList()
}

// ── 工具 ──
function statusType(s)  { return s === 1 ? 'success' : s === 3 ? 'warning' : 'danger' }
function statusLabel(s) { return s === 1 ? '正常' : s === 3 ? '停用' : s === 4 ? '封禁' : '未知' }
function formatDate(v)  {
  if (!v) return '—'
  return new Date(v).toLocaleString('zh-CN', { year:'numeric', month:'2-digit', day:'2-digit', hour:'2-digit', minute:'2-digit' })
}

onMounted(loadList)
</script>
