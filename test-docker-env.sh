#!/bin/bash

# Docker版MCP環境テストスクリプト

set -e

cd "$(dirname "$0")"

echo "🧪 Docker版MCP環境をテストしています..."

# Docker Composeが実行中か確認
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Docker Composeサービスが起動していません"
    echo "📦 起動するには: ./start-mysql-mcp-docker.sh"
    exit 1
fi

echo "✅ Docker Composeサービスが実行中です"

# MySQLコンテナの接続テスト
echo "🔍 MySQL接続テスト..."
if docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password -e "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ MySQL接続成功"
else
    echo "❌ MySQL接続失败"
    exit 1
fi

# MCPサーバーコンテナの基本テスト
echo "🔍 MCPサーバー基本テスト..."
if docker exec mysql-mcp-server uv --version > /dev/null 2>&1; then
    echo "✅ uvコマンド実行可能"
else
    echo "❌ uvコマンド実行失敗"
    exit 1
fi

# Python環境テスト
echo "🔍 Python環境テスト..."
if docker exec mysql-mcp-server uv run python -c "import mysql.connector; print('MySQL connector available')" > /dev/null 2>&1; then
    echo "✅ Python MySQL connector利用可能"
else
    echo "❌ Python MySQL connector利用不可"
    exit 1
fi

# MCPサーバーからのMySQL接続テスト
echo "🔍 MCP→MySQL接続テスト..."
if docker exec mysql-mcp-server uv run python -c "
import mysql.connector
import os
try:
    conn = mysql.connector.connect(
        host=os.getenv('MYSQL_HOST'),
        port=int(os.getenv('MYSQL_PORT')),
        user=os.getenv('MYSQL_USER'),
        password=os.getenv('MYSQL_PASSWORD'),
        database=os.getenv('MYSQL_DATABASE')
    )
    cursor = conn.cursor()
    cursor.execute('SELECT COUNT(*) FROM users')
    result = cursor.fetchone()
    print(f'Users count: {result[0]}')
    conn.close()
    print('Connection test successful')
except Exception as e:
    print(f'Connection failed: {e}')
    exit(1)
" > /dev/null 2>&1; then
    echo "✅ MCP→MySQL接続成功"
else
    echo "❌ MCP→MySQL接続失敗"
    exit 1
fi

# サンプルデータの確認
echo "🔍 サンプルデータ確認..."
user_count=$(docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password demo_db -e "SELECT COUNT(*) FROM users;" --skip-column-names 2>/dev/null)
product_count=$(docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password demo_db -e "SELECT COUNT(*) FROM products;" --skip-column-names 2>/dev/null)
order_count=$(docker exec mysql-mcp-demo mysql -u demo_user -pdemo_password demo_db -e "SELECT COUNT(*) FROM orders;" --skip-column-names 2>/dev/null)

echo "📊 データベース統計:"
echo "  ユーザー数: $user_count"
echo "  商品数: $product_count"
echo "  注文数: $order_count"

# MCP設定ファイルの確認
echo "🔍 MCP設定確認..."
if [ -f .vscode/mcp.json ]; then
    if grep -q "docker" .vscode/mcp.json; then
        echo "✅ Docker版MCP設定が適用されています"
    else
        echo "⚠️  ローカル版MCP設定が適用されています"
        echo "💡 Docker版に切り替えるには: ./switch-mcp-mode.sh docker"
    fi
else
    echo "❌ MCP設定ファイルが見つかりません"
fi

echo ""
echo "🎉 すべてのテストが完了しました！"
echo ""
echo "📋 コンテナステータス:"
docker-compose ps
