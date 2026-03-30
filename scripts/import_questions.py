#!/usr/bin/env python3
"""
문제은행 DB 임포트 스크립트

파싱된 JSON을 bulk-import API로 DB에 적재한다.
그룹이 없으면 자동 생성한다.

사용법:
  # 단일 파일
  python import_questions.py merged.json --api-url http://localhost:8080

  # 디렉토리 내 모든 JSON
  python import_questions.py data/output/ --api-url http://localhost:8080

  # API 키 지정
  python import_questions.py merged.json --api-url http://localhost:8080 --api-key admin
"""

import argparse
import json
import os
import sys
from pathlib import Path

try:
    import requests
except ImportError:
    print(
        "[ERROR] requests가 설치되지 않았습니다.\n"
        "  pip install requests",
        file=sys.stderr,
    )
    sys.exit(1)


BATCH_SIZE = 50  # API 타임아웃 방지용 배치 크기


def make_group_cd(metadata: dict) -> str:
    """메타데이터로 groupCd 생성.

    형식: {연도}-{유형}-R{회차}-{과목명}
    예: 2024-9LEVEL-R1-국어
    """
    year = metadata.get("examYear", "")
    category = metadata.get("category", "")
    round_num = metadata.get("examRound", 1)
    subject_nm = metadata.get("subjectNm", "")

    parts = [p for p in [year, category, f"R{round_num}", subject_nm] if p]
    return "-".join(parts) if parts else "IMPORT"


def find_or_create_group(
    api_url: str,
    headers: dict,
    metadata: dict,
) -> int:
    """기존 그룹을 찾거나 새로 생성한다. groupId를 반환한다."""
    group_cd = make_group_cd(metadata)

    # 기존 그룹 검색
    search_url = f"{api_url}/api/question-bank/groups"
    try:
        resp = requests.get(
            search_url,
            params={"keyword": group_cd, "page": 0, "size": 10},
            headers=headers,
            timeout=30,
        )
        resp.raise_for_status()
        data = resp.json()

        for group in data.get("data", []):
            if group.get("groupCd") == group_cd:
                print(f"[INFO] 기존 그룹 사용: {group_cd} (ID: {group['groupId']})")
                return group["groupId"]
    except requests.RequestException as e:
        print(f"[WARN] 그룹 검색 실패: {e}", file=sys.stderr)

    # 새 그룹 생성
    group_nm = group_cd
    create_data = {
        "groupCd": group_cd,
        "groupNm": group_nm,
        "examYear": metadata.get("examYear") or None,
        "examRound": metadata.get("examRound") or None,
        "category": metadata.get("category") or None,
        "source": metadata.get("source") or None,
        "isUse": "Y",
    }

    try:
        resp = requests.post(
            search_url,
            json=create_data,
            headers=headers,
            timeout=30,
        )
        resp.raise_for_status()
        result = resp.json()
        group_id = result["data"]["groupId"]
        print(f"[INFO] 새 그룹 생성: {group_cd} (ID: {group_id})")
        return group_id
    except requests.RequestException as e:
        print(f"[ERROR] 그룹 생성 실패: {e}", file=sys.stderr)
        if hasattr(e, "response") and e.response is not None:
            print(f"  응답: {e.response.text}", file=sys.stderr)
        sys.exit(1)


def import_items_batch(
    api_url: str,
    headers: dict,
    group_id: int,
    items: list[dict],
) -> tuple[int, int]:
    """문항을 배치 단위로 임포트한다. (성공수, 실패수) 반환."""
    success = 0
    fail = 0

    for i in range(0, len(items), BATCH_SIZE):
        batch = items[i : i + BATCH_SIZE]
        batch_num = i // BATCH_SIZE + 1
        total_batches = (len(items) + BATCH_SIZE - 1) // BATCH_SIZE

        # 각 item에 groupId 설정
        for item in batch:
            item["groupId"] = group_id

        url = f"{api_url}/api/question-bank/groups/{group_id}/bulk-import"
        try:
            resp = requests.post(
                url,
                json={"items": batch},
                headers=headers,
                timeout=60,
            )
            resp.raise_for_status()
            result = resp.json()
            count = result.get("count", len(batch))
            success += count
            print(
                f"  배치 {batch_num}/{total_batches}: {count}건 등록 완료"
            )
        except requests.RequestException as e:
            fail += len(batch)
            print(
                f"  배치 {batch_num}/{total_batches}: 실패 - {e}",
                file=sys.stderr,
            )
            if hasattr(e, "response") and e.response is not None:
                print(f"    응답: {e.response.text[:500]}", file=sys.stderr)

    return success, fail


def process_file(
    json_path: str,
    api_url: str,
    headers: dict,
) -> tuple[int, int]:
    """단일 JSON 파일을 DB에 임포트한다."""
    print(f"\n[FILE] {json_path}")

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    metadata = data.get("metadata", {})
    items = data.get("items", [])

    if not items:
        print("[WARN] 문항이 없습니다. 건너뜀.")
        return 0, 0

    # 정답 없는 문항 체크
    no_answer = [
        str(item.get("questionNo", "?"))
        for item in items
        if not item.get("correctAns")
    ]
    if no_answer:
        print(
            f"[WARN] 정답 없는 문항 {len(no_answer)}건: {', '.join(no_answer[:10])}"
            + ("..." if len(no_answer) > 10 else "")
        )

    # 그룹 찾기/생성
    group_id = find_or_create_group(api_url, headers, metadata)

    # 문항 임포트
    print(f"[INFO] {len(items)}건 임포트 시작 (그룹 ID: {group_id})")
    success, fail = import_items_batch(api_url, headers, group_id, items)

    print(f"[RESULT] 성공: {success}, 실패: {fail}")
    return success, fail


def main():
    parser = argparse.ArgumentParser(
        description="문제은행 DB 임포트 - JSON을 bulk-import API로 적재"
    )
    parser.add_argument("input", help="JSON 파일 또는 디렉토리")
    parser.add_argument(
        "--api-url",
        default="http://localhost:8080",
        help="API 서버 URL (기본: http://localhost:8080)",
    )
    parser.add_argument("--api-key", default="", help="X-Api-Key 헤더 값")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="실제 API 호출 없이 검증만 수행",
    )

    args = parser.parse_args()

    headers = {"Content-Type": "application/json"}
    if args.api_key:
        headers["X-Api-Key"] = args.api_key

    input_path = Path(args.input)
    total_success = 0
    total_fail = 0

    if args.dry_run:
        print("[DRY-RUN] 실제 API 호출 없이 파일 검증만 수행합니다.\n")

    if input_path.is_dir():
        json_files = sorted(input_path.glob("*.json"))
        if not json_files:
            print(f"[ERROR] {input_path}에서 JSON 파일을 찾을 수 없습니다.")
            sys.exit(1)

        print(f"[INFO] {len(json_files)}개 파일 처리 예정")

        for json_file in json_files:
            if args.dry_run:
                with open(json_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                items = data.get("items", [])
                meta = data.get("metadata", {})
                print(
                    f"  {json_file.name}: {len(items)}문항, "
                    f"과목={meta.get('subjectCd', '?')}, "
                    f"연도={meta.get('examYear', '?')}"
                )
                total_success += len(items)
            else:
                s, f = process_file(str(json_file), args.api_url, headers)
                total_success += s
                total_fail += f
    else:
        if not input_path.exists():
            print(f"[ERROR] 파일을 찾을 수 없습니다: {input_path}")
            sys.exit(1)

        if args.dry_run:
            with open(input_path, "r", encoding="utf-8") as f:
                data = json.load(f)
            items = data.get("items", [])
            meta = data.get("metadata", {})
            print(
                f"  {input_path.name}: {len(items)}문항, "
                f"과목={meta.get('subjectCd', '?')}, "
                f"연도={meta.get('examYear', '?')}"
            )
            total_success = len(items)
        else:
            total_success, total_fail = process_file(
                str(input_path), args.api_url, headers
            )

    print(f"\n{'='*50}")
    if args.dry_run:
        print(f"[DRY-RUN] 검증 완료: 총 {total_success}문항")
    else:
        print(f"[DONE] 임포트 완료: 성공 {total_success}, 실패 {total_fail}")


if __name__ == "__main__":
    main()
