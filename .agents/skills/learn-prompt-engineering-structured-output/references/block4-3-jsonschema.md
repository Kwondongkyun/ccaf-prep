# Block 4-3: JSON Schema via `tool_use`

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Tool Use): https://docs.claude.com/en/docs/build-with-claude/tool-use
> 📖 공식 문서 (Structured Outputs): https://docs.claude.com/en/docs/build-with-claude/tool-use/overview
> ```

## EXPLAIN

> Task 4.3 — `tool_use` 메커니즘으로 JSON 구조화 출력 강제

### 한 줄 정의

**Claude에 JSON 출력을 강제하려면 가짜 도구(`extract_data`)를 정의하고 `input_schema`로 형식 명시 → `tool_choice: {type: "tool", name: "extract_data"}`로 그 도구만 호출하게 강제. 결과는 `tool_use` 블록의 `input`에 들어옴.**

### 표준 패턴

```python
client.messages.create(
    model="claude-...",
    tools=[{
        "name": "extract_invoice",
        "description": "송장에서 필드 추출",
        "input_schema": {
            "type": "object",
            "properties": {
                "invoice_id": {"type": "string"},
                "amount":     {"type": "number"},
                "due_date":   {"type": "string", "format": "date"},
                "currency":   {"type": "string", "enum": ["USD", "EUR", "KRW", "other"]},
                "currency_other_detail": {"type": ["string", "null"]},
                "notes":      {"type": ["string", "null"]}  # nullable!
            },
            "required": ["invoice_id", "amount", "due_date"]
        }
    }],
    tool_choice={"type": "tool", "name": "extract_invoice"},
    messages=[...]
)
```

→ 결과: `response.content[0].input` = 파싱된 dict

### 핵심 frontmatter (schema 작성 규칙)

| 패턴 | 의미 |
|-----|------|
| `required: [...]` | 반드시 있어야 함. 없으면 모델이 hallucinate |
| `["string", "null"]` | **Nullable** — 정보 없으면 null (빈 string·기본값 X) |
| `enum + "other" + detail` | "other" 선택 시 detail 필드로 자유 기술 |
| `tool_choice: {type: "tool", name}` | 그 도구만 호출 강제 — `auto`는 free choice |

### `tool_choice` 4가지

```
{type: "auto"}           → 자유 선택 (도구 호출 안 할 수도)
{type: "any"}            → 반드시 어떤 도구든 호출
{type: "tool", name: X}  → 도구 X만 호출 (구조화 출력 강제)
{type: "none"}           → 도구 호출 금지
```

→ 구조화 출력 = `{type: "tool", name: ...}`

### Nullable의 의미 (hallucination 방지)

```
[Bad — required로만 처리]
required: ["notes"]
→ 모델이 정보 없을 때 "" 또는 "N/A" 또는 "Not specified" 등 채움 (비결정)

[Good — nullable]
notes: {type: ["string", "null"]}
→ 정보 없으면 null. 비결정성 제거
```

### Strict mode

- Claude API의 strict 모드: schema 위반 시 오류. 형식 syntax error 제거.
- Pydantic 검증(D4-4)과 짝: API 단계 syntax 검증 + Pydantic 단계 semantic 검증.

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| 프롬프트로 "JSON으로 답해" | **`tool_use` + tool_choice** — 결정적 |
| Optional 필드를 빈 string으로 | **`["type", "null"]`** nullable |
| `tool_choice: auto` 로 구조화 보장 | `auto`는 도구 안 부를 수도. **`{type: "tool", name}`** 필수 |
| Enum 외 값 처리는 무시 | **`"other" + detail`** 패턴으로 escape |

### Sample Q 시사점

- 직접 출제는 PDF에 없지만 In-Scope에 명시. **"Structured output via tool_use"**가 핵심 키워드.

## EXECUTE

```
W1. "고객 이메일 → {sentiment, intent, urgency} JSON" — schema 작성
W2. "회사명 enum [Apple, Google, Other] — Other면 자유 기술" — schema 패턴?
W3. "정보 없을 수 있는 phone 필드" — type 정의?
W4. "tool_choice: auto vs {type:'tool', name:'X'}" — 구조화 출력엔?
```

→ 각 답: schema 1조각 + 이유 1줄

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. JSON 출력을 결정적으로 강제하려면?",
      "header": "Quiz 4-3-A",
      "options": [
        {"label": "도구 정의 + `tool_choice: {type: 'tool', name: X}`", "description": "tool_use 강제"},
        {"label": "프롬프트에 'JSON으로 답해'", "description": "프롬프트"},
        {"label": "tool_choice: auto", "description": "auto"},
        {"label": "system_prompt에 schema 텍스트 첨부", "description": "system schema"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. Optional `notes` 필드 처리?",
      "header": "Quiz 4-3-B",
      "options": [
        {"label": "`{type: ['string', 'null']}` — null 허용", "description": "nullable"},
        {"label": "required에서 제외만", "description": "required 제외"},
        {"label": "기본값으로 빈 string", "description": "기본값"},
        {"label": "'N/A' 문자열", "description": "N/A"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. enum [USD, EUR, KRW] — 새 통화 등장 시?",
      "header": "Quiz 4-3-C",
      "options": [
        {"label": "enum에 'other' + currency_other_detail 추가", "description": "other+detail"},
        {"label": "schema 자체를 매번 갱신", "description": "매번 갱신"},
        {"label": "USD로 fallback", "description": "USD fallback"},
        {"label": "free string으로 변경", "description": "string"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A** — `tool_choice: {type: "tool", name}`이 호출 강제. `auto`는 도구 미호출 가능.
- **Q2: A (nullable)** — 빈 문자열·기본값은 hallucination 유도.
- **Q3: A (other+detail)** — Schema 안정성 + 새 케이스 capture.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 4-4 진행",
    "options": [
      {"label": "다음 (4-4 Validation-Retry)", "description": "Pydantic + semantic 피드백"},
      {"label": "4-3 변형", "description": "다른 schema 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
