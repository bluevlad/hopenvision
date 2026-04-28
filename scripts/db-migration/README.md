# DB Migration Scripts

Academy MariaDB (`acm_basic`) → Hopenvision PostgreSQL DDL 변환 도구.

## 파일

- `mariadb_to_pg.py` — DDL 자동 변환 스크립트 (Python 3.10+)

## 사용

```bash
# 전체 변환 (stdout)
python3 mariadb_to_pg.py ../../docs/db-migration/source/acm_basic.schema.sql

# 파일로 저장
python3 mariadb_to_pg.py ../../docs/db-migration/source/acm_basic.schema.sql -o /tmp/converted.sql

# 특정 테이블만
python3 mariadb_to_pg.py ../../docs/db-migration/source/acm_basic.schema.sql --tables id_admin,bk_book,en_enrollment
```

## 변환 룰 (자동)

| MariaDB | PostgreSQL | 근거 |
|---------|-----------|------|
| `BIGINT(N)`, `INT(N)` 등 | `BIGINT`, `INTEGER` (너비 표기 제거) | PG 의미 없음 |
| `DATETIME` | `TIMESTAMP` | [D-2](../../docs/db-migration/decisions/PHASE1_DECISIONS.md) |
| `TINYINT(1)`, `TINYINT(N)` | `SMALLINT` | [D-3](../../docs/db-migration/decisions/PHASE1_DECISIONS.md) |
| `MEDIUMTEXT`, `LONGTEXT`, `TINYTEXT` | `TEXT` | |
| `BLOB`, `LONGBLOB`, `VARBINARY(N)`, `BINARY(N)` | `BYTEA` | |
| `DOUBLE`, `FLOAT(N,M)` | `DOUBLE PRECISION`, `REAL` | |
| `AUTO_INCREMENT` (컬럼) | `GENERATED ALWAYS AS IDENTITY` | |
| `\`identifier\`` | `identifier` (백틱 제거 + lowercase) | [D-6](../../docs/db-migration/decisions/PHASE1_DECISIONS.md) |
| `CHARACTER SET ...`, `COLLATE ...` (인라인) | 제거 | DB 레벨 UTF8 |
| `ENGINE=...`, `ROW_FORMAT=...`, table-level `AUTO_INCREMENT=N` | 제거 | PG 무관 |
| `KEY name (cols) USING BTREE` | `CREATE INDEX ix_table_name ON table (cols);` (별도 분리) | |
| `UNIQUE KEY name (cols)` | `CREATE UNIQUE INDEX ux_table_name ON table (cols);` | |
| `COMMENT '...'` (컬럼) | `COMMENT ON COLUMN table.col IS '...';` (별도 분리) | |
| `current_timestamp()` | `CURRENT_TIMESTAMP` | |
| `ON UPDATE CURRENT_TIMESTAMP` | `/*PG_TODO_ON_UPDATE*/` 마커만 → 트리거 별도 처리 | |
| `DEFAULT NULL` | (제거, 묵시적) | |
| `/*!50001 ... */`, `/*M! ... */` (조건부 주석, view stub 포함) | 제거 | |

## 자동 변환 후 수동 보완 필요

1. **`/*PG_TODO_ON_UPDATE*/` 마커**: 각 테이블에 BEFORE UPDATE 트리거 함수 추가 (별도 V 마이그레이션)
2. **FK 순서**: CREATE TABLE 순서를 FK 종속성에 맞게 재배치
3. **인덱스 이름 충돌**: PG 는 schema unique → 잠재적 중복 검토
4. **한글 코멘트**: COMMENT ON COLUMN 으로 분리됨, 인코딩 검증
5. **시퀀스 발급 프로시저**: `GET_NEXTSEQ_*` 7개 → PostgreSQL `CREATE SEQUENCE` 일괄 대체 ([D-5](../../docs/db-migration/decisions/PHASE1_DECISIONS.md))
6. **함수/프로시저**: 본 스크립트는 DDL 만 변환 — `acm_basic.routines.sql` 은 수동 PL/pgSQL 변환 필요
7. **뷰**: `acm_basic.views.sql` (`comvnusermaster`, `v_inquiry`) 도 수동 변환 필요

## 검증 방법

```bash
# 변환 후 통계 확인
python3 mariadb_to_pg.py ../../docs/db-migration/source/acm_basic.schema.sql -o /tmp/converted.sql

grep -c '^CREATE TABLE' /tmp/converted.sql        # 270
grep -c 'GENERATED ALWAYS AS IDENTITY' /tmp/converted.sql  # 25
grep -c 'PG_TODO_ON_UPDATE' /tmp/converted.sql    # 7 (트리거 필요)
grep -c '\`' /tmp/converted.sql                    # 0 (백틱 잔여 없어야 함)

# dev DB 에 로딩 시뮬레이션
PGPASSWORD=2u3efnwWERTjq4HMZ8LrBknFv7VyQq psql \
  -h 172.30.1.72 -p 5432 -U dev_writer -d hopenvision_dev \
  -f /tmp/converted.sql
```

## 미지원 (수동 변환 필수)

- 함수 본문 (`BEGIN ... END` PL/SQL → PL/pgSQL)
- 프로시저 본문
- 뷰 SELECT 절의 `convert(... using utf8mb4)`
- `acm_*` prefix 테이블 (제외 대상이라 변환 불필요 — [PHASE1_DECISIONS.md](../../docs/db-migration/decisions/PHASE1_DECISIONS.md))
