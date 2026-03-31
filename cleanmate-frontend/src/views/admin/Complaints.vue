<template>
  <div>
    <!-- 搜索栏 -->
    <el-card style="margin-bottom:16px">
      <el-form inline>
        <el-form-item label="投诉状态">
          <el-select v-model="filters.status" clearable placeholder="全部" style="width:120px" @change="load">
            <el-option label="待处理" :value="1" />
            <el-option label="处理中" :value="2" />
            <el-option label="已结案" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="filters.keyword" placeholder="订单ID / 投诉原因" clearable style="width:200px" @keyup.enter="load" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="reset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 统计概览 -->
    <el-row :gutter="12" style="margin-bottom:16px">
      <el-col :span="8">
        <div class="mini-stat red">
          <div class="ms-num">{{ statCount.pending }}</div>
          <div class="ms-label">待处理</div>
        </div>
      </el-col>
      <el-col :span="8">
        <div class="mini-stat orange">
          <div class="ms-num">{{ statCount.processing }}</div>
          <div class="ms-label">处理中</div>
        </div>
      </el-col>
      <el-col :span="8">
        <div class="mini-stat green">
          <div class="ms-num">{{ statCount.closed }}</div>
          <div class="ms-label">已结案</div>
        </div>
      </el-col>
    </el-row>

    <!-- 表格 -->
    <el-card>
      <template #header>
        <span style="font-size:15px;font-weight:600">投诉处理</span>
        <span style="float:right;font-size:13px;color:#909399">共 {{ total }} 条</span>
      </template>

      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column label="ID" prop="id" width="70" />
        <el-table-column label="订单ID" prop="orderId" width="90" />
        <el-table-column label="顾客" prop="customerNickname" width="90" show-overflow-tooltip />
        <el-table-column label="保洁员" prop="cleanerNickname" width="90" show-overflow-tooltip />
        <el-table-column label="投诉原因" prop="reason" show-overflow-tooltip />
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="sType(row.status)" size="small">{{ sLabel(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="判定结果" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.result" type="info" size="small">{{ resultLabel(row.result) }}</el-tag>
            <span v-else style="color:#ccc">--</span>
          </template>
        </el-table-column>
        <el-table-column label="订单金额" width="100">
          <template #default="{ row }">
            {{ row.orderEstimateFee != null ? '¥' + row.orderEstimateFee : '--' }}
          </template>
        </el-table-column>
        <el-table-column label="管理备注" prop="adminRemark" show-overflow-tooltip />
        <el-table-column label="提交时间" width="155">
          <template #default="{ row }">{{ fmt(row.createdAt) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="130" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="openDetail(row)">查看</el-button>
            <el-button v-if="row.status !== 3" type="warning" link @click="openHandle(row)">处理</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        style="margin-top:16px;text-align:right"
        background layout="prev, pager, next, total"
        :total="total" :page-size="pageSize"
        v-model:current-page="currentPage" @current-change="load" />
    </el-card>

    <!-- 详情抽屉 -->
    <el-drawer v-model="drawer" title="投诉详情" size="480px" destroy-on-close>
      <div v-if="current" class="detail-body">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="投诉ID">{{ current.id }}</el-descriptions-item>
          <el-descriptions-item label="关联订单">{{ current.orderId }}</el-descriptions-item>
          <el-descriptions-item label="顾客">{{ current.customerNickname || '--' }}</el-descriptions-item>
          <el-descriptions-item label="保洁员">{{ current.cleanerNickname || '--' }}</el-descriptions-item>
          <el-descriptions-item label="投诉原因">{{ current.reason }}</el-descriptions-item>
          <el-descriptions-item label="当前状态">
            <el-tag :type="sType(current.status)">{{ sLabel(current.status) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="判定结果">{{ resultLabel(current.result) }}</el-descriptions-item>
          <el-descriptions-item label="订单金额">
            {{ current.orderEstimateFee != null ? '¥' + current.orderEstimateFee : '--' }}
          </el-descriptions-item>
          <el-descriptions-item label="管理备注">{{ current.adminRemark || '--' }}</el-descriptions-item>
          <el-descriptions-item label="结案时间">{{ fmt(current.handledAt) }}</el-descriptions-item>
          <el-descriptions-item label="提交时间">{{ fmt(current.createdAt) }}</el-descriptions-item>
        </el-descriptions>

        <div v-if="current.imgs" style="margin-top:16px">
          <div class="cert-title">投诉凭证照片</div>
          <div class="imgs-wrap">
            <el-image v-for="(src, i) in current.imgs.split(',')" :key="i"
              :src="src" :preview-src-list="current.imgs.split(',')"
              class="complaint-img" fit="cover" />
          </div>
        </div>

        <div v-if="current.status !== 3" style="margin-top:20px">
          <el-button type="primary" @click="openHandle(current)">处理此投诉</el-button>
        </div>
      </div>
    </el-drawer>

    <!-- 处理对话框 -->
    <el-dialog v-model="handleDialog" title="处理投诉" width="460px" destroy-on-close>
      <el-form :model="handleForm" label-width="90px">
        <!-- 订单金额参考（始终显示预估金额作为原始金额基准） -->
        <el-form-item label="订单金额">
          <span style="font-size:18px;font-weight:700;color:#ef4444">
            ¥{{ handleForm.orderEstimateFee ?? '--' }}
          </span>
          <span style="font-size:12px;color:#9ca3af;margin-left:6px">（全额退款将退回此金额）</span>
        </el-form-item>
        <el-form-item label="投诉状态" required>
          <el-radio-group v-model="handleForm.status">
            <el-radio :value="2">处理中</el-radio>
            <el-radio :value="3">已结案</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item v-if="handleForm.status === 3" label="判定结果" required>
          <el-select v-model="handleForm.result" placeholder="请选择" style="width:100%" @change="handleForm.refundAmount = null">
            <el-option label="全额退款（退回全部费用）" :value="1" />
            <el-option label="部分退款（填写退款金额）" :value="4" />
            <el-option label="免费重做（费用清零，重新派单）" :value="3" />
            <el-option label="驳回投诉（服务质量无问题）" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="handleForm.status === 3 && handleForm.result === 4" label="退款金额" required>
          <el-input-number v-model="handleForm.refundAmount" :min="0"
            :max="handleForm.orderEstimateFee" :precision="2" style="width:200px" />
          <span style="margin-left:8px;font-size:12px;color:#9ca3af">
            最高 ¥{{ handleForm.orderEstimateFee }}
          </span>
        </el-form-item>
        <el-form-item label="管理备注" required>
          <el-input v-model="handleForm.adminRemark" type="textarea" :rows="3" placeholder="请填写处理说明" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="handleDialog = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitHandle">提交处理</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getComplaints, handleComplaint } from '@/api/admin'

const list        = ref([])
const total       = ref(0)
const loading     = ref(false)
const currentPage = ref(1)
const pageSize    = 10
const drawer      = ref(false)
const current     = ref(null)
const handleDialog = ref(false)
const submitting  = ref(false)
const filters     = ref({ status: null, keyword: '' })
const handleForm  = ref({ id: null, status: 2, result: null, adminRemark: '', orderActualFee: null, orderEstimateFee: null, refundAmount: null })
const statCount   = ref({ pending: 0, processing: 0, closed: 0 })

function sType(s)      { return { 1:'danger', 2:'warning', 3:'success' }[s] ?? 'info' }
function sLabel(s)     { return { 1:'待处理', 2:'处理中', 3:'已结案' }[s] ?? '-' }
function resultLabel(r){ return { 1:'全额退款', 2:'驳回投诉', 3:'免费重做', 4:'部分退款' }[r] ?? '--' }
function fmt(t) { return t ? t.replace('T', ' ').slice(0, 16) : '-' }

async function load() {
  loading.value = true
  try {
    const params = { current: currentPage.value, size: pageSize }
    if (filters.value.status) params.status = filters.value.status
    if (filters.value.keyword) params.keyword = filters.value.keyword
    const res = await getComplaints(params)
    list.value  = res?.records ?? []
    total.value = res?.total ?? 0
  } catch {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

async function loadStats() {
  try {
    const [r1, r2, r3] = await Promise.all([
      getComplaints({ status: 1, size: 1 }),
      getComplaints({ status: 2, size: 1 }),
      getComplaints({ status: 3, size: 1 }),
    ])
    statCount.value = {
      pending:    r1?.total ?? 0,
      processing: r2?.total ?? 0,
      closed:     r3?.total ?? 0,
    }
  } catch { /* ignore */ }
}

function reset() {
  filters.value = { status: null, keyword: '' }
  currentPage.value = 1
  load()
}

function openDetail(row) {
  current.value = row
  drawer.value = true
}

function openHandle(row) {
  handleForm.value = {
    id: row.id,
    status: row.status === 1 ? 2 : 3,
    result: null,
    adminRemark: row.adminRemark || '',
    orderActualFee: row.orderActualFee,
    orderEstimateFee: row.orderEstimateFee,
  }
  handleDialog.value = true
}

async function submitHandle() {
  if (!handleForm.value.adminRemark.trim()) {
    ElMessage.warning('请填写处理说明')
    return
  }
  if (handleForm.value.status === 3 && !handleForm.value.result) {
    ElMessage.warning('结案时必须选择判定结果')
    return
  }
  if (handleForm.value.result === 4 && !handleForm.value.refundAmount) {
    ElMessage.warning('部分退款请填写退款金额')
    return
  }
  submitting.value = true
  try {
    await handleComplaint(handleForm.value.id, {
      status:       handleForm.value.status,
      result:       handleForm.value.result,
      adminRemark:  handleForm.value.adminRemark,
      refundAmount: handleForm.value.refundAmount,
    })
    ElMessage.success('处理成功')
    handleDialog.value = false
    drawer.value = false
    load()
    loadStats()
  } catch (e) {
    ElMessage.error(e?.message || '操作失败')
  } finally {
    submitting.value = false
  }
}

onMounted(() => { load(); loadStats() })
</script>

<style scoped>
.detail-body { padding: 4px 8px; }

.mini-stat {
  background: #fff;
  border-radius: 8px;
  padding: 16px 20px;
  display: flex; flex-direction: column; align-items: center;
  border-left: 4px solid;
  box-shadow: 0 1px 4px rgba(0,0,0,.06);
}
.mini-stat.red    { border-color: #ef4444; }
.mini-stat.orange { border-color: #f59e0b; }
.mini-stat.green  { border-color: #22c55e; }
.ms-num   { font-size: 28px; font-weight: 700; color: #1a1a2e; }
.ms-label { font-size: 13px; color: #909399; margin-top: 4px; }

.cert-title  { font-size: 13px; font-weight: 600; color: #606266; margin-bottom: 8px; }
.imgs-wrap   { display: flex; flex-wrap: wrap; gap: 8px; }
.complaint-img { width: 120px; height: 90px; border-radius: 6px; border: 1px solid #e4e7ed; }
</style>
