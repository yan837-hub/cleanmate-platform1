import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus, { ElMessage } from 'element-plus'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import zhCn from 'element-plus/es/locale/lang/zh-cn'
import 'element-plus/dist/index.css'

import App from './App.vue'
import router from './router'

// 全局统一 ElMessage 默认配置：缩短显示时间、避免遮挡顶部导航栏
const MSG_DEFAULTS = { offset: 70 }
const DURATION = { success: 1500, info: 1500, warning: 2500, error: 2500 }
;['success', 'info', 'warning', 'error'].forEach(type => {
  const original = ElMessage[type]
  ElMessage[type] = (msgOrOpts, opts = {}) => {
    const base = { duration: DURATION[type], ...MSG_DEFAULTS }
    if (typeof msgOrOpts === 'string') {
      return original({ message: msgOrOpts, ...base, ...opts })
    }
    return original({ ...base, ...msgOrOpts })
  }
})

const app = createApp(App)

// 注册所有 Element Plus 图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

app.use(createPinia())
app.use(router)
app.use(ElementPlus, { locale: zhCn })

app.mount('#app')
