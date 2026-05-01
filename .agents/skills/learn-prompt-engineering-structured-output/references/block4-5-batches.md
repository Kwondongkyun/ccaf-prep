# Block 4-5: Batch Processing (Message Batches API)

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Message Batches): https://docs.claude.com/en/docs/build-with-claude/batch-processing
> ```

## EXPLAIN

> Task 4.5 — 50% 비용 절감의 비동기 배치, 단 latency tolerant 작업에만

### 한 줄 정의

**Message Batches API: 50% 비용 절감, 최대 24시간 처리, `custom_id`로 결과 매칭. Real-time API 대비 latency 보장 없음 → blocking 워크플로우엔 부적합, overnight 작업엔 최적.**

### Batches vs Real-time 비교

| 축 | Real-time | Batches |
|---|---|---|
| 비용 | 100% | **50%** |
| 응답 시간 | 초 단위 | **최대 24시간** (보장 없음) |
| 적합 워크플로우 | 사용자 대기·blocking | 야간·정기·async |
| 결과 매칭 | 응답 즉시 | **`custom_id`** 필드로 |
| Tool calling | 지원 | 단발성만 (multi-turn 미지원) |

### 어떤 워크플로우에 어떤 API?

```
[Sample Q 11 패턴]
워크플로우 ①: blocking pre-merge check (개발자 PR 대기 중)
  → Real-time. Batches는 24h 내 응답이라 X.

워크플로우 ②: overnight technical debt report (다음 날 아침 검토)
  → Batches. 50% 절감. 24h 안에만 끝나면 됨.

→ 정답: 두 워크플로우 모두 Batches로? X.
       각 API를 적합한 use case에 매칭.
```

### `custom_id` 패턴

```python
batch = client.beta.messages.batches.create(requests=[
    {"custom_id": "doc-001", "params": {...}},
    {"custom_id": "doc-002", "params": {...}},
    ...
])

# 결과 가져올 때
for result in client.beta.messages.batches.results(batch.id):
    doc_id = result.custom_id  # ← 어느 입력의 결과인지 매칭
    handle(doc_id, result.message)
```

→ Batch는 결과 순서·완료 시점이 보장 안 됨. `custom_id`로 trace.

### 실패 처리

- 한 요청 실패해도 다른 요청 계속 처리
- 결과에서 `result.type == "error"` 인 항목 → `custom_id`로 식별 → modification 후 resubmit (예: 너무 큰 문서는 chunk)

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "비용 절감되니 모든 작업 Batches로" | **Latency tolerance 평가 먼저** (Sample Q 11) |
| "Batches에 fallback timeout 두면 안전" | **워크플로우 자체가 latency tolerant이어야**. timeout fallback은 over-engineering |
| "결과 순서 = 입력 순서" | **순서 보장 X**. `custom_id` 필수 |
| "Tool calling multi-turn도 Batches로" | 미지원. Real-time만 |

### Sample Q 매핑

> **Sample Q 11**: pre-merge 체크 + 야간 기술부채 리포트 — 둘 다 Batches로? → **A** (야간만 Batches, 실시간 체크는 Real-time 유지)

## EXECUTE

```
W1. "100건 invoice 야간 추출" — Real-time vs Batches?
W2. "PR 머지 차단 검사" — ?
W3. "결과 순서가 입력과 다르다" — 어떤 메커니즘?
W4. "한 batch에서 5건 실패" — 어떻게 추적?
W5. "Tool calling multi-turn 워크플로우" — Batches 가능?
```

→ 각 답: API 선택 + 1줄 이유

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 두 워크플로우 — (1) blocking pre-merge 검사 (2) overnight 기술부채 리포트. 매니저가 둘 다 Batches로 50% 절감 제안. 평가?",
      "header": "Quiz 4-5-A",
      "options": [
        {"label": "기술부채 리포트만 Batches, pre-merge는 Real-time 유지", "description": "사용 목적별 매칭"},
        {"label": "둘 다 Batches + status polling", "description": "둘 다 Batches"},
        {"label": "둘 다 Real-time 유지", "description": "둘 다 Real-time"},
        {"label": "둘 다 Batches + timeout fallback to Real-time", "description": "fallback"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. Batch 결과 순서가 입력과 다른 이유 + 매칭 메커니즘?",
      "header": "Quiz 4-5-B",
      "options": [
        {"label": "순서 보장 X. `custom_id`로 매칭", "description": "custom_id"},
        {"label": "순서 보장됨 — 그대로 사용", "description": "순서 보장"},
        {"label": "응답 timestamp로 매칭", "description": "timestamp"},
        {"label": "재요청해 순서 맞춤", "description": "재요청"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. Batches의 한계?",
      "header": "Quiz 4-5-C",
      "options": [
        {"label": "Multi-turn tool calling 미지원, 24h 내 완료 보장만", "description": "한계"},
        {"label": "비용이 더 비쌈", "description": "비용"},
        {"label": "동시 요청 1건만", "description": "1건만"},
        {"label": "Streaming만 가능", "description": "Streaming"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A** — Sample Q 11 정답. 각 API의 latency 특성을 워크플로우에 매칭.
- **Q2: A (`custom_id`)** — 비동기 처리라 순서·timing 보장 없음. ID로 trace.
- **Q3: A** — multi-turn tool calling 미지원, 24시간 내 완료(보장 X), Streaming 미지원 등.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 4-6 진행",
    "options": [
      {"label": "다음 (4-6 Multi-pass Review)", "description": "Large PR 분할 (Sample Q 12)"},
      {"label": "4-5 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
