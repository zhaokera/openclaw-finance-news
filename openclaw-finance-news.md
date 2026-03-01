# Skill: openclaw-finance-news

## 描述
实时获取最新财经新闻、市场动态、公司公告、行业资讯等。集成 DuckDuckGo 联网搜索能力，支持全网财经资讯搜索。

## 权限
- bash
- web_fetch
- web_search

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

### 7. 联网搜索
使用 DuckDuckGo 搜索全网财经资讯，突破数据源限制。

## 数据源

### DuckDuckGo 搜索（新增）
- 全网搜索：支持任意关键词的财经新闻搜索
- 实时搜索：搜索引擎实时索引，速度快
- 多源覆盖：覆盖全网所有网站的财经内容

### 新浪财经
- 实时新闻：`https://finance.sina.com.cn/news/`
- 公司新闻：`https://finance.sina.com.cn/company/`

### 东方财富
- 新闻中心：`https://news.eastmoney.com/`
- 公告中心：`https://data.eastmoney.com/executive/`

### 云财经
- 财经新闻：`https://www.yuncaijing.com/news/`
- 个股新闻：`https://www.yuncaijing.com/news/ggnr/`

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

# 联网搜索财经新闻（新增）
skill: openclaw-finance-news
action: search
query: A股投资策略 2024
limit: 10

# 联网搜索特定主题
skill: openclaw-finance-news
action: search
query: 芯片板块 最新消息
source: 全网
limit: 15

# 联网搜索股票相关资讯
skill: openclaw-finance-news
action: search_stock
query: 贵州茅台 分析
limit: 10
```

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
    }
  ],
  "total": 20,
  "fetch_time": "2024-01-15 14:30:05"
}
```

### 联网搜索输出
```json
{
  "query": "A股投资策略 2024",
  "source": "DuckDuckGo",
  "timestamp": "2024-01-15 14:30:00",
  "results": [
    {
      "title": "2024年A股投资策略报告",
      "url": "https://example.com/report",
      "snippet": "详细的投资策略分析...",
      "favicon": ""
    }
  ],
  "total": 10,
  "fetch_time": "2024-01-15 14:30:05"
}
```

## 辅助函数

```bash
# 使用 DuckDuckGo 搜索
duckduckgo_search() {
  local query=$1
  local limit=${2:-10}
  ddgr "$query" --limit $limit
}

# 搜索新闻
duckduckgo_news() {
  local query=$1
  local time_range=${2:-d}
  ddgr "$query" -n --time $time_range
}

# 搜索图片
duckduckgo_images() {
  local query=$1
  local limit=${2:-10}
  ddgr "$query" -i --limit $limit
}

# 搜索视频
duckduckgo_videos() {
  local query=$1
  local limit=${2:-5}
  ddgr "$query" -v --limit $limit
}

# 网站搜索
duckduckgo_site_search() {
  local query=$1
  local site=$2
  local limit=${3:-10}
  ddgr "site:$site $query" --limit $limit
}

# 获取即时答案
duckduckgo_answer() {
  local query=$1
  ddgr -y "$query"
}
```

## 注意事项

1. **搜索速度**: DuckDuckGo 搜索速度较快，结果实时性高
2. **数据覆盖**: 覆盖全网内容，不受限于特定网站 API
3. **结果质量**: 搜索引擎自动排序，相关性较高
4. **组合使用**: 可以结合特定网站 API 和搜索功能使用

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

## 相关链接

- [DuckDuckGo](https://duckduckgo.com/)
- [DDGR 工具](https://github.com/ruivu/duckduckgo-cli)
