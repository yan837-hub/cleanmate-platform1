<template>
  <div>
    <!-- 搜索栏 -->
    <el-card style="margin-bottom:16px">
      <el-form inline>
        <el-form-item label="审核状态">
          <el-select v-model="filters.auditStatus" clearable placeholder="全部" style="width:120px" @change="load">
            <el-option label="待审核" :value="2" />
            <el-option label="已通过" :value="1" />
            <el-option label="已拒绝" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="姓名搜索">
          <el-input v-model="filters.keyword" placeholder="真实姓名" clearable style="width:160px" @keyup.enter="load" />
        </el-form-item>
        <el-form-item v-if="companyFilterName" label="公司筛选">
          <el-tag closable @close="clearCompanyFilter" type="primary">{{ companyFilterName }}</el-tag>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="reset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 表格 -->
    <el-card>
      <template #header>
        <span style="font-size:15px;font-weight:600">保洁员管理</span>
        <span style="float:right;font-size:13px;color:#909399">共 {{ total }} 条</span>
      </template>

      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column label="真实姓名" width="100">
          <template #default="{ row }">
            <el-link type="primary" @click="openDetail(row)">{{ row.realName || '-' }}</el-link>
          </template>
        </el-table-column>
        <el-table-column label="手机号" prop="phone" width="130" />
        <el-table-column label="公司/个人" width="160">
          <template #default="{ row }">
            <template v-if="row.companyName && row.companyName !== '个人'">
              <el-tag v-if="row.companyStatus === 3" type="warning" size="small">
                {{ row.companyName }}（已停用）
              </el-tag>
              <el-tag v-else type="primary" size="small">{{ row.companyName }}</el-tag>
            </template>
            <el-tag v-else type="info" size="small">个人</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="服务区域" prop="serviceArea" show-overflow-tooltip />
        <el-table-column label="技能标签" width="160">
          <template #default="{ row }">
            <el-tag v-for="tag in (row.skillTags||'').split(',').filter(Boolean)" :key="tag"
              size="small" style="margin:2px">{{ tag }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="评分" width="70">
          <template #default="{ row }">{{ row.avgScore ? Number(row.avgScore).toFixed(1) : '-' }}</template>
        </el-table-column>
        <el-table-column label="接单数" prop="orderCount" width="70" />
        <el-table-column label="审核状态" width="90">
          <template #default="{ row }">
            <el-tag :type="auditTagType(row.auditStatus)" size="small">{{ auditLabel(row.auditStatus) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="账号状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.userStatus === 1 ? 'success' : 'danger'" size="small">
              {{ row.userStatus === 1 ? '正常' : '已禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="申请时间" width="155">
          <template #default="{ row }">{{ fmt(row.createdAt) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="openDetail(row)">查看</el-button>
            <el-button v-if="row.auditStatus === 2" type="success" link @click="openAudit(row, 1)">通过</el-button>
            <el-button v-if="row.auditStatus === 2" type="danger"  link @click="openAudit(row, 3)">拒绝</el-button>
            <el-button v-if="row.auditStatus === 1 && row.userStatus === 1" type="warning" link @click="toggleStatus(row, 3)">禁用</el-button>
            <el-button v-if="row.auditStatus === 1 && row.userStatus !== 1" type="success" link @click="toggleStatus(row, 1)">启用</el-button>
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
    <el-drawer v-model="drawer" title="保洁员详情" size="480px" destroy-on-close>
      <div v-if="current" style="padding:4px 8px">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="真实姓名">{{ current.realName }}</el-descriptions-item>
          <el-descriptions-item label="手机号">{{ current.phone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="身份证号">{{ current.idCard }}</el-descriptions-item>
          <el-descriptions-item label="公司/个人">
            <template v-if="current.companyName && current.companyName !== '个人'">
              <el-tag v-if="current.companyStatus === 3" type="warning" size="small">
                {{ current.companyName }}（已停用）
              </el-tag>
              <el-tag v-else type="primary" size="small">{{ current.companyName }}</el-tag>
            </template>
            <el-tag v-else type="info" size="small">个人</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="服务区域">{{ current.serviceArea || '-' }}</el-descriptions-item>
          <el-descriptions-item label="技能标签">
            <template v-if="current.skillTags">
              <el-tag v-for="tag in current.skillTags.split(',').filter(Boolean)" :key="tag"
                size="small" style="margin:2px">{{ tag }}</el-tag>
            </template>
            <span v-else style="color:#c0c4cc">暂无</span>
          </el-descriptions-item>
          <el-descriptions-item label="个人简介">{{ current.bio || '-' }}</el-descriptions-item>
          <el-descriptions-item label="审核状态">
            <el-tag :type="auditTagType(current.auditStatus)">{{ auditLabel(current.auditStatus) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="审核备注">{{ current.auditRemark || '-' }}</el-descriptions-item>
          <el-descriptions-item label="评分">{{ current.avgScore ? Number(current.avgScore).toFixed(1) : '-' }}</el-descriptions-item>
          <el-descriptions-item label="累计接单">{{ current.orderCount ?? 0 }} 单</el-descriptions-item>
          <el-descriptions-item label="申请时间">{{ fmt(current.createdAt) }}</el-descriptions-item>
          <el-descriptions-item label="审核时间">{{ fmt(current.auditedAt) }}</el-descriptions-item>
        </el-descriptions>

        <div style="margin-top:16px">
          <div class="cert-title">身份证照片</div>
          <div style="display:flex;gap:10px">
            <template v-if="current.idCardFront || current.idCardBack">
              <el-image v-if="current.idCardFront" :src="current.idCardFront" :preview-src-list="[current.idCardFront]" class="cert-img" fit="cover" />
              <el-image v-if="current.idCardBack"  :src="current.idCardBack"  :preview-src-list="[current.idCardBack]"  class="cert-img" fit="cover" />
            </template>
            <span v-else style="font-size:13px;color:#c0c4cc">未上传</span>
          </div>
        </div>
        <div style="margin-top:12px">
          <div class="cert-title">从业资格证</div>
          <el-image v-if="current.certImg" :src="current.certImg" :preview-src-list="[current.certImg]" class="cert-img" fit="cover" />
          <span v-else style="font-size:13px;color:#c0c4cc">未上传</span>
        </div>
        <div style="margin-top:12px">
          <div class="cert-title">健康证</div>
          <el-image v-if="current.healthCertImg" :src="current.healthCertImg" :preview-src-list="[current.healthCertImg]" class="cert-img" fit="cover" />
          <span v-else style="font-size:13px;color:#c0c4cc">未上传</span>
        </div>

        <div v-if="current.auditStatus === 2" style="margin-top:20px;display:flex;gap:10px">
          <el-button type="success" @click="openAudit(current, 1)">通过审核</el-button>
          <el-button type="danger"  @click="openAudit(current, 3)">拒绝审核</el-button>
        </div>
      </div>
    </el-drawer>

    <!-- 审核对话框 -->
    <el-dialog v-model="auditDialog" :title="auditForm.auditStatus === 1 ? '通过审核' : '拒绝审核'" width="420px">
      <el-form :model="auditForm" label-width="80px">
        <el-form-item label="操作">
          <el-tag :type="auditForm.auditStatus === 1 ? 'success' : 'danger'">
            {{ auditForm.auditStatus === 1 ? '✓ 通过' : '✗ 拒绝' }}
          </el-tag>
        </el-form-item>
        <el-form-item label="备注说明">
          <el-input v-model="auditForm.remark" type="textarea" :rows="3"
            :placeholder="auditForm.auditStatus === 1 ? '可填写通过说明（选填）' : '请填写拒绝原因（必填）'" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="auditDialog = false">取消</el-button>
        <el-button :type="auditForm.auditStatus === 1 ? 'success' : 'danger'"
          :loading="submitting" @click="submitAudit">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getPendingCleaners, auditCleaner, toggleCleanerStatus } from '@/api/admin'

const route = useRoute()

const list        = ref([])
const total       = ref(0)
const loading     = ref(false)
const currentPage = ref(1)
const pageSize    = 10
const drawer      = ref(false)
const current     = ref(null)
const auditDialog = ref(false)
const submitting  = ref(false)
const filters     = ref({ auditStatus: null, keyword: '' })
const auditForm   = ref({ id: null, auditStatus: 1, remark: '' })

// 来自公司页跳转的公司筛选
const companyFilterId   = ref(null)
const companyFilterName = ref('')

function auditTagType(s) { return { 1:'success', 2:'warning', 3:'danger' }[s] ?? 'info' }
function auditLabel(s)   { return { 1:'已通过', 2:'待审核', 3:'已拒绝' }[s] ?? '-' }
function fmt(t) { return t ? t.replace('T', ' ').slice(0, 16) : '-' }

async function load() {
  loading.value = true
  try {
    const params = { current: currentPage.value, size: pageSize }
    if (filters.value.auditStatus != null) params.auditStatus = filters.value.auditStatus
    if (filters.value.keyword) params.keyword = filters.value.keyword
    // 暂不把 companyId 传给后端（后端 keyword 目前只按姓名筛），前端做一次过滤展示即可
    const res = await getPendingCleaners(params)
    let records = res?.records ?? []
    // 若有公司筛选，前端过滤
    if (companyFilterId.value) {
      records = records.filter(r => r.companyId === companyFilterId.value)
    }
    list.value  = records
    total.value = res?.total ?? 0
  } catch {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

function reset() {
  filters.value = { auditStatus: null, keyword: '' }
  companyFilterId.value = null
  companyFilterName.value = ''
  currentPage.value = 1
  load()
}

function clearCompanyFilter() {
  companyFilterId.value = null
  companyFilterName.value = ''
  load()
}

function openDetail(row) {
  current.value = row
  drawer.value = true
}

function openAudit(row, status) {
  auditForm.value = { id: row.id, auditStatus: status, remark: '' }
  auditDialog.value = true
}

async function submitAudit() {
  if (auditForm.value.auditStatus === 3 && !auditForm.value.remark.trim()) {
    ElMessage.warning('拒绝时必须填写原因')
    return
  }
  submitting.value = true
  try {
    await auditCleaner(auditForm.value.id, auditForm.value.auditStatus, auditForm.value.remark)
    ElMessage.success(auditForm.value.auditStatus === 1 ? '审核通过' : '已拒绝')
    auditDialog.value = false
    drawer.value = false
    load()
  } catch (e) {
    ElMessage.error(e?.message || '操作失败')
  } finally {
    submitting.value = false
  }
}

async function toggleStatus(row, status) {
  const action = status === 3 ? '禁用' : '启用'
  try {
    await ElMessageBox.confirm(`确认${action}保洁员「${row.realName}」？`, '提示', { type: 'warning' })
    await toggleCleanerStatus(row.userId, status)
    ElMessage.success(`已${action}`)
    load()
  } catch (e) {
    if (e !== 'cancel') ElMessage.error(e?.message || '操作失败')
  }
}

onMounted(() => {
  // 支持从公司管理页跳转过来携带 companyId 参数
  if (route.query.companyId) {
    companyFilterId.value = Number(route.query.companyId)
    companyFilterName.value = route.query.companyName || ''
  }
  load()
})
</script>

<style scoped>
.cert-title { font-size: 13px; font-weight: 600; color: #606266; margin-bottom: 8px; }
.cert-img   { width: 140px; height: 88px; border-radius: 6px; border: 1px solid #e4e7ed; }
</style>
