<template>
  <div class="login-page">
    <div class="login-card">
      <!-- Logo -->
      <div class="logo">
        <div class="logo-icon">
          <span class="logo-letter">C</span>
        </div>
        <h1 class="brand-name">CleanMate</h1>
        <p class="brand-sub">居家上门保洁服务平台</p>
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
          <el-input v-model="form.phone" placeholder="请输入手机号" size="large" />
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
        <el-button
          size="large"
          :loading="loading"
          @click="handleLogin"
          class="login-btn"
        >
          登录
        </el-button>
      </el-form>

      <div class="footer-links">
        <span>还没有账号？</span>
        <el-link type="primary" @click="$router.push('/register')">立即注册</el-link>
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

/* Logo */
.logo {
  text-align: center;
  margin-bottom: 32px;
}

.logo-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #0ea5e9 0%, #10b981 100%);
  border-radius: 18px;
  margin-bottom: 14px;
  box-shadow: 0 4px 16px rgba(14,165,233,.28);
}

.logo-letter {
  font-size: 32px;
  font-weight: 800;
  color: #fff;
  line-height: 1;
  font-family: Georgia, serif;
}

.brand-name {
  font-size: 26px;
  font-weight: 800;
  margin: 0 0 4px;
  color: #18181b;
  letter-spacing: -0.5px;
}

.brand-sub {
  color: #a1a1aa;
  font-size: 13px;
  margin: 0;
}

/* 角色 Tab */
.role-tabs {
  display: flex;
  background: #f4f4f5;
  border-radius: 10px;
  padding: 4px;
  margin-bottom: 24px;
  gap: 2px;
}

.role-tab {
  flex: 1;
  text-align: center;
  padding: 9px 0;
  border-radius: 8px;
  font-size: 14px;
  color: #71717a;
  cursor: pointer;
  transition: all .2s;
}

.role-tab.active {
  background: #fff;
  color: #18181b;
  font-weight: 600;
  box-shadow: 0 1px 3px rgba(0,0,0,.1), 0 1px 2px rgba(0,0,0,.06);
}

/* 登录按钮 */
.login-btn {
  width: 100%;
  background: #18181b;
  border: none;
  border-radius: 10px;
  height: 46px;
  font-size: 15px;
  font-weight: 600;
  color: #fff;
  letter-spacing: 2px;
  transition: all .2s;
}

.login-btn:hover {
  background: #27272a;
  transform: translateY(-1px);
  box-shadow: 0 8px 20px rgba(0,0,0,.18);
}

/* 注册链接 */
.footer-links {
  text-align: center;
  margin-top: 18px;
  color: #a1a1aa;
  font-size: 13px;
}

/* 演示账号 */
.demo-section {
  margin-top: 20px;
  padding: 14px 16px;
  background: #fafafa;
  border: 1px solid #e4e4e7;
  border-radius: 12px;
}

.demo-title {
  font-size: 12px;
  color: #a1a1aa;
  margin-bottom: 10px;
}

.demo-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.demo-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #71717a;
  cursor: pointer;
  padding: 5px 8px;
  border-radius: 8px;
  transition: background .15s;
}

.demo-item:hover {
  background: #f4f4f5;
  color: #18181b;
}

.demo-role { color: #a1a1aa; }

.demo-phone {
  color: #3f3f46;
  font-weight: 500;
}
</style>
