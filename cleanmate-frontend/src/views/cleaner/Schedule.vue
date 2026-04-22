<template>
  <div class="schedule-wrap">
    <!-- 页面标题 -->
    <div class="page-header">
      <div>
        <h2 class="page-title">档期管理</h2>
        <p class="page-sub">设置您的工作时段，系统将在可接单时段内为您派单</p>
      </div>
    </div>

    <div class="schedule-grid">
      <!-- ═══ 左侧：每周固定时段 ═══ -->
      <div class="panel template-panel">
        <div class="panel-header">
          <div class="panel-header-left">
            <span class="panel-dot panel-dot--green"></span>
            <span class="panel-title">每周固定时段</span>
          </div>
        </div>

        <div class="template-list" v-loading="templateLoading">
          <div
            v-for="item in templateDays"
            :key="item.dayOfWeek"
            class="template-row"
            :class="{ 'template-row--active': item.isWork }"
          >
            <div class="day-info">
              <span class="day-label">{{ DAY_NAMES[item.dayOfWeek - 1] }}</span>
              <el-switch
                v-model="item.isWork"
                size="small"
                active-color="#2A6B47"
              />
            </div>
            <div class="time-pickers" :class="{ 'time-pickers--disabled': !item.isWork }">
              <el-time-picker
                v-model="item.startTimeDate"
                placeholder="开始"
                format="HH:mm"
                :disabled="!item.isWork"
                size="small"
                style="width:95px"
              />
              <span class="time-sep">~</span>
              <el-time-picker
                v-model="item.endTimeDate"
                placeholder="结束"
                format="HH:mm"
                :disabled="!item.isWork"
                size="small"
                style="width:95px"
              />
            </div>
            <div class="day-status" v-if="item.isWork">
              <span class="status-dot-on"></span>
              <span class="status-text-on">工作日</span>
            </div>
            <div class="day-status" v-else>
              <span class="status-dot-off"></span>
              <span class="status-text-off">休息</span>
            </div>
          </div>
        </div>

        <div class="template-footer">
          <el-button @click="quickSet" plain size="default" style="border-radius:50px">
            一键设置工作日
          </el-button>
          <el-button type="primary" @click="saveTemplate" :loading="saving" size="default" style="border-radius:50px">
            保存设置
          </el-button>
        </div>
      </div>

      <!-- ═══ 右侧：特殊调整日历 ═══ -->
      <div class="panel calendar-panel">
        <div class="panel-header">
          <div class="panel-header-left">
            <span class="panel-dot panel-dot--orange"></span>
            <span class="panel-title">特殊调整日历</span>
          </div>
          <div class="month-nav">
            <el-button :icon="ArrowLeft" circle size="small" @click="prevMonth" />
            <span class="year-month">{{ yearMonth }}</span>
            <el-button :icon="ArrowRight" circle size="small" @click="nextMonth" />
          </div>
        </div>

        <!-- 图例 -->
        <div class="legend">
          <span class="legend-item">
            <i class="legend-dot legend-dot--override"></i>
            特殊调整
          </span>
          <span class="legend-item">
            <i class="legend-dot legend-dot--lock"></i>
            已接单时段
          </span>
          <span class="legend-item">
            <i class="legend-dot legend-dot--today"></i>
            今日
          </span>
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
                'has-override': cell.hasOverride,
                'clickable': cell.inMonth,
              }"
              @click="cell.inMonth && openDialog(cell.dateStr)"
            >
              <div class="cell-date" :class="{ 'today-badge': cell.isToday }">
                {{ cell.day }}
              </div>
              <div class="cell-marks">
                <span v-if="cell.hasOverride" class="mark mark-override" :title="cell.overrideLabel">调</span>
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
      </div>
    </div>

    <!-- ═══ 特殊调整 Dialog ═══ -->
    <el-dialog
      v-model="dialogVisible"
      :title="`设置 ${selectedDate} 档期`"
      width="420px"
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
            <el-time-picker v-model="form.startTimeDate" format="HH:mm" placeholder="14:00" style="width:160px" />
          </el-form-item>
          <el-form-item label="结束时间">
            <el-time-picker v-model="form.endTimeDate" format="HH:mm" placeholder="18:00" style="width:160px" />
          </el-form-item>
        </template>
        <el-form-item label="备注">
          <el-input v-model="form.remark" placeholder="可选，如：请假 / 下午可接单" maxlength="50" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div style="display:flex; justify-content:space-between; align-items:center">
          <el-button v-if="existingOverrideId" type="danger" plain @click="removeOverride" :loading="submitting">
            删除调整
          </el-button>
          <div v-else></div>
          <div>
            <el-button @click="dialogVisible = false">取消</el-button>
            <el-button type="primary" @click="submitOverride" :loading="submitting">确定</el-button>
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

const DAY_NAMES = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']

function strToDate(str) {
  if (!str) return null
  const [h, m] = str.split(':').map(Number)
  const d = new Date()
  d.setHours(h, m, 0, 0)
  return d
}

function dateToStr(date) {
  if (!date) return null
  const h = String(date.getHours()).padStart(2, '0')
  const m = String(date.getMinutes()).padStart(2, '0')
  return `${h}:${m}`
}

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

const templateLoading = ref(false)
const saving = ref(false)

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

const calLoading = ref(false)
const overrideMap = ref({})
const lockMap = ref({})

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

const calendarCells = computed(() => {
  const y = currentYear.value
  const m = currentMonth.value
  const firstWeekday = new Date(y, m - 1, 1).getDay()
  const daysInMonth  = new Date(y, m, 0).getDate()
  const today = new Date()
  const cells = []
  const prevDays = new Date(y, m - 1, 0).getDate()
  for (let i = firstWeekday - 1; i >= 0; i--) {
    cells.push({ key: `p${i}`, day: prevDays - i, inMonth: false, isToday: false,
      hasOverride: false, lockSlots: [], overrideLabel: '', dateStr: '' })
  }
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
    cells.push({ key: dateStr, day: d, inMonth: true, isToday, hasOverride: !!ov, lockSlots: slots, overrideLabel, dateStr })
  }
  const remaining = 42 - cells.length
  for (let d = 1; d <= remaining; d++) {
    cells.push({ key: `n${d}`, day: d, inMonth: false, isToday: false,
      hasOverride: false, lockSlots: [], overrideLabel: '', dateStr: '' })
  }
  return cells
})

const dialogVisible    = ref(false)
const submitting       = ref(false)
const selectedDate     = ref('')
const existingOverrideId = ref(null)
const form = ref({ isOff: 1, startTimeDate: null, endTimeDate: null, remark: '' })

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

function quickSet() {
  templateDays.value = templateDays.value.map(d => {
    const isWork = d.dayOfWeek <= 6
    return { ...d, isWork, startTimeDate: isWork ? strToDate('09:00') : null, endTimeDate: isWork ? strToDate('20:00') : null }
  })
}

onMounted(() => {
  loadTemplate()
  loadCalData()
})
</script>

<style scoped>
.schedule-wrap {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: calc(100vh - 60px - 68px);
}

/* ── 顶部 ── */
.page-header {
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 16px;
  padding: 18px 24px;
}
.page-title { font-size: 22px; font-weight: 800; color: #1C3D2A; margin: 0 0 4px; }
.page-sub { font-size: 13px; color: #6B7280; margin: 0; }

/* ── 双栏布局 ── */
.schedule-grid {
  display: grid;
  grid-template-columns: 380px 1fr;
  gap: 16px;
  flex: 1;
  align-items: stretch;
}

.template-panel {
  display: flex;
  flex-direction: column;
}

.template-list {
  flex: 1;
}

.panel {
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 16px;
  padding: 20px 22px;
}
.panel-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 18px;
}
.panel-header-left { display: flex; align-items: center; gap: 8px; }
.panel-dot {
  width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0;
}
.panel-dot--green  { background: #2A6B47; box-shadow: 0 0 0 3px #DCFCE7; }
.panel-dot--orange { background: #D97706; box-shadow: 0 0 0 3px #FEF3C7; }
.panel-title { font-size: 16px; font-weight: 700; color: #1C3D2A; }

/* ── 周模板 ── */
.template-list { display: flex; flex-direction: column; gap: 6px; margin-bottom: 20px; }
.template-row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 11px 14px;
  border-radius: 10px;
  border: 1.5px solid #E5E7EB;
  background: #FAFBFA;
  transition: all .18s;
}
.template-row--active {
  border-color: #6EE7A0;
  background: #F0FDF4;
}
.day-info { display: flex; align-items: center; gap: 8px; width: 70px; flex-shrink: 0; }
.day-label { font-size: 13px; font-weight: 700; color: #1C3D2A; width: 28px; }
.time-pickers { display: flex; align-items: center; gap: 6px; flex: 1; }
.time-pickers--disabled { opacity: .45; }
.time-sep { font-size: 12px; color: #9CA3AF; }
.day-status { display: flex; align-items: center; gap: 4px; flex-shrink: 0; }
.status-dot-on  { width: 6px; height: 6px; border-radius: 50%; background: #2A6B47; }
.status-dot-off { width: 6px; height: 6px; border-radius: 50%; background: #D1D5DB; }
.status-text-on  { font-size: 11px; color: #2A6B47; font-weight: 600; }
.status-text-off { font-size: 11px; color: #9CA3AF; }
.template-footer {
  display: flex; justify-content: flex-end; gap: 10px;
  padding-top: 16px; border-top: 1px solid #E5EDE5;
}

/* ── 月历导航 ── */
.month-nav { display: flex; align-items: center; gap: 10px; }
.year-month { font-size: 14px; font-weight: 700; color: #1C3D2A; white-space: nowrap; }

/* ── 图例 ── */
.legend {
  display: flex; align-items: center; gap: 14px;
  margin-bottom: 14px; font-size: 12px; color: #6B7280; flex-wrap: wrap;
}
.legend-item { display: flex; align-items: center; gap: 5px; }
.legend-tip { margin-left: auto; color: #9CA3AF; font-style: italic; }
.legend-dot {
  width: 11px; height: 11px; border-radius: 3px; display: inline-block;
}
.legend-dot--override { background: #D97706; }
.legend-dot--lock     { background: #EF4444; }
.legend-dot--today    { background: #2A6B47; border-radius: 50%; }

/* ── 日历 ── */
.calendar {
  border: 1.5px solid #E0EBE0;
  border-radius: 12px;
  overflow: hidden;
}
.cal-weekdays {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  background: #F0F5F0;
  border-bottom: 1.5px solid #E0EBE0;
}
.cal-weekday {
  text-align: center;
  padding: 10px 0;
  font-size: 12px;
  font-weight: 700;
  color: #2A6B47;
}
.cal-body {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
}
.cal-cell {
  min-height: 78px;
  border-top: 1px solid #E5EDE5;
  border-right: 1px solid #E5EDE5;
  padding: 7px 6px;
  position: relative;
  box-sizing: border-box;
  transition: background .15s;
}
.cal-cell:nth-child(7n) { border-right: none; }
.cal-cell.other-month { background: #FAFBFA; }
.cal-cell.other-month .cell-date { color: #D1D5DB; }
.cal-cell.clickable { cursor: pointer; }
.cal-cell.clickable:hover { background: #F0FDF4; }
.cal-cell.is-today { background: #F0FDF4; }
.cal-cell.has-override { background: #FFFBEB; }

.cell-date {
  font-size: 13px; font-weight: 500;
  margin-bottom: 4px;
  width: 26px; height: 26px;
  display: flex; align-items: center; justify-content: center;
}
.today-badge {
  background: #2A6B47; color: #fff;
  border-radius: 50%; font-weight: 700;
}
.cell-marks { display: flex; gap: 3px; flex-wrap: wrap; }
.mark {
  font-size: 9px; padding: 1px 4px;
  border-radius: 4px; font-weight: 700; line-height: 1.5;
}
.mark-override { background: #FEF3C7; color: #B45309; }
.mark-lock     { background: #FEE2E2; color: #B91C1C; white-space: nowrap; letter-spacing: -0.3px; }
</style>
