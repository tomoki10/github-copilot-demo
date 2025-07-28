#!/bin/bash

# MySQL MCP Server Docker版 起動スクリプト
# GitHub Copilot Demo用

set -e

# スクリプトのディレクトリに移動
cd "$(dirname "$0")"

echo "🐳 Docker版MySQL MCPサーバーを起動しています..."

# 既存のコンテナを停止・削除（クリーンアップ）
echo "📦 既存のコンテナをクリーンアップしています..."
docker-compose down --remove-orphans 2>/dev/null || true

# Docker Composeでサービスをビルド・起動
echo "🔨 MCPサーバーをビルドしています..."
docker-compose build mcp-server

echo "🚀 サービスを起動しています..."
docker-compose up -d

# MySQLサーバーの起動確認
echo "⏳ MySQLサーバーの起動を待機中..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if docker exec mysql-mcp-demo mysqladmin ping -h localhost -u demo_user -pdemo_password --silent 2>/dev/null; then
        echo "✅ MySQLサーバーが起動しました"
        break
    fi
    attempt=$((attempt + 1))
    echo "  待機中... ($attempt/$max_attempts)"
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ MySQLサーバーの起動がタイムアウトしました"
    docker-compose logs mysql
    exit 1
fi

# MCPサーバーの起動確認
echo "⏳ MCPサーバーの起動を待機中..."
max_attempts=20
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if docker exec mysql-mcp-server uv run python -c "import mysql.connector; print('MCP Server OK')" > /dev/null 2>&1; then
        echo "✅ MCPサーバーが正常に起動しました"
        break
    fi
    attempt=$((attempt + 1))
    echo "  待機中... ($attempt/$max_attempts)"
    sleep 3
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ MCPサーバーの起動に失敗しました"
    echo "📋 MCPサーバーのログ:"
    docker-compose logs mcp-server
    exit 1
fi

echo ""
echo "🎉 Docker版MySQL MCPサーバーの準備が完了しました"
echo ""
echo "📚 使用方法:"
echo "  1. VS Codeでこのプロジェクトを開く"
echo "  2. .vscode/mcp.json を .vscode/mcp.docker.json で置き換える"
echo "  3. GitHub Copilot でMCPサーバーを利用開始"
echo ""
echo "🔧 管理コマンド:"
echo "  停止: docker-compose down"
echo "  ログ確認: docker-compose logs"
echo "  再起動: docker-compose restart"
echo ""
echo "🔍 ステータス確認:"
docker-compose ps
