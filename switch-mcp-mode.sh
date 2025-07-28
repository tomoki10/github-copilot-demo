#!/bin/bash

# MCP設定切り替えスクリプト
# ローカル実行とDocker実行を切り替える

set -e

cd "$(dirname "$0")"

if [ "$1" = "docker" ]; then
    echo "🐳 Docker版MCP設定に切り替えています..."
    cp .vscode/mcp.json .vscode/mcp.local.backup 2>/dev/null || true
    cp .vscode/mcp.docker.json .vscode/mcp.json
    echo "✅ Docker版設定に切り替えました"
    echo "📦 起動するには: ./start-mysql-mcp-docker.sh"
elif [ "$1" = "local" ]; then
    echo "🏠 ローカル版MCP設定に切り替えています..."
    if [ -f .vscode/mcp.local.backup ]; then
        cp .vscode/mcp.local.backup .vscode/mcp.json
    else
        cat > .vscode/mcp.json << 'EOF'
{
  "servers": {
    "mysql": {
        "command": "uv",
        "args": [
            "--directory",
            "/Users/sato.tomoki/Documents/generative_ai_work/github-copilot-demo",
            "run",
            "mysql_mcp_server"
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
EOF
    fi
    echo "✅ ローカル版設定に切り替えました"
    echo "🚀 起動するには: ./start-mysql-mcp.sh"
else
    echo "使用方法: $0 [docker|local]"
    echo ""
    echo "  docker - Docker版MCPサーバーを使用"
    echo "  local  - ローカル版MCPサーバーを使用"
    echo ""
    echo "現在の設定:"
    if grep -q "docker" .vscode/mcp.json 2>/dev/null; then
        echo "  🐳 Docker版"
    else
        echo "  🏠 ローカル版"
    fi
    exit 1
fi
