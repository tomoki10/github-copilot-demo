# MySQL MCP Server Python実装計画

## 📋 概要

Node.jsベースの`mysql-mcp-universal`からPythonベースの`mysql_mcp_server`への移行計画

- **移行元**: `mysql-mcp-universal` (Node.js)
- **移行先**: `@designcomputer/mysql_mcp_server` (Python)
- **パッケージ管理**: `uv` (Python)
- **環境管理**: Python仮想環境 + uvによる依存関係管理

## 🎯 移行理由

1. **パフォーマンス向上**: Pythonベースのサーバーの方が安定性が高い
2. **機能豊富**: より多くのMySQL機能をサポート
3. **保守性**: 活発に開発されているプロジェクト
4. **依存関係管理**: uvによる高速で信頼性の高いパッケージ管理

## 📦 技術スタック

### 現在の構成

```text
mysql-mcp-universal (Node.js)
└── npm グローバルインストール
└── 単純なMySQLクエリ実行
```

### 新しい構成

```text
mysql_mcp_server (Python)
├── uv による仮想環境管理
├── Python 3.11+
├── mysql-connector-python
└── 拡張されたMySQL機能サポート
```

## 🔧 実装ステップ

### Phase 1: 環境準備

1. uvのインストール・設定
2. Python仮想環境の作成
3. 依存関係の定義 (pyproject.toml)

### Phase 2: MCPサーバー移行

1. 既存Node.js版のアンインストール
2. Python版MCPサーバーのインストール
3. 起動スクリプトの作成

### Phase 3: 設定ファイル更新

1. mcp.jsonの更新
2. 環境変数による設定管理
3. セキュリティ強化

### Phase 4: 自動化・テスト

1. setup.shスクリプトの更新
2. 接続テストの実装
3. エラーハンドリングの強化

## 📁 ファイル構成

```
github-copilot-demo/
├── .vscode/
│   └── mcp.json                 # VS Code MCP設定 (更新)
├── spec/                        # 仕様書・計画書
│   ├── 01-implementation-plan.md
│   ├── 02-architecture.md
│   ├── 03-configuration.md
│   └── 04-troubleshooting.md
├── pyproject.toml               # Python依存関係定義 (新規)
├── start-mysql-mcp.sh           # MCP起動スクリプト (新規)
├── docker-compose.yml           # MySQL環境 (既存)
├── init.sql                     # 初期データ (既存)
├── setup.sh                     # セットアップスクリプト (更新)
└── README.md                    # プロジェクト説明 (更新)
```

## 🚀 実装スケジュール

### 週1: 基盤整備 ✅ 完了

- [x] uvインストールスクリプト作成
- [x] pyproject.toml設定
- [x] Python環境テスト
- [x] MySQL接続テスト
- [x] 基本MCPサーバー起動スクリプト作成

### 週2: MCPサーバー移行 ✅ 完了

- [x] Python版MCPサーバーインストール
- [x] 起動スクリプト作成
- [x] mcp.json更新
- [x] 既存Node.js版のアンインストール
- [x] MCPサーバー動作確認

### 週3: 統合・テスト ✅ 完了

- [x] setup.shスクリプト統合
- [x] エンドツーエンドテスト
- [x] ドキュメント更新
- [x] 環境変数の問題解決

#### ✅ 解決済み課題

**解決**: MCPサーバー起動時の環境変数エラー

**解決方法**:

- VS CodeのMCP設定（`mcp.json`）を直接uvコマンド実行方式に変更
- 起動スクリプト経由ではなく、MCPクライアントが直接環境変数を管理
- GitHubリポジトリ推奨の設定方式を採用

**テスト結果**:

- ✅ MCPサーバーが正常起動
- ✅ MySQL接続が安定動作
- ✅ 環境変数が正しく渡される

### 週4: 最適化・完成

- [ ] パフォーマンステスト
- [ ] エラーハンドリング強化
- [ ] 最終検証

## 🔄 ロールバック計画

問題が発生した場合の復旧手順:

1. **即座復旧**: Node.js版への切り戻し
2. **データ保護**: MySQL環境は影響なし
3. **設定復元**: 旧mcp.jsonの復元

## 📊 成功指標

### 技術指標

- [x] Python MCPサーバーの正常起動
- [x] MySQL接続の安定性  
- [x] GitHub Copilot Chatからのクエリ実行

### ユーザビリティ指標

- [x] セットアップ時間の短縮
- [x] エラーメッセージの分かりやすさ
- [x] トラブルシューティングの容易さ

## 🔧 保守・運用計画

### 定期メンテナンス

- Python依存関係の更新
- MCPサーバーのバージョン管理
- セキュリティパッチの適用

### モニタリング

- 接続エラーの監視
- パフォーマンス指標の収集
- ユーザーフィードバックの分析

---

**作成日**: 2025年7月25日  
**最終更新**: 2025年7月26日  
**バージョン**: 2.0  
**ステータス**: ✅ 実装完了 - 週3タスク完了
