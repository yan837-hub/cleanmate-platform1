<template>
  <div class="login-page">
    <div class="login-card">
      <!-- Logo -->
      <div class="logo">
        <div class="logo-icon">
          <span class="logo-letter">C</span>
        </div>
        <h1 class="brand-name">CleanMate</h1>
        <p class="brand-sub">注册新账号</p>
      </div>

      <!-- 角色 Tab -->
      <div class="role-tabs">
        <div class="role-tab" :class="{ active: form.role === 1 }" @click="switchRole(1)">顾客</div>
        <div class="role-tab" :class="{ active: form.role === 2 }" @click="switchRole(2)">保洁员</div>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules">
        <el-form-item prop="phone">
          <el-input v-model="form.phone" placeholder="请输入手机号" size="large" />
        </el-form-item>
        <!-- 顾客显示昵称，保洁员显示真实姓名 -->
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
          <el-form-item label="保洁员类型" prop="cleanerType">
            <el-radio-group v-model="form.cleanerType" @change="onCleanerTypeChange">
              <el-radio :value="1">个人保洁员</el-radio>
              <el-radio :value="2">公司保洁员</el-radio>
            </el-radio-group>
          </el-form-item>

          <el-form-item v-if="form.cleanerType === 2" label="所属公司" prop="companyId">
            <el-select
              v-model="form.companyId"
              placeholder="请选择所属公司"
              filterable
              size="large"
              style="width:100%"
              :loading="companyLoading"
            >
              <el-option
                v-for="c in companyList"
                :key="c.id"
                :label="c.name"
                :value="c.id"
              />
            </el-select>
          </el-form-item>

          <el-alert type="warning" :closable="false" show-icon style="margin-bottom:16px;border-radius:8px">
            保洁员注册后需等待管理员审核资质，审核通过后方可接单。
          </el-alert>
        </template>

        <el-button :loading="loading" @click="handleRegister" class="login-btn">注册</el-button>
      </el-form>

      <div class="footer-links">
        <span>已有账号？</span>
        <el-link type="primary" @click="$router.push('/login')">立即登录</el-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
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
  realName: '',     // 保洁员真实姓名
  password: '',
  confirmPassword: '',
  cleanerType: 1,   // 1=个人 2=公司
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
  if (val === 2 && companyList.value.length === 0) {
    loadCompanies()
  }
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
  if (form.role === 2 && form.cleanerType === 2 && !value) {
    callback(new Error('请选择所属公司'))
  } else {
    callback()
  }
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
    const payload = {
      phone: form.phone,
      password: form.password,
      role: form.role,
    }
    if (form.role === 1) {
      payload.nickname = form.nickname || form.phone
    } else {
      payload.realName = form.realName
      if (form.cleanerType === 2 && form.companyId) {
        payload.companyId = form.companyId
      }
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
  } catch {
    // 错误已由请求拦截器统一弹出
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background:
    radial-gradient(ellipse 65% 55% at 20% 65%, rgba(14,165,233,.09) 0%, transparent 100%),
    radial-gradient(ellipse 65% 55% at 80% 35%, rgba(16,185,129,.09) 0%, transparent 100%),
    #f9fafb;
}

.login-card {
  width: 420px;
  background: #fff;
  border-radius: 20px;
  padding: 44px 40px 36px;
  box-shadow: 0 0 0 1px rgba(0,0,0,.04), 0 4px 6px -1px rgba(0,0,0,.06), 0 16px 48px -8px rgba(0,0,0,.12);
}

.logo { text-align: center; margin-bottom: 32px; }
.logo-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 64px; height: 64px;
  background: linear-gradient(135deg, #0ea5e9 0%, #10b981 100%);
  border-radius: 18px;
  margin-bottom: 14px;
  box-shadow: 0 4px 16px rgba(14,165,233,.28);
}
.logo-letter { font-size: 32px; font-weight: 800; color: #fff; line-height: 1; font-family: Georgia, serif; }
.brand-name { font-size: 26px; font-weight: 800; margin: 0 0 4px; color: #18181b; letter-spacing: -0.5px; }
.brand-sub { color: #a1a1aa; font-size: 13px; margin: 0; }

.role-tabs {
  display: flex;
  background: #f4f4f5;
  border-radius: 10px;
  padding: 4px;
  margin-bottom: 24px;
  gap: 2px;
}
.role-tab {
  flex: 1; text-align: center; padding: 9px 0;
  border-radius: 8px; font-size: 14px; color: #71717a;
  cursor: pointer; transition: all .2s;
}
.role-tab.active {
  background: #fff; color: #18181b; font-weight: 600;
  box-shadow: 0 1px 3px rgba(0,0,0,.1), 0 1px 2px rgba(0,0,0,.06);
}

.login-btn {
  width: 100%;
  background: #18181b; border: none; border-radius: 10px;
  height: 46px; font-size: 15px; font-weight: 600;
  color: #fff; letter-spacing: 2px; transition: all .2s;
}
.login-btn:hover {
  background: #27272a;
  transform: translateY(-1px);
  box-shadow: 0 8px 20px rgba(0,0,0,.18);
}

.footer-links {
  text-align: center; margin-top: 18px;
  color: #a1a1aa; font-size: 13px;
}
</style>
