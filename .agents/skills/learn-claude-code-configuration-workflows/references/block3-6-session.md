# Block 3-6: Session Management (`/memory`, `/compact`, `--resume`, `fork_session`, Explore subagent)

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Sessions): https://docs.claude.com/en/docs/claude-code/sessions
> 📖 공식 문서 (Memory): https://docs.claude.com/en/docs/claude-code/memory
> ```

## EXPLAIN

> Task 3.6 — Long session에서 컨텍스트·메모리·재개·격리 관리

### 한 줄 정의

**컨텍스트가 가득 차거나 새 작업으로 전환할 때 5가지 도구: `/memory`(어느 레벨 지침인가) · `/compact`(압축) · `--resume`(이어하기) · `fork_session`(분기) · Explore subagent(독립 컨텍스트로 검색).**

### 5도구 표

| 도구 | 용도 | 언제 |
|-----|------|------|
| `/memory` | 현재 적용 중인 CLAUDE.md 계층 표시 | "내 지침이 왜 안 먹지?" 진단 |
| `/compact` | 대화 압축 (요약으로 대체) | 컨텍스트 80%+ 차서 새 토픽 진입 시 |
| `--resume` | 이전 세션 이어서 시작 | 어제 작업 연속 |
| `fork_session` | 현재 세션을 분기 (실험) | "다른 접근도 시도해볼까" |
| Explore subagent | 독립 컨텍스트에서 검색·읽기 | 코드베이스 탐색 (verbose 출력 격리) |

### 시나리오 → 도구 선택

```
"CLAUDE.md 지침이 적용 안 됨"        → /memory (계층 진단)
"3시간 디버깅, 컨텍스트 90% 참"       → /compact + key facts 보존
"어제 끊긴 작업 재개"                → claude --resume <session-id>
"두 가지 리팩터 접근 비교"            → fork_session
"100파일 코드베이스 어디 있는지 탐색"  → Explore subagent (verbose 격리)
```

### `/compact` 주의

```
[Bad]
/compact 를 그냥 호출 → 숫자·날짜·금액까지 vague 요약

[Good]
1. case facts 블록을 별도로 보존 (수치, ID, 날짜)
2. /compact 호출
3. 압축된 history + case facts 블록 → 다음 프롬프트
```

→ **D5-1**과 직결. Progressive summarization 위험.

### Explore subagent 

- 별도 컨텍스트로 spawn (Task tool)
- verbose 검색 결과 → 메인 안 거치고 격리
- 종료 시 요약만 메인으로 (D1-3 명시 컨텍스트 전달과 짝)

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| 컨텍스트 가득 → 무조건 새 세션 | **`/compact`** + case facts 보존 또는 Explore subagent |
| `/memory`로 메모리 추가 | `/memory`는 **진단**용 (어느 레벨 지침이 적용 중인지 표시) |
| `--resume` 없이 세션ID로 재시작 | `claude --resume <id>` 또는 인자 없이 인터랙티브 선택 |
| Long codebase 탐색을 메인에서 직접 | **Explore subagent로 격리** (D5-4와 연계) |

### Sample Q 시사점

- Q5(plan vs direct), Q6(rules)와 함께 "어느 도구가 맞는가" 판단 출제 가능.
- D5-4 Large codebase 와 연결 — manifest export 시 `--resume`으로 복원.

## EXECUTE

```
W1. "팀원 PR 리뷰 지침이 안 먹힘" — 어떤 명령으로 진단?
W2. "오전 작업 연속, 세션ID 모름" — 명령?
W3. "디버깅 3시간, 컨텍스트 가득" — `/compact` 직전 무엇을 추출?
W4. "200파일 monorepo에서 사용처 탐색" — 메인에서? subagent?
W5. "리팩터 접근 A·B 둘 다 실험" — ?
```

→ 각 답: 명령/도구 + 1줄 이유

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. CLAUDE.md 지침이 새 팀원에게 적용 안 됨. 첫 진단?",
      "header": "Quiz 3-6-A",
      "options": [
        {"label": "/memory — 어느 계층의 지침이 활성인지 표시", "description": "/memory"},
        {"label": "/compact", "description": "/compact"},
        {"label": "--resume", "description": "--resume"},
        {"label": "fork_session", "description": "fork"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 200파일 코드베이스에서 verbose 검색 → 메인 컨텍스트 보호?",
      "header": "Quiz 3-6-B",
      "options": [
        {"label": "Explore subagent — 격리 컨텍스트, 종료 시 요약만 반환", "description": "Explore"},
        {"label": "/compact 자주", "description": "/compact"},
        {"label": "메인에서 직접 Grep", "description": "메인 직접"},
        {"label": "Skill로 변환", "description": "Skill"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. 컨텍스트 90% — `/compact` 직전 가장 중요한 행동?",
      "header": "Quiz 3-6-C",
      "options": [
        {"label": "수치·ID·날짜 같은 case facts 블록을 별도 보존", "description": "case facts"},
        {"label": "그냥 /compact 호출", "description": "그냥"},
        {"label": "새 세션 시작", "description": "새 세션"},
        {"label": "fork_session", "description": "fork"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (`/memory`)** — 어느 계층 지침이 적용 중인지 진단. 계층 잘못이면 옮기면 됨.
- **Q2: A (Explore subagent)** — verbose 출력 격리. D5-4와 직결.
- **Q3: A (case facts)** — Progressive summarization 위험. 정확한 수치는 별도 블록으로 보존 후 압축.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 3 종료",
    "options": [
      {"label": "D3 종합 정리", "description": "6블록 관계도 + Sample Q 매핑"},
      {"label": "D4로 이동", "description": "Prompt Engineering"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
