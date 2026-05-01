# Claude Certified Architect — Foundations (CCA-F) 학습 패키지

> Claude Code Skill 기반 CCA-F 자가 학습 커리큘럼.
> **공식 Anthropic Exam Guide PDF (Version 0.1, 2025-02-10)** 의 5개 도메인 · 30개 Task Statement · 12개 Sample Question 을 그대로 1:1 매핑.

---

## 학습 방식

**문서 정독이 아니라, Claude Code 슬래시 커맨드가 강사 역할을 한다.**
`/learn-agentic-architecture-orchestration` 입력 → 한 블록씩 개념 설명 → 잠시 STOP → 직접 정리 → 객관식 자가 점검 → 다음 블록.

### 한 블록 = 2턴

> **Phase A (첫 턴)**
> 공식 문서 URL · 개념 설명 · 실습 안내 · STOP

사용자가 "완료" / "다음" 입력

> **Phase B (둘째 턴)**
> 객관식 자가 점검 퀴즈 · 정답·함정 매핑 · 다음 블록 확인

도메인 5개(D1~D5) × 30 Task = 30 블록 + 메타 4파일 + 모의고사 64문항까지 동일한 흐름.

---

## 설치

### 한 줄 설치 (권장)

```bash
npx skills add Kwondongkyun/ccaf-prep --agent claude-code --yes
```

특정 스킬만 설치:

```bash
npx skills add Kwondongkyun/ccaf-prep --skill learn-meta --agent claude-code --yes
```

### git clone 방식

```bash
git clone https://github.com/Kwondongkyun/ccaf-prep.git
cd ccaf-prep
./install.sh
```

`install.sh` 가 7개 스킬을 `~/.claude/skills/` 에 심볼릭 링크로 등록한다.
업데이트는 `git pull` 한 번이면 끝 (링크가 원본을 가리키므로 재설치 불필요).

제거: `./uninstall.sh`

> **이전 버전 사용자**: 옛 슬래시명 (`learn-agentic-architecture`, `learn-context-engineering`, `learn-claude-code`, `learn-agent-sdk`, `learn-production-deployment`) 5개를 `~/.claude/skills/` 에서 삭제 후 재설치.

### 수동 설치

심볼릭 링크 사용이 어렵다면:

```bash
cp -r .agents/skills/learn-* ~/.claude/skills/
```

---

## 시험 정보 (공식 PDF 기준)

```
이름      : Claude Certified Architect — Foundations (CCA-F)
문항      : 60문항 객관식 (시나리오 6개 중 4개 랜덤 출제)
시간      : 120분
합격선    : 720 / 1000
재응시    : 6개월 락
```

---

## 도메인 구성 (공식 5도메인 · 30 Task)

| Domain | 비중 | Tasks | 슬래시 커맨드 |
|---|---|---|---|
| **D1** Agentic Architecture & Orchestration | **27%** | 1.1 ~ 1.7 (7) | `/learn-agentic-architecture-orchestration` |
| **D2** Tool Design & MCP Integration | **18%** | 2.1 ~ 2.5 (5) | `/learn-tool-design-mcp-integration` |
| **D3** Claude Code Configuration & Workflows | **20%** | 3.1 ~ 3.6 (6) | `/learn-claude-code-configuration-workflows` |
| **D4** Prompt Engineering & Structured Output | **20%** | 4.1 ~ 4.6 (6) | `/learn-prompt-engineering-structured-output` |
| **D5** Context Management & Reliability | **15%** | 5.1 ~ 5.6 (6) | `/learn-context-management-reliability` |

**보조 스킬**

| 스킬 | 슬래시 | 내용 |
|---|---|---|
| 메타 | `/learn-meta` | 31 함정 · 6 시나리오 · 12 Sample Q 풀이 · 시험 전략 |
| 모의고사 | `/learn-quiz` | 4 모드 (Quick5 / Mini15 / Half30 / Full60), 64문항 풀 |

---

## 권장 학습 순서

```
/learn-meta
   → 함정 31개 · 시나리오 6 · Sample Q 12 · 전략 (먼저 권장)

/learn-agentic-architecture-orchestration   (D1, 27%)
   → 비중 1위. 코디네이터/서브에이전트/훅/세션 7 Task

/learn-claude-code-configuration-workflows  (D3, 20%)
   → CLAUDE.md / .claude/rules/ / commands / skills / plan vs direct

/learn-prompt-engineering-structured-output (D4, 20%)
   → Explicit criteria / few-shot / tool_use JSON / batches / multi-pass

/learn-tool-design-mcp-integration          (D2, 18%)
   → Tool description / structured error / tool_choice / MCP / built-in

/learn-context-management-reliability       (D5, 15%)
   → Conversation / escalation / error propagation / HITL / provenance

/learn-quiz
   → Half30 → Full60 순으로 응시. 80% 미만 도메인은 해당 스킬로 복습
```

---

## 학습 자료 출처

- **Anthropic 공식 Exam Guide** (Claude Certified Architect — Foundations, Version 0.1, 2025-02-10)
  → 도메인 비중 · Task Statement 30개 · Sample Question 12개 정답 정의
- **The Architect's Playbook** — 안티패턴 · Reference Matrix · production 디자인 보강 자료

> 위 자료의 원문은 본 레포에 포함되지 않으며, 별도 확보가 필요하다.

---

## 라이선스 / 면책

- 학습 자료는 비공식 (Anthropic 공식 PDF 원문은 포함되지 않음)
- Anthropic 공식 자료는 별도 배포 — 본 레포는 학습 가이드/프레임워크만 제공
- 시험 응시는 Anthropic 공식 채널 통해 진행
