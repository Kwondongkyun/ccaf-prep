# Block 2-5: Built-in Tools (Read/Write/Edit/Bash/Grep/Glob)

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Built-in Tools): https://docs.claude.com/en/docs/claude-code/settings#tools-available-to-claude
> ```

## EXPLAIN

> Task 2.5 — 6가지 built-in 도구의 목적·선택 기준을 안다

### 한 줄 정의

**파일은 Read/Write/Edit, 검색은 Grep/Glob, 명령은 Bash. 각각 책임 영역이 다르다 — 잘못 고르면 토큰 낭비·결과 부정확.**

### 6도구 표

| 도구 | 용도 | 언제 |
|-----|------|------|
| **Read** | 파일 1개 읽기 (전체/일부) | 경로를 알 때, 파일 내용 필요할 때 |
| **Write** | 파일 새로 쓰기 (덮어쓰기) | 신규 파일 또는 전면 재작성 |
| **Edit** | 기존 파일 부분 수정 (`old_string` → `new_string`) | 일부만 바꿀 때 — 토큰 절약 |
| **Grep** | 콘텐츠 패턴 검색 (regex, ripgrep 기반) | "어디서 X를 쓰는가" |
| **Glob** | 파일 경로 패턴 검색 (`**/*.ts`) | "어떤 파일들이 있는가" |
| **Bash** | 셸 명령 1회 실행 | 빌드·테스트·git·기타 외부 명령 |

### 선택 기준 (트리)

```
질문이 무엇인가?
├─ "파일 X 내용?" → Read (경로 안다)
├─ "X.ts 파일들?" → Glob (`**/X*.ts`)
├─ "이 함수 어디서 호출?" → Grep (`functionName\(`)
├─ "파일 새로 만들기" → Write
├─ "한 줄 바꾸기" → Edit (Read 먼저!)
└─ "테스트 실행 / git status" → Bash
```

### 자주 나오는 함정

| 잘못된 선택 | 올바른 선택 |
|-----------|-----------|
| `Bash("cat file.md")` | **Read** — Bash는 외부 명령 전용 |
| `Bash("grep -r 'foo' .")` | **Grep** — ripgrep 기반, 더 빠르고 컨텍스트 보존 |
| `Bash("find . -name '*.ts'")` | **Glob** — 패턴 매칭에 최적화 |
| `Write` 로 한 줄만 변경 | **Edit** — 전체 재작성은 토큰 낭비 |
| Read 없이 Edit | **Edit는 Read 후에만 가능** — 안전장치 |
| `Bash("echo hello")` | 텍스트 출력은 응답으로 직접 — Bash 불필요 |

### Glob vs Grep 핵심 차이

```
Glob:  파일 시스템 트리에서 경로 패턴 매치
       "src/**/*.tsx" — 어떤 파일들?
       빠름. 콘텐츠 안 읽음.

Grep:  파일 콘텐츠 안에서 정규식 매치
       "useState\(" — 어디서 쓰이나?
       콘텐츠 읽음. -l (filenames only), -A/-B (context) 지원.
```

### Sample Q 시사점

> 특정 시험 문항으로 6도구가 직접 출제되진 않지만, **Coordinator가 subagent에 어떤 도구만 허용할지** (D1·D5·`allowed-tools` frontmatter) 결정 시 적재적소 매칭이 핵심.

## EXECUTE

```
W1. "test/Button.test.tsx 파일 안의 mock 함수 호출 모두 찾기" — 어떤 도구?
W2. "src 폴더 안 .ts 파일 목록만" — ?
W3. "package.json의 dependencies 한 줄만 수정" — ?
W4. "git diff main…HEAD 실행" — ?
W5. "신규 README.md 작성" — ?
```

→ 각 답: 도구 + 그 이유 1줄

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. '코드베이스 전체에서 deprecated API `oldFunc()` 호출 위치를 찾으려면?",
      "header": "Quiz 2-5-A",
      "options": [
        {"label": "Grep — 콘텐츠 정규식 매치", "description": "Grep"},
        {"label": "Glob — 파일 경로 패턴", "description": "Glob"},
        {"label": "Bash grep -r", "description": "Bash grep"},
        {"label": "Read로 모든 파일", "description": "Read all"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. README.md의 한 섹션만 업데이트. 효율적인 도구?",
      "header": "Quiz 2-5-B",
      "options": [
        {"label": "Read 후 Edit — 토큰 효율 + 안전", "description": "Read+Edit"},
        {"label": "Write로 전체 재작성", "description": "Write all"},
        {"label": "Bash sed", "description": "sed"},
        {"label": "Edit 단독 (Read 생략)", "description": "Edit alone"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. Bash가 가장 적절한 작업은?",
      "header": "Quiz 2-5-C",
      "options": [
        {"label": "npm test 실행 + git status 확인", "description": "Bash 본연"},
        {"label": "파일 콘텐츠에서 함수 검색", "description": "Grep 영역"},
        {"label": "tsx 파일 목록", "description": "Glob 영역"},
        {"label": "한 파일 읽기", "description": "Read 영역"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (Grep)** — ripgrep 기반, 콘텐츠 정규식. Bash grep 보다 빠르고 결과 구조화.
- **Q2: A (Read+Edit)** — Edit는 Read 선행 필수. Write 전체 재작성은 토큰 낭비.
- **Q3: A** — Bash는 외부 셸 명령 전용. 파일 I/O·검색은 전용 도구 우선.

### 출제 변형

- **"Edit가 안 먹힌다"** → Read 안 했거나 `old_string` 유일하지 않음.
- **"Glob과 Grep 동시 필요"** → 먼저 Glob으로 후보 파일 → 그 안에서 Grep.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 2 종료",
    "options": [
      {"label": "D2 종합 정리", "description": "5블록 관계도 + Sample Q 매핑"},
      {"label": "D3로 이동", "description": "Claude Code Configuration"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
