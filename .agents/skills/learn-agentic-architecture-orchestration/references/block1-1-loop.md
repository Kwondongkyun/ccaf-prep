# Block 1-1: Agentic Loop 기본기

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서: https://docs.claude.com/en/docs/agents-and-tools/tool-use/overview
> 📖 Building Effective Agents (Anthropic): https://www.anthropic.com/engineering/building-effective-agents
> ```

## EXPLAIN

| 항목 | 내용 |
|------|------|
| 근본 원리 | **에이전트 = LLM이 도구를 호출하고 결과를 다시 입력으로 받는 루프**. 멈추는 시점은 모델이 결정한다 (`stop_reason`). |
| 비유 | 신입 직원이 "검색 → 결과 보고 → 또 검색 → 답 보고" 반복. 더 검색할 게 없으면 그제서야 최종 답변. |
| 핵심 키워드 | `tool_use`, `tool_result`, `stop_reason`, `end_turn`, `max_tokens` |

### 4단계 루프 (반드시 외울 것)

```
┌──────────────────────────────────────────────────────┐
│ [1] User Message + Tools 정의 → API 호출              │
│         │                                              │
│         ▼                                              │
│ [2] Claude 응답                                        │
│     ├─ stop_reason = "tool_use"  → 도구 호출 필요       │
│     └─ stop_reason = "end_turn"  → 최종 답변. 루프 종료 │
│         │                                              │
│         ▼ (tool_use인 경우만)                          │
│ [3] 앱이 도구 실행 → 결과 수집                          │
│         │                                              │
│         ▼                                              │
│ [4] role="user" + content=[tool_result] 로 다시 호출   │
│         │                                              │
│         └─ [2]로 돌아감 (반복)                         │
└──────────────────────────────────────────────────────┘
```

### 중요 포인트 4가지

1. **`stop_reason` 두 값이 핵심**
   - `tool_use` → 아직 끝나지 않음. 도구 결과를 줘야 다음 응답이 나온다.
   - `end_turn` → 모델이 더 할 게 없다고 판단. 루프 종료.
   - 그 외 `max_tokens`, `stop_sequence`, `pause_turn` 등도 있지만 시험은 위 두 개가 핵심.

2. **`tool_result`의 role은 `user`이다 (함정!)**
   - 직관적으로 "도구 결과니까 system이나 tool 같은 role이겠지?"라고 생각하기 쉽다.
   - **정답: `role: "user"`**, `content`는 `[{type: "tool_result", tool_use_id, content}]` 배열.
   - 이유: Claude API는 user/assistant 두 role만 사용. tool_result는 user 메시지의 한 형태.

3. **루프 종료 조건은 앱이 책임진다**
   - 모델은 "내가 끝났다"라고 `end_turn`만 보낼 뿐.
   - **무한 루프 / 같은 도구 반복 호출은 앱 레벨에서 가드해야 한다.**
   - 가드 패턴: max_iterations 카운터, 같은 tool_use_id/인자 반복 감지, timeout.

4. **Tools 정의는 매 호출마다 같이 보낸다**
   - `tools=[...]` 파라미터는 stateless. 매 API 호출에 포함.
   - Claude가 도구를 "기억"하는 게 아니라, 매번 시스템 프롬프트처럼 주입된다.

### 코드 흐름 (의사코드)

```python
messages = [{"role": "user", "content": "오늘 서울 날씨 알려줘"}]

while True:
    response = client.messages.create(
        model="claude-opus-4-5",
        tools=[get_weather_tool],
        messages=messages,
    )

    # 모델 응답을 messages에 추가
    messages.append({"role": "assistant", "content": response.content})

    if response.stop_reason == "end_turn":
        break  # 최종 답변 완료

    if response.stop_reason == "tool_use":
        # tool_use 블록 추출
        tool_use = next(b for b in response.content if b.type == "tool_use")

        # 앱이 도구 실행
        result = run_tool(tool_use.name, tool_use.input)

        # tool_result를 user role로 다시 보냄
        messages.append({
            "role": "user",
            "content": [{
                "type": "tool_result",
                "tool_use_id": tool_use.id,
                "content": str(result),
            }]
        })
        # 다음 iteration → 다시 API 호출

    # 무한 루프 가드 (실제 코드에선 필수)
    if len(messages) > MAX_TURNS:
        raise RuntimeError("agent loop exceeded max turns")
```

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "tool_result는 role=tool로 보내야지" | role=`user`, content는 tool_result 블록 배열 |
| "Claude가 알아서 멈춘다" | 앱이 무한 루프 가드를 짜야 함 |
| "tools 정의는 첫 호출만 하면 된다" | 매 API 호출에 tools 파라미터 포함 |
| "stop_reason은 한 번만 본다" | **매 응답마다** 본다. tool_use면 계속, end_turn이면 종료 |
| "도구 호출 실패하면 모델이 알아서 처리" | 앱이 에러를 tool_result로 모델에 다시 알려야 함 (Block 1-3에서 다룸) |

## EXECUTE

종이/메모장에 직접 4단계를 그려보세요.

```
1. 사용자가 "어제 게시된 가장 인기 있는 GitHub 레포 알려줘"라고 한다.
2. Claude가 search_github 도구를 호출하고 싶다고 응답한다.
   → stop_reason = ?
3. 앱이 검색 실행 후 결과를 다시 보낸다.
   → role = ?, content type = ?
4. Claude가 "어제 가장 인기 있는 레포는 ~ 입니다"라고 답한다.
   → stop_reason = ?
```

위 빈칸을 직접 채워보고, 의사코드를 한 번 손으로 써보세요. **머릿속 시뮬레이션 1회는 필수.**

추가로, 무한 루프 가드를 어떻게 짤지 1줄로 메모해보세요. (예: `if iteration > 25: break` 또는 `if same_tool_input_3times: break`)

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 4단계 루프의 순서로 옳은 것은?",
      "header": "Quiz 1-1-A",
      "options": [
        {"label": "User → Claude(tool_use) → 도구 실행 → tool_result(role=user) 재호출", "description": "정답 후보 A"},
        {"label": "User → Claude(end_turn) → 도구 실행 → tool_result(role=tool) 재호출", "description": "정답 후보 B"},
        {"label": "User → 도구 실행 → Claude(tool_use) → tool_result(role=assistant) 재호출", "description": "정답 후보 C"},
        {"label": "User → Claude(tool_use) → 도구 실행 → tool_result(role=tool) 재호출", "description": "정답 후보 D"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 도구 결과를 모델에 돌려줄 때 메시지의 role은?",
      "header": "Quiz 1-1-B",
      "options": [
        {"label": "user", "description": "tool_result는 user 메시지의 한 형태"},
        {"label": "assistant", "description": "모델이 만든 거니까"},
        {"label": "tool", "description": "도구 결과니까 자연스러움"},
        {"label": "system", "description": "시스템이 처리하니까"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. Claude가 같은 도구를 같은 인자로 5번 연속 호출하는 상황. 어떻게 대응하나?",
      "header": "Quiz 1-1-C",
      "options": [
        {"label": "프롬프트에 '같은 도구를 반복 호출하지 마'라고 추가", "description": "프롬프트로 강제"},
        {"label": "앱 레벨에서 같은 tool_use 반복 감지 → 루프 종료 또는 다른 경로 강제", "description": "Programmatic 가드"},
        {"label": "그냥 max_tokens까지 두고 본다", "description": "자연 종료 대기"},
        {"label": "temperature를 올려 다양성 확보", "description": "샘플링 변경"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A** — User → Claude(`stop_reason=tool_use`) → 앱이 도구 실행 → `role=user` + `tool_result` 블록으로 재호출. B는 end_turn이라 루프 안 돌고, C/D는 role이 틀림.
- **Q2: user** — Claude API는 user/assistant 두 role만 사용. tool_result는 user 메시지의 content 배열에 들어가는 블록 타입.
- **Q3: B (Programmatic 가드)** — **D1 핵심 함정 F1**: 프롬프트로 강제하지 말고 코드로 막는다. 앱이 같은 tool_use_id 또는 같은 (name, input) 패턴을 카운트해서 임계치 넘으면 루프 종료/다른 도구 강제/사용자 에스컬레이션.

### 출제 변형 (시험 직전 다시 보기)

- "loop를 무엇이 끝내는가?" → 모델의 `end_turn` + 앱의 가드 (둘 다)
- "tools 파라미터는 언제 보내나?" → **매 API 호출마다**
- "Claude가 도구를 호출하지 않고 바로 답변하면?" → `stop_reason=end_turn`, 루프 1회만에 종료. 정상 동작.

### 다음 블록 안내

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록으로 갈까요?",
    "header": "Block 1-2 진행",
    "options": [
      {"label": "다음 (1-2 Goal-Oriented Delegation)", "description": "Subagent 위임 원칙"},
      {"label": "1-1 한번 더", "description": "다른 변형 문제로 복습"},
      {"label": "잠시 멈춤", "description": "여기서 끊기"}
    ],
    "multiSelect": false
  }]
})
```
