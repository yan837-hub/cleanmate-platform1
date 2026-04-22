<template>
  <div class="login-page">
    <div class="login-card">
      <!-- Logo -->
      <div class="logo">
        <div class="logo-icon">
          <span class="logo-letter">C</span>
        </div>
        <h1 class="brand-name">CleanMate</h1>
        <p class="brand-sub">您的居家保洁专家</p>
      </div>

      <!-- 角色 Tab -->
      <div class="role-tabs">
        <div class="role-tab" :class="{ active: form.role === 1 }" @click="switchRole(1)">顾客</div>
        <div class="role-tab" :class="{ active: form.role === 2 }" @click="switchRole(2)">保洁员</div>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules">
        <el-form-item prop="phone">
          <el-input v-model="form.phone" placeholder="请输入手机号" size="large">
            <template #prefix>
              <span class="phone-prefix">+86</span>
            </template>
          </el-input>
        </el-form-item>

        <el-form-item v-if="form.role === 1" prop="nickname">
          <el-input v-model="form.nickname" placeholder="请输入昵称（可选）" size="large" />
        </el-form-item>
        <el-form-item v-if="form.role === 2" prop="realName">
          <el-input v-model="form.realName" placeholder="请输入真实姓名（必填，用于实名审核）" size="large" />
        </el-form-item>

        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="密码（至少6位）" size="large" show-password />
        </el-form-item>
        <el-form-item prop="confirmPassword">
          <el-input v-model="form.confirmPassword" type="password" placeholder="确认密码" size="large" show-password />
        </el-form-item>

        <!-- 保洁员专属：个人/公司选择 -->
        <template v-if="form.role === 2">
          <el-form-item prop="cleanerType" class="cleaner-type-item">
            <el-radio-group v-model="form.cleanerType" @change="onCleanerTypeChange">
              <el-radio :value="1">个人保洁员</el-radio>
              <el-radio :value="2">公司保洁员</el-radio>
            </el-radio-group>
          </el-form-item>

          <el-form-item v-if="form.cleanerType === 2" prop="companyId">
            <el-select
              v-model="form.companyId"
              placeholder="请选择所属公司"
              filterable
              size="large"
              style="width:100%"
              :loading="companyLoading"
            >
              <el-option v-for="c in companyList" :key="c.id" :label="c.name" :value="c.id" />
            </el-select>
          </el-form-item>

          <div class="audit-notice">
            <i class="ri-information-line"></i>
            保洁员注册后需等待管理员审核资质，审核通过后方可接单。
          </div>
        </template>

        <el-button :loading="loading" @click="handleRegister" class="login-btn">注册</el-button>
      </el-form>

      <div class="footer-links">
        <span>已有账号？</span>
        <span class="link" @click="$router.push('/login')">立即登录</span>
      </div>

      <div class="page-footer">CleanMate © 2024 高效保洁 治愈生活</div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { register } from '@/api/auth'
import { getPublicCompanyList } from '@/api/public'

const router = useRouter()
const formRef = ref()
const loading = ref(false)
const companyLoading = ref(false)
const companyList = ref([])

const form = reactive({
  role: 1,
  phone: '',
  nickname: '',
  realName: '',
  password: '',
  confirmPassword: '',
  cleanerType: 1,
  companyId: null,
})

function switchRole(role) {
  form.role = role
  form.cleanerType = 1
  form.companyId = null
  form.realName = ''
  form.nickname = ''
}

function onCleanerTypeChange(val) {
  form.companyId = null
  if (val === 2 && companyList.value.length === 0) loadCompanies()
}

async function loadCompanies() {
  companyLoading.value = true
  try {
    const data = await getPublicCompanyList()
    companyList.value = data ?? []
  } catch {
    ElMessage.error('获取公司列表失败')
  } finally {
    companyLoading.value = false
  }
}

const validateConfirmPwd = (rule, value, callback) => {
  if (value !== form.password) callback(new Error('两次密码不一致'))
  else callback()
}

const validateCompanyId = (rule, value, callback) => {
  if (form.role === 2 && form.cleanerType === 2 && !value) callback(new Error('请选择所属公司'))
  else callback()
}

const rules = {
  phone: [
    { required: true, message: '请输入手机号' },
    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确' },
  ],
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' },
    { min: 2, max: 20, message: '姓名长度 2~20 个字符', trigger: 'blur' },
  ],
  password: [
    { required: true, message: '请输入密码' },
    { min: 6, message: '密码至少6位' },
  ],
  confirmPassword: [
    { required: true, message: '请确认密码' },
    { validator: validateConfirmPwd },
  ],
  companyId: [{ validator: validateCompanyId }],
}

async function handleRegister() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  loading.value = true
  try {
    const payload = { phone: form.phone, password: form.password, role: form.role }
    if (form.role === 1) {
      payload.nickname = form.nickname || form.phone
    } else {
      payload.realName = form.realName
      if (form.cleanerType === 2 && form.companyId) payload.companyId = form.companyId
    }
    await register(payload)
    if (form.role === 2) {
      await ElMessageBox.alert(
        '注册成功！请登录后前往"个人资料"页面填写真实姓名、身份证等信息并提交审核，审核通过后即可开始接单。',
        '注册成功 — 请完善资料',
        { confirmButtonText: '去登录', type: 'success' }
      ).catch(() => {})
    } else {
      ElMessage.success('注册成功，请登录')
    }
    router.push('/login')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* 页面背景 — 奶油薄荷渐变 */
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(145deg, #F0F5F3 0%, #E8F0EC 100%);
  font-family: 'Inter', 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

/* 卡片 */
.login-card {
  width: 420px;
  background: #FFFFFF;
  border-radius: 20px;
  padding: 44px 40px 32px;
  box-shadow: 0 2px 8px rgba(0,0,0,.06), 0 16px 48px rgba(0,0,0,.08);
}

/* Logo */
.logo { text-align: center; margin-bottom: 28px; }

.logo-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 64px; height: 64px;
  background: #C8D4C4;
  border-radius: 18px;
  margin-bottom: 14px;
}

.logo-letter {
  font-size: 32px; font-weight: 800;
  color: #FFFFFF; line-height: 1;
  font-family: Georgia, serif;
}

.brand-name {
  font-size: 24px; font-weight: 700;
  margin: 0 0 4px; color: #4A4A4A;
  letter-spacing: 0.5px;
}

.brand-sub { color: #8A8A8A; font-size: 13px; margin: 0; }

/* 角色 Tab — 下划线风格 */
.role-tabs {
  display: flex;
  justify-content: center;
  gap: 32px;
  margin-bottom: 24px;
  border-bottom: 1px solid #E8EEEB;
  padding-bottom: 0;
}

.role-tab {
  padding: 8px 4px 10px;
  font-size: 14px; color: #8A8A8A;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  margin-bottom: -1px;
  transition: all .2s;
}

.role-tab.active {
  color: #4A4A4A; font-weight: 600;
  border-bottom-color: #B8C5D0;
}

/* 输入框覆盖 */
:deep(.el-input__wrapper) {
  background: #FAFAF8;
  border-radius: 10px;
  box-shadow: 0 0 0 1px #E8EEEB inset;
}

:deep(.el-input__wrapper:hover) {
  box-shadow: 0 0 0 1px #C8D4C4 inset;
}

:deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 0 0 1.5px #C8D4C4 inset !important;
}

:deep(.el-input__inner::placeholder) {
  color: #B8B8B8;
}

:deep(.el-select .el-input__wrapper) {
  background: #FAFAF8;
}

/* +86 前缀 */
.phone-prefix {
  color: #8A8A8A; font-size: 13px;
  padding-right: 8px;
  border-right: 1px solid #E0E8E4;
  margin-right: 4px;
}

/* 保洁员类型选择 */
.cleaner-type-item :deep(.el-form-item__content) {
  padding: 4px 0;
}

:deep(.el-radio__input.is-checked .el-radio__inner) {
  background: #C8D4C4;
  border-color: #C8D4C4;
}

:deep(.el-radio__input.is-checked + .el-radio__label) {
  color: #4A4A4A;
}

/* 审核提示 */
.audit-notice {
  display: flex;
  align-items: flex-start;
  gap: 6px;
  background: #F5F8F6;
  border: 1px solid #E0EAE4;
  border-radius: 10px;
  padding: 10px 14px;
  font-size: 12px; color: #8A8A8A;
  margin-bottom: 16px;
  line-height: 1.6;
}

.audit-notice i { color: #B8C5D0; font-size: 14px; flex-shrink: 0; margin-top: 1px; }

/* 注册按钮 */
.login-btn {
  width: 100%;
  background: #4A4A4A; border: none;
  border-radius: 10px; height: 46px;
  font-size: 15px; font-weight: 600;
  color: #FFFFFF; letter-spacing: 2px;
  transition: all .2s; margin-top: 4px;
}

.login-btn:hover {
  background: #3A3A3A;
  transform: translateY(-1px);
  box-shadow: 0 6px 18px rgba(74,74,74,.2);
}

/* 底部链接 */
.footer-links {
  text-align: center; margin-top: 18px;
  font-size: 13px; color: #8A8A8A;
}

.link {
  color: #C8D4C4; cursor: pointer;
  font-weight: 500; margin-left: 4px;
  transition: color .15s;
}

.link:hover { color: #A8B8A4; }

/* 版权行 */
.page-footer {
  text-align: center; margin-top: 24px;
  font-size: 11px; color: #B8B8B8;
}
</style>
