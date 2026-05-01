# Block 5-4: Large Codebase Exploration & Context Management

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Memory & /compact): https://docs.claude.com/en/docs/claude-code/memory
> 📖 공식 문서 (Subagents): https://docs.claude.com/en/docs/claude-code/sub-agents
> ```

## EXPLAIN

> Task 5.4 — 대규모 코드베이스 탐색 시 verbose 출력·세션 종료를 관리

### 한 줄 정의

**큰 코드베이스 탐색은 verbose grep/ls 결과·다수 파일 read로 컨텍스트를 빠르게 잠식한다. 4가지 메커니즘 — scratchpad(key findings 저장), subagent delegation(verbose 격리), manifest(crash recovery), `/compact`(필요 시 압축) — 을 결합한다.**

### 4가지 메커니즘

```
┌──────────────────┬────────────────────────────────────────────┐
│ Scratchpad        │ 발견을 외부 md 파일에. 컨텍스트에서 raw       │
│                   │ 검색결과는 trim, 핵심만 stash.               │
├──────────────────┼────────────────────────────────────────────┤
│ Subagent          │ Verbose 작업(grep 1000줄, repo 전체 read)을  │
│ delegation        │ 별도 subagent로 격리. 부모는 요약만 받음.     │
├──────────────────┼────────────────────────────────────────────┤
│ Manifest          │ 작업 상태·결정·블로커 영속 저장. Crash 후 복구.│
├──────────────────┼────────────────────────────────────────────┤
│ /compact          │ 자동 압축이 임계 도달 시 진행. 명시적 호출도   │
│                   │ 가능. 핵심은 미리 외부화 후 호출.             │
└──────────────────┴────────────────────────────────────────────┘
```

### Scratchpad 패턴

```markdown
# scratchpad-auth-refactor.md
> last updated: 2026-04-30 14:32

## 발견
- middleware/auth.py:42 — JWT verify에서 시간 비교 비안전
- routes/users.py:108 — token refresh logic 중복
- tests/auth_test.py — coverage 60%

## 가설
- 시간 비교 비안전 → constant-time 비교로 교체

## 다음 단계
1. constant-time 함수로 교체
2. refresh logic 통합
3. 테스트 추가
```

→ Verbose grep/file read 후 5줄 결론만 scratchpad. 다음 turn은 scratchpad 참조.

### Subagent delegation으로 verbose 격리

```
[Bad — 부모 컨텍스트에 grep 결과 1000줄]
부모 agent → grep "useState" repo wide → 1000줄 hit
→ 컨텍스트 잠식, 다음 작업 attention dilution

[Good — subagent 격리]
부모 → Task("grep 'useState' 후 hook 패턴별로 카테고리화하고
            상위 3개 파일과 패턴만 5줄로 요약 반환")
→ subagent가 1000줄 처리, 부모는 요약 5줄만 수령
```

→ "verbose 작업은 subagent에게" — D1 1-3(Subagent context)와 직결.

### Manifest 구조

```markdown
# session-manifest.md
> Last updated: 2026-04-30 14:32

## 현재 작업
- /api/v2/users endpoint 추가
- Subtask: 인증 미들웨어 통합 (in-progress)

## 결정사항
- Stack: Python 3.12 + FastAPI + Pydantic v2
- Auth: JWT (헤더 Bearer)

## 완료
- [x] 데이터 모델 정의
- [x] DB 스키마 마이그레이션

## 진행 중
- [ ] 인증 미들웨어
- [ ] 통합 테스트

## 블로커
- (없음)

## 다음 단계
- POST /users 엔드포인트
- 통합 테스트 추가
```

### /compact

```
[자동]
컨텍스트가 임계치 → Claude Code가 오래된 turn 압축
요약된 부분은 정확도 손실 가능

[명시적]
사용자: /compact
또는 사용자: "지금까지 결정 요약해줘" → 출력을 manifest에 저장 후 /compact

[전략]
1) 핵심 결정·case_facts를 manifest로 외부화 (먼저!)
2) /compact 호출
3) 압축 후 부족하면 manifest 재주입
```

→ /compact는 만능 X. 핵심을 외부화하지 않고 /compact만 하면 손실 가능.

### F-D5-4 함정

> "긴 디버깅 세션 도중 크래시. 다시 처음부터?"

| 잘못된 답 | 올바른 답 |
|---------|---------|
| 처음부터 다시 시작 — 안전 | **Manifest 읽기 → 상태 복원 → 재개**. 처음부터는 시간·비용 낭비 |

### 결정 매트릭스

| 상황 | 대응 |
|-----|-----|
| Repo wide grep/탐색 | **Subagent**로 격리 |
| 발견을 다음 turn으로 보존 | **Scratchpad** md |
| 결정·진행상태 영속 | **Manifest** |
| 컨텍스트 임계 접근 | 핵심 외부화 → **/compact** |
| Crash 복구 | Manifest 읽기 → 재개 |
| 새 작업 전환 (이전 무관) | `/clear` + 새 manifest |
| 세션 간 인수인계 | Manifest + scratchpad 참조 |

### Manifest 갱신 시점

```
[필수 갱신]
  - 중요 결정 (stack, 아키텍처)
  - 작업 milestone 완료
  - 블로커 발생/해소
  - 세션 종료 직전

[선택 갱신]
  - 매 turn (자동화 시)
  - 30분마다
```

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| Repo wide grep을 부모에서 직접 | **Subagent delegation** — 부모는 요약만 |
| /compact만 있으면 충분 | 핵심을 **manifest로 외부화** 후 /compact |
| 발견을 turn에 적어두면 보존 | 50 turn 후 못 찾음. **Scratchpad** 외부 |
| 처음부터 다시 시작이 안전 | 시간·비용 낭비. Manifest로 복구 |
| Manifest는 한 번만 쓰면 됨 | 정기 갱신 필수. Outdated면 잘못된 복원 |
| Raw 로그를 manifest로 | Noise. 결정·상태 요약만 |

### Sample Q / 시나리오 매핑

- 시나리오 6 (Structured Data Extraction) — 큰 데이터 결과 trim + scratchpad 패턴.
- 시나리오 2 (Code Generation) — repo wide 탐색은 subagent delegation.
- D1 1-3(Subagent context passing)·1-7(Session/fork) 와 직결.

## EXECUTE

```
W1. Repo wide "useState" 사용 현황 — 부모에서 직접 grep? 아니면?
W2. 50 turn 디버깅 세션 크래시 — 어떻게?
W3. 컨텍스트가 임계 접근 — 무엇을 먼저 하고 /compact?
W4. 발견 8건을 다음 turn에서도 참조하고 싶다 — 어디?
W5. Manifest를 last week 그대로 — 문제?
```

→ 각 답: 1-2줄

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. Repo wide grep 1000줄. 부모 agent에서 직접 호출 vs subagent 위임?",
      "header": "Quiz 5-4-A",
      "options": [
        {"label": "Subagent로 격리, 부모는 요약 5줄만 수령", "description": "Delegate"},
        {"label": "부모에서 직접 grep — 빠름", "description": "Direct"},
        {"label": "사용자가 grep 후 입력", "description": "Manual"},
        {"label": "/compact 후 다시 grep", "description": "Compact first"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 50 turn 작업 도중 세션 크래시. 가장 효율적 복구?",
      "header": "Quiz 5-4-B",
      "options": [
        {"label": "Manifest 읽기 → 상태·결정 복원 → 다음 단계 재개", "description": "Manifest"},
        {"label": "처음부터 다시 시작", "description": "Restart"},
        {"label": "Raw 로그 그대로 컨텍스트에", "description": "Raw"},
        {"label": "이전 작업 포기", "description": "Forget"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. 컨텍스트 임계 접근 시 가장 안전한 순서?",
      "header": "Quiz 5-4-C",
      "options": [
        {"label": "핵심 결정·findings를 manifest/scratchpad로 외부화 → /compact", "description": "External then compact"},
        {"label": "/compact 먼저 — 외부화 불필요", "description": "Compact first"},
        {"label": "그냥 누적", "description": "Accumulate"},
        {"label": "/clear 즉시", "description": "Clear"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (Delegate)** — Verbose 격리. 부모 컨텍스트 보호.
- **Q2: A (Manifest)** — F-D5-4 정면. 외부 영속 기록으로 빠른 복구.
- **Q3: A (External then compact)** — /compact는 손실 가능. 외부화 후 압축이 안전.

### 출제 변형

- **"Scratchpad vs Manifest 차이?"** → Scratchpad는 working notes(가설·발견), Manifest는 결정·진행상태·블로커.
- **"Subagent 결과 형식?"** → 구조화 + 요약 강제. raw 로그 X.
- **"/clear vs /compact?"** → /clear는 새 작업 전환, /compact는 같은 작업 내 압축.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 5-5 진행",
    "options": [
      {"label": "다음 (5-5 HITL & Confidence)", "description": "stratified sampling, field-level confidence"},
      {"label": "5-4 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
