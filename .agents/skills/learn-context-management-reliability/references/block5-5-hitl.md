# Block 5-5: HITL Review Workflows & Confidence Calibration

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Permissions/Approvals): https://docs.claude.com/en/docs/claude-code/permissions
> 📖 공식 문서 (Evaluation): https://docs.claude.com/en/docs/test-and-evaluate/develop-tests
> ```

## EXPLAIN

> Task 5.5 — High-stakes에만 HITL + field-level confidence·doc-type별 정확도로 자동화 결정

### 한 줄 정의

**모든 결정 HITL = 사용자 피로. 모든 자동 = 위험. Irreversible·legal·PII·large $·낮은 confidence만 HITL. 그리고 "97% overall accuracy"는 specific doc type 실패를 숨긴다 — field-level confidence + stratified random sampling으로 실제 위험을 노출.**

### Part A — HITL Escalation 신호

```
✓ Irreversible — 되돌릴 수 없음 (DB drop, 메일 발송, 결제)
✓ Legal/Compliance — 법적 책임 (계약, 동의)
✓ PII / Privacy — 개인정보 처리·노출
✓ Large $ — 임계 이상 금액 (회사·정책 기준)
✓ Trust boundary — 외부 시스템·고객 대면
✓ Low confidence — 모델 confidence 낮음, 분류 모호
```

### F-D5-5-A 함정

> "에이전트가 모든 결정에 사용자 확인 → 사용자 피로 / 모든 자동 → 위험. 균형은?"

| 잘못된 답 | 올바른 답 |
|---------|---------|
| 모든 결정 → 사용자 / 모든 자동 → AI | **High-stakes만 HITL** — 신호 기반 선택적 |

### HITL 결정 매트릭스

| 작업 | HITL? |
|-----|-------|
| 코드 분석·요약 | ❌ 자동 |
| 파일 읽기·grep | ❌ 자동 |
| 테스트 실행 | ❌ 자동 |
| 코드 작성 (작업 디렉토리) | ❌ 자동 |
| `rm -rf`, force-push | ✅ HITL |
| Production DB 변경 | ✅ HITL |
| 외부 메일·메시지 발송 | ✅ HITL |
| 결제 / 환불 | ✅ HITL |
| PII 출력 | ✅ HITL |
| 큰 리팩토링 (전체 영향) | ✅ HITL (또는 plan 승인) |

### 좋은 escalation 메시지

```
[Bad — 모호]
"이거 해도 될까요?"

[Good — 구조화]
다음 작업 승인 요청:
  - 작업: production DB의 users 테이블에서 30일 미접속 계정 삭제
  - 영향: 약 1,200건 (irreversible)
  - 대안: soft delete (is_active=false) 가능
  - 추천: soft delete 후 30일 후 hard delete
승인 / 거부 / 대안 선택?
```

### Part B — Confidence Calibration

```python
result = classify(input)
if result.confidence < 0.85:
    escalate_to_human(input, result, alternatives=top3)
else:
    auto_proceed(result)
```

→ Confidence 낮으면 사람. **그러나 confidence 자체가 정직한지** 검증 필요 → labeled validation set.

### F-D5-5-B 함정 — Aggregate Accuracy 함정

> Structured data extraction 시스템: "전체 97% accuracy" — 자동화로 보냐?

| 잘못된 답 | 올바른 답 |
|---------|---------|
| 97%면 충분히 신뢰 → 자동화 | **doc type/field별 분해 — 특정 type에서 60%면 자동화 X** |

```
[숨겨진 위험]
  Invoice docs:   99% accuracy (90% of volume)
  Receipts:       97% accuracy (8% of volume)
  Handwritten:    62% accuracy (2% of volume)  ← aggregate에 묻힘
  
→ Overall 97%는 handwritten의 38% 실패율을 가림.
  Handwritten 류는 자동화 부적합 → HITL로 라우팅.
```

### Field-level Confidence

```
[Bad — overall만]
"이 문서 자동 처리 가능"

[Good — field-level]
{
  invoice_number: 0.98,    → 자동
  total_amount: 0.95,      → 자동
  due_date: 0.62,          → HITL 필드 단위 검토
  vendor_name: 0.91,       → 자동
}
→ 필드별 신뢰 임계로 부분 자동 + 부분 HITL
```

### Labeled Validation Set

```
[필수]
  1. Document type별 ≥30 sample (편향 줄이기 위해 더 많이)
  2. Field별 ground truth labeled
  3. Aggregate accuracy + per-type + per-field 모두 보고

[자동화 결정 기준]
  Per-type accuracy ≥ threshold AND per-field confidence calibrated
  (calibration: confidence 0.9 응답이 실제 90% 맞나?)
```

### F-D5-5-C 함정 — Sampling 편향

> "Eval set을 production log 첫 100건으로. 평가 결과 신뢰?"

| 잘못된 답 | 올바른 답 |
|---------|---------|
| 첫 100건이면 충분 / high-confidence 추출 first N | **Stratified random sampling** — 카테고리별 비례 + 무작위 |

### Sampling 비교

```
[Bad — 시간순 첫 N건]
  - 시간 편향 (최근만 / 오래된 것만)
  - Production 분포 반영 X

[Bad — High-confidence first N]
  - 자동 처리된 쉬운 케이스만 — 모델 약점 못 봄
  - "자기 평가" 편향

[Bad — 단순 random]
  - 우연으로 minor stratum underrepresent
  - Edge case 0건 가능

[Good — Stratified random]
  - Strata = doc type / 사용자 segment / 입력 길이 / edge case
  - 각 stratum 안에서 random
  - Production 분포 보존 + edge case over-sample
```

### Stratified 구현

```python
def stratified_sample(records, strata_key, n):
    by_strata = defaultdict(list)
    for r in records:
        by_strata[r[strata_key]].append(r)
    
    total = len(records)
    sample = []
    for stratum, items in by_strata.items():
        share = len(items) / total
        k = round(n * share)
        sample.extend(random.sample(items, min(k, len(items))))
    return sample
```

→ Edge case (빈 입력, 비영문, 매우 긴 입력)는 비중 작아도 **의도적 over-sample**.

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| 모든 결정 → HITL | 사용자 피로 + 자동화 의미 X |
| 모든 자동 — AI 신뢰 | High-stakes에서 위험 |
| Overall 97%면 자동화 OK | **per-doc-type / per-field로 분해** — minor type 실패 숨겨짐 |
| Confidence는 모델 self-report로 충분 | **Labeled validation set으로 calibration 검증** |
| Eval 샘플은 첫 N건 / high-confidence first N | **Stratified random** — 카테고리 비례 + 무작위 + edge over-sample |
| Random하면 알아서 균형 | 우연 편향. Stratified가 결정적 |
| 한 번 샘플링 후 영구 | Production drift → 정기 갱신 |

### Sample Q / 시나리오 매핑

- 시나리오 4 (결제 자동화) — Large $·irreversible은 HITL 필수.
- 시나리오 6 (Structured Data Extraction) — aggregate 97% / per-type 분해 / stratified random.
- D4-4 (Validation-Retry) — confidence + retry는 자동화 경로의 보조.

## EXECUTE

```
W1. $50 환불 (정책 한도 $100) vs $5,000 환불 (한도 $100) — HITL?
W2. Extraction 시스템 overall 97%, handwritten doc 62%. 자동화?
W3. Confidence 0.95라고 모델이 보고. 어떻게 신뢰?
W4. Eval 샘플을 high-confidence 기록의 first 1000건 — 어디가 잘못?
W5. Edge case가 production 0.1%. Stratified 시 어떻게?
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
      "question": "Q1. Extraction 시스템 overall 97% accuracy. 자동화로 보낼까?",
      "header": "Quiz 5-5-A",
      "options": [
        {"label": "Per doc type / per field로 분해 — 특정 type 60%면 그 type만 HITL", "description": "Disaggregate"},
        {"label": "97%면 충분 — 전체 자동화", "description": "Aggregate"},
        {"label": "리스크 없음 — 그대로", "description": "As-is"},
        {"label": "더 큰 모델로 변경", "description": "Bigger"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. HITL 적용 기준으로 가장 적절?",
      "header": "Quiz 5-5-B",
      "options": [
        {"label": "Irreversible / Legal / PII / Large $ / Low confidence", "description": "Signals"},
        {"label": "모든 결정", "description": "All"},
        {"label": "랜덤 샘플", "description": "Random"},
        {"label": "사용자 요청 시만", "description": "On request"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. Eval set 샘플링. 가장 신뢰성 있는 방법?",
      "header": "Quiz 5-5-C",
      "options": [
        {"label": "Stratified random — 카테고리(doc type/segment) 비례 + edge over-sample", "description": "Stratified"},
        {"label": "Production log 첫 1000건", "description": "First N"},
        {"label": "High-confidence 기록의 first N", "description": "High-conf first"},
        {"label": "단순 random 1000건", "description": "Random"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (Disaggregate)** — F-D5-5-B 정면. Aggregate 평균은 minor type 실패 숨김. per-type/per-field로 자동화 영역 분리.
- **Q2: A (Signals)** — F-D5-5-A. 신호 기반 선택. 모두 HITL은 자동성 X, 모두 자동은 위험.
- **Q3: A (Stratified)** — F-D5-5-C. 시간순/high-confidence first N은 편향. Stratified + edge over-sample.

### 출제 변형

- **"Confidence 0.85가 적절?"** → 도메인별. Calibration set으로 결정 — "0.85 응답들 실제 정확도가 85%인가?"
- **"PII는 처리만 안 하면?"** → 출력·로그·외부 전송 다 영향. 노출 자체가 high-stakes.
- **"Strata 다차원?"** → 가능. doc type × 사용자 segment × 입력 길이 cross.
- **"Production 분포 미상?"** → 먼저 분포 측정 → stratified.
- **"한 번 샘플링 후 영구?"** → No. Drift 발생 → 정기 갱신.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 5-6 진행",
    "options": [
      {"label": "다음 (5-6 Information Provenance)", "description": "claim-source mapping, conflict annotate"},
      {"label": "5-5 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
