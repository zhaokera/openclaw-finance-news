#!/bin/bash

# OpenClaw Finance News Skill 测试脚本

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/finance_news.sh"
TEST_OUTPUT_DIR="$SCRIPT_DIR/test_output"
LOG_FILE="$SCRIPT_DIR/test.log"

# 创建测试输出目录
mkdir -p "$TEST_OUTPUT_DIR"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# 测试函数
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_success="$3"
    
    log "开始测试: $test_name"
    
    local output_file="$TEST_OUTPUT_DIR/${test_name}.json"
    local success=true
    
    # 执行命令
    if $command > "$output_file" 2>&1; then
        if [[ "$expected_success" == "true" ]]; then
            log "✓ 测试通过: $test_name"
        else
            log "✗ 测试失败: $test_name (期望失败但成功了)"
            success=false
        fi
    else
        if [[ "$expected_success" == "false" ]]; then
            log "✓ 测试通过: $test_name (正确处理了错误)"
        else
            log "✗ 测试失败: $test_name (命令执行失败)"
            success=false
        fi
    fi
    
    # 验证JSON格式
    if [[ "$success" == "true" ]] && [[ "$expected_success" == "true" ]]; then
        if ! python3 -m json.tool "$output_file" > /dev/null 2>&1; then
            log "✗ JSON格式验证失败: $test_name"
            success=false
        else
            log "✓ JSON格式验证通过: $test_name"
        fi
    fi
    
    return 0
}

# 清理缓存
cleanup_cache() {
    log "清理缓存..."
    rm -rf "$SCRIPT_DIR/cache"
    mkdir -p "$SCRIPT_DIR/cache"
}

# 测试1: 实时财经新闻
test_latest_news() {
    cleanup_cache
    run_test "latest_news_all" "$MAIN_SCRIPT latest_news all 5" "true"
    run_test "latest_news_market" "$MAIN_SCRIPT latest_news market 3" "true"
}

# 测试2: 股市快讯
test_market_news() {
    cleanup_cache
    run_test "market_news_all" "$MAIN_SCRIPT market_news all 5" "true"
}

# 测试3: 公司公告
test_company_announcements() {
    cleanup_cache
    run_test "company_announcements_valid" "$MAIN_SCRIPT company_announcements sh600000 3" "true"
    run_test "company_announcements_invalid" "$MAIN_SCRIPT company_announcements invalid_code 3" "false"
}

# 测试4: 宏观经济新闻
test_macro_news() {
    cleanup_cache
    run_test "macro_news" "$MAIN_SCRIPT macro_news 5" "true"
}

# 测试5: 行业资讯
test_industry_news() {
    cleanup_cache
    run_test "industry_news_tech" "$MAIN_SCRIPT industry_news 互联网 3" "true"
    run_test "industry_news_finance" "$MAIN_SCRIPT industry_news 金融 3" "true"
}

# 测试6: 热点新闻
test_hot_news() {
    cleanup_cache
    run_test "hot_news" "$MAIN_SCRIPT hot_news 5" "true"
}

# 测试7: 特定股票新闻
test_stock_news() {
    cleanup_cache
    run_test "stock_news_valid" "$MAIN_SCRIPT stock_news sz000001 3" "true"
    run_test "stock_news_invalid" "$MAIN_SCRIPT stock_news invalid_code 3" "false"
}

# 测试8: 搜索新闻
test_search_news() {
    cleanup_cache
    run_test "search_news_chip" "$MAIN_SCRIPT search_news 芯片 3" "true"
    run_test "search_news_empty" "$MAIN_SCRIPT search_news '' 3" "false"
}

# 测试9: 错误处理
test_error_handling() {
    cleanup_cache
    run_test "invalid_action" "$MAIN_SCRIPT invalid_action" "false"
    run_test "missing_params" "$MAIN_SCRIPT latest_news" "false"
}

# 运行所有测试
run_all_tests() {
    log "开始运行所有测试..."
    
    test_latest_news
    test_market_news
    test_company_announcements
    test_macro_news
    test_industry_news
    test_hot_news
    test_stock_news
    test_search_news
    test_error_handling
    
    log "所有测试完成!"
    log "测试结果保存在: $TEST_OUTPUT_DIR/"
    log "详细日志: $LOG_FILE"
}

# 主函数
main() {
    if [[ $# -eq 0 ]]; then
        run_all_tests
    else
        case "$1" in
            latest_news)
                test_latest_news
                ;;
            market_news)
                test_market_news
                ;;
            company_announcements)
                test_company_announcements
                ;;
            macro_news)
                test_macro_news
                ;;
            industry_news)
                test_industry_news
                ;;
            hot_news)
                test_hot_news
                ;;
            stock_news)
                test_stock_news
                ;;
            search_news)
                test_search_news
                ;;
            error_handling)
                test_error_handling
                ;;
            *)
                echo "用法: $0 [test_name]"
                echo "可用的测试: latest_news, market_news, company_announcements, macro_news, industry_news, hot_news, stock_news, search_news, error_handling"
                exit 1
                ;;
        esac
    fi
}

# 设置执行权限
chmod +x "$0"

# 执行主函数
main "$@"