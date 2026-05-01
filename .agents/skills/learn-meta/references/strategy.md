# CCA-F 시험 전략

> **시험:** 60문항 / 120분 / 720점 합격 (scaled 100~1000)
> **형식:** 6 시나리오 중 4개 랜덤 출제, 각 시나리오에 다중 문항
> **재응시:** 6개월 락

---

## 시간 배분

```
60문항 / 120분 = 평균 2분/문항

권장:
  [Pass 1] 80분 — 60문항 1차 풀이
    - 즉답 가능 (시나리오·함정 매핑됨): 30~60초
    - 모르는 건 마킹 + 스킵
  [Pass 2] 30분 — 마킹 문항 재시도
  [Pass 3] 10분 — 전체 빠른 검토
```

**원칙:** 어려운 문항에 5분 묶이지 않기. 마킹 후 다음.

---

## 정답 추론 — 5초 룰

객관식 4지선다. 보기 읽으면서 **5초 안에**:

```
[1] 시나리오 식별
   "고객 지원" → 시나리오 1
   "PR / GitHub Actions" → 시나리오 5
   "research / multi-source" → 시나리오 3
   ...

[2] 도메인 식별
   "도구 description / MCP" → D2
   "CLAUDE.md / .claude/" → D3
   "JSON Schema / Pydantic / Batches" → D4
   "escalation / manifest / provenance" → D5
   "agentic loop / subagent / coordinator" → D1

[3] 함정 매핑
   traps.md의 "함정 식별 체크리스트"

[4] 보기에서 함정 보기 즉시 제거
   "Sentiment 추가" → D5-2 함정 → 제거
   "Few-shot으로 도구 선택" → D2-1 함정 → 제거
   "한 번에 큰 PR" → D4-6 함정 → 제거

[5] 남은 옵션 중 가장 구체적·결정적 선택
```

---

## 빈출 정답 키워드 (50개)

```
- programmatic prerequisite / hook
- stop_reason (tool_use, end_turn)
- explicit context passing (subagent)
- hub-and-spoke
- decomposition breadth
- description (5요소: what/input/when/boundary/return)
- structured error (category/isRetryable/action)
- allowlist (allowed-tools)
- scoped tool (caller별 80%)
- tool_choice (auto/any/tool/none)
- .mcp.json (project scope)
- .claude/commands/ (project scope)
- .claude/rules/ + glob frontmatter
- context: fork
- plan mode (큰 변경)
- claude -p (CI 1회)
- /memory, /compact, --resume
- explicit criteria (vague X)
- few-shot (transformation/ambiguous)
- JSON Schema via tool_use
- nullable: true
- Pydantic + semantic feedback retry
- Message Batches (overnight, 24h SLA, 50% cost)
- multi-pass (file-by-file + integration)
- case_facts 보존
- lost-in-the-middle
- escalation triggers (정책 갭/명시 요청/진전 불가)
- structured error context (failure_type/attempted/partial/alternatives)
- scratchpad / manifest
- subagent delegation (verbose 격리)
- per-doc-type / per-field 분해
- stratified random sampling
- edge over-sample
- claim-source mapping
- annotate (양쪽 보존)
- coverage gap
```

→ 보기에 이 키워드가 있으면 정답 가능성 ↑.

---

## 빈출 함정 키워드 (즉시 제거)

```
- "Sentiment analysis" (D5-2 escalation은 정책 기반)
- "Self-confidence threshold만으로 escalate"
- "Few-shot으로 도구 선택 개선" (D2-1은 description-first)
- "정책을 CLAUDE.md / 프롬프트에" (D1·D3·D4는 시스템/programmatic)
- "모든 도구 default 노출"
- "큰 PR 한 번에" (D4-6은 multi-pass)
- "모든 호출 Batches로" (D4-5는 latency-tolerant만)
- "Aggregate 97% accuracy면 자동화" (D5-5는 disaggregate)
- "High-confidence first N으로 sampling" (D5-5는 stratified random)
- "Subagent 무한 retry" (D5-3은 structured error로 propagate)
- "Conflict 시 더 신뢰 가는 쪽 선택" (D5-6은 annotate)
- "처음부터 다시 시작" (D5-4는 manifest 복구)
```

---

## 시나리오별 우선순위

```
공식 12 Sample Q는 시나리오 1·2·3·5에서만. 시나리오 4·6은 (직접 노출 X) — 시험 출제 가능.

[Top 3 — 반드시 마스터]
1. 시나리오 1 (Customer Support) — D1·D2·D5 핵심
2. 시나리오 3 (Multi-Agent Research) — D1·D2·D5 결합
3. 시나리오 5 (CI) — D3·D4 결합

[Mid 2]
4. 시나리오 2 (Code Generation) — D3 단독
5. 시나리오 6 (Structured Extraction) — D4·D5

[Lower 1]
6. 시나리오 4 (Developer Productivity) — D3·D4
```

---

## 도메인 가중치별 학습 시간

```
D1 (27%) — 16~17문항 예상 → 가장 중요
D3 (20%) — 12문항 예상
D4 (20%) — 12문항 예상
D2 (18%) — 11문항 예상
D5 (15%) —  9문항 예상

→ D1 + D3 + D4 = 67%. 우선 마스터.
→ D2·D5는 출제 빈도 낮지만 multi-domain 시나리오에 자주 등장.
```

---

## 시험 직전 24시간 체크리스트

```
[D-1]
  □ traps.md 한 번 훑기
  □ sample-q.md 12문항 정답·도메인 매핑 확인
  □ scenarios.md 6 시나리오 맵 머리에
  □ "함정 식별 체크리스트" 5분

[당일 30분 전]
  □ 빈출 정답/함정 키워드 50+ 한 번 빠르게
  □ 시간 배분 계획 (80/30/10)

[시험 중]
  □ 시나리오 식별 → 도메인 → 함정 → 보기 5초
  □ 어려운 건 마킹 + 스킵
  □ Pass 2에서 마킹 재시도
```

---

## 흔한 실수

```
1. 첫 인상으로 정답 결정 — 함정 보기는 그럴듯
2. 보기 4개를 모두 읽지 않고 결정
3. 시나리오 무시하고 일반론으로 풀이
4. 한 문항에 5분 이상 — 시간 부족
5. "둘 다 맞아 보임"에서 더 구체적·결정적인 쪽 선택 안 함
6. Programmatic vs Prompt 헷갈림 — 정책은 항상 코드
7. CLAUDE.md vs 시스템 프롬프트 헷갈림 — 정체성·정책은 시스템
8. Project scope vs User scope 혼동 — 팀 공유는 project
```

---

## 마지막 한 줄

> **"가장 구체적·결정적·programmatic한 옵션이 보통 정답."**
> Vague·prompt-based·"AI 알아서" 옵션은 보통 함정.
