# Block 5-6: Information Provenance & Multi-source Synthesis

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Multi-Agent Patterns): https://www.anthropic.com/engineering/built-multi-agent-research-system
> ```

## EXPLAIN

> Task 5.6 — Synthesis 시 출처·시점·충돌을 보존

### 한 줄 정의

**Multi-source 연구·요약에서 source attribution이 누락되면 합쳐진 결과의 신뢰도 검증 불가. Subagent 출력에 `{claim, source, excerpt, date}` 강제 → synthesis 단계에서 보존·conflict 발생 시 annotate (한쪽 임의 선택 X).**

### 표준 Subagent 출력 schema

```python
{
    "findings": [
        {
            "claim": "AI 도입 후 코드 리뷰 시간 30% 감소",
            "source_url": "https://example.com/study-2025",
            "source_name": "Acme Corp 2025 Engineering Survey",
            "excerpt": "After integrating AI assistants, mean review time...",
            "publication_date": "2025-06-15",
            "confidence": "high"
        },
        ...
    ],
    "coverage_gaps": [
        "엔터프라이즈 외 small team 데이터 없음"
    ]
}
```

→ Coordinator·synthesis 에이전트는 이 구조 **그대로 보존**해야 한다.

### Synthesis의 4가지 책임

```
1. Claim-source mapping 보존
   각 진술 → 어느 source에서 왔는지 추적

2. Conflict annotation
   credible source 2개가 다른 통계
   → 한쪽 선택 X. 양쪽 보존 + 출처 명시

3. Temporal context
   publication_date 같이 표기
   → "2023 데이터: X / 2025 데이터: Y" — 모순 아닌 시점 차이

4. Coverage gap reporting
   well-supported 영역과 contested·unavailable 영역 분리
```

### Conflict 처리 (좋은 예 vs 나쁜 예)

```
[Bad — 임의 선택]
"AI 도입 시 생산성 25% 향상"
→ 어느 source인지, 다른 통계는 무엇이었는지 알 수 없음

[Good — annotate]
"AI 도입 시 생산성 향상 추정치는 source별로 차이가 있다:
 - Acme 2025 (n=500): 30% 감소
 - StackOverflow 2024 (n=10000): 18% 감소
 시점·표본 크기·정의 차이가 분산을 설명한다."
```

### Temporal data 함정

```
[Bad]
"클라우드 비용 평균 2배 → 0.5배"
→ 모순처럼 보임. 같은 source의 2020 vs 2024 데이터인데 시점 누락.

[Good]
"클라우드 비용 평균: 2020년 X, 2024년 Y (출처 동일)"
→ 시점 차이 → 시계열 변화로 인지
```

### Content type별 rendering

```
- 재무 데이터 → 표 (구조 보존)
- 뉴스·인용 → prose (맥락 보존)
- 기술 findings → structured list

→ 한 가지 형식으로 통일 X. 원형 보존.
```

### Coverage gap 패턴

```
[Bad — 가짜 완결성]
"창의 산업의 AI 영향 — 모든 영역 커버"
→ 사실 시각예술만 다뤘고 음악·문학·영화 누락

[Good]
"Well-supported: 시각예술(디지털아트, 그래픽디자인, 사진)
 Coverage gaps: 음악, 문학, 영화 — subagent assignment에 미포함"
→ 신뢰성 + 추가 작업 필요성 명확
```

→ Sample Q 7과 직결. Coordinator decomposition이 좁으면 synthesis도 좁아진다.

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| Subagent는 prose로 결과 반환 (자유 형식) | **Structured 출력 강제** — claim/source/excerpt/date |
| 충돌 시 더 신뢰 가는 source로 통일 | **Annotate** — 양쪽 보존 + 출처 명시 |
| 시계열 데이터를 "최신 값"으로 통일 | **Date 명시** — 시점 차이를 모순으로 오해 방지 |
| Synthesis 중간에 source URL 압축 | **보존** — 압축은 attribution 손실 |
| "모든 영역 커버" 라고 합리화 | **Coverage gap을 명시** — well-supported vs missing 분리 |

### Sample Q 시사점

- Direct 출제는 PDF Sample Q에 없음. 그러나 **D1 1-3(Subagent context)·1-6(Decomposition) + D5-3(Error propagation) + D5-6(Provenance)** 가 multi-agent research 시나리오의 핵심 4축.
- Sample Q 7(decomposition 좁음 → synthesis 좁음) 패턴이 D5-6과 연결.

## EXECUTE

```
W1. Subagent 출력 schema 설계 — 5필드?
W2. credible source 2개가 다른 통계 — 처리?
W3. 같은 source가 2020·2024 데이터 모두 — 시점 어떻게?
W4. 음악·문학 누락 — synthesis 출력에 어떻게 표기?
W5. 재무 데이터를 prose로 변환했더니 숫자 가독성↓ — 어떤 원칙?
```

→ 각 답: 1-2줄 결정

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. Multi-source 합성에서 credible source 2개가 다른 통계. 처리?",
      "header": "Quiz 5-6-A",
      "options": [
        {"label": "양쪽 모두 보존 + 각각 source 명시 (annotate)", "description": "annotate"},
        {"label": "더 신뢰가 가는 한쪽 선택", "description": "선택"},
        {"label": "평균값 계산", "description": "평균"},
        {"label": "최신 데이터로 통일", "description": "최신"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. Subagent에 어떤 출력 schema 강제?",
      "header": "Quiz 5-6-B",
      "options": [
        {"label": "{claim, source_url, source_name, excerpt, publication_date}", "description": "structured"},
        {"label": "Free prose narrative", "description": "prose"},
        {"label": "Bullet list만", "description": "bullet"},
        {"label": "JSON without dates", "description": "no dates"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. 합성 출력에서 음악·문학 누락. 어떻게 표기?",
      "header": "Quiz 5-6-C",
      "options": [
        {"label": "Well-supported vs Coverage gap 섹션 분리, gap 명시", "description": "gap 분리"},
        {"label": "'모든 분야 커버' 합리화", "description": "합리화"},
        {"label": "조용히 누락", "description": "조용히"},
        {"label": "재실행만 요청", "description": "재실행"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (annotate)** — 임의 선택은 정보 손실. 출처와 함께 양쪽 보존.
- **Q2: A** — Structured 강제로 attribution·temporal 보존.
- **Q3: A (gap 분리)** — Coverage gap 명시는 신뢰성 + 추가 작업 트리거.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 5 종료",
    "options": [
      {"label": "D5 종합 정리", "description": "6블록 관계도 + Sample Q 매핑"},
      {"label": "learn-meta로 이동", "description": "함정·시나리오·Sample Q 종합"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
