export const trustIndicators = [
  { num: '10,000', sup: '+', label: '累计服务次数' },
  { num: '98%',    sup: null, label: '客户满意度' },
  { num: '200',    sup: '+', label: '专业保洁员' }
]

// 服务卡片UI配置（按顺序对应后端返回的服务类型）
export const services = [
  {
    desc: '日常家庭清洁，让家焕然一新',
    tags: ['全面除尘', '地面清洁', '厨卫消杀'],
    rating: 4.9,
    icon: '🏠',
    bg: 'linear-gradient(135deg, #E8F0EA 0%, #D8E6DB 100%)',
    hot: true,
  },
  {
    desc: '全屋深度清洁，不留死角',
    tags: ['绒面污渍', '蒸汽消毒', '全屋精保'],
    rating: 5.0,
    icon: '✨',
    bg: 'linear-gradient(135deg, #F5F3F0 0%, #EBE8E3 100%)',
    hot: false,
  },
  {
    desc: '新房装修后的首次清洁',
    tags: ['新房入住', '装修除尘', '细缝精理'],
    rating: 4.8,
    icon: '🏗️',
    bg: 'linear-gradient(135deg, #F0EEF5 0%, #E6E3EB 100%)',
    hot: false,
  },
  {
    desc: '空调、油烟机等家电专业清洗',
    tags: ['空调拆洗', '油烟机洗', '洗衣机'],
    rating: 4.9,
    icon: '🔌',
    bg: 'linear-gradient(135deg, #F5F2ED 0%, #EBE7E0 100%)',
    hot: false,
  },
  {
    desc: '门窗玻璃专业清洁',
    tags: ['门窗玻璃', '纱窗清洁', '顽固污渍'],
    rating: 4.7,
    icon: '🪟',
    bg: 'linear-gradient(135deg, #EDF5F5 0%, #E0EBEB 100%)',
    hot: false,
  },
  {
    desc: '木地板养护打蜡服务',
    tags: ['木地板', '养护打蜡', '光泽还原'],
    rating: 4.8,
    icon: '🌿',
    bg: 'linear-gradient(135deg, #F0F5ED 0%, #E3EBE0 100%)',
    hot: false,
  },
]
