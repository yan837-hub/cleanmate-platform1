<template>
  <div>
    <el-card>
      <template #header>
        <div style="display:flex;justify-content:space-between;align-items:center">
          <span style="font-size:15px;font-weight:600">异常签到记录</span>
          <el-radio-group v-model="filter" size="small" @change="load">
            <el-radio-button label="">全部</el-radio-button>
            <el-radio-button label="0">未处理</el-radio-button>
            <el-radio-button label="1">已处理</el-radio-button>
          </el-radio-group>
        </div>
      </template>

      <el-table :data="list" v-loading="loading" border style="width:100%">
        <el-table-column prop="orderId" label="订单ID" width="90" />
        <el-table-column prop="cleanerId" label="保洁员ID" width="90" />
        <el-table-column prop="checkinTime" label="签到时间" width="160">
          <template #default="{ row }">{{ fmt(row.checkinTime) }}</template>
        </el-table-column>
        <el-table-column prop="distanceM" label="偏差距离(m)" width="110" />
        <el-table-column label="处理状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.handledBy ? 'success' : 'danger'" size="small">
              {{ row.handledBy ? '已处理' : '未处理' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="handleRemark" label="处理备注" />
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button v-if="!row.handledBy" size="small" type="primary" @click="openHandle(row)">
              标记处理
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" title="标记处理" width="420px">
      <el-form label-width="70px">
        <el-form-item label="处理备注">
          <el-input v-model="handleRemark" type="textarea" :rows="3" placeholder="填写处理说明（选填）" maxlength="200" show-word-limit />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitHandle">确认处理</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getAbnormalCheckins, handleAbnormalCheckin } from '@/api/admin'

const list = ref([])
const loading = ref(false)
const filter = ref('')

const dialogVisible = ref(false)
const handleRemark = ref('')
const currentRecord = ref(null)
const submitting = ref(false)

function fmt(t) { return t ? String(t).replace('T', ' ').slice(0, 16) : '-' }

async function load() {
  loading.value = true
  try {
    const params = filter.value !== '' ? { handled: filter.value } : {}
    list.value = await getAbnormalCheckins(params)
  } catch {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

function openHandle(row) {
  currentRecord.value = row
  handleRemark.value = ''
  dialogVisible.value = true
}

async function submitHandle() {
  submitting.value = true
  try {
    await handleAbnormalCheckin(currentRecord.value.id, handleRemark.value)
    ElMessage.success('已标记处理')
    currentRecord.value.handledBy = -1  // 本地更新，非空即视为已处理
    currentRecord.value.handleRemark = handleRemark.value
    dialogVisible.value = false
  } catch {
    ElMessage.error('操作失败')
  } finally {
    submitting.value = false
  }
}

onMounted(load)
</script>
