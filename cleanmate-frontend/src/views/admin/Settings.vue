<template>
  <div style="max-width:760px">

    <el-form label-width="160px" v-loading="loading">

      <!-- 交易参数 -->
      <el-card style="margin-bottom:20px">
        <template #header><span class="group-title">交易参数</span></template>

        <el-form-item label="平台抽成比例">
          <el-input-number
            v-model="form.platform_commission"
            :min="0" :max="100" :precision="1" :step="1"
            style="width:160px"
          />
          <span class="unit">%</span>
          <div class="hint">订单完成后，平台从保洁员收入中抽取的百分比</div>
        </el-form-item>

        <el-form-item label="可退单截止时间">
          <el-input-number
            v-model="form.refund_deadline_hours"
            :min="0" :max="72" :precision="0" :step="1"
            style="width:160px"
          />
          <span class="unit">小时（服务开始前）</span>
          <div class="hint">顾客在服务开始前 N 小时内可申请退单，超过则不允许</div>
        </el-form-item>

        <el-form-item label="最大派单距离">
          <el-input-number
            v-model="form.dispatch_max_distance_km"
            :min="1" :max="100" :precision="0" :step="1"
            style="width:160px"
          />
          <span class="unit">km</span>
          <div class="hint">超出该距离的保洁员不参与自动派单候选</div>
        </el-form-item>
      </el-card>

      <!-- 派单权重 -->
      <el-card style="margin-bottom:20px">
        <template #header>
          <div style="display:flex;align-items:center;justify-content:space-between">
            <span class="group-title">派单权重配置</span>
            <span class="hint" style="margin-top:0">三项之和建议为 1.0，系统自动归一化</span>
          </div>
        </template>

        <el-form-item label="距离权重">
          <el-slider v-model="form.dispatch_weight_distance" :min="0" :max="1" :step="0.05"
            :format-tooltip="pct" show-input input-size="small" style="width:400px" />
        </el-form-item>

        <el-form-item label="评分权重">
          <el-slider v-model="form.dispatch_weight_rating" :min="0" :max="1" :step="0.05"
            :format-tooltip="pct" show-input input-size="small" style="width:400px" />
        </el-form-item>

        <el-form-item label="接单量权重">
          <el-slider v-model="form.dispatch_weight_order_count" :min="0" :max="1" :step="0.05"
            :format-tooltip="pct" show-input input-size="small" style="width:400px" />
        </el-form-item>

        <el-form-item label="">
          <el-alert
            :title="`当前权重之和：${weightSum}`"
            :type="Math.abs(weightSum - 1) < 0.01 ? 'success' : 'warning'"
            :closable="false" show-icon
          />
        </el-form-item>
      </el-card>

      <!-- 保存 -->
      <el-form-item label="">
        <el-button type="primary" :loading="saving" @click="onSave">保存配置</el-button>
        <el-button @click="onReset">恢复默认</el-button>
      </el-form-item>

    </el-form>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

// 默认值（当数据库无记录时使用）
const DEFAULTS = {
  platform_commission:        15,
  refund_deadline_hours:      2,
  dispatch_max_distance_km:   20,
  dispatch_weight_distance:   0.4,
  dispatch_weight_rating:     0.35,
  dispatch_weight_order_count:0.25,
}

const loading = ref(false)
const saving  = ref(false)
const form    = reactive({ ...DEFAULTS })

const weightSum = computed(() =>
  +((form.dispatch_weight_distance + form.dispatch_weight_rating + form.dispatch_weight_order_count).toFixed(2))
)

async function loadConfig() {
  loading.value = true
  try {
    const data = await request.get('/admin/config')
    if (!data) return
    Object.keys(DEFAULTS).forEach(key => {
      if (data[key] !== undefined) {
        form[key] = Number(data[key])
      }
    })
  } finally {
    loading.value = false
  }
}

async function onSave() {
  saving.value = true
  try {
    const items = [
      { key: 'platform_commission',         value: String(form.platform_commission),         description: '平台抽成比例(%)' },
      { key: 'refund_deadline_hours',        value: String(form.refund_deadline_hours),        description: '退单截止时间(小时)' },
      { key: 'dispatch_max_distance_km',     value: String(form.dispatch_max_distance_km),     description: '派单最大距离(km)' },
      { key: 'dispatch_weight_distance',     value: String(form.dispatch_weight_distance),     description: '派单距离权重' },
      { key: 'dispatch_weight_rating',       value: String(form.dispatch_weight_rating),       description: '派单评分权重' },
      { key: 'dispatch_weight_order_count',  value: String(form.dispatch_weight_order_count),  description: '派单接单量权重' },
    ]
    await request.put('/admin/config', items)
    ElMessage.success('配置已保存')
  } finally {
    saving.value = false
  }
}

function onReset() {
  Object.assign(form, DEFAULTS)
}

function pct(v) { return (v * 100).toFixed(0) + '%' }

onMounted(loadConfig)
</script>

<style scoped>
.group-title { font-size: 15px; font-weight: 600; color: #111827; }
.unit  { margin-left: 8px; color: #6b7280; font-size: 13px; }
.hint  { font-size: 12px; color: #9ca3af; margin-top: 4px; }
</style>
