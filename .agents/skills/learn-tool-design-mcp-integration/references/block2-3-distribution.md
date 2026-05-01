# Block 2-3: Tool Distribution & `tool_choice`

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Tool Use): https://docs.claude.com/en/docs/build-with-claude/tool-use
> 📖 공식 문서 (Permissions): https://docs.claude.com/en/docs/claude-code/permissions
> ```

## EXPLAIN

> Task 2.3 — 작업·서브에이전트별 도구 노출 (allowlist) + `tool_choice`로 호출 강제

### 한 줄 정의

**모든 도구를 default로 노출 X. 작업/서브에이전트별 최소 도구 allowlist + 결정성이 필요할 때는 `tool_choice`로 호출 강제. 안전성 ↑ + LLM 의사결정 노이즈 ↓.**

### 두 축

```
[축 1 — Distribution (allowlist)]
  어떤 caller(서브에이전트·skill·command)에 어떤 도구를 노출할지
  → "이 도구를 쓸 수 있는가" 결정

[축 2 — tool_choice (호출 강제)]
  노출된 도구 중 LLM이 어떻게 선택할지
  → "이 호출에서 도구를 반드시 쓰는가" 결정
```

→ 두 축은 보완. allowlist는 정적 권한, tool_choice는 호출별 동적 정책.

### `tool_choice` 4가지 모드

```
tool_choice: {"type": "auto"}
  - 기본값. LLM이 도구 호출 vs 자연어 응답을 자유 선택.
  - 일반 대화·라우팅에 적합.

tool_choice: {"type": "any"}
  - LLM이 무조건 도구 중 하나를 호출. 자연어 단독 응답 불가.
  - 도구 라우터·필수 액션 패턴.

tool_choice: {"type": "tool", "name": "extract_entities"}
  - 지정한 도구만 호출. 구조화 출력 강제(JSON Schema via tool_use).
  - 결정성 100% 필요할 때.

tool_choice: {"type": "none"}
  - 어떤 도구도 호출 못함. 자연어 응답만.
  - 요약·설명 단계에서 도구 차단.
```

### 모드 선택 결정 트리

```
도구 호출이 필수인가?
├─ No → "auto"
└─ Yes
   ├─ 특정 도구 결과가 반드시 필요? → "tool" (구조화 출력)
   ├─ 여러 도구 중 하나면 OK? → "any"
   └─ 자연어 응답만 원함? → "none"
```

### 왜 최소 도구 (allowlist)?

```
[모든 도구 노출 — Bad]
  - LLM의 도구 선택 attention 분산 (description-matching이 어려워짐 — Block 2-1 연계)
  - destructive 도구 의도치 않은 호출 (rm, push, delete)
  - 보안: 권한 큰 도구가 작은 작업에 노출

[최소 allowlist — Good]
  - 작업에 필요한 도구만 — 선택 정확도 ↑
  - destructive 차단 (코드 분석에 Write 불필요)
  - 권한 분리 (subagent별)
```

### F-D2-3 함정

> "코드 분석 subagent가 가끔 파일을 수정. 어떻게?"

| 잘못된 답 | 올바른 답 |
|---------|---------|
| 프롬프트에 "수정 금지" | **allowed-tools: Read, Grep, Glob** — programmatic 차단 |

→ 프롬프트는 확률적. Allowlist는 결정적.

### Subagent 정의 시 도구 제한

```yaml
---
name: code-reviewer
description: PR 보안·성능 분석. 읽기 전용.
allowed-tools: [Read, Grep, Glob, Bash]
---
```

→ Edit, Write 누락 → 결정적으로 수정 불가.

### Skill / Slash command 도구 제한

```yaml
---
name: pr-review
context: fork
allowed-tools: Read, Grep
---
```

### 작업별 도구 매핑

| 작업 | 노출 도구 |
|-----|---------|
| 코드 분석 (읽기) | Read, Grep, Glob, Bash(읽기) |
| 코드 작성 | Read, Edit, Write, Bash |
| 디버깅 | Read, Grep, Bash |
| 배포 자동화 | Bash(특정), Read |
| 보안 스캔 | Read, Grep |
| 데이터 조회 | Custom DB tool only |

### Bash 세분화

```yaml
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(npm test:*)
```

→ Bash 전체 노출 ❌. 명령어 단위 allowlist 가능.

### `tool_choice` 활용 패턴

```python
# 1) 분류기 — 반드시 카테고리 도구 호출
response = client.messages.create(
    model="claude-opus-4-7",
    tools=[classify_intent_tool],
    tool_choice={"type": "tool", "name": "classify_intent"},
    messages=[{"role": "user", "content": user_query}]
)
# → 자연어 답변 없이 100% 구조화 결과

# 2) 라우터 — 여러 도구 중 하나 선택
response = client.messages.create(
    tools=[lookup_order, get_customer, refund_order],
    tool_choice={"type": "any"},
    messages=[...]
)
# → "안녕하세요" 같은 자연어 빠져나감 차단

# 3) 요약 — 도구 차단
response = client.messages.create(
    tools=[...],          # 도구는 정의되어 있음
    tool_choice={"type": "none"},
    messages=[{"role": "user", "content": "지금까지 발견 요약해줘"}]
)
# → 도구 호출 없이 자연어만
```

### `tool_choice` + 구조화 출력 (D4-3 연계)

```
JSON Schema validation이 필요한 경우:
  tool_choice: {type: "tool", name: "extract_X"} 강제
  → 응답이 반드시 해당 tool input_schema에 맞춘 JSON
  → Pydantic·Zod로 파싱·검증
```

→ Block 4-3 (JSON Schema via tool_use) 의 핵심 메커니즘.

### Risk hierarchy

```
[High risk — 명시 허용 필수]
  rm, mv, force-push, delete, drop, kill

[Medium]
  Write, Edit, push, deploy

[Low]
  Read, Grep, Glob, status 류 read-only
```

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "프롬프트로 도구 제한" | 확률적. allowed-tools (programmatic) |
| "default가 모든 도구" | 작업별 최소만 — 안전·정확도 |
| "Bash는 전체 노출" | 명령 단위 allowlist (`Bash(git status:*)`) |
| "Subagent도 메인 도구 다 받음" | 격리된 allowlist 명시 |
| "도구 많을수록 LLM이 똑똑" | Attention 분산 → 정확도 ↓ |
| "tool_choice는 auto면 충분" | 분류·구조화 출력은 `"tool"` 강제 |
| "구조화 출력은 JSON mode" | Anthropic은 `tool_use` + `tool_choice: tool`이 표준 |

### Sample Q 매핑

> "코드 리뷰 subagent가 파일 수정. 가장 결정적 방어?"
> → allowed-tools에서 Edit/Write 제외. 프롬프트는 부족.

> "Bash 전체를 subagent에 — 위험. 어떻게?"
> → 명령 단위 allowlist. `Bash(npm test:*)` 형태.

> "분류 결과를 매번 JSON으로 받고 싶다. 어떻게?"
> → `tool_choice: {type: "tool", name: classify}` (D4-3 연계)

## EXECUTE

```
W1. 보안 스캔 subagent — 어떤 도구만? allowed-tools 작성
W2. 배포 자동화 — 어떤 도구만? Bash 명령어 단위로
W3. 코드 분석 subagent가 가끔 push — 어떻게?
W4. 사용자 질문을 카테고리(billing/tech/refund) 셋 중 하나로 분류해 JSON 받고 싶다 — tool_choice 어떻게?
W5. "지금까지 작업 요약해줘" — 도구가 정의되어 있어도 호출 막고 싶다 — tool_choice?
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
      "question": "Q1. 코드 분석 subagent가 가끔 파일 수정. 가장 결정적 방어?",
      "header": "Quiz 2-3-A",
      "options": [
        {"label": "allowed-tools: [Read, Grep, Glob] — Edit/Write 제외", "description": "Allowlist"},
        {"label": "프롬프트에 '수정 금지' 강조", "description": "Prompt"},
        {"label": "사용자가 매번 검수", "description": "Manual"},
        {"label": "Subagent 사용 중단", "description": "Avoid"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 사용자 질문을 항상 정해진 분류 도구의 JSON 출력으로 받고 싶다. tool_choice?",
      "header": "Quiz 2-3-B",
      "options": [
        {"label": "{type: 'tool', name: 'classify_intent'}", "description": "특정 도구 강제"},
        {"label": "{type: 'auto'}", "description": "기본"},
        {"label": "{type: 'any'}", "description": "도구 중 아무거나"},
        {"label": "{type: 'none'}", "description": "도구 차단"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. 모든 도구를 default 노출의 가장 큰 부작용?",
      "header": "Quiz 2-3-C",
      "options": [
        {"label": "도구 선택 attention 분산 + destructive 의도치 않은 호출", "description": "Noise + risk"},
        {"label": "토큰 비용", "description": "Cost"},
        {"label": "응답 속도 ↓", "description": "Speed"},
        {"label": "문제 없음", "description": "Fine"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (Allowlist)** — F-D2-3 정면. Programmatic 차단. 프롬프트는 확률적.
- **Q2: A (`tool_choice: tool`)** — 구조화 출력 강제. `any`는 여러 도구 중 하나라 결정성 부족, `auto`는 자연어로 빠질 수 있음.
- **Q3: A (Noise + risk)** — Attention 분산 + destructive 사고. 양쪽 손해.

### 출제 변형

- **"도구 많을수록 좋다?"** → No. Attention dilution.
- **"Allowlist vs blocklist?"** → Allowlist 권장. 명시 허용만 — 안전 default.
- **"Subagent별 도구 다르게?"** → Yes. 작업·역할별 분리.
- **"tool_choice none은 언제?"** → 도구 정의는 유지하되 이 호출에서만 차단 (요약·설명 단계).

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 2-4 진행",
    "options": [
      {"label": "다음 (2-4 MCP Server Integration)", "description": ".mcp.json project scope"},
      {"label": "2-3 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
