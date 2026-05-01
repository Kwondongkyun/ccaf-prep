# D1 문항 풀 — Agentic Architecture & Orchestration (27%)

> 7 Tasks: 1.1 Agentic Loop / 1.2 Coordinator-Subagent / 1.3 Subagent Context / 1.4 Enforcement / 1.5 Hooks / 1.6 Decomposition / 1.7 Session

---

## D1-Q01
환불 한도 $500. 가끔 한도 초과 시도. 가장 결정적 차단?
- A) Programmatic prerequisite check (도구 실행 전 코드 검증)
- B) 시스템 프롬프트에 "$500 초과 금지" 강조
- C) Few-shot $499 환불 예시 5개
- D) 사용자가 매번 검수
**Answer: A** | F-D1-1 | Sample Q 1. 정책은 코드.

---

## D1-Q02
Agentic loop 종료 판단의 1차 메커니즘?
- A) `stop_reason` (tool_use → end_turn)
- B) 임의 반복 한도 (max_iterations)
- C) Verbose 자연어 신호
- D) 사용자가 매번 종료
**Answer: A** | F-D1-2.

---

## D1-Q03
Subagent에게 부모 결정·context를 전달하는 방법?
- A) Task 도구 호출 시 프롬프트에 명시 전달
- B) 자동 상속 — 별도 작업 불필요
- C) 환경변수에 저장
- D) 글로벌 메모리 동기화
**Answer: A** | F-D1-3.

---

## D1-Q04
Multi-agent 아키텍처에서 subagent끼리 직접 통신?
- A) Hub-and-spoke — coordinator 중앙, subagent 격리
- B) 모든 subagent 직접 mesh 통신
- C) Subagent가 부모 컨텍스트 자동 read
- D) Pub/sub 시스템
**Answer: A** | F-D1-4.

---

## D1-Q05
Coordinator가 "창의 산업 AI 영향" 질문에 시각예술만 분해. Synthesis도 좁아짐. 가장 효과적?
- A) Decomposition을 시각/음악/문학/영화로 충분히 + coverage gap 체크
- B) Synthesis 결과 더 길게 요약
- C) Synthesis에서 누락 분야 stub
- D) 같은 질문 다시
**Answer: A** | F-D1-5 | Sample Q 7.

---

## D1-Q06
도구 실행 후 결정성 강화 메커니즘?
- A) Hook (PostToolUse) intercept
- B) 프롬프트로 행동 강제
- C) 사용자 매번 검수
- D) 더 큰 모델
**Answer: A** | F-D1-6.

---

## D1-Q07
Verbose skill을 부모 컨텍스트에 그대로 노출?
- A) `context: fork` 또는 별 session으로 격리
- B) 그대로 노출 — 부모가 알아야
- C) Skill 사용 중단
- D) Skill 결과만 빈 string
**Answer: A** | F-D1-7.

---

## D1-Q08
Task decomposition 전략 두 가지?
- A) Prompt chaining (정적) vs 동적 분해 (orchestrator-worker)
- B) Sequential vs random
- C) JSON vs YAML
- D) Sync vs async only
**Answer: A** | Task 1.6.

---

## D1-Q09
50 turn 작업 도중 세션 크래시. 가장 효율적?
- A) Manifest 읽기 → 상태·결정 복원 → 재개
- B) 처음부터 다시
- C) Raw 로그 그대로
- D) 작업 포기
**Answer: A** | Task 1.7.

---

## D1-Q10
Coordinator에 모든 도구를 노출?
- A) Caller별 80% 사용 패턴에 맞춰 scoped tool
- B) 모든 도구 default 노출
- C) 도구 0개 — 자연어만
- D) Subagent마다 동일 도구
**Answer: A** | F-D2-3 cross domain.

---

## D1-Q11
Subagent가 internal docs search timeout. Coordinator에 어떻게 전달?
- A) Structured error context (failure_type, attempted, partial, alternatives)
- B) "search unavailable" 한 줄
- C) Silent fallback
- D) 빈 결과
**Answer: A** | F-D5-3 cross domain | Sample Q 8.

---

## D1-Q12
도구 호출 후 LLM 응답에서 다음 행동 결정?
- A) `stop_reason=tool_use` → 도구 실행 → 결과 message → 다시 호출
- B) 한 번 호출 후 자동 종료
- C) `stop_reason=end_turn`이면 도구 실행 후 다시
- D) 항상 무한 호출
**Answer: A** | Task 1.1.

---

## D1-Q13
Programmatic prerequisite vs 프롬프트 강조 — 어느 것이 결정적?
- A) Programmatic — 코드 검증은 결정적
- B) 프롬프트 — LLM이 더 잘 이해
- C) 둘 다 같음
- D) 프롬프트 + 사용자 매번 검수
**Answer: A** | F-D1-1.

---

## D1-Q14
Hub-and-spoke의 핵심 이점?
- A) Subagent 격리 + 병렬 + 결과 coordinator 수렴
- B) 통신 비용 절감
- C) 사용자 친화 UI
- D) 토큰 절감
**Answer: A** | Task 1.2.

---

## D1-Q15
Hooks (PreToolUse / PostToolUse)의 활용?
- A) 도구 호출 전후 결정성 강화 (검증·인터셉션)
- B) 프롬프트 자동 생성
- C) 사용자 알림만
- D) 토큰 카운팅
**Answer: A** | Task 1.5.
