# CCA-F 함정 30+ 종합 (공식 PDF 도메인 기준)

> **사용법:** 시험 직전 한 번 훑기. 정답 방향 키워드만으로 정답 가능하도록.
> **기준:** Anthropic Claude Certified Architect — Foundations Exam Guide PDF (Version 0.1, 2025-02-10)

---

## D1 — Agentic Architecture & Orchestration (27%)

### F-D1-1: Programmatic prerequisite > Prompt
**함정:** "정책·한도를 프롬프트에 적자."
**정답:** 정책·검증·게이트는 코드. 프롬프트는 보조. (Sample Q 1)
**키워드:** prerequisite check, code-level validation, hook.

### F-D1-2: stop_reason 4단계 루프
**함정:** "결과만 받으면 됨."
**정답:** `tool_use` → 도구 실행 → 결과 message → 다시 호출. `stop_reason`(`tool_use`/`end_turn`)으로 종료 판단. 임의 반복 한도는 보조.
**키워드:** agentic loop, stop_reason, end_turn.

### F-D1-3: 명시 컨텍스트 전달 (subagent)
**함정:** "Subagent가 부모 결정 자동 상속."
**정답:** **Task 도구 호출 시 프롬프트에 명시 전달**. 격리 default.
**키워드:** explicit context passing, isolation.

### F-D1-4: Hub-and-spoke
**함정:** "subagent끼리 직접 대화."
**정답:** Coordinator 중앙 + subagent 격리 + 병렬. 결과는 coordinator로 수렴.
**키워드:** coordinator-subagent, hub-and-spoke.

### F-D1-5: Decomposition 충분히
**함정:** "좁게 분해해서 빠르게."
**정답:** 너무 좁은 decomposition → synthesis도 좁아짐 (coverage gap). 충분히 분해 + coverage 확인. (Sample Q 7)
**키워드:** decomposition breadth, coverage.

### F-D1-6: Hooks (PostToolUse 인터셉션)
**함정:** "프롬프트로 행동 강제."
**정답:** Hook으로 결정성 강화. 프로그램이 통제.
**키워드:** PostToolUse, PreToolUse, hook intercept.

### F-D1-7: Session/fork
**함정:** "Verbose skill을 부모 세션에서."
**정답:** `context: fork` 또는 별 session으로 격리. 부모 컨텍스트 보호.
**키워드:** session, fork, resume.

---

## D2 — Tool Design & MCP Integration (18%)

### F-D2-1: Description-first
**함정:** "도구 선택 오류 → few-shot 추가."
**정답:** **Description 확장이 first step**. 5요소(what / input format / when / boundary / return). (Sample Q 2)
**키워드:** tool description, boundary, when-not-to-use.

### F-D2-2: Structured Error Response
**함정:** "Raw 에러 그대로 LLM에."
**정답:** `{errorCategory, message, isRetryable, suggestedAction, context}` 형식.
**키워드:** structured error, isRetryable.

### F-D2-3: Tool allowlist + scoped tool
**함정:** "모든 도구 default 노출 / 모든 caller에 다 줌."
**정답:** Caller별 80% 사용 패턴에 맞춰 scoped. allowlist + `tool_choice`로 강제. (Sample Q 9)
**키워드:** allowlist, scoped tool, tool_choice.

### F-D2-4: `.mcp.json` project scope
**함정:** "팀 공유 MCP를 `~/.claude.json`에."
**정답:** **`.mcp.json` (project scope, git 공유)**. `~/.claude.json`은 personal.
**키워드:** .mcp.json, project scope.

### F-D2-5: Built-in 도구 적재적소
**함정:** "코드 검색에 항상 grep."
**정답:** **Glob = 파일 패턴**, **Grep = 콘텐츠 검색**, **Bash = 일회성 명령**. Read/Edit/Write 구분.
**키워드:** Glob vs Grep, Read vs Bash cat.

### F-D2-6: 비슷한 두 도구 합치기 vs description 보강
**함정:** "두 도구가 비슷하니 lookup_entity로 통합."
**정답:** **Description 보강이 first step**. Consolidation은 valid한 architectural 선택이지만 first step으로는 과함.
**키워드:** description first, consolidation last.

---

## D3 — Claude Code Configuration & Workflows (20%)

### F-D3-1: CLAUDE.md = 컨벤션 / 시스템 프롬프트 = 정책
**함정:** "정책·페르소나도 CLAUDE.md에."
**정답:** 정책·정체성·안전은 **시스템 프롬프트**. CLAUDE.md는 컨벤션·도메인.
**키워드:** policy in system prompt.

### F-D3-2: `.claude/rules/` glob
**함정:** "흩어진 파일 컨벤션을 글로벌 CLAUDE.md에."
**정답:** **`.claude/rules/<rule>.md` + glob frontmatter**. 패턴 매칭 시 자동 적용. (Sample Q 6)
**키워드:** .claude/rules, glob frontmatter.

### F-D3-3: Project-scope command
**함정:** "Custom command를 user-scope에."
**정답:** 팀 공유는 **`.claude/commands/<name>.md`** (project scope, git). User-scope는 `~/.claude/commands/`. (Sample Q 4)
**키워드:** .claude/commands/, project scope.

### F-D3-4: Plan mode for large refactor
**함정:** "Monolith → microservice를 직접 시작."
**정답:** 큰 리팩토링은 **plan mode**로 합의 후 실행. 작은 변경엔 직접. (Sample Q 5)
**키워드:** plan mode, ExitPlanMode.

### F-D3-5: Skill `context: fork`
**함정:** "Verbose skill을 부모 컨텍스트에 그대로."
**정답:** `context: fork` frontmatter로 격리. 부모 토큰·attention 보호.
**키워드:** context: fork, allowed-tools.

### F-D3-6: Session resume / `/compact`
**함정:** "긴 작업 끊기면 처음부터."
**정답:** `--resume`, `/memory`, `/compact`, manifest로 복구.
**키워드:** resume, /compact, /memory.

---

## D4 — Prompt Engineering & Structured Output (20%)

### F-D4-1: Explicit criteria
**함정:** "잘 해줘"·"적절하게."
**정답:** 무엇을·무엇과 비교·통과 조건·출력 형식 4요소 명시.
**키워드:** explicit criteria, measurable.

### F-D4-2: Few-shot for transformation/ambiguous
**함정:** "Description만 늘려서 해결."
**정답:** **Few-shot 2-3개** — 입력 예시 + 기대 출력. Ambiguous·transformation에 결정적.
**키워드:** few-shot, input/output pair.

### F-D4-3: JSON Schema via tool_use
**함정:** "JSON mode로 강제."
**정답:** Anthropic은 `tool_use` + `tool_choice: {type:"tool", name:X}`. nullable 필드 명시.
**키워드:** tool_use, tool_choice, nullable.

### F-D4-4: Validation-Retry (semantic feedback)
**함정:** "Pydantic ValidationError 시 무한 retry."
**정답:** 에러 메시지를 **다음 프롬프트에 주입** + max retries (보통 2-3).
**키워드:** Pydantic, semantic feedback retry.

### F-D4-5: Batches API for latency-tolerant only
**함정:** "비용 절감 → 모든 호출 Batches."
**정답:** **24h SLA — overnight·offline만**. Pre-merge / blocking 사용자 대면엔 X. (Sample Q 11)
**키워드:** Message Batches, custom_id, latency tolerance.

### F-D4-6: Multi-pass file-by-file + integration
**함정:** "14파일 PR을 한 번에 리뷰."
**정답:** **File-by-file 리뷰 + integration pass**. 컨텍스트 분산·일관성 보존. (Sample Q 12)
**키워드:** multi-pass, file-by-file, integration.

---

## D5 — Context Management & Reliability (15%)

### F-D5-1: Case facts 보존
**함정:** "Progressive summarization으로 압축."
**정답:** 수치·날짜·금액·식별자는 **case_facts에 분리 보존** + 매 turn 재주입.
**키워드:** case_facts, lost-in-the-middle, trim.

### F-D5-2: Explicit escalation criteria
**함정:** "Sentiment·confidence로 escalate."
**정답:** **정책 갭 / 명시 요청 / 진전 불가**가 트리거. Few-shot로 boundary 보강. (Sample Q 3)
**키워드:** policy gap, explicit request, no progress.

### F-D5-3: Structured error context (multi-agent)
**함정:** "Subagent timeout → coordinator에 'search unavailable'."
**정답:** **failure_type / attempted_query / partial_results / alternatives** 4요소. Coordinator는 partial 합성 + 한계 명시. (Sample Q 8)
**키워드:** structured error context, partial results.

### F-D5-4: Subagent delegation + scratchpad + manifest
**함정:** "Repo wide grep을 부모에서 직접."
**정답:** Verbose는 subagent 격리. 발견은 scratchpad. 결정·상태는 manifest. /compact 전 외부화.
**키워드:** scratchpad, manifest, /compact.

### F-D5-5: HITL 신호 + per-doc-type 분해 + stratified random
**함정:** "97% overall accuracy로 자동화 결정 / 첫 N건 / high-confidence first N으로 sampling."
**정답:** Irreversible/Legal/PII/Large $/Low confidence만 HITL. **per-doc-type / per-field 분해**, **Stratified random sampling** + edge over-sample. (Sample Q 11/12 시나리오 적용)
**키워드:** disaggregate, stratified random, edge over-sample.

### F-D5-6: Information Provenance
**함정:** "Conflict 시 더 신뢰 가는 한쪽 선택."
**정답:** **양쪽 보존 + source·date annotate**. claim-source mapping. Coverage gap 명시.
**키워드:** claim-source mapping, annotate, coverage gap.

---

## Cross-domain 핵심 5선

1. **Description-first** (D2-1) — 도구 일관성 first step.
2. **Programmatic prerequisite** (D1-1) — 정책은 코드.
3. **Explicit criteria + few-shot** (D4-1, D4-2) — vague vs measurable.
4. **Structured error context** (D2-2, D5-3) — single-agent와 multi-agent에 공통 적용.
5. **Stratified + per-stratum disaggregation** (D5-5) — aggregate metric 함정.

---

## 함정 식별 체크리스트 (시험 중)

```
지문에 다음 키워드 보이면 즉시 정답 후보 좁히기:
- "조금 더 정확하게" / "잘 해줘" → Explicit criteria
- "도구 선택" / "비슷한 두 도구" → Description-first
- "subagent timeout" / "search unavailable" → Structured error context
- "97% accuracy" / "첫 N건" → Disaggregate + stratified
- "monolith → microservice" / "큰 리팩토링" → Plan mode
- "팀 공유" → project scope (.claude/, .mcp.json)
- "경계·정책·PII·정체성" → 시스템 프롬프트
- "프로젝트 stack·컨벤션" → CLAUDE.md / .claude/rules
- "명시 요청 / 정책 갭 / 진전 불가" → Escalation 트리거
- "sentiment / confidence-only" → 함정. 정책 기반으로 다시
- "14파일 PR / 큰 PR 리뷰" → Multi-pass file-by-file + integration
- "overnight / offline" → Batches OK. "blocking pre-merge" → Batches X
```
