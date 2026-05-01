# Block 5-3: Error Propagation in Multi-Agent Systems

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Multi-Agent Patterns): https://www.anthropic.com/engineering/built-multi-agent-research-system
> 📖 공식 문서 (Errors): https://docs.claude.com/en/api/errors
> ```

## EXPLAIN

> Task 5.3 — Subagent 실패를 구조화·전파하여 coordinator가 의미 있는 결정을 내리게 한다

### 한 줄 정의

**Subagent의 access failure(timeout, 권한, network)를 valid empty result처럼 숨기면 coordinator는 잘못된 결론(예: "검색 결과 없음")으로 합성한다. Failure type·attempted query·partial results·alternatives를 구조화해 그대로 전파해야 한다.**

### Sample Q 8 패턴 — 핵심 시나리오

> Multi-agent research system. 한 subagent가 internal docs 검색 timeout. 응답: "search unavailable". Coordinator가 합성 시 다른 subagent 결과만으로 "no internal references found"로 결론. **가장 효과적 처리?**
> 
> A) **Subagent가 structured error context 반환 (failure type, attempted query, partial results, alternatives) → coordinator가 partial 출력 + 한계 명시** ← 정답
> B) Subagent가 자동 retry 무한정
> C) Coordinator가 timeout만 보고 다른 subagent로 silent fallback
> D) Sentence "결과 없음"으로 통합

→ A 정답. **Access failure는 valid empty result와 다르다**.

### Failure ≠ Empty result

```
[Anti-pattern — 동등 취급]
  search returns []         → "no results"
  search times out          → "no results"  ← 잘못. 검색 자체가 실패
  search permission denied  → "no results"  ← 잘못. 검색 못함

→ 두 경우 모두 "결과 없음"으로 합성되면 사용자는 신뢰할 수 없는 빈 결론을 받음.

[Correct — 구분]
  empty result   → {status: "ok", findings: []}
  timeout        → {status: "access_failure", failure_type: "timeout", attempted: ..., partial: [...], alternatives: [...]}
  permission     → {status: "access_failure", failure_type: "permission_denied", ...}
```

### Structured Error Context (subagent → coordinator)

```python
{
    "status": "access_failure",
    "failure_type": "timeout" | "permission_denied" | "network" | "rate_limit" | "schema_mismatch",
    "attempted_query": "internal docs search 'auth migration'",
    "partial_results": [...],            # timeout 전 받은 부분 결과
    "alternatives": [
        "retry with shorter query",
        "use cached snapshot from 2025-04-29",
        "ask user for direct doc reference"
    ],
    "retry_after_sec": 30,                # transient면
    "context": {"agent": "internal-search", "ts": "..."}
}
```

→ Coordinator가 합성 시 이 구조를 보고:
- partial_results를 합성에 포함 (있으면)
- 최종 출력에 "internal docs는 timeout으로 부분 결과만" 명시
- 신뢰도 등급 낮춤
- alternatives를 사용자에게 옵션으로 제시

### 4가지 책임 (Subagent 측)

```
1. Categorize — failure_type 명시
2. Attempt log — 무엇을 시도했는지 기록
3. Partial preserve — timeout 전 받은 결과 보존
4. Alternative suggest — coordinator가 fallback 결정 가능하도록
```

### 4가지 책임 (Coordinator 측)

```
1. Failure ≠ empty 구분 — silent merge 금지
2. Partial 합성 — partial_results는 활용, 출처 명시
3. 한계 명시 — 최종 응답에 "어느 source가 실패" 보고
4. Decision propagate — alternatives 기반 retry/fallback/HITL 결정
```

### Anti-pattern 4가지

```
1. Silent fallback
   subagent timeout → coordinator가 다른 source로 조용히 대체
   → 사용자는 부분 답인지 전체 답인지 모름

2. "search unavailable" 같은 generic 메시지
   → failure_type·attempted·partial 누락 → 디버깅 불가

3. 무한 retry
   transient 가정으로 무한 retry → permanent(권한)면 비용 폭주

4. partial_results 폐기
   timeout 직전 받은 80% 결과를 그냥 버림
   → 정보 손실. 합성에 포함했어야
```

### Retry 분류 (보조 — D5-3 핵심은 propagation)

| 에러 타입 | 동작 |
|---------|------|
| 429 rate limit (retry-after) | 지정 시간 후 retry. structured error로 retry_after 전달 |
| 5xx 서버 | 백오프 + jitter, max 2~3 |
| 401/403 | 즉시 fail. failure_type=permission_denied로 propagate |
| 400 validation | 즉시 fail. coordinator가 입력 수정 후 재시도 |
| 도구 timeout | 1회 retry → access_failure로 partial과 함께 propagate |
| 비즈니스 룰 위반 | escalate to HITL (D5-2) |

→ Retry 자체보다 "**전파 시 구조 보존**"이 D5-3의 핵심.

### Coordinator 합성 출력 패턴

```
[Bad — silent]
"내부 문서에는 관련 정보가 없습니다."
→ 사용자는 신뢰. 사실 검색 자체가 실패였음.

[Good — annotate]
"외부 source 3건 발견 (출처: ...).
 내부 문서 검색은 timeout(60s)으로 부분 결과만 확보(2/예상 50건).
 권장: 더 구체적인 키워드로 재검색하거나 직접 문서 참조."
```

→ D5-6(Provenance)와 직결: conflict·gap을 annotate.

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| Timeout = empty result | **다름.** access_failure로 구분, partial 보존 |
| "search unavailable" 한 줄로 충분 | failure_type·attempted·partial·alternatives 4요소 |
| Subagent 에러는 coordinator가 알아서 처리 | Subagent가 **structured**로 명시 — coordinator는 합성용 |
| Partial 결과는 timeout 시 폐기 | **보존 + 합성 포함 + 한계 명시** |
| 무한 retry로 reliability ↑ | Permanent에 무의미. failure_type 분류 후 결정 |
| Coordinator가 silent fallback 더 사용자 친화 | 신뢰 손실. 한계 노출이 정직 |

### Sample Q 매핑

- **Q8 (multi-agent error)** → A. Structured error context (failure_type, attempted, partial, alternatives) → coordinator가 partial + 한계 명시.
- 시나리오 3 (Multi-Agent Research) — D5-3 + D5-6(Provenance)이 합성 신뢰성의 두 축.

## EXECUTE

```
W1. Internal search subagent가 60s timeout, 직전 2건 받음. 어떤 응답을 coordinator에 반환?
W2. Coordinator가 W1의 응답을 받았을 때 사용자에게 어떻게 합성해 보여줄까?
W3. Subagent가 401 permission denied. retry? Propagate?
W4. "search unavailable" 한 줄 응답의 위험 3가지?
W5. Partial results를 합성에 포함하는 게 정말 안전한가? 어떤 조건에서?
```

→ 각 답: 1-3줄

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. Subagent가 internal docs search timeout. Coordinator가 'no internal references' 결론으로 합성. 가장 효과적 처리?",
      "header": "Quiz 5-3-A",
      "options": [
        {"label": "Subagent가 structured error (failure_type, attempted, partial, alternatives) 반환 → coordinator는 partial 합성 + 한계 명시", "description": "Sample Q 8"},
        {"label": "Subagent가 무한 retry", "description": "Retry"},
        {"label": "Coordinator가 다른 subagent로 silent fallback", "description": "Silent"},
        {"label": "결과 없음으로 통합", "description": "Empty"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. Subagent error context의 핵심 4요소?",
      "header": "Quiz 5-3-B",
      "options": [
        {"label": "failure_type, attempted_query, partial_results, alternatives", "description": "정답"},
        {"label": "stack trace, line number, file, function", "description": "디버그 메타"},
        {"label": "user_id, session_id, ts, hash", "description": "세션 메타"},
        {"label": "단일 message 문자열", "description": "Single str"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. Timeout과 valid empty result를 동일 취급하면?",
      "header": "Quiz 5-3-C",
      "options": [
        {"label": "Coordinator가 잘못된 빈 결론 합성, 사용자 신뢰 손실", "description": "Silent failure"},
        {"label": "비용만 줄어들 뿐 문제 없음", "description": "Fine"},
        {"label": "Latency 개선", "description": "Latency"},
        {"label": "구조화 비용 절감", "description": "Cost"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (Sample Q 8)** — Structured error로 propagate. Coordinator는 partial을 활용하면서 한계 명시.
- **Q2: A** — failure_type·attempted·partial·alternatives. 4요소 모두 propagation 결정에 필요.
- **Q3: A (Silent failure)** — access_failure ≠ empty. 동일 취급은 합성 신뢰성 파괴.

### 출제 변형

- **"401 propagate?"** → 즉시 fail, failure_type=permission_denied로 coordinator에 보고. retry 무의미.
- **"Partial 0건이면?"** → partial_results=[] 명시 + alternatives. timeout 사실 자체가 정보.
- **"Coordinator가 alternatives 자동 실행?"** → 신중. cost·latency·신뢰성 trade-off 후 HITL 옵션 제시도 가능.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 5-4 진행",
    "options": [
      {"label": "다음 (5-4 Large Codebase)", "description": "scratchpad / manifest / subagent / /compact"},
      {"label": "5-3 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
