# D2 문항 풀 — Tool Design & MCP Integration (18%)

> 5 Tasks: 2.1 Tool Description / 2.2 Structured Error / 2.3 Distribution & tool_choice / 2.4 MCP / 2.5 Built-in Tools

---

## D2-Q01
Production logs에서 agent가 order 질문에 `get_customer` 호출. 두 도구 모두 minimal description. 가장 효과적 first step?
- A) 각 도구 description 확장 (입력 형식·예시·boundary·when NOT to use)
- B) Few-shot 5-8개 추가
- C) Routing classifier 구현
- D) `lookup_entity`로 통합
**Answer: A** | F-D2-1 | Sample Q 2.

---

## D2-Q02
좋은 tool description의 5요소?
- A) 무엇을·입력 형식·언제 쓰는지·boundary(NOT)·반환 형태
- B) 이름·인자·반환·예외·로깅
- C) 버전·작성자·날짜·태그·라이선스
- D) 한 줄 요약만
**Answer: A** | Task 2.1.

---

## D2-Q03
도구 실행 실패 시 LLM이 자연스럽게 처리하도록?
- A) `{errorCategory, message, isRetryable, suggestedAction, context}` 구조화 응답
- B) Raw exception 그대로 LLM에
- C) 빈 응답
- D) "잘 처리해" 프롬프트
**Answer: A** | F-D2-2.

---

## D2-Q04
사용자 질문을 항상 분류 도구의 JSON 출력으로 받고 싶다. tool_choice?
- A) {type: "tool", name: "classify_intent"}
- B) {type: "auto"}
- C) {type: "any"}
- D) {type: "none"}
**Answer: A** | F-D2-3 / D4-3 cross.

---

## D2-Q05
코드 분석 subagent가 가끔 파일 수정. 가장 결정적 방어?
- A) `allowed-tools: [Read, Grep, Glob]` — Edit/Write 제외
- B) 프롬프트에 "수정 금지"
- C) 사용자가 매번 검수
- D) Subagent 사용 중단
**Answer: A** | F-D2-3.

---

## D2-Q06
팀 공유 MCP server 등록 위치?
- A) `.mcp.json` (project scope, git 공유)
- B) `~/.claude.json` (user scope)
- C) 시스템 환경변수
- D) CLAUDE.md
**Answer: A** | F-D2-4.

---

## D2-Q07
synthesis agent가 매 verify마다 coordinator 거쳐 latency 40%↑. 85% simple fact-check.
- A) Synthesis에 scoped `verify_fact` 도구 추가, 복잡건은 기존 delegation 유지
- B) Synthesis에 모든 web 도구 부여
- C) Verify를 batch로 묶음
- D) 결과 캐싱
**Answer: A** | F-D2-3 | Sample Q 9.

---

## D2-Q08
"src/components 하위 .tsx 파일 모두 찾기" — 어떤 도구?
- A) Glob (`src/components/**/*.tsx`)
- B) Grep
- C) Bash `find`
- D) Read 반복
**Answer: A** | F-D2-5.

---

## D2-Q09
"useState 함수 사용 위치 모두" — 어떤 도구?
- A) Grep (콘텐츠 검색)
- B) Glob
- C) Bash `cat`
- D) Read 전체
**Answer: A** | F-D2-5.

---

## D2-Q10
파일 일부 편집은 어떤 도구?
- A) Edit (정확한 string replace)
- B) Write (전체 덮어쓰기)
- C) Bash sed
- D) Read 후 손으로
**Answer: A** | Task 2.5.

---

## D2-Q11
도구 description 보강 vs Few-shot — first step 우선순위?
- A) Description 보강 — 1차 메커니즘. Few-shot은 보조
- B) Few-shot — 더 강력
- C) 둘 다 같이
- D) 없음
**Answer: A** | F-D2-1.

---

## D2-Q12
"요약해줘"라고 했을 때 도구 호출 없이 자연어만 받고 싶다. tool_choice?
- A) {type: "none"}
- B) {type: "auto"}
- C) {type: "any"}
- D) tool 정의 자체를 제거
**Answer: A** | F-D2-3.
