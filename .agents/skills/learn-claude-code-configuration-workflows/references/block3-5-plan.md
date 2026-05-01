# Block 3-4: Plan Mode vs 직접 실행

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서: https://docs.claude.com/en/docs/claude-code/plan-mode
> 📖 Subagents (Explore): https://docs.claude.com/en/docs/claude-code/sub-agents
> ```

## EXPLAIN

> Task 3.4 — Plan mode와 직접 실행 사용 시점 결정

### 한 줄 정의

**Plan mode = 큰 변경·아키텍처 결정·멀티 파일 작업용. 잘 정의된 단순 변경엔 직접 실행. 둘을 섞을 수도 있다.**

### Plan Mode가 필요한 신호

```
[Plan mode]
✓ 다수의 유효한 접근법 존재
✓ 아키텍처 결정 (마이크로서비스 재구조화 등)
✓ 멀티 파일 수정 (45+ 파일 라이브러리 마이그레이션)
✓ 통합 접근법 비교 (다른 인프라 요건)

[직접 실행]
✓ 한 함수에 단일 검증 추가
✓ 명확한 stack trace 가진 단일 파일 버그 수정
✓ 날짜 검증 조건 추가
```

### 결정 매트릭스

| 작업 성격 | 선택 |
|---------|------|
| 단일 파일, 명확한 spec | **직접 실행** |
| 멀티 파일, 의존성 많음 | **Plan mode** |
| "어느 라이브러리로 갈까" | **Plan mode** (탐색·비교) |
| "이 함수 버그 fix" | **직접 실행** |
| "마이크로서비스로 재구조화" | **Plan mode** |
| "테스트 케이스 1개 추가" | **직접 실행** |

### F-D3-4 함정

> "단순 변경에도 plan mode를 항상 써야 안전?"

| 잘못된 답 | 올바른 답 |
|---------|---------|
| 항상 plan mode | **직접 실행** — Plan mode는 멀티 파일·아키텍처 결정용. 단순 변경에 쓰면 비효율 |

### Explore Subagent — Plan과 짝꿍

```
Plan mode에서 verbose 발견 페이즈가 컨텍스트 윈도우 소진 위험 시:

  ┌──────────────────┐
  │  Main agent      │
  │  (plan 작성)      │
  └─────┬────────────┘
        │ 위임
        ↓
  ┌──────────────────┐
  │ Explore subagent │ ← verbose discovery 실행
  │                  │   (ls -R, grep, file 탐색 등)
  └─────┬────────────┘
        │ 요약만 반환
        ↓
  ┌──────────────────┐
  │  Main agent      │ ← 핵심 finding만 받음
  │  (계획 마무리)    │   메인 컨텍스트 보존
  └──────────────────┘
```

**용도:** 멀티 페이즈 작업 중 컨텍스트 윈도우 소진 방지.

### 결합 사용 패턴

```
[1] Plan mode로 조사 + 설계
    예: 라이브러리 마이그레이션 plan 작성
    ↓
[2] Plan 승인 후 직접 실행 모드로 실제 마이그레이션
    예: 코드 수정 실행
```

→ Plan에서 다 끝낼 필요 없음. 설계는 plan, 실행은 직접.

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "단순 변경에도 plan mode가 안전" | 비효율. 직접 실행 |
| "Plan mode 안에서 모든 코드 작성" | Plan은 설계만. 실행은 직접 모드 |
| "Verbose 탐색을 메인 에이전트가 직접" | Explore subagent로 격리 — 컨텍스트 보존 |
| "Plan mode = 무조건 더 신중함" | Spec 명확하면 plan은 오버헤드 |
| "Plan mode와 Explore subagent는 같은 것" | 다름. Plan mode는 설계 단계, Explore는 verbose 발견 격리 |

### Sample Q 매핑

> "라이브러리 마이그레이션 (45개 파일 영향). 어떻게 시작?"
> → Plan mode로 설계 → 직접 실행 모드로 실제 적용. 순수 직접 실행은 위험, 순수 plan만으론 미완료.

> "단일 함수 null 체크 추가."
> → 직접 실행. Plan mode는 오버헤드.

## EXECUTE

다음 작업에 적합한 모드를 고르세요.

```
W1. "이 코드베이스를 모놀리스 → 마이크로서비스로 재구조화"
W2. "calculate_total 함수에 빈 배열 처리 추가"
W3. "axios → fetch로 마이그레이션 (전체 코드베이스 영향)"
W4. "신규 endpoint /api/v2/users 1개 추가"
W5. "메인 페이지 로딩 속도 개선 (원인 불명)"

→ 각각: Plan mode / 직접 실행 / 둘 다 결합
```

추가: W3을 plan만으로 끝낼 수 없는 이유 1줄.

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 45개 파일에 영향 주는 라이브러리 마이그레이션. 가장 적절한 접근?",
      "header": "Quiz 3-4-A",
      "options": [
        {"label": "Plan mode로 설계 → 직접 실행으로 적용", "description": "Plan + Direct"},
        {"label": "직접 실행만 — 한 파일씩 수정", "description": "Direct only"},
        {"label": "Plan mode만 — 모든 코드까지 plan에서 작성", "description": "Plan only"},
        {"label": "사용자가 수동 마이그레이션", "description": "Manual"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 'calculate_total 함수에 null 체크 추가'. 가장 적절한 모드?",
      "header": "Quiz 3-4-B",
      "options": [
        {"label": "직접 실행 — 명확한 단일 파일 변경", "description": "Direct"},
        {"label": "Plan mode — 모든 변경은 plan부터", "description": "Plan always"},
        {"label": "Explore subagent로 먼저 분석", "description": "Explore"},
        {"label": "다른 LLM에 물어보기", "description": "External"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. Plan mode 도중 verbose discovery로 컨텍스트 윈도우 소진 위험. 어떻게?",
      "header": "Quiz 3-4-C",
      "options": [
        {"label": "Explore subagent로 위임 — 격리된 컨텍스트에서 발견 후 요약만 반환", "description": "Explore subagent"},
        {"label": "/clear로 컨텍스트 리셋", "description": "Clear"},
        {"label": "더 큰 모델로 변경", "description": "Bigger model"},
        {"label": "Plan mode 종료 후 직접 실행", "description": "Switch mode"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (Plan + Direct)** — 결합 사용 패턴. Plan만으론 실제 코드 미완료, 직접만으론 큰 그림 없이 위험.
- **Q2: A (직접 실행)** — **F-D3-4 정면.** 단순 명확한 변경은 plan mode 불필요. 오버헤드.
- **Q3: A (Explore subagent)** — Verbose 발견 격리. 메인 컨텍스트 보존.

### 출제 변형

- **"Plan mode에서 코드까지 다 작성?"** → 아니. 설계만, 실행은 직접 모드.
- **"Explore subagent vs context: fork skill?"** → 둘 다 격리. Explore는 plan mode 발견 단계, fork는 skill 격리.
- **"단순 변경인데 plan mode 강제?"** → 비효율. 모드 선택은 작업 성격 기반.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 3-5 진행",
    "options": [
      {"label": "다음 (3-5 Iterative refinement)", "description": "Test-driven, interview, few-shot"},
      {"label": "3-4 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
