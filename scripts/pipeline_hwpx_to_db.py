#!/usr/bin/env python3
"""
HWPX → DB 통합 파이프라인

HWPX 파싱 → 정답 병합 → DB 임포트를 순차 실행한다.

사용법:
  # HWPX + 정답 PDF → DB
  python pipeline_hwpx_to_db.py \
    --hwpx data/hwpx/2024_9level_korean.hwpx \
    --answer-pdf data/answers/2024_9level_answer.pdf \
    --subject-cd 1001 --exam-year 2024 --exam-round 1 \
    --category 9LEVEL --api-url http://localhost:8080

  # HWPX + 수동 정답 JSON → DB
  python pipeline_hwpx_to_db.py \
    --hwpx data/hwpx/2024_9level_korean.hwpx \
    --answer-json data/answers/korean_answers.json \
    --subject-cd 1001 --exam-year 2024 --exam-round 1 \
    --category 9LEVEL --api-url http://localhost:8080

  # HWPX만 파싱 (DB 임포트 없이 JSON 출력)
  python pipeline_hwpx_to_db.py \
    --hwpx data/hwpx/2024_9level_korean.hwpx \
    --subject-cd 1001 --exam-year 2024 \
    --no-import --output data/output/result.json
"""

import argparse
import json
import os
import sys
import tempfile
from pathlib import Path

# 같은 디렉토리의 모듈 임포트
sys.path.insert(0, str(Path(__file__).parent))

from parse_hwpx import process_single_file as parse_hwpx
from merge_answers import merge_answers


def run_pipeline(args: argparse.Namespace) -> None:
    """파이프라인 전체 실행."""
    print("=" * 60)
    print("  HWPX → DB 통합 파이프라인")
    print("=" * 60)

    # === 단계 1: HWPX 파싱 ===
    print("\n[STEP 1/3] HWPX 파싱")
    print("-" * 40)

    # 중간 파일 경로
    temp_dir = tempfile.mkdtemp(prefix="hwpx_pipeline_")
    questions_json_path = os.path.join(temp_dir, "questions.json")

    questions_data = parse_hwpx(
        hwpx_path=args.hwpx,
        subject_cd=args.subject_cd,
        subject_nm=args.subject_name or "",
        output_path=questions_json_path,
        exam_year=args.exam_year or "",
        exam_round=args.exam_round,
        category=args.category,
        source=args.source,
    )

    item_count = len(questions_data.get("items", []))
    if item_count == 0:
        print("[ERROR] 파싱된 문제가 없습니다. 파이프라인을 중단합니다.")
        sys.exit(1)

    # === 단계 2: 정답 병합 ===
    print("\n[STEP 2/3] 정답 병합")
    print("-" * 40)

    answers_data = None

    if args.answer_pdf:
        # PDF에서 정답 추출
        try:
            from parse_answer_pdf import parse_answer_pdf

            answers = parse_answer_pdf(args.answer_pdf)
            answers_data = {"answers": answers}
        except ImportError:
            print(
                "[ERROR] pdfplumber가 필요합니다: pip install pdfplumber",
                file=sys.stderr,
            )
            sys.exit(1)
    elif args.answer_json:
        # 수동 정답 JSON 로드
        with open(args.answer_json, "r", encoding="utf-8") as f:
            answers_data = json.load(f)
    else:
        print("[INFO] 정답 소스가 지정되지 않았습니다. 정답 없이 진행합니다.")

    merged_data = questions_data
    if answers_data:
        merged_data, errors = merge_answers(questions_data, answers_data)
        if errors:
            print(f"[WARN] 병합 경고 {len(errors)}건:")
            for err in errors[:10]:
                print(f"  - {err}")
            if len(errors) > 10:
                print(f"  ... 외 {len(errors) - 10}건")

    # 결과 저장
    output_path = args.output
    if not output_path:
        stem = Path(args.hwpx).stem
        output_dir = Path(args.hwpx).parent / "output"
        output_dir.mkdir(parents=True, exist_ok=True)
        output_path = str(output_dir / f"{stem}_merged.json")

    os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(merged_data, f, ensure_ascii=False, indent=2)
    print(f"[INFO] 병합 결과 저장: {output_path}")

    # === 단계 3: DB 임포트 ===
    if args.no_import:
        print("\n[SKIP] --no-import 플래그로 DB 임포트 생략")
        print(f"\n[DONE] 파싱/병합 완료: {item_count}문항 → {output_path}")
        return

    print("\n[STEP 3/3] DB 임포트")
    print("-" * 40)

    from import_questions import process_file

    headers = {"Content-Type": "application/json"}
    if args.api_key:
        headers["X-Api-Key"] = args.api_key

    success, fail = process_file(output_path, args.api_url, headers)

    # === 최종 결과 ===
    print("\n" + "=" * 60)
    print(f"  파이프라인 완료")
    print(f"  - 파싱 문항: {item_count}")
    print(f"  - DB 등록 성공: {success}")
    print(f"  - DB 등록 실패: {fail}")
    print(f"  - 결과 JSON: {output_path}")
    print("=" * 60)

    # 임시 파일 정리
    try:
        os.remove(questions_json_path)
        os.rmdir(temp_dir)
    except OSError:
        pass


def main():
    parser = argparse.ArgumentParser(
        description="HWPX → DB 통합 파이프라인"
    )

    # 입력
    parser.add_argument("--hwpx", required=True, help="HWPX 파일 경로")
    parser.add_argument("--answer-pdf", help="정답표 PDF 파일 경로")
    parser.add_argument("--answer-json", help="정답 JSON 파일 경로 (PDF 대안)")

    # 메타데이터
    parser.add_argument("--subject-cd", required=True, help="과목코드 (예: 1001)")
    parser.add_argument("--subject-name", help="과목명 (예: 국어)")
    parser.add_argument("--exam-year", help="출제연도 (예: 2024)")
    parser.add_argument("--exam-round", type=int, default=1, help="회차 (기본: 1)")
    parser.add_argument("--category", default="9LEVEL", help="시험유형 (기본: 9LEVEL)")
    parser.add_argument("--source", default="ACTUAL", help="출처 (기본: ACTUAL)")

    # 출력
    parser.add_argument("--output", "-o", help="병합 결과 JSON 출력 경로")

    # API
    parser.add_argument(
        "--api-url",
        default="http://localhost:8080",
        help="API 서버 URL (기본: http://localhost:8080)",
    )
    parser.add_argument("--api-key", default="", help="X-Api-Key 헤더 값")
    parser.add_argument(
        "--no-import",
        action="store_true",
        help="DB 임포트 생략 (파싱/병합만 수행)",
    )

    args = parser.parse_args()

    if not Path(args.hwpx).exists():
        print(f"[ERROR] HWPX 파일을 찾을 수 없습니다: {args.hwpx}", file=sys.stderr)
        sys.exit(1)

    if args.answer_pdf and not Path(args.answer_pdf).exists():
        print(f"[ERROR] 정답 PDF를 찾을 수 없습니다: {args.answer_pdf}", file=sys.stderr)
        sys.exit(1)

    if args.answer_json and not Path(args.answer_json).exists():
        print(f"[ERROR] 정답 JSON을 찾을 수 없습니다: {args.answer_json}", file=sys.stderr)
        sys.exit(1)

    run_pipeline(args)


if __name__ == "__main__":
    main()
