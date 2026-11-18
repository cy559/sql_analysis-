USE tmall_analysis;

-- 1. 支付转化率（含未支付）
SELECT 
    COUNT(*) AS 总下单,
    SUM(CASE WHEN pay_status=1 THEN 1 ELSE 0 END) AS 已支付,
    SUM(CASE WHEN pay_status=2 THEN 1 ELSE 0 END) AS 已退款,
    CONCAT(ROUND(SUM(CASE WHEN pay_status=1 THEN 1 ELSE 0 END)*100.0/COUNT(*),1),'%') AS 支付转化率
FROM orders;

-- 2. GMV / 净GMV / 客单价（关联明细算实付）
SELECT 
    SUM(oi.quantity*oi.item_price-oi.discount) AS 实际GMV,
    SUM(CASE WHEN oi.refund_status=2 THEN oi.quantity*oi.item_price-oi.discount ELSE 0 END) AS 退款额,
    SUM(oi.quantity*oi.item_price-oi.discount) - SUM(CASE WHEN oi.refund_status=2 THEN oi.quantity*oi.item_price-oi.discount ELSE 0 END) AS 净GMV,
    ROUND(SUM(oi.quantity*oi.item_price-oi.discount) / COUNT(DISTINCT o.order_id),2) AS 客单价
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.pay_status IN (1,2);

-- 3. 省份TOP5 + 城市分布
SELECT 
    o.receiver_province,
    o.receiver_city,
    COUNT(DISTINCT o.order_id) AS 订单数,
    SUM(oi.quantity*oi.item_price-oi.discount) AS GMV,
    ROUND(SUM(oi.quantity*oi.item_price-oi.discount)/COUNT(DISTINCT o.order_id),2) AS 客单价
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.pay_status IN (1,2)
GROUP BY o.receiver_province,o.receiver_city
ORDER BY GMV DESC
LIMIT 10;

-- 4. 类目销售排行（关联商品表）
SELECT 
    p.category,
    p.brand,
    SUM(oi.quantity) AS 销量,
    SUM(oi.quantity*oi.item_price-oi.discount) AS 销售额,
    ROUND(SUM((oi.quantity*oi.item_price-oi.discount)-oi.quantity*p.cost)/SUM(oi.quantity*oi.item_price-oi.discount)*100,1) AS 毛利率
FROM order_items oi
JOIN products p ON oi.product_id=p.product_id
JOIN orders o ON oi.order_id=o.order_id
WHERE o.pay_status IN (1,2) AND oi.refund_status!=2
GROUP BY p.category,p.brand
ORDER BY 销售额 DESC;

-- 5. 用户画像：性别/城市等级消费力
SELECT 
    u.gender,
    u.city_level,
    COUNT(DISTINCT o.order_id) AS 订单数,
    ROUND(AVG(oi.quantity*oi.item_price-oi.discount),2) AS 平均客单,
    SUM(oi.quantity*oi.item_price-oi.discount) AS 总消费
FROM users u
JOIN orders o ON u.user_id=o.user_id
JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.pay_status IN (1,2)
GROUP BY u.gender,u.city_level
ORDER BY 总消费 DESC;

-- 6. 每日趋势（近3天）
SELECT 
    DATE(o.create_time) AS 日期,
    COUNT(DISTINCT o.order_id) AS 下单量,
    SUM(CASE WHEN o.pay_status=1 THEN 1 ELSE 0 END) AS 支付量,
    SUM(oi.quantity*oi.item_price-oi.discount) AS GMV
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id
GROUP BY DATE(o.create_time)
ORDER BY 日期;

-- 7. 退款率分析
SELECT 
    CONCAT(ROUND(SUM(CASE WHEN oi.refund_status=2 THEN 1 ELSE 0 END)*100.0/COUNT(*),1),'%') AS 订单退款率,
    CONCAT(ROUND(SUM(CASE WHEN oi.refund_status IN (1,2) THEN oi.quantity*oi.item_price-oi.discount ELSE 0 END)*100.0/SUM(oi.quantity*oi.item_price-oi.discount),1),'%') AS 金额退款率
FROM orders o
JOIN order_items oi ON o.order_id=oi.order_id
WHERE o.pay_status IN (1,2);
