# 공식 Sample Q 12개 풀이

> **출처:** Anthropic Claude Certified Architect — Foundations Exam Guide PDF (Version 0.1, 2025-02-10), 12 Sample Questions across 4 scenarios.
> 본 자료는 학습용 풀이·해설. 실제 시험 문항은 다름.

---

## Scenario A — Customer Support Resolution Agent (Q1·Q2·Q3)

### Q1 — Programmatic prerequisite (D1)

**상황** Customer Support 에이전트가 환불 처리. 정책상 $500 한도, 가끔 한도 초과 환불을 시도하는 케이스 발견. 가장 효과적 first step?

**보기**
- A) **Programmatic prerequisite check (allowance) — 도구 실행 전 코드 검증** ← 정답
- B) 시스템 프롬프트에 "$500 초과 금지" 강조
- C) Few-shot $499 환불 예시 5개
- D) 사용자가 매번 검수

**정답: A**
**도메인:** D1 (Task 1.4 — Enforcement·Handoff)
**함정:** F-D1-1 (Programmatic > Prompt)
**해설:** 정책·한도는 코드로. 프롬프트는 확률적 — LLM이 우회 가능. Hook 또는 prerequisite check가 결정적.

---

### Q2 — Tool description 보강 (D2)

**상황** Production logs에서 agent가 order 질문에 `get_customer`를 호출. 두 도구 모두 minimal description("Retrieves customer information" / "Retrieves order details"). 가장 효과적 first step?

**보기**
- A) Few-shot 예시 5-8개 (correct routing 보여주기)
- B) **각 도구의 description을 입력 형식·예시 쿼리·boundary·"when NOT to use"로 확장** ← 정답
- C) Routing classifier 구현
- D) 두 도구를 `lookup_entity`로 통합

**정답: B**
**도메인:** D2 (Task 2.1 — Tool Description & Boundary)
**함정:** F-D2-1 (Description-first)
**해설:** Description이 LLM 도구 선택의 1차 신호. 원인이 description 부재인데 few-shot은 token·복잡도만 추가. Routing classifier(C)는 over-engineered. Consolidation(D)은 valid한 architectural 선택이지만 first step으로는 과함.

---

### Q3 — Explicit escalation criteria (D5)

**상황** Customer Support agent의 escalation 정확도 80%. 사용자가 "에이전트가 사람에게 너무 늦게/빠르게 넘김". 가장 효과적?

**보기**
- A) **Explicit escalation criteria + few-shot 예시 (정책 갭 / 명시 요청 / 진전 불가)** ← 정답
- B) Sentiment analysis 추가
- C) 더 큰 모델
- D) Self-confidence threshold

**정답: A**
**도메인:** D5 (Task 5.2 — Escalation & Ambiguity)
**함정:** F-D5-2 (Sentiment X, 정책 갭/명시 요청/진전 불가 O)
**해설:** Escalation은 정책 기반 결정. Sentiment·confidence는 표면 신호로 잘못된 학습. Explicit criteria + few-shot이 boundary 학습에 결정적.

---

## Scenario B — Code Generation with Claude Code (Q4·Q5·Q6)

### Q4 — `.claude/commands/` project scope (D3)

**상황** 팀 전체가 사용할 custom slash command 정의. 어디에?

**보기**
- A) **`.claude/commands/<name>.md` (project scope, git 공유)** ← 정답
- B) `~/.claude/commands/<name>.md` (user scope)
- C) `~/.claude.json` MCP 항목
- D) CLAUDE.md 안에 inline

**정답: A**
**도메인:** D3 (Task 3.3 — Custom Commands)
**함정:** F-D3-3 (project vs user scope)
**해설:** 팀 공유 = git에 들어가는 project scope. user scope는 개인 dev box 전용.

---

### Q5 — Plan mode for monolith→microservice (D3)

**상황** 큰 monolith를 microservice로 마이그레이션. 어디부터 어떻게 시작?

**보기**
- A) **Plan mode로 단계·영향·트레이드오프를 먼저 설계, 사용자 승인 후 실행** ← 정답
- B) 직접 코드 작성 시작
- C) Subagent 5개를 동시 spawn해 영역별 병렬
- D) CLAUDE.md에 "microservice로 가자" 적기

**정답: A**
**도메인:** D3 (Task 3.5 — Plan vs Direct)
**함정:** F-D3-4 (큰 변경에 직접 시작)
**해설:** 큰 영향·되돌리기 어려운 작업은 plan으로 합의. 직접 시작하면 잘못된 방향에서 비용 폭주.

---

### Q6 — `.claude/rules/` glob (D3)

**상황** 모노레포에 흩어진 파일별 컨벤션 (예: `services/payment/**` 는 PCI 룰, `services/user/**` 는 PII 룰). 어떻게 적용?

**보기**
- A) **`.claude/rules/<rule>.md` 각각 + frontmatter `glob: services/payment/**`** ← 정답
- B) 글로벌 CLAUDE.md에 모든 룰
- C) 시스템 프롬프트에 모든 룰
- D) 사용자가 매번 룰 입력

**정답: A**
**도메인:** D3 (Task 3.2 — `.claude/rules/`)
**함정:** F-D3-2 (전역 CLAUDE.md에 흩뿌리기)
**해설:** 패턴 매칭으로 자동 적용. 글로벌 CLAUDE.md는 무관 룰까지 매번 로드 — 토큰·attention 낭비.

---

## Scenario C — Multi-Agent Research System (Q7·Q8·Q9)

### Q7 — Coordinator decomposition (D1)

**상황** Multi-agent research에서 coordinator가 "창의 산업 AI 영향" 질문에 시각예술만 분해하고 음악·문학·영화는 분해 누락. Synthesis도 시각예술 중심으로 좁아짐. 가장 효과적?

**보기**
- A) Subagent 결과를 더 길게 요약
- B) **Coordinator decomposition을 충분히 넓게 (시각/음악/문학/영화) + coverage gap 체크** ← 정답
- C) Synthesis 단계에서 누락 분야 stub 추가
- D) 동일 질문을 다시 던지기

**정답: B**
**도메인:** D1 (Task 1.6 — Decomposition)
**함정:** F-D1-5 (좁은 분해)
**해설:** Synthesis 품질은 decomposition breadth에 종속. 좁으면 synthesis도 좁다. Coverage gap 명시는 D5-6과 연계.

---

### Q8 — Structured error context (D5)

**상황** Multi-agent에서 internal docs 검색 subagent가 timeout. "search unavailable"이라고 응답. Coordinator는 다른 subagent 결과만으로 "no internal references found"로 합성. 가장 효과적?

**보기**
- A) **Subagent가 structured error context 반환 (failure_type, attempted_query, partial_results, alternatives) → coordinator가 partial 출력 + 한계 명시** ← 정답
- B) Subagent 무한 retry
- C) Coordinator가 다른 subagent로 silent fallback
- D) 결과 없음으로 통합

**정답: A**
**도메인:** D5 (Task 5.3 — Error Propagation)
**함정:** F-D5-3 (access failure ≠ empty result)
**해설:** Timeout과 valid empty는 다르다. Structured 4요소(failure_type/attempted/partial/alternatives)로 propagate. Coordinator는 partial 활용 + 한계 명시.

---

### Q9 — Scoped verify_fact tool (D2)

**상황** Synthesis agent가 매번 fact-check를 위해 coordinator를 거침. 40% latency 증가. 분석 결과 85%는 simple lookup, 15%는 deep investigation. 가장 효과적?

**보기**
- A) **Synthesis agent에 scoped `verify_fact` 도구 추가 (simple lookup용), 복잡 검증은 기존 coordinator delegation 유지** ← 정답
- B) Synthesis에 모든 web 도구 부여
- C) Verify를 batch로 묶음
- D) Web search 결과 캐싱

**정답: A**
**도메인:** D2 (Task 2.3 — Tool Distribution)
**함정:** F-D2-3 (caller별 80% 사용 패턴 미고려)
**해설:** 모든 도구 노출(B)은 책임 경계 무너짐. Caller별 80% 사용 패턴에 맞춘 scoped tool로 빠른 경로 + 신뢰성 보존.

---

## Scenario D — Claude Code for Continuous Integration (Q10·Q11·Q12)

### Q10 — `claude -p` flag (D3)

**상황** GitHub Actions에서 매 PR마다 자동 리뷰. CLI 호출 패턴?

**보기**
- A) **`claude -p "<prompt>"` (1회 실행, stdout 결과)** ← 정답
- B) `claude` 실행 후 인터랙티브 모드 자동화
- C) WebSocket 연결 유지
- D) Background daemon

**정답: A**
**도메인:** D3 (Task 3.6 / CLI usage)
**함정:** Stateful session vs one-shot 혼동
**해설:** `-p` (print mode)는 1회 실행에 최적. CI에 적합.

---

### Q11 — Batches API for overnight only (D4)

**상황** Pre-merge PR 리뷰는 즉시 응답 필요. 매일 야간엔 전체 codebase regression 분석. 비용 절감 위해 모두 Batches API로 가야 할까?

**보기**
- A) **Pre-merge는 standard messages.create(즉시), 야간 regression만 Batches API** ← 정답
- B) 모두 Batches로 비용 절감
- C) 모두 standard로 가용성 우선
- D) Pre-merge에서 Batches 폴링 루프

**정답: A**
**도메인:** D4 (Task 4.5 — Batches API)
**함정:** F-D4-5 (latency tolerance 미고려)
**해설:** Batches는 24h SLA, 50% cost. Latency-tolerant만. Blocking pre-merge는 즉시 호출.

---

### Q12 — Multi-pass file-by-file + integration (D4)

**상황** 14개 파일이 변경된 큰 PR을 한 번에 리뷰. Output 일관성·정확도 떨어짐. 가장 효과적?

**보기**
- A) **File-by-file pass(파일별 리뷰) + integration pass(전체 일관성)** ← 정답
- B) 14파일 한 번에 더 큰 컨텍스트로
- C) 사용자가 직접 파일별 분할
- D) Subagent 14개 동시 spawn

**정답: A**
**도메인:** D4 (Task 4.6 — Multi-instance / Multi-pass)
**함정:** F-D4-6 (큰 PR을 한 번에)
**해설:** Multi-pass: 1) 각 파일 독립 리뷰 → 2) integration pass에서 cross-file 일관성. Subagent 14개 동시(D)는 결과 통합 부재.

---

## 풀이 결정 트리 (시험 중)

```
1) 시나리오 식별 (지문 첫 2줄)
2) 도메인 식별 (키워드: "도구 description"=D2, "session/CLAUDE.md"=D3 등)
3) 함정 풀에서 정답 후보 좁히기 (traps.md 매핑)
4) 보기 4개에서 함정 보기 제거
5) 보통 정답은 가장 "구체적 + 결정적"인 옵션
```

## 빠른 정답 패턴

| 키워드 | 정답 방향 |
|-------|---------|
| 정책·한도·금액 강제 | Programmatic prerequisite (Q1) |
| 도구 잘못 선택 | Description 보강 first step (Q2) |
| Escalation 정확도 | Explicit criteria + few-shot (Q3) |
| 팀 공유 명령어 | `.claude/commands/` (Q4) |
| 큰 리팩토링 | Plan mode (Q5) |
| 흩어진 컨벤션 | `.claude/rules/` glob (Q6) |
| 합성 결과 좁음 | Decomposition 분해 폭 (Q7) |
| Subagent timeout | Structured error context (Q8) |
| Latency 40% ↑ | Scoped tool (Q9) |
| CI 1회 실행 | `claude -p` (Q10) |
| 비용 절감 + latency tolerance | Batches는 overnight만 (Q11) |
| 큰 PR 일관성 | Multi-pass (Q12) |
