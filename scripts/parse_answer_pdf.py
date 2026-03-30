#!/usr/bin/env python3
"""
정답표 PDF 파서

PDF 형식의 정답표에서 문제번호-정답 쌍을 추출하여 JSON으로 변환한다.

사용법:
  python parse_answer_pdf.py answer.pdf --output answers.json
  python parse_answer_pdf.py answer.pdf --subject-name 국어 --output answers.json
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path

try:
    import pdfplumber
except ImportError:
    print(
        "[ERROR] pdfplumber가 설치되지 않았습니다.\n"
        "  pip install pdfplumber",
        file=sys.stderr,
    )
    sys.exit(1)


# 번호-정답 패턴 (예: "1  3", "2  1", "1 ③")
NUM_ANS_PATTERN = re.compile(r"(\d{1,2})\s+(\d{1,2})")

# 원문자→숫자 매핑
CIRCLED_TO_NUM = {
    "①": "1", "②": "2", "③": "3", "④": "4", "⑤": "5",
    "⑥": "6", "⑦": "7", "⑧": "8", "⑨": "9", "⑩": "10",
}
CIRCLED_PATTERN = re.compile(r"(\d{1,2})\s*([①②③④⑤⑥⑦⑧⑨⑩])")


def parse_answer_from_table(pdf_path: str) -> dict[str, str]:
    """PDF 테이블에서 정답을 추출한다."""
    answers = {}

    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            tables = page.extract_tables()
            for table in tables:
                for row in table:
                    if not row:
                        continue
                    # 각 셀에서 번호-정답 쌍 추출
                    cells = [c.strip() if c else "" for c in row]
                    # 보통 테이블은 [번호, 정답, 번호, 정답, ...] 형태
                    for i in range(0, len(cells) - 1, 2):
                        num_str = cells[i]
                        ans_str = cells[i + 1]
                        if num_str and ans_str and num_str.isdigit():
                            # 원문자 변환
                            ans = CIRCLED_TO_NUM.get(ans_str.strip(), ans_str.strip())
                            if ans.isdigit():
                                answers[num_str] = ans

    return answers


def parse_answer_from_text(pdf_path: str) -> dict[str, str]:
    """PDF 텍스트에서 정답을 추출한다 (테이블 실패 시 fallback)."""
    answers = {}

    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            text = page.extract_text() or ""

            # 원문자 패턴 먼저 시도
            for match in CIRCLED_PATTERN.finditer(text):
                num = match.group(1)
                ans = CIRCLED_TO_NUM.get(match.group(2), match.group(2))
                answers[num] = ans

            # 숫자-숫자 패턴
            for match in NUM_ANS_PATTERN.finditer(text):
                num = match.group(1)
                ans = match.group(2)
                # 이미 원문자로 추출된 건 덮어쓰지 않음
                if num not in answers and int(ans) <= 5:
                    answers[num] = ans

    return answers


def parse_answer_pdf(pdf_path: str) -> dict[str, str]:
    """정답표 PDF를 파싱하여 {문제번호: 정답} 딕셔너리를 반환한다.

    1. 테이블 추출 시도
    2. 실패 시 텍스트 모드 fallback
    """
    # 테이블 모드 시도
    answers = parse_answer_from_table(pdf_path)
    if len(answers) >= 5:
        print(f"[INFO] 테이블 모드로 {len(answers)}개 정답 추출")
        return answers

    # 텍스트 모드 fallback
    print("[INFO] 테이블 추출 부족, 텍스트 모드 시도 중...")
    answers = parse_answer_from_text(pdf_path)
    print(f"[INFO] 텍스트 모드로 {len(answers)}개 정답 추출")
    return answers


def main():
    parser = argparse.ArgumentParser(
        description="정답표 PDF 파서 - PDF에서 문제번호-정답 쌍을 추출"
    )
    parser.add_argument("input", help="정답표 PDF 파일 경로")
    parser.add_argument("--output", "-o", help="출력 JSON 파일 경로")
    parser.add_argument("--subject-name", help="과목명 (메타데이터용)")

    args = parser.parse_args()

    if not Path(args.input).exists():
        print(f"[ERROR] 파일을 찾을 수 없습니다: {args.input}", file=sys.stderr)
        sys.exit(1)

    answers = parse_answer_pdf(args.input)

    if not answers:
        print("[WARN] 추출된 정답이 없습니다.", file=sys.stderr)

    # 정렬된 결과 생성
    sorted_answers = dict(sorted(answers.items(), key=lambda x: int(x[0])))

    result = {
        "subjectName": args.subject_name or "",
        "source": args.input,
        "totalCount": len(sorted_answers),
        "answers": sorted_answers,
    }

    output = args.output or str(Path(args.input).with_suffix(".answers.json"))
    os.makedirs(os.path.dirname(output) or ".", exist_ok=True)
    with open(output, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    print(f"\n[DONE] {len(sorted_answers)}개 정답 추출 → {output}")

    # 정답 미리보기
    for num, ans in list(sorted_answers.items())[:5]:
        print(f"  {num}번: {ans}")
    if len(sorted_answers) > 5:
        print(f"  ... 외 {len(sorted_answers) - 5}건")


if __name__ == "__main__":
    main()
