# OpenClaw Finance News Skill

实时获取最新财经新闻、市场动态、公司公告、行业资讯等。

## 功能

- 实时财经新闻
- 股市快讯（A股、港股、美股）
- 公司公告
- 宏观经济新闻
- 行业资讯
- 热点新闻
- 新闻搜索

## 数据源

- 新浪财经
- 东方财富
- 云财经
- 财联社
- 上证资讯

## 使用方法

```bash
# 获取实时财经新闻
./finance_news.sh latest_news all 20

# 获取股市快讯
./finance_news.sh market_news all 10

# 获取公司公告
./finance_news.sh company_announcements sh600000 10

# 获取宏观经济新闻
./finance_news.sh macro_news 10

# 获取行业资讯
./finance_news.sh industry_news 互联网 15

# 获取热点新闻
./finance_news.sh hot_news 20

# 获取特定股票的新闻
./finance_news.sh stock_news sz000001 15

# 搜索新闻
./finance_news.sh search_news 芯片 20
```

## 输出格式

所有输出均为标准 JSON 格式，包含错误处理和时间戳信息。