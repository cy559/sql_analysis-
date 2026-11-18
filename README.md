# 天猫订单 MySQL 分析

模拟真实电商订单系统（用户/商品/订单/明细 4表），多表关联完成核心业务指标计算。

## 文件说明
- `01_create_tables.sql` — 建表（含外键、索引）
- `02_insert_data.sql` — 脱敏示例数据（20用户/15商品/30订单）
- `03_core_queries.sql` — 7类核心分析（转化率/GMV/类目/画像/趋势/退款）

## 快速运行
\`\`\`bash
mysql -u root -p < 01_create_tables.sql
mysql -u root -p < 02_insert_data.sql
mysql -u root -p < 03_core_queries.sql
\`\`\`

## 分析维度
| 指标 | 说明 |
|------|------|
| 支付转化率 | 已付/总下单 |
| GMV/净GMV/客单价 | 关联明细算实付，扣退款 |
| 地域分布 | 省份+城市 TOP10 |
| 类目品牌排行 | 销量/销售额/毛利率 |
| 用户画像 | 性别×城市等级消费力 |
| 每日趋势 | 近3天下单/支付/GMV |
| 退款率 | 订单维度+金额维度 |

## 技术亮点
- 4表关联（users/products/orders/order_items）
- 实付金额 = 数量×单价−折扣，扣退款算净GMV
- 索引优化（支付时间、省份、订单ID）
- 与 Python 版项目形成「清洗+查询」闭环
