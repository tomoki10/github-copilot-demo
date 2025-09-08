# GitHub Copilot /Claude Code MySQL MCP Demo

このプロジェクトは、GitHub Copilot/Claude CodeでMySQL MCP（Model Context Protocol）を使用するデモです。GitHub Copilot Chat/Claude CodeからMySQLデータベースに直接アクセスしてクエリを実行できます。

## 簡易手順

```bash
docker compose up -d
claude
# 接続確認
/mcp
# 実行テスト
MCPを使ってユーザ情報を取得して
```

## 🎯 概要

- **Docker Compose**: MySQLデータベースを簡単にセットアップ
- **MySQL MCP**: GitHub CopilotからMySQLにアクセス
- **サンプルデータ**: ユーザー、商品、注文データを含む実用的な例

## 📋 前提条件

以下がインストールされている必要があります：

- Docker & Docker Compose
- Node.js & npm
- Visual Studio Code
- GitHub Copilot Extension

## 🚀 セットアップ

### オプション1: Docker版（推奨）

完全にコンテナ化された環境で実行します：

```bash
# Docker版MCPサーバーを起動
./start-mysql-mcp-docker.sh

# Docker版設定に切り替え
./switch-mcp-mode.sh docker

# 環境テスト
./test-docker-env.sh
```

### オプション2: ローカル版

ローカル環境でMCPサーバーを実行します：

```bash
# 自動セットアップ
chmod +x setup.sh
./setup.sh

# またはローカル版設定に切り替え
./switch-mcp-mode.sh local
```

### オプション3: 手動セットアップ

```bash
# MySQL MCPサーバーをインストール
npm install -g @modelcontextprotocol/server-mysql

# MySQLコンテナを起動
docker-compose up -d

# 接続テスト
docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password -e "SHOW DATABASES;"
```

### VS Codeを再起動

設定を反映させるため、VS Codeを再起動してください。

## 💾 データベース構造

### テーブル

- **users**: ユーザー情報（ID、名前、メール、年齢、部署）
- **products**: 商品情報（ID、名前、価格、在庫、カテゴリ、説明）
- **orders**: 注文情報（ID、ユーザーID、商品ID、数量、合計金額、ステータス）

### ビュー

- **order_summary**: 注文の詳細情報（顧客名、商品名、数量、金額、ステータス）

## 🎯 使用方法

GitHub Copilot Chatで以下のようなクエリを試してみてください：

### 基本的なクエリ

- "ユーザー一覧を表示してください"
- "商品テーブルの構造を教えてください"
- "注文テーブルの中身を見せてください"

### 分析クエリ

- "在庫が30個以下の商品を教えてください"
- "価格が10,000円以上の商品を見つけてください"
- "開発部のユーザーを表示してください"
- "注文状況別の件数を教えてください"

### 複雑なクエリ

- "田中太郎さんの注文履歴を表示してください"
- "最も人気のある商品を教えてください"
- "部署別の注文金額の合計を計算してください"
- "今月の売上トップ3の商品を教えてください"

### データベース操作

- "新しいユーザーを追加してください"
- "商品の在庫を更新してください"
- "注文ステータスを変更してください"

## 🛠️ 設定詳細

### 実行モード

#### Docker版（推奨）

- **メリット**: 環境の一貫性、依存関係の隔離、簡単なデプロイ
- **構成**: MySQL + MCPサーバー両方をコンテナで実行
- **設定ファイル**: `.vscode/mcp.docker.json`

#### ローカル版

- **メリット**: 軽量、デバッグが簡単
- **構成**: MySQLはコンテナ、MCPサーバーはローカル実行
- **設定ファイル**: `.vscode/mcp.json`

### Docker Compose設定

```yaml
services:
  mysql:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      MYSQL_DATABASE: demo_db
      MYSQL_USER: demo_user
      MYSQL_PASSWORD: demo_password
  
  mcp-server:  # Docker版でのみ使用
    build:
      dockerfile: Dockerfile.mcp-server
    environment:
      MYSQL_HOST: mysql
      MYSQL_USER: demo_user
      MYSQL_PASSWORD: demo_password
      MYSQL_DATABASE: demo_db
```

### VS Code設定

#### Docker版

```json
{
  "servers": {
    "mysql": {
      "command": "docker",
      "args": [
        "exec", "-i", "mysql-mcp-server",
        "uv", "run", "mysql_mcp_server"
      ]
    }
  }
}
```

#### ローカル版

```json
{
  "servers": {
    "mysql": {
      "command": "uv",
      "args": [
        "--directory", "/path/to/project",
        "run", "mysql_mcp_server"
      ],
      "env": {
        "MYSQL_HOST": "localhost",
        "MYSQL_PORT": "3306",
        "MYSQL_USER": "demo_user",
        "MYSQL_PASSWORD": "demo_password",
        "MYSQL_DATABASE": "demo_db"
      }
    }
  }
}
```

## 🔧 管理コマンド

### 環境切り替え

```bash
# Docker版に切り替え
./switch-mcp-mode.sh docker

# ローカル版に切り替え
./switch-mcp-mode.sh local

# 現在の設定確認
./switch-mcp-mode.sh
```

### Docker版管理

```bash
# 起動
./start-mysql-mcp-docker.sh

# 環境テスト
./test-docker-env.sh

# 停止
docker-compose down

# 停止（データも削除）
docker-compose down -v

# 再起動
docker-compose restart

# 再構築
docker-compose up -d --build

# ログ確認
docker-compose logs
docker-compose logs mcp-server
docker-compose logs mysql
```

### ローカル版管理

```bash
# 起動
./start-mysql-mcp.sh

# 環境テスト
./test-env.sh
```

### データベース管理

```bash
# MySQLに直接接続
docker exec -it mysql-mcp-demo mysql -u demo_user -pdemo_password demo_db

# データベースステータス確認
docker exec mysql-mcp-demo mysqladmin status -u demo_user -pdemo_password

# コンテナの状態確認
docker-compose ps
```

## 🐛 トラブルシューティング

### MySQL接続エラー

1. **コンテナが完全に起動するまで待つ**

   ```bash
   docker-compose logs mysql
   ```

2. **ポート3306が使用中**

   ```bash
   # 使用中のポートを確認
   lsof -i :3306
   
   # docker-compose.ymlでポートを変更
   ports:
     - "3307:3306"  # 3307に変更
   ```

3. **設定ファイルの確認**

   ```bash
   # VS Codeの設定を確認
   cat .vscode/settings.json
   ```

### MCP接続エラー

1. **MCPサーバーの再インストール**

   ```bash
   npm uninstall -g @modelcontextprotocol/server-mysql
   npm install -g @modelcontextprotocol/server-mysql
   ```

2. **VS Codeの再起動**
   設定変更後は必ずVS Codeを再起動してください。

3. **Node.jsバージョンの確認**

   ```bash
   node --version  # v18以上推奨
   npm --version
   ```

## 📚 参考資料

- [Model Context Protocol](https://github.com/modelcontextprotocol)
- [MySQL MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/mysql)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)

## 🤝 貢献

バグ報告や機能要望は、GitHubのIssueでお知らせください。

## 📄 ライセンス

MIT License
