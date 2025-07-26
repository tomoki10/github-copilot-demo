#!/bin/bash

# MySQL MCP Server 起動スクリプト
# GitHub Copilot Demo用

set -e

# スクリプトのディレクトリに移動
cd "$(dirname "$0")"

# PATHにuvを追加
export PATH="$HOME/.local/bin:$PATH"

# デバッグ情報を標準エラー出力に出力
echo "Starting MySQL MCP Server..." >&2
echo "Host: ${MYSQL_HOST:-not set}" >&2
echo "Port: ${MYSQL_PORT:-not set}" >&2
echo "User: ${MYSQL_USER:-not set}" >&2
echo "Database: ${MYSQL_DATABASE:-not set}" >&2

# MySQL MCP Serverを起動
exec uv run mysql_mcp_server
