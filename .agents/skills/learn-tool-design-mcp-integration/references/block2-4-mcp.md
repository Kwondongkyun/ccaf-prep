# Block 4-2: MCP 서버 통합 (stdio/HTTP/SSE, scope)

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (MCP): https://docs.claude.com/en/docs/claude-code/mcp
> 📖 공식 문서 (MCP Spec): https://modelcontextprotocol.io
> ```

## EXPLAIN

> Task 4.2 — Model Context Protocol 서버 등록·전송·스코프

### 한 줄 정의

**MCP는 외부 도구·리소스 서버 표준. 전송은 stdio/HTTP/SSE, 스코프는 user(`~/.claude.json`) / project(`.mcp.json`) / local 셋이다.**

### 3가지 전송(transport)

```
┌──────────┬──────────────────────────────────────────┐
│ stdio    │ 로컬 프로세스 spawn — 표준 입출력 통신       │
│          │ ex: npm 패키지, 로컬 바이너리                │
├──────────┼──────────────────────────────────────────┤
│ HTTP     │ 원격 서버 — REST 풍 호출                   │
│          │ ex: 사내 API, SaaS                        │
├──────────┼──────────────────────────────────────────┤
│ SSE      │ Server-Sent Events — 스트리밍 응답          │
│          │ ex: 장기 작업 진행상황 push                  │
└──────────┴──────────────────────────────────────────┘
```

### 3가지 스코프

```
┌───────────┬────────────────────────────────────────┐
│ user      │ ~/.claude.json                         │
│           │ → 본인 모든 프로젝트                       │
│           │ → 팀과 공유 X                            │
├───────────┼────────────────────────────────────────┤
│ project   │ <프로젝트>/.mcp.json (git 커밋)           │
│           │ → 팀 전체 공유                            │
│           │ → 모노레포 전반                            │
├───────────┼────────────────────────────────────────┤
│ local     │ 현재 세션만 (CLI --mcp-config)            │
│           │ → 일시적 테스트                            │
└───────────┴────────────────────────────────────────┘
```

### F-D4-2 함정

> "팀이 같은 사내 API MCP 서버를 써야 함. 어디에 등록?"

| 잘못된 답 | 올바른 답 |
|---------|---------|
| 각자 `~/.claude.json`에 추가 안내 | **`.mcp.json`** (프로젝트 스코프) — git 커밋으로 자동 공유 |

### .mcp.json 예시

```json
{
  "mcpServers": {
    "internal-api": {
      "type": "http",
      "url": "https://mcp.internal.example.com",
      "headers": { "X-Api-Key": "${INTERNAL_API_KEY}" }
    },
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./data"]
    }
  }
}
```

### Scope 결정 매트릭스

| 시나리오 | 스코프 |
|--------|------|
| 팀 공통 사내 API | **project** (.mcp.json) |
| 본인이 쓰는 개인 노트 서버 | **user** (~/.claude.json) |
| 임시 테스트용 | **local** (--mcp-config) |
| 모노레포의 표준 서버 | **project** |
| 회사 DB 접근 (보안) | **project** + 환경변수 |

### Transport 결정 매트릭스

| 상황 | Transport |
|-----|-----------|
| 로컬 파일시스템 도구 | **stdio** |
| 원격 SaaS API | **HTTP** |
| 장기 작업 진행상황 푸시 | **SSE** |
| 사내 마이크로서비스 | **HTTP** |
| npm 배포된 MCP 도구 | **stdio** (npx로 spawn) |

### 자주 나오는 함정

| 잘못된 생각 | 올바른 생각 |
|-----------|-----------|
| "팀 공유 서버는 각자 user에" | **project** (.mcp.json) — git 커밋 |
| "MCP는 무조건 stdio" | 원격은 HTTP/SSE. 전송 선택은 서버 위치 기반 |
| "Local scope = local 머신" | 아니, **현재 CLI 세션만**. 휘발성 |
| "비밀 키를 .mcp.json에 직접" | 환경변수 `${VAR}` 참조 — 커밋되지 않게 |
| "MCP 서버는 다 외부 패키지" | 자체 작성도 가능 — 표준 프로토콜 따르면 |

### Sample Q 매핑

> "팀 5명이 모두 사내 ticket 시스템 MCP 서버를 동일 설정으로 사용해야. 어디 등록?"
> → `.mcp.json` (프로젝트 스코프). git 커밋으로 자동 공유. user scope는 5명이 각자 설정 → drift.

> "개인적으로 쓰는 Notion 노트 MCP. 어디?"
> → `~/.claude.json` (user scope). 팀 공유 불필요.

## EXECUTE

다음을 어디에·어떻게 등록할지 결정.

```
W1. 팀 공통 GitHub MCP 서버
W2. 본인이 쓰는 개인 일정 MCP
W3. 임시 디버깅용 로컬 파일시스템 MCP
W4. SaaS — Slack MCP, 팀 전체 사용
W5. 사내 ML 모델 추론 (스트리밍 응답)

→ 각각: scope + transport
```

추가: W4의 비밀 토큰을 .mcp.json에 평문 저장하면 어떤 문제? 1줄.

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 팀 5명이 동일한 사내 ticket MCP 서버 설정 공유. 가장 효율?",
      "header": "Quiz 4-2-A",
      "options": [
        {"label": ".mcp.json (project scope) + git 커밋", "description": "Project"},
        {"label": "각자 ~/.claude.json에 동일 설정", "description": "User each"},
        {"label": "CLI --mcp-config로 매번 실행", "description": "Local"},
        {"label": "관리자 머신에만 설정", "description": "Single host"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 로컬 파일시스템 MCP 도구 (npm 패키지). 적절한 transport?",
      "header": "Quiz 4-2-B",
      "options": [
        {"label": "stdio — 로컬 프로세스 spawn", "description": "stdio"},
        {"label": "HTTP — REST 호출", "description": "HTTP"},
        {"label": "SSE — 스트리밍", "description": "SSE"},
        {"label": "WebSocket", "description": "WS"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. 원격 SaaS MCP에 API 키가 필요. .mcp.json은 git 커밋. 가장 안전?",
      "header": "Quiz 4-2-C",
      "options": [
        {"label": "headers에 ${API_KEY} 환경변수 참조", "description": "Env var"},
        {"label": ".mcp.json에 평문으로 직접", "description": "Plaintext"},
        {"label": ".gitignore에 .mcp.json 추가", "description": "Gitignore"},
        {"label": "키를 사용자가 매번 입력", "description": "Manual"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A (Project scope)** — **F-D4-2 정면.** git 공유 = drift 없음. 각자 user는 5명이 5번 설정 + 변경 시 동기화 부담.
- **Q2: A (stdio)** — 로컬 프로세스는 stdio. HTTP/SSE는 원격용.
- **Q3: A (환경변수)** — 평문 커밋은 키 누출. .gitignore는 팀 공유 깨짐. 환경변수가 표준.

### 출제 변형

- **"User scope vs Project — 우선순위?"** → 둘 다 등록되면 project가 우선 (대부분 SDK).
- **"--mcp-config 옵션 언제?"** → 일시 테스트, CI 단발성.
- **"MCP 서버를 직접 작성?"** → 가능. 프로토콜 표준만 따르면 됨.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 4-3 진행",
    "options": [
      {"label": "다음 (4-3 Custom tools)", "description": "@tool 데코레이터, schema"},
      {"label": "4-2 변형", "description": "다른 시나리오"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
