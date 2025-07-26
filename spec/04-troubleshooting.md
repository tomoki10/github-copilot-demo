# MySQL MCP Server トラブルシューティング

## 📋 概要

Python版MySQL MCPサーバーで発生する可能性のある問題と解決方法

## 🚨 よくある問題と解決法

### 1. uvインストール関連

#### 問題: uvがインストールされていない

```bash
Error: uv is not installed
```

**解決方法:**

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Homebrew
brew install uv

# パスの確認
echo $PATH
source ~/.zshrc  # または ~/.bashrc
```

#### 問題: uvのパスが通っていない

```bash
command not found: uv
```

**解決方法:**

```bash
# パスを追加
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 確認
which uv
uv --version
```

### 2. Python環境関連

#### 問題: Python 3.11以上がない

```bash
Error: Python 3.11+ required
```

**解決方法:**

```bash
# uvでPythonをインストール
uv python install 3.11

# システムのPythonバージョン確認
python3 --version

# macOSの場合（Homebrew）
brew install python@3.11
```

#### 問題: 仮想環境が作成されない

```bash
Error: Failed to create virtual environment
```

**解決方法:**

```bash
# 手動で仮想環境作成
uv venv

# 依存関係の再インストール
uv sync

# キャッシュクリア
uv cache clean
```

### 3. MCPサーバー関連

#### 問題: MCPサーバーが起動しない

```bash
Error: Failed to start MCP server
```

**解決方法:**

```bash
# 詳細ログで起動
./start-mysql-mcp.sh --debug

# 手動起動でテスト
uv run python -m mysql_mcp_server --help

# 依存関係確認
uv tree
```

#### 問題: MCPサーバーへの接続失敗

```bash
Error: Connection refused
```

**解決方法:**

```bash
# プロセス確認
ps aux | grep mysql_mcp_server

# ポート確認
lsof -i :8000

# VS Code設定確認
cat .vscode/mcp.json

# VS Code再起動
# Command + Shift + P -> "Developer: Reload Window"
```

### 4. MySQL接続関連

#### 問題: MySQL接続エラー

```bash
Error: Can't connect to MySQL server
```

**解決方法:**

```bash
# MySQLコンテナ状態確認
docker-compose ps
docker-compose logs mysql

# 手動接続テスト
docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password -e "SELECT 1;"

# ポート確認
lsof -i :3306

# 接続待機
sleep 30 && docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password -e "SELECT 1;"
```

#### 問題: 認証エラー

```bash
Error: Access denied for user 'demo_user'
```

**解決方法:**

```bash
# パスワード確認
echo $MYSQL_PASSWORD

# Docker環境変数確認
docker exec mysql-mcp-demo env | grep MYSQL

# MySQLユーザー作成（root権限で）
docker exec mysql-mcp-demo mysql -u root -prootpassword -e "
CREATE USER IF NOT EXISTS 'demo_user'@'%' IDENTIFIED BY 'demo_password';
GRANT ALL PRIVILEGES ON demo_db.* TO 'demo_user'@'%';
FLUSH PRIVILEGES;"
```

### 5. VS Code統合関連

#### 問題: GitHub Copilot ChatでMCPが認識されない

**解決方法:**

```bash
# mcp.json設定確認
cat .vscode/mcp.json

# VS Code拡張機能確認
# Extensions -> GitHub Copilot Chat

# VS Code設定リロード
# Command + Shift + P -> "Developer: Reload Window"

# GitHub Copilot再認証
# Command + Shift + P -> "GitHub Copilot: Sign Out"
```

#### 問題: MCPサーバーの応答がない

**解決方法:**

```bash
# MCPサーバーログ確認
tail -f logs/mcp_server.log

# タイムアウト設定確認
grep -r timeout .vscode/

# MCPサーバー再起動
pkill -f mysql_mcp_server
./start-mysql-mcp.sh
```

## 🔧 デバッグ手順

### 1. 段階的デバッグ

```bash
# Step 1: 基本環境確認
uv --version
python3 --version
docker --version

# Step 2: Docker環境確認
docker-compose ps
docker-compose logs mysql

# Step 3: MySQL接続確認
docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password -e "SHOW DATABASES;"

# Step 4: Python環境確認
uv run python -c "import mysql.connector; print('MySQL connector OK')"

# Step 5: MCPサーバー確認
uv run python -m mysql_mcp_server --help
```

### 2. ログ分析

```bash
# MCPサーバーログ
tail -f logs/mcp_server.log

# MySQLログ
docker-compose logs -f mysql

# VS Codeデベロッパーツール
# Command + Shift + P -> "Developer: Show Logs"
```

### 3. 設定検証

```bash
# 環境変数確認
env | grep MYSQL

# 設定ファイル確認
cat .vscode/mcp.json
cat pyproject.toml

# 依存関係確認
uv tree
```

## 🧪 テストコマンド集

### 基本動作テスト

```bash
# 1. 環境テスト
./test-environment.sh

# 2. MySQL接続テスト
./test-mysql-connection.sh

# 3. MCPサーバーテスト
./test-mcp-server.sh

# 4. 統合テスト
./test-integration.sh
```

### 手動テストクエリ

GitHub Copilot Chatで以下を試行:

```text
# 基本接続テスト
"データベースの状態を確認してください"

# テーブル確認
"usersテーブルの構造を表示してください"

# データ取得
"ユーザー一覧を表示してください"

# エラーテスト
"存在しないテーブルにアクセスしてください"
```

## 🛠️ パフォーマンス問題

### 遅い応答時間

**症状:** MCPサーバーの応答が遅い

**解決方法:**

```bash
# MySQL接続プール設定
echo "MYSQL_POOL_SIZE=10" >> .env

# タイムアウト調整
echo "MYSQL_CONNECT_TIMEOUT=5" >> .env

# ログレベル調整
echo "LOG_LEVEL=WARNING" >> .env

# インデックス確認
docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password demo_db -e "SHOW INDEX FROM users;"
```

### メモリ使用量増加

**症状:** MCPサーバーのメモリ使用量が多い

**解決方法:**

```bash
# プロセス監視
ps aux | grep mysql_mcp_server

# メモリ使用量確認
top -p $(pgrep -f mysql_mcp_server)

# 接続プール調整
echo "MYSQL_POOL_SIZE=5" >> .env
echo "MYSQL_POOL_RECYCLE=3600" >> .env
```

## 🚨 緊急時対応

### 完全リセット手順

```bash
# 1. 全停止
docker-compose down -v
pkill -f mysql_mcp_server

# 2. キャッシュクリア
uv cache clean
rm -rf .venv/
rm -rf logs/

# 3. 再セットアップ
./setup.sh

# 4. VS Code再起動
# Command + Q -> VS Code再起動
```

### ロールバック手順

```bash
# Node.js版に戻す
npm install -g mysql-mcp-universal

# mcp.json復元
cp .vscode/mcp.json.backup .vscode/mcp.json

# 設定確認
cat .vscode/mcp.json
```

## 📞 サポート情報

### ログ収集

問題報告時に以下の情報を収集:

```bash
# システム情報
uname -a
python3 --version
uv --version
docker --version

# 設定情報
cat .vscode/mcp.json
cat pyproject.toml

# ログ情報
tail -50 logs/mcp_server.log
docker-compose logs --tail=50 mysql

# プロセス情報
ps aux | grep -E "(mysql|python)"
lsof -i :3306
lsof -i :8000
```

### 関連リンク

- [uvドキュメント](https://docs.astral.sh/uv/)
- [MySQL Connector/Python](https://dev.mysql.com/doc/connector-python/en/)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [GitHub Copilot](https://docs.github.com/en/copilot)

---

**作成日**: 2025年7月25日  
**最終更新**: 2025年7月25日  
**バージョン**: 1.0
