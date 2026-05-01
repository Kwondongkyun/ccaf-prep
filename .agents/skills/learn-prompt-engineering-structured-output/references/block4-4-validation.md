# Block 4-4: Pydantic 검증·재시도 (구조화 출력)

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Structured Outputs): https://docs.claude.com/en/api/agent-sdk
> 📖 Pydantic: https://docs.pydantic.dev
> ```

## EXPLAIN

> Task 4.4 — Pydantic 모델로 LLM 출력 구조 강제 + 검증 실패 시 재시도

### 한 줄 정의

**LLM 자유 텍스트는 파싱 불안정. Pydantic 모델로 구조 정의 → 검증 실패 시 에러 메시지를 컨텍스트로 재시도.**

### 기본 패턴

```python
from pydantic import BaseModel, Field, ValidationError
from claude_agent_sdk import query

class ReviewResult(BaseModel):
    verdict: Literal["pass", "fail", "warn"]
    issues: list[Issue] = Field(default_factory=list)
    summary: str = Field(max_length=500)

async def review_with_retry(prompt: str, max_retries: int = 3):
    last_error = None
    for attempt in range(max_retries):
        full_prompt = prompt
        if last_error:
            full_prompt += f"\n\n이전 시도 실패: {last_error}\n반드시 스키마를 따르세요."
        
        raw = await collect(query(prompt=full_prompt))
        try:
            return ReviewResult.model_validate_json(raw)
        except ValidationError as e:
            last_error = str(e)
    
    raise RuntimeError(f"Validation failed after {max_retries} retries")
```

### F-D4-4 함정

> "LLM이 JSON 출력하라 했는데 가끔 형식 깨짐. 어떻게?"

| 잘못된 답 | 올바른 답 |
|---------|---------|
| 정규표현식으로 후처리 | **Pydantic 검증 + 검증 실패 메시지로 재시도** — 결정적 |

### 핵심 컴포넌트 3가지

```
[1] 모델 정의 (Pydantic BaseModel)
    - 필드 타입·범위·필수/선택 강제

[2] 검증 (model_validate_json)
    - 실패 시 ValidationError → 어디가 틀렸는지 명확

[3] 재시도 루프
    - 검증 실패 메시지를 다음 turn 컨텍스트로
    - max_retries로 무한 루프 방지
```

### 좋은 Pydantic 모델 — 예시

```python
class Issue(BaseModel):
    severity: Literal["critical", "high", "medium", "low"]
    file: str
    line: int = Field(ge=1)
    message: str = Field(min_length=10, max_length=500)

class ReviewResult(BaseModel):
    verdict: Literal["pass", "fail", "warn"]
    issues: list[Issue]
    summary: str
    
    @field_validator("issues")
    @classmethod
    def fail_requires_issues(cls, v, info):
        if info.data.get("verdict") == "fail" and not v:
            raise ValueError("verdict=fail이면 issues가 비어있을 수 없음")
        return v
```

→ **타입 + 범위 + 비즈니스 룰** 모두 강제.

### 재시도 시 핵심: 에러 메시지를 컨텍스트로

```
[Bad — 재시도]
  attempt 1 실패 → 같은 프롬프트로 다시
  → 같은 실수 반복 가능

[Good — 에러 컨텍스트 주입]
  attempt 1 실패 → "issues[0].line은 1 이상이어야"
  → attempt 2 프롬프트에 에러 추가
  → 모델이 무엇을 고쳐야 할지 알 수 있음
```

### Pydantic vs JSON Schema (CLI) — 결정 기준

| 상황 | 선택 |
|-----|------|
| Python SDK 워크플로우 | **Pydantic** |
| CLI / shell 파이프라인 | JSON Schema (`--json-schema`) |
| 비즈니스 룰 (cross-field) 필요 | **Pydantic** (validator) |
| 타 언어 시스템과 공유 | JSON Schema |

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "정규표현식으로 LLM 출력 후처리" | Pydantic 검증 — 결정적·자동 |
| "검증 실패하면 그냥 fail" | 검증 메시지를 다음 turn에 주입해 재시도 |
| "재시도 무한히" | max_retries 필수. 영구 실패 가능 |
| "모델은 단순 타입만" | validator로 cross-field 룰 강제 가능 |
| "JSON 형식만 강제하면 충분" | 의미 검증 (range, enum, business rule) 까지 |

### Sample Q 매핑

> "Agent가 JSON 응답을 가끔 잘못 형식. 가장 효과적?"
> → Pydantic 모델 검증 + 실패 시 에러 컨텍스트로 재시도. 정규식·프롬프트는 부족.

> "구조 통과했지만 의미적으로 모순 (verdict=pass인데 critical issue 있음). 어떻게?"
> → field_validator로 cross-field 룰 강제.

## EXECUTE

```
시나리오 1: PR 리뷰 결과 Pydantic 모델 설계
  - verdict, issues[], summary 필드
  - cross-field 룰?

시나리오 2: 검증 실패 시 재시도 루프 작성
  - max_retries는?
  - 에러 메시지 어떻게 컨텍스트에?

시나리오 3: 같은 작업을 정규식 후처리로 풀려고 하면
  - 어떤 한계?
```

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. LLM이 JSON 출력 가끔 형식 깨짐. 가장 효과적 처리?",
      "header": "Quiz 4-4-A",
      "options": [
        {"label": "Pydantic 검증 + 검증 실패 메시지를 컨텍스트로 재시도", "description": "Pydantic + retry"},
        {"label": "정규표현식 후처리", "description": "Regex"},
        {"label": "프롬프트에 'JSON으로' 강조", "description": "Prompt"},
        {"label": "사용자가 수동 파싱", "description": "Manual"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 구조는 맞지만 의미 모순 (pass + critical issue). 가장 효과적?",
      "header": "Quiz 4-4-B",
      "options": [
        {"label": "Pydantic field_validator로 cross-field 룰", "description": "Validator"},
        {"label": "프롬프트에 모순 경고", "description": "Prompt"},
        {"label": "후처리에서 if 체크", "description": "Post-check"},
        {"label": "허용", "description": "Accept"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. 재시도 루프 설계. 가장 안전?",
      "header": "Quiz 4-4-C",
      "options": [
        {"label": "max_retries=3 + 검증 에러 메시지를 다음 prompt에", "description": "Bounded + ctx"},
        {"label": "무한 retry — 성공할 때까지", "description": "Infinite"},
        {"label": "1회 시도만, 실패면 fail", "description": "Single"},
        {"label": "max_retries=3 + 같은 프롬프트 그대로", "description": "Same prompt"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (Pydantic + retry)** — **F-D4-4 정면.** 결정적 검증 + 에러를 컨텍스트화.
- **Q2: A (validator)** — Pydantic은 단순 타입 외 cross-field 룰 강제 가능.
- **Q3: A (Bounded + ctx)** — 한도 + 에러 컨텍스트. D 같은 프롬프트는 같은 실수 반복.

### 출제 변형

- **"Pydantic vs JSON schema?"** → Python SDK는 Pydantic, CLI는 JSON schema.
- **"검증 실패 시 에러 메시지 안 주면?"** → 모델이 뭘 고쳐야 할지 모름. 같은 실패 반복.
- **"validator는 어떤 룰?"** → Cross-field, 비즈니스 의미. 단순 타입은 필드 정의로.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 4-5 진행",
    "options": [
      {"label": "다음 (4-5 에러 핸들링·복구)", "description": "retry, fallback, classification"},
      {"label": "4-4 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
