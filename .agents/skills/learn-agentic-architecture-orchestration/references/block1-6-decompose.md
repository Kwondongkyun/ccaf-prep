# Block 1-6: Task Decomposition (Prompt Chaining vs 동적 분해)

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서: https://www.anthropic.com/engineering/building-effective-agents
> 📖 Prompt chaining 패턴: https://docs.claude.com/en/docs/agents-and-tools/agent-loops
> ```

## EXPLAIN

> Task 1.6 — 복잡한 워크플로우를 위한 작업 분해 전략 설계

### 한 줄 정의

**작업 분해는 두 가지 — 고정 순차 (prompt chaining) vs 동적 적응. 워크플로우 성격에 맞게 골라야 한다.**

### 두 패턴 비교

```
[Prompt Chaining — 고정 순차]
  Stage 1 (각 파일 분석) → Stage 2 (cross-file integration) → Stage 3 (최종 리뷰)
  ▲                                                                        ▲
  └────────────── 미리 정의된 파이프라인. 단계 고정 ──────────────────────┘

[Dynamic Decomposition — 적응형]
  탐색 → 발견 → 우선순위 → 발견에 따라 다음 작업 동적 생성
  ▲                                                            ▲
  └─────── 중간 결과가 다음 단계를 결정 ───────────────────────┘
```

### 어느 걸 언제?

| 작업 성격 | 선택 |
|---------|------|
| **예측 가능, 다측면 분석** (예: 코드 리뷰 — 각 파일 → integration) | **Prompt Chaining** |
| **오픈엔드 조사** (예: "레거시 코드베이스에 포괄적 테스트 추가") | **Dynamic Decomposition** |
| **고정된 컴플라이언스 절차** (예: 신원 검증 → 환불 → 알림) | **Prompt Chaining** + Hook 강제 |
| **리서치·탐사** (예: "X 분야 최신 동향") | **Dynamic** |

### 실전 예시 1: 대규모 코드 리뷰 (Prompt Chaining)

```
[Phase 1] 파일별 로컬 분석 패스
  - file_1 → 로컬 이슈 (lint, 함수별 로직)
  - file_2 → 로컬 이슈
  - ...
  - file_N → 로컬 이슈
  ↓
[Phase 2] Cross-file integration 패스
  - 의존성 흐름, 호출 관계, 인터페이스 일관성
  ↓
[Phase 3] 최종 리포트
```

**왜 분리?** 한 번에 다 보면 **attention dilution** — 모델이 큰 그림과 디테일 둘 다 놓침.

### 실전 예시 2: 오픈엔드 코드베이스 작업 (Dynamic)

```
[1] 구조 매핑
    "코드베이스 토폴로지 파악"
    ↓
[2] 발견에 따라 우선순위 식별
    "고임팩트 영역 = 핵심 비즈니스 로직 + 테스트 부재"
    ↓
[3] 의존성 발견 시 적응
    "core/payment.py 수정하려니 5개 의존 파일 발견 → 그쪽 먼저"
    ↓
[4] 우선순위 계획 동적 갱신
```

→ Phase 2 결과가 Phase 3을 정의. 미리 단계 고정 불가.

### Attention Dilution 함정

큰 작업 한 번에 던지면 모델이 **"뭐가 중요한지"** 못 가림.

```
❌ "이 50개 파일 코드베이스의 모든 이슈 + cross-file 의존성 + 보안 + 성능 + 테스트 커버리지 다 봐줘"
   → 모델이 표면적 finding 잔뜩 + 진짜 중요한 거 놓침

✅ Phase 1: 파일별 로컬 패스 (한 번에 한 파일)
   Phase 2: cross-file integration (Phase 1 finding 입력)
   Phase 3: 보안 전용 패스 (별도)
   → 각 Phase가 한 가지에 집중
```

### Dynamic의 시작 — 구조 매핑

오픈엔드 작업은 무조건 **"탐사 먼저, 계획은 나중"**:

```python
# Step 1: 코드베이스 토폴로지
modules = explore_structure()  # 디렉토리, 진입점, 의존성 그래프

# Step 2: 고임팩트 영역 식별
hotspots = identify_high_impact(modules)  # 비즈니스 로직, 테스트 부재 영역

# Step 3: 우선순위 계획 (의존성 기반 동적 갱신)
plan = []
for h in hotspots:
    deps = trace_dependencies(h)
    plan.extend(order_by_dependencies(h, deps))

# Step 4: 발견 추가 시 plan 갱신
```

### Prompt Chaining 작성 원칙

각 단계는 **다음 단계가 사용할 정확한 형식**으로 출력.

```
[Phase 1 출력 형식 명시]
파일별 finding을 다음 JSON 배열로:
[{"file": "...", "issues": [{"line": ..., "type": ..., "severity": ...}]}]

[Phase 2 입력]
Phase 1 출력 + cross-file 분석 지침
```

→ 단계 간 인터페이스 contract가 명확하면 chaining 안정.

### Sample Q 매핑

이 블록은 **Sample Q "코드 생성/리뷰" 시나리오** 답변과 직결.

> "대규모 멀티 파일 코드 리뷰에서 cross-file 이슈를 안정적으로 잡으려면?"
> → **multi-pass**: 파일별 로컬 패스 + 별도 integration 패스. 한 번에 다 보지 말 것 (attention dilution).

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "모든 작업을 한 번에 한 프롬프트로" | Attention dilution. 멀티 패스로 분할 |
| "Dynamic 분해는 무계획" | 구조 매핑 → 우선순위 → 의존성 추적 (단계는 있음) |
| "Prompt chaining은 항상 우월" | 오픈엔드 작업엔 부적합 — 적응 못함 |
| "Dynamic은 항상 우월" | 예측 가능 작업엔 chaining이 안정적 |
| "코드 리뷰는 한 번에 다 봐야 cross-file 잡음" | 반대. 파일별 패스 + integration 패스 분리가 더 정확 |

## EXECUTE

아래 워크플로우 각각에 적합한 분해 방식을 고르고 이유 1줄 적어보세요.

```
W1. "이 PR의 모든 파일에 대해 보안·성능·스타일·테스트 커버리지 리뷰"
W2. "레거시 코드베이스 X에 포괄적 테스트 추가 (현재 커버리지 0%)"
W3. "주문 환불 워크플로우: 신원확인 → 정책체크 → 환불처리 → 영수증발송"
W4. "AI 윤리 분야의 최근 6개월 학계 동향 조사"

→ 각각: Prompt Chaining / Dynamic / 둘다 / 어느 쪽이든 가능
```

추가: W2를 dynamic으로 풀 때 **첫 단계가 무엇이어야** 하는지 1줄. (힌트: 구조 매핑)

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 멀티 파일 PR 리뷰에서 cross-file 의존성 이슈를 자주 놓침. 가장 효과적 개선?",
      "header": "Quiz 1-6-A",
      "options": [
        {"label": "파일별 로컬 패스 + 별도 cross-file integration 패스로 분할 (multi-pass)", "description": "Prompt chaining"},
        {"label": "한 프롬프트에 모든 파일 + cross-file 지시를 한꺼번에 넣기", "description": "Single shot"},
        {"label": "extended thinking 활성화", "description": "Thinking"},
        {"label": "모델을 Opus로 업그레이드", "description": "Model upgrade"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 레거시 코드베이스에 포괄적 테스트 추가 작업. 가장 적절한 분해는?",
      "header": "Quiz 1-6-B",
      "options": [
        {"label": "Dynamic decomposition — 구조 매핑 → 고임팩트 영역 식별 → 의존성 따라 적응", "description": "Adaptive"},
        {"label": "Prompt chaining — 알파벳 순서로 모든 파일에 테스트 작성", "description": "Fixed pipeline"},
        {"label": "한 번에 'covering 테스트 다 짜줘' 요청", "description": "Single shot"},
        {"label": "Random 파일 골라서 테스트 작성", "description": "Random"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. 'Attention dilution'을 가장 잘 설명하는 것은?",
      "header": "Quiz 1-6-C",
      "options": [
        {"label": "한 작업에 너무 많은 측면을 한꺼번에 던지면 모델이 우선순위를 못 가려 표면적 finding만 늘어남", "description": "Cognitive overload"},
        {"label": "API rate limit이 hit되어 응답이 느려지는 현상", "description": "Rate limit"},
        {"label": "Context window가 가득 차서 앞 내용이 잊히는 현상", "description": "Context overflow"},
        {"label": "모델의 attention 메커니즘이 비활성화된 상태", "description": "Tech glitch"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A** — **Multi-pass.** 파일별 로컬 → cross-file integration. Single shot은 attention dilution. Thinking·모델 업그레이드는 근본 해결 아님.
- **Q2: A (Dynamic)** — 오픈엔드 작업의 정석. 구조 매핑부터 시작 → 발견에 따라 적응.
- **Q3: A** — Attention dilution = 한 번에 너무 많은 측면 → 우선순위 손실. 멀티 패스로 해결.

### 출제 변형

- **"환불 워크플로우 (신원→정책→환불→영수증)"** → Prompt chaining + Hook 강제 (Block 1-4 prerequisite). Dynamic 부적합 — 순서 고정 필수.
- **"리서치 + 보고서 (멀티 에이전트)"** → 코디네이터가 동적으로 갭 평가하면서 부분적 chaining (1-2 iterative refinement).
- **"한 번에 다 보면 안 되나?"** → 작은 작업이면 OK. 50파일 코드베이스 같은 규모에선 attention dilution.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 1-7 진행",
    "options": [
      {"label": "다음 (1-7 Session State / Resume / Fork)", "description": "D1 마지막 블록"},
      {"label": "1-6 변형 한 번 더", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
