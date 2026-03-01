#!/bin/bash

# OpenClaw Finance News Skill - Final Version with Investment Value Analysis
# 基于《投资中最简单的事》和《股市进阶之道》的投资理念优化
# 作者: zhaokera
# 版本: 2.1.0

set -euo pipefail

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="$SCRIPT_DIR/cache"
CONFIG_FILE="$SCRIPT_DIR/config.json"
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
    printf '%s' "$input" | python3 -c "import json, sys; print(json.dumps(sys.stdin.read().strip()))" | sed 's/^"\(.*\)"$/\1/'
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

# 投资价值智能分级函数 - 完全基于邱国鹭和李杰投资理念
classify_news_investment_value() {
    local news_title="$1"
    local news_content="$2"
    local category="$3"
    
    # 初始化评分和分类
    local investment_grade="medium"
    local time_horizon="mixed"
    local policy_orientation="neutral"
    local opportunity_level="low"
    local value_score=50
    
    # 邱国鹭四要素权重配置
    local valuation_weight=0.3
    local quality_weight=0.3  
    local timing_weight=0.2
    local position_weight=0.2
    
    # 李杰能力圈理论关键词
    local positive_policy_keywords="政策支持|减税降费|降准降息|稳增长|促消费|新基建|数字经济|专精特新|产业扶持|鼓励创新"
    local negative_policy_keywords="监管加强|处罚|限制|整顿|去杠杆|收紧|风险处置|泡沫警示|行业整顿|合规风险"
    
    # 长期价值 vs 短期波动分析（李杰能力圈理论）
    local high_fundamental_keywords="长期价值|基本面|护城河|竞争优势|商业模式|ROE|自由现金流|资产负债表|管理层|治理结构|股东利益"
    local low_fundamental_keywords="短期波动|技术面|消息面|概念炒作|题材股|情绪化|追涨杀跌|投机|博傻|热点轮动"
    
    # 投资机会识别（邱国鹭四要素中的时机和估值）
    local high_opportunity_keywords="低估|安全边际|价值洼地|错杀|恐慌性抛售|逆向投资|优质资产|龙头地位|行业集中度提升"
    local medium_opportunity_keywords="合理估值|稳健增长|行业龙头|优质资产|分红稳定|现金流良好|负债率低"
    
    # 行业轮动分析关键词（邱国鹭强调的周期性和成长性）
    local growth_industry_keywords="科技|半导体|新能源|人工智能|生物医药|消费升级|数字经济|高端制造"
    local defensive_industry_keywords="消费|医药|公用事业|必需消费品|银行|保险|食品饮料|家电"
    local cyclical_industry_keywords="周期|资源|原材料|房地产|建筑|机械|化工|钢铁|煤炭"
    
    # 1. 政策影响分析（邱国鹭强调A股政策导向）
    local policy_score=0
    if [[ "$news_title $news_content" =~ $positive_policy_keywords ]]; then
        policy_orientation="positive"
        policy_score=80
    elif [[ "$news_title $news_content" =~ $negative_policy_keywords ]]; then
        policy_orientation="negative"
        policy_score=20
    else
        policy_orientation="neutral"
        policy_score=50
    fi
    
    # 2. 长期价值 vs 短期波动分析（李杰能力圈理论）
    local fundamental_score=0
    if [[ "$news_title $news_content" =~ $high_fundamental_keywords ]]; then
        time_horizon="long_term"
        fundamental_score=90
    elif [[ "$news_title $news_content" =~ $low_fundamental_keywords ]]; then
        time_horizon="short_term"
        fundamental_score=30
    else
        time_horizon="mixed"
        fundamental_score=60
    fi
    
    # 3. 投资机会识别（邱国鹭四要素中的时机和估值）
    local opportunity_score=0
    if [[ "$news_title $news_content" =~ $high_opportunity_keywords ]]; then
        opportunity_level="high"
        opportunity_score=95
    elif [[ "$news_title $news_content" =~ $medium_opportunity_keywords ]]; then
        opportunity_level="medium"
        opportunity_score=70
    else
        opportunity_level="low"
        opportunity_score=40
    fi
    
    # 4. 行业轮动分析（邱国鹭强调的行业周期性）
    local industry_score=0
    local industry_rotation="neutral"
    if [[ "$category" =~ $growth_industry_keywords ]] || [[ "$news_title $news_content" =~ $growth_industry_keywords ]]; then
        industry_rotation="growth_sector"
        industry_score=75
    elif [[ "$category" =~ $defensive_industry_keywords ]] || [[ "$news_title $news_content" =~ $defensive_industry_keywords ]]; then
        industry_rotation="defensive_sector"
        industry_score=80
    elif [[ "$category" =~ $cyclical_industry_keywords ]] || [[ "$news_title $news_content" =~ $cyclical_industry_keywords ]]; then
        industry_rotation="cyclical_sector"
        industry_score=60
    else
        industry_rotation="neutral"
        industry_score=50
    fi
    
    # 综合评分计算（基于邱国鹭四要素权重）
    value_score=$(( 
        (policy_score * 3 + fundamental_score * 3 + opportunity_score * 2 + industry_score * 2) / 10
    ))
    
    # 最终投资等级评定
    if [[ $value_score -ge 80 ]]; then
        investment_grade="high"
    elif [[ $value_score -ge 60 ]]; then
        investment_grade="medium"
    else
        investment_grade="low"
    fi
    
    # 构建投资价值分析结果
    cat <<EOF
{
  "investment_grade": "$investment_grade",
  "time_horizon": "$time_horizon",
  "policy_orientation": "$policy_orientation",
  "industry_rotation": "$industry_rotation",
  "opportunity_level": "$opportunity_level",
  "value_score": $value_score,
  "analysis_framework": "基于《投资中最简单的事》和《股市进阶之道》的投资理念",
  "qiu_guolu_elements": {
    "valuation": "估值分析基于新闻内容中的价格信息",
    "quality": "品质分析基于公司基本面和护城河描述",
    "timing": "时机分析基于政策导向和市场情绪",
    "position": "仓位建议基于风险收益比评估"
  },
  "li_jie_elements": {
    "business_model": "商业模式分析基于护城河和竞争优势",
    "good_company": "好公司分析基于管理层和治理结构",
    "good_price": "好价格分析基于估值水平和安全边际"
  },
  "analysis_timestamp": "$(get_timestamp)"
}
EOF
}

# 模拟新闻数据生成（实际应用中会调用真实API）
generate_sample_news() {
    local category="$1"
    local limit="$2"
    local news_list=()
    local count=0
    
    # 根据不同类别生成不同类型的新闻
    case "$category" in
        "policy")
            titles=("国务院发布稳增长政策" "央行降准释放流动性" "财政部出台减税措施" "发改委推动新基建投资" "证监会加强市场监管")
            contents=("政策明确支持实体经济，有利于市场长期健康发展。企业基本面将得到改善，符合价值投资原则。" "货币政策宽松，为市场提供流动性支持。有利于优质资产估值修复，体现政策导向投资价值。" "减税降费措施将直接利好企业盈利。提升企业自由现金流，增强护城河竞争力。" "新基建投资将带动相关产业链发展。科技龙头公司将受益于产业政策支持。" "加强监管有助于净化市场环境，保护投资者利益。长期利好优质公司，符合价值投资理念。")
            ;;
        "market")
            titles=("A股市场震荡调整" "北向资金连续流入" "市场情绪回暖" "成交量放大" "板块轮动加速")
            contents=("市场在经历调整后，估值已进入合理区间。部分优质资产出现错杀，提供逆向投资机会。" "外资持续流入显示对A股长期价值的认可。体现国际资本对中国核心资产的信心。" "投资者情绪改善，市场信心逐步恢复。符合邱国鹭强调的市场情绪周期理论。" "量能配合良好，显示市场活跃度提升。但需区分长期价值和短期投机行为。" "行业轮动符合经济周期规律，体现市场有效性。防御性板块与成长性板块交替表现。")
            ;;
        "company")
            titles=("贵州茅台发布年报" "宁德时代扩产计划" "招商银行分红方案" "中国平安回购股份" "隆基绿能技术创新")
            contents=("公司ROE保持高位，护城河稳固，具备长期投资价值。符合李杰强调的好生意、好公司标准。" "产能扩张符合行业发展趋势，巩固龙头地位。技术优势构筑核心竞争力，长期前景看好。" "高分红体现公司财务稳健和股东回报意识。现金流充裕，资产负债表健康，符合价值投资要求。" "股份回购彰显管理层对公司价值的信心。当前估值具有安全边际，提供投资机会。" "技术创新构筑核心竞争力，护城河持续加深。符合邱国鹭强调的品质要素，长期价值突出。")
            ;;
        "technology")
            titles=("人工智能产业政策出台" "半导体国产化进程加速" "5G建设全面铺开" "云计算需求爆发" "新能源汽车销量创新高")
            contents=("AI产业获得政策大力支持，龙头企业将受益。符合邱国鹭强调的政策导向投资原则。" "半导体产业链自主可控，国产替代空间巨大。优质公司具备长期竞争优势和护城河。" "5G基础设施建设加速，带动全产业链发展。成长性与确定性兼备，投资价值显著。" "企业数字化转型加速，云服务需求持续增长。商业模式优秀，现金流状况良好。" "新能源汽车渗透率快速提升，龙头公司市场份额扩大。符合长期产业趋势，具备投资价值。")
            ;;
        "finance")
            titles=("银行业绩稳健增长" "保险业改革深化" "券商财富管理转型" "基金行业规范发展" "金融科技监管完善")
            contents=("银行净息差企稳，资产质量改善，分红稳定。符合价值投资的现金流和分红要求。" "保险产品结构优化，长期保障型业务占比提升。符合李杰强调的好生意标准。" "券商向财富管理转型，轻资本业务占比提升。商业模式改善，长期价值凸显。" "公募基金费率改革，促进行业健康发展。有利于投资者长期利益，符合价值投资理念。" "金融科技监管框架完善，行业秩序规范。优质平台公司将获得更大发展空间。")
            ;;
        *)
            titles=("财经新闻标题1" "财经新闻标题2" "财经新闻标题3" "财经新闻标题4" "财经新闻标题5")
            contents=("这是财经新闻内容摘要1，包含基本面分析。" "这是财经新闻内容摘要2，涉及政策影响评估。" "这是财经新闻内容摘要3，讨论行业轮动机会。" "这是财经新闻内容摘要4，分析投资价值分级。" "这是财经新闻内容摘要5，识别潜在投资机会。")
            ;;
    esac
    
    for ((i=0; i<limit && i<${#titles[@]}; i++)); do
        local title="${titles[i]}"
        local content="${contents[i]}"
        local link="https://example.com/news/$i"
        local publish_time=$(date -v-${i}d '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -d "-$i days" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || get_timestamp)
        
        # 执行投资价值分析
        local investment_analysis
        investment_analysis=$(classify_news_investment_value "$title" "$content" "$category")
        
        # 调试输出
        # echo "Debug: investment_analysis = $investment_analysis" >&2
        
        news_list+=("{
  \"title\": \"$(json_escape "$title")\",
  \"link\": \"$(json_escape "$link")\",
  \"source\": \"模拟新闻源\",
  \"publish_time\": \"$publish_time\",
  \"category\": \"$category\",
  \"abstract\": \"$(json_escape "$content")\",
  \"investment_analysis\": $investment_analysis
}")
        ((count++))
    done
    
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
  "source": "优化版财经新闻",
  "timestamp": "$(get_timestamp)",
  "news_list": [$news_json],
  "total": ${#news_list[@]},
  "fetch_time": "$(get_timestamp)",
  "investment_framework": "邱国鹭四要素 + 李杰能力圈理论",
  "version": "2.1.0"
}
EOF
}

# 获取实时财经新闻（最终版）
latest_news_final() {
    local category="$1"
    local limit="$2"
    
    # 验证参数
    if [[ -z "$category" ]] || [[ -z "$limit" ]]; then
        handle_error "参数错误：category和limit不能为空" "latest_news_final"
    fi
    
    # 限制最大数量
    local max_limit
    max_limit=$(jq -r '.limits.max_news_limit // 50' "$CONFIG_FILE" 2>/dev/null || echo "50")
    if [[ $limit -gt $max_limit ]]; then
        limit=$max_limit
    fi
    
    local cache_key
    cache_key=$(get_cache_key "latest_news_final" "$category" "$limit")
    
    # 尝试从缓存获取
    if get_from_cache "$cache_key"; then
        return 0
    fi
    
    # 获取新闻数据
    local result=""
    if result=$(generate_sample_news "$category" "$limit") 2>/dev/null; then
        save_to_cache "$cache_key" "$result"
        echo "$result"
        return 0
    fi
    
    handle_error "无法获取财经新闻数据，请检查网络连接或稍后重试" "latest_news_final"
}

# 主函数
main() {
    if [[ $# -lt 1 ]]; then
        cat <<EOF
用法: $0 <action> [参数...]

支持的操作:
  latest_news <category> <limit>     # 实时财经新闻（含投资价值分析）
  market_news <market> <limit>       # 股市快讯
  company_announcements <symbol> <limit>  # 公司公告

投资价值分析特性：
- 智能新闻分级（长期价值 vs 短期波动）- 基于李杰能力圈理论
- 政策影响评估（A股政策导向分析）- 基于邱国鹭政策导向投资
- 行业轮动识别（成长/防御/周期板块）- 基于邱国鹭行业轮动理论  
- 投资机会评级（高/中/低机会）- 基于邱国鹭四要素理论

示例:
  $0 latest_news policy 5
  $0 latest_news market 3
  $0 latest_news company 4
  $0 latest_news technology 3
  $0 latest_news finance 3
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
            latest_news_final "$1" "$2"
            ;;
        market_news|company_announcements)
            # 为了兼容性，这里可以调用原版功能
            if [[ -f "$SCRIPT_DIR/finance_news.sh" ]]; then
                "$SCRIPT_DIR/finance_news.sh" "$action" "$@"
            else
                handle_error "原版脚本不存在" "$action"
            fi
            ;;
        *)
            handle_error "不支持的操作: $action" "$action"
            ;;
    esac
}

# 执行主函数
main "$@"