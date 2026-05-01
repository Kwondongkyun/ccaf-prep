# Block 5-2: Escalation & Ambiguity Resolution

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Permissions / Approvals): https://docs.claude.com/en/docs/claude-code/permissions
> ```

## EXPLAIN

> Task 5.2 — 언제 사람에게 넘기고, 언제 자율 해결하는가

### 한 줄 정의

**에스컬레이션 트리거 = (1) 고객 명시 요청 (2) 정책 갭/예외 (3) 진전 불가. **NOT** sentiment 분석이나 self-confidence 점수.**

### 정당한 트리거 3가지

```
1. 고객 명시 요청
   "사람과 통화하고 싶어요" → 즉시 에스컬레이션
   조사·resolve 시도 X. 즉시.

2. 정책 갭 / 예외
   policy: own-site price match만 허용
   request: "competitor price match"
   → policy 명시 없음. 에스컬레이션.

3. 진전 불가
   3턴 동안 같은 이슈 반복. 정보 수집 안 됨.
   → 에스컬레이션.
```

### 정당하지 않은 트리거

```
[Bad]
- Sentiment 분석 → "고객이 화남" → 에스컬레이션
  → 화내는 단순 케이스도 있음. case complexity와 무관.

- Self-confidence score < 0.7 → 에스컬레이션
  → LLM은 어려운 케이스에 자신만만하게 틀리는 패턴 (calibration 안 됨)
  → 신뢰 X.
```

### 모호함 해결 (Ambiguity Resolution)

```
[Bad]
get_customer("John") → 5명 매치 → heuristic으로 1명 선택
  → wrong customer. 환불·중요 작업이면 사고

[Good]
5명 매치 → "추가 식별자(전화번호·주문번호) 필요" 요청
  → 명확 후 진행
```

### Sample Q 3 패턴

> "55% first-contact resolution. 단순 케이스(damage replacement w/ photo)는 에스컬레이션, 복잡 케이스(policy 예외)는 자율 시도. 어떻게 개선?"
> → **(A) Explicit escalation criteria + few-shot examples**

| 다른 보기 | 왜 틀림 |
|---------|--------|
| Self-confidence score → threshold | LLM은 hard case에 잘못 자신만만 |
| 별도 classifier 모델 학습 | over-engineered. prompt 먼저 |
| Sentiment 분석 | sentiment ≠ case complexity |

### Knowledge of (PDF 5.2 그대로)

- 적절한 트리거: 고객 요청, 정책 갭, 진전 불가
- 즉시 에스컬레이션 vs 시도 후 reiterate 시 에스컬레이션 구분
- multi-match 시 추가 식별자 요청 (heuristic 선택 X)

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| Sentiment 기반 에스컬레이션 | **정책 갭·고객 명시·진전 불가** 트리거 |
| Self-confidence threshold | LLM calibration 신뢰 X |
| 화난 고객 — 자율 시도 X | 자율 가능 케이스(자료 확보된 단순 환불)는 인정 후 시도, **재요청 시** 에스컬레이션 |
| 5명 매치 — heuristic 선택 | 추가 식별자 **요청** |

### Sample Q 매핑

- **Q3**: Explicit criteria + few-shot. **A**.

## EXECUTE

```
W1. "고객이 '사람 바꿔달라' 명시" — 즉시 / 한 번 시도?
W2. "DB에 5명 동명이인" — 어떻게?
W3. "policy: 자사 가격만 매치 / 요청: 경쟁사 가격" — 자율 / 에스컬레이션?
W4. "고객이 화남, 환불 자료 있음" — 즉시 에스컬레이션?
W5. "Sentiment > 부정 임계 → 에스컬레이션 자동" — 평가?
```

→ 각 답: 1-2줄 결정 + 트리거 분류

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. Agent가 단순 케이스 에스컬레이션, 복잡 케이스 자율 시도 — 가장 효과적 개선?",
      "header": "Quiz 5-2-A",
      "options": [
        {"label": "Explicit escalation criteria + few-shot examples", "description": "정답"},
        {"label": "Self-confidence score 임계", "description": "self-confidence"},
        {"label": "별도 classifier 모델", "description": "classifier"},
        {"label": "Sentiment 분석 자동 라우팅", "description": "sentiment"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 고객이 '사람과 얘기하고 싶다' 명시. 처리?",
      "header": "Quiz 5-2-B",
      "options": [
        {"label": "즉시 에스컬레이션. 조사 시도 X", "description": "즉시"},
        {"label": "먼저 자율 resolve 시도 후 안 되면 에스컬레이션", "description": "시도 후"},
        {"label": "sentiment 확인 후 결정", "description": "sentiment 확인"},
        {"label": "self-confidence 측정", "description": "confidence"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. tool 결과가 5명 매치. 처리?",
      "header": "Quiz 5-2-C",
      "options": [
        {"label": "추가 식별자 요청 (전화번호·주문번호)", "description": "추가 식별자"},
        {"label": "휴리스틱으로 가장 가능성 높은 1명 선택", "description": "heuristic"},
        {"label": "5명 모두 처리", "description": "5명 모두"},
        {"label": "에스컬레이션", "description": "에스컬레이션"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A** — Sample Q 3 정답. Self-confidence는 LLM이 hard case에 self-bias.
- **Q2: A (즉시)** — 명시 요청은 honor. 조사 시도는 신뢰 훼손.
- **Q3: A (추가 식별자)** — heuristic 선택은 wrong customer 위험. 환불·결제면 사고.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 5-3 진행",
    "options": [
      {"label": "다음 (5-3 Error Propagation)", "description": "Structured error context"},
      {"label": "5-2 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
