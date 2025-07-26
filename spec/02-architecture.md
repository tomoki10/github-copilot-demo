# MySQL MCP Server アーキテクチャ仕様 ✅ 実装完了

## 📋 システム概要

PythonベースのMySQL MCPサーバーによるGitHub Copilot Chat統合システム（実装完了）

- **実装状況**: ✅ 完全稼働
- **MCPサーバー**: `@designcomputer/mysql_mcp_server` (Python)
- **環境管理**: `uv` による高速パッケージ管理
- **データベース**: Docker MySQL 8.0
- **接続方式**: stdio MCP プロトコル

### アーキテクチャ図

```text
GitHub Copilot Chat
        ↓ (MCP Protocol)
VS Code MCP Client
        ↓ (JSON-RPC)
Python MCP Server (uv管理)
        ↓ (MySQL Connector)
Docker MySQL Container
        ↓ (Volume Mount)
init.sql (初期データ)
```

## 🏗️ コンポーネント構成

### 1. フロントエンド層

**GitHub Copilot Chat**

- ユーザーインターフェース
- 自然言語クエリの受付
- MCPプロトコル経由でのデータベースアクセス

### 2. インターフェース層

**VS Code MCP Client**

- MCPプロトコルの実装
- GitHub Copilot ChatとMCPサーバー間の仲介
- 設定管理 (`.vscode/mcp.json`)

### 3. アプリケーション層

**Python MCP Server**

```text
mysql_mcp_server/
├── server.py           # MCPサーバーメイン
├── handlers/
│   ├── query.py        # クエリ実行ハンドラー
│   ├── schema.py       # スキーマ情報ハンドラー
│   └── connection.py   # DB接続管理
├── models/
│   ├── database.py     # データベースモデル
│   └── response.py     # レスポンスモデル
└── utils/
    ├── config.py       # 設定管理
    └── logger.py       # ログ管理
```

### 4. データ層

**Docker MySQL Container**

- MySQL 8.0
- 永続化ボリューム (`mysql_data`)
- 初期データ自動投入 (`init.sql`)

## 🔧 技術仕様

### Python環境

```toml
[project]
name = "mysql-mcp-demo"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "mysql-connector-python>=8.0.33",
    "mcp>=0.1.0",
    "pydantic>=2.0.0",
    "typing-extensions>=4.0.0"
]
```

### MCP プロトコル仕様

**サポートされるメソッド**

1. `tools/list` - 利用可能なツール一覧
2. `tools/call` - SQLクエリ実行
3. `resources/list` - データベーススキーマ情報
4. `resources/read` - テーブル構造取得

**ツール定義**

```json
{
  "tools": [
    {
      "name": "mysql_query",
      "description": "Execute MySQL query",
      "inputSchema": {
        "type": "object",
        "properties": {
          "query": {"type": "string"},
          "parameters": {"type": "array"}
        }
      }
    }
  ]
}
```

### データベース設計

**接続情報**

- Host: `localhost`
- Port: `3306`
- Database: `demo_db`
- User: `demo_user`
- Password: `demo_password`

**テーブル構造**

```sql
-- ユーザーテーブル
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    age INT,
    department VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 商品テーブル
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    category VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 注文テーブル
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'completed', 'cancelled') DEFAULT 'pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);
```

## 🔄 データフロー

### クエリ実行フロー

1. **ユーザー入力**: GitHub Copilot Chatでクエリ入力
2. **自然言語処理**: GitHub CopilotがSQL文を生成
3. **MCP通信**: VS Code MCP ClientがPython MCPサーバーに要求
4. **SQL実行**: MySQL Connectorがデータベースにクエリ実行
5. **結果返却**: 実行結果をMCPプロトコル経由で返却
6. **表示**: GitHub Copilot Chatで結果表示

### エラーハンドリングフロー

```text
SQL Error
    ↓
MySQL Connector Exception
    ↓
Python MCP Server Error Handler
    ↓
MCP Error Response
    ↓
GitHub Copilot Chat Error Display
```

## 🛡️ セキュリティ設計

### 認証・認可

- MySQL接続: ユーザー名/パスワード認証
- MCP通信: ローカルプロセス間通信（セキュア）
- Docker: プライベートネットワーク

### 入力検証

```python
# SQLインジェクション対策
def validate_query(query: str) -> bool:
    """危険なSQL文をチェック"""
    dangerous_keywords = ['DROP', 'DELETE', 'TRUNCATE', 'ALTER']
    return not any(keyword in query.upper() for keyword in dangerous_keywords)

# パラメータ化クエリ使用
def execute_query(query: str, params: List[Any]) -> List[Dict]:
    """パラメータ化クエリで安全に実行"""
    cursor.execute(query, params)
    return cursor.fetchall()
```

### 接続セキュリティ

- SSL/TLS通信（本番環境）
- 接続タイムアウト設定
- 最大接続数制限

## 📊 監視・ログ設計

### ログレベル

- `DEBUG`: 詳細な実行情報
- `INFO`: 一般的な動作情報
- `WARNING`: 警告レベルのイベント
- `ERROR`: エラー情報
- `CRITICAL`: システム停止レベル

### メトリクス

- クエリ実行時間
- エラー発生率
- 接続数
- レスポンス時間

### ログフォーマット

```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('mcp_server.log'),
        logging.StreamHandler()
    ]
)
```

## 🔧 設定管理

### 環境変数

```bash
# データベース設定
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=demo_user
MYSQL_PASSWORD=demo_password
MYSQL_DATABASE=demo_db

# サーバー設定
MCP_SERVER_HOST=localhost
MCP_SERVER_PORT=8000
LOG_LEVEL=INFO
```

### 設定ファイル

```python
# config.py
from pydantic import BaseSettings

class Settings(BaseSettings):
    mysql_host: str = "localhost"
    mysql_port: int = 3306
    mysql_user: str = "demo_user"
    mysql_password: str = "demo_password"
    mysql_database: str = "demo_db"
    
    class Config:
        env_file = ".env"
```

## 🚀 デプロイメント設計

### 開発環境

```bash
# uvによる依存関係管理
uv add mysql-connector-python mcp

# 開発用起動
uv run python -m mysql_mcp_server --debug
```

### 本番環境

```bash
# uvによる本番インストール
uv sync --no-dev

# 本番用起動
uv run python -m mysql_mcp_server --production
```

---

**作成日**: 2025年7月25日  
**最終更新**: 2025年7月25日  
**バージョン**: 1.0
