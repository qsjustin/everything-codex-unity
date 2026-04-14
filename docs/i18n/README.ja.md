[English](../../README.md) | [中文](README.zh-CN.md) | **日本語** | [한국어](README.ko.md)

<!-- last-synced-version: 1.2.0 -->

# everything-claude-unity

**Unity ゲーム開発のための究極の Claude Code ツールキット。**

Claude Code に Unity の深い専門知識を与える、本番環境対応のプラグ&プレイシステムです。パフォーマンスの高い C# の記述からシーン構築、パフォーマンスプロファイリング、iOS/Android ビルドのトリガーまで、すべて自然言語で操作できます。

**個人のインディーモバイルゲーム開発者**向けに設計されています。Unity プロジェクトに導入するだけですぐに使えます。

---

## 機能一覧

| コンポーネント | 数 | 用途 |
|-----------|-------|---------|
| **Agents** | 15 | コーディング、検証、シーン構築、プロファイリング、テスト用の専門サブエージェント |
| **Commands** | 17 | `/unity-workflow`、`/unity-prototype`、`/unity-doctor` などのスラッシュコマンド |
| **Skills** | 35 | Unity のシステム、ゲームプレイパターン、モバイルジャンルに関するナレッジモジュール |
| **Hooks** | 20 | セーフティネット、品質ゲート、セッション永続化、コスト追跡、自動学習 |
| **Rules** | 5 | C# コーディング規約、パフォーマンスルール、MVS アーキテクチャパターン |
| **Scripts** | 8 | meta ファイル、コード品質、シリアライゼーション、アーキテクチャの検証ツール |
| **Templates** | 10 | MVS パターン用の C# テンプレート（Model、View、System、LifetimeScope、Message） |

---

## 主な特徴

### `/unity-workflow` — フル開発パイプライン

あらゆる機能開発に対応する構造化された4フェーズパイプライン: 要件の**明確化（Clarify）**、実装の**計画（Plan）**、専門エージェントによる**実行（Execute）**、自動レビュー＋修正ループによる**検証（Verify）**。

```
/unity-workflow "add a combo scoring system with multipliers and visual feedback"
```

### `/unity-prototype` — ワンプロンプトでプレイアブルに

メカニクスを説明するだけで、Claude が C# スクリプトの記述、MCP によるシーン構築、物理レイヤーの設定、カメラの設定を行い、コンパイルが通ることを確認します。

```
/unity-prototype "2D platformer with wall jumping and dash"
```

### 検証-修正ループ

`unity-verifier` エージェントがコード変更を自動的にレビューし、安全な問題（`[FormerlySerializedAs]` の欠落、キャッシュされていない `GetComponent`、Unity オブジェクトへの `?.` 使用など）を修正し、最大3回の反復で問題がなくなるまで再検証します。`/unity-workflow` に組み込まれており、`/unity-feature` や `/unity-prototype` ではオプションのステップとして利用可能です。

### フックプロファイル

フックは3つのプロファイルに整理されています。`UNITY_HOOK_PROFILE` を設定して実行するフックを制御できます:

| プロファイル | 有効な機能 | 推奨用途 |
|---------|--------------|----------|
| `minimal` | セーフティフックのみ（シーン/meta 破損のブロック、エディタガード、pre-compact） | CI パイプライン、経験豊富な開発者向け |
| `standard` | セーフティ＋品質警告＋セッション永続化＋停止時バリデーション（デフォルト） | 日常の開発作業 |
| `strict` | すべて: GateGuard、コスト追跡、自動学習、ビルド解析 | 新規プロジェクト、学習、監査 |

```bash
UNITY_HOOK_PROFILE=strict          # GateGuard を含むすべてのフックを有効化
UNITY_HOOK_PROFILE=minimal         # 重要なセーフティフックのみ
DISABLE_UNITY_HOOKS=1              # すべてのフックを完全にバイパス
UNITY_HOOK_MODE=warn               # ブロックを警告にダウングレード
DISABLE_HOOK_BLOCK_SCENE_EDIT=1    # 特定のフックを無効化
```

---

## クイックスタート

### 前提条件
- [Claude Code](https://claude.ai/claude-code) がインストール済み
- Unity 2021.3 LTS 以降
- [unity-mcp](https://github.com/CoplayDev/unity-mcp)（任意、フルパイプライン利用には推奨）

### インストール

```bash
# Unity プロジェクトのルートから:
git clone https://github.com/XeldarAlz/everything-claude-unity.git /tmp/ecu
/tmp/ecu/install.sh --project-dir .
rm -rf /tmp/ecu
```

手動インストール:
```bash
git clone https://github.com/XeldarAlz/everything-claude-unity.git
cp -r everything-claude-unity/.claude your-unity-project/.claude
chmod +x your-unity-project/.claude/hooks/*.sh
```

### アップグレード / アンインストール

```bash
# 最新版にアップグレード（カスタマイズを保持し、バックアップを作成）
./upgrade.sh --project-dir .

# アップグレード前に変更点をプレビュー
./upgrade.sh --project-dir . --dry-run

# クリーンアンインストール（バックアップ付き）
./uninstall.sh --project-dir .
```

### Unity MCP のセットアップ（推奨）

MCP ブリッジにより、Claude が Unity エディタを直接操作できるようになります。シーン構築、プロファイリング、ビルドなどが可能です。

1. Unity で: `Window > Package Manager > + > Add package from git URL`
2. 以下を貼り付け: `https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main`
3. `Window > MCP for Unity` を開き、**Start Server** をクリック
4. Claude Code が `.claude/settings.json` 経由で自動接続

### 初回実行

```bash
cd your-unity-project
claude

# インストールの確認:
/unity-doctor         # MCP、フック、プロジェクト構造をチェック

# 作業開始:
/unity-audit          # プロジェクト全体のヘルスチェック
/unity-workflow       # フルパイプライン: 明確化 → 計画 → 実行 → 検証
/unity-prototype      # ゲームメカニクスの高速プロトタイプ
```

---

## エージェント

### コードエージェント
| エージェント | モデル | 機能 |
|-------|-------|-------------|
| `unity-coder` | opus | Unity サブシステムを考慮した機能実装、関連スキルの読み込み |
| `unity-coder-lite` | sonnet | シンプルな追加作業向けの軽量版（フィールド、メソッド、単純なコンポーネント） |
| `unity-fixer` | opus | Unity 固有のパターン（参照の欠落、実行順序、コルーチンのライフサイクル）によるバグ診断 |
| `unity-fixer-lite` | sonnet | 明らかな問題のクイックフィックス（タイプミス、import の欠落、単純なエラー） |
| `unity-reviewer` | sonnet | シリアライゼーションの安全性、ホットパスでの GC、ライフサイクル順序のコードレビュー |
| `unity-shader-dev` | opus | モバイル GPU 向けに最適化された HLSL/ShaderGraph 開発、MCP によるライブテスト |

### オーケストレーションエージェント
| エージェント | モデル | 機能 |
|-------|-------|-------------|
| `unity-verifier` | opus | 検証-修正ループ: 変更をレビューし、安全な問題を自動修正、再検証（最大3回） |
| `unity-prototyper` | opus | エンドツーエンドのプロトタイピング: コード記述＋シーン構築＋物理＋カメラ |

### MCP 対応エージェント
| エージェント | モデル | 機能 | 主な MCP ツール |
|-------|-------|-------------|---------------|
| `unity-scene-builder` | opus | 説明からシーンを構築 | `manage_scene`, `batch_execute` |
| `unity-test-runner` | sonnet | テストの作成＋実行、結果レポート | `run_tests`, `read_console` |
| `unity-build-runner` | sonnet | ビルドの設定とトリガー | `manage_build`, `manage_packages` |
| `unity-optimizer` | opus | パフォーマンスの問題をプロファイリングして修正 | `manage_profiler`, `manage_graphics` |

### ハイブリッドエージェント
| エージェント | モデル | 機能 |
|-------|-------|-------------|
| `unity-ui-builder` | opus | コード＋MCP によるビジュアルセットアップで UI 画面を構築 |
| `unity-network-dev` | opus | Netcode/Mirror/Photon/Fish-Net によるマルチプレイヤー実装 |
| `unity-migrator` | sonnet | Unity バージョンおよびレンダーパイプラインの移行 |

コマンドは `--quick`（sonnet lite エージェントにルーティング）および `--thorough`（opus にルーティング）フラグに対応しています。完全なルーティングテーブルは [docs/MODEL-ROUTING.md](docs/MODEL-ROUTING.md) を参照してください。

---

## コマンド

### フルパイプライン
```
/unity-workflow <説明>   明確化 → 計画 → 実行 → 検証（推奨ワークフロー）
```

### 日常のワークフロー
```
/unity-feature <説明>    機能の計画＋実装（--quick で簡単なタスク向け）
/unity-fix <バグやエラー>       バグの診断と修正（--quick で明らかな修正向け）
/unity-prototype <メカニクス>     ワンプロンプトでプレイアブルプロトタイプ
/unity-scene <説明>      MCP によるシーン構築
/unity-shader <説明>     ライブプレビュー付きシェーダー作成
/unity-ui <画面の説明>  ビジュアルセットアップ付き UI 構築
/unity-network <フレームワーク>      マルチプレイヤーのセットアップ
```

### 品質ゲート
```
/unity-review [スコープ]           コードレビュー（--thorough で詳細な分析）
/unity-optimize                 MCP によるプロファイリング＋ボトルネック修正
/unity-test                     MCP によるテスト作成＋実行
/unity-audit                    プロジェクト全体のヘルスチェック
/unity-profile                  詳細プロファイリングセッション
```

### プロジェクトライフサイクル
```
/unity-init                     プロジェクトのスキャン＋CLAUDE.md の自動生成
/unity-build                    ビルドの設定＋トリガー
/unity-migrate                  バージョン/パイプライン移行の計画
/unity-doctor                   診断ヘルスチェック（MCP、フック、プロジェクト構造）
```

---

## フック

5つのライフサイクルイベントにわたる20のフックがプロファイルレベル別に整理されています。

### ブロッキングフック — PreToolUse（minimal プロファイル）
| フック | 防止する内容 |
|------|-----------------|
| `block-scene-edit` | .unity/.prefab YAML の直接テキスト編集（参照の破損を防止） |
| `block-meta-edit` | .meta ファイルの編集（アセット GUID の破損を防止） |
| `block-projectsettings` | git による ProjectSettings/ のステージング（代わりに MCP を使用） |
| `guard-editor-runtime` | `#if UNITY_EDITOR` ガードなしのランタイムコードでの `UnityEditor` 名前空間の使用 |

### GateGuard — PreToolUse（strict プロファイル）
| フック | 機能 |
|------|-------------|
| `gateguard` | エージェントが C# ファイルを先に Read するまで Edit/Write をブロック。幻覚による変更を防止。MVS ファイルの場合は、対応する Model/System の読み取りを提案。 |

### 品質フック — PostToolUse（standard プロファイル）
| フック | 検出する内容 |
|------|----------------|
| `warn-serialization` | `[FormerlySerializedAs]` なしのフィールド名変更（サイレントなデータ消失） |
| `warn-filename` | C# ファイル名とクラス名の不一致（スクリプトがアタッチ不可に） |
| `warn-platform-defines` | `#else` フォールバックなしの `#if UNITY_ANDROID` |
| `quality-gate` | Update 内の GetComponent、ゲームプレイでの LINQ、Unity オブジェクトへの `?.`、キャッシュされていない Camera.main、SendMessage |
| `validate-commit` | .meta ファイルの欠落、コミット時のコード品質問題 |
| `suggest-verify` | 5つ以上の C# ファイル変更後に `/unity-review` を提案 |
| `build-analyze` | ビルド後: シェーダーバリアント数、サイズ、ストリッピングの問題、非推奨 API |

### トラッキングフック — PostToolUse（standard/strict プロファイル）
| フック | 記録する内容 |
|------|----------------|
| `track-edits` | セッション中に変更されたファイル（standard） |
| `track-reads` | セッション中に読み取られたファイル — GateGuard にフィード（strict） |
| `cost-tracker` | タイムスタンプ付きのすべてのツール呼び出し（セッションメトリクス用、strict） |

### セッションフック — SessionStart / Stop
| フック | ライフサイクル | 機能 |
|------|-----------|-------------|
| `session-restore` | SessionStart | 前回のブランチ、ワークフローフェーズ、変更ファイルリストを復元 |
| `session-save` | Stop | 次の会話のためにセッション状態を保存（ブランチ、編集、所要時間） |
| `stop-validate` | Stop | セッション中に変更されたすべての C# ファイルに対してフルファイルバリデーションを実行 |
| `auto-learn` | Stop | セッションパターン（MVS 分類、ツール使用状況）をラーニングログに記録 |

### アドバイザリフック — PreCompact
| フック | 機能 |
|------|-------------|
| `pre-compact` | コンテキスト圧縮前に git 状態を保存 |

すべてのフックは環境変数によるキルスイッチに対応しています。上記の[フックプロファイル](#フックプロファイル)を参照してください。

---

## MVS アーキテクチャテンプレート

VContainer、MessagePipe、UniTask を使用した **Model-View-System** パターンのテンプレート:

| テンプレート | 用途 |
|----------|---------|
| `Model.cs.template` | `ReactiveProperty<T>` を持つ純粋な C# データクラス — Unity 依存なし |
| `System.cs.template` | VContainer コンストラクタインジェクション付きの純粋な C# クラス、`IDisposable` |
| `View.cs.template` | `Subscribe()` で Model を監視する MonoBehaviour、メソッドインジェクション |
| `LifetimeScope.cs.template` | Model/System/View/MessagePipe を登録する VContainer コンポジションルート |
| `Message.cs.template` | MessagePipe 用の `readonly struct` — ヒープアロケーションゼロ |

加えて、既存のテンプレート: `MonoBehaviour.cs`、`ScriptableObject.cs`、`EditModeTest.cs`、`PlayModeTest.cs`、`AssemblyDefinition.asmdef`。

---

## スキル

### 常時有効なコアスキル（6）
- **serialization-safety** — `[FormerlySerializedAs]`、`[SerializeField]`、Unity の null チェック
- **scriptable-objects** — SO イベントチャンネル、変数参照、ランタイムセット、ファクトリパターン
- **event-systems** — C# イベント、UnityEvent、SO チャンネル、ゼロアロケーション EventBus
- **object-pooling** — `ObjectPool<T>`、ウォームアップ、プールへの返却ライフサイクル
- **assembly-definitions** — 分割のタイミング、参照ルール、Editor/Runtime の分離
- **unity-mcp-patterns** — MCP ツールの効果的な使い方（`batch_execute`、`read_console`）

### Unity システム（10）
URP パイプライン、Input System、Addressables、Cinemachine、Animation、Audio、Physics、NavMesh、UI Toolkit、ShaderGraph

### ゲームプレイパターン（6）
キャラクターコントローラー（2D/3D）、インベントリシステム、ダイアログシステム、セーブシステム、ステートマシン、プロシージャル生成

### ジャンルブループリント（8） — モバイル特化
ハイパーカジュアル、マッチ3、放置/クリッカー、エンドレスランナー、パズル、RPG、2D プラットフォーマー、トップダウン

### サードパーティ（5）
DOTween、UniTask、VContainer、TextMeshPro、Odin Inspector

### プラットフォーム（1）
モバイル最適化（iOS + Android） — タッチ入力、セーフエリア、ASTC テクスチャ、サーマルスロットリング、バッテリー管理

---

## コーディングルール

本ツールキットは、常時読み込まれる5つのルールファイルで Unity のベストプラクティスを強制します:

- **csharp-unity** — `[SerializeField] private` と `m_` プレフィックス、デフォルトで sealed、明示的な型指定
- **performance** — Update でのゼロアロケーション、GetComponent のキャッシュ、オブジェクトプーリング、ゲームプレイでの LINQ 禁止
- **serialization** — リネーム時に `[FormerlySerializedAs]`、`obj?.` ではなく `obj == null`
- **architecture** — MVS パターン、DI に VContainer、イベントに MessagePipe、非同期に UniTask
- **unity-specifics** — Editor/Runtime の分離、スレッディング、コルーチンのライフサイクル、`?.` の危険性

---

## バリデーションスクリプト

プロジェクトの健全性を確認するために以下を実行してください:

```bash
./scripts/validate-meta-integrity.sh --all    # .meta ファイルの欠落/孤立、GUID の重複
./scripts/validate-code-quality.sh            # C# コードのパフォーマンス上の問題
./scripts/validate-asmdefs.sh                 # Assembly Definition の循環依存
./scripts/detect-missing-refs.sh              # シーン/プレハブの壊れた参照
./scripts/analyze-build-size.sh               # Editor.log からのビルドサイズ分析
./scripts/validate-serialization.sh           # FormerlySerializedAs が欠落したフィールドのリネーム
./scripts/validate-architecture.sh            # MVS パターン準拠チェック
./scripts/generate-claude-md.sh > CLAUDE.md   # プロジェクト用 CLAUDE.md の自動生成
```

---

## CLAUDE.md のサンプルファイル

モバイルゲームタイプ別の設定済みテンプレート:

- `examples/CLAUDE.md.hyper-casual` — ワンタップ操作、ミニマルなビジュアル、広告マネタイズ
- `examples/CLAUDE.md.match3` — グリッドシステム、カスケード、スペシャルタイル、ライフ/エナジー
- `examples/CLAUDE.md.idle-clicker` — 巨大な数値、オフライン進行、プレステージシステム
- `examples/CLAUDE.md.mobile-casual` — タッチ入力、小さなビルドサイズ、広告連携
- `examples/CLAUDE.md.2d-platformer` — Tilemap、バーチャルジョイスティック、モバイル最適化
- `examples/CLAUDE.md.rpg` — ステータス、インベントリ、ダイアログ、タッチ操作

---

## アーキテクチャ

### ワークフローパイプライン

```
/unity-workflow "add combo scoring"
    |
    +-- Phase 1: Clarify   -- 要件、制約、プラットフォームについてヒアリング
    +-- Phase 2: Plan      -- プロジェクトをスキャンし、エージェントを選択、実装計画を提示
    +-- Phase 3: Execute   -- unity-coder / unity-prototyper / unity-ui-builder にルーティング
    +-- Phase 4: Verify    -- unity-verifier がレビュー → 自動修正 → 再検証ループを実行
```

### エージェント間の連携

```
ユーザープロンプト
    |
    v
Command（ワークフローをオーケストレーション）
    |
    +-->  Code Agent（C# スクリプトを記述、関連スキルを読み込み）
    |       |
    |       +--> MCP Tools（GameObject の作成、コンポーネントの設定）
    |
    +-->  Verifier Agent（変更をレビュー、自動修正、再検証）
    |
    +-->  Test Agent（MCP 経由でテスト作成＋実行）
    |
    +-->  Optimizer Agent（MCP 経由でプロファイリング、ボトルネック修正）
```

### フックセーフティネット

```
Claude が PlayerView.cs を編集しようとする
    |
    +-->  _lib.sh: プロファイルレベル、キルスイッチをチェック
    +-->  PreToolUse: guard-editor-runtime.sh -- UnityEditor ガード
    +-->  PreToolUse: gateguard.sh -- このファイルは先に Read されたか？ [strict]
    |                               PlayerModel.cs の読み取りも提案
    |
    +-->  [編集が実行される]
    |
    +-->  PostToolUse: warn-serialization.sh -- フィールド名変更チェック
    |                  quality-gate.sh -- Update 内の GetComponent？ LINQ？ ?.？
    |                  track-edits.sh -- セッションメトリクス用に記録
    |
    +-->  [セッション終了]
         +-->  stop-validate.sh -- 変更された全 C# のフルファイルチェック
         +-->  session-save.sh -- 次の会話のために状態を永続化
         +-->  auto-learn.sh -- セッションパターンをログに記録
```

### セッションライフサイクル

```
SessionStart
    +-->  session-restore.sh -- 前回の状態を読み込み（ブランチ、フェーズ、ファイル）

[... フックによって追跡される作業 ...]

Stop
    +-->  stop-validate.sh -- 変更された全ファイルのバッチバリデーション
    +-->  session-save.sh -- /tmp/unity-claude-hooks/ に状態を保存
    +-->  auto-learn.sh -- セッションメトリクスを learnings.jsonl に追記
```

---

## ドキュメント

| ガイド | 内容 |
|-------|---------|
| [Getting Started](docs/GETTING-STARTED.md) | インストール、初回実行、トラブルシューティング |
| [Architecture](docs/ARCHITECTURE.md) | 設計思想、コンポーネント概要、フックシステム、ワークフローパイプライン |
| [Agent Guide](docs/AGENT-GUIDE.md) | 全15エージェント、使い分け、カスタマイズ |
| [Model Routing](docs/MODEL-ROUTING.md) | エージェントモデルの割り当て、`--quick`/`--thorough` フラグ、コストのトレードオフ |
| [MCP Setup](docs/MCP-SETUP.md) | unity-mcp のインストール、動作確認、トラブルシューティング |

---

## コントリビューション

ガイドラインは [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

貢献を歓迎する主な分野:
- 新しいモバイルジャンルスキル（タワーディフェンス、レーシング、カード/ガチャ、シミュレーション）
- 新しいシステムスキル（ProBuilder、Spline、2D Animation）
- モバイルプラットフォームスキル（ARKit/ARCore、通知、ディープリンク）
- モバイル向けネットワーキングフレームワークスキル（FishNet、Dark Rift）
- バグ報告とフックの改善

---

## ライセンス

MIT License。詳細は [LICENSE](LICENSE) を参照してください。
