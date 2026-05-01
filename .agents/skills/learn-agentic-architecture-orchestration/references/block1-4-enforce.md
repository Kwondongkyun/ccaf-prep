# Block 1-4: Enforcement·Handoff (Programmatic Prerequisite)

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서: https://docs.claude.com/en/api/agent-sdk/hooks
> 📖 Building Effective Agents: https://www.anthropic.com/engineering/building-effective-agents
> ```

## EXPLAIN

> Task 1.4 — enforcement·handoff 패턴을 갖춘 멀티스텝 워크플로우 구현
>
> ⚠️ **D1에서 가장 자주 출제되는 영역. Sample Q 1번이 정확히 이 토픽.**

### 한 줄 정의

**비즈니스 룰을 프롬프트로 부탁하지 말고, 코드로 강제(prerequisite gate / hook)하라.**

### 핵심 원칙: Programmatic > Prompt

| 측면 | Prompt 기반 | Programmatic 기반 |
|------|-----------|------------------|
| 보장 수준 | 확률적 (모델이 따를 확률) | 결정론적 (100%) |
| 실패율 | 0이 아님 | 0 |
| 적합 영역 | 가이드, 톤, 스타일 | 컴플라이언스, 재무, 보안, 신원 검증 |
| 비용 | 토큰 추가 | 코드 추가 |

→ **금융 거래 / 환불 / 신원 확인 / 정책 enforcement** 등 **결정론적 컴플라이언스가 필요한 곳**에는 반드시 programmatic.

### 패턴 1: Prerequisite Gate

**전제조건 단계가 완료될 때까지 다운스트림 도구 호출을 차단**.

```python
# 의사코드
def on_tool_call(tool_name, args):
    if tool_name in ["process_refund", "lookup_order"]:
        if not state.has_verified_customer_id:
            # 차단하고 에이전트에게 안내
            return {
                "isError": True,
                "errorCategory": "prerequisite_missing",
                "message": "get_customer로 customer ID 먼저 확보 필요",
                "isRetryable": False,
            }
    return execute_tool(tool_name, args)
```

→ `get_customer`가 검증된 ID를 반환할 때까지 `process_refund`·`lookup_order` 차단.
→ 모델이 "고객 이름만 듣고 환불 처리"하는 안티패턴 봉쇄.

### 패턴 2: Tool Call Interception (정책 enforcement)

```python
def on_tool_call(tool_name, args):
    # 환불 한도 정책
    if tool_name == "process_refund" and args["amount"] > 500:
        # 차단 + 에스컬레이션 워크플로우로 리디렉트
        return escalate_to_human(args, reason="amount_exceeds_500")
    return execute_tool(tool_name, args)
```

→ $500 초과 환불은 **모델 판단에 맡기지 않고** 코드가 차단 + 사람에게 라우팅.

### 패턴 3: 구조화된 Handoff

사람 상담원에게 에스컬레이션 시 **구조화된 요약** 제공. 사람은 대화 transcript에 접근권 없음.

```json
{
  "customer_id": "CUST_4823",
  "root_cause": "policy_gap_competitor_price_match",
  "refund_amount_usd": 750,
  "recommended_action": "manager_review_within_24h",
  "transcript_summary": "고객이 경쟁사 가격을 캡처해 매칭 요청. 자사 정책은 자사 사이트 조정만 명시."
}
```

**필수 필드:**
- 고객 정보 (식별자)
- 근본 원인 분석
- 권장 조치
- (필요 시) 금액·금융 데이터

### Sample Q 1번 정면 해부

> 12% 케이스에서 에이전트가 `get_customer`를 건너뛰고 고객 이름만으로 `lookup_order` 호출 → 잘못된 환불.
> 가장 효과적인 변경은?

| 선택지 | 정답 여부 | 이유 |
|--------|---------|------|
| A) **`get_customer` 검증 ID 반환 시까지 prerequisite로 lookup_order·process_refund 차단** | ✅ **정답** | Programmatic 결정론적 보장 |
| B) system prompt 강화 ("주문 작업 전 고객 검증 필수") | ❌ | 확률적 — 0이 아닌 실패율 잔존 |
| C) few-shot 예시로 `get_customer` 먼저 호출 시연 | ❌ | 동일 — 확률적 |
| D) 라우팅 분류기로 도구 부분집합 활성화 | ❌ | 도구 가용성 ≠ 도구 순서. 문제 핵심 빗나감 |

→ **재무적 결과를 초래하는 룰**은 항상 코드. 프롬프트로는 부족.

### 멀티 이슈 분해 + 통합 해결

다중 이슈 고객 요청 처리 패턴:

```
[1] 요청을 별개의 항목으로 분해
    예: "환불 + 배송 추적 + 계정 비밀번호 재설정"
    → [refund_issue, shipping_issue, password_reset]

[2] 공유 컨텍스트(고객 ID, 정책 메타) 사용
    각 이슈를 병렬 조사

[3] 통합된 해결책으로 종합 응답
```

→ 한 이슈씩 순차 처리보다 효율적, 일관된 응답.

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "프롬프트에 '환불 한도 $500' 명시하면 됨" | Hook으로 차단 — 결정론적 보장 |
| "few-shot 늘리면 prerequisite 행동 학습" | 0이 아닌 실패율. 비즈니스 룰엔 부족 |
| "에스컬레이션은 자연어 메시지로" | 구조화된 요약 (필드 정의된 JSON) |
| "prerequisite는 retry 가능" | 정책 위반은 `isRetryable: false` |
| "다중 이슈는 한 번에 한 개씩 처리" | 분해 + 병렬 조사 + 통합 응답 |

### Programmatic vs Prompt — 의사결정 표

| 상황 | 선택 |
|------|------|
| 톤·스타일 ("친절하게") | Prompt |
| 출력 형식 일관성 | Few-shot |
| 도구 선택 일관성 (잘못된 도구 선택) | Description 확장 (D2 Task 2.1) |
| 결정론적 컴플라이언스 (환불 한도) | **Hook (Programmatic)** |
| 도구 호출 순서 (신원 확인 → 환불) | **Prerequisite Gate (Programmatic)** |
| 데이터 정규화 (Unix → ISO) | **PostToolUse Hook (Programmatic)** — Block 1-5 |

## EXECUTE

다음을 직접 설계해보세요.

```
시나리오: 고객 지원 에이전트.
요건:
  R1. process_refund 호출 전 반드시 get_customer로 customer ID 검증.
  R2. 환불 금액 $1000 초과는 자동 처리 금지, 매니저 에스컬레이션.
  R3. 매니저는 대화 transcript 접근 불가.

작업 1: R1을 구현하는 prerequisite gate 의사코드.
작업 2: R2를 구현하는 hook 의사코드.
작업 3: R3 충족할 handoff payload(JSON 필드) 직접 적기.
```

추가: 위 3가지 중 **프롬프트로 처리하면 안 되는 이유**를 한 줄씩 적어보세요.

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 12% 확률로 에이전트가 get_customer를 건너뛰고 고객 이름만으로 lookup_order 호출 → 잘못된 환불. 가장 효과적 해결?",
      "header": "Quiz 1-4-A",
      "options": [
        {"label": "get_customer 검증 ID 반환까지 lookup_order·process_refund를 차단하는 prerequisite", "description": "Programmatic gate"},
        {"label": "system prompt에 '주문 작업 전 고객 검증 필수' 강화", "description": "Prompt 강화"},
        {"label": "few-shot 예시로 get_customer 선호출 시연", "description": "Few-shot"},
        {"label": "라우팅 분류기로 도구 부분집합 활성화", "description": "Tool routing"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 환불 한도 정책($500 초과 차단)을 신뢰성 있게 enforce하려면?",
      "header": "Quiz 1-4-B",
      "options": [
        {"label": "system prompt에 '$500 초과 환불 금지' 명시", "description": "Prompt"},
        {"label": "process_refund 호출 인터셉션 hook으로 차단 + 에스컬레이션 워크플로우로 리디렉트", "description": "Hook"},
        {"label": "tool_choice를 'auto'로 두고 모델 판단", "description": "Default"},
        {"label": "process_refund의 description에 한도 명시", "description": "Tool description"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. 사람 상담원 에스컬레이션 시 가장 적절한 handoff 형태는?",
      "header": "Quiz 1-4-C",
      "options": [
        {"label": "전체 대화 transcript 그대로 전달", "description": "Full transcript"},
        {"label": "고객 ID·근본원인·환불금액·권장조치를 담은 구조화 요약", "description": "Structured handoff"},
        {"label": "마지막 사용자 메시지만 전달", "description": "Last message"},
        {"label": "에이전트의 자유 서술형 요약", "description": "Free-form"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A** — **Sample Q 1번 정답.** 핵심 비즈니스 로직(신원 검증 → 금융 거래)에 prerequisite은 결정론적 보장. B/C는 확률적이라 재무 사고 위험. D는 가용성 ≠ 순서.
- **Q2: B (Hook)** — **F1 정면.** 한도는 정책. 프롬프트로는 0이 아닌 실패. Hook으로 차단 + 대체 워크플로우 라우팅.
- **Q3: B (Structured handoff)** — 사람은 transcript 접근 불가. 필수 필드(고객ID, 근본원인, 금액, 조치) 정의된 JSON. 자유 서술은 누락 위험.

### 출제 변형

- **"prerequisite gate 위반 시 응답?"** → `{isError: true, errorCategory: "prerequisite_missing", isRetryable: false, message: ...}` (D2 Task 2.2 구조화 에러와 결합)
- **"환불 한도 hook이 차단했을 때 다음 행동?"** → 에스컬레이션 워크플로우로 리디렉트. 단순 에러 반환은 부족.
- **"다중 이슈 요청 처리?"** → 분해 → 공유 컨텍스트로 병렬 조사 → 통합 응답.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 1-5 진행",
    "options": [
      {"label": "다음 (1-5 Hooks: PostToolUse·인터셉션)", "description": "Hook 패턴 더 깊이"},
      {"label": "1-4 변형 한 번 더", "description": "Sample Q 변형"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
