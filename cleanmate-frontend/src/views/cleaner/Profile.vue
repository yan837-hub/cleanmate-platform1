<template>
  <div>
    <!-- 账号信息 -->
    <el-card style="margin-bottom:16px" v-loading="infoLoading">
      <template #header>
        <div style="display:flex;justify-content:space-between;align-items:center">
          <span>账号信息</span>
          <el-tag :type="auditTagType" size="small">{{ auditTagText }}</el-tag>
        </div>
      </template>
      <div class="user-info-row">
        <el-avatar :size="56" style="background:#059669;font-size:22px;flex-shrink:0">
          {{ userInfo.nickname?.charAt(0) }}
        </el-avatar>
        <div class="user-meta">
          <div class="user-name">{{ userInfo.nickname }}</div>
          <div class="user-phone">{{ userInfo.phone }}</div>
          <div class="user-time">注册于 {{ formatTime(userInfo.createdAt) }}</div>
        </div>
      </div>
    </el-card>

    <!-- 资质审核资料 -->
    <el-card style="margin-bottom:16px" v-loading="profileLoading">
      <template #header><span>资质审核资料</span></template>

      <el-alert v-if="profile.auditStatus === 3" type="error"
        :description="'审核未通过' + (profile.auditRemark ? '：' + profile.auditRemark : '') + '，请修改后重新提交'"
        show-icon :closable="false" style="margin-bottom:20px" />
      <el-alert v-else-if="profile.auditStatus === 2" type="warning"
        description="资料已提交，请等待平台审核，审核通过后可开始接单"
        show-icon :closable="false" style="margin-bottom:20px" />
      <el-alert v-else-if="profile.auditStatus === 1" type="success"
        description="审核已通过，您可以正常接单。如需修改常驻位置或简介，保存后不影响审核状态。"
        show-icon :closable="false" style="margin-bottom:20px" />

      <el-form :model="profileForm" :rules="profileRules" ref="profileFormRef"
               label-width="110px" label-position="left">

        <!-- ① 实名信息 -->
        <div class="form-section-title">实名信息</div>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="真实姓名" prop="realName">
              <el-input v-model="profileForm.realName" placeholder="与身份证一致" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="身份证号" prop="idCard">
              <el-input v-model="profileForm.idCard" placeholder="18位身份证号码" maxlength="18" />
            </el-form-item>
          </el-col>
        </el-row>

        <!-- ② 证件照片 -->
        <div class="form-section-title">证件照片</div>
        <el-row :gutter="24">
          <el-col :span="12">
            <el-form-item label="身份证正面">
              <el-upload
                class="img-uploader"
                action="#"
                :show-file-list="false"
                :before-upload="(f) => beforeUpload(f)"
                :http-request="(opt) => doUpload(opt, 'idCardFront')"
                accept="image/jpeg,image/png,image/webp"
              >
                <div v-if="profileForm.idCardFront" class="img-preview-wrap">
                  <img :src="profileForm.idCardFront" class="img-preview" />
                  <div class="img-overlay">点击重新上传</div>
                </div>
                <div v-else class="img-placeholder">
                  <el-icon :size="28" color="#c0c4cc"><Plus /></el-icon>
                  <div class="img-hint">身份证人像面</div>
                </div>
              </el-upload>
              <div v-if="uploadingField === 'idCardFront'" class="uploading-tip">上传中...</div>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="身份证背面">
              <el-upload
                class="img-uploader"
                action="#"
                :show-file-list="false"
                :before-upload="(f) => beforeUpload(f)"
                :http-request="(opt) => doUpload(opt, 'idCardBack')"
                accept="image/jpeg,image/png,image/webp"
              >
                <div v-if="profileForm.idCardBack" class="img-preview-wrap">
                  <img :src="profileForm.idCardBack" class="img-preview" />
                  <div class="img-overlay">点击重新上传</div>
                </div>
                <div v-else class="img-placeholder">
                  <el-icon :size="28" color="#c0c4cc"><Plus /></el-icon>
                  <div class="img-hint">身份证国徽面</div>
                </div>
              </el-upload>
              <div v-if="uploadingField === 'idCardBack'" class="uploading-tip">上传中...</div>
            </el-form-item>
          </el-col>
        </el-row>

        <!-- ③ 服务资质证明 -->
        <div class="form-section-title">服务资质证明 <span class="tip">（选填，提高竞争力）</span></div>
        <el-row :gutter="24">
          <el-col :span="12">
            <el-form-item label="保洁资格证">
              <el-upload
                class="img-uploader"
                action="#"
                :show-file-list="false"
                :before-upload="(f) => beforeUpload(f)"
                :http-request="(opt) => doUpload(opt, 'certImg')"
                accept="image/jpeg,image/png,image/webp"
              >
                <div v-if="profileForm.certImg" class="img-preview-wrap">
                  <img :src="profileForm.certImg" class="img-preview" />
                  <div class="img-overlay">点击重新上传</div>
                </div>
                <div v-else class="img-placeholder">
                  <el-icon :size="28" color="#c0c4cc"><Plus /></el-icon>
                  <div class="img-hint">保洁资格证书</div>
                </div>
              </el-upload>
              <div v-if="uploadingField === 'certImg'" class="uploading-tip">上传中...</div>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="健康证">
              <el-upload
                class="img-uploader"
                action="#"
                :show-file-list="false"
                :before-upload="(f) => beforeUpload(f)"
                :http-request="(opt) => doUpload(opt, 'healthCertImg')"
                accept="image/jpeg,image/png,image/webp"
              >
                <div v-if="profileForm.healthCertImg" class="img-preview-wrap">
                  <img :src="profileForm.healthCertImg" class="img-preview" />
                  <div class="img-overlay">点击重新上传</div>
                </div>
                <div v-else class="img-placeholder">
                  <el-icon :size="28" color="#c0c4cc"><Plus /></el-icon>
                  <div class="img-hint">健康证</div>
                </div>
              </el-upload>
              <div v-if="uploadingField === 'healthCertImg'" class="uploading-tip">上传中...</div>
            </el-form-item>
          </el-col>
        </el-row>

        <!-- ④ 常驻位置 -->
        <div class="form-section-title">
          常驻位置
          <span class="tip">（用于系统计算距离，优先派单给距离近的保洁员）</span>
        </div>
        <el-form-item label="位置坐标">
          <div class="location-row">
            <el-input v-model.number="profileForm.longitude" placeholder="经度（如 116.4074）" style="width:180px" />
            <span style="margin:0 8px;color:#999">，</span>
            <el-input v-model.number="profileForm.latitude"  placeholder="纬度（如 39.9042）"  style="width:180px" />
            <el-button type="primary" plain size="small" :loading="locating"
              style="margin-left:12px" @click="getGeolocation">
              <el-icon style="margin-right:4px"><Location /></el-icon>定位当前位置
            </el-button>
            <el-button size="small" style="margin-left:8px" @click="showMap = !showMap">
              {{ showMap ? '收起地图' : '地图选点' }}
            </el-button>
          </div>
          <div v-if="profileForm.longitude && profileForm.latitude" class="location-desc">
            已设置：经度 {{ Number(profileForm.longitude).toFixed(6) }}，纬度 {{ Number(profileForm.latitude).toFixed(6) }}
          </div>
        </el-form-item>

        <!-- 高德地图 -->
        <el-form-item v-if="showMap" label=" ">
          <div class="map-wrap">
            <div id="cleaner-location-map" class="map-container"></div>
            <div class="map-tip">点击地图任意位置可设为常驻位置，蓝色标记为当前已选坐标</div>
          </div>
        </el-form-item>

        <!-- ⑤ 服务信息 -->
        <div class="form-section-title">服务信息</div>
        <el-form-item label="服务区域">
          <el-input v-model="profileForm.serviceArea" placeholder="如：朝阳区、海淀区、东城区" />
        </el-form-item>
        <el-form-item label="擅长服务">
          <el-checkbox-group v-model="selectedTags" class="tag-group">
            <el-checkbox
              v-for="st in serviceTypeOptions"
              :key="st.id"
              :value="st.name"
              :label="st.name"
              border
              size="small"
            />
          </el-checkbox-group>
          <div v-if="serviceTypeOptions.length === 0" style="font-size:12px;color:#bbb">
            暂无可选服务类型，请联系管理员添加
          </div>
        </el-form-item>

        <!-- ⑥ 个人简介 -->
        <div class="form-section-title">个人简介 <span class="tip">（选填）</span></div>
        <el-form-item label="简介">
          <el-input v-model="profileForm.bio" type="textarea" :rows="3"
            :maxlength="200" show-word-limit
            placeholder="介绍您的工作经验、服务特长、服务时间段等" />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" size="large" :loading="profileSaving"
            style="width:200px" @click="submitProfile">
            {{ profile.auditStatus === 3 ? '修改后重新提交审核' : '保存并提交' }}
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 修改密码 -->
    <el-card>
      <template #header><span>修改密码</span></template>
      <el-form :model="pwdForm" :rules="pwdRules" ref="pwdFormRef"
               label-width="110px" style="max-width:460px">
        <el-form-item label="当前密码" prop="oldPassword">
          <el-input v-model="pwdForm.oldPassword" type="password" show-password placeholder="请输入当前密码" />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="pwdForm.newPassword" type="password" show-password placeholder="至少6位" />
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
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus, Location } from '@element-plus/icons-vue'
import { getUserInfo, changePassword } from '@/api/auth'
import { getMyCleanerProfile, updateMyCleanerProfile } from '@/api/order'
import { getServiceTypes } from '@/api/service'
import request from '@/utils/request'

const serviceTypeOptions = ref([])

// ─── 账号信息 ────────────────────────────────────────────────
const infoLoading = ref(false)
const userInfo    = ref({ nickname: '', phone: '', createdAt: '' })

async function loadUserInfo() {
  infoLoading.value = true
  try { userInfo.value = await getUserInfo() }
  catch {} finally { infoLoading.value = false }
}

// ─── 资质档案 ────────────────────────────────────────────────
const profileLoading = ref(false)
const profileSaving  = ref(false)
const profileFormRef = ref(null)
const profile     = ref({ auditStatus: 2, auditRemark: null })
const profileForm = ref({
  realName: '', idCard: '',
  idCardFront: null, idCardBack: null,
  certImg: null, healthCertImg: null,
  serviceArea: '', bio: '',
  longitude: null, latitude: null,
})
const selectedTags = ref([])

const auditTagType = computed(() => ({ 1: 'success', 2: 'warning', 3: 'danger' }[profile.value.auditStatus] ?? 'info'))
const auditTagText = computed(() => ({ 1: '审核通过', 2: '待审核', 3: '审核未通过' }[profile.value.auditStatus] ?? '-'))

const profileRules = {
  realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }],
  idCard: [
    { required: true, message: '请输入身份证号', trigger: 'blur' },
    { pattern: /^\d{17}[\dXx]$/, message: '身份证号格式不正确', trigger: 'blur' },
  ],
}

async function loadProfile() {
  profileLoading.value = true
  try {
    const data = await getMyCleanerProfile()
    profile.value = data
    profileForm.value = {
      realName:      data.realName      || '',
      idCard:        data.idCard        || '',
      idCardFront:   data.idCardFront   || null,
      idCardBack:    data.idCardBack    || null,
      certImg:       data.certImg       || null,
      healthCertImg: data.healthCertImg || null,
      serviceArea:   data.serviceArea   || '',
      bio:           data.bio           || '',
      longitude:     data.longitude     ? Number(data.longitude) : null,
      latitude:      data.latitude      ? Number(data.latitude)  : null,
    }
    selectedTags.value = data.skillTags
      ? data.skillTags.split(',').map(t => t.trim()).filter(Boolean)
      : []
  } catch {} finally { profileLoading.value = false }
}

async function submitProfile() {
  const valid = await profileFormRef.value.validate().catch(() => false)
  if (!valid) return
  profileSaving.value = true
  try {
    await updateMyCleanerProfile({ ...profileForm.value, skillTags: selectedTags.value.join(',') })
    ElMessage.success(profile.value.auditStatus === 1 ? '资料已更新' : '资料已提交，请等待审核')
    await loadProfile()
  } catch (e) {
    ElMessage.error(e?.message || '提交失败')
  } finally { profileSaving.value = false }
}

// ─── 图片上传（统一处理所有字段） ────────────────────────────
const uploadingField = ref(null)

function beforeUpload(file) {
  const ok = /\.(jpg|jpeg|png|webp)$/i.test(file.name)
  if (!ok) { ElMessage.error('仅支持 JPG / PNG / WebP 格式'); return false }
  if (file.size > 5 * 1024 * 1024) { ElMessage.error('图片不能超过 5MB'); return false }
  return true
}

async function doUpload({ file }, field) {
  uploadingField.value = field
  try {
    const form = new FormData()
    form.append('file', file)
    const url = await request.post('/cleaner/profile/upload', form, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })
    profileForm.value[field] = url
    ElMessage.success('上传成功')
  } catch {
    ElMessage.error('上传失败，请重试')
  } finally {
    uploadingField.value = null
  }
}

// ─── 常驻位置 + 高德地图 ──────────────────────────────────────
const showMap  = ref(false)
const locating = ref(false)
let mapInstance = null
let mapMarker   = null

function getGeolocation() {
  if (!navigator.geolocation) { ElMessage.warning('浏览器不支持定位'); return }
  locating.value = true
  navigator.geolocation.getCurrentPosition(
    pos => {
      profileForm.value.longitude = parseFloat(pos.coords.longitude.toFixed(6))
      profileForm.value.latitude  = parseFloat(pos.coords.latitude.toFixed(6))
      locating.value = false
      ElMessage.success('定位成功')
      if (showMap.value && mapInstance) moveMarker(profileForm.value.longitude, profileForm.value.latitude)
    },
    () => { locating.value = false; ElMessage.error('定位失败，请手动输入或地图选点') },
    { timeout: 8000 }
  )
}

async function initMap() {
  await nextTick()
  const el = document.getElementById('cleaner-location-map')
  if (!el) return
  const key = import.meta.env.VITE_AMAP_KEY
  if (!key) { ElMessage.warning('未配置 VITE_AMAP_KEY，无法加载地图'); return }
  if (!window.AMap) {
    await new Promise((resolve, reject) => {
      const s = document.createElement('script')
      s.src = `https://webapi.amap.com/maps?v=2.0&key=${key}`
      s.onload = resolve
      s.onerror = () => reject(new Error('高德地图加载失败，请检查 Key'))
      document.head.appendChild(s)
    }).catch(e => { ElMessage.error(e.message); return })
  }
  if (!window.AMap) return
  const center = profileForm.value.longitude && profileForm.value.latitude
    ? [profileForm.value.longitude, profileForm.value.latitude]
    : [116.4074, 39.9042]
  mapInstance = new window.AMap.Map('cleaner-location-map', { zoom: 13, center, resizeEnable: true })
  if (profileForm.value.longitude && profileForm.value.latitude) {
    mapMarker = new window.AMap.Marker({ position: center, map: mapInstance })
  }
  mapInstance.on('click', e => {
    const lng = parseFloat(e.lnglat.getLng().toFixed(6))
    const lat = parseFloat(e.lnglat.getLat().toFixed(6))
    profileForm.value.longitude = lng
    profileForm.value.latitude  = lat
    moveMarker(lng, lat)
  })
}

function moveMarker(lng, lat) {
  if (!window.AMap || !mapInstance) return
  if (mapMarker) mapMarker.setPosition([lng, lat])
  else mapMarker = new window.AMap.Marker({ position: [lng, lat], map: mapInstance })
  mapInstance.setCenter([lng, lat])
}

watch(showMap, val => {
  if (val) initMap()
  else if (mapInstance) { mapInstance.destroy(); mapInstance = null; mapMarker = null }
})

// ─── 修改密码 ────────────────────────────────────────────────
const pwdLoading = ref(false)
const pwdFormRef = ref(null)
const pwdForm    = ref({ oldPassword: '', newPassword: '', confirmPassword: '' })
const pwdRules   = {
  oldPassword:     [{ required: true, message: '请输入当前密码', trigger: 'blur' }],
  newPassword:     [{ required: true, min: 6, message: '新密码至少6位', trigger: 'blur' }],
  confirmPassword: [{
    required: true,
    validator: (r, v, cb) => v !== pwdForm.value.newPassword ? cb(new Error('两次密码不一致')) : cb(),
    trigger: 'blur',
  }],
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
    ElMessage.error(e?.message || '修改失败，请检查当前密码')
  } finally { pwdLoading.value = false }
}

function formatTime(t) { return t ? String(t).replace('T', ' ').substring(0, 16) : '-' }

async function loadServiceTypes() {
  try {
    const data = await getServiceTypes()
    serviceTypeOptions.value = Array.isArray(data) ? data : []
  } catch {}
}

onMounted(() => { loadUserInfo(); loadProfile(); loadServiceTypes() })
onUnmounted(() => { if (mapInstance) { mapInstance.destroy(); mapInstance = null } })
</script>

<style scoped>
.user-info-row { display: flex; align-items: center; gap: 16px; }
.user-name  { font-size: 18px; font-weight: 700; color: #303133; }
.user-phone { font-size: 14px; color: #606266; margin-top: 4px; }
.user-time  { font-size: 12px; color: #909399; margin-top: 2px; }

.form-section-title {
  font-size: 14px; font-weight: 600; color: #374151;
  border-left: 3px solid #059669; padding-left: 10px;
  margin: 20px 0 14px;
}
.form-section-title:first-of-type { margin-top: 0; }
.tip { font-size: 12px; font-weight: 400; color: #9ca3af; }

.location-row { display: flex; align-items: center; flex-wrap: wrap; gap: 4px; }
.location-desc { font-size: 12px; color: #059669; margin-top: 6px; }

.map-wrap { width: 100%; }
.map-container { width: 100%; height: 320px; border-radius: 8px; border: 1px solid #e5e7eb; }
.map-tip { font-size: 12px; color: #9ca3af; margin-top: 6px; }

.tag-group { display: flex; flex-wrap: wrap; gap: 8px; }
.tag-group :deep(.el-checkbox.is-bordered) { margin: 0; border-radius: 6px; }

/* 图片上传框 */
:deep(.img-uploader .el-upload) {
  border: 1px dashed #d1d5db;
  border-radius: 8px;
  cursor: pointer;
  width: 200px;
  height: 130px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: border-color .2s;
  overflow: hidden;
}
:deep(.img-uploader .el-upload:hover) { border-color: #059669; }

.img-placeholder { display: flex; flex-direction: column; align-items: center; }
.img-hint { font-size: 12px; color: #9ca3af; margin-top: 6px; }

.img-preview-wrap {
  position: relative;
  width: 200px; height: 130px;
  border-radius: 8px; overflow: hidden;
}
.img-preview { width: 100%; height: 100%; object-fit: cover; display: block; }
.img-overlay {
  position: absolute; inset: 0;
  background: rgba(0,0,0,.4); color: #fff; font-size: 13px;
  display: flex; align-items: center; justify-content: center;
  opacity: 0; transition: opacity .2s;
}
.img-preview-wrap:hover .img-overlay { opacity: 1; }
.uploading-tip { font-size: 12px; color: #409eff; margin-top: 4px; }
</style>
