<template>
  <div>
    <!-- 页面标题 + Tab筛选 -->
    <div class="page-header">
      <h2 class="page-title">我的订单</h2>
    </div>

    <el-card shadow="never" class="orders-card">
      <el-tabs v-model="statusTab" @tab-change="handleTabChange" class="order-tabs">
        <el-tab-pane label="全部" name="" />
        <el-tab-pane label="待派单" name="1" />
        <el-tab-pane label="待确认" name="2" />
        <el-tab-pane label="待上门" name="3" />
        <el-tab-pane label="服务中" name="4" />
        <el-tab-pane label="待确认完成" name="5" />
        <el-tab-pane label="已完成" name="6" />
        <el-tab-pane label="售后中" name="7" />
        <el-tab-pane label="已取消" name="8" />
        <el-tab-pane label="改期审核中" name="9" />
      </el-tabs>

      <div v-loading="loading">
        <div v-if="orders.length === 0 && !loading" class="empty-wrap">
          <el-empty description="暂无相关订单" :image-size="80" />
        </div>

        <div v-for="order in orders" :key="order.id" class="order-card" @click="goDetail(order.id)">
          <div class="order-card-left">
            <div class="order-top-row">
              <span class="order-service">{{ order.serviceTypeName }}</span>
              <el-tag :type="orderStatusType(order)" size="small" round>
                {{ orderStatusText(order) }}
              </el-tag>
            </div>
            <div class="order-no">订单号：{{ order.orderNo }}</div>
            <div class="order-meta">
              <span class="meta-item"><el-icon><Clock /></el-icon> {{ formatTime(order.appointTime) }}</span>
              <span class="meta-sep">|</span>
              <span class="meta-item"><el-icon><Location /></el-icon> {{ order.addressSnapshot }}</span>
            </div>
          </div>
          <div class="order-card-right" @click.stop>
            <div class="order-fee">
              ¥{{ order.actualFee ?? order.estimateFee ?? '-' }}
              <span v-if="!order.actualFee && order.estimateFee" class="fee-tip">预估</span>
            </div>
            <div class="order-actions">
              <el-button
                v-if="[1, 2, 3].includes(order.status)"
                size="small"
                round
                @click="handleCancel(order)"
              >取消</el-button>
              <el-button
                v-if="order.status === 5"
                size="small"
                type="success"
                round
                @click="handleConfirm(order)"
              >确认完成</el-button>
              <el-button size="small" type="primary" round @click="goDetail(order.id)">详情</el-button>
            </div>
          </div>
        </div>

        <div v-if="total > pageSize" class="pagination-wrap">
          <el-pagination
            v-model:current-page="page"
            :page-size="pageSize"
            :total="total"
            background
            layout="prev, pager, next, total"
            @current-change="loadOrders"
          />
        </div>
      </div>
    </el-card>

    <!-- 取消原因弹窗 -->
    <el-dialog v-model="cancelDialog" title="取消订单" width="400px">
      <el-form>
        <el-form-item label="取消原因">
          <el-input v-model="cancelReason" type="textarea" :rows="3" placeholder="请输入取消原因（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="cancelDialog = false">返回</el-button>
        <el-button type="danger" :loading="cancelling" @click="confirmCancel">确认取消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { formatTime } from '@/utils/time'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Clock, Location } from '@element-plus/icons-vue'
import { getMyOrders, cancelOrder, confirmComplete } from '@/api/order'
import { orderStatusText, orderStatusType } from '@/utils/orderStatus'

const router = useRouter()

const loading = ref(false)
const orders = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = ref(10)
const statusTab = ref('')
const cancelDialog = ref(false)
const cancelReason = ref('')
const cancelling = ref(false)
const currentCancelId = ref(null)


function goDetail(id) {
  router.push(`/customer/orders/${id}`)
}

async function loadOrders() {
  loading.value = true
  try {
    const params = { page: page.value, size: pageSize.value }
    if (statusTab.value) params.status = statusTab.value
    const res = await getMyOrders(params)
    if (res && res.records) {
      orders.value = res.records
      total.value = res.total
    } else if (Array.isArray(res)) {
      orders.value = res
      total.value = res.length
    }
  } catch (e) {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

function handleTabChange() {
  page.value = 1
  loadOrders()
}

function handleCancel(order) {
  currentCancelId.value = order.id
  cancelReason.value = ''
  cancelDialog.value = true
}

async function confirmCancel() {
  cancelling.value = true
  try {
    await cancelOrder(currentCancelId.value, cancelReason.value)
    ElMessage.success('订单已取消')
    cancelDialog.value = false
    loadOrders()
  } catch (e) {
    ElMessage.error(e.message || '取消失败')
  } finally {
    cancelling.value = false
  }
}

async function handleConfirm(order) {
  // 未完成支付时跳转详情页完成支付
  if (order.payStatus !== 2) {
    ElMessage.warning('请先完成支付再确认完成')
    router.push(`/customer/orders/${order.id}`)
    return
  }
  try {
    await ElMessageBox.confirm('确认服务已完成？', '提示', { type: 'warning' })
    await confirmComplete(order.id)
    ElMessage.success('确认成功，感谢使用！')
    loadOrders()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message || '操作失败')
  }
}

onMounted(loadOrders)
</script>

<style scoped>
.page-header { margin-bottom: 20px; }
.page-title { font-size: 20px; font-weight: 700; color: #111; margin: 0; }

.orders-card { border-radius: 12px; }
.order-tabs { margin-bottom: 4px; }

.empty-wrap { padding: 40px 0; }

.order-card {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border: 1px solid #e0e7ff;
  border-radius: var(--cm-radius-md);
  padding: 18px 20px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all .18s;
  gap: 16px;
}
.order-card:hover {
  border-color: var(--cm-primary);
  box-shadow: 0 4px 16px rgba(14,165,233,.12);
  transform: translateY(-1px);
}

.order-card-left { flex: 1; min-width: 0; }
.order-top-row {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 6px;
}
.order-service { font-size: 16px; font-weight: 600; color: #111; }
.order-no { font-size: 12px; color: #9ca3af; margin-bottom: 8px; }
.order-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #6b7280;
  flex-wrap: wrap;
}
.meta-sep { color: #d1d5db; }
.meta-item { display: inline-flex; align-items: center; gap: 3px; }

.order-card-right {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 10px;
  flex-shrink: 0;
}
.order-fee { font-size: 20px; font-weight: 700; color: #ef4444; }
.fee-tip { font-size: 11px; font-weight: 400; color: #9ca3af; margin-left: 2px; }
.order-actions { display: flex; gap: 8px; }

.pagination-wrap { margin-top: 20px; display: flex; justify-content: flex-end; }
</style>
