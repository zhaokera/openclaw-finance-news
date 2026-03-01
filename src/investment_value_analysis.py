#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
财经新闻投资价值分析模块
基于邱国鹭《投资中最简单的事》和李杰《股市进阶之道》的投资理念
"""

import json
from datetime import datetime
from typing import Dict, Any, List

class InvestmentValueAnalyzer:
    def __init__(self):
        # 邱国鹭四要素权重
        self.qiu_weights = {
            'valuation': 0.3,      # 估值
            'quality': 0.3,        # 品质  
            'timing': 0.2,         # 时机
            'position': 0.2        # 仓位
        }
        
        # 李杰能力圈相关关键词
        self.li_keywords = {
            'business_model': ['商业模式', '护城河', '竞争优势', '行业地位'],
            'management': ['管理层', '治理结构', '股东利益', '诚信'],
            'financial_health': ['现金流', '负债率', 'ROE', '毛利率']
        }
    
    def analyze_news_investment_value(self, news_title: str, news_content: str, 
                                   news_category: str, publish_time: str) -> Dict[str, Any]:
        """
        分析新闻的投资价值
        """
        analysis_result = {
            "title": news_title,
            "category": news_category,
            "publish_time": publish_time,
            "investment_value_score": 0.0,
            "analysis": {
                "policy_impact": self._analyze_policy_impact(news_title, news_content),
                "industry_rotation": self._analyze_industry_rotation(news_category),
                "fundamental_change": self._analyze_fundamental_change(news_title, news_content),
                "long_term_vs_short_term": self._classify_long_term_impact(news_title, news_content),
                "investment_opportunity": self._identify_investment_opportunity(news_title, news_content)
            },
            "recommendations": []
        }
        
        # 计算综合投资价值评分
        policy_score = analysis_result["analysis"]["policy_impact"]["score"]
        industry_score = analysis_result["analysis"]["industry_rotation"]["score"] 
        fundamental_score = analysis_result["analysis"]["fundamental_change"]["score"]
        long_term_score = analysis_result["analysis"]["long_term_vs_short_term"]["score"]
        
        # 加权计算总分 (0-100分)
        total_score = (policy_score * 0.3 + industry_score * 0.2 + 
                      fundamental_score * 0.4 + long_term_score * 0.1)
        analysis_result["investment_value_score"] = round(total_score, 2)
        
        # 生成投资建议
        analysis_result["recommendations"] = self._generate_recommendations(analysis_result)
        
        return analysis_result
    
    def _analyze_policy_impact(self, title: str, content: str) -> Dict[str, Any]:
        """
        分析政策影响（邱国鹭强调的政策导向）
        """
        policy_keywords = ['政策', '改革', '监管', '补贴', '税收', '产业政策', '十四五', '规划']
        impact_score = 0
        impact_type = "中性"
        
        # 检测政策相关关键词
        text = title + " " + content
        policy_count = sum(1 for keyword in policy_keywords if keyword in text)
        
        if policy_count > 0:
            # 判断政策影响方向
            positive_keywords = ['支持', '利好', '促进', '鼓励', '减税', '补贴']
            negative_keywords = ['限制', '打压', '监管', '处罚', '加税']
            
            positive_count = sum(1 for keyword in positive_keywords if keyword in text)
            negative_count = sum(1 for keyword in negative_keywords if keyword in text)
            
            if positive_count > negative_count:
                impact_score = min(80 + policy_count * 5, 100)
                impact_type = "利好"
            elif negative_count > positive_count:
                impact_score = max(20 - policy_count * 5, 0)
                impact_type = "利空"
            else:
                impact_score = 50
                impact_type = "中性"
        else:
            impact_score = 30  # 无政策影响，默认较低分
        
        return {
            "score": impact_score,
            "type": impact_type,
            "keywords_found": [kw for kw in policy_keywords if kw in text],
            "description": f"政策影响分析: {impact_type} ({policy_count}个政策关键词)"
        }
    
    def _analyze_industry_rotation(self, category: str) -> Dict[str, Any]:
        """
        分析行业轮动信号
        """
        hot_industries = ['新能源', '半导体', '医药', '消费', '科技', '金融', '地产']
        
        if any(industry in category for industry in hot_industries):
            score = 75
            rotation_signal = "热门行业"
        else:
            score = 45
            rotation_signal = "一般行业"
        
        return {
            "score": score,
            "signal": rotation_signal,
            "description": f"行业轮动分析: {rotation_signal}"
        }
    
    def _analyze_fundamental_change(self, title: str, content: str) -> Dict[str, Any]:
        """
        分析基本面变化
        """
        fundamental_keywords = ['业绩', '利润', '营收', '增长', '毛利率', 'ROE', '现金流', '负债']
        text = title + " " + content
        
        fundamental_count = sum(1 for keyword in fundamental_keywords if keyword in text)
        
        if fundamental_count > 0:
            # 检测正面/负面词汇
            positive_fundamental = ['增长', '提升', '改善', '超预期', '创新高']
            negative_fundamental = ['下滑', '下降', '亏损', '不及预期', '恶化']
            
            positive_count = sum(1 for keyword in positive_fundamental if keyword in text)
            negative_count = sum(1 for keyword in negative_fundamental if keyword in text)
            
            if positive_count > negative_count:
                score = min(85 + fundamental_count * 3, 100)
            elif negative_count > positive_count:
                score = max(15 - fundamental_count * 3, 0)
            else:
                score = 60 + fundamental_count * 2
        else:
            score = 40  # 无基本面信息
        
        return {
            "score": score,
            "keywords_found": [kw for kw in fundamental_keywords if kw in text],
            "description": f"基本面变化分析: {fundamental_count}个基本面关键词"
        }
    
    def _classify_long_term_impact(self, title: str, content: str) -> Dict[str, Any]:
        """
        分类长期vs短期影响
        """
        long_term_keywords = ['战略', '长期', '未来', '规划', '布局', '转型', '创新', '研发']
        short_term_keywords = ['短期', '临时', '季度', '月度', '波动', '调整']
        
        text = title + " " + content
        long_term_count = sum(1 for keyword in long_term_keywords if keyword in text)
        short_term_count = sum(1 for keyword in short_term_keywords if keyword in text)
        
        if long_term_count > short_term_count:
            score = 80
            impact_type = "长期价值"
        elif short_term_count > long_term_count:
            score = 40
            impact_type = "短期波动"
        else:
            score = 60
            impact_type = "混合影响"
        
        return {
            "score": score,
            "type": impact_type,
            "description": f"影响时间维度: {impact_type}"
        }
    
    def _identify_investment_opportunity(self, title: str, content: str) -> Dict[str, Any]:
        """
        识别投资机会
        """
        opportunity_keywords = ['机会', '潜力', '低估', '价值', '买入', '增持', '推荐']
        risk_keywords = ['风险', '谨慎', '减持', '卖出', '高估', '泡沫']
        
        text = title + " " + content
        opportunity_count = sum(1 for keyword in opportunity_keywords if keyword in text)
        risk_count = sum(1 for keyword in risk_keywords if keyword in text)
        
        if opportunity_count > risk_count:
            opportunity_type = "买入机会"
            confidence = "高"
        elif risk_count > opportunity_count:
            opportunity_type = "规避风险"
            confidence = "高"
        else:
            opportunity_type = "观望"
            confidence = "中"
        
        return {
            "type": opportunity_type,
            "confidence": confidence,
            "description": f"投资机会识别: {opportunity_type} (信心: {confidence})"
        }
    
    def _generate_recommendations(self, analysis_result: Dict[str, Any]) -> List[str]:
        """
        生成投资建议
        """
        recommendations = []
        score = analysis_result["investment_value_score"]
        policy_impact = analysis_result["analysis"]["policy_impact"]["type"]
        fundamental_change = analysis_result["analysis"]["fundamental_change"]["score"]
        long_term_impact = analysis_result["analysis"]["long_term_vs_short_term"]["type"]
        opportunity = analysis_result["analysis"]["investment_opportunity"]["type"]
        
        # 基于邱国鹭的四要素生成建议
        if score >= 80:
            recommendations.append("【强烈关注】该新闻具有很高的投资价值，建议深入研究")
        elif score >= 60:
            recommendations.append("【值得关注】该新闻具有一定投资价值，可纳入观察")
        else:
            recommendations.append("【一般关注】该新闻投资价值有限，保持关注即可")
        
        # 政策导向建议
        if policy_impact == "利好":
            recommendations.append("【政策利好】符合邱国鹭强调的政策导向投资原则")
        elif policy_impact == "利空":
            recommendations.append("【政策风险】需谨慎对待，可能影响行业或公司基本面")
        
        # 基本面建议
        if fundamental_change >= 70:
            recommendations.append("【基本面改善】符合价值投资的核心要求")
        elif fundamental_change <= 30:
            recommendations.append("【基本面恶化】需警惕价值陷阱")
        
        # 长期价值建议
        if long_term_impact == "长期价值":
            recommendations.append("【长期视角】符合李杰强调的能力圈和长期持有理念")
        
        # 投资机会建议
        if opportunity == "买入机会":
            recommendations.append("【投资机会】可考虑在合适价位布局")
        elif opportunity == "规避风险":
            recommendations.append("【风险提示】建议规避相关投资")
        
        return recommendations[:5]  # 最多返回5条建议

def main():
    """测试函数"""
    analyzer = InvestmentValueAnalyzer()
    
    # 测试新闻
    test_news = {
        "title": "国家出台新能源汽车补贴政策，行业迎来重大利好",
        "content": "财政部今日宣布延长新能源汽车补贴政策至2025年，同时提高补贴标准。这将显著改善相关企业的盈利能力和现金流状况。",
        "category": "政策新闻",
        "publish_time": "2026-03-01 10:00:00"
    }
    
    result = analyzer.analyze_news_investment_value(
        test_news["title"], 
        test_news["content"], 
        test_news["category"], 
        test_news["publish_time"]
    )
    
    print(json.dumps(result, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()