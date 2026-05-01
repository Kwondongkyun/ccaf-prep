---
name: learn-tool-design-mcp-integration
description: CCA-F Domain 2 — Tool Design & MCP Integration (18%). 5개 Task Statement (2.1~2.5) — Tool Description & Boundary / Structured Error / Tool Distribution & tool_choice / MCP Server Integration / Built-in Tools. "D2", "tool", "MCP", "tool_choice", "built-in tools" 요청에 사용.
---

# CCA-F D2: Tool Design & MCP Integration (18%)

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

## References 파일 맵 (D2 = 5개 Task Statement)

| 블록 | Task | 모듈 | 파일 |
|------|------|------|------|
| 2-1 | Task 2.1 | Tool Description & Boundary | `references/block2-1-description.md` |
| 2-2 | Task 2.2 | Structured Error Response | `references/block2-2-error.md` |
| 2-3 | Task 2.3 | Tool Distribution & `tool_choice` | `references/block2-3-distribution.md` |
| 2-4 | Task 2.4 | MCP Server Integration (`.mcp.json`) | `references/block2-4-mcp.md` |
| 2-5 | Task 2.5 | Built-in Tools (Read/Write/Edit/Bash/Grep/Glob) | `references/block2-5-builtin.md` |

각 reference 파일은 `## EXPLAIN`, `## EXECUTE`, `## QUIZ` 섹션으로 구성된다.

---

## D2 핵심 함정 패턴 (Phase B 피드백 시 활용)

| # | 함정 | 정답 방향 |
|---|------|----------|
| F-D2-1 | 도구 선택이 헷갈릴 때 few-shot으로 해결 | **Description 확장** — 입력 형식·예시·boundary·언제 다른 도구 대신 쓰는지 |
| F-D2-2 | Tool 에러를 generic exception 으로 반환 | **Structured error** — `{category, isRetryable, message}` 구조 |
| F-D2-3 | 모든 작업에 모든 도구 노출 | **Task별 tool allowlist** + `tool_choice`로 강제 호출 |
| F-D2-4 | 팀 공유 MCP를 `~/.claude.json`에 둠 | **`.mcp.json`은 project scope (팀 공유)**, `~/.claude.json`은 personal |
| F-D2-5 | 코드 검색에 항상 grep | **Glob = 파일 패턴**, **Grep = 콘텐츠 검색**, **Bash = 한 번 실행 명령** — 적재적소 |
| F-D2-6 | 비슷한 두 도구를 합쳐서 `lookup_entity` 단일화 | **Description 보강이 first step** (Sample Q 2) |

---

## 진행 규칙

- 한 번에 한 블록씩 진행
- "다음", "skip", 블록 번호로 이동
- 5개 블록 모두 끝나면 D2 종합 정리 (블록 간 관계 + Sample Q 매핑) 출력

---

## 시작

```json
AskUserQuestion({
  "questions": [{
    "question": "어디서부터 시작할까요?",
    "header": "D2 시작 블록",
    "options": [
      {"label": "2-1 Tool Description", "description": "Description이 도구 선택의 1차 메커니즘 — 자주 출제 (Sample Q 2)"},
      {"label": "2-2 Structured Error", "description": "category/isRetryable 구조"},
      {"label": "2-4 MCP Server", "description": "project vs user scope, .mcp.json"},
      {"label": "처음부터 순서대로", "description": "2-1부터 2-5까지"}
    ],
    "multiSelect": false
  }]
})
```

> 시작 블록 선택 후 → 해당 블록의 Phase A부터 진행.
