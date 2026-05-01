# D4 문항 풀 — Prompt Engineering & Structured Output (20%)

> 6 Tasks: 4.1 Explicit Criteria / 4.2 Few-shot / 4.3 JSON Schema via tool_use / 4.4 Validation-Retry / 4.5 Batches / 4.6 Multi-pass Review

---

## D4-Q01
"이 PR 잘 리뷰해줘" — vague. 가장 효과적 개선?
- A) Explicit criteria 5개 + 출력 JSON 형식 명시
- B) 더 큰 모델
- C) 온도 낮춤
- D) 사용자 매번 검수
**Answer: A** | F-D4-1.

---

## D4-Q02
다양한 형식의 입력에서 동일 구조 추출이 일관성 X. 가장 효과적?
- A) Few-shot 2-3개 (입력→출력 페어)
- B) Description만 더 길게
- C) 더 큰 모델
- D) 무시
**Answer: A** | F-D4-2.

---

## D4-Q03
Anthropic API에서 강제된 JSON 출력?
- A) `tool_use` + `tool_choice: {type: "tool", name: X}`
- B) JSON mode flag
- C) Pydantic만으로
- D) 프롬프트에 "JSON으로"만
**Answer: A** | F-D4-3.

---

## D4-Q04
Optional 필드를 빈 문자열로 채우면?
- A) Hallucination 위험. `nullable: true` + null로 받기
- B) 빈 string이 안전
- C) 0으로 채움
- D) 필드 자체를 제거
**Answer: A** | F-D4-3.

---

## D4-Q05
Pydantic ValidationError 발생. 가장 효과적?
- A) 에러 메시지를 다음 프롬프트에 주입 + max retries
- B) 무한 retry
- C) 사용자에게 raw 에러 표시
- D) 빈 응답으로 fallback
**Answer: A** | F-D4-4.

---

## D4-Q06
Pre-merge PR 리뷰는 즉시 응답 필요. 야간 regression 분석. 모두 Batches?
- A) Pre-merge는 standard, 야간 regression만 Batches
- B) 모두 Batches로 비용 절감
- C) 모두 standard
- D) Pre-merge에서 Batches 폴링
**Answer: A** | F-D4-5 | Sample Q 11.

---

## D4-Q07
Batches API 특징?
- A) 24h SLA, 50% cost, custom_id로 결과 매칭
- B) 즉시 응답, full cost
- C) WebSocket 스트리밍
- D) Foreground only
**Answer: A** | Task 4.5.

---

## D4-Q08
14파일 변경 큰 PR을 한 번에 리뷰 → 일관성↓. 가장 효과적?
- A) File-by-file pass + integration pass
- B) 14파일 한 번에 더 큰 컨텍스트
- C) 사용자 직접 분할
- D) Subagent 14개 동시 (결과 통합 없이)
**Answer: A** | F-D4-6 | Sample Q 12.

---

## D4-Q09
도구 input_schema에 enum 활용?
- A) 분류 카테고리를 enum으로 강제 — 자유 텍스트 X
- B) 모든 필드 string
- C) Optional만 enum
- D) Enum 사용 금지
**Answer: A** | Task 4.3.

---

## D4-Q10
Few-shot이 가장 효과적인 케이스?
- A) Ambiguous 입력 / 형식 변환 / boundary 학습
- B) 단순 instruction following
- C) Long context summarization
- D) 모든 케이스
**Answer: A** | F-D4-2.

---

## D4-Q11
Validation retry 시 max retry 미설정의 위험?
- A) 무한 루프 → 비용·latency 폭주
- B) 더 정확한 결과
- C) 자동 종료
- D) 위험 없음
**Answer: A** | F-D4-4.

---

## D4-Q12
Multi-instance review의 핵심 가치?
- A) 자기 자신 리뷰의 self-bias 제거 (독립 인스턴스)
- B) 비용 절감
- C) 속도 ↑
- D) 토큰 절감
**Answer: A** | Task 4.6.
