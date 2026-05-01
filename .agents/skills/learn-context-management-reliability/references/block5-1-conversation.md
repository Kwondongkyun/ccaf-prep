# Block 5-1: Conversation Context Across Long Interactions

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Context Windows): https://docs.claude.com/en/docs/build-with-claude/context-windows
> 📖 공식 문서 (Memory): https://docs.claude.com/en/docs/claude-code/memory
> ```

## EXPLAIN

> Task 5.1 — 긴 대화에서 critical 정보(수치·날짜·금액·결정)를 보존

### 한 줄 정의

**매 API request에 complete conversation history가 들어간다. 단순 요약은 수치·날짜·금액을 vague하게 만들고, 40+ 필드 도구 결과를 그대로 누적하면 lost-in-the-middle로 critical 정보가 묻힌다. 정밀 보존(case facts) + 무관 영역 trim + 결정·식별자 외부화가 핵심.**

### Conversation context 작동

```
매 API call에 [system, message_1, message_2, ..., message_n] 전체 전송
  → message_n이 새 user 입력일 때도 1..n-1 모두 포함
  → 길어질수록 토큰·비용·latency·attention 분산 모두 ↑
```

### 함정 1 — Progressive summarization으로 수치가 흐려진다

```
[Bad — naive summary]
"고객이 환불을 요청. 금액·날짜·주문 ID는 이전 turn 참고."
→ 다음 turn에서 "이전 turn"이 또 요약됨 → "환불 진행 중" 같은 vague 상태로 수렴
→ 5 turn 후: "환불 금액 얼마였지?" 모름

[Good — preserve case facts]
case_facts = {
  order_id: "ORD-12345",
  amount: 89.50,
  refund_reason: "wrong size",
  request_date: "2025-04-30",
  customer_id: "CUS-678"
}
→ 매 turn 시스템 메시지·structured note로 명시. 요약은 prose에만.
```

→ Sample Q 시나리오 1 (Customer Support) 패턴.

### 함정 2 — Lost-in-the-middle

```
긴 컨텍스트에서 모델 attention 분포:
  [강함] ── 시작
  [약함] ── 중간 ← critical 결정이 여기 묻히면 무시됨
  [강함] ── 끝

[증거] needle-in-haystack 벤치 — 중간 위치 정답률 ↓

[대응]
  - 결정·정책은 시스템 프롬프트(시작) 또는 최신 turn(끝)에 재투입
  - 매 turn case_facts를 끝에 다시 포함
  - 50 turn 전의 한 줄짜리 결정은 잊혀진다고 가정
```

### 함정 3 — 40+ 필드 도구 결과 그대로 누적

```
[Bad]
get_customer 도구 → 47개 필드 (생일, 가입일, 마케팅 동의, 주소, ...)
→ 5번 호출 → 235개 필드 누적, 그 중 5개만 관련

[Good — trim & extract]
1) 도구 응답을 받은 직후 5개 관련 필드만 추출 → memory에 보존
2) 원본 47필드 응답은 다음 turn 컨텍스트에서 제거 (또는 요약 1줄)
3) 다음 호출 시 동일 customer면 캐시된 5필드 재사용
```

→ Tool 결과는 raw로 누적하지 말 것. **즉시 정리(distill)** 후 보존.

### 함정 4 — 결정을 말로만 한다

```
[Bad]
turn 12: "DB는 Postgres 16으로 가자"
turn 80: "DB 어떻게 하기로 했지?" — 모델이 12를 못 찾음

[Good]
turn 12: 결정 → manifest/scratchpad/시스템 메시지에 외부 기록
        매 turn 컨텍스트의 끝(또는 system)에 재주입
```

→ Manifest 패턴은 D5-4(Large Codebase)와 직결. D5-1은 "왜 외부화가 필요한가"의 reasoning.

### Critical 정보 분류

| 종류 | 예시 | 보존 방법 |
|-----|-----|----------|
| 식별자 | order_id, customer_id, ticket_id | case_facts에 명시 (turn 끝마다) |
| 수치·금액 | $89.50, 30%, 10건 | 정확값. 요약 prose에 흡수 X |
| 날짜·시점 | 2025-04-30, "어제" | 절대 날짜로 변환 후 보존 |
| 정책 결정 | "환불 가능 기준", "스택 선택" | 시스템 프롬프트 또는 manifest |
| 진행 상태 | "단계 3 진행 중" | 매 turn 갱신 |

### Trim 전략

```
1) Tool result trim
   raw 47필드 → 관련 5필드만 case_facts에 저장
   raw 응답은 다음 turn에서 제거하거나 1줄로 압축

2) 무관 turn 압축
   해결된 곁가지 (예: typo 정정 turn) → 1줄 요약으로

3) 시작/끝 보강
   결정·case facts를 시스템 메시지(시작) + 마지막 user message 직전(끝)
   → middle dilution 회피
```

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "Compaction 있으니 그냥 누적" | 자동 요약은 수치·날짜를 vague하게 — case_facts는 정밀 보존 |
| "긴 컨텍스트 = 더 정확" | Lost-in-the-middle. 길수록 중간 정보 무시 |
| "Tool 응답은 다 보관" | 5/47 필드만 관련 → 즉시 trim |
| "결정은 본 turn에 적었으니 안전" | 50 turn 후 못 찾음. 외부화 + 재주입 |
| "매 turn에 case_facts 반복은 토큰 낭비" | 정확도 ≫ 토큰. 안 하면 vague 수렴 |

### Sample Q 매핑

- 시나리오 1 (Customer Support) — case_facts(order_id, amount, date) 보존이 핵심.
- 시나리오 6 (Structured Data Extraction) — 40+ 필드 중 일부만 관련, 나머지 trim.

## EXECUTE

```
W1. 5번째 turn에서 환불 금액·날짜를 모델이 흐리게 답변. 원인 + 대응?
W2. get_customer가 47필드. 다음 turn 효율적으로 다룰 방법?
W3. turn 80에서 turn 12 결정을 못 찾음. 무엇을 해야 했나?
W4. "어제 주문" 같은 상대 시점이 누적되면? 처리?
W5. 매 turn 마지막에 case_facts 1줄을 다시 넣는 게 토큰 낭비 아니냐? 반박 1줄.
```

→ 각 답: 1-2줄

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. Customer Support agent가 5 turn 후 환불 금액·날짜를 vague하게 답변. 가장 효과적?",
      "header": "Quiz 5-1-A",
      "options": [
        {"label": "case_facts (order_id, amount, date)를 매 turn 명시·재주입", "description": "Preserve facts"},
        {"label": "더 큰 모델로 변경", "description": "Bigger"},
        {"label": "Progressive summarization 강화", "description": "More summary"},
        {"label": "사용자가 매번 다시 알려주기", "description": "Manual"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. Lost-in-the-middle 대응으로 가장 적절?",
      "header": "Quiz 5-1-B",
      "options": [
        {"label": "결정·case facts를 시스템(시작) + 최신 turn(끝)에 재주입", "description": "Position"},
        {"label": "중간에 강조 표시", "description": "Mid emphasis"},
        {"label": "컨텍스트를 더 길게", "description": "Longer"},
        {"label": "온도 낮춤", "description": "Temperature"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. get_customer가 47 필드 반환. 5개만 관련. 가장 효과적?",
      "header": "Quiz 5-1-C",
      "options": [
        {"label": "응답 직후 5필드만 추출해 case_facts 저장, raw 47필드는 trim", "description": "Distill"},
        {"label": "47필드 그대로 누적", "description": "Accumulate"},
        {"label": "도구 호출 빈도 줄이기", "description": "Less calls"},
        {"label": "필드 이름만 보존", "description": "Names only"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (Preserve facts)** — Progressive summarization은 수치·날짜를 흐리게. case_facts 정밀 보존이 1차.
- **Q2: A (Position)** — 시작·끝 attention이 강함. 중간 묻힘 회피.
- **Q3: A (Distill)** — Raw tool 결과는 누적 X. 5필드만 distill 후 trim.

### 출제 변형

- **"매 turn case_facts 재주입은 토큰 낭비?"** → 정확도가 토큰 비용 압도. vague 답변의 retry·escalation이 더 비싸다.
- **"Tool 결과를 어디까지 trim?"** → 다음 turn 작업에 쓰일 5필드만. 나머지는 1줄 요약 또는 제거.
- **"D5-1과 D5-4 차이?"** → 5-1은 conversation 안에서 critical 정보 보존 reasoning. 5-4는 large codebase 탐색에서 manifest·subagent·/compact 메커니즘.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 5-2 진행",
    "options": [
      {"label": "다음 (5-2 Escalation & Ambiguity)", "description": "explicit criteria — Sample Q 3"},
      {"label": "5-1 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
