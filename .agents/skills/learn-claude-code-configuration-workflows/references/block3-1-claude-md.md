# Block 3-1: CLAUDE.md 계층·스코프·@import·/memory

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Memory): https://docs.claude.com/en/docs/claude-code/memory
> 📖 공식 문서 (Settings): https://docs.claude.com/en/docs/claude-code/settings
> ```

## EXPLAIN

> Task 3.1 — 적절한 계층, 스코프, 모듈식 구성으로 CLAUDE.md 설정

### 한 줄 정의

**CLAUDE.md는 3-레벨 계층 (유저/프로젝트/디렉토리)이고, `@import`로 모듈화하고, `/memory`로 어떤 파일이 로드됐는지 확인한다.**

### CLAUDE.md 3-레벨 계층

```
┌──────────────────────────────────────────────┐
│ 유저 레벨                                     │
│ ~/.claude/CLAUDE.md                         │
│ → 그 유저 한 명에게만 적용                    │
│ → git에 안 들어감 → 팀원과 공유 안 됨         │
├──────────────────────────────────────────────┤
│ 프로젝트 레벨                                 │
│ <project>/CLAUDE.md 또는 .claude/CLAUDE.md  │
│ → 프로젝트 멤버 모두에게 적용                  │
│ → git 커밋 → 팀 공유                         │
├──────────────────────────────────────────────┤
│ 디렉토리 레벨                                 │
│ <project>/sub/CLAUDE.md                     │
│ → sub/ 하위에서만 적용                       │
└──────────────────────────────────────────────┘
```

### F-D3-1 함정 — 시험 단골

> "새 팀원이 CLAUDE.md 지침을 안 따른다. 어떻게?"

| 잘못된 답 | 올바른 답 |
|---------|---------|
| CLAUDE.md를 더 자세히 작성 | **계층 진단** — `~/.claude/CLAUDE.md`(유저 레벨)에 있어서 git 공유 안 됨 → 프로젝트 레벨로 옮겨야 |

→ "지침이 안 통한다" 시나리오는 거의 항상 **잘못된 레벨에 있다**가 정답.

### `@import` — CLAUDE.md 모듈화

큰 단일 파일 대신 외부 파일 참조:

```markdown
# CLAUDE.md (프로젝트 루트)
이 프로젝트는 Python + FastAPI 모노레포다.

@./packages/api/standards.md
@./packages/web/standards.md
@./packages/shared/conventions.md
```

각 패키지는 자기 도메인 표준만 import → **maintainer가 자기 패키지에 맞는 룰만 관리**.

### `.claude/rules/` — 토픽별 분할

```
.claude/rules/
├── testing.md        ← 테스트 컨벤션
├── api-conventions.md ← API 디자인
└── deployment.md      ← 배포 룰
```

CLAUDE.md에서 `@.claude/rules/testing.md`로 import. 토픽 단위 관리 → 모놀리식 CLAUDE.md 안티패턴 회피.

### `/memory` 명령어

```bash
/memory
```

→ **현재 세션에 로드된 모든 메모리 파일 목록 출력.**

용도:
1. **로드 확인** — 의도한 CLAUDE.md가 실제 로드됐는지
2. **계층 이슈 진단** — 유저/프로젝트/디렉토리 어느 레벨에서 왔는지
3. **세션 간 일관성** — 다른 세션에서 다른 결과 나올 때, 어느 레벨이 다른지 비교

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "CLAUDE.md는 한 파일에 다 적기" | `@import`로 모듈화 또는 `.claude/rules/` 토픽별 |
| "지침이 안 통하면 더 자세히 적기" | **계층 먼저 진단** (`/memory`) — 잘못된 레벨일 가능성 높음 |
| "유저 레벨이 가장 우선이라 거기 적기" | 팀 공유 필요한 룰은 프로젝트 레벨. 유저 레벨은 개인 선호만 |
| "디렉토리별 CLAUDE.md는 만능" | 흩어진 파일에 적용하려면 path-specific rule (Block 3-3) |
| "@import는 1단계만 가능" | 중첩 import 가능 |

### Sample Q 매핑

> "팀원 A의 Claude Code는 새 컨벤션을 따르는데, B는 안 따른다. 둘 다 같은 git 브랜치 작업 중. 가장 가능한 원인?"
> → 컨벤션이 **A의 `~/.claude/CLAUDE.md`** (유저 레벨)에 있어 B에게 공유 안 됨. 프로젝트 레벨로 이동 필요.

## EXECUTE

다음 시나리오를 직접 진단해보세요.

```
시나리오 1: 팀이 "테스트는 항상 pytest로" 컨벤션 도입.
  → 어느 레벨에 적어야? 어느 파일에?

시나리오 2: 본인만 "한국어로 응답해줘" 선호.
  → 어느 레벨? 어느 파일?

시나리오 3: 모노레포 — packages/api는 Python, packages/web은 TypeScript.
  → @import 구조 설계.

시나리오 4: 새 세션에서 컨벤션이 안 통하는 듯.
  → 어떤 명령어로 진단?
```

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 새 팀원이 프로젝트 컨벤션을 못 따른다. CLAUDE.md는 ~/.claude/CLAUDE.md에 있다. 가장 효과적 해결?",
      "header": "Quiz 3-1-A",
      "options": [
        {"label": "CLAUDE.md 내용을 프로젝트 루트로 이동 + git 커밋", "description": "Hierarchy fix"},
        {"label": "CLAUDE.md를 더 자세히 작성", "description": "More detail"},
        {"label": "팀원에게 CLAUDE.md를 ~/.claude/에 복사하라고 안내", "description": "Manual copy"},
        {"label": "Few-shot 예시 추가", "description": "Few-shot"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 모노레포에서 각 패키지가 다른 도메인 표준 따름. 가장 적절한 구성?",
      "header": "Quiz 3-1-B",
      "options": [
        {"label": "각 패키지에 CLAUDE.md + 루트 CLAUDE.md에서 @import로 모듈화", "description": "Modular"},
        {"label": "루트 CLAUDE.md에 모든 패키지 표준 한꺼번에", "description": "Monolithic"},
        {"label": "유저 레벨에 패키지별 규칙 작성", "description": "User level"},
        {"label": "각 패키지에 CLAUDE.md만 두고 루트는 비우기", "description": "No root"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. 세션 간 일관성 이슈를 진단하려면?",
      "header": "Quiz 3-1-C",
      "options": [
        {"label": "/memory — 로드된 메모리 파일 목록 확인", "description": "/memory"},
        {"label": "/clear — 컨텍스트 초기화", "description": "/clear"},
        {"label": "/help — 명령어 목록", "description": "/help"},
        {"label": "git log — 최근 커밋", "description": "git log"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A** — **F-D3-1 정면.** 유저 레벨은 git 공유 안 됨. 프로젝트 레벨 이동이 근본 해결. C는 일시방편이고 새 팀원 또 옴.
- **Q2: A (Modular)** — `@import`의 정확한 용도. Monolithic은 토큰 낭비 + maintainer 책임 분산 어려움.
- **Q3: A (`/memory`)** — 메모리 로드 상태 확인 명령어. 일관성 이슈는 거의 다 "어느 레벨이 어떻게 다른가" 문제.

### 출제 변형

- **"`@import`는 어디서 쓰나?"** → CLAUDE.md 본문에서 외부 파일 참조. 모듈화·토픽 분할용.
- **"`.claude/rules/` vs CLAUDE.md `@import`?"** → 둘 다 모듈화. rules는 path-specific 가능 (Block 3-3).
- **"유저 레벨에 두면 안 되는 것?"** → 팀 공유 필요한 컨벤션. 개인 선호만 유저 레벨.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 3-2 진행",
    "options": [
      {"label": "다음 (3-2 슬래시 커맨드 & Skill)", "description": "context: fork, allowed-tools"},
      {"label": "3-1 변형 한 번 더", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
