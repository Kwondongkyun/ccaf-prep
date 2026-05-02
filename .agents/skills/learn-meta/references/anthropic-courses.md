# Anthropic 공식 코스 ↔ CCA-F 도메인 매핑

> 본 레포는 CCA-F 출제 패턴의 **압축본**, Anthropic Academy(anthropic.skilljar.com) 공식 강의는 **원본**.
> 시험 준비 우선순위: 본 레포로 빠르게 출제 패턴·정답 키워드 흡수 → 약한 도메인은 아래 매핑된 공식 코스로 깊이 보충 → `/learn-quiz` 로 점검.
> 모든 코스 무료 · 수료증 발급 · 조사일 2026-05-01.

---

## D1 — Agentic Architecture & Orchestration (27%)

| 공식 코스 | 직접 매핑 Task | 보강 깊이 |
|---|---|---|
| **Building with the Claude API** → *Agents and workflows* (8 lessons) | 1.1 Agentic Loop / 1.6 Decomposition | Parallelization · Chaining · Routing 워크플로 패턴 |
| **Introduction to subagents** (4 lessons) | 1.2 Coordinator-Subagent / 1.3 Spawn & Context | 별도 컨텍스트 윈도우 · 구조화 출력 · 안티패턴 |
| **Building with the Claude API** → *Tool use* (13 lessons) | 1.5 Hooks (간접) | Multi-turn tool 흐름 |

→ 약점 도메인이 D1 이라면 **subagents 코스 우선 → API 코스의 Agents/workflows** 순.

---

## D2 — Tool Design & MCP Integration (18%)

| 공식 코스 | 직접 매핑 Task | 보강 깊이 |
|---|---|---|
| **Building with the Claude API** → *Tool use* (13 lessons) | 2.1 Description / 2.3 tool_choice | 도구 schema · 다중 도구 · 세분화 호출 |
| **Introduction to Model Context Protocol** (14 lessons) | 2.4 MCP Server | tools/resources/prompts 3 프리미티브 직접 구현 |
| **Model Context Protocol: Advanced Topics** (15 lessons) | 2.4 MCP (deep) | Sampling · notifications · roots · transports |
| **Building with the Claude API** → *MCP* (12 lessons) | 2.4 MCP | API 관점에서 본 MCP |

→ MCP 약하다면 **Intro to MCP → Advanced Topics** 순서가 가장 직선적.

---

## D3 — Claude Code Configuration & Workflows (20%)

| 공식 코스 | 직접 매핑 Task | 보강 깊이 |
|---|---|---|
| **Claude Code 101** (12 lessons, 1.5h) | 3.1 CLAUDE.md / 3.6 Session (`/compact`, `/clear`, `/context`) | Claude Code 입문, agentic loop 다이어그램 |
| **Claude Code in Action** (21 lessons) | 3.2 rules / 3.3 commands / 3.4 Skills / 3.5 Plan | 컨텍스트 제어 · 커스텀 명령 · MCP 통합 · GitHub 통합 · Hooks · SDK |
| **Introduction to agent skills** (6 lessons) | 3.4 Skills | Skill 작성·구성·다중 파일·팀 공유·트러블슈팅 |

→ D3 는 본 레포 + **Claude Code in Action** 만으로도 강하게 커버됨. Skills 디테일은 **agent skills** 코스 추가.

---

## D4 — Prompt Engineering & Structured Output (20%)

| 공식 코스 | 직접 매핑 Task | 보강 깊이 |
|---|---|---|
| **Building with the Claude API** → *Prompt engineering* (8 lessons) | 4.1 Criteria / 4.2 Few-shot | XML 태그 · 명확성 · 예시 제공 |
| **Building with the Claude API** → *Prompt evaluation* (8 lessons) | 4.4 Validation / 4.6 Multi-pass | Eval workflow · model/code-based grading |
| **Building with the Claude API** → *Structured data* | 4.3 JSON Schema via tool_use | API 차원에서의 구조화 출력 |
| **AI Fluency: Framework & Foundations** (20 lessons, 1.1h) | 4.1 Criteria (간접) | 4D Framework — Description (명확한 프롬프팅) |

→ D4 는 **API 코스의 Prompt engineering + Prompt evaluation** 두 섹션이 핵심.

---

## D5 — Context Management & Reliability (15%)

| 공식 코스 | 직접 매핑 Task | 보강 깊이 |
|---|---|---|
| **Claude Code 101** | 5.1 Conversation (CLAUDE.md, `/compact`, `/clear`) | 컨텍스트 압축 명령 |
| **AI Capabilities and Limitations** → *Working Memory* (2 lessons) | 5.1 Conversation | 컨텍스트 윈도우 = 작업 기억 멘탈 모델 |
| **Introduction to subagents** → *Designing effective subagents* | 5.3 Error Propagation | 구조화 출력 포맷 · 장애 보고 · 신뢰성 패턴 |
| **AI Fluency: Framework & Foundations** | 5.5 HITL & Confidence | 4D Framework — Diligence (책임감 있는 위임) |

→ D5 는 본 레포가 가장 강하게 정리한 영역. 공식 코스는 멘탈 모델 보강 용도.

---

## 학습 경로 (시험 합격 우선)

```
[Phase 1 — 본 레포로 출제 패턴 흡수]
/learn-meta                                          (함정 31 · Sample Q 12 · 시나리오 6)
  → 약점 도메인 식별

[Phase 2 — 약점 도메인 공식 코스 보충]
   D1 약함 → Introduction to subagents → API 코스 Agents/workflows
   D2 약함 → Intro to MCP → MCP Advanced Topics
   D3 약함 → Claude Code in Action → Intro to agent skills
   D4 약함 → API 코스 Prompt engineering + Prompt evaluation
   D5 약함 → Claude Code 101 (컨텍스트 명령) + subagents 코스

[Phase 3 — 본 레포로 점검]
/learn-quiz                                          (Half30 → Full60)
  → 80% 미만 도메인은 다시 Phase 2 로
```

---

## 시험과 무관하지만 추천 (참고용)

- **Claude 101** (14 lessons) — 비개발자 입문, 시험 출제 X
- **Introduction to Claude Cowork** (14 lessons) — 시험 출제 X
- **AI Fluency for educators / students / nonprofits / Teaching AI Fluency** — 4D Framework 응용, 시험 출제 X
- **Claude with Amazon Bedrock** (76 lessons) — Building with the Claude API 와 90% 동일 + Bedrock 인증
- **Claude with Google Cloud's Vertex AI** (87 lessons) — 위 + Agents and workflows 11 레슨 추가

→ 클라우드 환경 사용자는 **Building with the Claude API** 대신 Bedrock/Vertex AI 코스를 메인 경로로 삼아도 시험 커버리지는 동일.

---

## 분량 비교 (참고)

| 코스 | 레슨 수 | 형식 |
|---|---|---|
| Vertex AI | 87 | 영상+퀴즈 |
| Building with the Claude API | 85 | 영상+퀴즈 |
| Bedrock | 76 | 영상+퀴즈 |
| Claude Code in Action | 21 | 영상 중심 |
| MCP Advanced | 15 | 영상+퀴즈 |
| Claude 101 / MCP / Cowork | 14 each | 텍스트/영상 |
| AI Capabilities and Limitations | 13 | 영상+퀴즈 |
| Claude Code 101 | 12 | 영상+퀴즈 |
| AI Fluency 시리즈 | 4~9 each | 영상+퀴즈 |

→ 시험 합격 최단 경로: **본 레포 + Claude Code in Action + Intro to MCP + API 코스의 Prompt/Tool/Agents 섹션**.
