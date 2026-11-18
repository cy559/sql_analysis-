CREATE DATABASE IF NOT EXISTS tmall_analysis DEFAULT CHARACTER SET utf8mb4;
USE tmall_analysis;

-- 用户表
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    gender TINYINT COMMENT '1男2女',
    age INT,
    register_date DATE,
    city_level TINYINT COMMENT '1一线2新一线3二线4其他'
);

-- 商品表
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    category VARCHAR(50) COMMENT '类目',
    brand VARCHAR(50),
    price DECIMAL(10,2),
    cost DECIMAL(10,2)
);

-- 订单主表
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    user_id INT,
    create_time DATETIME,
    pay_time DATETIME,
    pay_status TINYINT COMMENT '0未付1已付2退款',
    pay_method TINYINT COMMENT '1支付宝2微信3银行卡',
    receiver_province VARCHAR(20),
    receiver_city VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- 订单明细表
DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(20),
    product_id INT,
    quantity INT,
    item_price DECIMAL(10,2),
    discount DECIMAL(10,2),
    refund_status TINYINT COMMENT '0无1部分2全额',
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE INDEX idx_orders_paytime ON orders(pay_time);
CREATE INDEX idx_orders_province ON orders(receiver_province);
CREATE INDEX idx_items_order ON order_items(order_id);
