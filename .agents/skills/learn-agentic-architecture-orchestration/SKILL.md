---
name: learn-agentic-architecture-orchestration
description: CCA-F Domain 1 — Agentic Architecture & Orchestration (27%). 7개 Task Statement (1.1~1.7) — Agentic Loop / Coordinator-Subagent / Subagent Spawn & Context / Enforcement·Handoff / Hooks / Task Decomposition / Session State. "D1", "에이전틱", "agentic", "orchestration" 요청에 사용.
---

# CCA-F D1: Agentic Architecture & Orchestration (27%)

이 스킬이 호출되면 아래 **STOP PROTOCOL**을 반드시 따른다.

---

## STOP PROTOCOL — 절대 위반 금지

### 각 블록은 반드시 2턴에 걸쳐 진행한다

```
┌─ Phase A (첫 번째 턴) ──────────────────────────────┐
│ 1. references/ 의 EXPLAIN 섹션을 읽는다                 │
│ 2. 개념을 설명한다 (다이어그램·비유 포함)                  │
│ 3. EXECUTE 섹션을 읽고 "직접 해보세요"를 안내한다           │
│ 4. ⛔ STOP. 턴 종료.                                    │
│                                                       │
│ ❌ Phase A에서 AskUserQuestion 호출 금지                 │
│ ❌ Phase A에서 QUIZ 섹션 읽기 금지                       │
└──────────────────────────────────────────────────────┘

  ⬇️ 사용자가 "완료", "다음", "ok" 입력

┌─ Phase B (두 번째 턴) ──────────────────────────────┐
│ 1. QUIZ 섹션을 읽는다                                   │
│ 2. AskUserQuestion으로 자가 점검 퀴즈 출제                │
│ 3. 정답/오답 피드백 + 함정 패턴 강조                      │
│ 4. 다음 블록 이동 여부를 AskUserQuestion으로 묻는다        │
└──────────────────────────────────────────────────────┘
```

### 핵심 금지 사항

1. Phase A에서 AskUserQuestion 호출 금지
2. Phase A에서 QUIZ 섹션 읽기 금지
3. 한 턴에 EXPLAIN + QUIZ 동시 진행 금지
4. 압축 금지 — 사용자는 "완벽하게" 준비 중

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

## References 파일 맵 (D1 = 7개 Task)

| 블록 | Task | 모듈 | 파일 |
|------|------|------|------|
| 1-1 | Task 1.1 | Agentic Loop 라이프사이클 | `references/block1-1-loop.md` |
| 1-2 | Task 1.2 | Coordinator-Subagent (Hub-and-spoke) | `references/block1-2-coordinator.md` |
| 1-3 | Task 1.3 | Subagent Spawn & Context Passing | `references/block1-3-subagent.md` |
| 1-4 | Task 1.4 | Enforcement·Handoff (Programmatic Prerequisite) | `references/block1-4-enforce.md` |
| 1-5 | Task 1.5 | Agent SDK Hooks (PostToolUse, 인터셉션) | `references/block1-5-hooks.md` |
| 1-6 | Task 1.6 | Task Decomposition (Prompt Chaining vs 동적) | `references/block1-6-decompose.md` |
| 1-7 | Task 1.7 | Session State / Resume / Fork | `references/block1-7-session.md` |

각 reference 파일은 `## EXPLAIN`, `## EXECUTE`, `## QUIZ` 섹션으로 구성된다.

---

## D1 핵심 함정 패턴 (Phase B 피드백 시 활용)

| # | 함정 | 정답 방향 |
|---|------|----------|
| F1 | "프롬프트로 강제하자" | **Programmatic 우선** — hook / prerequisite로 결정론적 보장 |
| F2 | Few-shot 예시 늘려서 도구 선택 개선 | **Description 확장** 우선 |
| F3 | Subagent가 부모 컨텍스트 자동 상속 | **명시적 전달** — Task 도구 호출 시 프롬프트에 직접 포함 |
| F4 | Verbose 자연어 신호로 루프 종료 판단 | `stop_reason` (`tool_use` / `end_turn`)으로 판단 |
| F5 | 임의 반복 한도를 주된 정지 메커니즘으로 사용 | 보조 가드일 뿐. 주는 stop_reason |
| F6 | Sentiment·자기 보고 신뢰도로 에스컬레이션 결정 | 정책 갭·고객 명시 요청·진전 불가가 트리거 (D5와 연계) |

---

## 진행 규칙

- 한 번에 한 블록씩 진행
- "다음", "skip", 블록 번호로 이동
- "다 끝내달라" 요청에도 STOP PROTOCOL 유지 — 한 턴에 하나
- 7개 블록 모두 끝나면 D1 종합 정리 (블록 간 관계도 + Sample Q 매핑) 출력

---

## 시작

```json
AskUserQuestion({
  "questions": [{
    "question": "어디서부터 시작할까요?",
    "header": "D1 시작 블록",
    "options": [
      {"label": "1-1 Agentic Loop", "description": "기본기. 첫 시작 권장"},
      {"label": "1-2 Coordinator-Subagent", "description": "멀티 에이전트 hub-and-spoke"},
      {"label": "1-4 Enforcement·Handoff", "description": "Programmatic prerequisite — 시험 자주 출제"},
      {"label": "처음부터 순서대로", "description": "1-1부터 1-7까지 차례로"}
    ],
    "multiSelect": false
  }]
})
```

> 시작 블록 선택 후 → 해당 블록의 Phase A부터 진행.
