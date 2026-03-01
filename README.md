# OpenClaw 财经新闻技能（集成 DuckDuckGo）

集成 DuckDuckGo 联网搜索能力的专业财经新闻 Skill，支持实时行情、新闻资讯、公司公告和全网搜索。

## 功能特性

### 🔍 实时财经新闻
- 最新发布的财经新闻、市场快讯、行业动态
- 多源数据支持：新浪财经、东方财富、云财经、财联社、上交所

### 📈 市场快讯
- A股、港股、美股市场的实时行情和新闻
- 资金流向、涨跌停、成交量分析

### 📋 公司公告
- 上市公司重要公告、财报发布、重大事项
- 公告分类：业绩预告、董事会、股权变动等

### 🌍 宏观经济
- 国家经济数据、政策法规、央行货币政策
- 政策影响分析、经济周期判断

### 🏭 行业资讯
- 不同行业的新闻、企业动态、市场趋势
- 行业轮动信号识别

### 🔥 热点新闻
- 市场热点题材、热门股票、新闻关注度排行榜

### 🌐 联网搜索（新增）
- 使用 DuckDuckGo 搜索全网财经资讯
- 突破数据源限制，覆盖全网内容
- 实时搜索，速度快

## 投资分析功能

基于邱国鹭《投资中最简单的事》和李杰《股市进阶之道》的投资理念：

### 邱国鹭四要素分析
- **估值**: 基于新闻内容中的价格信息进行估值分析
- **品质**: 护城河评估、ROE、现金流、负债率分析
- **时机**: 市场情绪、政策环境、行业周期判断
- **仓位**: 基于综合评分的仓位管理建议

### 李杰能力圈理论
- **好生意**: 商业模式分析、行业竞争格局
- **好公司**: 公司品质、护城河强度评估
- **好价格**: 估值水平、安全边际计算

### 特色功能
- **护城河评估**: 识别品牌、成本、网络效应、转换成本
- **安全边际计算**: 基于历史估值区间的量化分析
- **价值陷阱识别**: 警惕低PE高负债、低PB盈利下滑
- **风险控制**: 全面的风险预警和投资建议

## 安装使用

### 安装到 OpenClaw

1. 将 `openclaw-finance-news.md` 文件复制到 OpenClaw 的 skills 目录
   - macOS: `~/Library/Application Support/OpenClaw/skills/`
   - Windows: `%APPDATA%\OpenClaw\skills/`
   - Linux: `~/.config/OpenClaw/skills/`

2. 重启 OpenClaw 或重新加载 skills

### 依赖安装

```bash
# 安装 duckduckgo-cli (ddgr)
pip install ddgr

# 或使用 npx
npx duckduckgo-mcp-server
```

## 使用示例

```
# 获取实时财经新闻
skill: openclaw-finance-news
action: latest_news
category: all
limit: 20

# 获取政策新闻（含政策导向分析）
skill: openclaw-finance-news
action: latest_news
category: policy
limit: 5

# 获取市场新闻（含行业轮动分析）
skill: openclaw-finance-news
action: latest_news
category: market
limit: 5

# 公司公告
skill: openclaw-finance-news
action: company_announcements
symbol: sh600000
limit: 10

# 联网搜索财经新闻
skill: openclaw-finance-news
action: search
query: A股投资策略 2024
limit: 10

# 联网搜索股票相关资讯
skill: openclaw-finance-news
action: search_stock
query: 贵州茅台 分析
limit: 10

# 联网搜索特定主题
skill: openclaw-finance-news
action: search
query: 芯片板块 最新消息
source: 全网
limit: 15
```

## 数据源

### DuckDuckGo（新增）
- 全网搜索：支持任意关键词的财经新闻搜索
- 实时搜索：搜索引擎实时索引，速度快
- 多源覆盖：覆盖全网所有网站的财经内容

### 新浪财经
- 实时新闻：https://finance.sina.com.cn/news/
- 公司新闻：https://finance.sina.com.cn/company/

### 东方财富
- 新闻中心：https://news.eastmoney.com/
- 公告中心：https://data.eastmoney.com/executive/

### 云财经
- 财经新闻：https://www.yuncaijing.com/news/

### 财联社
- 电讯新闻：https://www.cls.cn/

### 上交所
- 公告披露：http://www.sse.com.cn/disclosure/

## 输出格式

### 实时财经新闻
```json
{
  "source": "新浪财经",
  "timestamp": "2024-01-15 14:30:00",
  "news_list": [...],
  "total": 20,
  "fetch_time": "2024-01-15 14:30:05"
}
```

### 联网搜索结果
```json
{
  "query": "A股投资策略 2024",
  "source": "DuckDuckGo",
  "timestamp": "2024-01-15 14:30:00",
  "results": [...],
  "total": 10,
  "fetch_time": "2024-01-15 14:30:05"
}
```

## 注意事项

1. **搜索速度**: DuckDuckGo 搜索速度较快，结果实时性高
2. **数据覆盖**: 覆盖全网内容，不受限于特定网站 API
3. **组合使用**: 可以结合特定网站 API 和搜索功能使用

## 相关项目

- [openclaw-stock-analyzer](https://github.com/zhaokera/openclaw-stock-analyzer) - A股实时分析
- [openclaw-duckgo](https://github.com/zhaokera/openclaw-duckgo) - DuckDuckGo 搜索

## 更新日志

### v2.0.0 (2024-01-15)
- 新增 DuckDuckGo 联网搜索能力
- 优化搜索功能，支持全网财经资讯搜索

### v1.0.0 (2024-01-15)
- 初始版本发布
- 实现实时财经新闻、股市快讯、公司公告、宏观经济、行业资讯功能

## 许可证

MIT License

## 作者

zhaokera
