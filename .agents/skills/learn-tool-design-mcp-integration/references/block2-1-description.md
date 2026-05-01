# Block 2-1: Tool Description & Boundary

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Tool Use): https://docs.claude.com/en/docs/build-with-claude/tool-use
> 📖 공식 문서 (Custom Tools): https://docs.claude.com/en/api/agent-sdk/custom-tools
> ```

## EXPLAIN

> Task 2.1 — 도구 description은 LLM이 도구를 선택하는 1차 메커니즘

### 한 줄 정의

**LLM의 도구 선택 ≈ description 매칭. minimal description("주문 조회") + 비슷한 두 도구 → 잘못된 선택. Description에 입력 형식·예시 쿼리·boundary·"언제 다른 도구 대신 쓰는지"를 담아야 한다. Few-shot은 description 보강 후 보조 수단.**

### 좋은 description vs 나쁜 description

```
[Bad — minimal]
"Retrieves customer information"
"Retrieves order details"
→ 비슷한 두 도구. LLM이 "내 order #12345 보여줘"에서 customer를 호출하는 사고.

[Good — boundary 포함]
get_customer:
  Look up a customer by their unique customer ID (format: CUS-XXXXX).
  Use this when the request requires customer-level data
  (account status, contact info, customer preferences).
  Do NOT use for order lookups — use lookup_order with order ID (format: ORD-XXXXX).
  Returns: customer record with id, name, email, account_tier.

lookup_order:
  Look up an order by order ID (format: ORD-XXXXX) or order number ("#12345").
  Use this for any order-related query (status, items, refund eligibility).
  Do NOT use for customer profile data — use get_customer.
  Returns: order record with id, customer_id, items, status.
```

### Description의 5가지 요소

```
1. 무엇을 하는가 (verb + 대상)
2. 입력 형식 (식별자 패턴, 예시)
3. 사용 시점 ("when to use")
4. boundary ("when NOT to use, use X instead")
5. 반환 형태 (필드·타입 요약)
```

### Sample Q 2 패턴 — 함정 F-D2-1 정면

> Production logs show the agent calls `get_customer` for order queries. Both tools have minimal descriptions. Most effective first step?
> 
> A) Add few-shot examples (5-8) showing correct routing
> B) **Expand each tool's description with input formats, example queries, edge cases, and boundaries** ← 정답
> C) Implement routing classifier
> D) Consolidate into single `lookup_entity`

**왜 B인가**: Description이 도구 선택의 1차 신호. 원인이 description 부재인데 few-shot은 token 비용·복잡도만 추가. Routing classifier(C)는 over-engineered. Consolidation(D)은 valid한 architectural 선택이지만 "first step"으로는 과함.

### Tool 분리 vs 통합 (Sample Q 9 패턴)

```
Sample Q 9: synthesis agent가 매번 verify_fact를 위해 coordinator 거침 (40% latency↑).
  85%는 simple fact-check, 15%는 deep investigation.

[Bad — 통합]
synthesis agent에 모든 web 도구 노출 → 책임 경계 무너짐

[Good — scoped tool]
synthesis agent에 scoped verify_fact만 (simple lookup용).
복잡 검증은 기존 coordinator delegation 유지.
→ 85% 빠른 경로 + 15% 신뢰성 보존.
```

**원칙**: 도구는 **권한 최소화** + **각 caller의 80% 사용 패턴**에 맞춰 분리.

### Custom tool 등록 (Agent SDK)

```python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool(
    name="lookup_order",
    description="""Look up an order by order ID (format: ORD-XXXXX).
Use for order status/items/refund eligibility queries.
Do NOT use for customer profile — use get_customer instead.
Returns: {id, customer_id, items[], status, total}.""",
    input_schema={"order_id": str}
)
async def lookup_order(args):
    order = await db.fetch_order(args["order_id"])
    return {"content": [{"type": "text", "text": json.dumps(order)}]}

server = create_sdk_mcp_server(name="orders", version="1.0", tools=[lookup_order])
```

→ MCP 표준 반환 `{"content": [{"type": "text", "text": ...}]}`.

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| Description 짧을수록 깔끔 | LLM 선택의 1차 신호. **5요소 모두 포함** |
| 도구 선택 오류 → few-shot 추가 | **Description 확장이 first step** (Sample Q 2) |
| 비슷한 두 도구 → 통합 | First step은 description 보강 |
| 모든 caller에 모든 도구 노출 | **scoped tool** — caller별 80% 사용 패턴 (Sample Q 9) |
| 한 도구에 여러 책임 | 단일 책임. LLM 선택 정확도↑ |

### Sample Q 매핑
- **Q2** (도구 선택 reliability) → **A는 정답이 아니고 B가 정답**. Description 우선.
- **Q9** (latency 40%↑) → A. Scoped verify_fact + 기존 delegation 유지.

## EXECUTE

```
W1. `get_customer` 와 `lookup_order` description 둘 다 한 줄. 5요소로 보강해 작성
W2. Synthesis agent에 verify_fact 추가 — 어떤 description이 적절?
W3. "한 도구가 retrieve+update 둘 다" — 분리해야 할 이유?
W4. 비슷한 도구 `search_docs` vs `query_docs` — boundary를 어떻게 description에 박는가?
```

→ 각 답: description 1단락 + 이유 1줄

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. Production에서 agent가 order 질문에 get_customer를 호출. 둘 다 minimal description. 가장 효과적 first step?",
      "header": "Quiz 2-1-A",
      "options": [
        {"label": "각 도구 description에 입력 형식·예시 쿼리·boundary 추가", "description": "Sample Q 2 정답"},
        {"label": "Few-shot 예시 5-8개 추가", "description": "Few-shot"},
        {"label": "Routing classifier 구현", "description": "Classifier"},
        {"label": "두 도구를 lookup_entity로 통합", "description": "Consolidate"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 좋은 tool description의 5요소?",
      "header": "Quiz 2-1-B",
      "options": [
        {"label": "무엇을·입력 형식·언제 쓰는지·boundary·반환 형태", "description": "정답"},
        {"label": "이름·인자·반환·예외·로깅", "description": "구현 측면"},
        {"label": "버전·작성자·날짜·태그·라이선스", "description": "메타데이터"},
        {"label": "한 줄 요약만", "description": "minimal"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. Synthesis agent가 매 verify마다 coordinator 거쳐 latency 40%↑. 85% simple fact-check.",
      "header": "Quiz 2-1-C",
      "options": [
        {"label": "synthesis에 scoped verify_fact 도구 추가, 복잡건은 기존 delegation 유지", "description": "Sample Q 9"},
        {"label": "synthesis에 모든 web 도구 부여", "description": "All tools"},
        {"label": "verify를 batch로 묶음", "description": "Batch"},
        {"label": "web search가 결과 미리 캐싱", "description": "Cache"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A** — Sample Q 2 정답. Description이 LLM 도구 선택의 1차 신호.
- **Q2: A** — 5요소가 boundary·올바른 선택을 모두 결정.
- **Q3: A** — Sample Q 9 정답. 80% 사용 패턴에 맞춘 scoped tool.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 2-2 진행",
    "options": [
      {"label": "다음 (2-2 Structured Error Response)", "description": "category + isRetryable"},
      {"label": "2-1 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
