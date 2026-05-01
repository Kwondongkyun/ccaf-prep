---
name: learn-prompt-engineering-structured-output
description: CCA-F Domain 4 — Prompt Engineering & Structured Output (20%). 6개 Task Statement (4.1~4.6) — Explicit Criteria / Few-shot / JSON Schema via tool_use / Validation-Retry / Batches API / Multi-instance·Multi-pass Review. "D4", "prompt", "JSON schema", "tool_use", "Pydantic", "Batches", "few-shot" 요청에 사용.
---

# CCA-F D4: Prompt Engineering & Structured Output (20%)

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

## References 파일 맵 (D4 = 6개 Task Statement)

| 블록 | Task | 모듈 | 파일 |
|------|------|------|------|
| 4-1 | Task 4.1 | Explicit Criteria & System Prompt | `references/block4-1-criteria.md` |
| 4-2 | Task 4.2 | Few-shot Examples (ambiguous, format demo) | `references/block4-2-fewshot.md` |
| 4-3 | Task 4.3 | JSON Schema via `tool_use` (`tool_choice`, nullable) | `references/block4-3-jsonschema.md` |
| 4-4 | Task 4.4 | Validation-Retry (Pydantic, semantic feedback) | `references/block4-4-validation.md` |
| 4-5 | Task 4.5 | Batch Processing (Message Batches API, `custom_id`) | `references/block4-5-batches.md` |
| 4-6 | Task 4.6 | Multi-instance / Multi-pass Review | `references/block4-6-review.md` |

각 reference 파일은 `## EXPLAIN`, `## EXECUTE`, `## QUIZ` 섹션으로 구성된다.

---

## D4 핵심 함정 패턴

| # | 함정 | 정답 방향 |
|---|------|----------|
| F-D4-1 | "잘 리뷰해줘" 같은 vague 지시 | **Explicit criteria** — 무엇을 무엇과 비교, 어떤 기준 충족 시 통과 |
| F-D4-2 | 구조 다양한 입력 처리에 description만 늘림 | **Few-shot 2-3개** — 입력→출력 패턴 학습 |
| F-D4-3 | Optional 필드를 빈 문자열·기본값으로 채움 | **`nullable: true`** — 정보 없으면 null (hallucination 방지) |
| F-D4-4 | Pydantic ValidationError 시 무한 retry | **에러 메시지를 다음 프롬프트에 주입** + 재시도 한도 |
| F-D4-5 | 모든 비용 절감을 Batches로 | **Latency tolerant만** — blocking pre-merge엔 X (Sample Q 11) |
| F-D4-6 | 14파일 PR을 한 번에 리뷰 → 일관성 깨짐 | **File-by-file pass + integration pass** (Sample Q 12) |

---

## 진행 규칙

- 한 번에 한 블록씩 진행
- 6개 블록 완료 시 D4 종합 정리 출력

---

## 시작

```json
AskUserQuestion({
  "questions": [{
    "question": "어디서부터 시작할까요?",
    "header": "D4 시작 블록",
    "options": [
      {"label": "4-3 JSON Schema via tool_use", "description": "Structured output 핵심 — Sample Q 자주"},
      {"label": "4-4 Validation-Retry", "description": "Pydantic + semantic 에러 피드백"},
      {"label": "4-5 Batches API", "description": "Latency tolerance 판단 (Sample Q 11)"},
      {"label": "4-6 Multi-pass Review", "description": "Large PR 분할 (Sample Q 12)"},
      {"label": "처음부터 순서대로", "description": "4-1부터 4-6까지"}
    ],
    "multiSelect": false
  }]
})
```

> 시작 블록 선택 후 → 해당 블록의 Phase A부터 진행.
