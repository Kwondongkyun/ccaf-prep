# Block 3-4: Skills (`context: fork`, `allowed-tools`, `argument-hint`)

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Skills): https://docs.claude.com/en/docs/claude-code/skills
> ```

## EXPLAIN

> Task 3.4 — Skill의 frontmatter 옵션으로 격리·도구 제한·인자 안내

### 한 줄 정의

**Skill = `.claude/skills/<name>/SKILL.md`. frontmatter로 `context: fork`(컨텍스트 격리), `allowed-tools`(도구 제한), `argument-hint`(호출 시 안내). 슬래시 커맨드와의 차이: skill은 description으로 자동 호출, 커맨드는 명시 호출.**

### Frontmatter 옵션

```yaml
---
name: review-pr
description: PR 리뷰 — 보안·성능·테스트 누락 검사
context: fork                    # 메인 컨텍스트와 격리. 종료 시 결과만 반환
allowed-tools: [Read, Grep, Bash(git:*)]   # 이 도구만 허용
argument-hint: "<PR번호>"         # 슬래시로 호출 시 인자 표시
---
```

### `context: fork` 효과

```
[fork 없음 — 기본]
메인 세션 → Skill 호출 → 메인 세션이 verbose 출력 다 흡수
  ⚠️ 컨텍스트 오염 (lost-in-the-middle, /compact 빈번)

[context: fork]
메인 세션 → Skill 호출 → 격리된 컨텍스트에서 실행
                       → 종료 시 요약만 메인에 반환
  ✅ 메인 컨텍스트 청결
```

### `allowed-tools` 형식

```yaml
allowed-tools:
  - Read
  - Grep
  - Bash(git:*)        # bash 중 git 시작 명령만
  - Bash(npm:test)     # 정확히 npm test
  - Edit               # 파일 수정 허용
```

→ Allowlist. 명시 안 한 도구는 호출 차단.

### Skill vs Slash Command 구분

| | Skill | Slash Command (`.claude/commands/`) |
|---|---|---|
| 호출 | description 매칭으로 **자동** | `/명령어` 명시 |
| 컨텍스트 격리 | `context: fork` 가능 | 불가 |
| 인자 | argument-hint | 자유 |
| 적합한 상황 | "특정 패턴 감지 시 자동 적용" | "사용자가 명시적으로 실행" |

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| Verbose skill 출력이 메인 컨텍스트 오염 → 어쩔 수 없음 | **`context: fork`** 추가 |
| 모든 도구 허용 (`allowed-tools` 생략) | **명시 = 안전·예측가능** |
| Skill 자동 호출 안 됨 → 메인 프롬프트에 직접 작성 | **description을 더 구체적으로** — 매칭 키워드 강화 |
| `path-specific 컨벤션`을 skill로 | **`.claude/rules/`** 가 정답 (Sample Q 6) |

### Sample Q 시사점

- 직접 출제는 없지만 **D3 함정 — `context: fork`로 격리** 패턴은 시험 빈출.

## EXECUTE

```
W1. "PR 14파일 리뷰 — verbose 출력 메인 오염 안 되게" — frontmatter 어떻게?
W2. "DB 마이그레이션 미리보기 skill — Bash psql만 허용" — allowed-tools?
W3. "skill이 자동 호출 안 됨" — 무엇을 점검?
W4. "사용자가 명시적으로만 실행, 매번 인자 입력" — Skill vs Command?
```

→ 각 답: frontmatter 1줄 + 이유 1줄

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. Skill이 verbose 출력으로 메인 컨텍스트 오염. 효과적 조치?",
      "header": "Quiz 3-4-A",
      "options": [
        {"label": "frontmatter에 `context: fork` 추가 — 격리 후 요약만 반환", "description": "fork"},
        {"label": "Skill 호출을 메인에서 줄이라고 사용자에게 요청", "description": "줄이기"},
        {"label": "/compact 자주 호출", "description": "compact"},
        {"label": "Skill을 slash command로 전환", "description": "command 전환"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. DB 마이그레이션 skill — `Bash psql:*`만 허용하려면?",
      "header": "Quiz 3-4-B",
      "options": [
        {"label": "frontmatter `allowed-tools: [Bash(psql:*)]`", "description": "allowed-tools"},
        {"label": "프롬프트에 '다른 도구 쓰지 말 것'", "description": "프롬프트"},
        {"label": "전역 settings.json", "description": "settings"},
        {"label": "Skill 안에서 if-else", "description": "if-else"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. `Skill` vs `Slash Command` — 자동 호출 vs 명시 호출 차이?",
      "header": "Quiz 3-4-C",
      "options": [
        {"label": "Skill = description 매칭 자동 / Command = `/명령어` 명시", "description": "정답"},
        {"label": "둘 다 자동", "description": "둘 다 자동"},
        {"label": "둘 다 명시 호출만", "description": "둘 다 명시"},
        {"label": "Skill = 명시 / Command = 자동", "description": "반대"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (`context: fork`)** — F-D3-3 정면. 격리된 컨텍스트에서 실행 후 결과만 메인 반환.
- **Q2: A (`allowed-tools`)** — frontmatter 명시. 프롬프트 지시는 결정성 떨어짐.
- **Q3: A** — Skill은 description으로 자동 활성, Command는 사용자가 `/명령` 입력.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 3-5 진행",
    "options": [
      {"label": "다음 (3-5 Plan vs Direct)", "description": "복잡도 판단"},
      {"label": "3-4 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
