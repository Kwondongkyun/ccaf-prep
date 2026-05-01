---
name: learn-quiz
description: CCA-F 종합 모의고사 — 가중치 분포(D1=27%, D2=18%, D3=20%, D4=20%, D5=15%)에 맞춘 60문항 시뮬레이션. 짧은 5/15/30/60 문항 모드 지원. "learn-quiz", "모의고사", "퀴즈" 요청에 사용.
---

# CCA-F 종합 모의고사

5개 도메인 학습 + learn-meta 후 사용. 가중치 분포에 맞춰 출제.

---

## 모드 선택

```
[1] Quick 5    — 5문항 / 약 10분 (도메인 빠른 확인)
[2] Mini 15    — 15문항 / 약 30분 (집중 점검)
[3] Half 30    — 30문항 / 약 60분 (실전 절반)
[4] Full 60    — 60문항 / 약 120분 (실전 풀 시뮬)
```

**가중치 (Full 60 기준):**
- D1: 16문항 (27%)
- D2: 11문항 (18%)
- D3: 12문항 (20%)
- D4: 12문항 (20%)
- D5: 9문항 (15%)

---

## 진행 프로토콜

### 1) 출제

**5문항씩 묶어서 AskUserQuestion으로 제출.**
- 한 번에 5개 보기 형식 카드
- 사용자가 답 선택
- 다음 5문항 출제

**전체 출제 끝까지 절대 정답 공개 X.**

### 2) 채점

모든 문항 완료 후:
```
[종합 결과]
  점수: NN / 60 (NN%)
  도메인별:
    D1: NN/16
    D2: NN/11
    D3: NN/12
    D4: NN/12
    D5: NN/9
  
[합격선] 720/1000 (72%) — 환산 점수 표기
```

### 3) 오답 풀이

오답만 골라 함정·정답 방향·해설 제공.

### 4) 재시도

같은 모드 다른 문항 / 다른 모드 / 약한 도메인 집중 옵션.

---

## References

| 파일 | 내용 |
|-----|------|
| `references/bank-d1.md` | D1 문항 풀 (~30) |
| `references/bank-d2.md` | D2 문항 풀 (~20) |
| `references/bank-d3.md` | D3 문항 풀 (~25) |
| `references/bank-d4.md` | D4 문항 풀 (~25) |
| `references/bank-d5.md` | D5 문항 풀 (~20) |

→ 각 모드는 가중치 비율로 무작위 추출.

---

## 출제 원칙

각 문항은 다음 형식:

```
{
  "question": "[D{N}] 시나리오/상황 한 줄",
  "header": "QN",
  "options": [
    {"label": "정답 — 결정적/구조화/programmatic 키워드", "description": "..."},
    {"label": "함정1 — 프롬프트 강조", "description": "..."},
    {"label": "함정2 — 매번 사용자", "description": "..."},
    {"label": "함정3 — '더 자세히' 류", "description": "..."}
  ],
  "multiSelect": false
}
```

→ learn-meta/strategy.md의 함정 보기 패턴 따름.

---

## 시작

```json
AskUserQuestion({
  "questions": [{
    "question": "어느 모드?",
    "header": "퀴즈 모드",
    "options": [
      {"label": "Quick 5", "description": "10분 — 빠른 확인"},
      {"label": "Mini 15", "description": "30분 — 집중 점검"},
      {"label": "Half 30", "description": "60분 — 실전 절반"},
      {"label": "Full 60", "description": "120분 — 실전 풀 시뮬"}
    ],
    "multiSelect": false
  }]
})
```

→ 모드 선택 후 가중치 비율로 무작위 추출 → 5개씩 출제 → 끝까지 채점 보류.
