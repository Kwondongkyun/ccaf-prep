# Block 1-7: Session State / Resume / Fork

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서: https://docs.claude.com/en/docs/claude-code/session-management
> 📖 fork_session: https://docs.claude.com/en/api/agent-sdk/sessions
> ```

## EXPLAIN

> Task 1.7 — 세션 상태, 재개, 포킹 관리 (D1 마지막 블록)

### 한 줄 정의

**세션은 named로 저장하고, `--resume <name>`으로 재개, `fork_session`으로 분기. 단, "이전 컨텍스트가 stale하면 재개 대신 새 세션 + 요약 주입"이 더 안전.**

### 핵심 4가지

**1. Named Session Resume — `--resume <session-name>`**

```bash
# 어제 작업 이어서
claude --resume "refund-investigation"
```

→ 명명된 investigation 세션을 작업 간 이어가기. 이전 대화·도구 결과 그대로 복원.

**2. Fork — 공유 베이스라인에서 분기**

```
        세션 A (공유 베이스라인)
         │
    ┌────┴────┐  fork_session
    ↓         ↓
  Fork-1     Fork-2
  (전략 X)   (전략 Y)
  독립 진행   독립 진행
```

→ **분기된 접근법 비교**에 사용. 예: 두 가지 리팩터링 전략, 두 테스트 프레임워크 시도.

**3. 코드 변경 후 Resume → 변경 알림 필수**

이전에 분석한 파일이 그동안 바뀌었다면? 에이전트는 **stale 컨텍스트**로 추론.

```
[어제] 에이전트가 payment.py 분석 → "이 함수는 X 동작"
[밤사이] 동료가 payment.py 리팩터링
[오늘] resume → 에이전트는 어제 분석 기준 답변 → 잘못된 결론
```

→ Resume 시 **변경된 파일을 명시적으로 알려주기**. 전체 재탐색 대신 타겟팅.

**4. Resume vs 새 세션 + 요약 주입**

| 상황 | 선택 |
|------|------|
| 이전 컨텍스트가 대체로 유효 | **Resume** |
| 이전 도구 결과가 stale (코드/데이터 크게 변동) | **새 세션 + 구조화 요약 주입** |

**왜?** Stale 도구 결과가 컨텍스트에 남아 있으면 모델이 그걸 기준으로 추론 — 신뢰성 ↓.

### 새 세션 + 요약 주입 패턴

```python
# 어제 세션의 핵심 finding을 요약 추출
summary = {
    "investigation_topic": "환불 처리 버그 추적",
    "key_findings": [
        "process_refund가 customer_id 검증 없이 호출됨",
        "policy_check가 일부 경로에서 skip됨",
    ],
    "verified_files": ["payment.py:45-89", "policy.py:120-145"],
    "open_questions": ["로깅 부재 — 어디서 검증이 빠졌는지"],
    "context_freshness_warning": "payment.py는 2025-01-20 이후 수정됨 — 재검증 필요",
}

# 새 세션 시작 + 위 요약을 system prompt 또는 첫 메시지에 주입
new_session = start(initial_context=summary)
```

### Fork 사용 시나리오

```
시나리오: "이 코드베이스를 어떻게 리팩터링할까"
공유 베이스라인 세션:
  - 코드 구조 파악
  - 의존성 그래프 작성
  - 핫스팟 식별

여기서 Fork:
  Fork-1: "Hexagonal architecture로 재구성"
  Fork-2: "Module 분리 + 점진적 마이그레이션"

각 Fork에서 독립적으로:
  - 마이그레이션 plan
  - 예상 리스크
  - 영향 범위

→ 두 결과를 비교해 더 나은 전략 선택
```

### Crash Recovery via Manifest (D5 Task 5.4와 연계)

장기 실행 워크플로우에서 crash 복구 핵심 패턴:

```python
# 각 에이전트가 알려진 위치로 상태 export
agent_a.export_state("./state/agent_a_2025-04-29T15:00.json")
agent_b.export_state("./state/agent_b_2025-04-29T15:00.json")

# 코디네이터가 manifest 작성
manifest = {
    "session_id": "research-2025-04",
    "agents": {
        "web_search": {"state_path": "./state/agent_a_...", "last_step": 12},
        "doc_analysis": {"state_path": "./state/agent_b_...", "last_step": 8},
    },
    "shared_findings": "./findings.json",
    "crashed_at": "2025-04-29T15:42:00",
}
manifest.save("./session/manifest.json")
```

```python
# 재개 시
manifest = load("./session/manifest.json")
for agent_name, info in manifest["agents"].items():
    agent = restore(info["state_path"])
    coordinator.attach(agent)
# → 손실 없이 재개
```

→ **에이전트 상태를 export 가능한 구조**로 두고 manifest로 묶는 것이 핵심. (D5에서 더 깊이)

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "Resume이 항상 새 세션보다 좋음" | Stale 컨텍스트면 새 세션 + 요약이 더 신뢰성 |
| "Resume 후 코드 변경 알릴 필요 없음" | 변경된 파일 명시 — 전체 재탐색 대신 타겟팅 |
| "Fork는 단순 복사" | 공유 베이스라인 위에서 독립 분기 — 비교 목적 |
| "Crash 발생하면 처음부터 다시" | Manifest 기반 export/restore로 손실 최소화 |
| "세션은 자동 명명" | `--resume <name>`으로 named 관리 권장 |

### Sample Q 매핑

이 블록은 **Code Generation with Claude Code 시나리오**의 "긴 investigation 세션 관리"와 연결.

> "코드 리팩터링 도중 crash 발생. 어떻게 복구?"
> → Manifest 기반 export/restore. 단순 resume은 stale 위험.

## EXECUTE

다음 시나리오에 적절한 선택을 하세요.

```
S1. 어제 코드베이스 X 분석 세션 종료. 오늘 X에 변경 없음. 이어서 분석.
S2. 어제 분석 후 동료가 X의 핵심 모듈 3개 리팩터링. 오늘 이어서.
S3. "Hexagonal vs Modular monolith" 두 전략을 같은 코드베이스에서 비교.
S4. 4시간 멀티 에이전트 리서치 도중 코디네이터 프로세스 crash.

→ 각각: Resume / 새 세션+요약 / Fork / Manifest 복구
```

추가: S2에서 단순 resume하면 어떤 안티패턴이 발생하는지 1줄.

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 어제 분석 세션 후 동료가 핵심 파일을 리팩터링. 오늘 분석 이어가려면?",
      "header": "Quiz 1-7-A",
      "options": [
        {"label": "단순 --resume — 이전 컨텍스트 그대로 복원", "description": "Resume only"},
        {"label": "Resume 후 변경 파일 알리거나, 새 세션 + 구조화 요약 주입", "description": "Aware reload"},
        {"label": "처음부터 모든 파일 재분석", "description": "Full restart"},
        {"label": "에이전트가 알아서 변경 감지", "description": "Auto detect"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 같은 코드베이스에서 두 가지 리팩터링 전략을 독립적으로 탐색하려면?",
      "header": "Quiz 1-7-B",
      "options": [
        {"label": "fork_session으로 공유 베이스라인에서 두 분기 생성", "description": "Fork"},
        {"label": "두 세션을 처음부터 따로 시작", "description": "Independent start"},
        {"label": "한 세션에서 두 전략을 번갈아 적용", "description": "Mixed"},
        {"label": "복사-붙여넣기로 세션 디렉토리 복제", "description": "Copy"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. 4시간 멀티 에이전트 리서치 중 crash. 손실 최소화 복구 설계는?",
      "header": "Quiz 1-7-C",
      "options": [
        {"label": "각 에이전트 상태를 알려진 위치로 export, 코디네이터는 manifest를 로드해 복원", "description": "Manifest"},
        {"label": "처음부터 다시 시작", "description": "Restart"},
        {"label": "마지막 메시지만 기억해 이어가기", "description": "Last message"},
        {"label": "사용자에게 다시 입력하라고 요청", "description": "User re-enter"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: B** — 코드 변경 시 단순 resume은 stale 컨텍스트 위험. 변경 알림 또는 새 세션+요약 주입.
- **Q2: A (Fork)** — 공유 베이스라인 위에서 분기 = fork_session의 정확한 용도. 처음부터 따로 시작은 베이스 분석 중복.
- **Q3: A (Manifest)** — D5 Task 5.4와 연결. 에이전트 상태 export + 코디네이터 manifest. 시험 D5 출제 가능성 높음.

### 출제 변형

- **"Resume vs 새 세션 결정 기준?"** → 이전 컨텍스트 freshness. Stale → 새 세션 + 요약.
- **"Fork된 두 분기의 결과 비교는 누가?"** → 사용자 또는 별도 비교 세션. Fork 자체는 비교 안 함.
- **"Manifest에 무엇을 포함?"** → 에이전트 상태 경로, 마지막 step, 공유 finding 위치, crash 시각.

---

## 🎯 D1 7개 블록 완료 — 종합 정리

### 블록 간 관계도

```
[Block 1-1] Agentic Loop ─────────────── 모든 에이전트의 기본기
                │
        ┌───────┴────────┐
        ↓                ↓
[1-2] Coordinator ─── [1-3] Subagent Spawn
   Hub-and-Spoke         Task 도구 + Context
        │
        ↓
[1-4] Enforcement ─── [1-5] Hooks
   Prerequisite          PostToolUse·인터셉션
        │                  │
        └────────┬─────────┘
                 ↓
[1-6] Decomposition ─── [1-7] Session State
   Chaining vs Dynamic    Resume·Fork·Manifest
```

### D1 함정 6개 재요약

| # | 함정 | 정답 | 관련 블록 |
|---|------|------|---------|
| F1 | 프롬프트로 강제 | Programmatic | 1-4, 1-5 |
| F2 | Few-shot으로 도구 선택 개선 | Description 확장 (D2) | 1-3, D2 |
| F3 | 컨텍스트 자동 상속 | 명시적 전달 | 1-2, 1-3 |
| F4 | 자연어 신호로 루프 종료 | stop_reason | 1-1 |
| F5 | 임의 반복 한도가 주된 정지 | 보조 가드일 뿐 | 1-1 |
| F6 | Sentiment 기반 에스컬레이션 | 정책 갭 + 명시 요청 (D5) | 1-7, D5 |

### Sample Q 매핑

| Sample Q | 도메인 | 정답 키 | 관련 블록 |
|---------|-------|---------|---------|
| Q1 (get_customer prerequisite) | D1 | Programmatic gate | **1-4** |
| Q2 (도구 description 확장) | D2 | Description | (D2 Task 2.1) |
| Q4 (verify_fact 도구) | D1/D2 | Scoped cross-role | **1-3** + D2 |
| Q9~10 (구조화 에러) | D1/D2 | errorCategory | **1-5** + D2 |

### 다음 단계

```json
AskUserQuestion({
  "questions": [{
    "question": "다음?",
    "header": "D1 완료",
    "options": [
      {"label": "D2로 (도구 설계 & MCP, 18%)", "description": "다음 도메인"},
      {"label": "D1 종합 모의 5문제", "description": "복습"},
      {"label": "learn-meta로 (함정 12 + 시나리오 6)", "description": "시험 메타"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
