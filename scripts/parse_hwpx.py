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

# 문제 번호 패턴: 단락 시작에서 "1." 또는 "문 1." 등
QUESTION_START_PATTERN = re.compile(r"^(?:문\s*)?(\d{1,2})\.\s*(.*)$", re.DOTALL)

# 선택지 시작 패턴: 단락 시작에서 ①②③④⑤
CHOICE_START_PATTERN = re.compile(r"^([①②③④⑤⑥⑦⑧⑨⑩])\s*(.*)", re.DOTALL)


def load_subject_mapping() -> dict:
    """과목명→subject_cd 매핑 로드"""
    if SUBJECT_MAPPING_PATH.exists():
        with open(SUBJECT_MAPPING_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def extract_paragraphs_from_hwpx(hwpx_path: str) -> list[str]:
    """HWPX 파일에서 단락별 텍스트를 추출한다.

    itertext()를 사용하여 <hp:t> 내부의 모든 텍스트
    (text + child tail 포함)를 정확하게 수집한다.
    """
    with zipfile.ZipFile(hwpx_path, "r") as zf:
        section_files = sorted(
            [n for n in zf.namelist() if re.match(r"Contents/section\d+\.xml", n)]
        )
        if not section_files:
            section_files = sorted(
                [n for n in zf.namelist() if "section" in n.lower() and n.endswith(".xml")]
            )
        if not section_files:
            raise ValueError(f"HWPX에서 section XML을 찾을 수 없습니다: {zf.namelist()}")

        all_paragraphs = []
        for section_file in section_files:
            xml_content = zf.read(section_file).decode("utf-8")
            paragraphs = _extract_paragraphs_from_xml(xml_content)
            all_paragraphs.extend(paragraphs)

    return all_paragraphs


def _extract_paragraphs_from_xml(xml_content: str) -> list[str]:
    """OWPML XML에서 단락별 텍스트를 추출한다.

    각 <hp:p> 요소에 대해 itertext()로 모든 텍스트를 수집한다.
    """
    root = ET.fromstring(xml_content)

    # hp paragraph 네임스페이스 감지
    hp_ns = None
    for m in re.finditer(r'xmlns:(\w+)="([^"]+)"', xml_content[:3000]):
        prefix, uri = m.group(1), m.group(2)
        if prefix == "hp" and "paragraph" in uri:
            hp_ns = uri
            break

    if not hp_ns:
        # fallback: hwpml을 포함하는 네임스페이스
        for m in re.finditer(r'xmlns:(\w+)="([^"]+)"', xml_content[:3000]):
            prefix, uri = m.group(1), m.group(2)
            if prefix == "hp":
                hp_ns = uri
                break

    paragraphs = []
    p_tag = f"{{{hp_ns}}}p" if hp_ns else "p"

    for p_elem in root.iter(p_tag):
        # itertext()로 모든 텍스트 수집 (text + tail 포함)
        text = "".join(p_elem.itertext()).strip()
        if text:
            # 이미지/그림 설명 태그 제거
            text = re.sub(r"그림입니다\.\s*원본 그림의 이름:.*?(?=\S{2}|$)", "", text, flags=re.DOTALL).strip()
            text = re.sub(r"문단띠로 사각형입니다\.", "", text).strip()
            if text:
                paragraphs.append(text)

    return paragraphs


def _split_multi_choice_paragraphs(paragraphs: list[str]) -> list[str]:
    """한 단락에 여러 선택지가 있는 경우 분리한다.

    예: "①currency②identification" → ["①currency", "②identification"]
    예: "③(C)－(A)－(B)④(C)－(B)－(A)" → ["③(C)－(A)－(B)", "④(C)－(B)－(A)"]
    """
    result = []
    for para in paragraphs:
        # 원문자가 2개 이상 있는 단락만 분리
        circled_positions = [(m.start(), m.group(1)) for m in CIRCLED_PATTERN.finditer(para)]
        if len(circled_positions) >= 2 and circled_positions[0][0] == 0:
            # 단락 시작이 원문자이고 여러 개 있으면 분리
            for k in range(len(circled_positions)):
                start = circled_positions[k][0]
                end = circled_positions[k + 1][0] if k + 1 < len(circled_positions) else len(para)
                part = para[start:end].strip()
                if part:
                    result.append(part)
        else:
            result.append(para)
    return result


def _filter_noise_paragraphs(paragraphs: list[str]) -> list[str]:
    """이미지 메타데이터, 헤더 등 노이즈 단락을 필터링한다."""
    result = []
    for para in paragraphs:
        # 이미지 파일 메타데이터 (예: "4.25N91│illust│영어_01.tif")
        if "│" in para and ("illust" in para or ".tif" in para or ".png" in para):
            continue
        # 시험지 헤더
        if re.match(r"^\d{4}년도\s*국가공무원", para):
            continue
        if re.match(r"^[가-힣]\s{2,}[가-힣]$", para):  # "국    어"
            continue
        if re.match(r"^쪽$", para):
            continue
        if re.match(r"^.형$", para):  # "나형"
            continue
        # 원본 그림 크기 정보만 있는 단락
        if "원본 그림의 크기" in para or "원본 그림의 이름" in para:
            continue
        result.append(para)
    return result


def _deduplicate_paragraphs(paragraphs: list[str]) -> list[str]:
    """중복 단락을 제거한다.

    OWPML에서 부모 단락이 자식 단락의 텍스트를 합쳐서 포함하는 경우가 있다.
    더 짧은 단위(개별 단락)를 유지하고 합쳐진 긴 단락을 제거한다.
    """
    if not paragraphs:
        return []

    # 전략: 연속된 짧은 단락들의 텍스트를 합친 것이 긴 단락과 일치하면,
    # 긴 단락을 제거하고 짧은 단락들만 유지한다.
    result = []
    skip_indices = set()

    for i, para in enumerate(paragraphs):
        if i in skip_indices:
            continue

        # 문제 시작 또는 선택지 시작은 항상 유지
        if QUESTION_START_PATTERN.match(para) or CHOICE_START_PATTERN.match(para):
            result.append(para)
            continue

        # 긴 단락인 경우, 다음 몇 단락의 합침과 비교
        is_duplicate = False
        if len(para) > 100:
            combined = ""
            for j in range(i + 1, min(i + 20, len(paragraphs))):
                if j in skip_indices:
                    continue
                combined += paragraphs[j]
                # 공백/줄바꿈 제거 후 비교
                if _normalize_for_compare(para) == _normalize_for_compare(combined):
                    is_duplicate = True
                    break
                if len(combined) > len(para) * 1.5:
                    break

        if not is_duplicate:
            result.append(para)

    return result


def _normalize_for_compare(text: str) -> str:
    """비교용 텍스트 정규화: 공백/특수문자 제거"""
    return re.sub(r"\s+", "", text)


def parse_questions_from_paragraphs(paragraphs: list[str]) -> list[dict]:
    """단락 리스트에서 문제를 구조화하여 파싱한다.

    선택지 그룹 기반 역방향 파싱 전략:
    1. 먼저 선택지 그룹(①~④ 연속)의 위치를 식별
    2. 각 선택지 그룹 앞에서 역방향으로 문제 번호를 찾음
    3. 이 방식으로 지문 내의 "1.", "2." 등을 문제 번호로 오인하지 않음
    """
    # 1단계: 각 단락을 분류하여 인덱스와 함께 저장
    para_info = []  # (index, type, data)
    for i, para in enumerate(paragraphs):
        c_match = CHOICE_START_PATTERN.match(para)
        q_match = QUESTION_START_PATTERN.match(para)

        if c_match:
            digit_char = c_match.group(1)
            cno = CIRCLED_DIGITS[digit_char]
            text = c_match.group(2).strip()
            para_info.append((i, "choice", cno, text))
        elif q_match:
            qno = int(q_match.group(1))
            text = q_match.group(2).strip()
            para_info.append((i, "qnum", qno, text))
        else:
            para_info.append((i, "content", 0, para))

    # 2단계: 선택지 그룹 식별 (연속된 ①②③④ 단락)
    choice_groups = []  # [(start_idx, end_idx, {cno: text})]
    i = 0
    while i < len(para_info):
        idx, ptype, num, text = para_info[i]
        if ptype == "choice" and num == 1:
            # ① 발견 → 그룹 시작
            group_start = i
            choices = {num: text}
            j = i + 1
            while j < len(para_info):
                _, pt, cn, ct = para_info[j]
                if pt == "choice" and cn not in choices:
                    choices[cn] = ct
                    j += 1
                else:
                    break
            if len(choices) >= 3:  # 최소 3개 선택지 필요
                choice_groups.append((group_start, j - 1, choices))
            i = j
        else:
            i += 1

    # 3단계: 각 선택지 그룹에 대해 역방향으로 문제 번호 찾기
    questions = []
    used_para_indices = set()
    expected_qno = 1

    for g_idx, (g_start, g_end, choices) in enumerate(choice_groups):
        # 선택지 인덱스 마킹
        for k in range(g_start, g_end + 1):
            used_para_indices.add(para_info[k][0])

        # 이전 선택지 그룹의 끝 이후부터 현재 그룹 시작 전까지 역방향 스캔
        prev_end = choice_groups[g_idx - 1][1] if g_idx > 0 else -1
        search_range = para_info[prev_end + 1:g_start]

        # 역방향으로 문제 번호 찾기
        qno_found = None
        qno_para_idx = None
        qno_text = ""
        for k in range(len(search_range) - 1, -1, -1):
            _, pt, num, text = search_range[k]
            if pt == "qnum" and num == expected_qno:
                qno_found = num
                qno_para_idx = k
                qno_text = text
                break

        if qno_found is None:
            # 기대 번호를 못 찾으면 아무 qnum이나 역방향으로 찾기
            for k in range(len(search_range) - 1, -1, -1):
                _, pt, num, text = search_range[k]
                if pt == "qnum" and 1 <= num <= 25:
                    qno_found = num
                    qno_para_idx = k
                    qno_text = text
                    break

        if qno_found is None:
            # fallback: 문제 번호를 찾지 못하면 expected_qno를 사용
            # (이미지 기반 문제, 빈 search_range 등에서 발생)
            qno_found = expected_qno
            qno_para_idx = 0 if search_range else None
            qno_text = ""

        if qno_found is not None:
            # 문제 번호 단락과 선택지 사이의 내용 = 문제 본문
            start_k = qno_para_idx if qno_para_idx is not None else 0
            text_parts = [qno_text] if qno_text else []
            if qno_para_idx is not None:
                used_para_indices.add(search_range[start_k][0])

            for k in range(start_k + 1, len(search_range)):
                real_idx, pt, _, text = search_range[k]
                if pt != "choice":
                    text_parts.append(text)
                    used_para_indices.add(real_idx)

            questions.append(_build_question(qno_found, text_parts, choices))
            expected_qno = qno_found + 1

    # 4단계: 인라인 선택지 문제 (본문 속 ①②③④) 감지
    # 선택지 그룹에 할당되지 않은 문제 번호가 있으면
    # 해당 영역의 텍스트에서 인라인 선택지를 추출
    found_qnos = {q["questionNo"] for q in questions}
    for entry in para_info:
        idx, pt, num, text = entry
        if pt == "qnum" and num not in found_qnos and idx not in used_para_indices:
            # 이 문제 번호 이후의 내용 단락을 합침
            text_parts = [text] if text else []
            inline_text = text
            for j in range(para_info.index(entry) + 1, len(para_info)):
                j_idx, j_pt, j_num, j_text = para_info[j]
                if j_pt == "qnum" and j_num in found_qnos:
                    break
                if j_pt == "qnum" and j_num not in found_qnos and j_num != num:
                    break
                if j_pt == "choice":
                    break
                if j_idx not in used_para_indices:
                    text_parts.append(j_text)
                    inline_text += " " + j_text

            # 합친 텍스트에 인라인 선택지가 있으면 추출
            combined = "\n".join(text_parts)
            if CIRCLED_PATTERN.search(combined):
                questions.append(_build_question(num, text_parts, {}))
                found_qnos.add(num)

    # 문제 번호순 정렬
    questions.sort(key=lambda q: q["questionNo"])

    return questions


def _build_question(question_no: int, text_parts: list[str], choices: dict[int, str]) -> dict:
    """문제 딕셔너리를 생성한다."""
    # 순수 숫자(페이지 번호) 제거
    filtered_parts = [p for p in text_parts if not re.match(r"^\[?\d+\]?$", p)]
    question_text = "\n".join(filtered_parts).strip()

    # 선택지가 비어있는데 문제 텍스트 안에 인라인 선택지(①②③④)가 있는 경우
    # (예: "어색한 문장" 유형 - 본문 속 ①~⑤ 문장 중 정답 고르기)
    if not choices and CIRCLED_PATTERN.search(question_text):
        # 인라인 선택지 문제 - 선택지를 텍스트에서 추출
        inline_matches = list(CIRCLED_PATTERN.finditer(question_text))
        if len(inline_matches) >= 3:
            for k, im in enumerate(inline_matches):
                digit = CIRCLED_DIGITS[im.group(1)]
                start = im.end()
                end = inline_matches[k + 1].start() if k + 1 < len(inline_matches) else len(question_text)
                choice_text = question_text[start:end].strip().rstrip(".")
                choices[digit] = choice_text
            # 문제 텍스트에서 선택지 부분 제거하지 않음 (인라인이므로 본문 유지)

    return {
        "questionNo": question_no,
        "questionText": question_text,
        "choice1": choices.get(1, ""),
        "choice2": choices.get(2, ""),
        "choice3": choices.get(3, ""),
        "choice4": choices.get(4, ""),
        "choice5": choices.get(5, ""),
        "correctAns": "",
        "questionType": "CHOICE",
        "isUse": "Y",
    }


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

    paragraphs = extract_paragraphs_from_hwpx(hwpx_path)
    print(f"[INFO] 추출된 단락 수: {len(paragraphs)}")

    # 전처리: 노이즈 필터링 → 선택지 분리 → 중복 제거
    paragraphs = _filter_noise_paragraphs(paragraphs)
    paragraphs = _split_multi_choice_paragraphs(paragraphs)
    paragraphs = _deduplicate_paragraphs(paragraphs)
    print(f"[INFO] 전처리 후 단락 수: {len(paragraphs)}")

    questions = parse_questions_from_paragraphs(paragraphs)
    print(f"[INFO] 파싱된 문제 수: {len(questions)}")

    # 문제 수 검증
    if len(questions) < 10:
        print(f"[WARN] 문제 수가 너무 적습니다 ({len(questions)}). 파싱 결과를 확인하세요.", file=sys.stderr)

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
            stem = hwpx_file.stem
            # 긴 키부터 매칭하여 "화학" vs "화학공학" 등의 모호성 방지
            for name, code in sorted(subject_mapping.items(), key=lambda x: len(x[0]), reverse=True):
                if name in stem:
                    sc = code
                    sn = name
                    break

        if not sc:
            print(
                f"[WARN] {hwpx_file.name}의 과목코드를 결정할 수 없습니다. 건너뜁니다.",
                file=sys.stderr,
            )
            continue

        out_file = output_path / f"{hwpx_file.stem}.json"
        try:
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
        except Exception as e:
            print(f"[ERROR] {hwpx_file.name} 처리 실패: {e}", file=sys.stderr)

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
        if not subject_cd:
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
