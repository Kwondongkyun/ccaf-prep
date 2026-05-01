---
name: learn-claude-code-configuration-workflows
description: CCA-F Domain 3 — Claude Code Configuration & Workflows (20%). 6개 Task Statement (3.1~3.6) — CLAUDE.md Hierarchy / Path-specific Rules / Custom Slash Commands / Skills (context fork) / Plan vs Direct / Session Management. "D3", "Claude Code", "CLAUDE.md", "slash command", ".claude/rules", "context fork" 요청에 사용.
---

# CCA-F D3: Claude Code Configuration & Workflows (20%)

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

## References 파일 맵 (D3 = 6개 Task Statement)

| 블록 | Task | 모듈 | 파일 |
|------|------|------|------|
| 3-1 | Task 3.1 | CLAUDE.md Configuration Hierarchy (user/project/directory, `@import`) | `references/block3-1-claude-md.md` |
| 3-2 | Task 3.2 | Path-specific Rules (`.claude/rules/` + glob frontmatter) | `references/block3-2-rules.md` |
| 3-3 | Task 3.3 | Custom Slash Commands (`.claude/commands/`) + `claude -p` | `references/block3-3-commands.md` |
| 3-4 | Task 3.4 | Skills (`context: fork`, `allowed-tools`, `argument-hint`) | `references/block3-4-skills.md` |
| 3-5 | Task 3.5 | Plan Mode vs Direct Execution | `references/block3-5-plan.md` |
| 3-6 | Task 3.6 | Session Management (`/memory`, `/compact`, `--resume`, `fork_session`, Explore subagent) | `references/block3-6-session.md` |

각 reference 파일은 `## EXPLAIN`, `## EXECUTE`, `## QUIZ` 섹션으로 구성된다.

---

## D3 핵심 함정 패턴

| # | 함정 | 정답 방향 |
|---|------|----------|
| F-D3-1 | 새 팀원이 CLAUDE.md 지침을 못 받음 → CLAUDE.md를 더 자세히 작성 | **계층 진단** — 유저 레벨(`~/.claude/CLAUDE.md`)에 있어서 git 공유 안 됨. 프로젝트 레벨로 옮겨야 (Sample Q 4) |
| F-D3-2 | 흩어진 테스트 파일에 컨벤션 적용 → 디렉토리별 CLAUDE.md | **Path-specific rule** — `.claude/rules/` + glob frontmatter (Sample Q 6) |
| F-D3-3 | Verbose skill 출력이 메인 컨텍스트 오염 | **`context: fork`** frontmatter로 격리 |
| F-D3-4 | 단순 변경에도 plan mode | **직접 실행** — Plan mode는 멀티 파일·아키텍처 결정용 (Sample Q 5) |
| F-D3-5 | CI에서 `claude "..."`가 무한 대기 | **`-p / --print` flag** — 비대화형 (Sample Q 10) |
| F-D3-6 | Long session에서 컨텍스트 가득 → 무조건 새 세션 | **`/compact`** 또는 Explore subagent로 verbose 격리 |

---

## 진행 규칙

- 한 번에 한 블록씩 진행
- 6개 블록 완료 시 D3 종합 정리 출력

---

## 시작

```json
AskUserQuestion({
  "questions": [{
    "question": "어디서부터 시작할까요?",
    "header": "D3 시작 블록",
    "options": [
      {"label": "3-1 CLAUDE.md Hierarchy", "description": "계층·@import — 자주 출제 (Sample Q 4)"},
      {"label": "3-2 Path-specific Rules", "description": "`.claude/rules/` + glob (Sample Q 6)"},
      {"label": "3-5 Plan vs Direct", "description": "복잡도 판단 (Sample Q 5)"},
      {"label": "처음부터 순서대로", "description": "3-1부터 3-6까지"}
    ],
    "multiSelect": false
  }]
})
```

> 시작 블록 선택 후 → 해당 블록의 Phase A부터 진행.
