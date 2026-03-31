<template>
  <div class="detail-page">
    <el-page-header @back="router.back()" title="返回" content="订单详情" style="margin-bottom: 20px" />

    <div v-loading="loading">
      <div v-if="order">
        <!-- 状态卡片 -->
        <el-card style="margin-bottom:16px;border-radius:12px">
          <div class="status-section">
            <!-- 投诉已结案时覆盖显示 -->
            <template v-if="existingComplaint?.status === 3">
              <el-tag type="success" size="large">售后已结案</el-tag>
              <div class="status-hint" style="color:#16a34a">
                投诉已处理完毕（{{ resultLabel(existingComplaint.result) }}），感谢您的耐心等待
              </div>
            </template>
            <template v-else>
              <el-tag :type="orderStatusType(order)" size="large">{{ orderStatusText(order) }}</el-tag>
              <div class="status-hint">{{ statusHint(order.status) }}</div>
            </template>
          </div>
          <div class="action-row" v-if="showActions || canReportNoShow">
            <el-button
              v-if="[1, 2, 3].includes(order.status)"
              @click="handleCancel"
            >取消订单</el-button>
            <!-- status=3：距预约>2小时时显示申请改期 -->
            <el-button
              v-if="order.status === 3 && canReschedule"
              type="primary"
              plain
              @click="openRescheduleDialog"
            >申请改期</el-button>
            <el-button
              v-if="order.status === 5"
              type="success"
              @click="handleConfirm"
            >确认完成</el-button>
            <!-- status=5：拒绝确认+发起投诉 -->
            <el-button
              v-if="order.status === 5"
              type="danger"
              plain
              @click="openComplaintDialog"
            >拒绝确认 / 发起投诉</el-button>
            <el-button
              v-if="canReportNoShow"
              type="danger"
              plain
              @click="handleNoShow"
            >保洁员未到场</el-button>
          </div>
          <!-- 支付催促警告：服务已完成但未付款时显示 -->
          <el-alert
            v-if="showPayWarning"
            type="error"
            show-icon
            :closable="false"
            style="margin-top:12px"
          >
            <template #title>
              <span style="font-weight:600">请完成支付 · 评价功能暂时锁定</span>
            </template>
            <template #default>
              服务已完成，请在下方完成支付。支付后即可解锁评价功能，保洁员收入也将同步确认。
            </template>
          </el-alert>

          <!-- status=9：改期申请中标签 + 申请详情 -->
          <div v-if="order.status === 9 && rescheduleRecord" class="reschedule-status">
            <el-icon><Clock /></el-icon>
            改期申请中：
            <span>{{ formatTime(rescheduleRecord.oldTime) }}</span>
            <span style="margin:0 6px">→</span>
            <span style="color:#2563eb;font-weight:500">{{ formatTime(rescheduleRecord.newTime) }}</span>
            <el-tag type="warning" size="small" style="margin-left:8px">待保洁员确认</el-tag>
          </div>
          <!-- status=6：完成后7天内售后入口 -->
          <div v-if="order.status === 6 && canComplaintAfterDone" class="after-sale-tip">
            <el-button type="warning" plain size="small" @click="openComplaintDialog">
              发起售后投诉
            </el-button>
            <span class="tip-text">服务完成后7天内可发起售后</span>
          </div>
          <!-- 投诉状态行（结案时由上方状态卡显示，此处仅在处理中时补充） -->
          <div v-if="existingComplaint && existingComplaint.status !== 3" class="complaint-status">
            <el-icon><Warning /></el-icon>
            投诉已提交，当前状态：
            <el-tag :type="{'1':'danger','2':'warning','3':'success'}[existingComplaint.status]" size="small">
              {{ {'1':'待处理','2':'处理中','3':'已结案'}[existingComplaint.status] }}
            </el-tag>
            <template v-if="existingComplaint.status === 3">
              <span class="closed-tip">· 售后已处理完毕，</span>
              <span v-if="existingComplaint.result !== 3" class="closed-tip" style="color:#5b21b6">请在下方进行服务评价</span>
              <span v-else class="closed-tip">平台将重新为您安排服务</span>
            </template>
            <span v-if="existingComplaint.adminRemark" class="complaint-remark">
              管理员回复：{{ existingComplaint.adminRemark }}
            </span>
          </div>
          <!-- 已接单但未到签到窗口关闭时间的提示 -->
          <div v-if="order.status === 3 && !canReportNoShow" class="no-show-tip">
            如保洁员超过预约时间30分钟仍未到场，可在此页面报告
          </div>
        </el-card>

        <!-- 服务信息 -->
        <el-card style="margin-bottom:16px;border-radius:12px">
          <template #header><span class="section-title">服务信息</span></template>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="订单号" :span="2">{{ order.orderNo }}</el-descriptions-item>
            <el-descriptions-item label="服务类型">{{ order.serviceTypeName }}</el-descriptions-item>
            <el-descriptions-item label="预约时间">{{ formatTime(order.appointTime) }}</el-descriptions-item>
            <el-descriptions-item v-if="order.planDuration" label="计划时长">
              {{ order.planDuration / 60 }} 小时
            </el-descriptions-item>
            <el-descriptions-item v-if="order.houseArea" label="房屋面积">
              {{ order.houseArea }} ㎡
            </el-descriptions-item>
            <el-descriptions-item label="下单时间">{{ formatTime(order.createdAt) }}</el-descriptions-item>
          </el-descriptions>
        </el-card>

        <!-- 费用信息 -->
        <el-card style="margin-bottom:16px;border-radius:12px">
          <template #header><span class="section-title">费用信息</span></template>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="预估费用">¥ {{ order.estimateFee }}</el-descriptions-item>
            <el-descriptions-item label="实际费用">
              <span class="fee">¥ {{ order.actualFee ?? order.estimateFee ?? '--' }}</span>
              <el-tag v-if="existingComplaint?.status === 3 && existingComplaint.result === 1"
                type="success" size="small" style="margin-left:6px">已全额退款</el-tag>
            </el-descriptions-item>
            <el-descriptions-item v-if="order.actualDuration" label="实际时长">
              {{ order.actualDuration / 60 }} 小时
            </el-descriptions-item>
          </el-descriptions>
        </el-card>

        <!-- 支付区域 -->
        <el-card
          class="pay-card-anchor"
          style="margin-bottom:16px;border-radius:12px"
          :style="showPayWarning ? 'border:2px solid #ef4444;box-shadow:0 0 0 3px rgba(239,68,68,.1)' : ''"
        >
          <template #header>
            <span class="section-title">支付</span>
            <el-tag v-if="showPayWarning" type="danger" size="small" style="margin-left:8px">待支付</el-tag>
            <el-tag v-if="order?.payStatus === 2" type="success" size="small" style="margin-left:8px">已完成</el-tag>
          </template>

          <!-- 已完成支付 -->
          <div v-if="order.payStatus === 2" class="pay-done">
            <el-tag type="success" size="large">已完成支付 ✓</el-tag>
          </div>

          <!-- pay_status=0 且 status=1：显示支付定金 -->
          <div v-else-if="order.payStatus === 0 && order.status === 1">
            <div class="pay-amount">定金 ¥{{ depositPreview }}</div>
            <div class="pay-sub">（可锁定订单，约为预估费用的30%）</div>
            <div class="pay-hint">也可完成后一次性支付全额</div>
            <el-button type="primary" style="margin-top:12px" @click="handlePayDeposit">
              支付定金 ¥{{ depositPreview }}
            </el-button>
          </div>

          <!-- pay_status=1 且 status IN(5,6)：显示支付尾款 -->
          <div v-else-if="order.payStatus === 1 && [5, 6].includes(order.status)">
            <div class="pay-paid">已付定金 ¥{{ order.depositFee ?? depositPreview }}</div>
            <div class="pay-amount">尾款 ¥{{ tailFeePreview }}</div>
            <el-button type="primary" style="margin-top:12px" @click="handlePayFinal">
              支付尾款 ¥{{ tailFeePreview }}
            </el-button>
          </div>

          <!-- pay_status=0 且 status IN(5,6)：显示支付全额 -->
          <div v-else-if="order.payStatus === 0 && [5, 6].includes(order.status)">
            <div class="pay-amount">¥{{ order.actualFee ?? order.estimateFee }}</div>
            <el-button type="primary" style="margin-top:12px" @click="handlePayFull">
              支付全额 ¥{{ order.actualFee ?? order.estimateFee }}
            </el-button>
          </div>

          <!-- 其他状态（未生成费用 / 未到支付时机）-->
          <div v-else class="pay-hint">暂无需支付</div>
        </el-card>

        <!-- 服务地址 -->
        <el-card style="margin-bottom:16px;border-radius:12px">
          <template #header><span class="section-title">服务地址</span></template>
          <div class="addr-box">
            <div class="addr-detail">{{ order.addressSnapshot }}</div>
          </div>
        </el-card>

        <!-- 保洁员信息（已派单后显示） -->
        <el-card v-if="order.cleanerName" style="margin-bottom:16px;border-radius:12px">
          <template #header><span class="section-title">保洁员信息</span></template>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="姓名">{{ order.cleanerName }}</el-descriptions-item>
            <el-descriptions-item label="评分">
              <el-rate :model-value="order.cleanerAvgScore" disabled allow-half />
            </el-descriptions-item>
          </el-descriptions>
        </el-card>

        <!-- 备注 -->
        <el-card v-if="order.remark" style="margin-bottom:16px;border-radius:12px">
          <template #header><span class="section-title">备注</span></template>
          <div class="remark-text">{{ order.remark }}</div>
        </el-card>

        <!-- 退款信息（售后结案后显示，兼容 order.status=7 但投诉已结案的情况） -->
        <el-card v-if="existingComplaint && existingComplaint.status === 3"
          style="margin-bottom:16px;border-radius:12px">
          <template #header>
            <span class="section-title">售后处理结果</span>
          </template>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="判定结果">
              <el-tag :type="resultTagType(existingComplaint.result)">
                {{ resultLabel(existingComplaint.result) }}
              </el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="退款金额" v-if="existingComplaint.result === 1">
              <span class="refund-amount">¥ {{ order.estimateFee }}</span>
            </el-descriptions-item>
            <template v-if="existingComplaint.result === 4">
              <el-descriptions-item label="服务原价">
                <span style="text-decoration:line-through;color:#9ca3af">¥ {{ order.estimateFee }}</span>
              </el-descriptions-item>
              <el-descriptions-item label="退款金额">
                <span class="refund-amount" style="color:#f59e0b">¥ {{ order.actualFee }}</span>
              </el-descriptions-item>
              <el-descriptions-item label="实际消费">
                <span style="font-weight:700;color:#374151">
                  ¥ {{ (parseFloat(order.estimateFee) - parseFloat(order.actualFee)).toFixed(2) }}
                </span>
              </el-descriptions-item>
            </template>
            <el-descriptions-item label="管理员说明" :span="2">
              {{ existingComplaint.adminRemark || '--' }}
            </el-descriptions-item>
            <el-descriptions-item label="结案时间">
              {{ fmtComplaintTime(existingComplaint.handledAt) }}
            </el-descriptions-item>
          </el-descriptions>
          <!-- 免费重做提示 -->
          <el-alert v-if="existingComplaint.result === 3" type="warning" show-icon
            title="订单已安排免费重做，平台将重新为您派单，请留意消息通知"
            style="margin-top:12px" :closable="false" />
        </el-card>

        <!-- 未支付时评价入口占位提示 -->
        <el-card v-if="order?.status === 6 && order?.payStatus !== 2 && !existingComplaint" style="margin-bottom:16px;border-radius:12px">
          <template #header><span class="section-title">服务评价</span></template>
          <el-empty :image-size="60" description="完成支付后即可评价">
            <el-button type="primary" size="small" @click="scrollToPayCard">去支付</el-button>
          </el-empty>
        </el-card>

        <!-- 评价：status=6 正常完成 且已全额支付，或投诉已结案（非免费重做）均可评价 -->
        <el-card v-if="canReview"
          :style="!existingReview ? 'border:2px solid #f59e0b;box-shadow:0 0 0 3px rgba(245,158,11,.1)' : ''">
          <template #header>
            <span class="section-title">服务评价</span>
            <el-tag v-if="!existingReview" type="warning" size="small" style="margin-left:8px">待评价</el-tag>
          </template>

          <!-- 已评价：展示评价内容 -->
          <div v-if="existingReview">
            <div class="review-row">
              <span class="review-label">服务态度</span>
              <el-rate :model-value="existingReview.scoreAttitude" disabled />
            </div>
            <div class="review-row">
              <span class="review-label">清洁效果</span>
              <el-rate :model-value="existingReview.scoreQuality" disabled />
            </div>
            <div class="review-row">
              <span class="review-label">准时到达</span>
              <el-rate :model-value="existingReview.scorePunctual" disabled />
            </div>
            <div v-if="existingReview.content" class="review-content">{{ existingReview.content }}</div>
            <div class="review-time">评价时间：{{ formatTime(existingReview.createdAt) }}</div>
          </div>

          <!-- 未评价：评价表单 -->
          <div v-else>
            <div class="review-row">
              <span class="review-label">服务态度</span>
              <el-rate v-model="reviewForm.scoreAttitude" />
            </div>
            <div class="review-row">
              <span class="review-label">清洁效果</span>
              <el-rate v-model="reviewForm.scoreQuality" />
            </div>
            <div class="review-row">
              <span class="review-label">准时到达</span>
              <el-rate v-model="reviewForm.scorePunctual" />
            </div>
            <el-input
              v-model="reviewForm.content"
              type="textarea"
              :rows="3"
              placeholder="分享您的服务体验（选填）"
              style="margin: 12px 0"
            />
            <el-button type="primary" :loading="submittingReview" @click="handleSubmitReview">
              提交评价
            </el-button>
          </div>
        </el-card>
      </div>

      <el-empty v-else-if="!loading" description="订单不存在" />
    </div>

    <!-- 投诉对话框 -->
    <el-dialog v-model="complaintDialog"
      :title="order?.status === 5 ? '拒绝确认 / 发起投诉' : '发起售后投诉'"
      width="460px" destroy-on-close>
      <div class="complaint-tip" v-if="order?.status === 5">
        <el-alert type="warning" show-icon :closable="false"
          title="提交投诉后订单将进入「售后处理中」，管理员会在1-3个工作日内处理" />
      </div>
      <el-form style="margin-top:12px">
        <el-form-item label="投诉原因" required>
          <el-input v-model="complaintForm.reason" type="textarea" :rows="4"
            placeholder="请详细描述您遇到的问题，如服务质量、物品损坏等" />
        </el-form-item>
        <el-form-item label="凭证说明">
          <el-input v-model="complaintForm.imgs" placeholder="图片URL，多张用逗号分隔（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="complaintDialog = false">取消</el-button>
        <el-button type="danger" :loading="submittingComplaint" @click="handleSubmitComplaint">
          确认提交投诉
        </el-button>
      </template>
    </el-dialog>

    <!-- 改期申请弹窗 -->
    <el-dialog v-model="rescheduleDialog" title="申请改期" width="420px" destroy-on-close>
      <el-alert type="info" :closable="false" style="margin-bottom:16px"
        title="改期后需保洁员确认，确认前原时间暂保留" />
      <el-form>
        <el-form-item label="新预约时间" required>
          <el-date-picker
            v-model="newAppointTime"
            type="datetime"
            placeholder="选择新的预约时间"
            format="YYYY-MM-DD HH:mm"
            value-format="YYYY-MM-DD HH:mm:ss"
            :disabled-date="disablePastDates"
            style="width:100%"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rescheduleDialog = false">取消</el-button>
        <el-button type="primary" :loading="submittingReschedule" @click="handleSubmitReschedule">
          提交申请
        </el-button>
      </template>
    </el-dialog>

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
import { ref, computed, onMounted, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getOrderDetail, cancelOrder, confirmComplete, reportNoShow, getOrderReview, submitReview, submitComplaint, getOrderComplaint, submitReschedule, getRescheduleStatus, payDeposit, payFinal, payFull } from '@/api/order'
import { Warning, Clock } from '@element-plus/icons-vue'
import { formatTime } from '@/utils/time'
import { orderStatusText, orderStatusType } from '@/utils/orderStatus'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const order = ref(null)
const cancelDialog = ref(false)
const cancelReason = ref('')
const cancelling = ref(false)

// 评价相关
const existingReview = ref(null)
const reviewForm = ref({ scoreAttitude: 5, scoreQuality: 5, scorePunctual: 5, content: '' })
const submittingReview = ref(false)

// 投诉相关
const complaintDialog    = ref(false)
const submittingComplaint = ref(false)
const existingComplaint  = ref(null)
const complaintForm      = ref({ reason: '', imgs: '' })

// 改期相关
const rescheduleDialog    = ref(false)
const submittingReschedule = ref(false)
const newAppointTime      = ref('')
const rescheduleRecord    = ref(null)

const HINT_MAP = {
  1: '系统正在为您匹配保洁员，请稍候',
  2: '保洁员已收到派单，等待确认接单',
  3: '保洁员已确认，请在预约时间等候',
  4: '保洁员正在为您提供服务',
  5: '服务已完成，请确认完成；超时将自动确认',
  6: '订单已完成，感谢您的使用！',
  7: '投诉已提交，管理员正在处理，请耐心等待',
  8: '订单已取消',
  9: '改期申请已提交，等待保洁员确认，原时间暂保留',
}

function statusHint(s) { return HINT_MAP[s] || '' }

const showActions = computed(() => order.value && [1, 2, 3, 5].includes(order.value.status))

// status=3 且距预约时间 > 2小时时可申请改期
const canReschedule = computed(() => {
  if (!order.value || order.value.status !== 3 || !order.value.appointTime) return false
  const appoint = new Date(order.value.appointTime)
  return (appoint - new Date()) > 2 * 60 * 60 * 1000
})

// 是否可以评价：status=6 已完成 且 已全额支付，或投诉已结案（非免费重做）
const canReview = computed(() => {
  if (!order.value) return false
  const complaintClosed = existingComplaint.value?.status === 3
  const isRedo = existingComplaint.value?.result === 3
  if (isRedo) return false  // 免费重做：原订单不评价
  // 投诉结案不受支付状态限制（退款类已结案，支付已处理）
  if (complaintClosed) return true
  // 正常完成：必须已全额支付才能评价
  return order.value.status === 6 && order.value.payStatus === 2
})

// 是否需要显示支付催促警告（服务已完成但未付款）
const showPayWarning = computed(() => {
  if (!order.value) return false
  return [5, 6].includes(order.value.status) && order.value.payStatus !== 2
})


// 已完成后7天内可投诉（且未投诉过）
const canComplaintAfterDone = computed(() => {
  if (!order.value || order.value.status !== 6 || existingComplaint.value) return false
  if (!order.value.completedAt) return true
  const completed = new Date(order.value.completedAt)
  completed.setDate(completed.getDate() + 7)
  return new Date() < completed
})

// 是否可以报告未到场：状态=已接单(3) 且 当前时间超过预约时间+30分钟
const canReportNoShow = computed(() => {
  if (!order.value || order.value.status !== 3) return false
  const appointTime = new Date(order.value.appointTime)
  appointTime.setMinutes(appointTime.getMinutes() + 30)
  return new Date() > appointTime
})

function fmtComplaintTime(t) { return t ? t.replace('T', ' ').slice(0, 16) : '--' }

function resultLabel(r) {
  return { 1: '全额退款', 2: '驳回投诉', 3: '免费重做', 4: '部分退款' }[r] ?? '--'
}
function resultTagType(r) {
  return { 1: 'danger', 2: 'info', 3: 'primary', 4: 'warning' }[r] ?? 'info'
}

async function loadOrder() {
  loading.value = true
  try {
    const res = await getOrderDetail(route.params.id)
    order.value = res
    if (res.status === 6) {
      existingReview.value = await getOrderReview(route.params.id)
    }
    // 已投诉或售后中时，加载投诉记录
    if ([5, 6, 7].includes(res.status)) {
      try {
        existingComplaint.value = await getOrderComplaint(route.params.id)
      } catch { /* 无投诉记录 */ }
    }
    // 改期审核中时加载改期记录
    if (res.status === 9) {
      try {
        rescheduleRecord.value = await getRescheduleStatus(route.params.id)
      } catch { /* 无改期记录 */ }
    }
  } catch (e) {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

function openRescheduleDialog() {
  newAppointTime.value = ''
  rescheduleDialog.value = true
}

async function handleSubmitReschedule() {
  if (!newAppointTime.value) {
    ElMessage.warning('请选择新的预约时间')
    return
  }
  await ElMessageBox.confirm(
    '提交后需等待保洁员确认，确认继续申请改期？',
    '改期确认', { type: 'warning' }
  )
  submittingReschedule.value = true
  try {
    await submitReschedule(route.params.id, newAppointTime.value)
    ElMessage.success('改期申请已提交，请等待保洁员确认')
    rescheduleDialog.value = false
    await loadOrder()
  } catch (e) {
    ElMessage.error(e.message || '提交失败')
  } finally {
    submittingReschedule.value = false
  }
}

function disablePastDates(date) {
  return date < new Date(new Date().setHours(0, 0, 0, 0))
}

function openComplaintDialog() {
  complaintForm.value = { reason: '', imgs: '' }
  complaintDialog.value = true
}

async function handleSubmitComplaint() {
  if (!complaintForm.value.reason.trim()) {
    ElMessage.warning('请填写投诉原因')
    return
  }
  await ElMessageBox.confirm(
    order.value.status === 5
      ? '提交投诉后订单将进入售后处理状态，确认继续？'
      : '确认发起售后投诉？',
    '投诉确认', { type: 'warning', confirmButtonText: '确认提交', confirmButtonClass: 'el-button--danger' }
  )
  submittingComplaint.value = true
  try {
    await submitComplaint(route.params.id, complaintForm.value)
    ElMessage.success('投诉已提交，管理员将在1-3个工作日内处理')
    complaintDialog.value = false
    await loadOrder()
  } catch (e) {
    ElMessage.error(e.message || '提交失败')
  } finally {
    submittingComplaint.value = false
  }
}

async function handleSubmitReview() {
  submittingReview.value = true
  try {
    await submitReview(route.params.id, reviewForm.value)
    ElMessage.success('评价提交成功，感谢您的反馈！')
    existingReview.value = await getOrderReview(route.params.id)
  } catch (e) {
    ElMessage.error(e.message || '提交失败')
  } finally {
    submittingReview.value = false
  }
}

function handleCancel() {
  cancelReason.value = ''
  cancelDialog.value = true
}

async function confirmCancel() {
  cancelling.value = true
  try {
    await cancelOrder(route.params.id, cancelReason.value)
    ElMessage.success('订单已取消')
    cancelDialog.value = false
    await loadOrder()
  } catch (e) {
    ElMessage.error(e.message || '取消失败')
  } finally {
    cancelling.value = false
  }
}

async function handleConfirm() {
  // 未完成支付时，先强制支付再确认完成
  if (order.value.payStatus !== 2) {
    const payAmount = order.value.payStatus === 1 ? tailFeePreview.value : (order.value.actualFee ?? order.value.estimateFee)
    const payLabel = order.value.payStatus === 1 ? '尾款' : '全额'
    const payFn = order.value.payStatus === 1 ? () => payFinal(route.params.id) : () => payFull(route.params.id)
    try {
      await ElMessageBox.confirm(
        `确认完成前需先完成支付\n支付金额：¥${payAmount}`,
        `模拟支付 — ${payLabel}`,
        { type: 'warning', confirmButtonText: '确认支付', cancelButtonText: '取消' }
      )
      await payFn()
      ElMessage.success('支付成功')
      await loadOrder()
    } catch {
      return
    }
  }
  try {
    await ElMessageBox.confirm('确认服务已完成？', '提示', { type: 'warning' })
    await confirmComplete(route.params.id)
    ElMessage.success('确认成功，感谢使用！')
    await loadOrder()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e.message || '操作失败')
  }
}

async function handleNoShow() {
  await ElMessageBox.confirm(
    '确认报告保洁员未到场？订单将被取消，平台会记录此次异常。',
    '报告未到场', { type: 'warning', confirmButtonText: '确认报告', confirmButtonClass: 'el-button--danger' }
  )
  try {
    await reportNoShow(route.params.id)
    ElMessage.success('已报告，订单已取消')
    await loadOrder()
  } catch (e) {
    ElMessage.error(e.message || '操作失败')
  }
}

// ─────────── 支付 ───────────

// 定金预览（estimateFee × 0.20，2位小数）
const depositPreview = computed(() => {
  if (!order.value?.estimateFee) return '--'
  return (parseFloat(order.value.estimateFee) * 0.3).toFixed(2)
})

// 尾款预览（depositFee 为空时用前端估算定金兜底）
const tailFeePreview = computed(() => {
  if (!order.value) return '--'
  const actual = parseFloat(order.value.actualFee ?? order.value.estimateFee ?? 0)
  const deposit = parseFloat(order.value.depositFee ?? depositPreview.value ?? 0)
  return (actual - deposit).toFixed(2)
})

async function confirmSimPay(label, amount, action) {
  await ElMessageBox.confirm(
    `这是模拟支付，点击确认即视为支付成功\n支付金额：¥${amount}`,
    `模拟支付 — ${label}`,
    { type: 'info', confirmButtonText: '确认支付', cancelButtonText: '取消' }
  )
  await action()
  ElMessage.success('支付成功')
  await loadOrder()
}

function scrollToPayCard() {
  nextTick(() => {
    document.querySelector('.pay-card-anchor')?.scrollIntoView({ behavior: 'smooth', block: 'center' })
  })
}

async function handlePayDeposit() {
  await confirmSimPay('定金', depositPreview.value, () => payDeposit(route.params.id))
}

async function handlePayFinal() {
  await confirmSimPay('尾款', tailFeePreview.value, () => payFinal(route.params.id))
}

async function handlePayFull() {
  const amount = order.value.actualFee ?? order.value.estimateFee
  await confirmSimPay('全额', amount, () => payFull(route.params.id))
}

onMounted(loadOrder)
</script>

<style scoped>
.detail-page { width: 100%; }
.section-title { font-size: 14px; font-weight: 600; color: #111; }

.status-section { margin-bottom: 12px; }
.status-hint { margin-top: 8px; font-size: 13px; color: #6b7280; }
.action-row { display: flex; gap: 12px; margin-top: 12px; flex-wrap: wrap; }

.fee { font-size: 16px; font-weight: 700; color: #ef4444; }
.fee-original { font-size: 14px; color: #9ca3af; text-decoration: line-through; margin-right: 6px; }
.fee-adjusted { font-size: 16px; font-weight: 700; color: #16a34a; }
.text-muted { color: #c0c4cc; font-size: 13px; }

.addr-box { padding: 4px 0; }
.addr-contact { font-size: 14px; font-weight: 500; margin-bottom: 6px; }
.addr-detail { font-size: 13px; color: #6b7280; }

.remark-text { font-size: 13px; color: #6b7280; line-height: 1.6; }
.no-show-tip { margin-top: 10px; font-size: 12px; color: #9ca3af; }

.review-row { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
.review-label { font-size: 13px; color: #6b7280; width: 60px; flex-shrink: 0; }
.review-content { font-size: 14px; color: #111; background: #eff6ff; border-radius: 8px; padding: 10px 14px; margin: 8px 0; border-left: 3px solid #2563eb; }
.review-time { font-size: 12px; color: #9ca3af; margin-top: 8px; }

.after-sale-tip { display: flex; align-items: center; gap: 10px; margin-top: 12px; }
.tip-text { font-size: 12px; color: #9ca3af; }

.complaint-status {
  display: flex; align-items: center; gap: 8px;
  margin-top: 12px; padding: 10px 14px;
  background: #fff7ed; border-radius: 8px;
  border-left: 3px solid #f59e0b;
  font-size: 13px; color: #606266; flex-wrap: wrap;
}
.complaint-remark { color: #374151; margin-top: 4px; width: 100%; }
.complaint-tip { margin-bottom: 4px; }
.refund-amount { font-size: 18px; font-weight: 700; color: #16a34a; }
.closed-tip { font-size: 13px; color: #606266; }

.reschedule-status {
  display: flex; align-items: center; gap: 6px;
  margin-top: 12px; padding: 10px 14px;
  background: #fffbeb; border-radius: 8px;
  border-left: 3px solid #f59e0b;
  font-size: 13px; color: #606266; flex-wrap: wrap;
}

.pay-done { padding: 4px 0; }
.pay-amount { font-size: 22px; font-weight: 700; color: #ef4444; }
.pay-paid { font-size: 13px; color: #6b7280; margin-bottom: 6px; }
.pay-sub { font-size: 12px; color: #9ca3af; margin-top: 2px; }
.pay-hint { font-size: 12px; color: #9ca3af; margin-top: 6px; }
</style>
