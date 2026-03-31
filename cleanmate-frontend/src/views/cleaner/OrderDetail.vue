<template>
  <div v-loading="loading">
    <el-page-header @back="$router.back()" content="订单详情" style="margin-bottom:16px" />

    <el-descriptions v-if="order" :column="2" border>
      <el-descriptions-item label="订单号">{{ order.orderNo }}</el-descriptions-item>
      <el-descriptions-item label="状态">
        <el-tag :type="orderStatusType(order)">{{ orderStatusText(order) }}</el-tag>
      </el-descriptions-item>
      <el-descriptions-item label="服务类型">{{ order.serviceTypeName }}</el-descriptions-item>
      <el-descriptions-item label="预约时间">{{ formatTime(order.appointTime) }}</el-descriptions-item>
      <el-descriptions-item label="服务地址" :span="2">{{ order.addressSnapshot }}</el-descriptions-item>
      <el-descriptions-item label="预约时长">{{ order.planDuration }} 分钟</el-descriptions-item>
      <el-descriptions-item label="预估金额">¥{{ order.estimateFee }}</el-descriptions-item>
      <el-descriptions-item v-if="order.actualDuration" label="实际时长">{{ order.actualDuration }} 分钟</el-descriptions-item>
      <el-descriptions-item v-if="order.actualFee" label="实际金额">¥{{ order.actualFee }}</el-descriptions-item>
      <el-descriptions-item v-if="order.remark" label="备注" :span="2">{{ order.remark }}</el-descriptions-item>
    </el-descriptions>

    <!-- 操作区 -->
    <el-card style="margin-top:16px" v-if="order">
      <!-- 接单/拒单：派单待确认(2) -->
      <template v-if="order.status === 2">
        <el-result icon="warning" title="您收到一个派单">
          <template #sub-title>
            请在30分钟内确认接单，超时将自动退回待派单池
          </template>
          <template #extra>
            <el-button type="primary" :loading="actionLoading" @click="doAccept">确认接单</el-button>
            <el-button type="danger" plain :loading="actionLoading" @click="doReject">拒绝接单</el-button>
          </template>
        </el-result>
      </template>

      <!-- 改期审核中(9)：顾客申请改期，等待保洁员处理 -->
      <template v-if="order.status === 9">
        <el-alert
          v-if="pendingReschedule"
          type="warning"
          :closable="false"
          style="margin-bottom:16px"
        >
          <template #title>
            顾客申请改期：
            <b>{{ formatTime(pendingReschedule.oldTime) }}</b>
            &nbsp;→&nbsp;
            <b style="color:#2563eb">{{ formatTime(pendingReschedule.newTime) }}</b>
          </template>
        </el-alert>
        <el-alert v-else type="warning" :closable="false" title="顾客已提交改期申请，正在加载..." style="margin-bottom:16px" />
        <div style="display:flex;gap:12px">
          <el-button type="success" :loading="actionLoading" @click="doApproveReschedule">同意改期</el-button>
          <el-button type="danger" plain :loading="actionLoading" @click="doRejectReschedule">拒绝改期</el-button>
        </div>
      </template>

      <!-- 签到打卡：状态=已接单(3) -->
      <template v-if="order.status === 3">
        <!-- 相邻订单路线提示 -->
        <el-card v-if="routeHint.hasPrevOrder" shadow="never"
          style="margin-bottom:16px;background:#f0f7ff;border-color:#b3d4ff">
          <div style="font-weight:600;margin-bottom:6px">🗺 相邻订单路线提示</div>
          <div style="font-size:13px;color:#606266;margin-bottom:8px">上一单完工后需前往本单</div>
          <div style="font-size:13px;margin-bottom:4px">📍 上一单：{{ routeHint.prevOrderAddress }}</div>
          <div style="font-size:13px;margin-bottom:8px">📍 本单：{{ routeHint.currentAddress }}</div>
          <img :src="routeHint.staticMapUrl" style="width:100%;border-radius:8px;margin:4px 0 10px;display:block" alt="路线预览" />
          <div style="font-size:13px;color:#409eff;margin-bottom:10px">
            距离约 {{ routeHint.distanceKm }} km，预计行程 {{ routeHint.estimatedMinutes }} 分钟
          </div>
          <el-button type="primary" size="small" @click="openNavigation">
            打开高德地图导航
          </el-button>
        </el-card>

        <div style="margin-bottom:8px;font-weight:bold">签到打卡</div>
        <el-alert type="info" :closable="false" style="margin-bottom:12px"
          :description="`签到时间窗口：${formatDate(checkinWindowStart)} ~ ${formatDate(checkinWindowEnd)}（预约时间前1小时至后2小时）`" />
        <div style="display:flex;gap:12px;align-items:center">
          <el-button type="primary" :loading="actionLoading" @click="doCheckin"
            :disabled="!canCheckin">
            {{ canCheckin ? '获取位置并签到' : '暂未到签到时间' }}
          </el-button>
          <el-button type="danger" plain :loading="actionLoading" @click="doCancel">
            取消订单
          </el-button>
          <span style="font-size:12px;color:#9ca3af">距预约 {{ cleanerCancelHours }} 小时前可取消</span>
        </div>
      </template>

      <!-- 照片上传 + 完工上报：状态=服务中(4) -->
      <template v-if="order.status === 4">
        <div style="margin-bottom:16px">
          <div style="font-weight:bold;margin-bottom:8px">上传服务照片</div>
          <el-radio-group v-model="photoPhase" style="margin-bottom:8px">
            <el-radio-button :value="1">服务前</el-radio-button>
            <el-radio-button :value="2">服务中</el-radio-button>
            <el-radio-button :value="3">服务后</el-radio-button>
          </el-radio-group>
          <br />
          <el-upload
            action="#"
            :http-request="handleUpload"
            :show-file-list="false"
            accept="image/*"
            :disabled="uploading"
          >
            <el-button :loading="uploading" type="default">选择图片上传</el-button>
          </el-upload>
          <div style="margin-top:12px;display:flex;flex-wrap:wrap;gap:8px">
            <el-image
              v-for="(p, i) in photos"
              :key="i"
              :src="p.imgUrl"
              style="width:80px;height:80px;object-fit:cover;border-radius:4px"
              :preview-src-list="photos.map(x=>x.imgUrl)"
            />
          </div>
        </div>

        <el-divider />

        <div style="font-weight:bold;margin-bottom:8px">完工上报</div>
        <el-form inline>
          <el-form-item label="实际服务时长（分钟）">
            <el-input-number v-model="actualDuration" :min="30" :step="30" style="width:160px" />
          </el-form-item>
          <el-form-item>
            <el-button type="success" :loading="actionLoading" @click="doComplete">提交完工</el-button>
          </el-form-item>
        </el-form>
      </template>

      <!-- 等待顾客确认：状态=待确认完成(5) -->
      <template v-if="order.status === 5">
        <el-result icon="success" title="已完工上报">
          <template #sub-title>
            等待顾客确认，若顾客未操作将于
            <b>{{ formatTime(order.autoConfirmAt) }}</b>
            自动确认
          </template>
        </el-result>
        <div style="margin-top:12px;display:flex;flex-wrap:wrap;gap:8px">
          <el-image
            v-for="(p, i) in photos"
            :key="i"
            :src="p.imgUrl"
            style="width:80px;height:80px;object-fit:cover;border-radius:4px"
            :preview-src-list="photos.map(x=>x.imgUrl)"
          />
        </div>
      </template>

      <!-- 已完成 -->
      <template v-if="order.status === 6">
        <el-result icon="success" title="订单已完成"
          :sub-title="`实际金额：¥${order.actualFee}，完成时间：${formatTime(order.completedAt)}`" />
      </template>

      <!-- 售后处理中 / 已结案 -->
      <template v-if="order.status === 7">
        <el-result
          :icon="order.complaintStatus === 3 ? 'success' : 'warning'"
          :title="order.complaintStatus === 3 ? '售后已结案' : '售后处理中'"
        >
          <template #sub-title>
            <div v-if="order.complaintStatus === 3">
              <div>处理结果：<el-tag :type="resultTagType(order.complaintResult)" size="small">{{ resultLabel(order.complaintResult) }}</el-tag></div>
              <div v-if="order.complaintResult === 1" style="margin-top:8px;color:#ef4444">
                全额退款，本单收入归零（原金额 ¥{{ order.estimateFee }}）
              </div>
            </div>
            <div v-else>管理员正在处理中，请耐心等待</div>
          </template>
        </el-result>
      </template>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { getCleanerOrderDetail, checkin, reportComplete, uploadPhoto, getOrderPhotos, acceptOrder, rejectOrder, cleanerCancelOrder, getRouteHint, getCleanerReschedules, handleReschedule } from '@/api/order'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'
import { formatTime } from '@/utils/time'
import { orderStatusText, orderStatusType } from '@/utils/orderStatus'

const route = useRoute()
const orderId = route.params.id

const order = ref(null)
const cleanerCancelHours = ref(4) // 默认4小时，加载后从后端覆盖
const loading = ref(false)
const actionLoading = ref(false)
const routeHint = ref({ hasPrevOrder: false })
const pendingReschedule = ref(null)

// 签到窗口：预约时间前1小时 ~ 后2小时（返回 Date 对象，避免 toISOString 丢失时区）
const checkinWindowStart = computed(() => {
  if (!order.value?.appointTime) return null
  const t = new Date(order.value.appointTime)
  t.setHours(t.getHours() - 1)
  return t
})
const checkinWindowEnd = computed(() => {
  if (!order.value?.appointTime) return null
  const t = new Date(order.value.appointTime)
  t.setHours(t.getHours() + 2)
  return t
})
const canCheckin = computed(() => {
  if (!checkinWindowStart.value || !checkinWindowEnd.value) return false
  const now = new Date()
  return now >= checkinWindowStart.value && now <= checkinWindowEnd.value
})

function formatDate(d) {
  if (!d) return ''
  const pad = n => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}
const uploading = ref(false)
const photos = ref([])
const photoPhase = ref(1)
const actualDuration = ref(120)

async function loadOrder() {
  loading.value = true
  try {
    const data = await getCleanerOrderDetail(orderId)
    order.value = data
    if (data.status === 3) getRouteHint(orderId).then(r => { routeHint.value = r }).catch(() => {})
    if (data.status >= 4) await loadPhotos()
    if (data.status === 9) {
      try {
        const list = await getCleanerReschedules(orderId)
        pendingReschedule.value = list[0] ?? null
      } catch {}
    }
  } catch {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

async function loadPhotos() {
  try {
    const data = await getOrderPhotos(orderId)
    photos.value = data
  } catch {}
}

async function doAccept() {
  actionLoading.value = true
  try {
    await acceptOrder(orderId)
    ElMessage.success('接单成功！请按时上门服务')
    await loadOrder()
  } catch (e) {
    ElMessage.error(e?.message || '接单失败')
  } finally {
    actionLoading.value = false
  }
}

async function doCancel() {
  await ElMessageBox.confirm(
    '确认取消此订单？取消后订单将退回待派单池，仅限距预约时间4小时前操作',
    '取消订单', { type: 'warning', confirmButtonText: '确认取消', confirmButtonClass: 'el-button--danger' }
  )
  actionLoading.value = true
  try {
    await cleanerCancelOrder(orderId, '')
    ElMessage.success('已取消，订单已退回待派单池')
    await loadOrder()
  } catch {
    // 错误已由 request 拦截器统一弹出，此处不重复提示
  } finally {
    actionLoading.value = false
  }
}

async function doReject() {
  await ElMessageBox.confirm('确认拒绝此订单？订单将退回待派单池', '拒绝接单', { type: 'warning' })
  actionLoading.value = true
  try {
    await rejectOrder(orderId)
    ElMessage.info('已拒绝，订单已退回')
    await loadOrder()
  } catch (e) {
    ElMessage.error(e?.message || '操作失败')
  } finally {
    actionLoading.value = false
  }
}

async function doCheckin() {
  actionLoading.value = true
  let pos = null
  try {
    pos = await getCurrentPosition()
  } catch (e) {
    ElMessage.error(e?.message || '获取位置失败，请允许定位权限')
    actionLoading.value = false
    return
  }

  // 计算与服务地址的直线距离（前端估算，仅用于展示）
  let distTip = ''
  if (order.value?.latitude && order.value?.longitude) {
    const d = haversineMeters(
      pos.latitude, pos.longitude,
      Number(order.value.latitude), Number(order.value.longitude)
    )
    const color = d > 500 ? '#ef4444' : '#16a34a'
    distTip = `<br/><span style="color:${color};font-weight:600">距服务地址约 ${d} 米</span>`
    if (d > 500) distTip += `<br/><span style="color:#ef4444;font-size:12px">偏差较大，签到后系统将标记为异常</span>`
  }

  try {
    await ElMessageBox.confirm(
      `当前位置：<br/>经度 ${pos.longitude.toFixed(6)}<br/>纬度 ${pos.latitude.toFixed(6)}${distTip}<br/><br/>确认以此位置签到？`,
      '位置确认',
      { dangerouslyUseHTMLString: true, confirmButtonText: '确认签到', cancelButtonText: '取消', type: 'info' }
    )
  } catch {
    actionLoading.value = false
    return
  }

  try {
    await checkin(orderId, pos.longitude, pos.latitude)
    ElMessage.success('签到成功，服务已开始')
    await loadOrder()
  } catch (e) {
    ElMessage.error(e?.message || '签到失败')
  } finally {
    actionLoading.value = false
  }
}

// Haversine 公式计算两点距离（米）
function haversineMeters(lat1, lon1, lat2, lon2) {
  const R = 6371000
  const dLat = (lat2 - lat1) * Math.PI / 180
  const dLon = (lon2 - lon1) * Math.PI / 180
  const a = Math.sin(dLat/2) ** 2 +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.sin(dLon/2) ** 2
  return Math.round(2 * R * Math.asin(Math.sqrt(a)))
}

function getCurrentPosition() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) return reject(new Error('浏览器不支持定位'))
    navigator.geolocation.getCurrentPosition(
      pos => resolve({ longitude: pos.coords.longitude, latitude: pos.coords.latitude }),
      () => reject(new Error('获取位置失败，请允许定位权限'))
    )
  })
}

async function handleUpload({ file }) {
  uploading.value = true
  try {
    await uploadPhoto(orderId, file, photoPhase.value)
    ElMessage.success('上传成功')
    await loadPhotos()
  } catch {
    ElMessage.error('上传失败')
  } finally {
    uploading.value = false
  }
}

async function doComplete() {
  await ElMessageBox.confirm(`确认提交完工？实际服务时长：${actualDuration.value} 分钟`, '完工确认', { type: 'warning' })
  actionLoading.value = true
  try {
    await reportComplete(orderId, actualDuration.value)
    ElMessage.success('完工上报成功，等待顾客确认')
    await loadOrder()
  } catch {
    ElMessage.error('提交失败')
  } finally {
    actionLoading.value = false
  }
}

function openNavigation() { window.open(routeHint.value.mapUrl, '_blank') }

async function doApproveReschedule() {
  if (!pendingReschedule.value) return
  await ElMessageBox.confirm(
    `确认同意将预约时间改为 ${formatTime(pendingReschedule.value.newTime)}？`,
    '同意改期', { type: 'warning' }
  )
  actionLoading.value = true
  try {
    await handleReschedule(pendingReschedule.value.id, true)
    ElMessage.success('已同意改期，预约时间已更新')
    await loadOrder()
  } catch (e) {
    ElMessage.error(e?.message || '操作失败')
  } finally {
    actionLoading.value = false
  }
}

async function doRejectReschedule() {
  if (!pendingReschedule.value) return
  let remark = ''
  try {
    const { value } = await ElMessageBox.prompt('请输入拒绝原因（选填）', '拒绝改期', {
      inputPlaceholder: '例如：该时段已有其他安排',
      confirmButtonText: '确认拒绝',
      confirmButtonClass: 'el-button--danger',
      cancelButtonText: '取消',
    })
    remark = value || ''
  } catch {
    return // 用户点取消
  }
  actionLoading.value = true
  try {
    await handleReschedule(pendingReschedule.value.id, false, remark)
    ElMessage.info('已拒绝改期，原时间不变')
    await loadOrder()
  } catch (e) {
    ElMessage.error(e?.message || '操作失败')
  } finally {
    actionLoading.value = false
  }
}

const RESULT_MAP = {
  1: { text: '全额退款', type: 'danger' },
  2: { text: '投诉驳回', type: 'info' },
  3: { text: '免费重做', type: 'primary' },
}
function resultLabel(r) { return RESULT_MAP[r]?.text ?? '-' }
function resultTagType(r) { return RESULT_MAP[r]?.type ?? '' }


onMounted(async () => {
  loadOrder()
  try {
    const cfg = await request.get('/public/config', { params: { keys: 'cleaner_cancel_hours' } })
    if (cfg?.cleaner_cancel_hours) cleanerCancelHours.value = Number(cfg.cleaner_cancel_hours)
  } catch { /* 保持默认值 */ }
})
</script>
