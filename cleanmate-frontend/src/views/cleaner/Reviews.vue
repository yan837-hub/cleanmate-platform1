<template>
  <div class="reviews-wrap">
    <!-- 顶部标题 -->
    <div class="page-header">
      <div>
        <h2 class="page-title">我的评价</h2>
        <p class="page-sub">来自顾客的真实服务反馈</p>
      </div>
    </div>

    <!-- 双栏布局：左=评分概览，右=评价列表 -->
    <div class="reviews-grid">

      <!-- 左侧：评分概览 -->
      <div class="panel score-panel">
        <div class="score-header">
          <div class="panel-dot panel-dot--green"></div>
          <span class="panel-title">评分概览</span>
        </div>

        <div class="overall-score-block">
          <div class="overall-number">{{ overallScore ?? '—' }}</div>
          <div class="overall-stars">
            <el-rate
              :model-value="overallScore ?? 0"
              disabled
              size="large"
              color="#F59E0B"
            />
          </div>
          <div class="overall-label">综合评分</div>
        </div>

        <div class="score-divider"></div>

        <div class="score-stats">
          <div class="score-stat-item">
            <span class="score-stat-icon">📋</span>
            <span class="score-stat-text">共 <b>{{ total }}</b> 条评价</span>
          </div>
          <div class="score-stat-item" v-if="excellentCount > 0">
            <span class="score-stat-icon">⭐</span>
            <span class="score-stat-text">好评率 <b class="good-rate">{{ goodRate }}%</b></span>
          </div>
        </div>

        <div class="score-divider"></div>

        <div class="score-tips">
          <div class="score-tip-title">提升评分建议</div>
          <div class="score-tip-item">
            <span class="tip-dot"></span>
            准时到达服务地点
          </div>
          <div class="score-tip-item">
            <span class="tip-dot"></span>
            保持良好服务态度
          </div>
          <div class="score-tip-item">
            <span class="tip-dot"></span>
            完成后主动检查效果
          </div>
          <div class="score-tip-item">
            <span class="tip-dot"></span>
            及时回复顾客评价
          </div>
        </div>
      </div>

      <!-- 右侧：评价列表 -->
      <div class="panel list-panel">
        <div class="list-panel-header">
          <div class="panel-dot panel-dot--orange"></div>
          <span class="panel-title">评价列表</span>
          <span class="total-badge" v-if="total > 0">{{ total }} 条</span>
        </div>

        <div v-loading="loading">
          <el-empty
            v-if="!loading && list.length === 0"
            description="暂无评价记录"
            :image-size="100"
            style="padding: 48px 0"
          />

          <div v-for="item in list" :key="item.id" class="review-item">
            <!-- 评价头部 -->
            <div class="review-header">
              <div class="review-meta">
                <span class="review-date">{{ fmt(item.createdAt) }}</span>
                <span class="avg-score-badge">综合 {{ item.avgScore }} 分</span>
              </div>
            </div>

            <!-- 评分详情 -->
            <div class="score-rows">
              <div class="score-row">
                <span class="score-row-label">服务态度</span>
                <el-rate :model-value="item.scoreAttitude" disabled size="small" />
                <span class="score-row-num">{{ item.scoreAttitude }}</span>
              </div>
              <div class="score-row">
                <span class="score-row-label">清洁效果</span>
                <el-rate :model-value="item.scoreQuality" disabled size="small" />
                <span class="score-row-num">{{ item.scoreQuality }}</span>
              </div>
              <div class="score-row">
                <span class="score-row-label">准时到达</span>
                <el-rate :model-value="item.scorePunctual" disabled size="small" />
                <span class="score-row-num">{{ item.scorePunctual }}</span>
              </div>
            </div>

            <!-- 评价内容 -->
            <div v-if="item.content" class="review-content">
              <el-icon size="13" color="#D97706"><ChatDotRound /></el-icon>
              {{ item.content }}
            </div>

            <!-- 评价图片 -->
            <div v-if="item.imgs" class="review-imgs">
              <el-image
                v-for="url in item.imgs.split(',')"
                :key="url"
                :src="url"
                style="width:72px;height:72px;border-radius:8px;object-fit:cover"
                :preview-src-list="item.imgs.split(',')"
                fit="cover"
              />
            </div>

            <!-- 我的回复 -->
            <div v-if="item.replyContent" class="reply-block">
              <div class="reply-meta">
                <el-icon size="11"><ChatLineRound /></el-icon>
                我的回复（{{ fmt(item.repliedAt) }}）
              </div>
              <div class="reply-text">{{ item.replyContent }}</div>
            </div>
            <div v-else class="reply-action">
              <button class="reply-btn" @click="openReply(item)">回复评价</button>
            </div>
          </div>
        </div>

        <div class="pagination-wrap" v-if="total > pageSize">
          <el-pagination
            background
            layout="prev, pager, next"
            :total="total"
            :page-size="pageSize"
            v-model:current-page="currentPage"
            @current-change="load"
          />
        </div>
      </div>
    </div>

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
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { ChatDotRound, ChatLineRound } from '@element-plus/icons-vue'
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

const excellentCount = computed(() => list.value.filter(r => r.avgScore >= 4).length)
const goodRate = computed(() => {
  if (total.value === 0) return 0
  return Math.round((list.value.filter(r => r.avgScore >= 4).length / total.value) * 100)
})

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
.reviews-wrap {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: calc(100vh - 60px - 68px);
}

/* ── 顶部 ── */
.page-header {
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 16px;
  padding: 18px 24px;
}
.page-title { font-size: 22px; font-weight: 800; color: #1C3D2A; margin: 0 0 4px; }
.page-sub { font-size: 13px; color: #6B7280; margin: 0; }

/* ── 双栏 ── */
.reviews-grid {
  display: grid;
  grid-template-columns: 260px 1fr;
  gap: 16px;
  flex: 1;
  align-items: start;
}

.panel {
  background: #fff;
  border: 1.5px solid #E0EBE0;
  border-radius: 16px;
  padding: 22px;
}

/* ── 左侧评分概览：不随右侧列表撑高 ── */
.score-panel {
  align-self: start;
  position: sticky;
  top: 16px;
}

.score-header {
  display: flex; align-items: center; gap: 8px;
  margin-bottom: 20px;
}
.panel-dot {
  width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0;
}
.panel-dot--green  { background: #2A6B47; box-shadow: 0 0 0 3px #DCFCE7; }
.panel-dot--orange { background: #D97706; box-shadow: 0 0 0 3px #FEF3C7; }
.panel-title { font-size: 16px; font-weight: 700; color: #1C3D2A; }

.overall-score-block {
  text-align: center;
  padding: 20px 0;
}
.overall-number {
  font-size: 60px; font-weight: 900;
  color: #F59E0B; line-height: 1;
  letter-spacing: -2px; margin-bottom: 10px;
}
.overall-stars { margin-bottom: 8px; }
.overall-label { font-size: 13px; color: #6B7280; }

.score-divider { height: 1px; background: #E5EDE5; margin: 16px 0; }

.score-stats { display: flex; flex-direction: column; gap: 10px; }
.score-stat-item {
  display: flex; align-items: center; gap: 8px;
  font-size: 13px; color: #374151;
}
.score-stat-icon { font-size: 16px; }
.good-rate { color: #2A6B47; font-size: 15px; }

.score-tips { display: flex; flex-direction: column; gap: 8px; }
.score-tip-title { font-size: 13px; font-weight: 700; color: #1C3D2A; margin-bottom: 6px; }
.score-tip-item {
  display: flex; align-items: center; gap: 8px;
  font-size: 12px; color: #6B7280;
}
.tip-dot { width: 5px; height: 5px; border-radius: 50%; background: #2A6B47; flex-shrink: 0; }

/* ── 右侧评价列表 ── */
.list-panel-header {
  display: flex; align-items: center; gap: 8px;
  margin-bottom: 18px;
}
.total-badge {
  font-size: 11px; color: #D97706;
  background: #FEF3C7; border-radius: 20px;
  padding: 2px 10px; font-weight: 700;
}

.review-item {
  padding: 18px 0;
  border-bottom: 1px solid #E5EDE5;
}
.review-item:last-child { border-bottom: none; }

.review-header { margin-bottom: 12px; }
.review-meta { display: flex; align-items: center; gap: 10px; }
.review-date { font-size: 12px; color: #9CA3AF; }
.avg-score-badge {
  font-size: 12px; font-weight: 700;
  color: #B45309; background: #FEF3C7;
  border-radius: 20px; padding: 2px 10px;
}

.score-rows { display: flex; flex-direction: column; gap: 6px; margin-bottom: 12px; }
.score-row {
  display: flex; align-items: center; gap: 8px;
}
.score-row-label {
  font-size: 12px; color: #6B7280;
  width: 52px; flex-shrink: 0;
}
.score-row-num {
  font-size: 12px; color: #374151; font-weight: 700;
  margin-left: 4px;
}

.review-content {
  display: flex; align-items: flex-start; gap: 7px;
  font-size: 14px; color: #374151;
  background: #FFFBEB;
  border: 1px solid #FDE68A;
  border-radius: 10px;
  padding: 11px 14px;
  margin-bottom: 10px;
  line-height: 1.6;
}

.review-imgs { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 10px; }

.reply-block {
  background: #E6F4EE;
  border: 1px solid #6EE7A0;
  border-left: 4px solid #2A6B47;
  border-radius: 10px;
  padding: 10px 14px;
  margin-top: 8px;
}
.reply-meta {
  display: flex; align-items: center; gap: 5px;
  font-size: 11px; color: #4A6B5A; margin-bottom: 6px;
}
.reply-text { font-size: 13px; color: #1C3D2A; line-height: 1.6; }

.reply-action { margin-top: 8px; }
.reply-btn {
  background: #E6F4EE; border: 1.5px solid #6EE7A0;
  color: #2A6B47; font-size: 13px; font-weight: 600;
  padding: 6px 16px; border-radius: 50px;
  cursor: pointer; transition: all .18s;
}
.reply-btn:hover { background: #2A6B47; color: #fff; border-color: #2A6B47; }

.pagination-wrap { display: flex; justify-content: center; padding-top: 18px; }
</style>
