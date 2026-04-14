[English](../../README.md) | **中文** | [日本語](README.ja.md) | [한국어](README.ko.md)

<!-- last-synced-version: 1.2.0 -->

# everything-claude-unity

**为 Unity 游戏开发打造的终极 Claude Code 工具集。**

一套生产级、即插即用的系统，为 Claude Code 注入深度 Unity 专业知识——从编写高性能 C# 代码到构建场景、性能分析、触发 iOS/Android 构建——全部通过自然语言完成。

专为**独立手游开发者**打造。放入任何 Unity 项目即可使用。

---

## 核心组件

| 组件 | 数量 | 用途 |
|------|------|------|
| **Agents** | 15 | 专业子代理，涵盖编码、验证、场景构建、性能分析、测试 |
| **Commands** | 21 | 斜杠命令，如 `/unity-workflow`、`/unity-ralph`、`/unity-team` |
| **Skills** | 36 | 知识模块，覆盖 Unity 系统、游戏玩法模式和移动端类型 |
| **Hooks** | 22 | 安全防护、质量门禁、通知、会话持久化、自动学习 |
| **Rules** | 5 | C# 编码规范、性能规则、MVS 架构模式 |
| **Scripts** | 8 | 验证工具，检查 meta 文件、代码质量、序列化、架构 |
| **Templates** | 10 | MVS 模式的 C# 模板（Model、View、System、LifetimeScope、Message） |
| **Tests** | 46 | 针对 hooks、库工具函数和安装流程的自动化测试套件 |

---

## 功能亮点

### `/unity-workflow` — 完整开发流水线

一个结构化的四阶段流水线，适用于任何功能开发：**澄清（Clarify）**需求、**规划（Plan）**实现方案、由专业代理**执行（Execute）**、通过自动审查 + 修复循环进行**验证（Verify）**。

```
/unity-workflow "add a combo scoring system with multipliers and visual feedback"
```

### `/unity-prototype` — 一句话到可玩原型

描述一个游戏机制，Claude 会编写 C# 脚本、通过 MCP 构建场景、设置物理层、配置摄像机，并验证编译通过。

```
/unity-prototype "2D platformer with wall jumping and dash"
```

### `/unity-ralph` — 不达标不罢休的验证修复循环

持续运行验证-修复循环——在项目完全通过或达到安全上限前绝不停止。最多可执行 30 轮有效验证，并内置停滞检测。

```
/unity-ralph --max-iterations 10
```

### `/unity-team` — 并行代理协作

同时启动多个代理——编码 + 测试 + 审查并行运行，加速开发效率。

```
/unity-team --build "add health system with damage and healing"
```

### 验证-修复循环

`unity-verifier` 代理会自动审查代码更改，修复可安全处理的问题（缺少 `[FormerlySerializedAs]`、未缓存的 `GetComponent`、对 Unity 对象使用 `?.` 等），然后重新验证——最多迭代 3 次直到全部通过。该功能内置于 `/unity-workflow`，也可在 `/unity-feature` 和 `/unity-prototype` 中作为可选步骤使用。

### Hook 配置档

Hooks 分为三个配置档。通过设置 `UNITY_HOOK_PROFILE` 来控制运行哪些 hooks：

| 配置档 | 启用内容 | 适用场景 |
|--------|----------|----------|
| `minimal` | 仅安全类 hooks（阻止场景/meta 文件损坏、编辑器防护、pre-compact） | CI 流水线、经验丰富的开发者 |
| `standard` | 安全防护 + 质量告警 + 会话持久化 + 停止验证（默认） | 日常开发 |
| `strict` | 全部启用：GateGuard、成本追踪、自动学习、构建分析 | 新项目、学习阶段、审计 |

```bash
UNITY_HOOK_PROFILE=strict          # 启用所有 hooks，包括 GateGuard
UNITY_HOOK_PROFILE=minimal         # 仅启用关键安全 hooks
DISABLE_UNITY_HOOKS=1              # 完全跳过所有 hooks
UNITY_HOOK_MODE=warn               # 将阻断降级为警告
DISABLE_HOOK_BLOCK_SCENE_EDIT=1    # 禁用特定 hook
```

---

## 快速开始

### 前置要求
- 已安装 [Claude Code](https://claude.ai/claude-code)
- Unity 2021.3 LTS 或更高版本
- [unity-mcp](https://github.com/CoplayDev/unity-mcp)（可选，但推荐安装以获得完整流水线功能）

### 安装

```bash
# 在你的 Unity 项目根目录下执行：
git clone https://github.com/XeldarAlz/everything-claude-unity.git /tmp/ecu
/tmp/ecu/install.sh --project-dir .
rm -rf /tmp/ecu
```

或手动安装：
```bash
git clone https://github.com/XeldarAlz/everything-claude-unity.git
cp -r everything-claude-unity/.claude your-unity-project/.claude
chmod +x your-unity-project/.claude/hooks/*.sh
```

### 升级 / 卸载

```bash
# 升级到最新版本（保留你的自定义配置，自动创建备份）
./upgrade.sh --project-dir .

# 升级前预览变更内容
./upgrade.sh --project-dir . --dry-run

# 干净卸载（附带备份）
./uninstall.sh --project-dir .
```

### 配置 Unity MCP（推荐）

MCP 桥接使 Claude 能直接控制 Unity 编辑器——场景构建、性能分析、构建触发等。

1. 在 Unity 中：`Window > Package Manager > + > Add package from git URL`
2. 粘贴：`https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main`
3. 打开 `Window > MCP for Unity`，点击 **Start Server**
4. Claude Code 通过 `.claude/settings.json` 自动连接

### 首次运行

```bash
cd your-unity-project
claude

# 验证安装：
/unity-doctor         # 检查 MCP、hooks、项目结构

# 开始工作：
/unity-audit          # 全面的项目健康检查
/unity-workflow       # 完整流水线：澄清 → 规划 → 执行 → 验证
/unity-prototype      # 快速原型化游戏机制
```

---

## 代理（Agents）

### 代码代理
| 代理 | 模型 | 功能 |
|------|------|------|
| `unity-coder` | opus | 具备 Unity 子系统感知的功能实现，自动加载相关技能 |
| `unity-coder-lite` | sonnet | 适用于简单任务的轻量版（字段、方法、简单组件） |
| `unity-fixer` | opus | 利用 Unity 特有模式诊断 bug（引用缺失、执行顺序、协程生命周期） |
| `unity-fixer-lite` | sonnet | 快速修复明显问题（拼写错误、缺少 import、简单报错） |
| `unity-reviewer` | sonnet | 审查序列化安全性、热路径中的 GC、生命周期顺序 |
| `unity-shader-dev` | opus | 面向移动端 GPU 优化的 HLSL/ShaderGraph 开发，通过 MCP 实时测试 |

### 编排代理
| 代理 | 模型 | 功能 |
|------|------|------|
| `unity-verifier` | opus | 验证-修复循环：审查更改、自动修复安全问题、重新验证（最多 3 轮） |
| `unity-prototyper` | opus | 端到端原型构建：编写代码 + 构建场景 + 物理 + 摄像机 |

### MCP 驱动代理
| 代理 | 模型 | 功能 | 主要 MCP 工具 |
|------|------|------|---------------|
| `unity-scene-builder` | opus | 根据描述构建场景 | `manage_scene`, `batch_execute` |
| `unity-test-runner` | sonnet | 编写并运行测试，报告结果 | `run_tests`, `read_console` |
| `unity-build-runner` | sonnet | 配置并触发构建 | `manage_build`, `manage_packages` |
| `unity-optimizer` | opus | 分析并修复性能问题 | `manage_profiler`, `manage_graphics` |

### 混合代理
| 代理 | 模型 | 功能 |
|------|------|------|
| `unity-ui-builder` | opus | 通过代码 + MCP 可视化设置构建 UI 界面 |
| `unity-network-dev` | opus | 使用 Netcode/Mirror/Photon/Fish-Net 实现多人联网 |
| `unity-migrator` | sonnet | Unity 版本和渲染管线迁移 |

命令支持 `--quick`（路由到 sonnet lite 代理）和 `--thorough`（路由到 opus）标志。完整的路由表请参阅 [docs/MODEL-ROUTING.md](docs/MODEL-ROUTING.md)。

---

## 命令（Commands）

### 完整流水线
```
/unity-workflow <描述>   澄清 → 规划 → 执行 → 验证（推荐工作流）
```

### 日常开发
```
/unity-feature <描述>    规划 + 实现功能（--quick 适用于简单任务）
/unity-fix <bug 或报错>       诊断并修复 bug（--quick 适用于明显问题）
/unity-prototype <机制>     一句话到可玩原型
/unity-scene <描述>      通过 MCP 构建场景
/unity-shader <描述>     创建着色器并实时预览
/unity-ui <界面描述>  构建 UI 并进行可视化设置
/unity-network <框架>      配置多人联网
```

### 质量门禁
```
/unity-review [范围]           代码审查（--thorough 进行深度分析）
/unity-optimize                 通过 MCP 进行性能分析 + 修复瓶颈
/unity-test                     通过 MCP 编写并运行测试
/unity-audit                    全面的项目健康检查
/unity-profile                  深度性能分析会话
```

### 编排调度
```
/unity-ralph [选项]          持续验证-修复循环（不达标不停止）
/unity-team <--preset|--custom> 并行代理（编码 + 测试 + 审查同时进行）
/unity-interview <主题>        深度苏格拉底式需求访谈
/unity-learn [子命令]       会话分析：回顾、提取模式、草拟技能
```

### 项目生命周期
```
/unity-init                     扫描项目 + 生成 CLAUDE.md
/unity-build                    配置并触发构建
/unity-migrate                  规划版本/管线迁移
/unity-doctor                   诊断健康检查（MCP、hooks、项目结构）
```

---

## Hooks

跨 5 个生命周期事件的 22 个 hooks，按配置档级别组织。

### 阻断类 Hooks — PreToolUse（minimal 配置档）
| Hook | 防止的操作 |
|------|-----------|
| `block-scene-edit` | 直接文本编辑 .unity/.prefab YAML（会破坏引用关系） |
| `block-meta-edit` | 编辑 .meta 文件（会破坏资源 GUID） |
| `block-projectsettings` | 通过 git 暂存 ProjectSettings/（应使用 MCP 代替） |
| `guard-editor-runtime` | 运行时代码中使用 `UnityEditor` 命名空间而未加 `#if UNITY_EDITOR` 保护 |
| `guard-project-config` | 弱化代码质量规则（.editorconfig、分析器设置、.csproj NoWarn） |

### GateGuard — PreToolUse（strict 配置档）
| Hook | 功能 |
|------|------|
| `gateguard` | 在代理先 Read 文件之前，阻止对 C# 文件的 Edit/Write 操作。防止产生幻觉式更改。对于 MVS 文件，会建议同时阅读对应的 Model/System。 |

### 质量类 Hooks — PostToolUse（standard 配置档）
| Hook | 检测内容 |
|------|---------|
| `warn-serialization` | 重命名字段时缺少 `[FormerlySerializedAs]`（导致数据静默丢失） |
| `warn-filename` | C# 文件名与类名不匹配（脚本无法挂载） |
| `warn-platform-defines` | `#if UNITY_ANDROID` 缺少 `#else` 回退 |
| `quality-gate` | Update 中调用 GetComponent、游戏逻辑中使用 LINQ、对 Unity 对象使用 `?.`、未缓存的 Camera.main、SendMessage |
| `validate-commit` | 缺失的 .meta 文件、提交时的代码质量问题 |
| `suggest-verify` | 修改超过 5 个 C# 文件后建议运行 `/unity-review` |
| `build-analyze` | 构建后分析：着色器变体数量、包体大小、代码裁剪问题、已弃用 API |

### 追踪类 Hooks — PostToolUse（standard/strict 配置档）
| Hook | 记录内容 |
|------|---------|
| `track-edits` | 会话期间修改的文件（standard） |
| `track-reads` | 会话期间读取的文件——供 GateGuard 使用（strict） |
| `cost-tracker` | 每次工具调用及时间戳，用于会话指标统计（strict） |

### 会话类 Hooks — SessionStart / Stop
| Hook | 生命周期 | 功能 |
|------|----------|------|
| `session-restore` | SessionStart | 恢复之前的分支、工作流阶段、已修改文件列表 |
| `session-save` | Stop | 为下次对话保存会话状态（分支、编辑内容、持续时间） |
| `stop-validate` | Stop | 对会话期间修改的所有 C# 文件执行完整验证 |
| `auto-learn` | Stop | 将会话模式（MVS 分类、工具使用情况、类别）记录到学习日志 |
| `notify` | Stop | 当会话超过最短持续时间时发送 webhook 通知（Discord/Slack） |

### 建议类 Hooks — PreCompact
| Hook | 功能 |
|------|------|
| `pre-compact` | 在上下文压缩前保存 git 状态 |

所有 hooks 均支持通过环境变量进行单独禁用。详见上方的 [Hook 配置档](#hook-配置档)。

---

## MVS 架构模板

基于 **Model-View-System** 模式的模板，配合 VContainer、MessagePipe 和 UniTask 使用：

| 模板 | 用途 |
|------|------|
| `Model.cs.template` | 纯 C# 数据类，使用 `ReactiveProperty<T>`——无 Unity 依赖 |
| `System.cs.template` | 纯 C# 类，VContainer 构造函数注入，实现 `IDisposable` |
| `View.cs.template` | MonoBehaviour，通过 `Subscribe()` 观察 Model，方法注入 |
| `LifetimeScope.cs.template` | VContainer 组合根，注册 Model/System/View/MessagePipe |
| `Message.cs.template` | MessagePipe 专用的 `readonly struct`——零堆内存分配 |

另附基础模板：`MonoBehaviour.cs`、`ScriptableObject.cs`、`EditModeTest.cs`、`PlayModeTest.cs`、`AssemblyDefinition.asmdef`。

---

## 技能（Skills）

### 常驻核心技能（8）
- **serialization-safety** — `[FormerlySerializedAs]`、`[SerializeField]`、Unity 空值检查
- **scriptable-objects** — SO 事件通道、变量引用、运行时集合、工厂模式
- **event-systems** — C# 事件、UnityEvent、SO 通道、零分配 EventBus
- **object-pooling** — `ObjectPool<T>`、预热、归还池生命周期
- **assembly-definitions** — 何时拆分、引用规则、Editor/Runtime 分离
- **unity-mcp-patterns** — 如何高效使用 MCP 工具（`batch_execute`、`read_console`）
- **learner** — 调试后知识提取，含质量门禁和置信度评分
- **hud-statusline** — Claude Code 状态栏集成，显示工作流阶段和会话指标

### Unity 系统（10）
URP 管线、Input System、Addressables、Cinemachine、Animation、Audio、Physics、NavMesh、UI Toolkit、ShaderGraph

### 游戏玩法模式（6）
角色控制器（2D/3D）、背包系统、对话系统、存档系统、状态机、程序化生成

### 类型蓝图（8）— 移动端专属
超休闲、三消、放置/点击、无尽跑酷、益智、RPG、2D 平台跳跃、俯视角

### 第三方集成（5）
DOTween、UniTask、VContainer、TextMeshPro、Odin Inspector

### 平台（1）
移动端优化（iOS + Android）——触控输入、安全区域、ASTC 纹理、温控降频、电池管理

---

## 编码规则

本工具集通过 5 个始终加载的规则文件强制执行 Unity 最佳实践：

- **csharp-unity** — `[SerializeField] private` 配合 `m_` 前缀、默认 sealed、显式类型声明
- **performance** — Update 中零堆分配、缓存 GetComponent、对象池化、游戏逻辑中禁用 LINQ
- **serialization** — 重命名时必须加 `[FormerlySerializedAs]`、使用 `obj == null` 而非 `obj?.`
- **architecture** — MVS 模式、VContainer 依赖注入、MessagePipe 事件通信、UniTask 异步处理
- **unity-specifics** — Editor/Runtime 分离、线程安全、协程生命周期、`?.` 陷阱

---

## 验证脚本

运行以下脚本检查项目健康状态：

```bash
./scripts/validate-meta-integrity.sh --all    # 缺失/孤立的 .meta 文件、重复 GUID
./scripts/validate-code-quality.sh            # C# 代码中的性能隐患
./scripts/validate-asmdefs.sh                 # Assembly Definition 的循环依赖
./scripts/detect-missing-refs.sh              # 场景/预制体中的断裂引用
./scripts/analyze-build-size.sh               # 从 Editor.log 分析构建包体大小
./scripts/validate-serialization.sh           # 字段重命名缺少 FormerlySerializedAs
./scripts/validate-architecture.sh            # MVS 模式合规性检查
./scripts/generate-claude-md.sh > CLAUDE.md   # 自动生成项目 CLAUDE.md
```

---

## CLAUDE.md 示例文件

为移动游戏类型预置的配置模板：

- `examples/CLAUDE.md.hyper-casual` — 单击操作、极简视觉、广告变现
- `examples/CLAUDE.md.match3` — 网格系统、连锁消除、特殊方块、体力/能量
- `examples/CLAUDE.md.idle-clicker` — 大数值运算、离线收益、转生系统
- `examples/CLAUDE.md.mobile-casual` — 触控输入、小包体、广告集成
- `examples/CLAUDE.md.2d-platformer` — Tilemap、虚拟摇杆、移动端优化
- `examples/CLAUDE.md.rpg` — 属性系统、背包、对话、触控操作

---

## 架构

### 工作流流水线

```
/unity-workflow "add combo scoring"
    |
    +-- Phase 1: Clarify   -- 就需求、约束、目标平台进行访谈
    +-- Phase 2: Plan      -- 扫描项目结构，选择代理，呈现实现计划
    +-- Phase 3: Execute   -- 路由到 unity-coder / unity-prototyper / unity-ui-builder
    +-- Phase 4: Verify    -- unity-verifier 执行审查 → 自动修复 → 重新验证循环
```

### 代理交互

```
用户提示
    |
    v
Command（编排工作流）
    |
    +-->  Code Agent（编写 C# 脚本，加载相关技能）
    |       |
    |       +--> MCP Tools（创建 GameObject，配置组件）
    |
    +-->  Verifier Agent（审查更改，自动修复，重新验证）
    |
    +-->  Test Agent（通过 MCP 编写并运行测试）
    |
    +-->  Optimizer Agent（通过 MCP 进行性能分析，修复瓶颈）
```

### Hook 安全网

```
Claude 尝试编辑 PlayerView.cs
    |
    +-->  _lib.sh: 检查配置档级别和禁用开关
    +-->  PreToolUse: guard-editor-runtime.sh -- UnityEditor 防护
    +-->  PreToolUse: gateguard.sh -- 该文件是否已先被 Read？ [strict]
    |                               建议同时阅读 PlayerModel.cs
    |
    +-->  [编辑执行]
    |
    +-->  PostToolUse: warn-serialization.sh -- 字段重命名检查
    |                  quality-gate.sh -- Update 中有 GetComponent？LINQ？?.？
    |                  track-edits.sh -- 记录以供会话指标统计
    |
    +-->  [会话结束]
         +-->  stop-validate.sh -- 对所有已修改的 C# 文件执行完整检查
         +-->  session-save.sh -- 为下次对话持久化状态
         +-->  auto-learn.sh -- 将会话模式记录到日志
```

### 会话生命周期

```
SessionStart
    +-->  session-restore.sh -- 加载之前的状态（分支、阶段、文件列表）

[... 工作进行中，由 hooks 持续追踪 ...]

Stop
    +-->  stop-validate.sh -- 对所有已修改文件进行批量验证
    +-->  session-save.sh -- 将状态保存到 /tmp/unity-claude-hooks/
    +-->  auto-learn.sh -- 将会话指标追加写入 learnings.jsonl
```

---

## 文档

| 指南 | 内容 |
|------|------|
| [Getting Started](docs/GETTING-STARTED.md) | 安装、首次运行、常见问题排查 |
| [Architecture](docs/ARCHITECTURE.md) | 设计理念、组件概览、hook 系统、工作流流水线 |
| [Agent Guide](docs/AGENT-GUIDE.md) | 全部 15 个代理详解、使用场景、自定义方法 |
| [Model Routing](docs/MODEL-ROUTING.md) | 代理模型分配、`--quick`/`--thorough` 标志、成本权衡 |
| [MCP Setup](docs/MCP-SETUP.md) | unity-mcp 安装、验证、问题排查 |

---

## 贡献

请参阅 [CONTRIBUTING.md](CONTRIBUTING.md) 了解贡献指南。

欢迎在以下方面贡献：
- 新的移动游戏类型技能（塔防、竞速、卡牌/抽卡、模拟经营）
- 新的系统技能（ProBuilder、Spline、2D Animation）
- 移动平台技能（ARKit/ARCore、推送通知、深度链接）
- 移动端网络框架技能（FishNet、Dark Rift）
- Bug 报告和 hook 改进

---

## 许可证

MIT 许可证。详见 [LICENSE](LICENSE)。
