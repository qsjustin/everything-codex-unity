[English](../../README.md) | [中文](README.zh-CN.md) | [日本語](README.ja.md) | **한국어**

<!-- last-synced-version: 1.2.0 -->

# everything-codex-unity

**Unity 게임 개발을 위한 최고의 Codex 툴킷.**

Codex에 Unity 전문 지식을 부여하는 프로덕션 수준의 플러그 앤 플레이 시스템입니다. 고성능 C# 작성부터 씬 구성, 성능 프로파일링, iOS/Android 빌드 실행까지 모두 자연어로 제어할 수 있습니다.

**1인 인디 모바일 게임 개발자**를 위해 설계되었습니다. 어떤 Unity 프로젝트에든 넣기만 하면 바로 동작합니다.

---

## 구성 요소

| 구성 요소 | 수량 | 용도 |
|-----------|------|------|
| **Agents** | 15 | 코딩, 검증, 씬 구성, 프로파일링, 테스트를 위한 전문 서브 에이전트 |
| **Commands** | 17 | `/unity-workflow`, `/unity-prototype`, `/unity-doctor` 등의 슬래시 명령어 |
| **Skills** | 35 | Unity 시스템, 게임플레이 패턴, 모바일 장르별 지식 모듈 |
| **Hooks** | 20 | 안전 장치, 품질 게이트, 세션 영속성, 비용 추적, 자동 학습 |
| **Rules** | 5 | C# 코딩 표준, 성능 규칙, MVS 아키텍처 패턴 |
| **Scripts** | 8 | meta 파일, 코드 품질, 직렬화, 아키텍처 검증 도구 |
| **Templates** | 10 | MVS 패턴(Model, View, System, LifetimeScope, Message)용 C# 템플릿 |

---

## 주요 기능

### `/unity-workflow` — 전체 개발 파이프라인

모든 기능 개발을 위한 4단계 구조화된 파이프라인: 요구사항 **확인(Clarify)**, 구현 **계획(Plan)**, 전문 에이전트를 통한 **실행(Execute)**, 자동 리뷰 + 수정 루프를 통한 **검증(Verify)**.

```
/unity-workflow "add a combo scoring system with multipliers and visual feedback"
```

### `/unity-prototype` — 한 줄 프롬프트로 플레이 가능한 프로토타입 완성

메카닉을 설명하면 Codex가 C# 스크립트를 작성하고, MCP를 통해 씬을 구성하고, 물리 레이어를 설정하고, 카메라를 조정하고, 컴파일 여부까지 확인합니다.

```
/unity-prototype "2D platformer with wall jumping and dash"
```

### Verify-Fix 루프

`unity-verifier` 에이전트가 코드 변경 사항을 자동으로 리뷰하고, 안전한 문제(`[FormerlySerializedAs]` 누락, 캐시되지 않은 `GetComponent`, Unity 객체에 대한 `?.` 사용 등)를 수정한 뒤, 코드가 깨끗해질 때까지 최대 3회 반복 검증합니다. `/unity-workflow`에 내장되어 있으며 `/unity-feature` 및 `/unity-prototype`에서 선택적으로 사용 가능합니다.

### Hook 프로파일

Hook은 세 가지 프로파일로 구성됩니다. `UNITY_HOOK_PROFILE`을 설정하여 실행할 Hook을 제어합니다:

| 프로파일 | 활성화 항목 | 적합한 용도 |
|----------|------------|------------|
| `minimal` | 안전 Hook만 (씬/meta 파일 손상 방지, 에디터 가드, pre-compact) | CI 파이프라인, 숙련된 개발자 |
| `standard` | 안전 + 품질 경고 + 세션 영속성 + 종료 시 검증 (기본값) | 일상적인 개발 |
| `strict` | 모든 기능: GateGuard, 비용 추적, 자동 학습, 빌드 분석 | 신규 프로젝트, 학습, 감사 |

```bash
UNITY_HOOK_PROFILE=strict          # GateGuard 포함 모든 Hook 활성화
UNITY_HOOK_PROFILE=minimal         # 핵심 안전 Hook만 활성화
DISABLE_UNITY_HOOKS=1              # 모든 Hook 비활성화
UNITY_HOOK_MODE=warn               # 차단을 경고로 전환
DISABLE_HOOK_BLOCK_SCENE_EDIT=1    # 특정 Hook 비활성화
```

---

## 빠른 시작

### 사전 요구 사항
- [Codex](https://openai.com/codex) 설치
- Unity 2021.3 LTS 이상
- [unity-mcp](https://github.com/CoplayDev/unity-mcp) (선택 사항이지만 전체 파이프라인 활용 시 권장)

### 설치

```bash
# Unity 프로젝트 루트에서 실행:
git clone https://github.com/qsjustin/everything-codex-unity.git /tmp/ecu
/tmp/ecu/install.sh --project-dir .
rm -rf /tmp/ecu
```

수동 설치:
```bash
git clone https://github.com/qsjustin/everything-codex-unity.git
cp -r everything-codex-unity/.codex-plugin everything-codex-unity/skills everything-codex-unity/.mcp.json everything-codex-unity/.codex-legacy your-unity-project/
chmod +x your-unity-project/.codex-legacy/hooks/*.sh
```

### 업그레이드 / 제거

```bash
# 최신 버전으로 업그레이드 (사용자 설정 유지, 백업 생성)
./upgrade.sh --project-dir .

# 업그레이드 전 변경 사항 미리 확인
./upgrade.sh --project-dir . --dry-run

# 완전 제거 (백업 포함)
./uninstall.sh --project-dir .
```

### Unity MCP 설정 (권장)

MCP 브릿지를 통해 Codex가 Unity 에디터를 직접 제어할 수 있습니다 -- 씬 구성, 프로파일링, 빌드 등.

1. Unity에서: `Window > Package Manager > + > Add package from git URL`
2. 다음 URL을 입력: `https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main`
3. `Window > MCP for Unity`를 열고 **Start Server** 클릭
4. Codex가 `.mcp.json`을 통해 자동 연결

### 첫 실행

```bash
cd your-unity-project
codex

# 설치 확인:
/unity-doctor         # MCP, Hook, 프로젝트 구조 점검

# 작업 시작:
/unity-audit          # 전체 프로젝트 상태 점검
/unity-workflow       # 전체 파이프라인: 확인 → 계획 → 실행 → 검증
/unity-prototype      # 게임 메카닉 빠른 프로토타이핑
```

---

## Agents

### 코드 에이전트
| 에이전트 | 모델 | 기능 |
|----------|------|------|
| `unity-coder` | opus | Unity 서브시스템 인식 기반 기능 구현, 관련 스킬 자동 로드 |
| `unity-coder-lite` | sonnet | 단순한 추가 작업(필드, 메서드, 간단한 컴포넌트)을 위한 경량 버전 |
| `unity-fixer` | opus | Unity 특화 패턴(누락된 레퍼런스, 실행 순서, 코루틴 수명 주기)을 활용한 버그 진단 |
| `unity-fixer-lite` | sonnet | 명백한 문제(오타, 누락된 import, 단순 오류) 빠른 수정 |
| `unity-reviewer` | sonnet | 직렬화 안전성, 핫 경로 GC, 수명 주기 순서 등을 점검하는 코드 리뷰 |
| `unity-shader-dev` | opus | 모바일 GPU에 최적화된 HLSL/ShaderGraph 개발, MCP를 통한 실시간 테스트 |

### 오케스트레이션 에이전트
| 에이전트 | 모델 | 기능 |
|----------|------|------|
| `unity-verifier` | opus | Verify-Fix 루프: 변경 사항 리뷰, 안전한 문제 자동 수정, 재검증 (최대 3회 반복) |
| `unity-prototyper` | opus | 엔드투엔드 프로토타이핑: 코드 작성 + 씬 구성 + 물리 + 카메라 |

### MCP 기반 에이전트
| 에이전트 | 모델 | 기능 | 주요 MCP 도구 |
|----------|------|------|--------------|
| `unity-scene-builder` | opus | 설명을 기반으로 씬 구성 | `manage_scene`, `batch_execute` |
| `unity-test-runner` | sonnet | 테스트 작성 + 실행, 결과 보고 | `run_tests`, `read_console` |
| `unity-build-runner` | sonnet | 빌드 설정 및 실행 | `manage_build`, `manage_packages` |
| `unity-optimizer` | opus | 성능 프로파일링 및 최적화 | `manage_profiler`, `manage_graphics` |

### 하이브리드 에이전트
| 에이전트 | 모델 | 기능 |
|----------|------|------|
| `unity-ui-builder` | opus | 코드 + MCP를 통한 시각적 UI 화면 구성 |
| `unity-network-dev` | opus | Netcode/Mirror/Photon/Fish-Net 기반 멀티플레이어 구현 |
| `unity-migrator` | sonnet | Unity 버전 및 렌더 파이프라인 마이그레이션 |

명령어는 `--quick`(sonnet lite 에이전트로 라우팅) 및 `--thorough`(opus로 라우팅) 플래그를 지원합니다. 전체 라우팅 테이블은 [docs/MODEL-ROUTING.md](docs/MODEL-ROUTING.md)를 참조하세요.

---

## Commands

### 전체 파이프라인
```
/unity-workflow <설명>             확인 → 계획 → 실행 → 검증 (권장 워크플로)
```

### 일상 작업
```
/unity-feature <설명>              기능 계획 + 구현 (--quick으로 간단한 작업 처리)
/unity-fix <버그 또는 오류>         버그 진단 및 수정 (--quick으로 명백한 문제 처리)
/unity-prototype <메카닉>          한 줄 프롬프트로 프로토타입 완성
/unity-scene <설명>                MCP를 통한 씬 구성
/unity-shader <설명>               실시간 프리뷰와 함께 셰이더 생성
/unity-ui <화면 설명>              시각적 UI 구성
/unity-network <프레임워크>         멀티플레이어 설정
```

### 품질 게이트
```
/unity-review [범위]               코드 리뷰 (--thorough로 심층 분석)
/unity-optimize                    MCP 프로파일링 + 병목 해결
/unity-test                        MCP를 통한 테스트 작성 + 실행
/unity-audit                       전체 프로젝트 상태 점검
/unity-profile                     심층 프로파일링 세션
```

### 프로젝트 수명 주기
```
/unity-init                        프로젝트 스캔 + AGENTS.md 생성
/unity-build                       빌드 설정 + 실행
/unity-migrate                     버전/파이프라인 마이그레이션 계획
/unity-doctor                      진단 점검 (MCP, Hook, 프로젝트 구조)
```

---

## Hooks

5개 수명 주기 이벤트에 걸친 20개 Hook이 프로파일 수준별로 구성되어 있습니다.

### 차단 Hook -- PreToolUse (minimal 프로파일)
| Hook | 방지 대상 |
|------|----------|
| `block-scene-edit` | .unity/.prefab YAML 파일 직접 편집 (레퍼런스 손상 방지) |
| `block-meta-edit` | .meta 파일 편집 (에셋 GUID 깨짐 방지) |
| `block-projectsettings` | git을 통한 ProjectSettings/ 스테이징 (MCP 사용 권장) |
| `guard-editor-runtime` | `#if UNITY_EDITOR` 없이 런타임 코드에서 `UnityEditor` 네임스페이스 사용 |

### GateGuard -- PreToolUse (strict 프로파일)
| Hook | 기능 |
|------|------|
| `gateguard` | 에이전트가 C# 파일을 먼저 Read하지 않으면 Edit/Write를 차단합니다. 환각에 의한 변경을 방지합니다. MVS 파일의 경우 대응하는 Model/System 파일 읽기를 제안합니다. |

### 품질 Hook -- PostToolUse (standard 프로파일)
| Hook | 감지 대상 |
|------|----------|
| `warn-serialization` | `[FormerlySerializedAs]` 없이 필드 이름 변경 (데이터 무손실 손실) |
| `warn-filename` | C# 파일명과 클래스명 불일치 (스크립트 연결 불가) |
| `warn-platform-defines` | `#else` 폴백 없는 `#if UNITY_ANDROID` |
| `quality-gate` | Update에서 GetComponent, 게임플레이 코드에서 LINQ, Unity 객체에 `?.` 사용, 캐시되지 않은 Camera.main, SendMessage |
| `validate-commit` | 커밋 시 누락된 .meta 파일, 코드 품질 문제 |
| `suggest-verify` | C# 파일 5개 이상 수정 시 `/unity-review` 제안 |
| `build-analyze` | 빌드 후: 셰이더 배리언트 수, 용량, 스트리핑 문제, 폐기된 API |

### 추적 Hook -- PostToolUse (standard/strict 프로파일)
| Hook | 기록 대상 |
|------|----------|
| `track-edits` | 세션 중 수정된 파일 (standard) |
| `track-reads` | 세션 중 읽은 파일 -- GateGuard에 반영 (strict) |
| `cost-tracker` | 모든 도구 호출을 타임스탬프와 함께 기록하여 세션 메트릭 산출 (strict) |

### 세션 Hook -- SessionStart / Stop
| Hook | 수명 주기 | 기능 |
|------|----------|------|
| `session-restore` | SessionStart | 이전 브랜치, 워크플로 단계, 수정 파일 목록 복원 |
| `session-save` | Stop | 다음 대화를 위한 세션 상태 저장 (브랜치, 편집 내역, 소요 시간) |
| `stop-validate` | Stop | 세션 중 수정된 모든 C# 파일에 대해 전체 파일 검증 실행 |
| `auto-learn` | Stop | 세션 패턴(MVS 분류, 도구 사용 현황)을 학습 로그에 기록 |

### 조언 Hook -- PreCompact
| Hook | 기능 |
|------|------|
| `pre-compact` | 컨텍스트 압축 전에 git 상태 저장 |

모든 Hook은 환경 변수를 통한 개별 비활성화를 지원합니다. 위의 [Hook 프로파일](#hook-프로파일) 섹션을 참조하세요.

---

## MVS 아키텍처 템플릿

VContainer, MessagePipe, UniTask 기반의 **Model-View-System** 패턴 템플릿:

| 템플릿 | 용도 |
|--------|------|
| `Model.cs.template` | `ReactiveProperty<T>` 기반 순수 C# 데이터 클래스 -- Unity 의존성 없음 |
| `System.cs.template` | VContainer 생성자 주입을 사용하는 순수 C# 클래스, `IDisposable` 구현 |
| `View.cs.template` | `Subscribe()`로 Model을 관찰하는 MonoBehaviour, 메서드 주입 방식 |
| `LifetimeScope.cs.template` | Model/System/View/MessagePipe 등록을 위한 VContainer 컴포지션 루트 |
| `Message.cs.template` | MessagePipe용 `readonly struct` -- 힙 할당 없음 |

기본 템플릿도 포함: `MonoBehaviour.cs`, `ScriptableObject.cs`, `EditModeTest.cs`, `PlayModeTest.cs`, `AssemblyDefinition.asmdef`.

---

## Skills

### 상시 활성 코어 (6개)
- **serialization-safety** -- `[FormerlySerializedAs]`, `[SerializeField]`, Unity null 검사
- **scriptable-objects** -- SO 이벤트 채널, 변수 레퍼런스, 런타임 세트, 팩토리 패턴
- **event-systems** -- C# 이벤트, UnityEvent, SO 채널, 무할당 EventBus
- **object-pooling** -- `ObjectPool<T>`, 워밍업, 풀 반환 수명 주기
- **assembly-definitions** -- 분할 시점, 참조 규칙, Editor/Runtime 분리
- **unity-mcp-patterns** -- MCP 도구 효과적 활용법 (`batch_execute`, `read_console`)

### Unity 시스템 (10개)
URP 파이프라인, Input System, Addressables, Cinemachine, Animation, Audio, Physics, NavMesh, UI Toolkit, ShaderGraph

### 게임플레이 패턴 (6개)
캐릭터 컨트롤러 (2D/3D), 인벤토리 시스템, 대화 시스템, 세이브 시스템, 상태 머신, 절차적 생성

### 장르 블루프린트 (8개) -- 모바일 특화
하이퍼캐주얼, 매치-3, 방치형/클리커, 끝없는 러너, 퍼즐, RPG, 2D 플랫포머, 탑다운

### 서드파티 (5개)
DOTween, UniTask, VContainer, TextMeshPro, Odin Inspector

### 플랫폼 (1개)
모바일 최적화 (iOS + Android) -- 터치 입력, 안전 영역, ASTC 텍스처, 발열 제어, 배터리 관리

---

## 코딩 규칙

이 툴킷은 상시 로드되는 5개의 규칙 파일을 통해 Unity 모범 사례를 적용합니다:

- **csharp-unity** -- `[SerializeField] private`에 `m_` 접두사, 기본 sealed, 명시적 타입
- **performance** -- Update 내 무할당, GetComponent 캐싱, 오브젝트 풀링, 게임플레이에서 LINQ 금지
- **serialization** -- 이름 변경 시 `[FormerlySerializedAs]`, `obj?.` 대신 `obj == null` 사용
- **architecture** -- MVS 패턴, DI에 VContainer, 이벤트에 MessagePipe, 비동기에 UniTask
- **unity-specifics** -- Editor/Runtime 분리, 스레딩, 코루틴 수명 주기, `?.` 위험성

---

## 검증 스크립트

프로젝트 상태를 점검하려면 다음을 실행하세요:

```bash
./scripts/validate-meta-integrity.sh --all    # 누락/고아 .meta 파일, 중복 GUID
./scripts/validate-code-quality.sh            # C# 코드 내 성능 함정
./scripts/validate-asmdefs.sh                 # 순환 어셈블리 정의 의존성
./scripts/detect-missing-refs.sh              # 씬/프리팹 내 깨진 레퍼런스
./scripts/analyze-build-size.sh               # Editor.log 기반 빌드 크기 분석
./scripts/validate-serialization.sh           # FormerlySerializedAs 누락된 필드 이름 변경
./scripts/validate-architecture.sh            # MVS 패턴 준수 여부 점검
./scripts/generate-agents-md.sh > AGENTS.md   # 프로젝트 AGENTS.md 자동 생성
```

---

## 예시 AGENTS.md 파일

모바일 게임 유형별 사전 구성 파일:

- `examples/AGENTS.md.hyper-casual` -- 원탭 조작, 최소한의 비주얼, 광고 수익화
- `examples/AGENTS.md.match3` -- 그리드 시스템, 캐스케이드, 특수 타일, 라이프/에너지
- `examples/AGENTS.md.idle-clicker` -- 거대한 숫자, 오프라인 진행, 환생 시스템
- `examples/AGENTS.md.mobile-casual` -- 터치 입력, 작은 빌드 용량, 광고 연동
- `examples/AGENTS.md.2d-platformer` -- 타일맵, 가상 조이스틱, 모바일 최적화
- `examples/AGENTS.md.rpg` -- 스탯, 인벤토리, 대화, 터치 조작

---

## 아키텍처

### 워크플로 파이프라인

```
/unity-workflow "add combo scoring"
    │
    ├─ 1단계: 확인(Clarify)   ── 요구사항, 제약 조건, 플랫폼에 대한 인터뷰
    ├─ 2단계: 계획(Plan)      ── 프로젝트 스캔, 에이전트 선택, 구현 계획 제시
    ├─ 3단계: 실행(Execute)   ── unity-coder / unity-prototyper / unity-ui-builder로 라우팅
    └─ 4단계: 검증(Verify)    ── unity-verifier가 리뷰 → 자동 수정 → 재검증 루프 실행
```

### 에이전트 상호작용

```
사용자 프롬프트
    │
    ▼
Command (워크플로 오케스트레이션)
    │
    ├──▶ 코드 에이전트 (C# 스크립트 작성, 관련 스킬 로드)
    │       │
    │       └──▶ MCP 도구 (GameObject 생성, 컴포넌트 설정)
    │
    ├──▶ 검증 에이전트 (변경 사항 리뷰, 자동 수정, 재검증)
    │
    ├──▶ 테스트 에이전트 (MCP를 통한 테스트 작성 + 실행)
    │
    └──▶ 최적화 에이전트 (MCP를 통한 프로파일링, 병목 해결)
```

### Hook 안전 장치

```
Codex가 PlayerView.cs 편집 시도
    │
    ├──▶ _lib.sh: 프로파일 수준, 개별 비활성화 확인
    ├──▶ PreToolUse: guard-editor-runtime.sh — UnityEditor 가드
    ├──▶ PreToolUse: gateguard.sh — 이 파일을 먼저 Read했는가? [strict]
    │                               PlayerModel.cs도 함께 읽기를 제안
    │
    ├──▶ [편집 수행]
    │
    ├──▶ PostToolUse: warn-serialization.sh — 필드 이름 변경 점검
    │                  quality-gate.sh — Update에서 GetComponent? LINQ? ?.?
    │                  track-edits.sh — 세션 메트릭용 기록
    │
    └──▶ [세션 종료]
         ├──▶ stop-validate.sh — 수정된 모든 C# 파일 전체 검증
         ├──▶ session-save.sh — 다음 대화를 위한 상태 저장
         └──▶ auto-learn.sh — 세션 패턴 로깅
```

### 세션 수명 주기

```
SessionStart
    └──▶ session-restore.sh — 이전 상태 로드 (브랜치, 단계, 파일)

[... Hook에 의해 추적되는 작업 진행 ...]

Stop
    ├──▶ stop-validate.sh — 수정된 모든 파일에 대한 일괄 검증
    ├──▶ session-save.sh — /tmp/unity-codex-hooks/에 상태 저장
    └──▶ auto-learn.sh — learnings.jsonl에 세션 메트릭 추가
```

---

## 문서

| 가이드 | 용도 |
|--------|------|
| [시작하기](docs/GETTING-STARTED.md) | 설치, 첫 실행, 문제 해결 |
| [아키텍처](docs/ARCHITECTURE.md) | 설계 철학, 구성 요소 개요, Hook 시스템, 워크플로 파이프라인 |
| [에이전트 가이드](docs/AGENT-GUIDE.md) | 15개 에이전트 전체 소개, 사용 시점, 커스터마이징 |
| [모델 라우팅](docs/MODEL-ROUTING.md) | 에이전트 모델 할당, `--quick`/`--thorough` 플래그, 비용 대비 효과 |
| [MCP 설정](docs/MCP-SETUP.md) | unity-mcp 설치, 동작 확인, 문제 해결 |

---

## 기여하기

가이드라인은 [CONTRIBUTING.md](CONTRIBUTING.md)를 참조하세요.

기여를 환영하는 주요 분야:
- 새로운 모바일 장르 스킬 (타워 디펜스, 레이싱, 카드/가챠, 시뮬레이션)
- 새로운 시스템 스킬 (ProBuilder, Spline, 2D Animation)
- 모바일 플랫폼 스킬 (ARKit/ARCore, 알림, 딥 링크)
- 모바일용 네트워킹 프레임워크 스킬 (FishNet, Dark Rift)
- 버그 리포트 및 Hook 개선

---

## 라이선스

MIT 라이선스. 자세한 내용은 [LICENSE](LICENSE)를 참조하세요.
