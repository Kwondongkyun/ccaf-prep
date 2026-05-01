# Block 4-6: Multi-instance / Multi-pass Review

> **Phase A 시작 시 반드시 아래 형태로 출력한다:**
> ```
> 📖 공식 문서 (Best Practices): https://www.anthropic.com/engineering/claude-code-best-practices
> ```

## EXPLAIN

> Task 4.6 — Large PR이나 코드 리뷰에서 single-pass의 attention dilution 회피

### 한 줄 정의

**14파일 PR을 한 번에 리뷰하면 attention 분산 → 일관성 깨짐(같은 패턴인데 한 곳은 지적, 다른 곳은 통과). 해결: file-by-file local pass + integration-focused cross-file pass. 또한 코드 생성과 리뷰는 독립 인스턴스로 분리(self-bias 회피).**

### Single-pass의 실패 모드 (Sample Q 12)

```
14파일 PR을 한 번에 리뷰
  ↓
[증상]
- 어떤 파일은 detailed, 어떤 파일은 superficial
- 같은 패턴인데 file A에선 지적, file B에선 통과
- 명백한 버그 누락

[원인]
- Attention dilution — 컨텍스트 길어질수록 정밀도 떨어짐
- "lost in the middle" — 중간 파일 처리 약함
```

### Multi-pass 구조

```
Pass 1: File-by-file local review
  for each file:
    - 해당 파일만 컨텍스트에 포함
    - local issues (logic, naming, edge cases) 검출
    - 결과 누적

Pass 2: Integration cross-file
  - 모든 파일 한 번에
  - local 이슈 무시. 오직 cross-file 데이터 흐름·dependency·계약 깨짐
  - 결과 + Pass 1 결과 → final report
```

### Multi-instance 패턴 (생성 vs 리뷰)

```
[Bad — self-bias]
같은 세션에서 코드 생성 → 같은 세션에서 리뷰
  → 자기 결정 합리화. 문제 인식 어려움

[Good — 독립 인스턴스]
인스턴스 A: 코드 생성 (생성 컨텍스트 보유)
인스턴스 B: 리뷰 (생성 컨텍스트 없음, code만 봄)
  → bias 없는 검증
```

### 자주 나오는 함정 (Sample Q 12 매핑)

| 잘못된 답 | 올바른 답 |
|---------|---------|
| 개발자에게 PR 작게 쪼개라고 요청 | **시스템이 multi-pass로 처리** (사용자 부담 X) |
| 더 큰 컨텍스트 윈도우 모델로 교체 | 컨텍스트 크기 ≠ attention 품질. **Multi-pass 우선** |
| 3번 같은 review 돌려 합집합 | 중복 cost, attention 문제 미해결 |
| Multi-pass + 독립 인스턴스 (정답) | **File pass + integration pass + 코드 생성과 분리** |

### 언제 Single-pass 충분?

- 1-3 파일 변경
- 단일 모듈 내
- 명확히 좁은 범위

### Sample Q 매핑

> **Sample Q 12**: 14파일 single-pass → inconsistent. 정답 = (A) split into focused passes + integration pass.

## EXECUTE

```
W1. "20파일 monorepo PR — 단일 review pass" — 어떤 증상 예상?
W2. "Multi-pass 설계 — Pass 1과 Pass 2 책임 분리?"
W3. "코드 생성 + 즉시 리뷰를 같은 세션에서" — 어떤 bias?
W4. "PR 3파일 — multi-pass 필요?" — 판단 기준?
```

→ 각 답: 1-2줄 결정

---
👆 위 내용을 한번 정리해보세요.
이해되면 "완료" 또는 "다음"이라고 입력해주세요.

## QUIZ

```json
AskUserQuestion({
  "questions": [
    {
      "question": "Q1. 14파일 PR single-pass review가 inconsistent. 가장 효과적 재구성?",
      "header": "Quiz 4-6-A",
      "options": [
        {"label": "File-by-file local pass + integration cross-file pass", "description": "Multi-pass"},
        {"label": "PR을 3-4파일씩 쪼개라고 개발자에게 요청", "description": "쪼개기"},
        {"label": "더 큰 컨텍스트 모델로 한 번에", "description": "큰 모델"},
        {"label": "동일 review 3번 돌려 2/3 합의", "description": "3번 합의"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q2. 코드 생성과 리뷰를 같은 세션에서 — 문제?",
      "header": "Quiz 4-6-B",
      "options": [
        {"label": "Self-bias — 자기 결정 합리화. 독립 인스턴스로 리뷰", "description": "Self-bias"},
        {"label": "비용만 더 듦", "description": "비용"},
        {"label": "속도만 느려짐", "description": "속도"},
        {"label": "문제 없음", "description": "문제 없음"}
      ],
      "multiSelect": false
    },
    {
      "question": "Q3. Multi-pass — Pass 1과 Pass 2 책임 분리?",
      "header": "Quiz 4-6-C",
      "options": [
        {"label": "Pass 1: 파일별 local 이슈 / Pass 2: cross-file integration", "description": "정답"},
        {"label": "Pass 1: critical / Pass 2: minor", "description": "심각도"},
        {"label": "Pass 1: 보안 / Pass 2: 성능", "description": "도메인"},
        {"label": "Pass 1: 작성 / Pass 2: 수정", "description": "작성/수정"}
      ],
      "multiSelect": false
    }
  ]
})
```

### 정답 & 해설

- **Q1: A** — Sample Q 12 정답. 사용자 부담 전가도, 더 큰 모델도 attention 품질 해결 못 함.
- **Q2: A** — Self-bias 회피. 별도 인스턴스가 코드만 보고 리뷰.
- **Q3: A** — local pass는 파일 단위 정밀, integration pass는 dependency·계약.

### 다음 블록

```json
AskUserQuestion({
  "questions": [{
    "question": "다음 블록?",
    "header": "Block 4 종료",
    "options": [
      {"label": "D4 종합 정리", "description": "6블록 관계도 + Sample Q 매핑"},
      {"label": "D5로 이동", "description": "Context Management & Reliability"},
      {"label": "잠시 멈춤", "description": "끊기"}
    ],
    "multiSelect": false
  }]
})
```
