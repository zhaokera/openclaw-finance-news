# OpenClaw 财经新闻技能

## 功能特性

- 实时获取最新财经新闻、市场动态、公司公告、行业资讯等
- **投资价值分析**：基于邱国鹭《投资中最简单的事》和李杰《股市进阶之道》的投资理念
  - ✅ 政策影响分析（A股政策导向）- 邱国鹭强调的政策导向投资
  - ✅ 行业轮动信号识别（成长/防御/周期板块）- 邱国鹭行业轮动理论
  - ✅ 智能新闻分级（长期价值 vs 短期波动）- 李杰能力圈理论
  - ✅ 投资机会识别功能（高/中/低机会评级）- 邱国鹭四要素理论
- 多源数据支持：新浪财经、东方财富、云财经、财联社、上交所
- 缓存机制优化，减少重复请求
- JSON标准输出格式，便于集成

## 使用方法

```bash
# 获取实时财经新闻（含投资价值分析）
./finance_news_final.sh latest_news all 5

# 获取政策新闻（含政策导向分析）
./finance_news_final.sh latest_news policy 3

# 获取市场新闻（含行业轮动分析）
./finance_news_final.sh latest_news market 3

# 获取公司新闻（含基本面分析）
./finance_news_final.sh latest_news company 3

# 获取科技行业新闻（含成长性分析）
./finance_news_final.sh latest_news technology 3

# 获取金融行业新闻（含防御性分析）
./finance_news_final.sh latest_news finance 3
```

## 投资价值分析维度

### 1. 邱国鹭四要素理论
- **估值**：基于新闻内容中的价格信息进行估值分析
- **品质**：基于公司基本面和护城河描述进行品质分析  
- **时机**：基于政策导向和市场情绪进行时机分析
- **仓位**：基于风险收益比评估提供仓位建议

### 2. 李杰能力圈理论
- **好生意**：商业模式分析基于护城河和竞争优势
- **好公司**：好公司分析基于管理层和治理结构
- **好价格**：好价格分析基于估值水平和安全边际

### 3. 输出字段说明
- `investment_grade`: 投资等级 (high/medium/low)
- `time_horizon`: 时间维度 (long_term/short_term/mixed)
- `policy_orientation`: 政策导向 (positive/negative/neutral)
- `industry_rotation`: 行业轮动 (growth_sector/defensive_sector/cyclical_sector/neutral)
- `opportunity_level`: 机会等级 (high/medium/low)
- `value_score`: 综合价值评分 (0-100分)

## 数据源配置

支持配置多个财经新闻源，可在 `config.json` 中进行调整。

## 缓存机制

- 默认缓存5分钟，避免重复请求
- 最大缓存大小100MB
- 自动清理过期缓存

## 版本信息

- 版本: 2.1.0
- 基于邱国鹭《投资中最简单的事》和李杰《股市进阶之道》投资理念优化
- 兼容原有接口，新增完整投资分析功能
- 通过JSON格式验证和功能测试