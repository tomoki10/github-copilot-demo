# GitHub Copilot MySQL MCP Demo

このプロジェクトは、GitHub CopilotでMySQL MCP（Model Context Protocol）を使用するデモです。GitHub Copilot ChatからMySQLデータベースに直接アクセスしてクエリを実行できます。

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

### 1. 自動セットアップ（推奨）

```bash
chmod +x setup.sh
./setup.sh
```

### 2. 手動セットアップ

```bash
# MySQL MCPサーバーをインストール
npm install -g @modelcontextprotocol/server-mysql

# MySQLコンテナを起動
docker-compose up -d

# 接続テスト
docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password -e "SHOW DATABASES;"
```

### 3. VS Codeを再起動

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
```

### VS Code設定

```json
{
  "github.copilot.chat.experimental.mcpServers": {
    "mysql": {
      "command": "npx",
      "args": [
        "@modelcontextprotocol/server-mysql",
        "mysql://demo_user:demo_password@localhost:3306/demo_db"
      ]
    }
  }
}
```

## 🔧 管理コマンド

### データベース管理

```bash
# MySQLに直接接続
docker exec -it mysql-mcp-demo mysql -u demo_user -pdemo_password demo_db

# ログの確認
docker-compose logs mysql

# コンテナの状態確認
docker-compose ps
```

### 停止・再起動

```bash
# 停止
docker-compose down

# 停止（データも削除）
docker-compose down -v

# 再起動
docker-compose restart

# 再構築
docker-compose up -d --build
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
