# Block 2-2: Structured Error Context

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Tool Use): https://docs.claude.com/en/docs/build-with-claude/tool-use
> 📖 공식 문서 (Errors): https://docs.claude.com/en/api/errors
> ```

## EXPLAIN

> Task 2.2 — 에러를 LLM에 그대로 넘기지 않고 구조화 컨텍스트로 변환

### 한 줄 정의

**Raw 에러 메시지를 LLM에 그대로 던지지 않는다. `{errorCategory, message, suggestedAction}` 형태로 구조화 → LLM이 결정적으로 다음 행동 선택.**

### 표준 형식

```python
{
    "errorCategory": "transient" | "permanent" | "validation" | "fatal",
    "message": "사람·LLM이 읽을 설명",
    "suggestedAction": "retry" | "fail" | "fallback" | "escalate",
    "context": {
        "tool": "search_db",
        "args": {...},
        "attempt": 2,
        "details": {...}
    }
}
```

### F-D2-2 함정 (= D1 F5)

> "도구 호출 실패. raw 에러 메시지를 LLM에 그대로. 결과: LLM이 어떻게 처리할지 일관성 없음."

| 잘못된 답 | 올바른 답 |
|---------|---------|
| 프롬프트로 "에러 잘 처리해" | **Structured Error** — `{category, message, suggestedAction}` |

### 왜 raw가 부족한가

```
[Raw 에러 — 비결정적]
"ConnectionTimeoutError: Failed after 30s"
  → LLM 해석: "그럴 수도, 다시 해볼까? 다른 도구? 사용자 알림?"
  → 매번 다른 행동

[Structured — 결정적]
{
  "errorCategory": "transient",
  "message": "DB 연결 30초 timeout",
  "suggestedAction": "retry",
  "context": {"attempt": 1, "max_retries": 3}
}
  → LLM 행동 명확: retry
```

### 카테고리별 의미

```
transient  → 일시적. retry 의미 있음 (rate limit, 5xx)
permanent  → 영구적. retry 무의미 (4xx 인증·검증)
validation → 입력 문제. 입력 고치고 재시도
fatal      → 비즈니스/안전. HITL escalate
```

### suggestedAction 4가지

```
retry      → 같은 도구 다시 호출
fail       → 즉시 종료, 사용자에게 보고
fallback   → 대체 도구·캐시·기본값
escalate   → HITL — 사람 결정 필요
```

### 좋은 예 vs 나쁜 예

```python
# Bad
return f"Error: {e}"

# Good
return {
    "errorCategory": classify(e),
    "message": str(e),
    "suggestedAction": decide_action(e),
    "context": {
        "tool": tool_name,
        "args": redact_pii(args),
        "attempt": attempt,
    }
}
```

### LLM이 받는 효과

```
[Raw로 받음]
  "Failed: 401 Unauthorized"
  LLM: "다시 시도해볼까... credential 갱신할까... 사용자에게 물어볼까..."
  → 비결정적

[Structured로 받음]
  category=permanent, action=escalate
  LLM: "재시도 무의미. 사용자에게 credential 확인 요청"
  → 결정적
```

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "에러는 raw text가 자연스러움" | LLM 행동 비일관. 구조화 권장 |
| "errorCategory만 있으면 됨" | suggestedAction까지 — 행동 결정성 ↑ |
| "context는 옵션" | 디버그·재시도에 결정적 |
| "한 카테고리로 통일" | 분류는 행동을 결정. 분리 필수 |
| "프롬프트에 '에러 잘 처리해'" | 확률적. Structured로 결정적 |

### Sample Q 매핑

> "도구 호출 실패. LLM이 어떻게 다룰지 매번 다름. 가장 효과적?"
> → Structured Error 컨텍스트. `{category, action}`으로 결정적.

> "Transient + permanent 구분 안 하고 다 retry. 문제는?"
> → Permanent에 retry는 무의미한 비용. 카테고리 + action으로 분기.

## EXECUTE

```
W1. 401 Unauthorized — 어떤 category·action?
W2. 429 rate limit — ?
W3. 400 검증 실패 — ?
W4. PII 누설 시도 감지 — ?
W5. DB 연결 timeout — ?

→ 각각: errorCategory + suggestedAction
```

추가: errorCategory만 주고 suggestedAction 빼면 어떤 비결정성 발생? 1줄.

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 도구 호출 실패 시 LLM 처리가 매번 다름. 가장 효과적?",
      "header": "Quiz 2-2-A",
      "options": [
        {"label": "{errorCategory, message, suggestedAction, context} 구조화", "description": "Structured"},
        {"label": "Raw 에러 그대로 + '잘 처리해' 프롬프트", "description": "Raw"},
        {"label": "에러 무시", "description": "Ignore"},
        {"label": "사용자에게 매번 묻기", "description": "Ask"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 401 Unauthorized — 가장 적절한 분류?",
      "header": "Quiz 2-2-B",
      "options": [
        {"label": "permanent + escalate (credential 이슈)", "description": "Permanent"},
        {"label": "transient + retry", "description": "Transient"},
        {"label": "validation + fail", "description": "Validation"},
        {"label": "fatal + ignore", "description": "Fatal ignore"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. Structured Error에서 빠지면 LLM 결정성 가장 떨어지는 필드?",
      "header": "Quiz 2-2-C",
      "options": [
        {"label": "suggestedAction — 다음 행동의 명시 신호", "description": "Action"},
        {"label": "message", "description": "Message"},
        {"label": "context", "description": "Context"},
        {"label": "errorCategory", "description": "Category"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (Structured)** — **F-D2-2 정면.** 결정적 행동을 위한 데이터화. Raw는 LLM 해석 분산.
- **Q2: A (Permanent + escalate)** — credential 이슈는 retry 무의미. 사용자 개입 필요.
- **Q3: A (suggestedAction)** — 행동 명시. category만으로는 LLM이 행동 추측해야 함.

### 출제 변형

- **"context 필드 왜?"** → 디버그·재시도 시 인자·시도 횟수 같은 메타.
- **"카테고리 통일?"** → 분류 의미 사라짐. 행동도 결정 못 함.
- **"raw + 프롬프트로 충분?"** → 확률적. Structured는 결정적.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 2-3 진행",
    "options": [
      {"label": "다음 (2-3 Tool Scoping & Allowlist)", "description": "최소 도구·작업별"},
      {"label": "2-2 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
