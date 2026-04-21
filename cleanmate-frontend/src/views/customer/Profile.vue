<template>
  <div>
    <h2 class="page-title">个人中心</h2>
    <!-- 个人信息 -->
    <el-card style="margin-bottom:20px;border-radius:12px" v-loading="infoLoading">
      <template #header><span style="font-weight:600">个人信息</span></template>
      <div class="user-info-row">
        <el-avatar :size="56" class="avatar">{{ userInfo.nickname?.charAt(0) }}</el-avatar>
        <div class="user-meta">
          <div class="user-name">{{ userInfo.nickname }}</div>
          <div class="user-phone">{{ userInfo.phone }}</div>
        </div>
      </div>
      <el-descriptions :column="2" style="margin-top:16px">
        <el-descriptions-item label="用户名">{{ userInfo.nickname }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ userInfo.phone }}</el-descriptions-item>
        <el-descriptions-item label="注册时间">{{ formatTime(userInfo.createdAt) }}</el-descriptions-item>
        <el-descriptions-item label="账号状态">
          <el-tag type="success" size="small">正常</el-tag>
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <!-- 地址管理 -->
    <el-card style="margin-bottom:20px;border-radius:12px">
      <template #header>
        <div style="display:flex;justify-content:space-between;align-items:center">
          <span style="font-weight:600">地址管理</span>
          <el-button type="primary" size="small" @click="showDialog = true">+ 添加地址</el-button>
        </div>
      </template>

      <el-empty v-if="addresses.length === 0" description="暂无地址，请添加" />
      <div v-else style="display:flex;flex-direction:column;gap:10px">
        <el-card
          v-for="a in addresses"
          :key="a.id"
          shadow="never"
          style="border:1px solid #e4e7ed"
        >
          <div style="display:flex;justify-content:space-between;align-items:flex-start">
            <div>
              <el-tag v-if="a.label" size="small" style="margin-right:6px">{{ a.label }}</el-tag>
              <el-tag v-if="a.isDefault" size="small" type="success">默认</el-tag>
              <span style="margin-left:8px;font-weight:500">{{ a.contactName }} {{ a.contactPhone }}</span>
              <div style="margin-top:4px;font-size:13px;color:#606266">
                {{ a.province }}{{ a.city }}{{ a.district }}{{ a.detail }}
              </div>
            </div>
            <div style="display:flex;gap:8px;flex-shrink:0">
              <el-button v-if="!a.isDefault" link type="primary" @click="setDefault(a.id)">设默认</el-button>
              <el-button link type="danger" @click="removeAddr(a.id)">删除</el-button>
            </div>
          </div>
        </el-card>
      </div>
    </el-card>

    <!-- 修改密码 -->
    <el-card style="border-radius:12px">
      <template #header><span style="font-weight:600">修改密码</span></template>
      <el-form :model="pwdForm" :rules="pwdRules" ref="pwdFormRef" label-width="100px" style="max-width:440px">
        <el-form-item label="当前密码" prop="oldPassword">
          <el-input v-model="pwdForm.oldPassword" type="password" show-password placeholder="请输入当前密码" />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="pwdForm.newPassword" type="password" show-password placeholder="请输入新密码（至少6位）" />
        </el-form-item>
        <el-form-item label="确认新密码" prop="confirmPassword">
          <el-input v-model="pwdForm.confirmPassword" type="password" show-password placeholder="再次输入新密码" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="pwdLoading" @click="submitPassword" style="width:200px">
            修改密码
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 新增地址弹窗 -->
    <el-dialog v-model="showDialog" title="新增地址" width="480px" @close="resetForm">
      <el-form :model="addrForm" :rules="addrRules" ref="addrFormRef" label-width="90px">
        <el-form-item label="标签">
          <el-input v-model="addrForm.label" placeholder="家/公司（选填）" />
        </el-form-item>
        <el-form-item label="联系人" prop="contactName">
          <el-input v-model="addrForm.contactName" />
        </el-form-item>
        <el-form-item label="手机号" prop="contactPhone">
          <el-input v-model="addrForm.contactPhone" />
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
        <el-button @click="showDialog = false">取消</el-button>
        <el-button type="primary" :loading="addrSaving" @click="saveAddr">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { regionData, codeToText } from 'element-china-area-data'
import { getUserInfo, changePassword } from '@/api/auth'
import { getAddresses, addAddress, deleteAddress, setDefaultAddress } from '@/api/address'
import { formatTime } from '@/utils/time'

// ---- 个人信息 ----
const infoLoading = ref(false)
const userInfo = ref({ nickname: '', phone: '', createdAt: '' })

async function loadUserInfo() {
  infoLoading.value = true
  try {
    userInfo.value = await getUserInfo()
  } catch {} finally {
    infoLoading.value = false
  }
}

// ---- 修改密码 ----
const pwdLoading = ref(false)
const pwdFormRef = ref(null)
const pwdForm = ref({ oldPassword: '', newPassword: '', confirmPassword: '' })
const pwdRules = {
  oldPassword:     [{ required: true, message: '请输入当前密码', trigger: 'blur' }],
  newPassword:     [{ required: true, min: 6, message: '新密码至少6位', trigger: 'blur' }],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    {
      validator: (rule, val, cb) =>
        val !== pwdForm.value.newPassword ? cb(new Error('两次密码不一致')) : cb(),
      trigger: 'blur',
    },
  ],
}

async function submitPassword() {
  const valid = await pwdFormRef.value.validate().catch(() => false)
  if (!valid) return
  pwdLoading.value = true
  try {
    await changePassword({ oldPassword: pwdForm.value.oldPassword, newPassword: pwdForm.value.newPassword })
    ElMessage.success('密码修改成功')
    pwdForm.value = { oldPassword: '', newPassword: '', confirmPassword: '' }
    pwdFormRef.value.resetFields()
  } catch (e) {
    ElMessage.error(e?.message || '修改失败，请检查当前密码是否正确')
  } finally {
    pwdLoading.value = false
  }
}

// ---- 地址管理 ----
const addresses = ref([])
const showDialog = ref(false)
const addrSaving = ref(false)
const addrFormRef = ref(null)
const areaCode = ref([])
const addrForm = ref({ label: '', contactName: '', contactPhone: '', province: '', city: '', district: '', detail: '', isDefault: 0 })
const addrRules = {
  contactName:  [{ required: true, message: '请输入联系人', trigger: 'blur' }],
  contactPhone: [{ required: true, message: '请输入手机号', trigger: 'blur' }],
  district:     [{ required: true, message: '请选择省市区', trigger: 'change' }],
  detail:       [{ required: true, message: '请输入详细地址', trigger: 'blur' }],
}

function handleAreaChange(val) {
  addrForm.value.province = codeToText[val[0]] || ''
  addrForm.value.city     = codeToText[val[1]] || ''
  addrForm.value.district = codeToText[val[2]] || ''
}

async function loadAddresses() {
  addresses.value = await getAddresses()
}

async function saveAddr() {
  const valid = await addrFormRef.value.validate().catch(() => false)
  if (!valid) return
  addrSaving.value = true
  try {
    await addAddress({ ...addrForm.value })
    ElMessage.success('添加成功')
    showDialog.value = false
    await loadAddresses()
  } catch {
    ElMessage.error('添加失败')
  } finally {
    addrSaving.value = false
  }
}

async function setDefault(id) {
  await setDefaultAddress(id)
  await loadAddresses()
}

async function removeAddr(id) {
  await ElMessageBox.confirm('确认删除该地址？', '提示', { type: 'warning' })
  await deleteAddress(id)
  await loadAddresses()
}

function resetForm() {
  addrForm.value = { label: '', contactName: '', contactPhone: '', province: '', city: '', district: '', detail: '', isDefault: 0 }
  areaCode.value = []
  addrFormRef.value?.resetFields()
}

onMounted(() => {
  loadUserInfo()
  loadAddresses()
})
</script>

<style scoped>
.page-title { font-size: 20px; font-weight: 700; color: #3A3734; margin: 0 0 20px; }
.user-info-row { display: flex; align-items: center; gap: 16px; }
.avatar { background: #A3BDA9 !important; color: #2D4A33 !important; font-size: 20px; font-weight: 700; flex-shrink: 0; }
.user-name { font-size: 18px; font-weight: 700; color: #3A3734; }
.user-phone { font-size: 14px; color: #8A857E; margin-top: 4px; }
</style>
