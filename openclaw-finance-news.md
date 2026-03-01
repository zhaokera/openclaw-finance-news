# Skill: openclaw-finance-news

## 描述
实时获取最新财经新闻、市场动态、公司公告、行业资讯等。

## 权限
- bash
- web_fetch

## 功能

### 1. 实时财经新闻
获取最新发布的财经新闻、市场快讯、行业动态。

### 2. 股市快讯
A股、港股、美股市场的实时行情和新闻。

### 3. 公司公告
上市公司重要公告、财报发布、重大事项。

### 4. 宏观经济
国家经济数据、政策法规、央行货币政策。

### 5. 行业资讯
不同行业的新闻、企业动态、市场趋势。

### 6. 热点新闻
市场热点题材、热门股票、新闻关注度排行榜。

## 数据源

### 新浪财经
- 实时新闻：`https://finance.sina.com.cn/news/`
- 公司新闻：`https://finance.sina.com.cn/company/`

### 东方财富
- 新闻中心：`https://news.eastmoney.com/`
- 公告中心：`https://data.eastmoney.com/executive/`

### 云财经
- 财经新闻：`https://www.yuncaijing.com/news/`
- 个股新闻：`https://www.yuncaijing.com/news/ggnr/`

### 东方财富网
- 新闻频道：`https://news.eastmoney.com/`
- 公告频道：`https://data.eastmoney.com/executive/`

### 财联社
- 电讯新闻：`https://www.cls.cn/`
- 热点新闻：`https://www.cls.cn/node/4282`

### 上证资讯
- 上证新闻：`http://www.sse.com.cn/`
- 上市公司公告：`http://www.sse.com.cn/disclosure/`

## 使用示例

```
# 获取实时财经新闻
skill: openclaw-finance-news
action: latest_news
category: all
limit: 20

# 获取股市快讯
skill: openclaw-finance-news
action: market_news
market: all
limit: 10

# 获取公司公告
skill: openclaw-finance-news
action: company_announcements
symbol: sh600000
limit: 10

# 获取宏观经济新闻
skill: openclaw-finance-news
action: macro_news
limit: 10

# 获取行业资讯
skill: openclaw-finance-news
action: industry_news
industry: 互联网
limit: 15

# 获取热点新闻
skill: openclaw-finance-news
action: hot_news
limit: 20

# 获取特定股票的新闻
skill: openclaw-finance-news
action: stock_news
symbol: sz000001
limit: 15

# 搜索新闻
skill: openclaw-finance-news
action: search_news
keyword: 芯片
limit: 20
```

## 新闻分类

| 分类 | 说明 |
|------|------|
| all | 全部新闻 |
| market | 市场新闻 |
| company | 公司新闻 |
| macro | 宏观经济 |
| industry | 行业资讯 |
| international | 国际新闻 |
| policy | 政策法规 |
| technology | 科技新闻 |
| finance | 金融新闻 |
| property | 房地产 |

## 输出格式

### 实时财经新闻输出
```json
{
  "source": "新浪财经",
  "timestamp": "2024-01-15 14:30:00",
  "news_list": [
    {
      "title": "沪指收复3000点，地产股集体大涨",
      "link": "https://finance.sina.com.cn/news/2024-01-15/",
      "source": "新浪财经",
      "publish_time": "2024-01-15 14:30:00",
      "category": "市场新闻",
      "abstract": "今日大盘表现强劲，沪指收复3000点大关，地产股集体大涨..."
    },
    {
      "title": "央行宣布下调存款准备金率0.5个百分点",
      "link": "https://finance.sina.com.cn/news/2024-01-15/",
      "source": "新浪财经",
      "publish_time": "2024-01-15 10:15:00",
      "category": "宏观政策",
      "abstract": "为支持实体经济健康发展，央行决定下调金融机构存款准备金率..."
    }
  ],
  "total": 20,
  "fetch_time": "2024-01-15 14:30:05"
}
```

### 股市快讯输出
```json
{
  "source": "东方财富",
  "timestamp": "2024-01-15 15:00:00",
  "market_news": [
    {
      "title": "A股三大股指集体上涨，创业板指涨超2%",
      "link": "https://news.eastmoney.com/202401/R20240115500000.html",
      "source": "东方财富",
      "publish_time": "2024-01-15 15:00:00",
      "category": "股市快讯",
      "tags": ["A股", "创业板", "上涨"]
    },
    {
      "title": "北向资金净买入50亿元，连续3日加仓",
      "link": "https://news.eastmoney.com/202401/R20240115500001.html",
      "source": "东方财富",
      "publish_time": "2024-01-15 14:55:00",
      "category": "资金动向",
      "tags": ["北向资金", "净买入", "加仓"]
    }
  ],
  "total": 10,
  "fetch_time": "2024-01-15 15:00:05"
}
```

### 公司公告输出
```json
{
  "symbol": "sh600000",
  "stock_name": "浦发银行",
  "source": "东方财富",
  "timestamp": "2024-01-15 14:00:00",
  "announcements": [
    {
      "title": "浦发银行2023年年度业绩预告公告",
      "link": "http://www.sse.com.cn/disclosure/Announcement/Company/2024-01-15/600000_20240115_12345.html",
      "publish_time": "2024-01-15 14:00:00",
      "category": "业绩预告",
      "content": "经财务部门初步测算，预计2023年年度实现归属于母公司股东的净利润..."
    },
    {
      "title": "浦发银行关于董事辞职的公告",
      "link": "http://www.sse.com.cn/disclosure/Announcement/Company/2024-01-14/600000_20240114_67890.html",
      "publish_time": "2024-01-14 18:00:00",
      "category": "董事会",
      "content": "公司董事会近日收到董事张三先生的辞职报告..."
    }
  ],
  "total": 10,
  "fetch_time": "2024-01-15 14:00:05"
}
```

### 搜索新闻输出
```json
{
  "keyword": "芯片",
  "source": "云财经",
  "timestamp": "2024-01-15 14:30:00",
  "news_list": [
    {
      "title": "国产芯片迎来重大突破，多家企业发布新进展",
      "link": "https://www.yuncaijing.com/news/12345.html",
      "source": "云财经",
      "publish_time": "2024-01-15 14:30:00",
      "category": "科技新闻",
      "abstract": "近日，国产芯片领域传来好消息，多家芯片企业发布最新技术进展..."
    },
    {
      "title": "芯片股集体上涨，半导体板块成资金关注焦点",
      "link": "https://www.yuncaijing.com/news/12346.html",
      "source": "云财经",
      "publish_time": "2024-01-15 10:15:00",
      "category": "市场新闻",
      "abstract": "受利好消息影响，芯片股今日集体上涨，半导体板块成为资金关注焦点..."
    }
  ],
  "total": 20,
  "fetch_time": "2024-01-15 14:30:05"
}
```

## API 数据源详情

### 新浪财经新闻 API
```bash
# 实时新闻列表
curl -s "https://finance.sina.com.cn/js/county/new folly.js"

# 公司新闻
curl -s "https://finance.sina.com.cn/js/jjhh.js"

# 宏观经济新闻
curl -s "https://finance.sina.com.cn/js/macrodynamics.js"
```

### 东方财富新闻 API
```bash
# 新闻列表
curl -s "https://news.eastmoney.com/stock/api/header.json"

# 公告列表
curl -s "https://datacenter.eastmoney.com/api/data/get?datatype=WEB&client=WAP&platform=wapidata&num=20&pg=1"
```

### 云财经 API
```bash
# 新闻列表
curl -s "https://api.yuncaijing.com/v1/news/list"

# 股票新闻
curl -s "https://api.yuncaijing.com/v1/stock/news?code=600000"
```

## 高级用法

### 1. 添加新闻订阅
```
skill: openclaw-finance-news
action: subscribe
category: 芯片
refresh_interval: 30
```

### 2. 设置新闻过滤
```
skill: openclaw-finance-news
action: filter
include_keywords: 芯片,半导体
exclude_keywords: ST,*ST
min_importance: 5
```

### 3. 获取新闻摘要
```
skill: openclaw-finance-news
action: summary
date: 2024-01-15
type: daily
```

### 4. 设置新闻提醒
```
skill: openclaw-finance-news
action: setup_alert
type: price_breakout
symbol: sh600000
condition: price > 10
notify_channel: email
```

### 5. 查看新闻历史
```
skill: openclaw-finance-news
action: history
date_range: 2024-01-01 to 2024-01-15
category: macro
```

## 辅助函数

```bash
# 获取新闻列表
get_news_list() {
  local category=${1:-all}
  local limit=${2:-20}
  local url="https://finance.sina.com.cn/js/county/new_folly.js"
  curl -s "$url" | jq "."
}

# 获取股票新闻
get_stock_news() {
  local symbol=$1
  local limit=${2:-20}
  local url="https://api.yuncaijing.com/v1/stock/news?code=${symbol:1}"
  curl -s "$url" | jq "."
}

# 获取公告列表
get_announcements() {
  local symbol=$1
  local limit=${2:-10}
  local url="https://data.eastmoney.com/executive/stock.js?code=${symbol}"
  curl -s "$url" | jq "."
}

# 搜索新闻
search_news() {
  local keyword=$1
  local limit=${2:-20}
  local url="https://www.yuncaijing.com/news/search?keyword=${keyword}"
  curl -s "$url" | jq "."
}

# 获取宏观经济新闻
get_macro_news() {
  local limit=${1:-10}
  local url="https://finance.sina.com.cn/js/macrodynamics.js"
  curl -s "$url" | jq "."
}

# 获取行业新闻
get_industry_news() {
  local industry=$1
  local limit=${2:-15}
  local url="https://finance.sina.com.cn/js/industry.js?industry=${industry}"
  curl -s "$url" | jq "."
}

# 获取财经日历
get_finance_calendar() {
  local date=${1:-2024-01-15}
  local url="https://finance.sina.com.cn/js/callendar.js?date=${date}"
  curl -s "$url" | jq "."
}
```

## 输出字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| source | string | 新闻来源 |
| timestamp | string | 获取时间 |
| news_list/array | array | 新闻列表 |
| title | string | 新闻标题 |
| link | string | 新闻链接 |
| source | string | 新闻来源 |
| publish_time | string | 发布时间 |
| category | string | 新闻分类 |
| abstract | string | 新闻摘要 |
| content | string | 新闻内容 |
| tags | array | 新闻标签 |
| total | int | 总数 |
| fetch_time | string | 获取时间 |
| keyword | string | 搜索关键词 |
| symbol | string | 股票代码 |
| stock_name | string | 股票名称 |

## 警告和注意事项

1. **数据延迟**: 免费 API 数据可能存在延迟，请勿用于高频交易决策
2. **API 限制**: 注意各网站的访问频率限制，避免被封禁
3. **数据准确性**: 新闻数据仅供参考，不构成投资建议
4. **网络依赖**: 依赖网络连接，网络异常时无法获取数据
5. **格式变化**: 网站页面格式可能变动，需要及时调整解析逻辑
6. **版权说明**: 新闻内容版权归原作者所有，请勿用于商业用途

## 更新日志

### v1.0.0 (2024-01-15)
- 初始版本发布
- 实现实时财经新闻、股市快讯、公司公告、宏观经济、行业资讯功能
- 支持新闻搜索、新闻订阅、新闻过滤、新闻提醒等高级功能

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 作者

zhaokera

## 相关链接

- [新浪财经](https://finance.sina.com.cn/)
- [东方财富](https://www.eastmoney.com/)
- [云财经](https://www.yuncaijing.com/)
- [财联社](https://www.cls.cn/)
- [上证资讯](http://www.sse.com.cn/)
