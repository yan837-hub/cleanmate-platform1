<template>
  <div>
    <!-- 筛选栏 -->
    <el-card style="margin-bottom:16px">
      <el-form inline>
        <el-form-item label="可见状态">
          <el-select v-model="params.isVisible" clearable placeholder="全部" style="width:120px" @change="load">
            <el-option label="可见" :value="1" />
            <el-option label="已屏蔽" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="params.keyword" placeholder="评价内容/订单号" clearable style="width:200px" @keyup.enter="load" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
          <el-button @click="reset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 列表 -->
    <el-card>
      <el-table :data="list" v-loading="loading" stripe>
        <el-table-column label="订单号" prop="orderNo" width="200" />
        <el-table-column label="顾客" prop="customerNickname" width="100" />
        <el-table-column label="保洁员" prop="cleanerNickname" width="100" />
        <el-table-column label="综合评分" width="100">
          <template #default="{ row }">
            <el-rate :model-value="Number(row.avgScore)" disabled show-score />
          </template>
        </el-table-column>
        <el-table-column label="评价内容" prop="content" min-width="160" show-overflow-tooltip />
        <el-table-column label="评价图片" width="160">
          <template #default="{ row }">
            <div v-if="row.imgs" style="display:flex;gap:4px;flex-wrap:wrap">
              <el-image
                v-for="url in row.imgs.split(',')"
                :key="url"
                :src="url"
                style="width:48px;height:48px;border-radius:4px;object-fit:cover"
                :preview-src-list="row.imgs.split(',')"
                fit="cover"
              />
            </div>
            <span v-else style="color:#c0c4cc;font-size:12px">无</span>
          </template>
        </el-table-column>
        <el-table-column label="保洁员回复" prop="replyContent" min-width="130" show-overflow-tooltip />
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.isVisible === 1 ? 'success' : 'danger'" size="small">
              {{ row.isVisible === 1 ? '可见' : '已屏蔽' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="评价时间" prop="createdAt" width="160" />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.isVisible === 1" type="danger" text size="small" @click="openHide(row)">屏蔽</el-button>
            <el-button v-else type="primary" text size="small" @click="doShow(row)">恢复显示</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        style="margin-top:16px;justify-content:flex-end;display:flex"
        background
        layout="total, prev, pager, next"
        :total="total"
        :page-size="params.size"
        :current-page="params.current"
        @current-change="p => { params.current = p; load() }"
      />
    </el-card>

    <!-- 屏蔽弹窗 -->
    <el-dialog v-model="hideDialog" title="屏蔽评价" width="400px">
      <el-form>
        <el-form-item label="屏蔽原因">
          <el-input v-model="hideReason" type="textarea" :rows="3" placeholder="请填写屏蔽原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="hideDialog = false">取消</el-button>
        <el-button type="danger" :loading="submitting" @click="doHide">确认屏蔽</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getAdminReviews, hideReview, showReview } from '@/api/admin'

const loading = ref(false)
const submitting = ref(false)
const list = ref([])
const total = ref(0)
const params = reactive({ current: 1, size: 10, isVisible: null, keyword: '' })

const hideDialog = ref(false)
const hideReason = ref('')
const currentRow = ref(null)

async function load() {
  loading.value = true
  try {
    const res = await getAdminReviews(params)
    list.value = res.records
    total.value = res.total
  } finally {
    loading.value = false
  }
}

function reset() {
  params.current = 1
  params.isVisible = null
  params.keyword = ''
  load()
}

function openHide(row) {
  currentRow.value = row
  hideReason.value = ''
  hideDialog.value = true
}

async function doHide() {
  submitting.value = true
  try {
    await hideReview(currentRow.value.id, hideReason.value)
    ElMessage.success('已屏蔽')
    hideDialog.value = false
    load()
  } finally {
    submitting.value = false
  }
}

async function doShow(row) {
  await showReview(row.id)
  ElMessage.success('已恢复显示')
  load()
}

onMounted(load)
</script>
