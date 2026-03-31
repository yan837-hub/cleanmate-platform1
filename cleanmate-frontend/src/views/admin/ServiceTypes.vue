<template>
  <div class="service-types-page">
    <!-- 顶部工具栏 -->
    <div class="toolbar">
      <el-radio-group v-model="filterStatus" @change="loadList">
        <el-radio-button :value="null">全部</el-radio-button>
        <el-radio-button :value="1">已上架</el-radio-button>
        <el-radio-button :value="2">已下架</el-radio-button>
      </el-radio-group>
      <el-button type="primary" @click="openCreate">+ 新增服务类型</el-button>
    </div>

    <!-- 卡片列表 -->
    <div v-loading="loading" class="card-grid">
      <el-empty v-if="!loading && list.length === 0" description="暂无服务类型，点击右上角新增" :image-size="100" />

      <div
        v-for="item in list"
        :key="item.id"
        class="service-card"
        :class="{ 'is-offline': item.status === 2 }"
      >
        <!-- 左侧图标 -->
        <div class="card-icon" :style="{ background: iconBg(item.id) }">
          {{ item.name.slice(0, 1) }}
        </div>

        <!-- 中间内容 -->
        <div class="card-main">
          <div class="card-top">
            <span class="card-name">{{ item.name }}</span>
            <span class="card-desc">{{ item.description }}</span>
          </div>
          <div class="card-bottom">
            <el-tag size="small" :type="priceModeTag(item.priceMode)" effect="plain">
              {{ priceModeText(item.priceMode) }}
            </el-tag>
            <span class="card-price">¥{{ item.basePrice }}<small>{{ priceUnit(item.priceMode) }}</small></span>
            <span class="card-meta-item" v-if="item.suggestWorkers">{{ item.suggestWorkers }}人</span>
            <span class="card-meta-item" v-if="item.minDuration">{{ item.minDuration }}分钟起</span>
          </div>
          <!-- 面积阶梯小标签 -->
          <div v-if="item.priceMode === 2 && item.priceTiers?.length" class="tier-tags">
            <span v-for="(t, i) in item.priceTiers" :key="i" class="tier-tag">
              {{ t.areaMin }}–{{ t.areaMax || '∞' }}㎡ · ¥{{ t.unitPrice }}/㎡
            </span>
          </div>
        </div>

        <!-- 右侧：状态 + 操作 -->
        <div class="card-right">
          <el-tag
            :type="item.status === 1 ? 'success' : 'info'"
            size="small"
            effect="light"
            class="status-tag"
          >
            {{ item.status === 1 ? '上架中' : '已下架' }}
          </el-tag>
          <div class="card-actions">
            <el-button size="small" text @click="openEdit(item)">编辑</el-button>
            <el-divider direction="vertical" />
            <el-button
              size="small"
              text
              :type="item.status === 1 ? 'warning' : 'success'"
              @click="handleToggleStatus(item)"
            >
              {{ item.status === 1 ? '下架' : '上架' }}
            </el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 分页 -->
    <div v-if="page.total > page.size" class="pagination">
      <el-pagination
        v-model:current-page="page.current"
        v-model:page-size="page.size"
        :total="page.total"
        layout="total, prev, pager, next"
        @current-change="loadList"
      />
    </div>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="editingId ? '编辑服务类型' : '新增服务类型'"
      width="620px"
      destroy-on-close
    >
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">

        <el-form-item label="服务名称" prop="name">
          <el-input v-model="form.name" placeholder="例如：日常保洁" />
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="简短描述该服务内容" />
        </el-form-item>
        <el-form-item label="封面图URL">
          <el-input v-model="form.coverImg" placeholder="https://..." />
        </el-form-item>

        <el-form-item label="计价方式" prop="priceMode">
          <el-radio-group v-model="form.priceMode" @change="onPriceModeChange">
            <el-radio :value="1">按小时</el-radio>
            <el-radio :value="2">按面积</el-radio>
            <el-radio :value="3">固定套餐</el-radio>
          </el-radio-group>
        </el-form-item>

        <!-- 按小时 -->
        <template v-if="form.priceMode === 1">
          <el-form-item label="单价" prop="basePrice">
            <el-input-number v-model="form.basePrice" :precision="2" :min="0" style="width:160px" />
            <span class="unit-label">元 / 小时</span>
          </el-form-item>
          <el-form-item label="最短时长">
            <el-input-number v-model="form.minDuration" :min="30" :step="30" style="width:160px" />
            <span class="unit-label">分钟</span>
          </el-form-item>
        </template>

        <!-- 按面积 -->
        <template v-if="form.priceMode === 2">
          <el-form-item label="起步单价">
            <el-input-number v-model="form.basePrice" :precision="2" :min="0" style="width:160px" />
            <span class="unit-label">元 / ㎡</span>
          </el-form-item>
          <el-form-item label="面积阶梯">
            <div class="tier-list">
              <div v-for="(tier, idx) in form.priceTiers" :key="idx" class="tier-row">
                <el-input-number v-model="tier.areaMin" :min="0" style="width:90px" />
                <span class="tier-sep">㎡ 到</span>
                <el-input-number v-model="tier.areaMax" :min="0" placeholder="0=无上限" style="width:110px" />
                <span class="tier-sep">㎡，</span>
                <el-input-number v-model="tier.unitPrice" :precision="2" :min="0" style="width:95px" />
                <span class="tier-sep">元/㎡</span>
                <el-button type="danger" text @click="removeTier(idx)">删除</el-button>
              </div>
              <el-button size="small" @click="addTier">+ 添加阶梯</el-button>
              <div class="tier-hint">上限填 0 表示该区间无上限，如：120㎡以上填 areaMax=0</div>
            </div>
          </el-form-item>
        </template>

        <!-- 固定套餐 -->
        <template v-if="form.priceMode === 3">
          <el-form-item label="套餐价格" prop="basePrice">
            <el-input-number v-model="form.basePrice" :precision="2" :min="0" style="width:160px" />
            <span class="unit-label">元 / 次</span>
          </el-form-item>
        </template>

        <el-form-item label="建议人数">
          <el-input-number v-model="form.suggestWorkers" :min="1" :max="10" style="width:120px" />
          <span class="unit-label">人</span>
        </el-form-item>
        <el-form-item label="排序权重">
          <el-input-number v-model="form.sortOrder" :min="0" style="width:120px" />
          <span class="unit-label">数值越大越靠前</span>
        </el-form-item>

      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  getServiceTypes,
  createServiceType,
  updateServiceType,
  updateServiceTypeStatus,
} from '@/api/admin'

// ---- 列表 ----
const loading = ref(false)
const list = ref([])
const filterStatus = ref(null)   // 默认全部
const page = reactive({ current: 1, size: 12, total: 0 })

async function loadList() {
  loading.value = true
  try {
    const res = await getServiceTypes({
      current: page.current,
      size: page.size,
      status: filterStatus.value ?? undefined,
    })
    list.value = res.records
    page.total = res.total
  } finally {
    loading.value = false
  }
}

onMounted(loadList)

// ---- 上下架 ----
async function handleToggleStatus(row) {
  const action = row.status === 1 ? '下架' : '上架'
  await ElMessageBox.confirm(`确认将「${row.name}」${action}？`, '提示', { type: 'warning' })
  try {
    const res = await updateServiceTypeStatus(row.id, row.status === 1 ? 2 : 1)
    if (res) ElMessage.warning(res)
    ElMessage.success(`${action}成功`)
    loadList()
  } catch {/* 取消 */}
}

// ---- 弹窗 ----
const dialogVisible = ref(false)
const submitting = ref(false)
const editingId = ref(null)
const formRef = ref()

const defaultForm = () => ({
  name: '', description: '', coverImg: '',
  priceMode: 1, basePrice: null,
  minDuration: 120, suggestWorkers: 1, sortOrder: 0,
  priceTiers: [],
})
const form = reactive(defaultForm())

const rules = {
  name: [{ required: true, message: '请输入服务名称', trigger: 'blur' }],
  priceMode: [{ required: true, message: '请选择计价方式' }],
  basePrice: [{ required: true, message: '请输入价格', trigger: 'blur' }],
}

function openCreate() {
  editingId.value = null
  Object.assign(form, defaultForm())
  dialogVisible.value = true
}

function openEdit(row) {
  editingId.value = row.id
  Object.assign(form, {
    name: row.name,
    description: row.description || '',
    coverImg: row.coverImg || '',
    priceMode: row.priceMode,
    basePrice: Number(row.basePrice),
    minDuration: row.minDuration || 120,
    suggestWorkers: row.suggestWorkers || 1,
    sortOrder: row.sortOrder || 0,
    priceTiers: (row.priceTiers || []).map(t => ({
      areaMin: t.areaMin, areaMax: t.areaMax, unitPrice: Number(t.unitPrice),
    })),
  })
  dialogVisible.value = true
}

function onPriceModeChange() { form.priceTiers = []; form.basePrice = null }
function addTier() { form.priceTiers.push({ areaMin: 0, areaMax: 0, unitPrice: null }) }
function removeTier(idx) { form.priceTiers.splice(idx, 1) }

async function handleSubmit() {
  await formRef.value.validate()
  if (form.priceMode === 2 && form.priceTiers.length === 0) {
    ElMessage.warning('按面积计价请至少添加一条面积阶梯'); return
  }
  submitting.value = true
  try {
    const payload = {
      name: form.name, description: form.description, coverImg: form.coverImg,
      priceMode: form.priceMode, basePrice: form.basePrice,
      minDuration: form.priceMode === 1 ? form.minDuration : null,
      suggestWorkers: form.suggestWorkers, sortOrder: form.sortOrder,
      priceTiers: form.priceMode === 2 ? form.priceTiers : [],
    }
    if (editingId.value) {
      await updateServiceType(editingId.value, payload)
      ElMessage.success('更新成功')
    } else {
      await createServiceType(payload)
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    loadList()
  } finally {
    submitting.value = false
  }
}

// ---- 辅助 ----
function priceModeText(mode) { return { 1: '按小时', 2: '按面积', 3: '固定套餐' }[mode] || '-' }
function priceModeTag(mode)  { return { 1: 'primary', 2: 'warning', 3: 'success' }[mode] || '' }
function priceUnit(mode)     { return { 1: '/小时', 2: '/㎡', 3: '/次' }[mode] || '' }

const ICON_COLORS = ['#4f46e5','#0891b2','#059669','#d97706','#dc2626','#7c3aed','#db2777','#2563eb']
function iconBg(id) { return ICON_COLORS[id % ICON_COLORS.length] }
</script>

<style scoped>
.service-types-page { padding-bottom: 24px; }

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

/* 卡片列表 */
.card-grid {
  display: flex;
  flex-direction: column;
  gap: 10px;
  min-height: 120px;
}

.service-card {
  background: #fff;
  border-radius: 10px;
  border: 1px solid #f0f0f0;
  padding: 16px 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  transition: box-shadow 0.15s;
}
.service-card:hover { box-shadow: 0 2px 12px rgba(0,0,0,0.07); }
.service-card.is-offline { opacity: 0.55; }

/* 左侧彩色图标 */
.card-icon {
  width: 44px;
  height: 44px;
  border-radius: 10px;
  color: #fff;
  font-size: 18px;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

/* 中间主内容 */
.card-main {
  flex: 1;
  min-width: 0;
}
.card-top {
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin-bottom: 7px;
}
.card-name {
  font-size: 15px;
  font-weight: 600;
  color: #1a1a1a;
  white-space: nowrap;
}
.card-desc {
  font-size: 12px;
  color: #aaa;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 320px;
}
.card-bottom {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}
.card-price {
  font-size: 14px;
  font-weight: 600;
  color: #4f46e5;
}
.card-price small { font-size: 11px; font-weight: 400; color: #999; }
.card-meta-item {
  font-size: 12px;
  color: #bbb;
}
.card-meta-item::before { content: '· '; }

/* 阶梯标签行 */
.tier-tags {
  margin-top: 6px;
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}
.tier-tag {
  font-size: 11px;
  color: #6366f1;
  background: #eef2ff;
  border-radius: 4px;
  padding: 1px 7px;
}

/* 右侧状态+操作 */
.card-right {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 10px;
  flex-shrink: 0;
}
.status-tag { min-width: 56px; text-align: center; }
.card-actions {
  display: flex;
  align-items: center;
}

/* 弹窗内 */
.unit-label { margin-left: 8px; color: #666; font-size: 13px; }
.tier-list { width: 100%; }
.tier-row {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-bottom: 8px;
  flex-wrap: wrap;
}
.tier-sep { color: #666; font-size: 13px; white-space: nowrap; }
.tier-hint { margin-top: 4px; font-size: 12px; color: #bbb; }

.pagination { margin-top: 16px; display: flex; justify-content: flex-end; }
</style>
