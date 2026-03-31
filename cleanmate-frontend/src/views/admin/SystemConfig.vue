<template>
  <div class="config-page">

    <!-- 分组卡片 -->
    <div v-for="group in groups" :key="group.title" class="config-group">
      <div class="group-header">
        <el-icon class="group-icon"><component :is="group.icon" /></el-icon>
        <span>{{ group.title }}</span>
      </div>

      <div class="config-list" v-loading="loading">
        <div
          v-for="row in rowsOf(group)"
          :key="row.configKey"
          class="config-row"
          :class="{ editing: editingKey === row.configKey }"
        >
          <!-- 左：说明 -->
          <div class="col-label">
            <span class="label-text">{{ labelMap[row.configKey].name }}</span>
            <span class="label-hint">{{ labelMap[row.configKey].hint }}</span>
          </div>

          <!-- 中：值 / 输入框 -->
          <div class="col-value">
            <template v-if="editingKey === row.configKey">
              <el-input
                v-model="editingValue"
                size="small"
                style="width:120px"
                @keyup.enter="confirmEdit(row)"
                @keyup.esc="cancelEdit"
                ref="editInputRef"
              />
              <span class="unit-tag">{{ labelMap[row.configKey].unit }}</span>
            </template>
            <template v-else>
              <span class="value-num">{{ row.configValue }}</span>
              <span class="unit-tag">{{ labelMap[row.configKey].unit }}</span>
            </template>
          </div>

          <!-- 右：时间 + 操作 -->
          <div class="col-meta">
            <span class="update-time">{{ formatDate(row.updatedAt) }}</span>
          </div>

          <div class="col-action">
            <template v-if="editingKey === row.configKey">
              <el-button type="primary" size="small" :loading="saving" @click="confirmEdit(row)">保存</el-button>
              <el-button size="small" @click="cancelEdit">取消</el-button>
            </template>
            <el-button v-else type="primary" plain size="small" @click="startEdit(row)">编辑</el-button>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, nextTick, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

// key → { name, hint, unit, group }
const labelMap = {
  commission_rate:          { name: '平台佣金比例',     hint: '订单完成后平台从保洁员收入中抽取的比例',       unit: '（如 0.15 = 15%）', group: 'trade' },
  deposit_rate:             { name: '定金比例',         hint: '顾客下单时预付的定金占总价的比例',             unit: '（如 0.20 = 20%）', group: 'trade' },
  auto_confirm_hours:       { name: '自动确认时长',     hint: '服务完成后顾客未操作，系统自动确认完成的等待时间', unit: '小时',             group: 'trade' },
  refund_deadline_hours:    { name: '退单截止时间',     hint: '已接单状态下，顾客最晚可取消订单的时间节点',   unit: '服务开始前 N 小时', group: 'trade' },
  dispatch_max_distance_km: { name: '派单最大距离',     hint: '超出此距离的保洁员不参与自动派单候选',         unit: 'km',               group: 'dispatch' },
  commute_buffer_minutes:   { name: '通勤缓冲时间',     hint: '档期检查时，服务前后各预留的通勤时间',         unit: '分钟',             group: 'dispatch' },
  dispatch_timeout_minutes: { name: '接单响应超时',     hint: '保洁员收到派单通知后，超时未响应则重新派单',   unit: '分钟',             group: 'dispatch' },
  checkin_max_distance_m:   { name: 'GPS 签到偏差上限',   hint: '保洁员签到时与服务地址的最大允许距离偏差',         unit: '米',               group: 'checkin' },
  cleaner_cancel_hours:     { name: '保洁员取消截止时间', hint: '已接单状态下，保洁员最晚可主动取消订单的时间节点', unit: '服务开始前 N 小时', group: 'trade'   },
}

const groups = [
  { title: '交易参数',  icon: 'Money',    key: 'trade'    },
  { title: '派单参数',  icon: 'Location', key: 'dispatch' },
  { title: '签到参数',  icon: 'Position', key: 'checkin'  },
]

const loading = ref(false)
const rows    = ref([])

const editingKey   = ref(null)
const editingValue = ref('')
const saving       = ref(false)
const editInputRef = ref(null)

function rowsOf(group) {
  return rows.value.filter(r => labelMap[r.configKey]?.group === group.key)
}

// 每个 key 对应的默认值（DB 无记录时展示，首次编辑保存后自动写入）
const defaultValues = {
  commission_rate:          '0.15',
  deposit_rate:             '0.20',
  auto_confirm_hours:       '24',
  refund_deadline_hours:    '2',
  cleaner_cancel_hours:     '4',
  commute_buffer_minutes:   '30',
  dispatch_timeout_minutes: '30',
  dispatch_max_distance_km: '30',
  checkin_max_distance_m:   '500',
}

async function loadConfig() {
  loading.value = true
  try {
    const fromDb = (await request.get('/admin/system-config')) ?? []
    const dbMap  = Object.fromEntries(fromDb.map(r => [r.configKey, r]))

    // 以 labelMap 为基准，DB 有则用 DB 数据，DB 没有则用默认值占位
    rows.value = Object.keys(labelMap).map(key => dbMap[key] ?? {
      configKey:   key,
      configValue: defaultValues[key] ?? '—',
      updatedAt:   null,
    })
  } finally {
    loading.value = false
  }
}

function startEdit(row) {
  editingKey.value   = row.configKey
  editingValue.value = row.configValue
  nextTick(() => editInputRef.value?.focus())
}

function cancelEdit() {
  editingKey.value = null
}

async function confirmEdit(row) {
  const newVal = editingValue.value.trim()
  if (newVal === row.configValue) { cancelEdit(); return }

  saving.value = true
  const oldVal = row.configValue
  try {
    await request.put(`/admin/system-config/${row.configKey}`, { configValue: newVal })
    row.configValue = newVal
    row.updatedAt   = new Date().toISOString()
    ElMessage.success('已保存')
    cancelEdit()
  } catch {
    row.configValue = oldVal
    ElMessage.error('保存失败，已还原旧值')
  } finally {
    saving.value = false
  }
}

function formatDate(v) {
  if (!v) return '—'
  return new Date(v).toLocaleString('zh-CN', {
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit',
  })
}

onMounted(loadConfig)
</script>

<style scoped>
.config-page { max-width: 860px; display: flex; flex-direction: column; gap: 20px; }

/* 分组卡片 */
.config-group {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 1px 6px rgba(0,0,0,.06);
  overflow: hidden;
}

.group-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 24px;
  font-size: 14px;
  font-weight: 700;
  color: #111827;
  background: #f9fafb;
  border-bottom: 1px solid #f3f4f6;
}
.group-icon { color: #5b21b6; }

/* 每行参数 */
.config-row {
  display: flex;
  align-items: center;
  padding: 16px 24px;
  border-bottom: 1px solid #f3f4f6;
  gap: 16px;
  transition: background .15s;
}
.config-row:last-child { border-bottom: none; }
.config-row:hover      { background: #fafafa; }
.config-row.editing    { background: #f5f3ff; }

/* 列宽 */
.col-label  { flex: 1; min-width: 0; }
.col-value  { width: 200px; display: flex; align-items: center; gap: 6px; }
.col-meta   { width: 140px; }
.col-action { width: 110px; display: flex; gap: 6px; justify-content: flex-end; }

/* 说明文字 */
.label-text { display: block; font-size: 14px; font-weight: 600; color: #1f2937; }
.label-hint { display: block; font-size: 12px; color: #9ca3af; margin-top: 3px; line-height: 1.4; }

/* 数值 */
.value-num  { font-size: 16px; font-weight: 700; color: #5b21b6; font-family: monospace; }
.unit-tag   { font-size: 12px; color: #6b7280; white-space: nowrap; }

/* 时间 */
.update-time { font-size: 12px; color: #9ca3af; }
</style>
