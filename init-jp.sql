-- GitHub Copilot MySQL MCP Demo 用の初期データベース設定

CREATE DATABASE IF NOT EXISTS demo_db;
USE demo_db;

-- ユーザーテーブル
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    age INT,
    department VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 商品テーブル
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    category VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 注文テーブル
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id INT,
    quantity INT NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- サンプルユーザーデータ
INSERT INTO users (name, email, age, department) VALUES 
('田中太郎', 'tanaka@example.com', 28, '開発部'),
('佐藤花子', 'sato@example.com', 32, 'マーケティング部'),
('鈴木一郎', 'suzuki@example.com', 25, '営業部'),
('高橋美咲', 'takahashi@example.com', 29, 'デザイン部'),
('山田健太', 'yamada@example.com', 35, '開発部');

-- サンプル商品データ
INSERT INTO products (name, price, stock, category, description) VALUES 
('MacBook Pro', 199800.00, 10, 'ノートPC', '最新のM3チップ搭載のノートパソコン'),
('ワイヤレスマウス', 2980.00, 50, '周辺機器', '高精度なワイヤレスマウス'),
('メカニカルキーボード', 12800.00, 25, '周辺機器', '打鍵感の良いメカニカルキーボード'),
('4Kモニター', 35900.00, 15, 'モニター', '27インチ4K解像度モニター'),
('Webカメラ', 8900.00, 30, '周辺機器', 'フルHD対応Webカメラ'),
('スマートフォン', 89800.00, 20, 'スマートフォン', '最新のフラッグシップモデル'),
('タブレット', 45600.00, 18, 'タブレット', '10インチタブレット'),
('ヘッドフォン', 15400.00, 40, 'オーディオ', 'ノイズキャンセリング機能付き');

-- サンプル注文データ
INSERT INTO orders (user_id, product_id, quantity, total_price, status) VALUES 
(1, 1, 1, 199800.00, 'completed'),
(2, 2, 2, 5960.00, 'completed'),
(3, 3, 1, 12800.00, 'pending'),
(1, 4, 1, 35900.00, 'shipped'),
(4, 5, 1, 8900.00, 'completed'),
(5, 6, 1, 89800.00, 'pending'),
(2, 7, 1, 45600.00, 'shipped'),
(3, 8, 1, 15400.00, 'completed');

-- データの確認
SELECT 'Users Table:' as info;
SELECT * FROM users;

SELECT 'Products Table:' as info;
SELECT * FROM products;

SELECT 'Orders Table:' as info;
SELECT * FROM orders;

-- ビューの作成（便利なクエリ用）
CREATE VIEW order_summary AS
SELECT 
    o.id as order_id,
    u.name as customer_name,
    p.name as product_name,
    o.quantity,
    o.total_price,
    o.status,
    o.order_date
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN products p ON o.product_id = p.id;
