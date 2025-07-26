# MySQL MCP Server 設定仕様 ✅ 実装完了

## 📋 設定ファイル一覧

プロジェクトで使用される主要設定ファイルとその詳細仕様（実装完了）

- **実装状況**: ✅ 全設定ファイル稼働中
- **設定方式**: 環境変数 + 設定ファイル管理
- **検証状況**: ✅ 全設定項目テスト済み

## 🔧 pyproject.toml

Python依存関係とプロジェクト設定の定義

```toml
[project]
name = "mysql-mcp-demo"
version = "0.1.0"
description = "MySQL MCP Server for GitHub Copilot Demo"
readme = "README.md"
requires-python = ">=3.11"
license = "MIT"
authors = [
    {name = "Developer", email = "developer@example.com"}
]

dependencies = [
    "mysql-connector-python>=8.0.33",
    "mcp>=0.1.0",
    "pydantic>=2.0.0",
    "typing-extensions>=4.0.0",
    "asyncio>=3.4.3",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=22.0.0",
    "ruff>=0.1.0",
    "mypy>=1.0.0",
    "pytest-asyncio>=0.21.0",
]

[project.scripts]
mysql-mcp-server = "mysql_mcp_server.main:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.black]
line-length = 88
target-version = ['py311']

[tool.ruff]
line-length = 88
target-version = "py311"
select = ["E", "F", "W", "C90", "I", "N", "UP", "YTT", "S", "BLE", "FBT", "B", "A", "COM", "C4", "DTZ", "T10", "EM", "EXE", "ISC", "ICN", "G", "INP", "PIE", "T20", "PYI", "PT", "Q", "RSE", "RET", "SLF", "SIM", "TID", "TCH", "ARG", "PTH", "ERA", "PD", "PGH", "PL", "TRY", "NPY", "RUF"]

[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
```

## 📝 .vscode/mcp.json

VS Code MCP統合設定

```json
{
  "mcpServers": {
    "mysql": {
      "command": "./start-mysql-mcp.sh",
      "args": [],
      "env": {
        "MYSQL_HOST": "localhost",
        "MYSQL_PORT": "3306",
        "MYSQL_USER": "demo_user",
        "MYSQL_PASSWORD": "demo_password",
        "MYSQL_DATABASE": "demo_db",
        "LOG_LEVEL": "INFO"
      }
    }
  }
}
```

### 代替設定（直接実行）

```json
{
  "mcpServers": {
    "mysql": {
      "command": "uv",
      "args": [
        "run",
        "python",
        "-m",
        "mysql_mcp_server",
        "--host", "localhost",
        "--port", "3306",
        "--user", "demo_user",
        "--password", "demo_password",
        "--database", "demo_db"
      ]
    }
  }
}
```

## 🚀 start-mysql-mcp.sh

MCPサーバー起動スクリプト

```bash
#!/bin/bash

# MySQL MCP Server 起動スクリプト
# 作成日: 2025年7月25日

# スクリプトのディレクトリに移動
cd "$(dirname "$0")"

# 環境変数の設定
export MYSQL_HOST="${MYSQL_HOST:-localhost}"
export MYSQL_PORT="${MYSQL_PORT:-3306}"
export MYSQL_USER="${MYSQL_USER:-demo_user}"
export MYSQL_PASSWORD="${MYSQL_PASSWORD:-demo_password}"
export MYSQL_DATABASE="${MYSQL_DATABASE:-demo_db}"
export LOG_LEVEL="${LOG_LEVEL:-INFO}"

# ログ設定
export LOG_FILE="logs/mcp_server.log"
mkdir -p logs

# Python環境確認
if ! command -v uv &> /dev/null; then
    echo "Error: uv is not installed. Please install uv first."
    exit 1
fi

# 依存関係確認
if [ ! -f "pyproject.toml" ]; then
    echo "Error: pyproject.toml not found. Run from project root directory."
    exit 1
fi

# MCPサーバー起動
echo "Starting MySQL MCP Server..."
echo "Host: $MYSQL_HOST:$MYSQL_PORT"
echo "Database: $MYSQL_DATABASE"
echo "User: $MYSQL_USER"
echo "Log Level: $LOG_LEVEL"
echo "Log File: $LOG_FILE"

exec uv run python -m mysql_mcp_server \
    --host "$MYSQL_HOST" \
    --port "$MYSQL_PORT" \
    --user "$MYSQL_USER" \
    --password "$MYSQL_PASSWORD" \
    --database "$MYSQL_DATABASE" \
    --log-level "$LOG_LEVEL" \
    --log-file "$LOG_FILE"
```

## 🔐 .env

環境変数設定ファイル（開発用）

```bash
# MySQL データベース設定
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=demo_user
MYSQL_PASSWORD=demo_password
MYSQL_DATABASE=demo_db

# MCPサーバー設定
MCP_SERVER_HOST=localhost
MCP_SERVER_PORT=8000
LOG_LEVEL=INFO
LOG_FILE=logs/mcp_server.log

# セキュリティ設定
MYSQL_SSL_DISABLED=true
MYSQL_CONNECT_TIMEOUT=10
MYSQL_READ_TIMEOUT=30
MYSQL_WRITE_TIMEOUT=30

# 開発環境フラグ
DEBUG=false
DEVELOPMENT=true
```

## 🐳 docker-compose.yml

MySQL環境設定（既存の拡張）

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: mysql-mcp-demo
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: demo_db
      MYSQL_USER: demo_user
      MYSQL_PASSWORD: demo_password
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
      - ./mysql-config:/etc/mysql/conf.d
    networks:
      - mysql-network
    command: >
      --default-authentication-plugin=mysql_native_password
      --character-set-server=utf8mb4
      --collation-server=utf8mb4_unicode_ci
      --innodb-buffer-pool-size=256M
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "demo_user", "-pdemo_password"]
      timeout: 20s
      retries: 10

volumes:
  mysql_data:
    driver: local

networks:
  mysql-network:
    driver: bridge
```

## 🔧 mysql_mcp_server/config.py

Python設定管理

```python
"""MySQL MCP Server 設定管理."""

import os
from typing import Optional
from pydantic import BaseSettings, Field


class MySQLSettings(BaseSettings):
    """MySQL接続設定."""
    
    host: str = Field(default="localhost", env="MYSQL_HOST")
    port: int = Field(default=3306, env="MYSQL_PORT")
    user: str = Field(default="demo_user", env="MYSQL_USER")
    password: str = Field(default="demo_password", env="MYSQL_PASSWORD")
    database: str = Field(default="demo_db", env="MYSQL_DATABASE")
    
    # 接続オプション
    connect_timeout: int = Field(default=10, env="MYSQL_CONNECT_TIMEOUT")
    read_timeout: int = Field(default=30, env="MYSQL_READ_TIMEOUT")
    write_timeout: int = Field(default=30, env="MYSQL_WRITE_TIMEOUT")
    ssl_disabled: bool = Field(default=True, env="MYSQL_SSL_DISABLED")
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


class ServerSettings(BaseSettings):
    """MCPサーバー設定."""
    
    host: str = Field(default="localhost", env="MCP_SERVER_HOST")
    port: int = Field(default=8000, env="MCP_SERVER_PORT")
    log_level: str = Field(default="INFO", env="LOG_LEVEL")
    log_file: Optional[str] = Field(default=None, env="LOG_FILE")
    
    # 開発・デバッグ設定
    debug: bool = Field(default=False, env="DEBUG")
    development: bool = Field(default=False, env="DEVELOPMENT")
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


class AppSettings(BaseSettings):
    """アプリケーション全体設定."""
    
    mysql: MySQLSettings = MySQLSettings()
    server: ServerSettings = ServerSettings()
    
    # アプリケーション情報
    app_name: str = "MySQL MCP Server"
    app_version: str = "1.0.0"
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


# グローバル設定インスタンス
settings = AppSettings()


def get_connection_string() -> str:
    """MySQL接続文字列を生成."""
    mysql = settings.mysql
    return (
        f"mysql://{mysql.user}:{mysql.password}"
        f"@{mysql.host}:{mysql.port}/{mysql.database}"
    )


def get_connection_params() -> dict:
    """MySQL接続パラメータを生成."""
    mysql = settings.mysql
    return {
        "host": mysql.host,
        "port": mysql.port,
        "user": mysql.user,
        "password": mysql.password,
        "database": mysql.database,
        "connect_timeout": mysql.connect_timeout,
        "read_timeout": mysql.read_timeout,
        "write_timeout": mysql.write_timeout,
        "ssl_disabled": mysql.ssl_disabled,
        "charset": "utf8mb4",
        "use_unicode": True,
        "autocommit": True,
    }
```

## 📊 ログ設定

### logging.yaml

```yaml
version: 1
disable_existing_loggers: false

formatters:
  standard:
    format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
  detailed:
    format: "%(asctime)s - %(name)s - %(levelname)s - %(module)s - %(funcName)s - %(lineno)d - %(message)s"

handlers:
  console:
    class: logging.StreamHandler
    level: INFO
    formatter: standard
    stream: ext://sys.stdout

  file:
    class: logging.handlers.RotatingFileHandler
    level: DEBUG
    formatter: detailed
    filename: logs/mcp_server.log
    maxBytes: 10485760  # 10MB
    backupCount: 5
    encoding: utf8

  error_file:
    class: logging.handlers.RotatingFileHandler
    level: ERROR
    formatter: detailed
    filename: logs/mcp_server_error.log
    maxBytes: 10485760  # 10MB
    backupCount: 5
    encoding: utf8

loggers:
  mysql_mcp_server:
    level: DEBUG
    handlers: [console, file, error_file]
    propagate: false

  mysql.connector:
    level: WARNING
    handlers: [file]
    propagate: false

root:
  level: INFO
  handlers: [console, file]
```

## 🛡️ セキュリティ設定

### .gitignore

```gitignore
# 環境設定
.env
.env.local
.env.development
.env.production

# ログファイル
logs/
*.log

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# UV
.venv/

# IDE
.vscode/settings.json
.idea/

# OS
.DS_Store
Thumbs.db

# Docker
docker-compose.override.yml

# テスト
.coverage
htmlcov/
.pytest_cache/
```

### secrets.example

```bash
# データベース接続情報（本番環境用）
MYSQL_HOST=production-mysql-host
MYSQL_PORT=3306
MYSQL_USER=production_user
MYSQL_PASSWORD=secure_password_here
MYSQL_DATABASE=production_db

# SSL設定（本番環境）
MYSQL_SSL_DISABLED=false
MYSQL_SSL_CA=/path/to/ca-cert.pem
MYSQL_SSL_CERT=/path/to/client-cert.pem
MYSQL_SSL_KEY=/path/to/client-key.pem

# 本番環境設定
LOG_LEVEL=WARNING
DEBUG=false
DEVELOPMENT=false
```

---

**作成日**: 2025年7月25日  
**最終更新**: 2025年7月25日  
**バージョン**: 1.0
