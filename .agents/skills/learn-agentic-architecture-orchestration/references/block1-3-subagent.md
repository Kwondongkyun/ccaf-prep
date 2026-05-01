# Block 1-3: Subagent Spawn & Context Passing

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서: https://docs.claude.com/en/api/agent-sdk/subagents
> 📖 Task tool: https://docs.claude.com/en/docs/claude-code/sub-agents
> ```

## EXPLAIN

> Task 1.3 — 서브에이전트 호출, 컨텍스트 전달, 스폰 설정

### 한 줄 정의

**Task 도구로 서브에이전트를 스폰하고, 컨텍스트는 프롬프트에 명시적으로 포함한다. 자동 상속 없음.**

### 4가지 핵심 사실

**1. Task 도구 = 서브에이전트 스폰 메커니즘**
- 코디네이터가 서브에이전트를 호출할 때 사용하는 내장 도구.
- **코디네이터의 `allowedTools`에 `"Task"`가 포함되어야 함.** 없으면 위임 불가.
- 예: `allowedTools: ["Read", "Grep", "Task"]`

**2. 컨텍스트는 자동 상속되지 않는다 (D1 핵심 함정)**
- 서브에이전트는 **격리된 새 컨텍스트**에서 시작.
- 코디네이터의 대화 이력·파일 읽은 결과·이전 도구 결과는 자동으로 안 넘어감.
- → Task 호출 시 `prompt` 파라미터에 **필요한 모든 정보를 직접 포함**.

```python
# ❌ 자동 상속 가정 (실패)
spawn_subagent(
    type="synthesis",
    prompt="이전에 모은 자료들 종합해줘"  # 서브에이전트는 "이전 자료"가 뭔지 모름
)

# ✅ 명시적 전달
spawn_subagent(
    type="synthesis",
    prompt=f"""
    아래 웹 검색 결과와 문서 분석 출력을 종합해 보고서를 작성하라.

    [웹 검색 결과]
    {web_results}

    [문서 분석 출력]
    {doc_analysis}

    [품질 기준]
    - 인용 보존, 상충 주장 별도 표시
    """
)
```

**3. AgentDefinition 설정 — 각 서브에이전트의 정체성**

각 서브에이전트는 다음 3가지로 정의:

| 필드 | 역할 | 예시 |
|------|------|------|
| `description` | 어떤 작업에 적합한지 (코디네이터가 위임 결정 시 참조) | "웹에서 최신 학술·뉴스 자료를 수집" |
| `system prompt` | 서브에이전트의 행동 원칙·출력 형식 | "모든 finding에 URL과 발췌 포함" |
| `allowedTools` | 사용 가능한 도구 제한 | `["WebSearch", "WebFetch"]` |

**4. 병렬 스폰 — 한 응답에서 여러 Task 호출**
- 코디네이터가 한 응답에서 Task 도구를 **여러 개 emit** 가능.
- 서브에이전트들이 **병렬 실행**됨.
- 턴을 분리하지 말 것 — "먼저 A 호출 → 결과 받고 → 다음 턴에 B 호출"은 비효율.

```python
# 한 응답에 동시 emit
[
  Task(type="web", prompt=...),
  Task(type="docs", prompt=...),
  Task(type="db", prompt=...)
]
# → 셋이 병렬 실행, 결과 모두 다음 턴에 한꺼번에 도착
```

### 메타데이터 분리 — Attribution 보존

서브에이전트 간 컨텍스트 전달 시 **콘텐츠와 메타데이터를 분리한 구조화 포맷** 사용.

```json
[
  {
    "content": "GPT-4o의 MMLU 점수는 88.7%이다",
    "source_url": "https://arxiv.org/abs/2410.xxxx",
    "document": "OpenAI Technical Report",
    "page": 12
  },
  ...
]
```

→ 종합 단계에서 인용 매핑 보존됨. 그냥 텍스트로만 넘기면 출처 손실.

### Fork 기반 세션 — 분기 탐색

`fork_session`으로 **공유 베이스라인에서 독립 분기**를 만듦.

```
                  공유 분석 베이스라인
                         │
              ┌──────────┼──────────┐
              ↓          ↓          ↓
         Fork A      Fork B      Fork C
       (전략 1)     (전략 2)    (전략 3)
       독립 진행     독립 진행    독립 진행
```

- 같은 출발점에서 **다른 접근법** 탐색에 유용 (예: 두 가지 리팩터링 전략 비교).
- D1 Task 1.7 (Session State)에서 더 깊이.

### 코디네이터 프롬프트 작성 원칙 (재강조)

```
❌ "1단계 검색, 2단계 분석, 3단계 종합 — 정확히 이 순서"
✅ "리서치 목표: X. 품질 기준: Y. 적절한 서브에이전트를 선택해 위임."
```

→ 단계별 절차는 서브에이전트의 **적응성을 죽임**. 목표·기준만 주고 어떻게는 맡긴다.

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "서브에이전트가 코디네이터 컨텍스트를 자동 상속" | 명시적 prompt 포함 필수 |
| "코디네이터에 Task 도구 별도 등록 불필요" | `allowedTools`에 `"Task"` 포함 |
| "서브에이전트는 차례로 호출해야 안전" | 한 응답에 병렬 Task 호출 가능 |
| "서브에이전트에 모든 도구 다 줘서 자유도 ↑" | 역할별 `allowedTools` 제한 (D2 Task 2.3) |
| "메타데이터는 본문에 자연어로 끼워넣자" | 구조화 포맷으로 분리 |

### Sample Q 매핑

이 블록은 **Multi-Agent Research 시나리오 Sample Q (484번 줄)** 와 직결.

> "종합 에이전트가 fact verification이 필요할 때 어떻게 해결?"
> → 정답: **종합 에이전트에 단순 조회용 verify_fact 도구를 scope해서 제공**, 복잡한 검증은 코디네이터를 통해 웹검색 에이전트로 위임.
> (= scoped cross-role 도구 + hub-routed 라우팅 결합)

## EXECUTE

다음을 직접 작성해보세요.

```
시나리오: 멀티 에이전트 리서치 시스템.
서브에이전트: web_search, doc_analysis, synthesis, report

작업 1: synthesis 서브에이전트의 AgentDefinition 3필드를 직접 적어보세요.
  - description:
  - system prompt (3줄 이내):
  - allowedTools:

작업 2: 코디네이터가 web_search와 doc_analysis를 병렬 호출하는 의사코드.
  (Task 도구를 두 번 emit하는 형태로)

작업 3: 위 결과를 synthesis에 넘기는 prompt 템플릿 — "자동 상속 안 함" 함정을 피하면서.
```

추가: AgentDefinition의 `allowedTools`에 **무엇을 넣지 말아야** 하는지 1줄 메모. (힌트: Task 도구는 서브에이전트가 또 다른 서브에이전트를 부르는 게 아니라면 보통 빠짐)

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 코디네이터에서 서브에이전트를 스폰하려는데 동작 안 함. 가장 가능성 높은 원인?",
      "header": "Quiz 1-3-A",
      "options": [
        {"label": "코디네이터의 allowedTools에 'Task'가 없음", "description": "Task 도구 미등록"},
        {"label": "서브에이전트의 system prompt가 없음", "description": "Identity 누락"},
        {"label": "tool_choice가 'auto'로 되어 있음", "description": "기본값"},
        {"label": "API 키가 만료됨", "description": "Auth"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 코디네이터가 web 검색 결과를 synthesis 서브에이전트에 전달. 가장 안전한 방법?",
      "header": "Quiz 1-3-B",
      "options": [
        {"label": "그냥 호출 — 서브에이전트가 부모 컨텍스트 알아서 상속", "description": "Auto inherit"},
        {"label": "Task 호출의 prompt 파라미터에 검색 결과 + 메타데이터(URL/문서명) 직접 포함", "description": "Explicit pass with structured data"},
        {"label": "공유 디스크에 파일 쓰고 서브에이전트가 읽도록", "description": "Filesystem"},
        {"label": "서브에이전트의 system prompt를 동적으로 수정", "description": "Mutate identity"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. 시간 절약 위해 web_search·doc_analysis·db_query 3개 서브에이전트를 병렬 실행하려면?",
      "header": "Quiz 1-3-C",
      "options": [
        {"label": "각 서브에이전트를 별도 턴에 차례로 호출", "description": "Sequential"},
        {"label": "한 응답에서 Task 도구를 3번 emit", "description": "Parallel spawn"},
        {"label": "코디네이터를 3개 인스턴스로 띄우기", "description": "Coordinator scaling"},
        {"label": "병렬 호출 불가 — 항상 순차", "description": "API limit"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A** — 코디네이터 `allowedTools`에 `"Task"` 없으면 서브에이전트 스폰 불가. 가장 흔한 셋업 실수.
- **Q2: B (Explicit pass)** — **D1 함정 F3 정면.** 자동 상속 안 함. 메타데이터(URL/문서명) 분리 포함이 attribution 보존의 핵심.
- **Q3: B (Parallel spawn)** — 한 응답에 Task 여러 개 emit하면 병렬 실행. 턴 분리는 비효율.

### 출제 변형

- "synthesis 에이전트가 verify_fact를 자주 호출. 어떻게?" → **scoped cross-role 도구 부여** (Sample Q 484 매핑)
- "서브에이전트에 어떤 도구를 줄지?" → **자기 역할에 적합한 것만**. 종합 에이전트에 WebSearch 다 주지 말고, 단순 verify만.
- "Fork session 언제 쓰나?" → 같은 베이스라인에서 **분기된 접근법** 비교 (예: 두 리팩터링 전략).

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 1-4 진행",
    "options": [
      {"label": "다음 (1-4 Enforcement·Handoff)", "description": "Programmatic prerequisite — 시험 자주 출제 (Sample Q 1번)"},
      {"label": "1-3 변형 한 번 더", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
