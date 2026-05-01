# D3 문항 풀 — Claude Code Configuration & Workflows (20%)

> 6 Tasks: 3.1 CLAUDE.md / 3.2 .claude/rules/ / 3.3 Custom Commands / 3.4 Skills / 3.5 Plan vs Direct / 3.6 Session

---

## D3-Q01
"이 프로젝트는 Python 3.12 + FastAPI + Pydantic v2" — 어디 적나?
- A) CLAUDE.md (프로젝트 컨벤션 — git 공유)
- B) 시스템 프롬프트
- C) `~/.claude.json`
- D) 어디든 OK
**Answer: A** | F-D3-1.

---

## D3-Q02
"PII 누설 금지" — 어디?
- A) 시스템 프롬프트 (정책·안전)
- B) CLAUDE.md
- C) `.claude/rules/`
- D) `.gitignore`
**Answer: A** | F-D3-1.

---

## D3-Q03
모노레포에 흩어진 파일별 컨벤션 (services/payment/** PCI). 어떻게?
- A) `.claude/rules/<rule>.md` + `glob: services/payment/**`
- B) 글로벌 CLAUDE.md에 모든 룰
- C) 시스템 프롬프트에 모든 룰
- D) 사용자가 매번 입력
**Answer: A** | F-D3-2 | Sample Q 6.

---

## D3-Q04
팀 전체가 사용할 custom slash command?
- A) `.claude/commands/<name>.md` (project scope, git)
- B) `~/.claude/commands/<name>.md` (user scope)
- C) `~/.claude.json`
- D) CLAUDE.md inline
**Answer: A** | F-D3-3 | Sample Q 4.

---

## D3-Q05
큰 monolith → microservice 마이그레이션. 시작?
- A) Plan mode로 단계·영향·트레이드오프 합의 후 실행
- B) 직접 코드 작성 시작
- C) Subagent 5개 동시 spawn
- D) CLAUDE.md에 "microservice로 가자"
**Answer: A** | F-D3-4 | Sample Q 5.

---

## D3-Q06
Verbose skill의 토큰·attention을 부모 컨텍스트에서 격리?
- A) Skill frontmatter에 `context: fork`
- B) Skill 사용 중단
- C) 매번 사용자 승인
- D) 토큰 압축
**Answer: A** | F-D3-5.

---

## D3-Q07
Skill에서 도구 사용 권한 제한?
- A) Frontmatter `allowed-tools: [Read, Grep]`
- B) 프롬프트에 "Edit 금지"
- C) Skill 사용 중단
- D) 사용자 매번 승인
**Answer: A** | F-D3-5.

---

## D3-Q08
긴 작업 도중 세션 끊김. 다음 날 재개?
- A) `claude --resume <session-id>` + manifest
- B) 처음부터 다시
- C) 다른 사용자에게 위임
- D) 작업 포기
**Answer: A** | F-D3-6.

---

## D3-Q09
GitHub Actions에서 매 PR 자동 리뷰. CLI 호출?
- A) `claude -p "<prompt>"` (1회 실행)
- B) 인터랙티브 모드 자동화
- C) WebSocket 유지
- D) Background daemon
**Answer: A** | Sample Q 10.

---

## D3-Q10
컨텍스트 임계 접근. 가장 안전한 순서?
- A) 핵심 결정·findings를 manifest로 외부화 → /compact
- B) /compact 먼저
- C) 그냥 누적
- D) /clear 즉시
**Answer: A** | F-D3-6.

---

## D3-Q11
정체성·페르소나는 어디?
- A) 시스템 프롬프트
- B) CLAUDE.md
- C) `.claude/rules/`
- D) 없어도 됨
**Answer: A** | F-D3-1.

---

## D3-Q12
같은 세션에서 코드 생성 + 같은 코드 리뷰. 위험?
- A) Self-bias — 독립 인스턴스로 리뷰
- B) 토큰 절감으로 OK
- C) 빠르므로 OK
- D) 위험 없음
**Answer: A** | Task 3.5/3.6.

---

## D3-Q13
새 작업 전환 (이전 디버깅 무관)?
- A) `/clear` + 새 manifest
- B) 누적
- C) `/compact`
- D) 새 세션 — 모든 정보 재입력
**Answer: A** | F-D3-6.
