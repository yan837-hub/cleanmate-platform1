<template>
  <div class="schedule-wrap">
    <el-row :gutter="20">

      <!-- ═══ 左侧：每周固定时段 ═══ -->
      <el-col :span="9">
        <el-card>
          <template #header>
            <span style="font-size:15px; font-weight:600">每周固定时段</span>
          </template>

          <div v-loading="templateLoading">
            <div
              v-for="item in templateDays"
              :key="item.dayOfWeek"
              class="template-row"
            >
              <span class="day-label">{{ DAY_NAMES[item.dayOfWeek - 1] }}</span>
              <el-switch v-model="item.isWork" size="small" />
              <el-time-picker
                v-model="item.startTimeDate"
                placeholder="开始"
                format="HH:mm"
                :disabled="!item.isWork"
                size="small"
                style="width:100px"
              />
              <span class="sep">~</span>
              <el-time-picker
                v-model="item.endTimeDate"
                placeholder="结束"
                format="HH:mm"
                :disabled="!item.isWork"
                size="small"
                style="width:100px"
              />
            </div>

            <div class="template-footer">
              <el-button @click="quickSet">一键设置工作日</el-button>
              <el-button type="primary" @click="saveTemplate" :loading="saving">
                保存设置
              </el-button>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- ═══ 右侧：特殊调整日历 ═══ -->
      <el-col :span="15">
        <el-card>
          <template #header>
            <div class="cal-header-bar">
              <span style="font-size:15px; font-weight:600">特殊调整</span>
              <div class="month-nav">
                <el-button :icon="ArrowLeft" circle size="small" @click="prevMonth" />
                <span class="year-month">{{ yearMonth }}</span>
                <el-button :icon="ArrowRight" circle size="small" @click="nextMonth" />
              </div>
            </div>
          </template>

          <!-- 图例 -->
          <div class="legend">
            <span class="legend-item"><i class="dot dot-override"></i>特殊调整</span>
            <span class="legend-item"><i class="dot dot-lock"></i>已接单时段</span>
            <span class="legend-tip">点击任意日期可设置调整</span>
          </div>

          <!-- 日历 -->
          <div class="calendar" v-loading="calLoading">
            <div class="cal-weekdays">
              <div v-for="d in ['日','一','二','三','四','五','六']" :key="d" class="cal-weekday">
                {{ d }}
              </div>
            </div>
            <div class="cal-body">
              <div
                v-for="cell in calendarCells"
                :key="cell.key"
                class="cal-cell"
                :class="{
                  'other-month': !cell.inMonth,
                  'is-today': cell.isToday,
                  'clickable': cell.inMonth,
                }"
                @click="cell.inMonth && openDialog(cell.dateStr)"
              >
                <div class="cell-date" :class="{ 'today-badge': cell.isToday }">
                  {{ cell.day }}
                </div>
                <div class="cell-marks">
                  <span v-if="cell.hasOverride" class="mark mark-override"
                    :title="cell.overrideLabel">调</span>
                  <template v-if="cell.lockSlots.length">
                    <span
                      v-for="(slot, i) in cell.lockSlots.slice(0, 2)"
                      :key="i"
                      class="mark mark-lock"
                      :title="`已接单 ${slot.startTime}~${slot.endTime}`"
                    >{{ slot.startTime }}~{{ slot.endTime }}</span>
                    <span v-if="cell.lockSlots.length > 2" class="mark mark-lock">
                      +{{ cell.lockSlots.length - 2 }}
                    </span>
                  </template>
                </div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- ═══ 特殊调整 Dialog ═══ -->
    <el-dialog
      v-model="dialogVisible"
      :title="`设置 ${selectedDate}`"
      width="400px"
      @closed="resetForm"
    >
      <el-form :model="form" label-width="90px" style="padding-right:10px">
        <el-form-item label="调整类型">
          <el-radio-group v-model="form.isOff">
            <el-radio :value="1">全天不可接单</el-radio>
            <el-radio :value="0">自定义可接单时段</el-radio>
          </el-radio-group>
        </el-form-item>

        <template v-if="form.isOff === 0">
          <el-form-item label="开始时间">
            <el-time-picker
              v-model="form.startTimeDate"
              format="HH:mm"
              placeholder="14:00"
              style="width:160px"
            />
          </el-form-item>
          <el-form-item label="结束时间">
            <el-time-picker
              v-model="form.endTimeDate"
              format="HH:mm"
              placeholder="18:00"
              style="width:160px"
            />
          </el-form-item>
        </template>

        <el-form-item label="备注">
          <el-input
            v-model="form.remark"
            placeholder="可选，如：请假 / 下午可接单"
            maxlength="50"
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <div style="display:flex; justify-content:space-between; align-items:center">
          <el-button
            v-if="existingOverrideId"
            type="danger"
            plain
            @click="removeOverride"
            :loading="submitting"
          >
            删除调整
          </el-button>
          <div v-else></div>
          <div>
            <el-button @click="dialogVisible = false">取消</el-button>
            <el-button type="primary" @click="submitOverride" :loading="submitting">
              确定
            </el-button>
          </div>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { ArrowLeft, ArrowRight } from '@element-plus/icons-vue'
import {
  getScheduleTemplate,
  saveScheduleTemplate,
  getScheduleOverrides,
  saveScheduleOverride,
  deleteScheduleOverride,
  getScheduleLockedDates,
} from '@/api/order'

// ─── 常量 ───────────────────────────────────────────
const DAY_NAMES = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']

// ─── 时间工具函数 ─────────────────────────────────────
/** "HH:mm" → Date（当天） */
function strToDate(str) {
  if (!str) return null
  const [h, m] = str.split(':').map(Number)
  const d = new Date()
  d.setHours(h, m, 0, 0)
  return d
}

/** Date → "HH:mm" */
function dateToStr(date) {
  if (!date) return null
  const h = String(date.getHours()).padStart(2, '0')
  const m = String(date.getMinutes()).padStart(2, '0')
  return `${h}:${m}`
}

// ─── 月份导航 ──────────────────────────────────────────
const currentYear  = ref(new Date().getFullYear())
const currentMonth = ref(new Date().getMonth() + 1)

const yearMonth = computed(() =>
  `${currentYear.value} 年 ${String(currentMonth.value).padStart(2, '0')} 月`
)
const monthKey = computed(() =>
  `${currentYear.value}-${String(currentMonth.value).padStart(2, '0')}`
)

function prevMonth() {
  if (currentMonth.value === 1) { currentMonth.value = 12; currentYear.value-- }
  else currentMonth.value--
  loadCalData()
}
function nextMonth() {
  if (currentMonth.value === 12) { currentMonth.value = 1; currentYear.value++ }
  else currentMonth.value++
  loadCalData()
}

// ─── 周模板 ────────────────────────────────────────────
const templateLoading = ref(false)
const saving = ref(false)

// 每行的响应式数据（含 Date 对象供 TimePicker 使用）
const templateDays = ref(
  Array.from({ length: 7 }, (_, i) => ({
    dayOfWeek: i + 1,
    isWork: false,
    startTimeDate: null,
    endTimeDate: null,
  }))
)

async function loadTemplate() {
  templateLoading.value = true
  try {
    const list = await getScheduleTemplate()
    // list: [{dayOfWeek, isWork, startTime, endTime}, ...]
    const map = {}
    list.forEach(d => { map[d.dayOfWeek] = d })
    templateDays.value = Array.from({ length: 7 }, (_, i) => {
      const day = i + 1
      const d = map[day]
      return {
        dayOfWeek: day,
        isWork: d ? d.isWork : false,
        startTimeDate: d?.isWork ? strToDate(d.startTime) : null,
        endTimeDate:   d?.isWork ? strToDate(d.endTime)   : null,
      }
    })
  } catch {
    ElMessage.error('加载周模板失败')
  } finally {
    templateLoading.value = false
  }
}

async function saveTemplate() {
  // 校验：isWork=true 时必须填时间
  for (const d of templateDays.value) {
    if (d.isWork && (!d.startTimeDate || !d.endTimeDate)) {
      ElMessage.warning(`${DAY_NAMES[d.dayOfWeek - 1]} 已开启但未填写时间`)
      return
    }
  }
  saving.value = true
  try {
    const payload = templateDays.value.map(d => ({
      dayOfWeek: d.dayOfWeek,
      isWork: d.isWork,
      startTime: d.isWork ? dateToStr(d.startTimeDate) : null,
      endTime:   d.isWork ? dateToStr(d.endTimeDate)   : null,
    }))
    await saveScheduleTemplate(payload)
    ElMessage.success('保存成功')
  } catch {
    ElMessage.error('保存失败，请重试')
  } finally {
    saving.value = false
  }
}

// ─── 日历数据 ──────────────────────────────────────────
const calLoading = ref(false)
/** 当月 override 列表，key by dateStr */
const overrideMap = ref({})     // { "2025-01-15": {id, isOff, startTime, ...} }
/** 当月有效时段锁定，key by dateStr，value 为时段数组 */
const lockMap = ref({})         // { "2025-01-15": [{startTime, endTime}, ...] }

async function loadCalData() {
  calLoading.value = true
  try {
    const [overrides, lockSlots] = await Promise.all([
      getScheduleOverrides(monthKey.value),
      getScheduleLockedDates(monthKey.value),
    ])
    const ovMap = {}
    overrides.forEach(o => { ovMap[o.date] = o })
    overrideMap.value = ovMap
    // 按日期分组时段
    const lkMap = {}
    lockSlots.forEach(s => {
      if (!lkMap[s.date]) lkMap[s.date] = []
      lkMap[s.date].push({ startTime: s.startTime, endTime: s.endTime })
    })
    lockMap.value = lkMap
  } catch {
    ElMessage.error('加载日历数据失败')
  } finally {
    calLoading.value = false
  }
}

// 日历格子计算
const calendarCells = computed(() => {
  const y = currentYear.value
  const m = currentMonth.value
  const firstWeekday = new Date(y, m - 1, 1).getDay() // 0=Sun
  const daysInMonth  = new Date(y, m, 0).getDate()
  const today = new Date()

  const cells = []

  // 前补上月末日
  const prevDays = new Date(y, m - 1, 0).getDate()
  for (let i = firstWeekday - 1; i >= 0; i--) {
    cells.push({ key: `p${i}`, day: prevDays - i, inMonth: false, isToday: false,
      hasOverride: false, lockSlots: [], overrideLabel: '', dateStr: '' })
  }

  // 本月
  for (let d = 1; d <= daysInMonth; d++) {
    const dateStr = `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`
    const isToday = today.getFullYear() === y && today.getMonth() + 1 === m && today.getDate() === d
    const ov = overrideMap.value[dateStr]
    let overrideLabel = ''
    if (ov) {
      overrideLabel = ov.isOff === 1
        ? '全天不可接单'
        : `可接单 ${ov.startTime ?? ''}-${ov.endTime ?? ''}`
    }
    const slots = lockMap.value[dateStr] || []
    cells.push({
      key: dateStr, day: d, inMonth: true, isToday,
      hasOverride: !!ov,
      lockSlots: slots,
      overrideLabel,
      dateStr,
    })
  }

  // 后补（补满 6 行 = 42 格）
  const remaining = 42 - cells.length
  for (let d = 1; d <= remaining; d++) {
    cells.push({ key: `n${d}`, day: d, inMonth: false, isToday: false,
      hasOverride: false, lockSlots: [], overrideLabel: '', dateStr: '' })
  }
  return cells
})

// ─── 特殊调整 Dialog ───────────────────────────────────
const dialogVisible    = ref(false)
const submitting       = ref(false)
const selectedDate     = ref('')
const existingOverrideId = ref(null)

const form = ref({
  isOff: 1,
  startTimeDate: null,
  endTimeDate: null,
  remark: '',
})

function openDialog(dateStr) {
  selectedDate.value = dateStr
  const existing = overrideMap.value[dateStr]
  if (existing) {
    existingOverrideId.value = existing.id
    form.value = {
      isOff: existing.isOff ?? 1,
      startTimeDate: existing.startTime ? strToDate(existing.startTime) : null,
      endTimeDate:   existing.endTime   ? strToDate(existing.endTime)   : null,
      remark: existing.remark ?? '',
    }
  } else {
    existingOverrideId.value = null
    form.value = { isOff: 1, startTimeDate: null, endTimeDate: null, remark: '' }
  }
  dialogVisible.value = true
}

function resetForm() {
  form.value = { isOff: 1, startTimeDate: null, endTimeDate: null, remark: '' }
  existingOverrideId.value = null
  selectedDate.value = ''
}

async function submitOverride() {
  if (form.value.isOff === 0 && (!form.value.startTimeDate || !form.value.endTimeDate)) {
    ElMessage.warning('自定义时段请填写起止时间')
    return
  }
  submitting.value = true
  try {
    const payload = {
      date: selectedDate.value,
      isOff: form.value.isOff,
      startTime: form.value.isOff === 0 ? dateToStr(form.value.startTimeDate) : null,
      endTime:   form.value.isOff === 0 ? dateToStr(form.value.endTimeDate)   : null,
      remark: form.value.remark || null,
    }
    await saveScheduleOverride(payload)
    ElMessage.success('设置成功')
    dialogVisible.value = false
    await loadCalData()
  } catch {
    ElMessage.error('保存失败，请重试')
  } finally {
    submitting.value = false
  }
}

async function removeOverride() {
  if (!existingOverrideId.value) return
  submitting.value = true
  try {
    await deleteScheduleOverride(existingOverrideId.value)
    ElMessage.success('已删除')
    dialogVisible.value = false
    await loadCalData()
  } catch {
    ElMessage.error('删除失败')
  } finally {
    submitting.value = false
  }
}

// ─── 一键设置工作日（周一~周六 09:00-20:00，周日关闭） ──
function quickSet() {
  templateDays.value = templateDays.value.map(d => {
    const isWork = d.dayOfWeek <= 6 // 1~6 工作，7=周日关闭
    return {
      ...d,
      isWork,
      startTimeDate: isWork ? strToDate('09:00') : null,
      endTimeDate:   isWork ? strToDate('20:00') : null,
    }
  })
}

// ─── 初始化 ────────────────────────────────────────────
onMounted(() => {
  loadTemplate()
  loadCalData()
})
</script>

<style scoped>
.schedule-wrap { min-height: 100%; }

/* ── 左侧周模板 ── */
.template-row {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
}
.template-row:last-of-type { border-bottom: none; }
.day-label {
  width: 36px;
  font-size: 13px;
  font-weight: 600;
  color: #303133;
  flex-shrink: 0;
}
.sep { color: #c0c4cc; font-size: 12px; }
.template-footer {
  margin-top: 20px;
  text-align: right;
}

/* ── 右侧日历 ── */
.cal-header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.month-nav {
  display: flex;
  align-items: center;
  gap: 10px;
}
.year-month { font-size: 14px; font-weight: 600; color: #303133; }

.legend {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 12px;
  font-size: 12px;
  color: #606266;
}
.legend-item { display: flex; align-items: center; gap: 4px; }
.legend-tip { margin-left: auto; color: #909399; }
.dot {
  width: 10px; height: 10px;
  border-radius: 2px;
  display: inline-block;
}
.dot-override { background: #f59e0b; }
.dot-lock     { background: #ef4444; }

/* 日历主体 */
.calendar {
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  overflow: hidden;
}
.cal-weekdays {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  background: #f5f5ff;
}
.cal-weekday {
  text-align: center;
  padding: 8px 0;
  font-size: 12px;
  font-weight: 600;
  color: #5b21b6;
}
.cal-body {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
}
.cal-cell {
  min-height: 72px;
  border-top: 1px solid #e4e7ed;
  border-right: 1px solid #e4e7ed;
  padding: 6px;
  position: relative;
  box-sizing: border-box;
}
.cal-cell:nth-child(7n) { border-right: none; }
.cal-cell.other-month { background: #fafafa; }
.cal-cell.other-month .cell-date { color: #c0c4cc; }
.cal-cell.clickable {
  cursor: pointer;
  transition: background 0.15s;
}
.cal-cell.clickable:hover { background: #f5f0ff; }

.cell-date {
  font-size: 13px;
  font-weight: 500;
  margin-bottom: 4px;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.today-badge {
  background: #5b21b6;
  color: #fff;
  border-radius: 50%;
  font-weight: 700;
}

.cell-marks {
  display: flex;
  gap: 3px;
  flex-wrap: wrap;
}
.mark {
  font-size: 10px;
  padding: 1px 4px;
  border-radius: 3px;
  font-weight: 600;
  line-height: 1.5;
}
.mark-override { background: #fef3c7; color: #92400e; }
.mark-lock {
  background: #fee2e2;
  color: #991b1b;
  white-space: nowrap;
  font-size: 9px;
  letter-spacing: -0.3px;
}
</style>
