<template>
  <div>
    <!-- Tab 切换 -->
    <el-tabs v-model="activeTab" @tab-change="onTabChange" style="margin-bottom:4px">
      <el-tab-pane label="全部订单" name="all" />
      <el-tab-pane label="超时无人接单" name="expired" />
    </el-tabs>

    <!-- 超时无人接单说明 -->
    <el-alert
      v-if="activeTab === 'expired'"
      type="warning"
      :closable="false"
      style="margin-bottom:12px"
      title="以下订单因预约时间已过且无保洁员接单，已由系统自动取消退款。可用于分析供需缺口时段/区域。"
    />

    <!-- 搜索栏（仅全部订单 Tab 显示） -->
    <el-card v-if="activeTab === 'all'" style="margin-bottom:16px">
      <el-form inline>
        <el-form-item label="订单状态">
          <el-select v-model="filters.status" clearable placeholder="全部" style="width:130px" @change="load">
            <el-option v-for="s in statusOptions" :key="s.value" :label="s.label" :value="s.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="来源">
          <el-select v-model="filters.source" clearable placeholder="全部" style="width:120px" @change="load">
            <el-option :value="1" label="平台自有" />
            <el-option :value="2" label="外部导入" />
            <el-option :value="3" label="手动录入" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="filters.keyword" placeholder="订单号 / 地址" clearable style="width:200px" @keyup.enter="load" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="reset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 订单表格 -->
    <el-card>
      <template #header>
        <span style="font-size:15px;font-weight:600">{{ activeTab === 'expired' ? '超时无人接单' : '订单管理' }}</span>
        <span style="float:right">
          <template v-if="activeTab === 'all'">
            <el-button type="success" size="small" style="margin-right:8px" :loading="submitting" @click="batchImport">模拟外部导入</el-button>
            <el-button type="primary" size="small" @click="openManualDialog">录入订单</el-button>
          </template>
          <span style="margin-left:12px;font-size:13px;color:#909399">共 {{ activeTab === 'expired' ? expiredTotal : total }} 条</span>
        </span>
      </template>

      <el-table :data="activeTab === 'expired' ? expiredList : list" v-loading="loading">
        <el-table-column label="订单号" prop="orderNo" width="200" />
        <el-table-column label="服务类型" prop="serviceTypeName" width="100" />
        <el-table-column label="来源" width="90">
          <template #default="{ row }">
            <el-tag :type="sourceType(row.source)" size="small">{{ row.sourceLabel || '平台自有' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column v-if="activeTab === 'all'" label="状态" width="110">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)" size="small">{{ row.statusDesc }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="预约时间" width="155">
          <template #default="{ row }">{{ fmt(row.appointTime) }}</template>
        </el-table-column>
        <el-table-column label="服务地址" prop="addressSnapshot" show-overflow-tooltip />
        <el-table-column v-if="activeTab === 'all'" label="保洁员" width="90">
          <template #default="{ row }">{{ row.cleanerName || '-' }}</template>
        </el-table-column>
        <el-table-column label="预估金额" width="90">
          <template #default="{ row }">¥{{ row.estimateFee }}</template>
        </el-table-column>
        <el-table-column label="下单时间" width="155">
          <template #default="{ row }">{{ fmt(row.createdAt) }}</template>
        </el-table-column>
        <el-table-column v-if="activeTab === 'expired'" label="自动取消时间" width="155">
          <template #default="{ row }">{{ fmt(row.updatedAt) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="80" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="openDetail(row)">详情</el-button>
            <el-button
              v-if="row.status === 1"
              type="warning" link
              @click="triggerDispatch(row)"
            >派单</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        style="margin-top:16px;text-align:right"
        background
        layout="prev, pager, next, total"
        :total="activeTab === 'expired' ? expiredTotal : total"
        :page-size="pageSize"
        v-model:current-page="currentPage"
        @current-change="activeTab === 'expired' ? loadExpired() : load()"
      />
    </el-card>

    <!-- 详情抽屉 -->
    <el-drawer v-model="drawer" title="订单详情" size="480px">
      <div v-if="detail" class="detail-body">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="订单号">{{ detail.orderNo }}</el-descriptions-item>
          <el-descriptions-item label="来源">
            <el-tag :type="sourceType(detail.source)" size="small">{{ detail.sourceLabel || '平台自有' }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="statusType(detail.status)">{{ detail.statusDesc }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="服务类型">{{ detail.serviceTypeName }}</el-descriptions-item>
          <el-descriptions-item label="预约时间">{{ fmt(detail.appointTime) }}</el-descriptions-item>
          <el-descriptions-item v-if="detail.planDuration" label="计划时长">{{ detail.planDuration }} 分钟</el-descriptions-item>
          <el-descriptions-item label="服务地址">{{ detail.addressSnapshot }}</el-descriptions-item>
          <el-descriptions-item label="保洁员">{{ detail.cleanerName || '未分配' }}</el-descriptions-item>
          <el-descriptions-item label="保洁员电话">{{ detail.cleanerPhone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="预估费用">¥{{ detail.estimateFee }}</el-descriptions-item>
          <el-descriptions-item label="实际费用">{{ detail.actualFee ? '¥' + detail.actualFee : '待结算' }}</el-descriptions-item>
          <el-descriptions-item label="下单时间">{{ fmt(detail.createdAt) }}</el-descriptions-item>
          <el-descriptions-item v-if="detail.remark" label="备注">{{ detail.remark }}</el-descriptions-item>
          <el-descriptions-item v-if="detail.cancelReason" label="取消原因">
            <span style="color:#f56c6c">{{ detail.cancelReason }}</span>
          </el-descriptions-item>
        </el-descriptions>

        <div style="margin-top:20px;display:flex;gap:10px" v-if="detail.status === 1">
          <el-button type="primary" @click="triggerDispatch(detail)">触发自动派单</el-button>
        </div>
      </div>
    </el-drawer>

    <!-- 录入订单弹窗（source=3） -->
    <el-dialog v-model="manualDialog" title="手动录入订单" width="500px" :close-on-click-modal="false">
      <el-form :model="orderForm" label-width="90px">
        <el-form-item label="顾客手机号" required>
          <el-input v-model="orderForm.customerPhone" placeholder="11位手机号" />
        </el-form-item>
        <el-form-item label="服务类型" required>
          <el-input v-model="orderForm.serviceTypeName" placeholder="如：日常保洁（模糊匹配）" />
        </el-form-item>
        <el-form-item label="服务地址" required>
          <el-input v-model="orderForm.addressDetail" placeholder="详细地址" />
        </el-form-item>
        <el-form-item label="经度">
          <el-input v-model="orderForm.longitude" placeholder="如：106.55" />
        </el-form-item>
        <el-form-item label="纬度">
          <el-input v-model="orderForm.latitude" placeholder="如：29.56" />
        </el-form-item>
        <el-form-item label="房屋面积">
          <el-input v-model="orderForm.houseArea" placeholder="㎡" />
        </el-form-item>
        <el-form-item label="预约时间" required>
          <el-date-picker
            v-model="orderForm.appointTime"
            type="datetime"
            placeholder="选择时间"
            format="YYYY-MM-DD HH:mm:ss"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width:100%"
          />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="orderForm.remark" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="manualDialog = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitManual">确认录入</el-button>
      </template>
    </el-dialog>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  getAdminOrders, getAdminOrderDetail, autoDispatch,
  manualCreateOrder, importExternalOrder, getExpiredUnacceptedOrders
} from '@/api/admin'

const activeTab    = ref('all')
const list         = ref([])
const total        = ref(0)
const expiredList  = ref([])
const expiredTotal = ref(0)
const loading      = ref(false)
const currentPage  = ref(1)
const pageSize     = 10
const drawer       = ref(false)
const detail       = ref(null)
const submitting   = ref(false)
const manualDialog = ref(false)

const filters = ref({ status: null, source: null, keyword: '' })

function onTabChange(tab) {
  currentPage.value = 1
  if (tab === 'expired') loadExpired()
  else load()
}

async function loadExpired() {
  loading.value = true
  try {
    const res = await getExpiredUnacceptedOrders({ current: currentPage.value, size: pageSize })
    expiredList.value  = res.records
    expiredTotal.value = res.total
  } catch {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

const emptyOrderForm = () => ({
  customerPhone: '', serviceTypeName: '', addressDetail: '',
  longitude: '', latitude: '', houseArea: '', appointTime: '', remark: ''
})
const orderForm = ref(emptyOrderForm())

const statusOptions = [
  { value: 1, label: '待派单' },
  { value: 2, label: '待确认' },
  { value: 3, label: '已接单' },
  { value: 4, label: '服务中' },
  { value: 5, label: '待确认完成' },
  { value: 6, label: '已完成' },
  { value: 7, label: '售后中' },
  { value: 8, label: '已取消' },
  { value: 9, label: '改期审核中' },
]

function statusType(s) {
  return { 1:'info', 2:'warning', 3:'', 4:'primary', 5:'warning', 6:'success', 7:'danger', 8:'info', 9:'warning' }[s] ?? 'info'
}
function sourceType(s) {
  return { 1: 'primary', 2: 'warning', 3: 'info' }[s] ?? 'primary'
}
function fmt(t) { return t ? t.replace('T', ' ').slice(0, 16) : '-' }

// 生成本地时间字符串（不用 toISOString 避免 UTC 偏移）
function futureDate(days, hour) {
  const d = new Date()
  d.setDate(d.getDate() + days)
  d.setHours(hour, 0, 0, 0)
  const pad = n => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} ${pad(hour)}:00:00`
}

// 每次点击重新生成，地址/坐标/面积/手机号全部随机
function buildMockOrders() {
  const rand4 = () => String(Math.floor(Math.random() * 9000) + 1000)
  const randPhone = () => '138' + String(Math.floor(Math.random() * 90000000) + 10000000)
  const randArea = () => [60, 80, 90, 100, 120, 150][Math.floor(Math.random() * 6)]
  // 重庆主城区坐标范围随机偏移（±0.08°）
  const locations = [
    { district: '渝北区', street: '金开大道西段', lng: 106.58, lat: 29.72 },
    { district: '江北区', street: '北滨一路',     lng: 106.55, lat: 29.58 },
    { district: '南岸区', street: '南坪西路',     lng: 106.56, lat: 29.52 },
    { district: '沙坪坝区', street: '大学城南路', lng: 106.33, lat: 29.61 },
    { district: '渝中区', street: '解放碑商圈',   lng: 106.57, lat: 29.56 },
    { district: '九龙坡区', street: '杨家坪步行街', lng: 106.50, lat: 29.52 },
  ]
  const pick = arr => arr[Math.floor(Math.random() * arr.length)]
  const randLoc = () => {
    const loc = pick(locations)
    const offset = () => (Math.random() - 0.5) * 0.16
    return {
      addressDetail: `重庆市${loc.district}${loc.street}${rand4()}号`,
      longitude: parseFloat((loc.lng + offset()).toFixed(4)),
      latitude:  parseFloat((loc.lat + offset()).toFixed(4)),
    }
  }
  const platforms = [
    { prefix: 'JD', platformName: '京东到家' },
    { prefix: 'MT', platformName: '美团到家' },
  ]
  const services = ['日常保洁', '深度保洁', '开荒保洁']
  const remarks  = ['请带拖把', '重点清洁厨房', '新房请仔细清洁', '宠物家庭请注意', '']
  const hours    = [9, 10, 14, 15]

  return Array.from({ length: 4 }, (_, i) => {
    const p   = pick(platforms)
    const loc = randLoc()
    return {
      platformOrderNo: p.prefix + rand4(),
      platformName: p.platformName,
      customerPhone: randPhone(),
      serviceTypeName: pick(services),
      ...loc,
      houseArea: randArea(),
      appointTime: futureDate(i + 1, pick(hours)),
      remark: pick(remarks),
    }
  })
}

async function load() {
  loading.value = true
  try {
    const params = { current: currentPage.value, size: pageSize }
    if (filters.value.status)  params.status  = filters.value.status
    if (filters.value.source)  params.source  = filters.value.source
    if (filters.value.keyword) params.keyword = filters.value.keyword
    const res = await getAdminOrders(params)
    list.value  = res.records
    total.value = res.total
  } catch {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

function reset() {
  filters.value = { status: null, source: null, keyword: '' }
  currentPage.value = 1
  load()
}

async function openDetail(row) {
  detail.value = null
  drawer.value = true
  detail.value = await getAdminOrderDetail(row.id)
}

async function triggerDispatch(row) {
  try {
    await ElMessageBox.confirm(`对订单 ${row.orderNo} 触发自动派单？`, '确认', { type: 'warning' })
  } catch { return }
  try {
    const msg = await autoDispatch(row.id)
    ElMessage.success(msg || '派单成功')
    load()
    drawer.value = false
  } catch (e) {
    ElMessage.error(e?.message || '派单失败')
  }
}

function openManualDialog() {
  orderForm.value = emptyOrderForm()
  manualDialog.value = true
}

// 一键批量导入预设模拟订单
async function batchImport() {
  submitting.value = true
  let success = 0
  for (const order of buildMockOrders()) {
    try {
      await importExternalOrder(order)
      success++
    } catch {
      // 单条失败不中断，继续下一条
    }
  }
  submitting.value = false
  ElMessage.success(`已导入 ${success} / 4 条外部订单`)
  load()
}

async function submitManual() {
  if (!orderForm.value.customerPhone || !orderForm.value.serviceTypeName ||
      !orderForm.value.addressDetail  || !orderForm.value.appointTime) {
    ElMessage.warning('请填写必填项')
    return
  }
  submitting.value = true
  try {
    const res = await manualCreateOrder(orderForm.value)
    ElMessage.success(`录入成功，订单号：${res.systemOrderNo}，预估费用：¥${res.estimateFee}`)
    manualDialog.value = false
    load()
  } catch (e) {
    ElMessage.error(e?.message || '录入失败')
  } finally {
    submitting.value = false
  }
}

const route = useRoute()

onMounted(async () => {
  await load()
  const openId = route.query.openId
  if (openId) {
    openDetail({ id: Number(openId) })
  }
})
</script>

<style scoped>
.detail-body { padding: 4px 0; }
</style>