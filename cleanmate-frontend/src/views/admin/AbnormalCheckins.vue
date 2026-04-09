<template>
  <div>
    <el-tabs v-model="activeTab" style="margin-bottom:16px">
      <el-tab-pane label="异常签到" name="checkins" />
      <el-tab-pane label="异常通知" name="notifications" />
    </el-tabs>

    <!-- 异常签到 -->
    <template v-if="activeTab === 'checkins'">
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
    </template>

    <!-- 异常通知 -->
    <template v-if="activeTab === 'notifications'">
      <el-card>
        <template #header>
          <div style="display:flex;justify-content:space-between;align-items:center">
            <span style="font-size:16px;font-weight:600">异常通知</span>
            <el-button v-if="notifications.some(n => n.isRead === 0)" link type="primary" @click="markAllNotificationsRead">全部标记已读</el-button>
          </div>
        </template>

        <el-table :data="pagedNotifications" v-loading="notifLoading" stripe style="width:100%">
          <el-table-column label="ID" prop="id" width="80" />
          <el-table-column label="订单ID" prop="refId" width="100" />
          <el-table-column label="标题" prop="title" width="220" />
          <el-table-column label="内容" prop="content" show-overflow-tooltip min-width="160" />
          <el-table-column label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="row.isRead === 1 ? 'success' : 'danger'" size="small">{{ row.isRead === 1 ? '已读' : '未读' }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="时间" prop="createdAt" width="170">
            <template #default="{ row }">{{ fmt(row.createdAt) }}</template>
          </el-table-column>
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="{ row }">
              <el-button v-if="row.type === 12" type="warning" link size="small"
                @click="() => { handleNotificationMarkRead(row); activeTab = 'checkins' }">
                查看异常签到
              </el-button>
              <template v-else-if="row.title && row.title.includes('派单失败')">
                <el-button type="danger" link size="small"
                  @click="() => { handleNotificationMarkRead(row); router.push({ path: '/admin/dispatch', query: { orderId: row.refId } }) }">
                  去派单
                </el-button>
              </template>
              <el-button v-else type="primary" link size="small" @click="openOrderDrawer(row.refId)">查看订单</el-button>
              <el-button type="success" link size="small" @click="handleNotificationMarkRead(row)" v-if="row.isRead === 0">标记已读</el-button>
            </template>
          </el-table-column>
        </el-table>

        <el-pagination
          style="margin-top:16px;text-align:right"
          background layout="prev, pager, next, total"
          :total="notifications.length" :page-size="notifPageSize"
          v-model:current-page="notifPage" />
      </el-card>
    </template>

    <!-- 订单详情抽屉 -->
    <el-drawer v-model="orderDrawer" title="订单详情" size="520px" destroy-on-close>
      <div v-loading="orderDetailLoading">
        <template v-if="orderDetail">
          <el-descriptions :column="1" border>
            <el-descriptions-item label="订单号">{{ orderDetail.orderNo }}</el-descriptions-item>
            <el-descriptions-item label="服务类型">{{ orderDetail.serviceTypeName }}</el-descriptions-item>
            <el-descriptions-item label="顾客">{{ orderDetail.customerName }}</el-descriptions-item>
            <el-descriptions-item label="保洁员">{{ orderDetail.cleanerName || '--' }}</el-descriptions-item>
            <el-descriptions-item label="服务地址">{{ orderDetail.addressSnapshot }}</el-descriptions-item>
            <el-descriptions-item label="预约时间">{{ fmt(orderDetail.appointTime) }}</el-descriptions-item>
            <el-descriptions-item label="订单状态">{{ orderDetail.statusText || orderDetail.status }}</el-descriptions-item>
            <el-descriptions-item label="预估费用">¥{{ orderDetail.estimateFee }}</el-descriptions-item>
            <el-descriptions-item label="实际费用">{{ orderDetail.actualFee != null ? '¥' + orderDetail.actualFee : '--' }}</el-descriptions-item>
            <el-descriptions-item label="下单时间">{{ fmt(orderDetail.createdAt) }}</el-descriptions-item>
          </el-descriptions>
        </template>
        <el-empty v-else-if="!orderDetailLoading" description="暂无数据" />
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getAbnormalCheckins, handleAbnormalCheckin, getAdminNotifications, markAdminNotificationRead, getAdminOrderDetail } from '@/api/admin'

const router = useRouter()
const activeTab = ref('checkins')

// 异常签到
const list = ref([])
const loading = ref(false)
const filter = ref('')
const dialogVisible = ref(false)
const handleRemark = ref('')
const currentRecord = ref(null)
const submitting = ref(false)

// 异常通知
const notifications = ref([])
const notifLoading = ref(false)
const notifPage = ref(1)
const notifPageSize = 10
const pagedNotifications = computed(() => {
  const start = (notifPage.value - 1) * notifPageSize
  return notifications.value.slice(start, start + notifPageSize)
})
const orderDrawer = ref(false)
const orderDetail = ref(null)
const orderDetailLoading = ref(false)

function fmt(t) { return t ? String(t).replace('T', ' ').slice(0, 16) : '-' }

// 异常签到方法
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
    currentRecord.value.handledBy = -1
    currentRecord.value.handleRemark = handleRemark.value
    dialogVisible.value = false
  } catch {
    ElMessage.error('操作失败')
  } finally {
    submitting.value = false
  }
}

// 异常通知方法
async function loadNotifications() {
  notifLoading.value = true
  try {
    const data = await getAdminNotifications()
    notifications.value = (data || []).filter(n => n.type === 8 || n.type === 12)
    notifPage.value = 1
  } catch {
    ElMessage.error('加载异常通知失败')
  } finally {
    notifLoading.value = false
  }
}

async function handleNotificationMarkRead(row) {
  if (row.isRead === 1) return
  try {
    await markAdminNotificationRead(row.id)
    row.isRead = 1
    ElMessage.success('已标记已读')
  } catch {
    ElMessage.error('标记已读失败')
  }
}

async function markAllNotificationsRead() {
  for (const row of notifications.value.filter(n => n.isRead === 0)) {
    await handleNotificationMarkRead(row)
  }
}

async function openOrderDrawer(orderId) {
  if (!orderId) return
  orderDrawer.value = true
  orderDetail.value = null
  orderDetailLoading.value = true
  try {
    orderDetail.value = await getAdminOrderDetail(orderId)
  } catch {
    ElMessage.error('加载订单详情失败')
  } finally {
    orderDetailLoading.value = false
  }
}

watch(activeTab, (val) => {
  if (val === 'notifications') loadNotifications()
})

onMounted(load)
</script>