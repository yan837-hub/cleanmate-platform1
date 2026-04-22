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
        <div
          v-for="tab in roleTabs"
          :key="tab.role"
          class="role-tab"
          :class="{ active: activeRole === tab.role }"
          @click="activeRole = tab.role"
        >
          {{ tab.label }}
        </div>
      </div>

      <!-- 登录表单 -->
      <el-form ref="formRef" :model="form" :rules="rules" @keyup.enter="handleLogin">
        <el-form-item prop="phone">
          <el-input v-model="form.phone" placeholder="请输入手机号" size="large">
            <template #prefix>
              <span class="phone-prefix">+86</span>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item prop="password">
          <el-input
            v-model="form.password"
            type="password"
            placeholder="请输入密码"
            size="large"
            show-password
          />
        </el-form-item>

        <div class="forgot-row">
          <span class="forgot-link">忘记密码？</span>
        </div>

        <el-button size="large" :loading="loading" @click="handleLogin" class="login-btn">
          登录
        </el-button>
      </el-form>

      <div class="footer-links">
        <span>还没有账号？</span>
        <span class="link" @click="$router.push('/register')">立即注册</span>
      </div>

      <!-- 演示账号区 -->
      <div class="demo-section">
        <div class="demo-title">演示账号（点击快速填入，密码均为 123456）：</div>
        <div class="demo-list">
          <div
            v-for="demo in demoAccounts"
            :key="demo.phone"
            class="demo-item"
            @click="fillDemo(demo)"
          >
            <el-icon><component :is="demo.icon" /></el-icon>
            <span class="demo-role">{{ demo.label }}：</span>
            <span class="demo-phone">{{ demo.phone }}</span>
          </div>
        </div>
      </div>

      <div class="page-footer">CleanMate © 2024 高效保洁 治愈生活</div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, SetUp, Avatar } from '@element-plus/icons-vue'
import { login } from '@/api/auth'
import { useUserStore } from '@/store/user'
import { getHomeRoute } from '@/utils/auth'

const router = useRouter()
const userStore = useUserStore()
const formRef = ref()
const loading = ref(false)
const activeRole = ref(1)

const roleTabs = [
  { role: 1, label: '顾客' },
  { role: 2, label: '保洁员' },
  { role: 3, label: '管理员' },
]

const demoAccounts = [
  { label: '顾客',    phone: '13800000001', password: '123456', role: 1, icon: 'User' },
  { label: '保洁员1', phone: '13800000002', password: '123456', role: 2, icon: 'SetUp' },
  { label: '保洁员2', phone: '13800000004', password: '123456', role: 2, icon: 'SetUp' },
  { label: '管理员',  phone: '13800000003', password: '123456', role: 3, icon: 'Avatar' },
]

const form = reactive({ phone: '', password: '' })

const rules = {
  phone: [
    { required: true, message: '请输入手机号' },
    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确' },
  ],
  password: [{ required: true, message: '请输入密码' }],
}

function fillDemo(demo) {
  form.phone = demo.phone
  form.password = demo.password
  activeRole.value = demo.role
  handleLogin()
}

async function handleLogin() {
  await formRef.value.validate()
  loading.value = true
  try {
    const data = await login({ ...form, role: activeRole.value })
    userStore.login(data)
    ElMessage.success('登录成功')
    router.push(getHomeRoute(data.role))
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

/* +86 前缀 */
.phone-prefix {
  color: #8A8A8A; font-size: 13px;
  padding-right: 8px;
  border-right: 1px solid #E0E8E4;
  margin-right: 4px;
}

/* 忘记密码行 */
.forgot-row {
  text-align: right;
  margin: -8px 0 12px;
}

.forgot-link {
  font-size: 12px; color: #B8B8B8;
  cursor: pointer; transition: color .15s;
}

.forgot-link:hover { color: #8A8A8A; }

/* 登录按钮 */
.login-btn {
  width: 100%;
  background: #4A4A4A; border: none;
  border-radius: 10px; height: 46px;
  font-size: 15px; font-weight: 600;
  color: #FFFFFF; letter-spacing: 2px;
  transition: all .2s;
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

/* 演示账号区 */
.demo-section {
  margin-top: 20px;
  padding: 14px 16px;
  background: #F5F8F6;
  border: 1px solid #E0EAE4;
  border-radius: 12px;
}

.demo-title {
  font-size: 12px; color: #B8B8B8;
  margin-bottom: 10px;
}

.demo-list { display: flex; flex-direction: column; gap: 6px; }

.demo-item {
  display: flex; align-items: center; gap: 6px;
  font-size: 13px; color: #8A8A8A;
  cursor: pointer; padding: 5px 8px;
  border-radius: 8px; transition: background .15s;
}

.demo-item:hover { background: #EAF0EC; color: #4A4A4A; }

.demo-role { color: #B8B8B8; }

.demo-phone { color: #C8D4C4; font-weight: 500; }

/* 版权行 */
.page-footer {
  text-align: center; margin-top: 20px;
  font-size: 11px; color: #B8B8B8;
}
</style>
