<template>
  <div>
    <!-- 搜索栏 -->
    <el-card style="margin-bottom:16px">
      <el-form inline>
        <el-form-item label="状态">
          <el-select v-model="filters.status" clearable placeholder="全部" style="width:120px" @change="load">
            <el-option label="正常" :value="1" />
            <el-option label="停用" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="公司名称">
          <el-input v-model="filters.keyword" placeholder="搜索公司名称" clearable style="width:180px" @keyup.enter="load" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="reset">重置</el-button>
        </el-form-item>
        <el-form-item style="float:right">
          <el-button type="primary" @click="openForm(null)">+ 新增公司</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 表格 -->
    <el-card>
      <template #header>
        <span style="font-size:15px;font-weight:600">公司管理</span>
        <span style="float:right;font-size:13px;color:#909399">共 {{ total }} 条</span>
      </template>

      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column label="公司名称" prop="name" min-width="160" show-overflow-tooltip />
        <el-table-column label="营业执照号" prop="licenseNo" width="180" />
        <el-table-column label="联系人" prop="contactName" width="90" />
        <el-table-column label="联系电话" prop="contactPhone" width="130" />
        <el-table-column label="保洁员数" width="90">
          <template #default="{ row }">
            <el-link type="primary" @click="goCleaners(row)">{{ row.cleanerCount ?? 0 }}</el-link>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '正常' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="备注" prop="auditRemark" show-overflow-tooltip />
        <el-table-column label="创建时间" width="155">
          <template #default="{ row }">{{ fmt(row.createdAt) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="openDetail(row)">详情</el-button>
            <el-button type="warning" link @click="openForm(row)">编辑</el-button>
            <el-button v-if="row.status === 1" type="danger"  link @click="toggleStatus(row, 3)">停用</el-button>
            <el-button v-if="row.status === 3" type="success" link @click="toggleStatus(row, 1)">启用</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        style="margin-top:16px;text-align:right"
        background layout="prev, pager, next, total"
        :total="total" :page-size="pageSize"
        v-model:current-page="currentPage" @current-change="load" />
    </el-card>

    <!-- 详情抽屉 -->
    <el-drawer v-model="drawer" title="公司详情" size="440px" destroy-on-close>
      <div v-if="current" style="padding:4px 8px">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="公司名称">{{ current.name }}</el-descriptions-item>
          <el-descriptions-item label="营业执照号">{{ current.licenseNo || '-' }}</el-descriptions-item>
          <el-descriptions-item label="联系人">{{ current.contactName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ current.contactPhone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="公司地址">{{ current.address || '-' }}</el-descriptions-item>
          <el-descriptions-item label="旗下保洁员">{{ current.cleanerCount ?? 0 }} 人</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="current.status === 1 ? 'success' : 'danger'">
              {{ current.status === 1 ? '正常' : '停用' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="备注">{{ current.auditRemark || '-' }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ fmt(current.createdAt) }}</el-descriptions-item>
          <el-descriptions-item label="最后更新">{{ fmt(current.updatedAt) }}</el-descriptions-item>
        </el-descriptions>
        <div v-if="current.licenseImg" style="margin-top:16px">
          <div style="font-size:13px;font-weight:600;color:#606266;margin-bottom:8px">营业执照</div>
          <el-image :src="current.licenseImg" :preview-src-list="[current.licenseImg]"
            style="width:100%;max-height:200px;border-radius:6px;border:1px solid #e4e7ed" fit="contain" />
        </div>
      </div>
    </el-drawer>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="formDialog" :title="formData.id ? '编辑公司' : '新增公司'" width="500px" destroy-on-close>
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="90px">
        <el-form-item label="公司名称" prop="name">
          <el-input v-model="formData.name" placeholder="请输入公司名称" />
        </el-form-item>
        <el-form-item label="营业执照号" prop="licenseNo">
          <el-input v-model="formData.licenseNo" placeholder="请输入营业执照号" />
        </el-form-item>
        <el-form-item label="联系人">
          <el-input v-model="formData.contactName" placeholder="请输入联系人姓名" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="formData.contactPhone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="公司地址">
          <el-input v-model="formData.address" placeholder="请输入公司地址" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="formData.remark" type="textarea" :rows="2" placeholder="备注说明（选填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="formDialog = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="submitForm">确认</el-button>
      </template>
    </el-dialog>

    <!-- 停用确认弹窗 -->
    <el-dialog v-model="statusDialog" title="停用公司" width="420px">
      <el-form label-width="80px">
        <el-form-item label="操作">
          <el-tag type="danger">停用该公司</el-tag>
          <span style="margin-left:8px;font-size:13px;color:#909399">停用后该公司保洁员将无法通过公司名展示</span>
        </el-form-item>
        <el-form-item label="备注原因">
          <el-input v-model="statusRemark" type="textarea" :rows="2" placeholder="请填写停用原因（必填）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="statusDialog = false">取消</el-button>
        <el-button type="danger" :loading="submitting" @click="confirmToggleStatus">确认停用</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getAdminCompanies, createCompany, updateCompany, toggleCompanyStatus } from '@/api/admin'

const router = useRouter()
const list        = ref([])
const total       = ref(0)
const loading     = ref(false)
const currentPage = ref(1)
const pageSize    = 10
const drawer      = ref(false)
const current     = ref(null)
const formDialog  = ref(false)
const statusDialog= ref(false)
const submitting  = ref(false)
const statusRemark= ref('')
const statusTarget= ref(null) // { row, targetStatus }
const filters     = ref({ status: null, keyword: '' })
const formRef     = ref()

const formData = reactive({
  id: null,
  name: '',
  licenseNo: '',
  contactName: '',
  contactPhone: '',
  address: '',
  remark: '',
})

const formRules = {
  name: [{ required: true, message: '请输入公司名称' }],
}

function fmt(t) { return t ? t.replace('T', ' ').slice(0, 16) : '-' }

async function load() {
  loading.value = true
  try {
    const params = { current: currentPage.value, size: pageSize }
    if (filters.value.status != null) params.status = filters.value.status
    if (filters.value.keyword) params.keyword = filters.value.keyword
    const res = await getAdminCompanies(params)
    list.value  = res?.records ?? []
    total.value = res?.total ?? 0
  } catch {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

function reset() {
  filters.value = { status: null, keyword: '' }
  currentPage.value = 1
  load()
}

function openDetail(row) {
  current.value = row
  drawer.value = true
}

function openForm(row) {
  if (row) {
    Object.assign(formData, {
      id: row.id,
      name: row.name,
      licenseNo: row.licenseNo || '',
      contactName: row.contactName || '',
      contactPhone: row.contactPhone || '',
      address: row.address || '',
      remark: row.auditRemark || '',
    })
  } else {
    Object.assign(formData, { id: null, name: '', licenseNo: '', contactName: '', contactPhone: '', address: '', remark: '' })
  }
  formDialog.value = true
}

async function submitForm() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitting.value = true
  try {
    if (formData.id) {
      await updateCompany(formData.id, formData)
      ElMessage.success('编辑成功')
    } else {
      await createCompany(formData)
      ElMessage.success('新增成功')
    }
    formDialog.value = false
    load()
  } catch (e) {
    ElMessage.error(e?.message || '操作失败')
  } finally {
    submitting.value = false
  }
}

function toggleStatus(row, targetStatus) {
  if (targetStatus === 3) {
    statusTarget.value = { row, targetStatus }
    statusRemark.value = ''
    statusDialog.value = true
  } else {
    doToggle(row, targetStatus, '')
  }
}

async function confirmToggleStatus() {
  if (!statusRemark.value.trim()) {
    ElMessage.warning('请填写停用原因')
    return
  }
  const { row, targetStatus } = statusTarget.value
  submitting.value = true
  try {
    await doToggle(row, targetStatus, statusRemark.value)
    statusDialog.value = false
  } finally {
    submitting.value = false
  }
}

async function doToggle(row, targetStatus, remark) {
  try {
    await toggleCompanyStatus(row.id, targetStatus, remark)
    ElMessage.success(targetStatus === 1 ? '已启用' : '已停用')
    load()
  } catch (e) {
    ElMessage.error(e?.message || '操作失败')
  }
}

function goCleaners(row) {
  router.push({ path: '/admin/audit/cleaners', query: { companyId: row.id, companyName: row.name } })
}

onMounted(load)
</script>
