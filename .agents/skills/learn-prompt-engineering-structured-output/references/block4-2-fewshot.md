# Block 2-4: Few-shot 예시 (입출력 패턴)

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Prompt Engineering): https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/multishot-prompting
> ```

## EXPLAIN

> Task 2.4 — Few-shot 예시는 transformation·분류에 결정적. 도구 사용 일관성엔 description 우선.

### 한 줄 정의

**Few-shot = 입력·출력 쌍 예시. Transformation·포맷팅·분류에 강력. 도구 사용엔 description이 우선 (D1 F2).**

### 적용 영역 매트릭스

| 작업 | 우선 |
|-----|------|
| 데이터 transformation | **Few-shot** |
| 포맷팅·정규화 | **Few-shot** |
| 분류·태깅 | **Few-shot** (라벨 일관성) |
| 도구 사용 일관성 | **Description** (D1 F2) |
| 워크플로우 단계 안내 | Description |
| Edge case 처리 | Few-shot (구체 예시 강력) |

### F-D2-4 함정 (= D1 F2)

> "도구 사용 일관성이 떨어짐. Few-shot 예시 5개 추가하면?"

| 잘못된 답 | 올바른 답 |
|---------|---------|
| Few-shot으로 일관성 ↑ | **Description 확장 우선** — 도구는 description 기반 선택 |

→ Transformation은 few-shot이 맞지만, 도구 사용은 description.

### 좋은 Few-shot — 패턴

```
[Bad — 자연어 설명만]
"이메일 주소를 정중하게 포맷"
→ 결과: "John D <john@x.com>" / "John Doe (john@x.com)" 들쭉날쭉

[Good — Few-shot]
입력: john@example.com  → 출력: john@example.com
입력: JOHN@EXAMPLE.COM  → 출력: john@example.com
입력: " John@Example.Com " → 출력: john@example.com

지금 변환:
입력: " ALICE@TEST.COM "
→ 출력: alice@test.com  (일관)
```

### Few-shot 갯수 가이드

```
1개  → 패턴 일반화 부족. 비추.
2~3개 → 표준. 다양성 확보.
5개+ → 토큰 비용. 더 안 좋아질 수도 (overfitting).
```

→ **2~3개가 sweet spot.**

### Edge case 포함

```
[Bad — 정상 케이스만]
입력: "Hello"  → 출력: "안녕하세요"
입력: "Bye"    → 출력: "안녕히"

[Good — edge case 포함]
입력: "Hello"   → 출력: "안녕하세요"
입력: ""        → 출력: ""  (빈 입력)
입력: "123"     → 출력: "123" (비번역 대상)
```

→ Edge case를 예시로 보여주면 LLM이 일반화.

### 도구 사용 vs Few-shot — 구분

```
[도구 사용 일관성 — Description]
- "언제 쓰는지" 문장으로
- "반환 형태" 문장으로
- "부작용" 명시

[데이터 변환 일관성 — Few-shot]
- 입력 → 출력 쌍 2~3개
- Edge case 포함
```

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "Few-shot은 항상 좋다" | 도구 사용엔 description 우선 (D1 F2) |
| "예시 많을수록 좋다" | 2~3개 sweet spot. 5개+는 비용·overfit |
| "정상 케이스만 충분" | Edge case 포함이 일반화 ↑ |
| "Description 길게 쓰면 transformation도 OK" | 자연어는 transformation에 약함 |
| "Few-shot 1개로 충분" | 패턴 일반화 부족. 2~3개 |

### Sample Q 매핑

> "데이터 정규화 자연어 spec → 결과 들쭉날쭉. 가장 효과적?"
> → Few-shot 2~3쌍 추가. Description 길이는 효과 미약.

> "도구 사용 일관성 ↓. Few-shot 추가?"
> → 잘못. **Description 확장**이 우선 (D1 F2).

> "분류 라벨이 매번 다른 표현. 어떻게?"
> → Few-shot — 라벨 후보를 예시로 못 박음.

## EXECUTE

```
W1. 이메일 주소 정규화 — Few-shot vs Description?
W2. 도구 사용 일관성 향상 — ?
W3. 사용자 의도 분류 (구매/문의/취소) — ?
W4. JSON 응답 형식 강제 — ?

→ 각각: Few-shot / Description
```

추가: Few-shot에 정상 케이스만 5개 넣었는데 edge case 깨짐. 왜? 1줄.

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 데이터 transformation 일관성이 부족. 가장 효과적?",
      "header": "Quiz 2-4-A",
      "options": [
        {"label": "Few-shot 2~3쌍 (입력→출력) + edge case 포함", "description": "Few-shot"},
        {"label": "Description을 더 길게", "description": "Longer desc"},
        {"label": "Pydantic 검증만", "description": "Pydantic"},
        {"label": "후처리 정규식", "description": "Regex"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 도구 사용 시점/방법이 일관성 없음. 가장 효과적?",
      "header": "Quiz 2-4-B",
      "options": [
        {"label": "도구 description을 '언제·왜·반환'으로 확장", "description": "Description"},
        {"label": "Few-shot 5개 추가", "description": "Few-shot"},
        {"label": "강제 호출 프롬프트", "description": "Force"},
        {"label": "도구 갯수 줄이기", "description": "Reduce"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. Few-shot 적정 갯수?",
      "header": "Quiz 2-4-C",
      "options": [
        {"label": "2~3개 (sweet spot, edge case 포함)", "description": "2-3"},
        {"label": "1개 (간결)", "description": "1"},
        {"label": "10개+ (많을수록 좋음)", "description": "Many"},
        {"label": "0개 (자연어로 충분)", "description": "0"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (Few-shot)** — Transformation은 예시가 결정적. Edge case 포함 일반화 ↑.
- **Q2: A (Description)** — **F-D2-4 정면 (= D1 F2).** 도구 사용은 description 우선.
- **Q3: A (2~3)** — 1개는 일반화 부족, 5개+는 비용·overfit.

### 출제 변형

- **"Edge case 안 넣으면?"** → 정상 케이스 안에선 OK, 경계에서 깨짐.
- **"Few-shot vs Pydantic?"** → Few-shot은 출력 패턴, Pydantic은 검증·강제. 같이 쓸 수도 있음.
- **"Description 짧게 + Few-shot 많이?"** → 도구 사용엔 description 우선. Transformation은 few-shot.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 2-5 진행",
    "options": [
      {"label": "다음 (2-5 컨텍스트 윈도우 관리)", "description": "Manifest, summary, /clear"},
      {"label": "2-4 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
