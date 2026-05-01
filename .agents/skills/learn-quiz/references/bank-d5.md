# D5 문항 풀 — Context Management & Reliability (15%)

> 6 Tasks: 5.1 Conversation Context / 5.2 Escalation / 5.3 Error Propagation / 5.4 Large Codebase / 5.5 HITL & Confidence / 5.6 Provenance

---

## D5-Q01
Customer Support agent가 5 turn 후 환불 금액·날짜를 vague하게 답변. 가장 효과적?
- A) case_facts (order_id, amount, date)를 매 turn 명시·재주입
- B) 더 큰 모델
- C) Progressive summarization 강화
- D) 사용자 매번 다시 알려주기
**Answer: A** | F-D5-1.

---

## D5-Q02
Customer Support agent의 escalation 정확도 80%. 가장 효과적?
- A) Explicit escalation criteria + few-shot (정책 갭/명시 요청/진전 불가)
- B) Sentiment analysis 추가
- C) 더 큰 모델
- D) Self-confidence threshold만
**Answer: A** | F-D5-2 | Sample Q 3.

---

## D5-Q03
Subagent가 internal docs search timeout. 가장 효과적 처리?
- A) Structured error context (failure_type, attempted, partial, alternatives) → coordinator partial 합성 + 한계 명시
- B) Subagent 무한 retry
- C) Coordinator가 silent fallback
- D) 결과 없음으로 통합
**Answer: A** | F-D5-3 | Sample Q 8.

---

## D5-Q04
Repo wide grep 1000줄 결과. 부모 vs subagent?
- A) Subagent 격리, 부모는 요약 5줄만 수령
- B) 부모에서 직접
- C) 사용자 grep 후 입력
- D) /compact 후 다시 grep
**Answer: A** | F-D5-4.

---

## D5-Q05
50 turn 작업 도중 세션 크래시. 가장 효율적 복구?
- A) Manifest 읽기 → 상태·결정 복원 → 재개
- B) 처음부터 다시
- C) Raw 로그 그대로
- D) 작업 포기
**Answer: A** | F-D5-4.

---

## D5-Q06
Extraction 시스템 overall 97% accuracy. 자동화?
- A) Per doc type / per field 분해 — 특정 type 60%면 그 type만 HITL
- B) 97% 충분 — 전체 자동
- C) 그대로
- D) 더 큰 모델
**Answer: A** | F-D5-5.

---

## D5-Q07
HITL 적용 기준?
- A) Irreversible / Legal / PII / Large $ / Low confidence
- B) 모든 결정
- C) 랜덤 샘플
- D) 사용자 요청 시만
**Answer: A** | F-D5-5.

---

## D5-Q08
Eval set 샘플링. 가장 신뢰성?
- A) Stratified random — 카테고리 비례 + edge over-sample
- B) Production log 첫 1000건
- C) High-confidence 기록의 first N
- D) 단순 random 1000건
**Answer: A** | F-D5-5.

---

## D5-Q09
Multi-source 합성에서 credible source 2개가 다른 통계?
- A) 양쪽 모두 보존 + 각각 source 명시 (annotate)
- B) 더 신뢰 가는 한쪽 선택
- C) 평균값
- D) 최신 데이터로 통일
**Answer: A** | F-D5-6.

---

## D5-Q10
Subagent에 어떤 출력 schema 강제?
- A) {claim, source_url, source_name, excerpt, publication_date}
- B) Free prose narrative
- C) Bullet list만
- D) JSON without dates
**Answer: A** | F-D5-6.

---

## D5-Q11
Synthesis 출력에서 음악·문학 누락. 어떻게 표기?
- A) Well-supported vs Coverage gap 섹션 분리, gap 명시
- B) "모든 분야 커버" 합리화
- C) 조용히 누락
- D) 재실행만 요청
**Answer: A** | F-D5-6.

---

## D5-Q12
get_customer가 47필드 반환. 5개만 관련. 가장 효과적?
- A) 응답 직후 5필드만 추출해 case_facts 저장, raw 47필드 trim
- B) 47필드 그대로 누적
- C) 도구 호출 빈도 줄이기
- D) 필드 이름만 보존
**Answer: A** | F-D5-1.
