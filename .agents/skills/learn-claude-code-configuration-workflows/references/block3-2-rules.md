# Block 3-3: Path-specific Rules (.claude/rules/)

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서: https://docs.claude.com/en/docs/claude-code/memory#path-specific-rules
> ```

## EXPLAIN

> Task 3.3 — 조건부 컨벤션 로딩을 위한 path-specific 룰 적용

### 한 줄 정의

**`.claude/rules/` 파일의 YAML frontmatter `paths` 필드에 glob 패턴을 지정하면, 매칭되는 파일을 편집할 때만 룰이 로드된다.**

### 구조 예시

```markdown
# .claude/rules/test-conventions.md
---
paths: ["**/*.test.tsx", "**/*.test.ts"]
---

테스트 파일 컨벤션:
- describe/it 패턴 사용
- mock은 jest.mock()으로
- ...
```

→ `*.test.tsx`/`*.test.ts` 파일 편집 시에만 이 룰 자동 로드. 다른 파일 작업 시 토큰 절약.

### F-D3-3 함정 — 자주 출제

> "코드베이스 전반에 흩어진 테스트 파일에 컨벤션 적용. 어떻게?"

| 잘못된 답 | 올바른 답 |
|---------|---------|
| 각 디렉토리마다 CLAUDE.md 작성 | **path-specific rule** — `paths: ["**/*.test.tsx"]`로 위치 무관 적용 |

→ 디렉토리 레벨 CLAUDE.md는 **그 디렉토리 안의 모든 파일**에 적용. 흩어진 같은 종류 파일엔 부적합.

### Path-specific vs 디렉토리 CLAUDE.md

| 상황 | 선택 |
|------|------|
| `terraform/` 디렉토리 안의 모든 파일 | 디렉토리 CLAUDE.md (`terraform/CLAUDE.md`) |
| 코드베이스 전반에 흩어진 `*.test.tsx` | **Path-specific rule** (`paths: ["**/*.test.tsx"]`) |
| 특정 패키지 안의 컨벤션 | 디렉토리 CLAUDE.md |
| 모든 마이그레이션 파일 (`migrations/**/*.sql`) | Path-specific rule |

### Glob 패턴 예시

```yaml
paths: ["**/*.test.tsx"]                    # 모든 .test.tsx
paths: ["**/*.test.{ts,tsx}"]               # ts + tsx
paths: ["src/**/*.api.ts"]                  # src 하위 .api.ts만
paths: ["terraform/**/*"]                   # terraform 하위 전체
paths: ["packages/api/**/*.py", "scripts/**/*.py"]  # 여러 경로
```

### 토큰 절감 효과

```
[디렉토리 CLAUDE.md만 사용]
  - 매 세션 모든 디렉토리의 CLAUDE.md 로드 시도
  - 무관한 컨텍스트가 토큰 차지

[Path-specific rule]
  - 매칭되는 파일 편집 시에만 로드
  - 무관한 작업에선 0 토큰
```

→ 큰 모노레포에서 효과 큼.

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "흩어진 파일 컨벤션은 디렉토리 CLAUDE.md로" | path-specific rule (glob) |
| "Path-specific rule은 항상 좋음" | 한 디렉토리에 집중된 컨벤션은 디렉토리 CLAUDE.md가 단순 |
| "Glob 패턴은 한 개만" | 배열로 여러 개 가능 |
| "Rule 파일은 자동으로 모두 로드" | path-specific은 매칭 시에만 로드 |
| "토큰 절약은 부수효과" | 실제로 큰 코드베이스에선 의미 있음 |

### Sample Q 매핑

> "코드베이스 전체에 흩어진 .test.tsx 파일에 일관된 테스트 컨벤션 적용. 가장 효율적 방법?"
> → Path-specific rule with `paths: ["**/*.test.tsx"]`. 각 디렉토리 CLAUDE.md는 비효율 + 일관성 깨짐.

## EXECUTE

다음 시나리오에 적합한 위치·방식을 고르세요.

```
W1. terraform/ 디렉토리 안 모든 파일 — IaC 컨벤션
W2. 코드베이스 전반의 *.migration.sql 파일 — 마이그레이션 룰
W3. packages/api/ 안의 모든 Python 파일 — 패키지 표준
W4. **/*.test.* 모든 테스트 파일 — 테스트 작성 컨벤션

→ 각각: 디렉토리 CLAUDE.md / path-specific rule
```

추가: W2를 디렉토리 CLAUDE.md로 풀려고 하면 어떤 문제? 1줄.

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 코드베이스 전반에 흩어진 *.test.tsx 파일에 컨벤션 적용. 가장 효율적?",
      "header": "Quiz 3-3-A",
      "options": [
        {"label": ".claude/rules/test.md에 paths: ['**/*.test.tsx'] frontmatter", "description": "Path-specific"},
        {"label": "각 디렉토리에 CLAUDE.md 만들어 동일 내용 반복", "description": "Per-dir"},
        {"label": "루트 CLAUDE.md에 모든 테스트 컨벤션", "description": "Root global"},
        {"label": "사용자가 매번 컨벤션 명시", "description": "Manual"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. terraform/ 디렉토리 안의 모든 파일에 IaC 컨벤션. 적절한 위치는?",
      "header": "Quiz 3-3-B",
      "options": [
        {"label": "terraform/CLAUDE.md (디렉토리 레벨)", "description": "Dir-level"},
        {"label": ".claude/rules/iac.md with paths: ['terraform/**/*']", "description": "Path-specific"},
        {"label": "둘 다 동등하게 적합", "description": "Either"},
        {"label": "유저 레벨 CLAUDE.md", "description": "User-level"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. Path-specific rule의 주된 이점은?",
      "header": "Quiz 3-3-C",
      "options": [
        {"label": "매칭 파일 편집 시에만 로드 → 토큰 절감 + 무관한 컨텍스트 제거", "description": "Conditional load"},
        {"label": "보안 강화", "description": "Security"},
        {"label": "API 응답 속도 ↑", "description": "Speed"},
        {"label": "git 커밋 자동화", "description": "Git"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A** — **F-D3-3 정면.** 흩어진 파일 = path-specific rule. 디렉토리별 반복은 일관성·유지보수 모두 실패.
- **Q2: 둘 다 가능, A가 단순** — 한 디렉토리에 집중되면 디렉토리 CLAUDE.md가 단순. B도 동작하지만 과한 설계.
- **Q3: A** — 조건부 로딩 = 토큰 절감 + 컨텍스트 청결. 큰 모노레포에서 큰 이득.

### 출제 변형

- **"여러 glob 패턴?"** → 배열로: `paths: ["**/*.test.ts", "**/*.test.tsx"]`
- **"Glob 매칭 시 rule이 항상 로드?"** → Yes, 자동.
- **"Rule 파일이 매칭되지 않으면?"** → 로드 안 됨. 토큰 0.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 3-4 진행",
    "options": [
      {"label": "다음 (3-4 Plan mode)", "description": "Plan mode vs 직접 실행"},
      {"label": "3-3 변형 한 번 더", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
