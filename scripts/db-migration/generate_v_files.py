#!/usr/bin/env python3
"""
V*.sql Flyway 마이그레이션 파일 일괄 생성

PHASE1_FLYWAY_PLAN.md 의 V → 테이블 매핑을 정의하고, mariadb_to_pg.py 를 호출해서
도메인별 V*.sql 파일을 생성한다. ON UPDATE CURRENT_TIMESTAMP 가 있는 테이블에 대해
트리거 함수도 자동 부착.

사용:
  python3 generate_v_files.py                      # api/src/main/resources/db/migration/ 에 출력
  python3 generate_v_files.py -o /tmp/migration   # 다른 디렉토리
  python3 generate_v_files.py --dry-run           # 출력 위치만 표시
"""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent.parent
SCHEMA_FILE = REPO_ROOT / "docs/db-migration/source/acm_basic.schema.sql"
DEFAULT_OUT = REPO_ROOT / "api/src/main/resources/db/migration"


# ============================================================
# V → 테이블 매핑 (PHASE1_FLYWAY_PLAN.md section 3 + 실측 보정)
# ============================================================
# 각 entry: (V번호, 파일명_suffix, 설명, [테이블 리스트])
# acm_* 는 모두 제외 ([PHASE1_DECISIONS.md D-1, ADR-001])
# ex_mock_exam, ex_mock_attempt 도 제외 (ADR-001 ex_mock 폐기)
V_GROUPS: list[tuple[int, str, str, list[str]]] = [
    # ---- legacy + eGov + 공통코드 (FK 마스터 성격) ----
    (2, "platform_common_codes", "공통코드 마스터 (cmmn_*)", [
        "cmmn_code", "cmmn_cl_code", "cmmn_detail_code",
    ]),
    (3, "platform_egov_user_master", "eGovFramework 회원 마스터 (3종)", [
        "gnrl_mber", "emplyr_info", "entrprs_mber",
    ]),
    (4, "platform_egov_auth_log", "eGov 권한/로그/사용자 (10종)", [
        # FK 종속성 순서: author_info, role_info (parents) → roles_hierarchy, author_role_relate (children)
        "author_info", "role_info",
        "roles_hierarchy", "author_role_relate",
        "emplyrscrtyestbs", "sys_log", "mb_access_log",
        "off_user", "on_user", "tbl_users",
    ]),
    (5, "platform_egov_bbs", "eGov 게시판 (4종)", [
        "comtnbbs", "comtnbbsmaster", "comtnbbsmasteroptn", "comtnbbsuse",
    ]),
    (6, "platform_egov_log", "eGov 로그/모니터링 (15종)", [
        "comtnloginlog", "comtnloginpolicy", "comtnntwrksvcmntrng",
        "comtnntwrksvcmntrngloginfo", "comtnprivacylog", "comtntrsmrcvlog",
        "comtnuserlog", "comtsbbssummary", "comtssyslogsummary",
        "comtstrsmrcvlogsummary", "comtsweblogsummary", "comtnprogrmlist",
        "comtntmplatinfo", "comtnmenuinfo",
    ]),
    (7, "platform_misc", "기타 운영/배치 (9종)", [
        "sc_tran", "ba_config_cd", "batch_opert", "batch_schdul",
        "batch_schdul_dfk", "backup_opert", "web_log", "www_poll", "www_poll_item",
    ]),

    # ---- 윌비스 TB_* 레거시 (도메인별 분할) ----
    (8, "legacy_tb_member", "윌비스 회원 (tb_ma_*, tb_tm_users 등)", [
        "tb_ma_member", "tb_ma_member_category", "tb_ma_member_main_category",
        "tb_ma_member_prf", "tb_ma_member_series", "tb_ma_member_subject",
        "tb_tm_users", "tb_tm_admin", "tm_device_history", "tm_ist",
    ]),
    (9, "legacy_tb_lecture", "윌비스 강의 마스터/영상", [
        "tb_lec_mst", "tb_lec_mst_memo", "tb_lec_bridge", "tb_lec_jong",
        "tb_movie", "tb_mymovie", "tb_mylecture", "tb_mylecture_pause",
        "tb_subject_info", "tb_subject_category", "tb_subject_series",
        "tb_category_info", "tb_category_series",
        "tb_category_subject_order", "tb_main_category_subject_order",
        "tb_series_info", "tb_learning_form_info",
        # tb_category_mapping 은 V28 (inquiry_extension) 에 정의 (academy V11~V12 정의)
    ]),
    (10, "legacy_tb_offline", "윌비스 오프라인 강의/주문/사물함", [
        "tb_off_lec_mst", "tb_off_lec_bridge", "tb_off_lec_jong",
        "tb_off_lecture_date", "tb_off_mylecture",
        "tb_off_orders", "tb_off_approvals", "tb_off_order_mgnt_no",
        "tb_off_refund", "tb_off_cc_cart", "tb_off_cc_j_cart",
        "tb_off_choice_jong_no", "tb_off_plus_ca_book",
        "tb_off_box", "tb_off_box_num", "tb_off_box_rent",
        "tb_off_room", "tb_off_room_num",
    ]),
    (11, "legacy_tb_order", "윌비스 온라인 주문/결제", [
        "tb_orders", "tb_torders", "tb_approvals", "tb_order_mgnt_no",
        "tb_order_yearpackage", "tb_paysettlement", "tb_paysettlement_add",
        "tb_seq_orderno", "tb_seqoff_orderno",
    ]),
    (12, "legacy_tb_book", "윌비스 교재/배송", [
        "tb_ca_book", "tb_plus_ca_book", "tb_comment_book", "tb_delivers",
    ]),
    (13, "legacy_tb_cart_bookmark", "윌비스 카트/북마크", [
        "tb_cc_cart", "tb_cc_j_cart", "tb_choice_jong_no", "tb_bookmark",
    ]),
    (14, "legacy_tb_board_inquiry", "윌비스 게시판/문의 (legacy + 신규)", [
        "tb_board", "tb_board2", "tb_board_category_info", "tb_board_comment",
        "tb_board_cs", "tb_board_file", "tb_board_mng", "tb_board_voting",
        "tb_inquiry", "tb_inquiry_file", "tb_inquiry_train",
        "tb_inquiry_analysis", "tb_inquiry_routing_log",
        "tb_inquiry_stats_monthly", "tb_inquiry_embedding",
    ]),
    (15, "legacy_tb_event_banner_popup", "윌비스 이벤트/배너/팝업", [
        "tb_event_info", "tb_event_file", "tb_event_option1",
        "tb_event_option2", "tb_event_result",
        "tb_banner", "tb_banner_item", "tb_popup_info",
    ]),
    (16, "legacy_tb_sg_menu_site", "윌비스 사이트/메뉴 (sg_*)", [
        "tb_sg_site", "tb_sg_site_menu", "tb_sg_menu_mst", "tb_sg_menu_mst2",
    ]),
    (17, "legacy_tb_tm_message", "윌비스 메시지/쿠폰 (tm_*)", [
        "tb_tm_board", "tb_tm_coupon", "tb_tm_mycoupon",
    ]),
    (18, "legacy_tb_test", "윌비스 시험/모의고사 (t* prefix, exam_* 와 별도)", [
        "tb_top_mst", "tb_titem", "tb_titempool", "tb_tcommoncode",
        "tb_texamidseq", "tb_texamineeanswer", "tb_tboardtestclass",
        "tb_tboardtestenv", "tb_tattachfile", "tb_tapprovals",
        "tb_tsubjectarea", "tb_tccsrssubjectinfo", "tb_tuserchoicesubject",
        "tb_twronganswernote", "tb_tmockregistration", "tb_tmocksubject",
        "tb_tmockgrade", "tb_tmockclsclsseries",
    ]),
    (19, "legacy_tb_misc", "윌비스 기타 (우편번호/마일리지/통계/공통)", [
        "tb_zipcode", "tb_zipcode_new", "tb_pmp_downlog",
        "tb_mileage_history", "tb_renew_history",
        "tb_comment", "tb_dday", "tb_discount", "tb_note_send_info",
        "tb_stat_prf", "tb_ba_config_cd", "tb_common_password",
        "tb_danintcount", "tb_danpint",
    ]),

    # ---- OTHER (eGov 외 잔여 — gosi/counsel/coop) ----
    (20, "gosi_master", "고시 마스터/과목 (9종)", [
        "gosi_mst", "gosi_cod", "gosi_subject", "gosi_sbj_mst",
        "gosi_area_mst", "gosi_pass_mst", "gosi_pass_sta",
        "gosi_stat_mst", "gosi_vod",
    ]),
    (21, "gosi_result", "고시 응시 결과 (4종)", [
        "gosi_rst_mst", "gosi_rst_det", "gosi_rst_sbj", "gosi_rst_smp",
    ]),
    (22, "counsel", "상담 (3종)", [
        "counsel_rst", "counsel_sch", "counsel_time",
    ]),
    (23, "coop", "협력사 쿠폰 (4종)", [
        "coop_mst", "coop_coupon", "coop_coupon_mst", "cop_seq",
    ]),
    (24, "misc_other", "분류외 잔여", [
        "notuse_coupon_lecture", "material_menu_mst",
    ]),

    # ---- 신규 prefix (academy V2~V13 정의) ----
    (25, "identity_admin", "관리자 계정 (academy V2)", [
        "id_admin",
    ]),
    (26, "enrollment_cart_order", "수강 신청/장바구니/주문 (academy V5)", [
        "en_cart_item", "en_enrollment", "od_order", "od_order_item", "od_payment",
    ]),
    (27, "point_book", "포인트/쿠폰/교재 (academy V6)", [
        "pt_coupon", "pt_coupon_user", "pt_mileage_ledger",
        "bk_book", "bk_delivery_address", "bk_delivery",
    ]),
    (28, "inquiry_extension", "1:1 문의 확장 (academy V11~V12)", [
        "tb_category_mapping",
    ]),
]


def run_converter(tables: list[str]) -> str:
    """mariadb_to_pg.py 를 호출해서 지정 테이블만 변환."""
    table_arg = ",".join(tables)
    result = subprocess.run(
        [
            "python3",
            str(SCRIPT_DIR / "mariadb_to_pg.py"),
            str(SCHEMA_FILE),
            "--tables",
            table_arg,
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout


def extract_tables_with_on_update(sql: str) -> list[str]:
    """변환된 SQL 에서 PG_TODO_ON_UPDATE 마커가 있는 테이블 식별."""
    tables = []
    current_table = None
    for line in sql.split("\n"):
        m = re.match(r"^CREATE TABLE\s+(\w+)\s*\(", line)
        if m:
            current_table = m.group(1)
            continue
        if "PG_TODO_ON_UPDATE" in line and current_table:
            if current_table not in tables:
                tables.append(current_table)
    return tables


def append_upd_dt_triggers(sql: str, tables: list[str]) -> str:
    """ON UPDATE CURRENT_TIMESTAMP 가 있던 테이블에 BEFORE UPDATE 트리거 추가."""
    if not tables:
        return sql

    trigger_func = """
-- ============================================
-- ON UPDATE CURRENT_TIMESTAMP 트리거
-- ============================================
-- 공용 트리거 함수 (한 번만 정의 — 첫 번째 V 에서만 CREATE)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'set_upd_dt_now') THEN
        EXECUTE $func$
            CREATE FUNCTION set_upd_dt_now() RETURNS trigger AS $body$
            BEGIN
                IF TG_OP = 'UPDATE' THEN
                    -- 컬럼명이 upd_dt 또는 updated_at 인 경우 모두 처리
                    BEGIN
                        NEW.upd_dt := CURRENT_TIMESTAMP;
                    EXCEPTION WHEN OTHERS THEN
                        BEGIN
                            NEW.updated_at := CURRENT_TIMESTAMP;
                        EXCEPTION WHEN OTHERS THEN
                            NULL;
                        END;
                    END;
                END IF;
                RETURN NEW;
            END;
            $body$ LANGUAGE plpgsql;
        $func$;
    END IF;
END $$;
"""

    triggers = []
    for tbl in tables:
        triggers.append(
            f"DROP TRIGGER IF EXISTS trg_{tbl}_upd_dt ON {tbl};\n"
            f"CREATE TRIGGER trg_{tbl}_upd_dt BEFORE UPDATE ON {tbl}\n"
            f"  FOR EACH ROW EXECUTE FUNCTION set_upd_dt_now();"
        )
    return sql + trigger_func + "\n\n" + "\n\n".join(triggers) + "\n"


def generate_v_file(version: int, suffix: str, desc: str, tables: list[str], out_dir: Path, include_trigger_setup: bool) -> Path | None:
    """단일 V*.sql 파일 생성. tables 가 모두 존재하지 않으면 None 반환."""
    converted = run_converter(tables)

    # CREATE TABLE 이 하나라도 생성됐는지 확인
    if "CREATE TABLE" not in converted:
        print(f"  ⚠️  V{version}: 변환된 테이블 없음 — skip", file=sys.stderr)
        return None

    on_update_tables = extract_tables_with_on_update(converted)

    header = f"""-- ============================================
-- V{version}__{suffix}.sql
-- {desc}
-- 대상 테이블: {len(tables)}개 ({', '.join(tables[:5])}{'...' if len(tables) > 5 else ''})
-- 자동 생성: scripts/db-migration/generate_v_files.py
-- ============================================

"""

    # 처음 트리거 사용하는 V 에만 함수 정의 (DO $$ ... $$ 안에서 IF NOT EXISTS 로 idempotent)
    body = converted
    if on_update_tables:
        body = append_upd_dt_triggers(body, on_update_tables)

    out_path = out_dir / f"V{version}__{suffix}.sql"
    out_path.write_text(header + body, encoding="utf-8")
    return out_path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-o", "--output-dir", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    if not SCHEMA_FILE.exists():
        print(f"Error: 스키마 덤프 파일 없음 — {SCHEMA_FILE}", file=sys.stderr)
        sys.exit(1)

    if args.dry_run:
        print(f"출력 디렉토리: {args.output_dir}")
        print(f"생성 예정: V2~V{V_GROUPS[-1][0]} ({len(V_GROUPS)}개 파일)")
        for v, suffix, desc, tables in V_GROUPS:
            print(f"  V{v}__{suffix}.sql ({len(tables)}개 테이블)")
        return

    args.output_dir.mkdir(parents=True, exist_ok=True)

    generated: list[Path] = []
    for i, (v, suffix, desc, tables) in enumerate(V_GROUPS):
        print(f"V{v}__{suffix} 생성 중... ({len(tables)}개 테이블)", file=sys.stderr)
        path = generate_v_file(v, suffix, desc, tables, args.output_dir, include_trigger_setup=(i == 0))
        if path:
            generated.append(path)

    print(f"\n✓ {len(generated)}개 V*.sql 생성 완료", file=sys.stderr)
    for p in generated:
        print(f"  {p.relative_to(REPO_ROOT)}", file=sys.stderr)


if __name__ == "__main__":
    main()
