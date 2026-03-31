<template>
  <div class="book-page">
    <h2 class="outer-title">立即预约</h2>
    <el-card style="border-radius:12px">
      <template #header>
        <span class="page-title">请选择您需要的服务</span>
      </template>

      <el-steps :active="step" finish-status="success" align-center style="margin-bottom: 32px">
        <el-step title="选择服务" />
        <el-step title="预约信息" />
        <el-step title="确认下单" />
      </el-steps>

      <!-- Step 1: 选择服务类型 -->
      <div v-if="step === 0">
        <el-row :gutter="16" style="margin-bottom: 24px">
          <el-col
            v-for="s in serviceTypes"
            :key="s.id"
            :span="8"
            style="margin-bottom: 14px"
          >
            <div
              class="svc-card"
              :class="{ selected: form.serviceTypeId === s.id }"
              @click="selectService(s)"
            >
              <div class="svc-tag" :style="{ background: tagColor(s.id) }">{{ s.name.slice(0, 1) }}</div>
              <div class="svc-info">
                <div class="svc-name">{{ s.name }}</div>
                <div class="svc-desc">{{ s.description }}</div>
                <div class="svc-price">
                  <span v-if="s.priceMode === 1">¥{{ s.basePrice }}/小时</span>
                  <span v-else-if="s.priceMode === 2">¥{{ s.basePrice }}/㎡起</span>
                  <span v-else>¥{{ s.basePrice }}</span>
                </div>
              </div>
              <el-icon v-if="form.serviceTypeId === s.id" class="check-icon" style="color:var(--cm-primary)"><CircleCheckFilled /></el-icon>
            </div>
          </el-col>
        </el-row>
        <div class="step-actions">
          <el-button type="primary" :disabled="!form.serviceTypeId" @click="step = 1">下一步</el-button>
        </div>
      </div>

      <!-- Step 2: 预约信息 -->
      <div v-if="step === 1">
        <el-form :model="form" :rules="rules" ref="formRef" label-width="100px" style="max-width:760px;margin:0 auto">
          <el-form-item label="预约时间" prop="appointTime">
            <el-date-picker
              v-model="form.appointTime"
              type="datetime"
              placeholder="选择预约时间"
              :disabled-date="disabledDate"
              format="YYYY-MM-DD HH:mm"
              value-format="YYYY-MM-DDTHH:mm:ss"
              style="width: 100%"
            />
          </el-form-item>

          <el-form-item
            v-if="selectedService && selectedService.priceMode === 1"
            label="服务时长"
            prop="planDuration"
          >
            <el-input-number
              v-model="form.planDuration"
              :min="selectedService.minDuration || 60"
              :step="60"
            />
            <span style="margin-left: 8px; color: #999">
              分钟（{{ form.planDuration ? (form.planDuration / 60).toFixed(1) : 0 }} 小时）
            </span>
          </el-form-item>

          <el-form-item
            v-if="selectedService && selectedService.priceMode === 2"
            label="房屋面积"
            prop="houseArea"
          >
            <el-input-number v-model="form.houseArea" :min="10" :step="10" />
            <span style="margin-left: 8px; color: #999">㎡</span>
          </el-form-item>

          <el-form-item label="服务地址" prop="addressId">
            <div style="width: 100%">
              <div v-if="addresses.length === 0" class="no-address">暂无地址，请先添加</div>
              <div v-else class="address-list">
                <div
                  v-for="addr in addresses"
                  :key="addr.id"
                  class="address-item"
                  :class="{ selected: form.addressId === addr.id }"
                  @click="form.addressId = addr.id"
                >
                  <div class="addr-top">
                    <el-tag v-if="addr.label" size="small">{{ addr.label }}</el-tag>
                    <el-tag v-if="addr.isDefault" size="small" type="success">默认</el-tag>
                    <span class="addr-contact">{{ addr.contactName }} {{ addr.contactPhone }}</span>
                  </div>
                  <div class="addr-detail">
                    {{ addr.province }}{{ addr.city }}{{ addr.district }}{{ addr.detail }}
                  </div>
                </div>
              </div>
              <el-button text type="primary" style="margin-top: 8px" @click="showAddAddr = true">
                + 新增地址
              </el-button>
            </div>
          </el-form-item>

          <el-form-item label="备注">
            <el-input
              v-model="form.remark"
              type="textarea"
              :rows="2"
              placeholder="特殊要求、门禁密码等（选填）"
            />
          </el-form-item>
        </el-form>
        <div class="step-actions">
          <el-button @click="step = 0">上一步</el-button>
          <el-button type="primary" @click="goConfirm">下一步</el-button>
        </div>
      </div>

      <!-- Step 3: 确认下单 -->
      <div v-if="step === 2" class="confirm-wrap">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="服务类型">
            {{ selectedService && selectedService.name }}
          </el-descriptions-item>
          <el-descriptions-item label="预约时间">
            {{ form.appointTime && form.appointTime.replace('T', ' ') }}
          </el-descriptions-item>
          <el-descriptions-item v-if="form.planDuration" label="服务时长">
            {{ form.planDuration / 60 }} 小时
          </el-descriptions-item>
          <el-descriptions-item v-if="form.houseArea" label="房屋面积">
            {{ form.houseArea }} ㎡
          </el-descriptions-item>
          <el-descriptions-item label="服务地址">
            {{ selectedAddressText }}
          </el-descriptions-item>
          <el-descriptions-item v-if="form.remark" label="备注">
            {{ form.remark }}
          </el-descriptions-item>
        </el-descriptions>

        <!-- 费用汇总区 -->
        <div class="fee-summary">
          <span class="fee-summary-label">预估费用</span>
          <span class="fee-summary-amount">¥ {{ estimatedFee }}</span>
        </div>

        <div class="step-actions">
          <el-button @click="step = 1">上一步</el-button>
          <el-button type="primary" size="large" :loading="submitting" @click="submitOrder">确认提交订单</el-button>
        </div>
      </div>
    </el-card>

    <!-- 新增地址弹窗 -->
    <el-dialog v-model="showAddAddr" title="新增地址" width="500px" @close="resetAddrForm">
      <el-form :model="addrForm" :rules="addrRules" ref="addrFormRef" label-width="90px">
        <el-form-item label="标签">
          <el-input v-model="addrForm.label" placeholder="家/公司（选填）" />
        </el-form-item>
        <el-form-item label="联系人" prop="contactName">
          <el-input v-model="addrForm.contactName" placeholder="姓名" />
        </el-form-item>
        <el-form-item label="手机号" prop="contactPhone">
          <el-input v-model="addrForm.contactPhone" placeholder="手机号" />
        </el-form-item>
        <el-form-item label="省市区" prop="district">
          <el-cascader
            v-model="areaCode"
            :options="regionData"
            @change="handleAreaChange"
            placeholder="请选择省/市/区"
            style="width:100%"
          />
        </el-form-item>
        <el-form-item label="详细地址" prop="detail">
          <el-input v-model="addrForm.detail" placeholder="街道、楼栋、门牌号" />
        </el-form-item>
        <el-form-item label="设为默认">
          <el-switch v-model="addrForm.isDefault" :active-value="1" :inactive-value="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddAddr = false">取消</el-button>
        <el-button type="primary" :loading="savingAddr" @click="saveAddress">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/store/user'
import { ElMessage } from 'element-plus'
import { CircleCheckFilled } from '@element-plus/icons-vue'
import { getServiceTypes } from '@/api/service'
import { getAddresses, addAddress } from '@/api/address'
import { createOrder } from '@/api/order'
import { regionData, codeToText } from 'element-china-area-data'

const router = useRouter()
const userStore = useUserStore()

const step = ref(0)
const serviceTypes = ref([])
const addresses = ref([])
const submitting = ref(false)
const showAddAddr = ref(false)
const savingAddr = ref(false)
const formRef = ref(null)
const addrFormRef = ref(null)

const form = ref({
  serviceTypeId: null,
  appointTime: '',
  planDuration: 120,
  houseArea: null,
  addressId: null,
  remark: ''
})

const areaCode = ref([])
const addrForm = ref({
  label: '',
  contactName: '',
  contactPhone: '',
  province: '',
  city: '',
  district: '',
  detail: '',
  isDefault: 0
})

function handleAreaChange(val) {
  addrForm.value.province = codeToText[val[0]] || ''
  addrForm.value.city     = codeToText[val[1]] || ''
  addrForm.value.district = codeToText[val[2]] || ''
}

watch(showAddAddr, val => {
  if (val) {
    const u = userStore.userInfo
    if (u) {
      addrForm.value.contactName  = u.nickname || ''
      addrForm.value.contactPhone = u.phone    || ''
    }
  }
})

const rules = {
  appointTime: [{ required: true, message: '请选择预约时间', trigger: 'change' }],
  planDuration: [{ required: true, message: '请输入服务时长', trigger: 'change' }],
  houseArea: [{ required: true, message: '请输入房屋面积', trigger: 'change' }]
}

const addrRules = {
  contactName: [{ required: true, message: '请输入联系人姓名', trigger: 'blur' }],
  contactPhone: [{ required: true, message: '请输入手机号', trigger: 'blur' }],
  district:    [{ required: true, message: '请选择省市区', trigger: 'change' }],
  detail:      [{ required: true, message: '请输入详细地址', trigger: 'blur' }],
}

const selectedService = computed(() =>
  serviceTypes.value.find(s => s.id === form.value.serviceTypeId)
)

const selectedAddress = computed(() =>
  addresses.value.find(a => a.id === form.value.addressId)
)

const selectedAddressText = computed(() => {
  const a = selectedAddress.value
  if (!a) return ''
  return `${a.province}${a.city}${a.district}${a.detail}`
})

const estimatedFee = computed(() => {
  const s = selectedService.value
  if (!s) return '0.00'
  const base = parseFloat(s.basePrice)
  if (s.priceMode === 1) {
    const hours = (form.value.planDuration || 0) / 60
    return (hours * base).toFixed(2)
  } else if (s.priceMode === 2) {
    return ((form.value.houseArea || 0) * base).toFixed(2)
  } else {
    return base.toFixed(2)
  }
})

function disabledDate(date) {
  return date < new Date(new Date().setHours(0, 0, 0, 0))
}

const COLORS = ['#5b21b6','#0ea5e9','#f59e0b','#10b981','#3b82f6','#ef4444','#8b5cf6','#ec4899']
function tagColor(id) {
  return COLORS[(id - 1) % COLORS.length]
}

function selectService(s) {
  form.value.serviceTypeId = s.id
  if (s.priceMode === 1 && s.minDuration) {
    form.value.planDuration = s.minDuration
  }
}

async function goConfirm() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  if (!form.value.addressId) {
    ElMessage.warning('请选择服务地址')
    return
  }
  step.value = 2
}

async function submitOrder() {
  submitting.value = true
  try {
    const s = selectedService.value
    const payload = {
      serviceTypeId: form.value.serviceTypeId,
      addressId: form.value.addressId,
      appointTime: form.value.appointTime,
      remark: form.value.remark
    }
    if (s.priceMode === 1) payload.planDuration = form.value.planDuration
    if (s.priceMode === 2) payload.houseArea = form.value.houseArea

    const orderId = await createOrder(payload)
    ElMessage.success('下单成功！')
    router.push(`/customer/orders/${orderId}`)
  } catch (e) {
    ElMessage.error(e.message || '下单失败，请重试')
  } finally {
    submitting.value = false
  }
}

async function saveAddress() {
  const valid = await addrFormRef.value.validate().catch(() => false)
  if (!valid) return
  savingAddr.value = true
  try {
    await addAddress({ ...addrForm.value })
    ElMessage.success('地址添加成功')
    showAddAddr.value = false
    await loadAddresses()
  } catch (e) {
    ElMessage.error(e.message || '添加失败')
  } finally {
    savingAddr.value = false
  }
}

function resetAddrForm() {
  addrForm.value = {
    label: '', contactName: '', contactPhone: '',
    province: '', city: '', district: '', detail: '', isDefault: 0
  }
  areaCode.value = []
  addrFormRef.value && addrFormRef.value.resetFields()
}

async function loadAddresses() {
  try {
    addresses.value = await getAddresses()
    const def = addresses.value.find(a => a.isDefault === 1)
    if (def && !form.value.addressId) form.value.addressId = def.id
  } catch {}
}

onMounted(async () => {
  try {
    serviceTypes.value = await getServiceTypes()
  } catch {}
  await loadAddresses()
})
</script>

<style scoped>
.book-page { width: 100%; }
.outer-title { font-size: 20px; font-weight: 700; color: #111; margin: 0 0 20px; }
.page-title { font-size: 15px; font-weight: 600; color: #374151; }

.svc-card {
  display: flex;
  align-items: center;
  gap: 12px;
  border: 2px solid #e0e7ff;
  border-radius: var(--cm-radius-md);
  padding: 16px;
  cursor: pointer;
  transition: all .2s;
  position: relative;
  background: #fff;
}
.svc-card:hover { border-color: var(--cm-primary); box-shadow: 0 4px 12px rgba(14,165,233,.12); }
.svc-card.selected { border-color: var(--cm-primary); background: #f0f9ff; }

.svc-tag {
  width: 40px; height: 40px; border-radius: 10px; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  color: #fff; font-size: 15px; font-weight: 700;
}
.svc-info { flex: 1; min-width: 0; }
.svc-name { font-size: 14px; font-weight: 600; color: #111; margin-bottom: 2px; }
.svc-desc { font-size: 12px; color: #9ca3af; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: 4px; }
.svc-price { font-size: 13px; color: #ef4444; font-weight: 600; }
.check-icon { position: absolute; top: 8px; right: 8px; font-size: 20px; }

.address-list { display: flex; flex-direction: column; gap: 8px; }
.address-item {
  border: 1px solid #e0e7ff;
  border-radius: 8px;
  padding: 10px 14px;
  cursor: pointer;
  transition: all .2s;
}
.address-item:hover { border-color: var(--cm-primary); }
.address-item.selected { border-color: var(--cm-primary); background: #f0f9ff; }
.addr-top { display: flex; align-items: center; gap: 6px; margin-bottom: 4px; }
.addr-contact { font-size: 13px; color: #303133; }
.addr-detail { font-size: 13px; color: #6b7280; }
.no-address { color: #9ca3af; font-size: 13px; padding: 8px 0; }

.confirm-wrap { max-width: 760px; margin: 0 auto; }

.fee-summary {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 16px;
  padding: 16px 24px;
  background: #f0f9ff;
  border: 1.5px solid var(--cm-primary);
  border-radius: var(--cm-radius-md);
}
.fee-summary-label { font-size: 15px; font-weight: 600; color: #374151; }
.fee-summary-amount { font-size: 28px; font-weight: 700; color: var(--cm-danger); letter-spacing: -0.5px; }

.step-actions { margin-top: 24px; display: flex; justify-content: center; gap: 16px; }

</style>
