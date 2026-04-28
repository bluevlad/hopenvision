#!/usr/bin/env python3
"""
MariaDB → PostgreSQL DDL 자동 변환 스크립트

입력: docs/db-migration/source/acm_basic.schema.sql
출력: stdout (또는 -o 로 파일)

PHASE1_DECISIONS.md 의 결정 반영:
  D-2: DATETIME → TIMESTAMP (timezone 없음)
  D-3: TINYINT(1) → SMALLINT
  D-6: 식별자 lowercase 정규화 (TB_ prefix 보존)

자동화 가능한 변환만 처리. 다음은 수동 보완 필요:
  - ON UPDATE CURRENT_TIMESTAMP → 트리거 (별도 V 마이그레이션)
  - KEY 인덱스 → CREATE INDEX (CREATE TABLE 분리 후처리)
  - FK 제약 (RESTRICT, CASCADE 행위 검증)
  - 한글 코멘트 → COMMENT ON COLUMN

사용:
  python3 mariadb_to_pg.py docs/db-migration/source/acm_basic.schema.sql > /tmp/converted.sql
  python3 mariadb_to_pg.py docs/db-migration/source/acm_basic.schema.sql -o /tmp/converted.sql
  python3 mariadb_to_pg.py docs/db-migration/source/acm_basic.schema.sql --tables tb_ma_member,tb_orders
"""
import argparse
import re
import sys
from typing import Iterable


# ---------- 토큰화/유틸 ----------

CREATE_TABLE_RE = re.compile(
    r"CREATE TABLE\s+`?(?P<name>\w+)`?\s*\((?P<body>.*?)\)\s*ENGINE=.*?;",
    re.DOTALL | re.IGNORECASE,
)


MARIADB_CONDITIONAL_COMMENT_RE = re.compile(r"/\*[!M][^*]*?\*/;?", re.DOTALL)


def strip_mariadb_noise(sql: str) -> str:
    """MariaDB 전용 조건부 주석 (/*!50001 ... */, /*M! ... */) 제거.
    뷰 stub (CREATE VIEW AS SELECT 1 AS col) 도 함께 제거됨."""
    return MARIADB_CONDITIONAL_COMMENT_RE.sub("", sql)


def split_table_blocks(sql: str) -> Iterable[str]:
    """CREATE TABLE ... ; 블록 단위로 yield. 다른 라인(코멘트, SET 등) 은 그대로 yield."""
    pos = 0
    while True:
        m = CREATE_TABLE_RE.search(sql, pos)
        if not m:
            yield sql[pos:]
            break
        if m.start() > pos:
            yield sql[pos:m.start()]
        yield m.group(0)
        pos = m.end()


# ---------- 타입/구문 변환 ----------

# (pattern, replacement) — order matters
TYPE_RULES = [
    # 정수 — N 너비 표기 제거 (표시용일 뿐 PG 의미 없음)
    (re.compile(r"\bbigint\(\d+\)", re.IGNORECASE), "BIGINT"),
    (re.compile(r"\btinyint\(1\)", re.IGNORECASE), "SMALLINT"),  # D-3: BOOLEAN 회피
    (re.compile(r"\btinyint\(\d+\)", re.IGNORECASE), "SMALLINT"),
    (re.compile(r"\bsmallint\(\d+\)", re.IGNORECASE), "SMALLINT"),
    (re.compile(r"\bmediumint\(\d+\)", re.IGNORECASE), "INTEGER"),
    (re.compile(r"\bint\(\d+\)", re.IGNORECASE), "INTEGER"),

    # 시간 — D-2: TIMESTAMP
    (re.compile(r"\bdatetime\b", re.IGNORECASE), "TIMESTAMP"),

    # 텍스트
    (re.compile(r"\bmediumtext\b", re.IGNORECASE), "TEXT"),
    (re.compile(r"\blongtext\b", re.IGNORECASE), "TEXT"),
    (re.compile(r"\btinytext\b", re.IGNORECASE), "TEXT"),

    # 바이너리
    (re.compile(r"\blongblob\b", re.IGNORECASE), "BYTEA"),
    (re.compile(r"\bmediumblob\b", re.IGNORECASE), "BYTEA"),
    (re.compile(r"\btinyblob\b", re.IGNORECASE), "BYTEA"),
    (re.compile(r"\bblob\b", re.IGNORECASE), "BYTEA"),
    (re.compile(r"\bvarbinary\(\d+\)", re.IGNORECASE), "BYTEA"),
    (re.compile(r"\bbinary\(\d+\)", re.IGNORECASE), "BYTEA"),

    # 부동소수 — N,M 표기는 PG 호환
    (re.compile(r"\bdouble(\s*\(\d+,\d+\))?", re.IGNORECASE), "DOUBLE PRECISION"),
    (re.compile(r"\bfloat(\s*\(\d+,\d+\))?", re.IGNORECASE), "REAL"),

    # CHARSET/COLLATE 인라인 절 제거 (컬럼 정의 내)
    (re.compile(r"\s+CHARACTER SET\s+\w+", re.IGNORECASE), ""),
    (re.compile(r"\s+CHARSET\s+\w+", re.IGNORECASE), ""),
    (re.compile(r"\s+COLLATE\s+\w+", re.IGNORECASE), ""),

    # current_timestamp() → CURRENT_TIMESTAMP (PG 호환은 되지만 통일)
    (re.compile(r"\bcurrent_timestamp\(\)", re.IGNORECASE), "CURRENT_TIMESTAMP"),

    # ON UPDATE CURRENT_TIMESTAMP → 제거 (트리거로 별도 처리, on_update_marker 주석 추가)
    (re.compile(r"\s+ON\s+UPDATE\s+CURRENT_TIMESTAMP", re.IGNORECASE), " /*PG_TODO_ON_UPDATE*/"),

    # AUTO_INCREMENT → GENERATED ALWAYS AS IDENTITY 는 컬럼 정의 후처리에서 (단순 치환 X)
]

ENGINE_CLAUSE_RE = re.compile(
    r"\)\s*ENGINE=\w+(?:\s+AUTO_INCREMENT=\d+)?(?:\s+DEFAULT\s+CHARSET=\w+)?(?:\s+COLLATE=\w+)?(?:\s+COMMENT='[^']*')?(?:\s+ROW_FORMAT=\w+)?\s*;",
    re.IGNORECASE,
)

KEY_LINE_RE = re.compile(
    r"^\s*(?:UNIQUE\s+)?KEY\s+`?(\w+)`?\s*\(([^)]*)\)(?:\s+USING\s+\w+)?\s*,?\s*$",
    re.IGNORECASE,
)
PRIMARY_KEY_RE = re.compile(
    r"^\s*PRIMARY\s+KEY\s*\(([^)]*)\)(?:\s+USING\s+\w+)?\s*,?\s*$",
    re.IGNORECASE,
)
CONSTRAINT_FK_RE = re.compile(
    r"^\s*CONSTRAINT\s+`?(?P<cname>\w+)`?\s+FOREIGN\s+KEY\s+\((?P<cols>[^)]+)\)\s+REFERENCES\s+`?(?P<rtbl>\w+)`?\s*\((?P<rcols>[^)]+)\)(?P<rest>.*?)\s*,?\s*$",
    re.IGNORECASE,
)
COLUMN_LINE_RE = re.compile(r"^\s*`?(?P<name>\w+)`?\s+(?P<rest>.+?)(?P<comma>,?)\s*$")


# PostgreSQL 예약어 (식별자 자체로 사용 시 따옴표 필요)
PG_RESERVED = {
    "do", "user", "order", "group", "table", "column", "select", "from",
    "where", "limit", "offset", "default", "primary", "key", "unique",
    "check", "constraint", "case", "when", "then", "else", "end", "as",
    "is", "null", "not", "and", "or", "in", "like", "between", "exists",
    "array", "current", "type", "domain", "schema", "view", "index",
    "trigger", "function", "procedure", "begin", "commit", "rollback",
    "grant", "revoke", "session", "system", "all", "any", "some", "true",
    "false", "boolean", "char", "varchar", "text", "integer", "bigint",
    "smallint", "numeric", "decimal", "real", "double", "date", "time",
    "timestamp", "interval",
}


def normalize_identifier(s: str) -> str:
    """백틱 제거 + lowercase. PG 예약어는 따옴표 필요."""
    cleaned = s.strip().strip("`").lower()
    if cleaned in PG_RESERVED:
        return f'"{cleaned}"'
    return cleaned


def lowercase_in_parens(text: str) -> str:
    """(col1, col2) 형식의 컬럼 리스트를 lowercase 화."""
    parts = [normalize_identifier(p) for p in text.split(",")]
    return ", ".join(parts)


def convert_table(create_sql: str) -> tuple[str, list[str], list[str]]:
    """
    하나의 CREATE TABLE 블록을 변환.

    반환: (table_ddl, index_ddls, comments) — 인덱스/코멘트는 별도 분리해서 후행 추가.
    """
    m = CREATE_TABLE_RE.match(create_sql)
    if not m:
        return create_sql, [], []

    table_name = normalize_identifier(m.group("name"))
    body = m.group("body")

    # 줄 단위 분해
    lines = [ln for ln in body.split("\n") if ln.strip()]

    column_lines: list[str] = []
    pk_clause: str | None = None
    indexes: list[tuple[str, str, bool]] = []  # (name, cols, unique)
    fks: list[str] = []
    column_comments: list[tuple[str, str]] = []  # (col_name, comment)

    for ln in lines:
        ln = ln.rstrip(",").rstrip()
        if not ln.strip():
            continue

        # PRIMARY KEY
        m_pk = PRIMARY_KEY_RE.match(ln)
        if m_pk:
            cols = lowercase_in_parens(m_pk.group(1))
            pk_clause = f"  PRIMARY KEY ({cols})"
            continue

        # UNIQUE KEY / KEY (인덱스)
        m_key = KEY_LINE_RE.match(ln)
        if m_key:
            idx_name = normalize_identifier(m_key.group(1))
            cols = lowercase_in_parens(m_key.group(2))
            is_unique = "UNIQUE" in ln.upper().split("KEY")[0]
            indexes.append((idx_name, cols, is_unique))
            continue

        # FOREIGN KEY
        m_fk = CONSTRAINT_FK_RE.match(ln)
        if m_fk:
            cname = normalize_identifier(m_fk.group("cname"))
            cols = lowercase_in_parens(m_fk.group("cols"))
            rtbl = normalize_identifier(m_fk.group("rtbl"))
            rcols = lowercase_in_parens(m_fk.group("rcols"))
            rest = m_fk.group("rest").strip()
            fks.append(
                f"  CONSTRAINT {cname} FOREIGN KEY ({cols}) "
                f"REFERENCES {rtbl} ({rcols}){' ' + rest if rest else ''}"
            )
            continue

        # 일반 컬럼 정의
        m_col = COLUMN_LINE_RE.match(ln)
        if m_col:
            col_name = normalize_identifier(m_col.group("name"))
            rest = m_col.group("rest").rstrip(",").strip()

            # 코멘트 추출
            comment_match = re.search(r"COMMENT\s+'((?:[^'\\]|\\.|'')*)'", rest, re.IGNORECASE)
            if comment_match:
                col_comment = comment_match.group(1).replace("''", "'")
                column_comments.append((col_name, col_comment))
                rest = re.sub(r"\s*COMMENT\s+'(?:[^'\\]|\\.|'')*'", "", rest, flags=re.IGNORECASE).strip()

            # AUTO_INCREMENT 처리 → IDENTITY
            has_auto_inc = bool(re.search(r"\bAUTO_INCREMENT\b", rest, re.IGNORECASE))
            if has_auto_inc:
                rest = re.sub(r"\s*AUTO_INCREMENT", "", rest, flags=re.IGNORECASE)
                rest = re.sub(r"NOT NULL", "NOT NULL GENERATED ALWAYS AS IDENTITY", rest, count=1, flags=re.IGNORECASE)

            # 타입 변환 룰 적용
            for pattern, repl in TYPE_RULES:
                rest = pattern.sub(repl, rest)

            # DEFAULT NULL 은 PG 에서는 묵시적 (제거 — 가독성)
            rest = re.sub(r"\s+DEFAULT\s+NULL", "", rest, flags=re.IGNORECASE)

            # 빈공백 정리
            rest = re.sub(r"\s+", " ", rest).strip()

            column_lines.append(f"  {col_name} {rest}")
        else:
            # 매칭 실패한 줄 — TODO 마커
            column_lines.append(f"  /*PG_TODO: {ln}*/")

    # 테이블 DDL 조립
    table_clauses = column_lines.copy()
    if pk_clause:
        table_clauses.append(pk_clause)
    table_clauses.extend(fks)

    # 마지막 콤마 추가
    table_ddl = (
        f"CREATE TABLE {table_name} (\n"
        + ",\n".join(table_clauses)
        + "\n);\n"
    )

    # 인덱스 DDL — 별도 CREATE INDEX
    index_ddls = []
    for idx_name, cols, is_unique in indexes:
        unique_kw = "UNIQUE " if is_unique else ""
        prefix = "ux" if is_unique else "ix"
        # 원본 인덱스명이 이미 테이블명/접두어 가지면 중복 회피
        # 예: uk_id_admin_username → ux_id_admin_username
        clean_name = idx_name
        for old_pfx in ("uk_", "ix_", "idx_", "fk_", "key_"):
            if clean_name.startswith(old_pfx):
                clean_name = clean_name[len(old_pfx):]
                break
        # 테이블명이 이미 인덱스명에 포함되면 중복 회피
        if clean_name.startswith(table_name + "_"):
            full_name = f"{prefix}_{clean_name}"
        elif clean_name == table_name:
            full_name = f"{prefix}_{table_name}_{cols.replace(', ', '_').replace(' ', '')[:30]}"
        else:
            full_name = f"{prefix}_{table_name}_{clean_name}"
        # PG identifier 길이 63자 제한
        if len(full_name) > 63:
            full_name = full_name[:63]
        index_ddls.append(f"CREATE {unique_kw}INDEX {full_name} ON {table_name} ({cols});")

    # 코멘트
    comments = [
        f"COMMENT ON COLUMN {table_name}.{c} IS '{cmt}';"
        for c, cmt in column_comments
    ]

    return table_ddl, index_ddls, comments


def convert(sql: str, table_order: list[str] | None = None) -> str:
    """
    sql 을 PG DDL 로 변환.
    table_order 가 주어지면 해당 순서대로 출력 (FK 종속성 순서 보장).
    table_order 가 None 이면 입력 SQL 순서 유지.
    """
    out: list[str] = [
        "-- ============================================",
        "-- Auto-generated by mariadb_to_pg.py",
        "-- 입력: acm_basic.schema.sql (MariaDB 11.8)",
        "-- 출력: PostgreSQL 15 호환 DDL",
        "-- ⚠️  자동 변환 결과 — 수동 검증 필수",
        "-- 마커: /*PG_TODO_ON_UPDATE*/, /*PG_TODO: ...*/ → 트리거/수동 처리",
        "-- ============================================",
        "",
    ]

    # 테이블별 변환 결과 수집 + 비-테이블 블록 (보존할 것만)
    table_filter = set(t.lower() for t in table_order) if table_order else None
    table_outputs: dict[str, list[str]] = {}  # table_name -> [ddl, indexes, comments]
    other_blocks: list[str] = []

    for block in split_table_blocks(sql):
        m = CREATE_TABLE_RE.match(block)
        if m:
            raw_name = m.group("name").strip().strip("`").lower()
            if table_filter and raw_name not in table_filter:
                continue
            ddl, indexes, comments = convert_table(block)
            chunk: list[str] = [f"-- =========== {raw_name} ===========", ddl]
            chunk.extend(indexes)
            chunk.extend(comments)
            chunk.append("")
            table_outputs[raw_name] = chunk
        else:
            # 라인 단위로 필터: MariaDB 전용 헤더는 모두 drop
            kept_lines = []
            for line in block.split("\n"):
                stripped = line.strip()
                if not stripped:
                    continue
                if (
                    stripped.startswith("/*!")
                    or stripped.startswith("/*M!")
                    or stripped.upper().startswith("SET ")
                    or stripped.upper().startswith("DROP TABLE IF EXISTS")
                    or stripped.upper().startswith("LOCK TABLES")
                    or stripped.upper().startswith("UNLOCK TABLES")
                    or stripped.startswith("--")
                ):
                    continue
                kept_lines.append(line)
            if kept_lines:
                other_blocks.append("\n".join(kept_lines))

    # 출력: table_order 가 있으면 그 순서대로, 없으면 발견 순서대로
    if table_order:
        for tbl in table_order:
            tbl_lc = tbl.lower()
            if tbl_lc in table_outputs:
                out.extend(table_outputs[tbl_lc])
            else:
                out.append(f"-- ⚠️  테이블 '{tbl}' 을 acm_basic 에서 찾을 수 없음")
                out.append("")
    else:
        for chunk in table_outputs.values():
            out.extend(chunk)

    out.extend(other_blocks)

    return "\n".join(out) + "\n"


# ---------- CLI ----------

def main():
    ap = argparse.ArgumentParser(description="MariaDB → PostgreSQL DDL 변환")
    ap.add_argument("input", help="입력 SQL 파일 (mysqldump --no-data 결과)")
    ap.add_argument("-o", "--output", help="출력 파일 (생략 시 stdout)")
    ap.add_argument("--tables", help="콤마 구분 테이블 이름 (lowercase). 생략 시 전체 변환")
    args = ap.parse_args()

    with open(args.input, "r", encoding="utf-8") as f:
        sql = f.read()

    sql = strip_mariadb_noise(sql)

    table_order = (
        [t.strip().lower() for t in args.tables.split(",")] if args.tables else None
    )

    out = convert(sql, table_order)

    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(out)
        print(f"converted → {args.output}", file=sys.stderr)
    else:
        sys.stdout.write(out)


if __name__ == "__main__":
    main()
