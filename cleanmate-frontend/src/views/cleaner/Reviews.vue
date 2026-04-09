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
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getMyReviews, getMyCleanerProfile } from '@/api/order'

const list = ref([])
const total = ref(0)
const loading = ref(false)
const currentPage = ref(1)
const pageSize = 10
const overallScore = ref(null)

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

onMounted(load)
</script>

<style scoped>
.review-item { padding: 4px 0; }
.review-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.review-date { font-size: 13px; color: #909399; }
.scores { display: flex; gap: 24px; flex-wrap: wrap; margin-bottom: 8px; }
.score-item { display: flex; align-items: center; gap: 4px; font-size: 13px; color: #606266; }
.review-content { font-size: 14px; color: #303133; background: #f5f7fa; border-radius: 6px; padding: 8px 12px; }
</style>