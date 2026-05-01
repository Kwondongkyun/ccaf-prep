# Block 1-5: Agent SDK Hooks (PostToolUse·인터셉션)

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서: https://docs.claude.com/en/api/agent-sdk/hooks
> ```

## EXPLAIN

> Task 1.5 — 도구 호출 인터셉션·데이터 정규화를 위한 Agent SDK Hook 적용

### 한 줄 정의

**Hook = 도구 호출의 흐름에 끼어들어 결정론적 처리를 박는 메커니즘.** 두 방향이 있다 — 들어오는 결과 변환(`PostToolUse`) / 나가는 호출 차단(인터셉션).

### Hook 두 종류

```
                  ┌──── 도구 호출 ────┐
                  │                  │
   에이전트 ─────▶ │  [인터셉션 hook] │ ─────▶ 도구 실행
                  │                  │            │
                  │                  │            ▼
                  │  [PostToolUse]   │ ◀──── 도구 결과
                  │                  │
                  └──────────────────┘
                          │
                          ▼
                       에이전트
```

| Hook | 시점 | 용도 |
|------|------|------|
| **인터셉션 (PreTool)** | 도구가 실행되기 **전** | 정책 enforcement, 차단, 리디렉트 |
| **PostToolUse** | 도구 실행 **후**, 모델이 결과 보기 **전** | 데이터 정규화, 형식 변환, 필드 추리기 |

### 패턴 1: PostToolUse — 데이터 정규화

여러 MCP 도구가 **이질적 형식**으로 데이터 반환 → 에이전트가 처리 전에 통일.

```python
@hook("PostToolUse")
def normalize(tool_name, result):
    if tool_name == "get_order":
        # Unix timestamp → ISO 8601
        result["created_at"] = unix_to_iso(result["created_at"])
    if tool_name == "lookup_user":
        # 숫자 status code → 문자열
        result["status"] = STATUS_MAP[result["status"]]
    return result
```

→ 에이전트는 항상 일관된 형식만 본다. 모델이 "Unix vs ISO" 같은 잡음에 토큰 낭비 안 함.

### 패턴 2: 인터셉션 — 정책 차단 + 리디렉트

```python
@hook("PreToolUse")
def enforce(tool_name, args):
    # 환불 한도 정책
    if tool_name == "process_refund" and args["amount"] > 500:
        return {
            "blocked": True,
            "redirect_to": "escalate_to_human",
            "reason": "amount_exceeds_500",
        }
    return None  # 통과
```

→ Block 1-4의 prerequisite gate와 형제 패턴. 모두 **결정론적 컴플라이언스** 도구.

### Hook vs Prompt — 결정 기준

| 보장 수준 필요 | 선택 |
|--------------|------|
| 100% 보장 (재무·법률·보안) | **Hook** |
| 80~95% 충분 (가이드·톤) | Prompt |

**비즈니스 룰이 보장된 컴플라이언스를 요구하면 항상 Hook.**

### PostToolUse의 진짜 가치

자주 간과되는 패턴 3가지:

**1. 토큰 절감 — verbose 응답 추리기**
```python
# 주문 조회가 40+ 필드 반환. 에이전트가 필요한 건 5개.
@hook("PostToolUse")
def trim_order(tool_name, result):
    if tool_name == "get_order":
        return {k: result[k] for k in ["id", "status", "amount", "items", "customer_id"]}
```
→ 컨텍스트 부풀음 방지 (D5 Task 5.1과 연계).

**2. 메타데이터 부착**
```python
# 검색 결과에 출처 attribution 자동 주입
result["__source"] = {"url": api_url, "fetched_at": now()}
```

**3. 에러 정규화 (구조화)**
```python
# 도구마다 에러 포맷 다름 → 통일
return {
    "isError": True,
    "errorCategory": "transient" | "validation" | "permission" | "business",
    "isRetryable": bool,
    "message": "..."
}
```
→ D2 Task 2.2 구조화 에러 응답 생성 위치.

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "Hook 없이 프롬프트로 정규화 부탁" | PostToolUse hook으로 결정론적 |
| "정책 enforcement는 모델에게 부탁" | 인터셉션 hook으로 차단 |
| "PostToolUse는 후처리만" | 데이터 정규화 + 토큰 절감 + 메타데이터 부착 다목적 |
| "Hook은 세팅 복잡해서 배보다 배꼽" | 결정론 보장 + 토큰 절감 → ROI ↑ |
| "에러는 도구가 알아서 던지면 됨" | Hook으로 errorCategory 구조 통일 |

### Sample Q 매핑

이 블록은 **Sample Q 1번 (prerequisite)** + **Sample Q 8·9번 (구조화 에러)** 와 연결. Hook은 두 영역의 공통 메커니즘.

## EXECUTE

다음 시나리오에 hook 의사코드를 작성해보세요.

```
시나리오: 고객 지원 에이전트.

도구:
- get_order (Unix timestamp 반환)
- get_user (status가 정수 코드)
- process_refund (금액 인자)

요건:
R1. get_order/get_user 결과를 ISO 8601 + 문자열 status로 정규화
R2. process_refund의 amount > 500이면 차단 + escalate_to_human으로 리디렉트
R3. 모든 도구 에러를 {errorCategory, isRetryable, message} 구조로 통일

작업: PostToolUse hook 1개 + PreToolUse hook 1개 의사코드.
```

추가: R3을 구현하지 않고 도구마다 다른 에러 포맷으로 두면 어떤 안티패턴이 되는지 1줄 메모.

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 4개 MCP 도구가 모두 다른 timestamp 형식 반환 (Unix·ISO·human-readable·epoch ms). 에이전트가 비교 작업에서 자주 실수. 가장 효과적 해결?",
      "header": "Quiz 1-5-A",
      "options": [
        {"label": "PostToolUse hook으로 모든 timestamp를 ISO 8601로 정규화 후 에이전트에 전달", "description": "Programmatic normalize"},
        {"label": "system prompt에 '항상 timestamp 변환 후 비교'라고 강조", "description": "Prompt"},
        {"label": "각 도구의 description에 형식 명시", "description": "Description"},
        {"label": "Few-shot으로 변환 예시 제시", "description": "Few-shot"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. Hook이 가장 부적합한 사용처는?",
      "header": "Quiz 1-5-B",
      "options": [
        {"label": "환불 한도 enforcement", "description": "결정론적"},
        {"label": "Unix → ISO 정규화", "description": "포맷 변환"},
        {"label": "에이전트 응답 톤을 더 친절하게 만들기", "description": "Tone"},
        {"label": "verbose 도구 응답에서 5개 필드만 추리기", "description": "Token 절감"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. 도구마다 에러 응답 형식이 다름. 코디네이터가 복구 결정을 내리려면?",
      "header": "Quiz 1-5-C",
      "options": [
        {"label": "PostToolUse hook으로 {errorCategory, isRetryable, message} 구조 통일", "description": "Structured normalization"},
        {"label": "system prompt에 '에러는 잘 처리해'라고 안내", "description": "Prompt"},
        {"label": "에러 발생 시 자동으로 사용자에게 에스컬레이션", "description": "Escalate all"},
        {"label": "에러를 무시하고 계속 진행", "description": "Suppress"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A** — **F1 정면.** 형식 정규화는 코드의 영역. 프롬프트 강조는 확률적, description은 도구 선택용이지 결과 변환용 아님.
- **Q2: C (톤)** — Hook은 결정론적 처리용. 톤은 확률적이라 프롬프트가 적합. 환불 한도/포맷 변환/필드 추리기는 모두 hook 적합.
- **Q3: A** — 일률적 에러 응답은 코디네이터가 복구 못함. errorCategory + isRetryable로 구분해야 transient는 retry, business는 즉시 사용자 알림 등 분기 가능.

### 출제 변형

- **"Hook으로 토큰 절감?"** → 가능. 40+ 필드 도구 응답에서 필요한 5개만 추리기.
- **"Hook이 차단한 호출은 모델에게 어떻게 알리나?"** → 차단 사실을 tool_result로 반환 (errorCategory 명시).
- **"PostToolUse hook이 변경한 결과를 모델이 보고 인식 못하면?"** → 결과 자체를 변환하므로 모델은 변환된 형태만 봄. 인식 이슈 없음.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 1-6 진행",
    "options": [
      {"label": "다음 (1-6 Task Decomposition)", "description": "Prompt chaining vs 동적 분해"},
      {"label": "1-5 변형 한 번 더", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
