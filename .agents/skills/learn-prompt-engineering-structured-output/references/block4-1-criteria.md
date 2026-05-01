# Block 4-1: Explicit Criteria & System Prompt

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (System Prompts): https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/system-prompts
> 📖 공식 문서 (Be Clear & Direct): https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/be-clear-and-direct
> ```

## EXPLAIN

> Task 4.1 — 명시적·측정 가능 기준 (explicit criteria) + 시스템 프롬프트의 정책·정체성 통제

### 한 줄 정의

**"잘 해줘"는 평가 불가. Prompt에는 무엇을·무엇과 비교·어떤 기준 충족 시 통과를 explicit하게 적는다. 시스템 프롬프트 = 정책·제약·정체성 (개발자 통제). CLAUDE.md = 프로젝트 컨벤션 (팀 공유). 정책을 CLAUDE.md에 두면 사용자가 우회 가능.**

### Vague vs Explicit

```
[Bad — vague]
"이 PR 잘 리뷰해줘"
"적절한 응답을 해줘"
"필요하면 escalate"
→ 평가 불가, 일관성 X, "잘"의 정의가 매번 달라짐

[Good — explicit]
"PR을 다음 5가지 기준으로 리뷰:
 1. SQL Injection (parameterized query 사용 여부)
 2. N+1 query (loop 안의 DB call)
 3. Secret leak (API key, password hardcoded)
 4. Test coverage (변경 함수에 테스트 존재)
 5. 에러 핸들링 (외부 호출에 try/except)
 각 항목 통과/실패 + 이유 1줄."
→ 측정 가능, 일관성, 평가 가능
```

### Explicit Criteria의 4요소

```
1. 무엇을 평가? (대상 — PR, 응답, 분류)
2. 무엇과 비교? (기준 — checklist, 정책, 예시)
3. 통과 조건? (모든 항목 / N개 이상 / threshold)
4. 출력 형식? (binary, score, structured)
```

### Sample Q 3 패턴 — 함정 F-D5-2 정면 (D4-1과 직결)

> Customer Support agent가 80% escalation accuracy. 가장 효과적?
> 
> A) **Explicit escalation criteria + few-shot 예시 (정책 갭, 진전 불가, 명시 요청)** ← 정답
> B) Sentiment analysis 추가
> C) 더 큰 모델
> D) Self-confidence threshold

→ Vague한 escalation을 **explicit criteria + few-shot**으로 (D5-2와 D4-1·D4-2의 교차).

### 시스템 프롬프트 vs CLAUDE.md 역할

```
┌──────────────────┬──────────────────────────────────┐
│ 시스템 프롬프트     │ CLAUDE.md                       │
├──────────────────┼──────────────────────────────────┤
│ 정체성·역할        │ 프로젝트 구조·도메인              │
│ 정책·제약          │ 코드 컨벤션                      │
│ 안전 가드          │ 사용 라이브러리·버전              │
│ 출력 형식 강제     │ 테스트·배포 절차                  │
│ Persona 기조      │ "이 코드베이스의 룰"              │
│ → 변경 자주 X      │ → 자주 업데이트                  │
│ → 코드 배포 단위    │ → git 커밋 (팀 공유)             │
└──────────────────┴──────────────────────────────────┘
```

### F-D4-1 함정

> "에이전트가 PII를 누설. 어떻게?"

| 잘못된 답 | 올바른 답 |
|---------|---------|
| CLAUDE.md에 "PII 다루지 마" | **시스템 프롬프트** — 정책·제약은 시스템 |

→ CLAUDE.md는 사용자가 무시·수정 가능 영역. 안전·정책은 시스템 프롬프트.

### 결정 질문

```
이 룰이...
  - 정체성·역할? → 시스템 프롬프트
  - 정책·제약·안전? → 시스템 프롬프트
  - 출력 형식 강제? → 시스템 프롬프트
  - 평가 기준 (explicit criteria)? → 시스템 프롬프트
  - 프로젝트 구조? → CLAUDE.md
  - 코드 컨벤션? → CLAUDE.md
  - 자주 업데이트? → CLAUDE.md
```

### 시스템 프롬프트 작성 — explicit criteria 예

```
당신은 PR 리뷰 에이전트다.

[리뷰 기준 — 모두 평가]
1. SQL Injection: parameterized query인가?
2. N+1 query: loop 안에서 DB 호출 없는가?
3. Secret leak: API key·password가 코드에 있는가?
4. Test: 변경된 public 함수에 테스트가 있는가?
5. Error handling: 외부 호출(HTTP, DB)이 try/except로 감싸져 있는가?

[출력 형식]
{
  "verdict": "approve" | "request_changes",
  "issues": [{"category": str, "file": str, "line": int, "fix": str}],
  "summary": str  // 100자 이내
}

[정책]
- 추측 금지. 코드에서 확인 안되면 "확인 필요"로 표기.
- PII가 포함된 데이터는 응답에 그대로 인용 금지.
```

### CLAUDE.md 작성 — 좋은 예

```markdown
# Project Conventions

## Stack
- Python 3.12 + FastAPI + Pydantic v2
- 테스트: pytest, 커버리지 80% 이상

## DB
- Postgres 16, 마이그레이션은 alembic

## API
- /api/v1/* — REST
- 인증: JWT (헤더 Bearer)
```

→ 시스템 프롬프트와 명확히 다른 영역 (정책·제약 X, 컨벤션 O).

### Explicit Criteria + Few-shot 결합 (D4-2 연계)

```
Criteria만 → 형식·경계는 명시되었지만 모호한 경우 처리 불명확
Few-shot 추가 → 입력 예시 + 기대 출력으로 패턴 학습
→ Sample Q 3 정답: criteria + few-shot 함께
```

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "잘 해줘"로 충분 | **Explicit criteria** — 측정 가능 기준 |
| 정책·페르소나도 CLAUDE.md에 | 정책은 시스템. CLAUDE.md는 우회 가능 |
| 시스템에 stack·라이브러리 명시 | 컨벤션은 CLAUDE.md (자주 변경, 팀 공유) |
| 둘 다 같은 내용 중복 | 영역 분리 — 중복은 drift 위험 |
| "explicit하면 prompt 길어져서 비싸짐" | 일관성·평가 가능성이 cost 압도 |

### Sample Q 매핑

- **Q3** (escalation 80% accuracy) → A. Explicit criteria + few-shot.
- 시나리오 1 (Customer Support) 다수 → vague가 안 됨. Criteria 명시.

## EXECUTE

```
W1. "PR 잘 리뷰해줘" → explicit criteria 5개로 재작성
W2. "PII 누설 금지" — 시스템 vs CLAUDE.md?
W3. "이 프로젝트는 Python 3.12 + FastAPI" — 어디?
W4. "출력은 항상 JSON 스키마 따름" — 어디?
W5. Escalation 80% accuracy. Criteria 3개 + few-shot 2개로 어떻게 명시?
```

→ 각 답: 1-3줄

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. PR 리뷰 정확도가 낮음. 'PR 잘 리뷰해줘'라는 vague한 prompt. 가장 효과적 first step?",
      "header": "Quiz 4-1-A",
      "options": [
        {"label": "Explicit criteria 5개 + 출력 JSON 형식 명시", "description": "Explicit"},
        {"label": "더 큰 모델로 변경", "description": "Bigger model"},
        {"label": "온도 낮추기", "description": "Temperature"},
        {"label": "사용자가 매번 검수", "description": "Manual"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 에이전트가 PII를 코드에 그대로 출력. 가장 효과적?",
      "header": "Quiz 4-1-B",
      "options": [
        {"label": "시스템 프롬프트에 PII 금지 정책", "description": "System prompt"},
        {"label": "CLAUDE.md에 'PII 금지'", "description": "CLAUDE.md"},
        {"label": "사용자가 매번 검수", "description": "Manual"},
        {"label": "Few-shot으로 PII 없는 예시", "description": "Few-shot"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. '이 프로젝트는 Python 3.12 + FastAPI + Pydantic v2' — 어디 적나?",
      "header": "Quiz 4-1-C",
      "options": [
        {"label": "CLAUDE.md (프로젝트 stack — 팀 공유)", "description": "CLAUDE.md"},
        {"label": "시스템 프롬프트", "description": "System prompt"},
        {"label": "유저 ~/.claude.json", "description": "User"},
        {"label": "어디든 OK", "description": "Anywhere"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (Explicit)** — F-D4-1 정면. "잘"은 평가 불가. Criteria 명시가 일관성·정확도의 1차 메커니즘.
- **Q2: A (System prompt)** — 정책·안전은 시스템. CLAUDE.md는 사용자 영역이라 우회 가능.
- **Q3: A (CLAUDE.md)** — Stack은 프로젝트 컨벤션. 자주 업데이트, 팀 공유. 시스템 프롬프트엔 부적합.

### 출제 변형

- **"explicit하면 토큰 비싸짐?"** → 일관성·평가 가능성이 cost 압도. 짧고 모호한 게 더 비싸 (실패 retry).
- **"시스템 프롬프트에 stack?"** → 가능하지만 자주 변경되면 부담. CLAUDE.md가 적절.
- **"CLAUDE.md에 출력 형식?"** → 형식이 안전·정책 수준이면 시스템. 단순 권장이면 CLAUDE.md.
- **"두 곳 충돌?"** → 시스템이 우선. 충돌 자체를 피하기 — 영역 분리.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 4-2 진행",
    "options": [
      {"label": "다음 (4-2 Few-shot Examples)", "description": "ambiguous input + format demo"},
      {"label": "4-1 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
