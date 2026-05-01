---
name: learn-context-management-reliability
description: CCA-F Domain 5 — Context Management & Reliability (15%). 6개 Task Statement (5.1~5.6) — Conversation Context / Escalation & Ambiguity / Error Propagation / Large Codebase / HITL & Confidence / Information Provenance. "D5", "context management", "escalation", "HITL", "manifest", "provenance" 요청에 사용.
---

# CCA-F D5: Context Management & Reliability (15%)

이 스킬이 호출되면 아래 **STOP PROTOCOL**을 반드시 따른다.

---

## STOP PROTOCOL — 절대 위반 금지

### 각 블록은 반드시 2턴에 걸쳐 진행한다

**Phase A (첫 번째 턴)**
1. references/ 의 EXPLAIN 섹션을 읽는다
2. 개념을 설명한다 (다이어그램·비유 포함)
3. EXECUTE 섹션을 읽고 "직접 해보세요"를 안내한다
4. STOP. 턴 종료.

⛔ Phase A에서 AskUserQuestion 호출 금지
⛔ Phase A에서 QUIZ 섹션 읽기 금지

→ 사용자가 "완료" / "다음" / "ok" 입력

**Phase B (두 번째 턴)**
1. QUIZ 섹션을 읽는다
2. AskUserQuestion으로 자가 점검 퀴즈 출제
3. 정답/오답 피드백 + 함정 패턴 강조
4. 다음 블록 이동 여부를 AskUserQuestion으로 묻는다

### 핵심 금지 사항

1. Phase A에서 AskUserQuestion 호출 금지
2. Phase A에서 QUIZ 섹션 읽기 금지
3. 한 턴에 EXPLAIN + QUIZ 동시 진행 금지
4. 압축 금지

### 공식 문서 URL 출력 (필수)

각 블록 Phase A 시작 시 reference 파일 상단의 `> 공식 문서:` URL을 그대로 출력.

```
📖 공식 문서: [URL]
```

### Phase A 종료 시 필수 문구

```
---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.
```

이 문구 이후 어떤 도구 호출이나 추가 텍스트도 출력하지 않는다.

---

## References 파일 맵 (D5 = 6개 Task Statement)

| 블록 | Task | 모듈 | 파일 |
|------|------|------|------|
| 5-1 | Task 5.1 | Conversation Context Preservation (case facts, lost-in-the-middle, trim) | `references/block5-1-conversation.md` |
| 5-2 | Task 5.2 | Escalation & Ambiguity Resolution | `references/block5-2-escalation.md` |
| 5-3 | Task 5.3 | Error Propagation in Multi-agent Systems | `references/block5-3-propagation.md` |
| 5-4 | Task 5.4 | Large Codebase Context (scratchpad, manifest, subagent delegation) | `references/block5-4-codebase.md` |
| 5-5 | Task 5.5 | HITL Workflows & Confidence Calibration (stratified sampling) | `references/block5-5-hitl.md` |
| 5-6 | Task 5.6 | Information Provenance (claim-source mapping, conflict annotation) | `references/block5-6-provenance.md` |

각 reference 파일은 `## EXPLAIN`, `## EXECUTE`, `## QUIZ` 섹션으로 구성된다.

---

## D5 핵심 함정 패턴

| # | 함정 | 정답 방향 |
|---|------|----------|
| F-D5-1 | Progressive summarization으로 숫자·날짜·금액까지 압축 | **Case facts 블록을 분리** — 매 프롬프트에 원본 그대로 포함 |
| F-D5-2 | Sentiment 분석으로 에스컬레이션 결정 | **정책 갭·고객 명시 요청·진전 불가**가 트리거 (Sample Q 3) |
| F-D5-3 | Subagent 타임아웃 시 generic "search unavailable" 반환 | **Structured error context** — failure type, attempted query, partial results, alternatives (Sample Q 8) |
| F-D5-4 | Long codebase exploration에서 메인 에이전트가 모든 verbose 출력 흡수 | **Subagent delegation + scratchpad files** — coordinator는 high-level만 |
| F-D5-5 | High-confidence 추출의 첫 N건만 검토 | **Stratified random sampling** — bias 없는 정기 샘플 |
| F-D5-6 | Synthesis 단계에서 source URL·날짜 누락 | **Claim-source mapping** + 충돌 시 annotate (한쪽 임의 선택 X) |

---

## 진행 규칙

- 한 번에 한 블록씩 진행
- 6개 블록 완료 시 D5 종합 정리 출력

---

## 시작

```json
AskUserQuestion({
  "questions": [{
    "question": "어디서부터 시작할까요?",
    "header": "D5 시작 블록",
    "options": [
      {"label": "5-1 Conversation Context", "description": "Case facts, lost-in-the-middle"},
      {"label": "5-2 Escalation & Ambiguity", "description": "정책 갭 트리거 (Sample Q 3)"},
      {"label": "5-3 Error Propagation", "description": "Structured error context (Sample Q 8)"},
      {"label": "5-5 HITL & Confidence", "description": "Stratified sampling"},
      {"label": "처음부터 순서대로", "description": "5-1부터 5-6까지"}
    ],
    "multiSelect": false
  }]
})
```

> 시작 블록 선택 후 → 해당 블록의 Phase A부터 진행.
