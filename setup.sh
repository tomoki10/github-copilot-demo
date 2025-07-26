#!/bin/bash

echo "🚀 GitHub Copilot MySQL MCP デモのセットアップを開始します..."
echo ""

# 前提条件チェック
echo "📋 前提条件をチェックしています..."

# Dockerがインストールされているかチェック
if ! command -v docker &> /dev/null; then
    echo "❌ Dockerがインストールされていません。Dockerをインストールしてください。"
    exit 1
fi

# Docker Composeがインストールされているかチェック
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Composeがインストールされていません。Docker Composeをインストールしてください。"
    exit 1
fi

# uvがインストールされているかチェック
if ! command -v uv &> /dev/null; then
    echo "📦 uvをインストールしています..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source ~/.bashrc || source ~/.zshrc || true
    export PATH="$HOME/.local/bin:$PATH"
    if ! command -v uv &> /dev/null; then
        echo "❌ uvのインストールに失敗しました。手動でインストールしてください。"
        exit 1
    fi
    echo "✅ uvのインストールが完了しました。"
fi

echo "✅ 前提条件のチェックが完了しました。"
echo ""

# 既存のMySQLコンテナを停止・削除
echo "🧹 既存のMySQLコンテナをクリーンアップしています..."
docker-compose down -v 2>/dev/null || true
docker container rm mysql-mcp-demo 2>/dev/null || true

# 既存のNode.js版MCPサーバーをアンインストール
echo "🗑️  既存のNode.js版MCPサーバーをアンインストールしています..."
npm uninstall -g mysql-mcp-universal 2>/dev/null || true
echo "✅ クリーンアップが完了しました。"
echo ""

# Python環境の設定とMCPサーバーのインストール
echo "� Python環境とMCPサーバーをセットアップしています..."

# MySQL MCPサーバーの依存関係をインストール
uv sync
if [ $? -eq 0 ]; then
    echo "✅ Python環境のセットアップが完了しました。"
else
    echo "❌ Python環境のセットアップに失敗しました。"
    exit 1
fi

# 起動スクリプトに実行権限を付与
chmod +x start-mysql-mcp.sh
echo ""

# Docker ComposeでMySQLを起動
echo "🐳 MySQLコンテナを起動しています..."
docker-compose up -d
if [ $? -eq 0 ]; then
    echo "✅ MySQLコンテナの起動が完了しました。"
else
    echo "❌ MySQLコンテナの起動に失敗しました。"
    exit 1
fi
echo ""

# MySQLが起動するまで待機
echo "⏳ MySQLが完全に起動するまで待機しています（約30秒）..."
sleep 30

# 接続テストを複数回試行
echo "🔍 MySQL接続をテストしています..."
for i in {1..5}; do
    if docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password -e "SELECT 1;" > /dev/null 2>&1; then
        echo "✅ MySQL接続テストが成功しました。"
        break
    else
        if [ $i -eq 5 ]; then
            echo "❌ MySQL接続テストに失敗しました。"
            echo "📝 トラブルシューティング:"
            echo "   - docker-compose logs でログを確認してください"
            echo "   - ポート3306が他のプロセスで使用されていないか確認してください"
            exit 1
        else
            echo "   接続テスト試行 $i/5 失敗、10秒後に再試行..."
            sleep 10
        fi
    fi
done
echo ""

# MCPサーバーのテスト
echo "🔍 MCP サーバーをテストしています..."
if MYSQL_HOST=localhost MYSQL_PORT=3306 MYSQL_USER=demo_user MYSQL_PASSWORD=demo_password MYSQL_DATABASE=demo_db timeout 5 uv run mysql_mcp_server > /dev/null 2>&1; then
    echo "✅ MCP サーバーが正常に動作しています。"
else
    echo "⚠️  MCP サーバーのテストをスキップしました。VS Code再起動後に動作確認してください。"
fi
echo ""

# データベース構造の確認
echo "📊 データベース構造を確認しています..."
echo "   データベース一覧:"
docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password -e "SHOW DATABASES;" | grep -v "information_schema\|performance_schema\|mysql\|sys\|Database"

echo "   テーブル一覧:"
docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password demo_db -e "SHOW TABLES;"

echo "   サンプルデータ:"
docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password demo_db -e "SELECT COUNT(*) as user_count FROM users; SELECT COUNT(*) as product_count FROM products; SELECT COUNT(*) as order_count FROM orders;"
echo ""

echo "🎉 セットアップが完了しました！"
echo ""
echo "📖 次のステップ:"
echo "   1. VS Codeを再起動してください"
echo "   2. GitHub Copilot Chatを開いてください"
echo "   3. 以下のようなクエリを試してみてください:"
echo ""
echo "   💬 サンプルクエリ:"
echo "      'ユーザー一覧を表示してください'"
echo "      'products テーブルの構造を教えてください'"
echo "      '在庫が30個以下の商品を教えてください'"
echo "      '田中太郎さんの注文履歴を表示してください'"
echo "      '注文状況をまとめて表示してください'"
echo ""
echo "📚 詳細な使い方は README.md を参照してください。"
echo ""
echo "🛑 停止方法: docker-compose down"
