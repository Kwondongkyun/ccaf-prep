# Block 3-2: 슬래시 커맨드 & Skill (context: fork)

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Slash Commands): https://docs.claude.com/en/docs/claude-code/slash-commands
> 📖 공식 문서 (Skills): https://docs.claude.com/en/docs/claude-code/skills
> ```

## EXPLAIN

> Task 3.2 — 커스텀 슬래시 커맨드와 skill 생성·설정

### 한 줄 정의

**슬래시 커맨드는 프로젝트(`.claude/commands/`) vs 유저(`~/.claude/commands/`) 스코프, Skill은 SKILL.md frontmatter로 `context: fork`·`allowed-tools`·`argument-hint` 설정.**

### 슬래시 커맨드 스코프

```
[.claude/commands/]                    [~/.claude/commands/]
  프로젝트 스코프                          유저 스코프
  - git 커밋 → 팀 공유                    - 개인용 (공유 X)
  - 팀 전체 워크플로우                      - 본인 선호 커맨드
  ex: /pr-review, /deploy-check            ex: /my-summary
```

선택 기준:
- **팀이 같이 쓸 워크플로우** → 프로젝트 스코프 (.claude/commands/)
- **개인용 커스터마이징** → 유저 스코프 (~/.claude/commands/)

### Skill — SKILL.md frontmatter

```markdown
---
name: code-review
description: PR을 리뷰한다. 보안·성능·테스트 커버리지 포함.
context: fork
allowed-tools: Read, Grep, Glob
argument-hint: <pr-number>
---

# Code Review Skill
...
```

### 4가지 핵심 frontmatter

**1. `context: fork` — 격리된 sub-agent 컨텍스트**

```
[일반 skill]: 메인 대화 컨텍스트에서 실행 → verbose 출력이 메인 오염
[context: fork]: 격리된 sub-agent에서 실행 → 메인 컨텍스트 보존
```

용도:
- **Verbose 출력 skill** — 코드베이스 분석, 대규모 검색
- **탐색적 컨텍스트** — 대안 브레인스토밍, 여러 접근법 시도

**2. `allowed-tools` — 도구 제한**

```yaml
allowed-tools: Read, Grep    # 읽기 전용 — destructive 작업 방지
```

→ skill이 의도치 않게 파일 수정·삭제하는 사고 방지.

**3. `argument-hint` — 필수 인자 prompt**

```yaml
argument-hint: <pr-number>
```

→ 인자 없이 호출 시 사용자에게 "pr-number를 입력해주세요" 안내.

**4. 개인 변형 — 다른 이름으로 `~/.claude/skills/`**

팀 skill을 본인만 다르게 쓰고 싶을 때:
```
~/.claude/skills/code-review-mine/  ← 다른 이름으로 개인 변형
```
→ 팀원 영향 없음.

### Skill vs CLAUDE.md — 결정 기준

| 측면 | Skill | CLAUDE.md |
|-----|-------|-----------|
| 로드 시점 | **온디맨드** (호출 시) | **항상 자동 로드** |
| 적합 영역 | 작업별 워크플로우 | 범용 표준·컨벤션 |
| 토큰 비용 | 호출 시만 | 매 세션 |
| 예시 | `/code-review`, `/deploy-check` | "테스트는 pytest", "한국어로 응답" |

**판별 질문:** "이게 매 세션에 필요한가?"
- Yes → CLAUDE.md
- 특정 작업에만 → Skill

### F-D3-2 함정

> "코드베이스 분석 skill이 verbose한 도구 출력을 만들어 메인 대화 컨텍스트가 오염됨. 어떻게?"

| 잘못된 답 | 올바른 답 |
|---------|---------|
| Skill 출력을 짧게 요약하라고 프롬프트 강화 | **`context: fork`** — sub-agent 격리. 결과 요약만 메인에 반환 |

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "Skill을 모든 작업에 — CLAUDE.md 대신" | 항상 필요한 룰은 CLAUDE.md, 특정 작업은 Skill |
| "Verbose skill은 그냥 두면 됨" | `context: fork`로 격리 |
| "Skill에 모든 도구 다 줘서 자유도 ↑" | `allowed-tools`로 제한 — 의도치 않은 작업 방지 |
| "팀 skill을 직접 수정하면 됨" | 개인용은 다른 이름으로 `~/.claude/skills/`에 |
| "argument-hint 없어도 됨" | 인자 필요한 skill엔 명시해야 사용성 ↑ |

## EXECUTE

다음을 직접 설계해보세요.

```
시나리오 1: 팀에 PR 리뷰용 skill을 만든다.
  - 위치: ?
  - context: fork? 왜?
  - allowed-tools: 어떻게 제한?

시나리오 2: 본인이 "주간 회고 작성" 개인 워크플로우를 만든다.
  - 위치: ?
  - CLAUDE.md vs Skill?

시나리오 3: 팀 skill `code-review`를 본인만 다른 기준으로.
  - 어떻게?
```

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 코드베이스 분석 skill의 verbose 출력이 메인 대화를 오염. 가장 효과적 해결?",
      "header": "Quiz 3-2-A",
      "options": [
        {"label": "skill frontmatter에 context: fork 추가 — sub-agent 격리", "description": "Fork"},
        {"label": "Skill에 '결과를 요약해서 출력' 프롬프트 추가", "description": "Prompt"},
        {"label": "Skill 사용 빈도 줄이기", "description": "Avoid"},
        {"label": "Skill을 CLAUDE.md로 변환", "description": "Convert"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 팀 워크플로우 vs 개인 커스터마이징 - 슬래시 커맨드 위치는?",
      "header": "Quiz 3-2-B",
      "options": [
        {"label": "팀: .claude/commands/ (git 공유), 개인: ~/.claude/commands/", "description": "Scope split"},
        {"label": "둘 다 .claude/commands/", "description": "All project"},
        {"label": "둘 다 ~/.claude/commands/", "description": "All user"},
        {"label": "Skill로 통합", "description": "Skill only"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. 프로젝트의 PR 리뷰 skill에 destructive 도구 사용 위험. 어떻게 제한?",
      "header": "Quiz 3-2-C",
      "options": [
        {"label": "frontmatter에 allowed-tools: Read, Grep만 명시", "description": "Tool restrict"},
        {"label": "프롬프트에 '파일 수정 금지' 명시", "description": "Prompt"},
        {"label": "사용자가 매번 확인", "description": "Manual review"},
        {"label": "Skill을 사용하지 않음", "description": "Avoid"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (`context: fork`)** — **F-D3-2 정면.** Skill을 격리된 sub-agent에서 실행 → 메인 컨텍스트 보존. 프롬프트는 확률적이라 부족.
- **Q2: A** — `.claude/commands/` (git 공유) vs `~/.claude/commands/` (개인). 두 스코프 분리는 계층 원칙과 동일.
- **Q3: A (`allowed-tools`)** — Programmatic 제한. 프롬프트보다 결정론적.

### 출제 변형

- **"Skill vs CLAUDE.md?"** → 항상 필요 = CLAUDE.md, 특정 작업 = Skill.
- **"개인 변형은 어떻게?"** → 다른 이름으로 `~/.claude/skills/`에. 팀 skill 직접 수정 X.
- **"`argument-hint` 안 적으면?"** → 인자 없이 호출 시 사용자가 헤맴. 사용성 저하.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 3-3 진행",
    "options": [
      {"label": "다음 (3-3 Path-specific rules)", "description": "glob 패턴 룰"},
      {"label": "3-2 변형 한 번 더", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
