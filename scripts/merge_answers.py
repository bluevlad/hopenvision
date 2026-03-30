#!/usr/bin/env python3
"""
문제 + 정답 머지 유틸리티

parse_hwpx.py의 문제 JSON과 parse_answer_pdf.py의 정답 JSON을 병합한다.

사용법:
  python merge_answers.py questions.json answers.json --output merged.json

  # 정답 JSON 대신 수동 입력 템플릿 사용
  python merge_answers.py questions.json answers_manual.json --output merged.json
"""

import argparse
import json
import os
import sys
from pathlib import Path


def merge_answers(
    questions_data: dict,
    answers_data: dict,
) -> tuple[dict, list[str]]:
    """문제 JSON에 정답을 병합한다.

    Args:
        questions_data: parse_hwpx.py 출력 (metadata + items)
        answers_data: parse_answer_pdf.py 출력 또는 수동 정답 (answers 딕셔너리)

    Returns:
        (병합된 데이터, 에러 리스트)
    """
    answers = answers_data.get("answers", {})
    items = questions_data.get("items", [])
    errors = []

    matched = 0
    unmatched = 0

    for item in items:
        q_no = str(item.get("questionNo", ""))
        if q_no in answers:
            item["correctAns"] = str(answers[q_no])
            matched += 1
        else:
            unmatched += 1
            errors.append(f"문제 {q_no}번: 정답을 찾을 수 없음")

    # 정답 JSON에 있지만 문제에 없는 번호 체크
    question_nos = {str(item.get("questionNo", "")) for item in items}
    for ans_no in answers:
        if ans_no not in question_nos:
            errors.append(f"정답 {ans_no}번: 대응하는 문제 없음")

    print(f"[INFO] 매칭 완료: {matched}건 성공, {unmatched}건 미매칭")

    return questions_data, errors


def main():
    parser = argparse.ArgumentParser(
        description="문제 + 정답 머지 - 문제 JSON에 정답을 채워 넣음"
    )
    parser.add_argument("questions", help="문제 JSON 파일 (parse_hwpx.py 출력)")
    parser.add_argument("answers", help="정답 JSON 파일 (parse_answer_pdf.py 출력 또는 수동)")
    parser.add_argument("--output", "-o", help="출력 파일 경로")

    args = parser.parse_args()

    # 파일 로드
    with open(args.questions, "r", encoding="utf-8") as f:
        questions_data = json.load(f)

    with open(args.answers, "r", encoding="utf-8") as f:
        answers_data = json.load(f)

    # 병합
    merged, errors = merge_answers(questions_data, answers_data)

    # 에러 출력
    if errors:
        print(f"\n[WARN] {len(errors)}건의 경고:")
        for err in errors:
            print(f"  - {err}")

    # 저장
    output = args.output or str(
        Path(args.questions).with_stem(
            Path(args.questions).stem + "_merged"
        )
    )
    os.makedirs(os.path.dirname(output) or ".", exist_ok=True)
    with open(output, "w", encoding="utf-8") as f:
        json.dump(merged, f, ensure_ascii=False, indent=2)

    total = len(merged.get("items", []))
    with_ans = sum(1 for item in merged.get("items", []) if item.get("correctAns"))
    print(f"\n[DONE] 병합 완료: {total}문제 중 {with_ans}건 정답 있음 → {output}")


if __name__ == "__main__":
    main()
