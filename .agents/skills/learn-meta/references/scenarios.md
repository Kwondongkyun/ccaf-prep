# CCA-F 공식 시나리오 6개

> **공식 PDF 기준 (Preparation Exercises 섹션):** 6개 중 4개 랜덤 출제. 각 시나리오에 다중 문항 (2~5).
> **사용법:** 각 시나리오를 통째 머리에 박고, 어떤 함정이 어디에 매핑되는지 인지.

---

## 시나리오 1: Customer Support Resolution Agent

**상황**
고객의 주문·환불·계정 문의를 자동 처리하는 에이전트. 환불 한도 정책($500), 정책 외 case는 사람에게.
공식 Sample Q 1·2·3가 이 시나리오.

**도메인:** D1 / D2 / D5

**가능한 출제 함정**
- F-D1-1: $500 환불 한도를 프롬프트에 적기 → **programmatic prerequisite/hook으로** (Q1 정답 A)
- F-D2-1: `get_customer` / `lookup_order` minimal description → **5요소로 보강** (Q2 정답 B)
- F-D5-2: Sentiment 기반 escalation → **explicit criteria(정책 갭/명시 요청/진전 불가) + few-shot** (Q3 정답 A)
- F-D5-1: 5턴 후 환불 금액·날짜 vague → **case_facts 매 turn 재주입**

**핵심 답변 패턴**
- "한도를 어떻게 강제?" → programmatic check. 프롬프트 보조.
- "도구 잘못 선택?" → description 보강이 first step. Few-shot은 두번째.
- "Escalation 정확도 낮음?" → explicit criteria + few-shot. Sentiment는 함정.

---

## 시나리오 2: Code Generation with Claude Code

**상황**
모노레포에서 코드 생성. 흩어진 파일별 컨벤션, 큰 리팩토링(monolith→microservice), 팀 공유 명령어가 필요.
공식 Sample Q 4·5·6이 이 시나리오.

**도메인:** D3

**가능한 출제 함정**
- F-D3-3: 팀 공유 custom command를 `~/.claude/commands/`에 → **`.claude/commands/` (project scope)** (Q4 정답 A)
- F-D3-4: monolith→microservice를 직접 시작 → **Plan mode로 합의 후** (Q5 정답 A)
- F-D3-2: 흩어진 컨벤션을 글로벌 CLAUDE.md에 → **`.claude/rules/<rule>.md` + glob** (Q6 정답 A)
- F-D3-5: Verbose subagent를 부모 컨텍스트에 → `context: fork`

**핵심 답변 패턴**
- "팀 전체 사용?" → project scope (`.claude/commands/`, `.claude/rules/`).
- "전체 영향 큰 작업?" → Plan mode.
- "패턴별 컨벤션?" → glob frontmatter.

---

## 시나리오 3: Multi-Agent Research System

**상황**
사용자 질문에 대해 web search · internal docs · academic papers 등 multi-source. Coordinator + subagent 병렬.
공식 Sample Q 7·8·9가 이 시나리오.

**도메인:** D1 / D2 / D5

**가능한 출제 함정**
- F-D1-5: Decomposition 너무 좁음 (시각예술만, 음악·문학 빠짐) → **분해 충분히 + coverage gap 명시** (Q7 정답 B)
- F-D5-3: Subagent timeout → "search unavailable"로 합성 → **structured error context (failure_type/attempted/partial/alternatives)** (Q8 정답 A)
- F-D2-3: synthesis가 매번 coordinator 거쳐 latency↑ → **scoped verify_fact tool** (80% 사용 패턴) (Q9 정답 A)
- F-D5-6: Conflict 시 한쪽 임의 선택 → **양쪽 annotate + source/date**

**핵심 답변 패턴**
- "synthesis가 좁음?" → decomposition 분해 폭 검토.
- "Subagent 실패 → 빈 결과처럼 합성?" → structured error로 propagate.
- "Coordinator 거쳐서 latency?" → caller별 scoped tool로 80% 빠른 경로.

---

## 시나리오 4: Developer Productivity with Claude

**상황**
개발자가 daily workflow에서 Claude 활용. CLAUDE.md, custom commands, skills, plan mode, session resume.
공식 Sample Q에는 직접 노출 X (시험 출제 가능).

**도메인:** D3 / D4

**가능한 출제 함정**
- F-D3-1: 정체성·정책을 CLAUDE.md에 → 시스템 프롬프트
- F-D3-5: skill `context: fork`로 verbose 격리
- F-D3-6: `--resume`, `/memory`, `/compact`로 긴 세션 관리
- F-D4-1: vague 지시 → explicit criteria
- F-D4-2: ambiguous 입력 → few-shot 2-3개

**핵심 답변 패턴**
- "긴 세션에서 결정 망각?" → manifest + 매 turn 재주입.
- "verbose skill 격리?" → `context: fork`.
- "vague 결과 반복?" → explicit criteria.

---

## 시나리오 5: Claude Code for Continuous Integration

**상황**
PR마다 자동 리뷰. 매일 야간엔 전체 codebase regression 분석. blocking pre-merge에서 빠른 결과 필요.
공식 Sample Q 10·11·12가 이 시나리오.

**도메인:** D3 / D4

**가능한 출제 함정**
- F-D3-3 / SDK: GitHub Actions에서 1회 실행 → **`claude -p` flag** (Q10 정답 A)
- F-D4-5: 모든 호출을 Batches로 → **overnight/offline만** (pre-merge는 즉시 — Q11 정답 A)
- F-D4-6: 14파일 PR을 한 번에 리뷰 → **file-by-file + integration pass** (Q12 정답 A)
- F-D3-5: 같은 세션에서 코드 생성 + 리뷰 → 독립 인스턴스 (self-bias 방지)

**핵심 답변 패턴**
- "CI에서 1회 실행?" → `claude -p`.
- "Latency 민감?" → 즉시 호출. Batches는 overnight.
- "큰 PR 일관성?" → file-by-file + integration pass.

---

## 시나리오 6: Structured Data Extraction

**상황**
다양한 문서(invoice, receipt, handwritten 등)에서 구조화 데이터 추출. 자동화 vs HITL 결정 필요.
공식 Sample Q에는 직접 노출 X (시험 출제 가능).

**도메인:** D4 / D5

**가능한 출제 함정**
- F-D4-3: JSON Schema via tool_use + nullable 필드
- F-D4-4: Pydantic ValidationError → semantic feedback retry
- F-D5-5: Aggregate 97% accuracy → **per-doc-type 분해** — handwritten 62%면 그 type만 HITL
- F-D5-5 (sampling): high-confidence first N → **stratified random + edge over-sample**
- F-D5-1: 47필드 응답 누적 → 5필드만 distill, raw trim

**핵심 답변 패턴**
- "전체 정확도 OK면 자동?" → No. per-type / per-field 분해.
- "Eval 샘플?" → stratified random + edge over-sample.
- "Optional 필드?" → JSON Schema에 nullable: true.

---

## 시나리오 매핑 표

| 시나리오 | 메인 도메인 | 공식 Sample Q | 핵심 함정 |
|---------|----------|--------------|---------|
| 1. Customer Support | D1·D2·D5 | Q1, Q2, Q3 | Programmatic / Description-first / Explicit escalation |
| 2. Code Generation | D3 | Q4, Q5, Q6 | Project scope / Plan mode / `.claude/rules/` glob |
| 3. Multi-Agent Research | D1·D2·D5 | Q7, Q8, Q9 | Decomposition / Structured error / Scoped tool |
| 4. Developer Productivity | D3·D4 | (미표시) | `context: fork` / Resume / Explicit criteria |
| 5. CI | D3·D4 | Q10, Q11, Q12 | `claude -p` / Batches latency / Multi-pass |
| 6. Structured Extraction | D4·D5 | (미표시) | JSON Schema / Disaggregate / Stratified random |

---

## 시험 중 시나리오 식별

```
지문 첫 줄에서 식별:
- "고객 지원 / 환불 / 주문" → 시나리오 1
- "PR / commit / 코드 생성" → 시나리오 2 또는 5
- "research / multi-source / synthesis" → 시나리오 3
- "개발자 daily / IDE" → 시나리오 4
- "CI / GitHub Actions / pre-merge" → 시나리오 5
- "extraction / invoice / document" → 시나리오 6

→ 시나리오 식별 → 매핑된 함정 풀 좁히기 → 정답 빠르게.
```
