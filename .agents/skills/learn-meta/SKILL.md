---
name: learn-meta
description: CCA-F 시험 메타 — 공식 PDF 기반 함정 30+, 시나리오 6, Sample Q 12, 시험 전략, Anthropic Academy 17 공식 코스 ↔ 도메인 매핑. "learn-meta", "함정", "시나리오", "출제 패턴", "공식 코스" 요청에 사용.
---

# CCA-F 시험 메타 — 공식 PDF 기반 출제 패턴 종합

이 스킬은 5개 도메인 학습 후 출제 함정·시나리오·Sample Q를 종합한다.

---

## 시험 정보 (공식 PDF Version 0.1, 2025-02-10)

```
이름: Claude Certified Architect — Foundations (CCA-F)
문항: 60문항 (객관식)
시간: 120분
합격선: 720 / 1000 (scaled)
재응시: 6개월 락
형식: 시나리오 기반 — 6개 시나리오 중 4개 랜덤 출제, 각 시나리오에 다중 문항

도메인 가중치 (공식):
  D1 — Agentic Architecture & Orchestration         27% (Tasks 1.1~1.7)
  D2 — Tool Design & MCP Integration                18% (Tasks 2.1~2.5)
  D3 — Claude Code Configuration & Workflows        20% (Tasks 3.1~3.6)
  D4 — Prompt Engineering & Structured Output       20% (Tasks 4.1~4.6)
  D5 — Context Management & Reliability             15% (Tasks 5.1~5.6)
```

---

## References 파일 맵

| 파일 | 내용 |
|-----|------|
| `references/traps.md` | 30+ 함정 패턴 종합 (도메인별) |
| `references/scenarios.md` | 공식 6 시나리오 — 출제 가능 패턴 |
| `references/sample-q.md` | 공식 Sample Q 12개 풀이 + 함정 매핑 |
| `references/strategy.md` | 시험 전략·시간 배분·실수 방지 |
| `references/anthropic-courses.md` | 공식 Anthropic Academy 17 코스 ↔ CCA-F 도메인 매핑 |

---

## 30+ 함정 종합 — 정답 방향

### D1 — Agentic Architecture & Orchestration (7)
1. **Programmatic prerequisite** — 프롬프트보다 코드 검증 (Sample Q 1)
2. **stop_reason 4단계** — `tool_use` / `end_turn`으로 루프 종료
3. **명시 컨텍스트 전달** — Subagent 자동 상속 X (Task 도구로 명시)
4. **Hub-and-spoke** — coordinator-subagent 격리 + 병렬
5. **Decomposition 충분히** — 좁은 분해는 synthesis도 좁아짐 (Sample Q 7)
6. **Hooks 인터셉션** — PostToolUse로 결정성 강화
7. **Session/fork** — verbose skill 격리

### D2 — Tool Design & MCP Integration (6)
8. **Description-first** — 도구 선택은 description 보강이 first step (Sample Q 2)
9. **5요소 description** — what / input format / when / boundary / return
10. **Structured Error** — `{category, isRetryable, message}`
11. **Tool allowlist + scoped tool** — 80% 사용 패턴 (Sample Q 9)
12. **`.mcp.json` project scope** — 팀 공유. `~/.claude.json`은 personal
13. **Built-in 도구 적재적소** — Glob=파일 패턴 / Grep=콘텐츠 / Bash=일회성

### D3 — Claude Code Configuration & Workflows (6)
14. **CLAUDE.md = 컨벤션** — 정책·페르소나는 시스템 프롬프트
15. **`.claude/rules/` glob** — 흩어진 파일 컨벤션 (Sample Q 6)
16. **Project-scope command (`.claude/commands/`)** — 팀 공유 (Sample Q 4)
17. **Plan mode for monolith→microservice** — 큰 리팩토링은 plan (Sample Q 5)
18. **Skill `context: fork`** — Verbose skill 부모 격리
19. **Session resume / fork** — `/memory`, `/compact`, `--resume`

### D4 — Prompt Engineering & Structured Output (6)
20. **Explicit criteria** — vague "잘 해줘" X
21. **Few-shot for transformation** — ambiguous 입력에 2-3개
22. **JSON Schema via tool_use** — `tool_choice: {type: "tool"}` 강제
23. **Validation-Retry** — Pydantic + semantic 에러를 다음 프롬프트에 주입
24. **Batches API for latency-tolerant only** — blocking pre-merge엔 X (Sample Q 11)
25. **Multi-pass review** — 14파일 PR은 file-by-file + integration (Sample Q 12)

### D5 — Context Management & Reliability (6)
26. **Case facts 보존** — Progressive summarization으로 수치·날짜 vague X
27. **Explicit escalation criteria** — 정책 갭·진전 불가·명시 요청. Sentiment X (Sample Q 3)
28. **Structured error context (multi-agent)** — failure_type / attempted / partial / alternatives (Sample Q 8)
29. **Subagent delegation + scratchpad** — verbose 격리, manifest로 crash 복구
30. **High-stakes만 HITL + per-doc-type 분해** — aggregate 97% 함정 / stratified random
31. **Information Provenance** — claim-source mapping + conflict annotate

---

## 출제 시나리오 6개 (공식 PDF — Preparation Exercises 기준)

> 시험에 6개 중 4개 랜덤 출제. 각 시나리오는 다중 문항.

1. **Customer Support Resolution Agent** (Q1-3) — D1·D2·D5
2. **Code Generation with Claude Code** (Q4-6) — D3
3. **Multi-Agent Research System** (Q7-9) — D1·D2·D5
4. **Developer Productivity with Claude** — D3·D4 (Sample Q 미표시 — 출제 가능)
5. **Claude Code for Continuous Integration** (Q10-12) — D3·D4
6. **Structured Data Extraction** — D4·D5 (Sample Q 미표시 — 출제 가능)

→ 자세히는 `references/scenarios.md`.

---

## 공식 Sample Q 12개 (요약)

> 자세한 풀이는 `references/sample-q.md`.

| # | 시나리오 | 도메인 | 정답 | 핵심 함정 |
|---|---------|-------|------|---------|
| 1 | Customer Support | D1 | A | Programmatic prerequisite (allowance/refund) |
| 2 | Customer Support | D2 | B | Tool description 보강 (description-first) |
| 3 | Customer Support | D5 | A | Explicit escalation criteria |
| 4 | Code Generation  | D3 | A | `.claude/commands/` project scope |
| 5 | Code Generation  | D3 | A | Plan mode for monolith→microservice |
| 6 | Code Generation  | D3 | A | `.claude/rules/` glob |
| 7 | Multi-Agent      | D1 | B | Coordinator decomposition 너무 좁음 |
| 8 | Multi-Agent      | D5 | A | Structured error context |
| 9 | Multi-Agent      | D2 | A | Scoped verify_fact tool |
| 10| CI                | D3 | A | `claude -p` flag |
| 11| CI                | D4 | A | Batches API for overnight only |
| 12| CI                | D4 | A | Multi-pass file-by-file + integration |

---

## 시작

```json
AskUserQuestion({
  "questions": [{
    "question": "어디부터?",
    "header": "Meta 시작",
    "options": [
      {"label": "함정 30+ 정리 (traps.md)", "description": "도메인별 함정 종합"},
      {"label": "시나리오 6개 (scenarios.md)", "description": "공식 출제 시나리오"},
      {"label": "Sample Q 풀이 (sample-q.md)", "description": "12문항 정답·해설"},
      {"label": "시험 전략 (strategy.md)", "description": "시간·실수 방지"},
      {"label": "공식 코스 매핑 (anthropic-courses.md)", "description": "약점 도메인 보강용 Anthropic Academy 17 코스"}
    ],
    "multiSelect": false
  }]
})
```
