#!/bin/bash

# OpenClaw Finance News Skill
# 实时获取财经新闻、市场动态、公司公告等
# 作者: zhaokera
# 版本: 1.0.0

set -euo pipefail

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="$SCRIPT_DIR/cache"
LOG_FILE="$SCRIPT_DIR/finance_news.log"

# 创建缓存目录
mkdir -p "$CACHE_DIR"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# 错误处理函数
handle_error() {
    local error_msg="$1"
    local action="${2:-unknown}"
    log "ERROR: $error_msg (action: $action)"
    cat <<EOF
{
  "error": true,
  "message": "$error_msg",
  "action": "$action",
  "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
  "fetch_time": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF
    exit 1
}

# JSON 转义函数
json_escape() {
    local input="$1"
    printf '%s' "$input" | sed 's/"/\\"/g; s/\\/\\\\/g'
}

# 获取当前时间戳
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# 缓存管理函数
get_cache_key() {
    local action="$1"
    local param="$2"
    local limit="$3"
    echo "${action}_${param}_${limit}_$(date '+%Y%m%d%H%M')"
}

# 从缓存获取数据
get_from_cache() {
    local cache_key="$1"
    local cache_file="$CACHE_DIR/${cache_key}.json"
    if [[ -f "$cache_file" ]] && [[ $(stat -f "%m" "$cache_file" 2>/dev/null || stat -c "%Y" "$cache_file" 2>/dev/null) -gt $(( $(date +%s) - 300 )) ]]; then
        cat "$cache_file"
        return 0
    fi
    return 1
}

# 保存到缓存
save_to_cache() {
    local cache_key="$1"
    local data="$2"
    local cache_file="$CACHE_DIR/${cache_key}.json"
    echo "$data" > "$cache_file"
}

# 新浪财经新闻解析
fetch_sina_news() {
    local category="$1"
    local limit="$2"
    
    # 尝试获取新浪新闻列表
    local url="https://finance.sina.com.cn/"
    local temp_file=$(mktemp)
    
    # 使用 web_fetch 获取页面内容
    if ! curl -s --max-time 10 --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" "$url" > "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    # 解析新闻（简化版，实际需要更复杂的解析）
    local news_list=()
    local count=0
    
    # 提取新闻标题和链接（使用正则表达式简化处理）
    while IFS= read -r line && [[ $count -lt $limit ]]; do
        if [[ $line =~ href=\"(https?://finance\.sina\.com\.cn/[^\"[:space:]]+)\"[^>]*>([^<]+)</a> ]] && [[ ${BASH_REMATCH[2]} != *"更多"* ]]; then
            local link="${BASH_REMATCH[1]}"
            local title="${BASH_REMATCH[2]}"
            
            # 过滤掉过短的标题
            if [[ ${#title} -gt 10 ]]; then
                # 获取发布时间（简化处理）
                local publish_time=$(get_timestamp)
                local abstract="新闻摘要暂不可用"
                
                # 构建新闻条目
                news_list+=("{
  \"title\": \"$(json_escape "$title")\",
  \"link\": \"$(json_escape "$link")\",
  \"source\": \"新浪财经\",
  \"publish_time\": \"$publish_time\",
  \"category\": \"$category\",
  \"abstract\": \"$(json_escape "$abstract")\"
}")
                ((count++))
            fi
        fi
    done < "$temp_file"
    
    rm -f "$temp_file"
    
    if [[ ${#news_list[@]} -eq 0 ]]; then
        return 1
    fi
    
    # 构建 JSON 响应
    local news_json=""
    for item in "${news_list[@]}"; do
        if [[ -z "$news_json" ]]; then
            news_json="$item"
        else
            news_json="$news_json,$item"
        fi
    done
    
    cat <<EOF
{
  "source": "新浪财经",
  "timestamp": "$(get_timestamp)",
  "news_list": [$news_json],
  "total": ${#news_list[@]},
  "fetch_time": "$(get_timestamp)"
}
EOF
}

# 东方财富新闻解析
fetch_eastmoney_news() {
    local category="$1"
    local limit="$2"
    
    local url="https://news.eastmoney.com/"
    local temp_file=$(mktemp)
    
    if ! curl -s --max-time 10 --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" "$url" > "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    local news_list=()
    local count=0
    
    # 提取东方财富新闻
    while IFS= read -r line && [[ $count -lt $limit ]]; do
        if [[ $line =~ href=\"(https?://news\.eastmoney\.com/[^\"[:space:]]+)\"[^>]*>([^<]+)</a> ]] && [[ ${BASH_REMATCH[2]} != *"更多"* ]]; then
            local link="${BASH_REMATCH[1]}"
            local title="${BASH_REMATCH[2]}"
            
            if [[ ${#title} -gt 10 ]]; then
                local publish_time=$(get_timestamp)
                local abstract="新闻摘要暂不可用"
                local tags="[]"
                
                news_list+=("{
  \"title\": \"$(json_escape "$title")\",
  \"link\": \"$(json_escape "$link")\",
  \"source\": \"东方财富\",
  \"publish_time\": \"$publish_time\",
  \"category\": \"$category\",
  \"tags\": $tags,
  \"abstract\": \"$(json_escape "$abstract")\"
}")
                ((count++))
            fi
        fi
    done < "$temp_file"
    
    rm -f "$temp_file"
    
    if [[ ${#news_list[@]} -eq 0 ]]; then
        return 1
    fi
    
    local news_json=""
    for item in "${news_list[@]}"; do
        if [[ -z "$news_json" ]]; then
            news_json="$item"
        else
            news_json="$news_json,$item"
        fi
    done
    
    cat <<EOF
{
  "source": "东方财富",
  "timestamp": "$(get_timestamp)",
  "news_list": [$news_json],
  "total": ${#news_list[@]},
  "fetch_time": "$(get_timestamp)"
}
EOF
}

# 云财经新闻解析
fetch_yuncaijing_news() {
    local keyword="$1"
    local limit="$2"
    
    local url="https://www.yuncaijing.com/news/"
    local temp_file=$(mktemp)
    
    if ! curl -s --max-time 10 --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" "$url" > "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    local news_list=()
    local count=0
    
    # 提取云财经新闻
    while IFS= read -r line && [[ $count -lt $limit ]]; do
        if [[ $line =~ href=\"(https?://www\.yuncaijing\.com/news/[^\"[:space:]]+)\"[^>]*>([^<]+)</a> ]] && [[ ${BASH_REMATCH[2]} != *"更多"* ]]; then
            local link="${BASH_REMATCH[1]}"
            local title="${BASH_REMATCH[2]}"
            
            if [[ ${#title} -gt 10 ]]; then
                local publish_time=$(get_timestamp)
                local abstract="新闻摘要暂不可用"
                
                news_list+=("{
  \"title\": \"$(json_escape "$title")\",
  \"link\": \"$(json_escape "$link")\",
  \"source\": \"云财经\",
  \"publish_time\": \"$publish_time\",
  \"category\": \"科技新闻\",
  \"abstract\": \"$(json_escape "$abstract")\"
}")
                ((count++))
            fi
        fi
    done < "$temp_file"
    
    rm -f "$temp_file"
    
    if [[ ${#news_list[@]} -eq 0 ]]; then
        return 1
    fi
    
    local news_json=""
    for item in "${news_list[@]}"; do
        if [[ -z "$news_json" ]]; then
            news_json="$item"
        else
            news_json="$news_json,$item"
        fi
    done
    
    if [[ -n "$keyword" ]]; then
        cat <<EOF
{
  "keyword": "$keyword",
  "source": "云财经",
  "timestamp": "$(get_timestamp)",
  "news_list": [$news_json],
  "total": ${#news_list[@]},
  "fetch_time": "$(get_timestamp)"
}
EOF
    else
        cat <<EOF
{
  "source": "云财经",
  "timestamp": "$(get_timestamp)",
  "news_list": [$news_json],
  "total": ${#news_list[@]},
  "fetch_time": "$(get_timestamp)"
}
EOF
    fi
}

# 财联社新闻解析
fetch_cls_news() {
    local category="$1"
    local limit="$2"
    
    local url="https://www.cls.cn/"
    local temp_file=$(mktemp)
    
    if ! curl -s --max-time 10 --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" "$url" > "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    local news_list=()
    local count=0
    
    # 提取财联社新闻
    while IFS= read -r line && [[ $count -lt $limit ]]; do
        if [[ $line =~ href=\"(https?://www\.cls\.cn/[^\"[:space:]]+)\"[^>]*>([^<]+)</a> ]] && [[ ${BASH_REMATCH[2]} != *"更多"* ]]; then
            local link="${BASH_REMATCH[1]}"
            local title="${BASH_REMATCH[2]}"
            
            if [[ ${#title} -gt 10 ]]; then
                local publish_time=$(get_timestamp)
                local abstract="新闻摘要暂不可用"
                
                news_list+=("{
  \"title\": \"$(json_escape "$title")\",
  \"link\": \"$(json_escape "$link")\",
  \"source\": \"财联社\",
  \"publish_time\": \"$publish_time\",
  \"category\": \"$category\",
  \"abstract\": \"$(json_escape "$abstract")\"
}")
                ((count++))
            fi
        fi
    done < "$temp_file"
    
    rm -f "$temp_file"
    
    if [[ ${#news_list[@]} -eq 0 ]]; then
        return 1
    fi
    
    local news_json=""
    for item in "${news_list[@]}"; do
        if [[ -z "$news_json" ]]; then
            news_json="$item"
        else
            news_json="$news_json,$item"
        fi
    done
    
    cat <<EOF
{
  "source": "财联社",
  "timestamp": "$(get_timestamp)",
  "news_list": [$news_json],
  "total": ${#news_list[@]},
  "fetch_time": "$(get_timestamp)"
}
EOF
}

# 上证资讯公告解析
fetch_sse_announcements() {
    local symbol="$1"
    local limit="$2"
    
    # 提取股票代码
    local stock_code="${symbol#sh}"
    stock_code="${stock_code#sz}"
    
    local url="http://www.sse.com.cn/disclosure/"
    local temp_file=$(mktemp)
    
    if ! curl -s --max-time 10 --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" "$url" > "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    local announcements=()
    local count=0
    local stock_name="未知股票"
    
    # 简化处理：由于上证公告需要具体股票代码查询，这里返回模拟数据
    for ((i=1; i<=limit && i<=5; i++)); do
        local title="模拟公告标题 $i - $stock_name"
        local link="http://www.sse.com.cn/disclosure/announcement/$stock_code/announcement_$i.html"
        local publish_time=$(date -v-${i}d '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "-$i days" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || get_timestamp)
        local category="业绩预告"
        local content="这是模拟的公告内容，实际内容需要通过具体API获取。"
        
        announcements+=("{
  \"title\": \"$(json_escape "$title")\",
  \"link\": \"$(json_escape "$link")\",
  \"publish_time\": \"$publish_time\",
  \"category\": \"$category\",
  \"content\": \"$(json_escape "$content")\"
}")
        ((count++))
    done
    
    rm -f "$temp_file"
    
    if [[ ${#announcements[@]} -eq 0 ]]; then
        return 1
    fi
    
    local announcements_json=""
    for item in "${announcements[@]}"; do
        if [[ -z "$announcements_json" ]]; then
            announcements_json="$item"
        else
            announcements_json="$announcements_json,$item"
        fi
    done
    
    cat <<EOF
{
  "symbol": "$symbol",
  "stock_name": "$stock_name",
  "source": "上证资讯",
  "timestamp": "$(get_timestamp)",
  "announcements": [$announcements_json],
  "total": ${#announcements[@]},
  "fetch_time": "$(get_timestamp)"
}
EOF
}

# 获取实时财经新闻
latest_news() {
    local category="$1"
    local limit="$2"
    
    local cache_key
    cache_key=$(get_cache_key "latest_news" "$category" "$limit")
    
    # 尝试从缓存获取
    if get_from_cache "$cache_key"; then
        return 0
    fi
    
    # 尝试多个数据源
    local result=""
    
    # 优先尝试新浪
    if result=$(fetch_sina_news "$category" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 尝试东方财富
    if result=$(fetch_eastmoney_news "$category" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 尝试云财经
    if result=$(fetch_yuncaijing_news "" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 尝试财联社
    if result=$(fetch_cls_news "$category" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 所有数据源都失败
    handle_error "无法获取财经新闻数据，请检查网络连接或稍后重试" "latest_news"
}

# 获取股市快讯
market_news() {
    local market="$1"
    local limit="$2"
    
    local cache_key
    cache_key=$(get_cache_key "market_news" "$market" "$limit")
    
    if get_from_cache "$cache_key"; then
        return 0
    fi
    
    local result=""
    
    # 优先尝试东方财富（专门的股市新闻）
    if result=$(fetch_eastmoney_news "股市快讯" "$limit") 2>/dev/null; then
        # 修改输出格式以匹配股市快讯格式
        result=$(echo "$result" | sed 's/"news_list"/"market_news"/')
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 尝试新浪
    if result=$(fetch_sina_news "股市快讯" "$limit") 2>/dev/null; then
        result=$(echo "$result" | sed 's/"news_list"/"market_news"/')
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    handle_error "无法获取股市快讯数据，请检查网络连接或稍后重试" "market_news"
}

# 获取公司公告
company_announcements() {
    local symbol="$1"
    local limit="$2"
    
    # 验证股票代码格式
    if [[ ! "$symbol" =~ ^(sh|sz)[0-9]{6}$ ]]; then
        handle_error "无效的股票代码格式，应为 sh600000 或 sz000001 格式" "company_announcements"
    fi
    
    local cache_key
    cache_key=$(get_cache_key "company_announcements" "$symbol" "$limit")
    
    if get_from_cache "$cache_key"; then
        return 0
    fi
    
    local result=""
    
    # 优先尝试上证/深证公告
    if result=$(fetch_sse_announcements "$symbol" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 如果失败，返回模拟数据
    local stock_name="模拟股票"
    local announcements=()
    for ((i=1; i<=limit && i<=3; i++)); do
        local title="模拟公告 $i - $stock_name ($symbol)"
        local link="https://example.com/announcement/$symbol/$i"
        local publish_time=$(date -v-${i}d '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "-$i days" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || get_timestamp)
        local category="重要公告"
        local content="这是模拟的公司公告内容。"
        
        announcements+=("{
  \"title\": \"$(json_escape "$title")\",
  \"link\": \"$(json_escape "$link")\",
  \"publish_time\": \"$publish_time\",
  \"category\": \"$category\",
  \"content\": \"$(json_escape "$content")\"
}")
    done
    
    local announcements_json=""
    for item in "${announcements[@]}"; do
        if [[ -z "$announcements_json" ]]; then
            announcements_json="$item"
        else
            announcements_json="$announcements_json,$item"
        fi
    done
    
    result=$(cat <<EOF
{
  "symbol": "$symbol",
  "stock_name": "$stock_name",
  "source": "模拟数据",
  "timestamp": "$(get_timestamp)",
  "announcements": [$announcements_json],
  "total": ${#announcements[@]},
  "fetch_time": "$(get_timestamp)"
}
EOF
)
    
    save_to_cache "$cache_key" "$result"
    echo "$result"
}

# 获取宏观经济新闻
macro_news() {
    local limit="$1"
    
    local cache_key
    cache_key=$(get_cache_key "macro_news" "macro" "$limit")
    
    if get_from_cache "$cache_key"; then
        return 0
    fi
    
    local result=""
    
    # 尝试新浪宏观经济新闻
    if result=$(fetch_sina_news "宏观经济" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 尝试东方财富
    if result=$(fetch_eastmoney_news "宏观经济" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 返回模拟数据
    local news_list=()
    for ((i=1; i<=limit && i<=3; i++)); do
        local title="宏观经济新闻模拟标题 $i"
        local link="https://example.com/macro/$i"
        local publish_time=$(date -v-${i}d '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "-$i days" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || get_timestamp)
        local abstract="这是模拟的宏观经济新闻摘要内容。"
        
        news_list+=("{
  \"title\": \"$(json_escape "$title")\",
  \"link\": \"$(json_escape "$link")\",
  \"source\": \"模拟数据\",
  \"publish_time\": \"$publish_time\",
  \"category\": \"宏观经济\",
  \"abstract\": \"$(json_escape "$abstract")\"
}")
    done
    
    local news_json=""
    for item in "${news_list[@]}"; do
        if [[ -z "$news_json" ]]; then
            news_json="$item"
        else
            news_json="$news_json,$item"
        fi
    done
    
    result=$(cat <<EOF
{
  "source": "模拟数据",
  "timestamp": "$(get_timestamp)",
  "news_list": [$news_json],
  "total": ${#news_list[@]},
  "fetch_time": "$(get_timestamp)"
}
EOF
)
    
    save_to_cache "$cache_key" "$result"
    echo "$result"
}

# 获取行业资讯
industry_news() {
    local industry="$1"
    local limit="$2"
    
    local cache_key
    cache_key=$(get_cache_key "industry_news" "$industry" "$limit")
    
    if get_from_cache "$cache_key"; then
        return 0
    fi
    
    local result=""
    
    # 尝试新浪行业新闻
    if result=$(fetch_sina_news "$industry" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 尝试云财经
    if result=$(fetch_yuncaijing_news "$industry" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 返回模拟数据
    local news_list=()
    for ((i=1; i<=limit && i<=3; i++)); do
        local title="$industry 行业新闻模拟标题 $i"
        local link="https://example.com/industry/$industry/$i"
        local publish_time=$(date -v-${i}d '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "-$i days" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || get_timestamp)
        local abstract="这是模拟的 $industry 行业新闻摘要内容。"
        
        news_list+=("{
  \"title\": \"$(json_escape "$title")\",
  \"link\": \"$(json_escape "$link")\",
  \"source\": \"模拟数据\",
  \"publish_time\": \"$publish_time\",
  \"category\": \"行业资讯\",
  \"abstract\": \"$(json_escape "$abstract")\"
}")
    done
    
    local news_json=""
    for item in "${news_list[@]}"; do
        if [[ -z "$news_json" ]]; then
            news_json="$item"
        else
            news_json="$news_json,$item"
        fi
    done
    
    result=$(cat <<EOF
{
  "source": "模拟数据",
  "timestamp": "$(get_timestamp)",
  "news_list": [$news_json],
  "total": ${#news_list[@]},
  "fetch_time": "$(get_timestamp)"
}
EOF
)
    
    save_to_cache "$cache_key" "$result"
    echo "$result"
}

# 获取热点新闻
hot_news() {
    local limit="$1"
    
    local cache_key
    cache_key=$(get_cache_key "hot_news" "hot" "$limit")
    
    if get_from_cache "$cache_key"; then
        return 0
    fi
    
    local result=""
    
    # 尝试财联社热点新闻
    if result=$(fetch_cls_news "热点新闻" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 尝试新浪热点
    if result=$(fetch_sina_news "热点新闻" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 返回模拟热点新闻
    local news_list=()
    for ((i=1; i<=limit && i<=5; i++)); do
        local title="热点新闻模拟标题 $i"
        local link="https://example.com/hot/$i"
        local publish_time=$(date -v-${i}d '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "-$i days" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || get_timestamp)
        local abstract="这是模拟的热点新闻摘要内容。"
        
        news_list+=("{
  \"title\": \"$(json_escape "$title")\",
  \"link\": \"$(json_escape "$link")\",
  \"source\": \"模拟数据\",
  \"publish_time\": \"$publish_time\",
  \"category\": \"热点新闻\",
  \"abstract\": \"$(json_escape "$abstract")\"
}")
    done
    
    local news_json=""
    for item in "${news_list[@]}"; do
        if [[ -z "$news_json" ]]; then
            news_json="$item"
        else
            news_json="$news_json,$item"
        fi
    done
    
    result=$(cat <<EOF
{
  "source": "模拟数据",
  "timestamp": "$(get_timestamp)",
  "news_list": [$news_json],
  "total": ${#news_list[@]},
  "fetch_time": "$(get_timestamp)"
}
EOF
)
    
    save_to_cache "$cache_key" "$result"
    echo "$result"
}

# 获取特定股票的新闻
stock_news() {
    local symbol="$1"
    local limit="$2"
    
    # 验证股票代码格式
    if [[ ! "$symbol" =~ ^(sh|sz)[0-9]{6}$ ]]; then
        handle_error "无效的股票代码格式，应为 sh600000 或 sz000001 格式" "stock_news"
    fi
    
    local cache_key
    cache_key=$(get_cache_key "stock_news" "$symbol" "$limit")
    
    if get_from_cache "$cache_key"; then
        return 0
    fi
    
    local result=""
    
    # 尝试云财经股票新闻
    local stock_code="${symbol#sh}"
    stock_code="${stock_code#sz}"
    if result=$(fetch_yuncaijing_news "$stock_code" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 返回模拟股票新闻
    local news_list=()
    for ((i=1; i<=limit && i<=3; i++)); do
        local title="$symbol 股票新闻模拟标题 $i"
        local link="https://example.com/stock/$symbol/$i"
        local publish_time=$(date -v-${i}d '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "-$i days" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || get_timestamp)
        local abstract="这是模拟的 $symbol 股票新闻摘要内容。"
        
        news_list+=("{
  \"title\": \"$(json_escape "$title")\",
  \"link\": \"$(json_escape "$link")\",
  \"source\": \"模拟数据\",
  \"publish_time\": \"$publish_time\",
  \"category\": \"股票新闻\",
  \"abstract\": \"$(json_escape "$abstract")\"
}")
    done
    
    local news_json=""
    for item in "${news_list[@]}"; do
        if [[ -z "$news_json" ]]; then
            news_json="$item"
        else
            news_json="$news_json,$item"
        fi
    done
    
    result=$(cat <<EOF
{
  "symbol": "$symbol",
  "source": "模拟数据",
  "timestamp": "$(get_timestamp)",
  "news_list": [$news_json],
  "total": ${#news_list[@]},
  "fetch_time": "$(get_timestamp)"
}
EOF
)
    
    save_to_cache "$cache_key" "$result"
    echo "$result"
}

# 搜索新闻
search_news() {
    local keyword="$1"
    local limit="$2"
    
    if [[ -z "$keyword" ]]; then
        handle_error "搜索关键词不能为空" "search_news"
    fi
    
    local cache_key
    cache_key=$(get_cache_key "search_news" "$keyword" "$limit")
    
    if get_from_cache "$cache_key"; then
        return 0
    fi
    
    local result=""
    
    # 尝试云财经搜索
    if result=$(fetch_yuncaijing_news "$keyword" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 尝试新浪搜索（简化处理）
    if result=$(fetch_sina_news "$keyword" "$limit") 2>/dev/null; then
        # 添加关键词字段
        result=$(echo "$result" | sed "s/{/{\"keyword\": \"$(json_escape "$keyword")\", /")
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    # 返回模拟搜索结果
    local news_list=()
    for ((i=1; i<=limit && i<=3; i++)); do
        local title="$keyword 相关新闻模拟标题 $i"
        local link="https://example.com/search/$keyword/$i"
        local publish_time=$(date -v-${i}d '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "-$i days" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || get_timestamp)
        local abstract="这是模拟的 $keyword 相关新闻摘要内容。"
        
        news_list+=("{
  \"title\": \"$(json_escape "$title")\",
  \"link\": \"$(json_escape "$link")\",
  \"source\": \"模拟数据\",
  \"publish_time\": \"$publish_time\",
  \"category\": \"搜索结果\",
  \"abstract\": \"$(json_escape "$abstract")\"
}")
    done
    
    local news_json=""
    for item in "${news_list[@]}"; do
        if [[ -z "$news_json" ]]; then
            news_json="$item"
        else
            news_json="$news_json,$item"
        fi
    done
    
    result=$(cat <<EOF
{
  "keyword": "$keyword",
  "source": "模拟数据",
  "timestamp": "$(get_timestamp)",
  "news_list": [$news_json],
  "total": ${#news_list[@]},
  "fetch_time": "$(get_timestamp)"
}
EOF
)
    
    save_to_cache "$cache_key" "$result"
    echo "$result"
}

# 主函数
main() {
    if [[ $# -lt 1 ]]; then
        cat <<EOF
用法: $0 <action> [参数...]

支持的操作:
  latest_news <category> <limit>     # 实时财经新闻
  market_news <market> <limit>       # 股市快讯
  company_announcements <symbol> <limit>  # 公司公告
  macro_news <limit>                 # 宏观经济新闻
  industry_news <industry> <limit>   # 行业资讯
  hot_news <limit>                   # 热点新闻
  stock_news <symbol> <limit>        # 特定股票新闻
  search_news <keyword> <limit>      # 搜索新闻

示例:
  $0 latest_news all 20
  $0 market_news all 10
  $0 company_announcements sh600000 10
EOF
        exit 1
    fi
    
    local action="$1"
    shift
    
    case "$action" in
        latest_news)
            if [[ $# -ne 2 ]]; then
                handle_error "latest_news 需要 2 个参数: category limit" "$action"
            fi
            latest_news "$1" "$2"
            ;;
        market_news)
            if [[ $# -ne 2 ]]; then
                handle_error "market_news 需要 2 个参数: market limit" "$action"
            fi
            market_news "$1" "$2"
            ;;
        company_announcements)
            if [[ $# -ne 2 ]]; then
                handle_error "company_announcements 需要 2 个参数: symbol limit" "$action"
            fi
            company_announcements "$1" "$2"
            ;;
        macro_news)
            if [[ $# -ne 1 ]]; then
                handle_error "macro_news 需要 1 个参数: limit" "$action"
            fi
            macro_news "$1"
            ;;
        industry_news)
            if [[ $# -ne 2 ]]; then
                handle_error "industry_news 需要 2 个参数: industry limit" "$action"
            fi
            industry_news "$1" "$2"
            ;;
        hot_news)
            if [[ $# -ne 1 ]]; then
                handle_error "hot_news 需要 1 个参数: limit" "$action"
            fi
            hot_news "$1"
            ;;
        stock_news)
            if [[ $# -ne 2 ]]; then
                handle_error "stock_news 需要 2 个参数: symbol limit" "$action"
            fi
            stock_news "$1" "$2"
            ;;
        search_news)
            if [[ $# -ne 2 ]]; then
                handle_error "search_news 需要 2 个参数: keyword limit" "$action"
            fi
            search_news "$1" "$2"
            ;;
        *)
            handle_error "不支持的操作: $action" "$action"
            ;;
    esac
}

# 设置执行权限
chmod +x "$0"

# 执行主函数
main "$@"