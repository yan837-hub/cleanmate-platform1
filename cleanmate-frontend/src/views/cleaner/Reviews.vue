<template>
  <div>
    <el-card>
      <template #header>
        <span style="font-size:15px;font-weight:600">我的评价</span>
        <span style="float:right;display:flex;align-items:center;gap:16px">
          <span v-if="overallScore != null" style="font-size:13px;color:#f59e0b;font-weight:600">
            综合评分：{{ overallScore }} 分
          </span>
          <span style="font-size:13px;color:#909399">共 {{ total }} 条</span>
        </span>
      </template>

      <el-empty v-if="!loading && list.length === 0" description="暂无评价记录" />

      <div v-for="item in list" :key="item.id" class="review-item">
        <div class="review-header">
          <span class="review-date">{{ fmt(item.createdAt) }}</span>
          <el-tag type="warning" size="small">综合 {{ item.avgScore }} 分</el-tag>
        </div>
        <div class="scores">
          <span class="score-item">
            服务态度
            <el-rate :model-value="item.scoreAttitude" disabled size="small" />
          </span>
          <span class="score-item">
            清洁效果
            <el-rate :model-value="item.scoreQuality" disabled size="small" />
          </span>
          <span class="score-item">
            准时到达
            <el-rate :model-value="item.scorePunctual" disabled size="small" />
          </span>
        </div>
        <div v-if="item.content" class="review-content">{{ item.content }}</div>
        <div v-if="item.imgs" style="display:flex;gap:6px;flex-wrap:wrap;margin:8px 0">
          <el-image
            v-for="url in item.imgs.split(',')"
            :key="url"
            :src="url"
            style="width:72px;height:72px;border-radius:4px;object-fit:cover"
            :preview-src-list="item.imgs.split(',')"
            fit="cover"
          />
        </div>
        <!-- 已有回复 -->
        <div v-if="item.replyContent" class="reply-content">
          <span style="color:#909399;font-size:12px">我的回复（{{ fmt(item.repliedAt) }}）：</span>
          {{ item.replyContent }}
        </div>
        <!-- 回复按钮 -->
        <div v-else style="margin-top:6px">
          <el-button size="small" link type="primary" @click="openReply(item)">回复评价</el-button>
        </div>
        <el-divider style="margin:12px 0" />
      </div>

      <el-pagination
        v-if="total > pageSize"
        style="margin-top:8px;text-align:right"
        background layout="prev, pager, next"
        :total="total" :page-size="pageSize"
        v-model:current-page="currentPage"
        @current-change="load" />
    </el-card>

    <!-- 回复对话框 -->
    <el-dialog v-model="replyVisible" title="回复评价" width="480px">
      <el-input v-model="replyText" type="textarea" :rows="4" placeholder="输入回复内容..." maxlength="200" show-word-limit />
      <template #footer>
        <el-button @click="replyVisible = false">取消</el-button>
        <el-button type="primary" :loading="replying" @click="submitReply">提交回复</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getMyReviews, getMyCleanerProfile, replyReview } from '@/api/order'

const list = ref([])
const total = ref(0)
const loading = ref(false)
const currentPage = ref(1)
const pageSize = 10
const overallScore = ref(null)

const replyVisible = ref(false)
const replyText = ref('')
const replyTarget = ref(null)
const replying = ref(false)

function fmt(t) { return t ? t.replace('T', ' ').slice(0, 16) : '-' }

async function load() {
  loading.value = true
  try {
    const [res, profile] = await Promise.all([
      getMyReviews({ current: currentPage.value, size: pageSize }),
      getMyCleanerProfile()
    ])
    list.value = res?.records ?? []
    total.value = res?.total ?? 0
    overallScore.value = profile?.avgScore ?? null
  } catch {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

function openReply(item) {
  replyTarget.value = item
  replyText.value = ''
  replyVisible.value = true
}

async function submitReply() {
  if (!replyText.value.trim()) { ElMessage.warning('请输入回复内容'); return }
  replying.value = true
  try {
    await replyReview(replyTarget.value.id, replyText.value.trim())
    ElMessage.success('回复成功')
    replyTarget.value.replyContent = replyText.value.trim()
    replyTarget.value.repliedAt = new Date().toISOString()
    replyVisible.value = false
  } catch {
    ElMessage.error('回复失败')
  } finally {
    replying.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.review-item { padding: 4px 0; }
.review-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.review-date { font-size: 13px; color: #B8B0A8; }
.scores { display: flex; gap: 24px; flex-wrap: wrap; margin-bottom: 8px; }
.score-item { display: flex; align-items: center; gap: 4px; font-size: 13px; color: #5A5450; }
.review-content { font-size: 14px; color: #3A3734; background: #F5F2EE; border-radius: 8px; padding: 10px 14px; }
.reply-content { font-size: 13px; color: #5A5450; background: #EDF4ED; border-radius: 8px; padding: 10px 14px; margin-top: 6px; border-left: 3px solid #8FA888; }
</style>