# Model Routing Guide

## Overview

Agents use different Claude models based on task complexity. **Opus** handles creative, multi-step reasoning. **Sonnet** handles structured analysis and simpler implementations. This optimizes cost and latency without sacrificing quality where it matters.

## Agent Model Assignments

| Agent | Model | Rationale |
|-------|-------|-----------|
| **unity-coder** | opus | Multi-system features need architectural reasoning |
| **unity-coder-lite** | sonnet | Simple additions (fields, methods, single components) |
| **unity-prototyper** | opus | End-to-end prototyping requires creativity + planning |
| **unity-fixer** | opus | Complex bugs need deep investigation and reasoning |
| **unity-fixer-lite** | sonnet | Obvious fixes (typos, missing imports, simple errors) |
| **unity-verifier** | opus | Verify-fix loop needs judgment about what's safe to fix |
| **unity-optimizer** | opus | Performance analysis requires understanding trade-offs |
| **unity-ui-builder** | opus | UI layout + responsive design needs creative decisions |
| **unity-shader-dev** | opus | Shader math and HLSL need precision and creativity |
| **unity-network-dev** | opus | Networking architecture is inherently complex |
| **unity-scene-builder** | opus | Scene composition needs spatial reasoning |
| **unity-reviewer** | sonnet | Checklist-based review is structured, not creative |
| **unity-test-runner** | sonnet | Test writing follows patterns, not deep reasoning |
| **unity-build-runner** | sonnet | Build config is procedural, not creative |
| **unity-migrator** | sonnet | Migration follows documented upgrade paths |

## Command Flags

### `--quick` (faster, cheaper)

Routes to the sonnet-tier lite agent instead of the default opus agent.

```bash
/unity-feature --quick "add a health field to PlayerModel"
/unity-fix --quick "missing using statement in GameManager"
```

**Use when:**
- The task is straightforward with an obvious solution
- You're making a small, localized change
- Speed matters more than depth of reasoning

### `--thorough` (deeper analysis)

Routes to opus for tasks that normally use sonnet.

```bash
/unity-review --thorough "review the entire combat system"
```

**Use when:**
- You want deeper architectural analysis
- The review covers complex, interconnected systems
- You're preparing for a major release

## Cost/Latency Trade-offs

| Model | Relative Cost | Relative Speed | Best For |
|-------|--------------|----------------|----------|
| **Opus** | Higher | Slower | Creative work, complex reasoning, multi-step tasks |
| **Sonnet** | Lower | Faster | Structured tasks, reviews, simple implementations |

## Guidelines for New Agents

When creating a new agent:
1. **Default to sonnet** — upgrade to opus only if the task requires multi-step reasoning or creative generation
2. **Create a lite variant** only if the command is frequently used for both simple and complex tasks
3. **Document the routing** in the command file with clear "good fit" / "not good fit" lists
