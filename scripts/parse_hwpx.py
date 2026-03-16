#!/usr/bin/env python3
"""
HWPX 기출문제 파서

HWPX(ZIP 내 OWPML XML) 파일에서 기출문제 텍스트를 추출하고
bulk-import API 호환 JSON으로 변환한다.

사용법:
  # 단일 파일
  python parse_hwpx.py input.hwpx --subject-cd 1001 --output output.json

  # 디렉토리 일괄
  python parse_hwpx.py input_dir/ --output-dir output_dir/

  # 과목명으로 지정 (subject_mapping.json 사용)
  python parse_hwpx.py input.hwpx --subject-name 국어 --output output.json
"""

import argparse
import json
import os
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path


# 과목 매핑 로드
SCRIPT_DIR = Path(__file__).parent
SUBJECT_MAPPING_PATH = SCRIPT_DIR / "subject_mapping.json"

# 원문자 상수
CIRCLED_DIGITS = {
    "①": 1, "②": 2, "③": 3, "④": 4, "⑤": 5,
    "⑥": 6, "⑦": 7, "⑧": 8, "⑨": 9, "⑩": 10,
}

# 원문자 정규식 패턴
CIRCLED_PATTERN = re.compile(r"([①②③④⑤⑥⑦⑧⑨⑩])")

# 문제 번호 패턴: "문 1." 또는 "문1." 또는 단순 "1." (줄 시작)
QUESTION_NUM_PATTERN = re.compile(
    r"(?:^|\n)\s*(?:문\s*)?(\d{1,2})\s*\.\s*",
    re.MULTILINE,
)


def load_subject_mapping() -> dict:
    """과목명→subject_cd 매핑 로드"""
    if SUBJECT_MAPPING_PATH.exists():
        with open(SUBJECT_MAPPING_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def extract_text_from_hwpx(hwpx_path: str) -> str:
    """HWPX 파일에서 전체 텍스트를 추출한다."""
    with zipfile.ZipFile(hwpx_path, "r") as zf:
        # section 파일 찾기 (Contents/section0.xml, section1.xml, ...)
        section_files = sorted(
            [n for n in zf.namelist() if re.match(r"Contents/section\d+\.xml", n)]
        )
        if not section_files:
            # 대체 경로 시도
            section_files = sorted(
                [n for n in zf.namelist() if "section" in n.lower() and n.endswith(".xml")]
            )

        if not section_files:
            raise ValueError(
                f"HWPX에서 section XML을 찾을 수 없습니다. "
                f"파일 목록: {zf.namelist()}"
            )

        all_text_parts = []
        for section_file in section_files:
            xml_content = zf.read(section_file)
            text_parts = _parse_owpml_text(xml_content)
            all_text_parts.extend(text_parts)

    return "\n".join(all_text_parts)


def _parse_owpml_text(xml_bytes: bytes) -> list[str]:
    """OWPML XML에서 텍스트를 추출한다.

    OWPML 네임스페이스를 동적으로 감지하여 <hp:t> 요소의 텍스트를 모은다.
    """
    root = ET.fromstring(xml_bytes)

    # 네임스페이스 동적 감지
    ns_map = {}
    for event, elem in ET.iterparse(
        __import__("io").BytesIO(xml_bytes), events=["start-ns"]
    ):
        prefix, uri = elem
        ns_map[prefix] = uri

    # hp 네임스페이스 찾기
    hp_ns = None
    for prefix, uri in ns_map.items():
        if "hancom" in uri.lower() or "hwpml" in uri.lower() or prefix in ("hp", ""):
            hp_ns = uri
            break

    # 텍스트 요소 수집
    text_parts = []
    paragraph_texts = []

    if hp_ns:
        # 네임스페이스가 있는 경우
        for elem in root.iter():
            tag = elem.tag
            # {namespace}localname 형식에서 localname 추출
            local_name = tag.split("}")[-1] if "}" in tag else tag

            if local_name == "t" and elem.text:
                paragraph_texts.append(elem.text)
            elif local_name == "p":
                # 단락 경계 - 현재 모은 텍스트를 합침
                if paragraph_texts:
                    text_parts.append("".join(paragraph_texts))
                    paragraph_texts = []
    else:
        # 네임스페이스 없는 경우 - 모든 't' 태그
        for elem in root.iter():
            tag = elem.tag.split("}")[-1] if "}" in elem.tag else elem.tag
            if tag == "t" and elem.text:
                paragraph_texts.append(elem.text)
            elif tag == "p":
                if paragraph_texts:
                    text_parts.append("".join(paragraph_texts))
                    paragraph_texts = []

    # 남은 텍스트 처리
    if paragraph_texts:
        text_parts.append("".join(paragraph_texts))

    return text_parts


def parse_questions(full_text: str) -> list[dict]:
    """전체 텍스트에서 문제를 구조화하여 파싱한다.

    Returns:
        문제 딕셔너리 리스트. 각 딕셔너리는 questionNo, questionText,
        choice1~choice5, correctAns 필드를 포함한다.
    """
    # 문제 번호 위치 찾기
    matches = list(QUESTION_NUM_PATTERN.finditer(full_text))
    if not matches:
        print("[WARN] 문제 번호 패턴을 찾을 수 없습니다.", file=sys.stderr)
        return []

    questions = []
    for i, match in enumerate(matches):
        question_no = int(match.group(1))

        # 문제 텍스트 범위: 현재 매치 끝 ~ 다음 문제 시작 (또는 문서 끝)
        start = match.end()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(full_text)
        block = full_text[start:end].strip()

        # 선택지 파싱
        question_text, choices = _parse_choices(block)

        question = {
            "questionNo": question_no,
            "questionText": question_text.strip(),
            "choice1": choices.get(1, ""),
            "choice2": choices.get(2, ""),
            "choice3": choices.get(3, ""),
            "choice4": choices.get(4, ""),
            "choice5": choices.get(5, ""),
            "correctAns": "",
            "questionType": "CHOICE",
            "isUse": "Y",
        }
        questions.append(question)

    return questions


def _parse_choices(block: str) -> tuple[str, dict[int, str]]:
    """문제 블록에서 본문과 선택지를 분리한다.

    Returns:
        (문제본문, {1: "선택지1", 2: "선택지2", ...})
    """
    # 원문자 위치 찾기
    circled_matches = list(CIRCLED_PATTERN.finditer(block))
    if not circled_matches:
        return block, {}

    # 첫 번째 원문자 위치 → 그 앞이 문제 본문
    question_text = block[: circled_matches[0].start()].strip()

    # 선택지 추출
    choices = {}
    for j, cm in enumerate(circled_matches):
        digit = CIRCLED_DIGITS[cm.group(1)]
        choice_start = cm.end()
        choice_end = (
            circled_matches[j + 1].start()
            if j + 1 < len(circled_matches)
            else len(block)
        )
        choice_text = block[choice_start:choice_end].strip()
        choices[digit] = choice_text

    return question_text, choices


def build_output(
    questions: list[dict],
    subject_cd: str,
    subject_nm: str = "",
    exam_year: str = "",
    exam_round: int = 1,
    category: str = "9LEVEL",
    source: str = "ACTUAL",
) -> dict:
    """파싱된 문제를 bulk-import API 호환 JSON으로 변환한다."""
    for q in questions:
        q["subjectCd"] = subject_cd

    return {
        "metadata": {
            "examYear": exam_year,
            "examRound": exam_round,
            "category": category,
            "source": source,
            "subjectCd": subject_cd,
            "subjectNm": subject_nm,
        },
        "items": questions,
    }


def process_single_file(
    hwpx_path: str,
    subject_cd: str,
    subject_nm: str = "",
    output_path: str | None = None,
    exam_year: str = "",
    exam_round: int = 1,
    category: str = "9LEVEL",
    source: str = "ACTUAL",
) -> dict:
    """단일 HWPX 파일을 처리한다."""
    print(f"[INFO] 파싱 중: {hwpx_path}")

    full_text = extract_text_from_hwpx(hwpx_path)
    print(f"[INFO] 추출된 텍스트 길이: {len(full_text)} chars")

    questions = parse_questions(full_text)
    print(f"[INFO] 파싱된 문제 수: {len(questions)}")

    result = build_output(
        questions,
        subject_cd=subject_cd,
        subject_nm=subject_nm,
        exam_year=exam_year,
        exam_round=exam_round,
        category=category,
        source=source,
    )

    if output_path:
        os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        print(f"[INFO] 출력 파일: {output_path}")

    return result


def process_directory(
    input_dir: str,
    output_dir: str,
    subject_cd: str | None = None,
    subject_nm: str = "",
    exam_year: str = "",
    exam_round: int = 1,
    category: str = "9LEVEL",
    source: str = "ACTUAL",
) -> list[dict]:
    """디렉토리 내 모든 HWPX 파일을 일괄 처리한다."""
    input_path = Path(input_dir)
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    hwpx_files = sorted(input_path.glob("*.hwpx"))
    if not hwpx_files:
        print(f"[WARN] {input_dir}에서 HWPX 파일을 찾을 수 없습니다.", file=sys.stderr)
        return []

    subject_mapping = load_subject_mapping()
    results = []

    for hwpx_file in hwpx_files:
        # 과목코드 결정: CLI 인자 > 파일명에서 추론
        sc = subject_cd
        sn = subject_nm

        if not sc:
            # 파일명에서 과목명 추론 시도
            stem = hwpx_file.stem
            for name, code in subject_mapping.items():
                if name in stem:
                    sc = code
                    sn = name
                    break

        if not sc:
            print(
                f"[WARN] {hwpx_file.name}의 과목코드를 결정할 수 없습니다. --subject-cd를 지정하세요.",
                file=sys.stderr,
            )
            continue

        out_file = output_path / f"{hwpx_file.stem}.json"
        result = process_single_file(
            str(hwpx_file),
            subject_cd=sc,
            subject_nm=sn,
            output_path=str(out_file),
            exam_year=exam_year,
            exam_round=exam_round,
            category=category,
            source=source,
        )
        results.append(result)

    return results


def main():
    parser = argparse.ArgumentParser(
        description="HWPX 기출문제 파서 - HWPX에서 문제를 추출하여 JSON으로 변환"
    )
    parser.add_argument("input", help="HWPX 파일 경로 또는 디렉토리 경로")
    parser.add_argument("--subject-cd", help="과목코드 (예: 1001)")
    parser.add_argument("--subject-name", help="과목명 (subject_mapping.json에서 코드 조회)")
    parser.add_argument("--output", "-o", help="출력 JSON 파일 경로 (단일 파일 모드)")
    parser.add_argument("--output-dir", help="출력 디렉토리 (디렉토리 모드)")
    parser.add_argument("--exam-year", default="", help="출제 연도 (예: 2024)")
    parser.add_argument("--exam-round", type=int, default=1, help="회차 (기본: 1)")
    parser.add_argument("--category", default="9LEVEL", help="시험 유형 (기본: 9LEVEL)")
    parser.add_argument("--source", default="ACTUAL", help="출처 (기본: ACTUAL)")

    args = parser.parse_args()

    # 과목코드 결정
    subject_mapping = load_subject_mapping()
    subject_cd = args.subject_cd
    subject_nm = args.subject_name or ""

    if args.subject_name and not subject_cd:
        subject_cd = subject_mapping.get(args.subject_name)
        if not subject_cd:
            print(
                f"[ERROR] 과목명 '{args.subject_name}'을 subject_mapping.json에서 찾을 수 없습니다.",
                file=sys.stderr,
            )
            sys.exit(1)
        subject_nm = args.subject_name

    input_path = Path(args.input)

    if input_path.is_dir():
        # 디렉토리 모드
        output_dir = args.output_dir or str(input_path / "output")
        results = process_directory(
            str(input_path),
            output_dir,
            subject_cd=subject_cd,
            subject_nm=subject_nm,
            exam_year=args.exam_year,
            exam_round=args.exam_round,
            category=args.category,
            source=args.source,
        )
        total = sum(len(r["items"]) for r in results)
        print(f"\n[DONE] {len(results)}개 파일 처리 완료, 총 {total}문제 추출")
    else:
        # 단일 파일 모드
        if not subject_cd:
            # 파일명에서 추론 시도
            for name, code in subject_mapping.items():
                if name in input_path.stem:
                    subject_cd = code
                    subject_nm = name
                    break

        if not subject_cd:
            print(
                "[ERROR] --subject-cd 또는 --subject-name을 지정하세요.",
                file=sys.stderr,
            )
            sys.exit(1)

        output = args.output or str(input_path.with_suffix(".json"))
        result = process_single_file(
            str(input_path),
            subject_cd=subject_cd,
            subject_nm=subject_nm,
            output_path=output,
            exam_year=args.exam_year,
            exam_round=args.exam_round,
            category=args.category,
            source=args.source,
        )
        print(f"\n[DONE] {len(result['items'])}문제 추출 완료")


if __name__ == "__main__":
    main()
