# Academy `acm_basic` 마이그레이션 원본 자료

> Academy → Hopenvision 통합 (MariaDB → PostgreSQL) 변환 작업의 입력 자료.
> 생성일: 2026-04-28
> 출처: 로컬 MariaDB 11.8.5 (`127.0.0.1:3306/acm_basic`)

## 파일 목록

| 파일 | 크기 | 내용 |
|------|------|------|
| `acm_basic.schema.sql` | 215 KB | 270 BASE TABLE의 CREATE TABLE 문 (no-data) |
| `acm_basic.routines.sql` | 115 KB | 35 PROCEDURE + 18 FUNCTION 정의 |
| `acm_basic.views.sql` | 3.4 KB | 2 VIEW 정의 (`comvnusermaster`, `v_inquiry`) |
| `tables.tsv` | — | 270 테이블 인벤토리 (prefix/rows/size/action) |
| `inventory.md` | — | 사람이 읽는 인벤토리 요약 (이 README의 통계와 동기화) |

## 통계 요약

- **BASE TABLE**: 270 (이관 209, 제외 61)
- **VIEW**: 2
- **PROCEDURE**: 35
- **FUNCTION**: 18 (⚠️ `ENCRYPT`/`DECRYPT`/`HASH_STR_DATA` 포함)
- **TRIGGER**: 0
- **데이터 총량**: 약 428 MB / 310만 행

### Prefix 분포

| Prefix | 개수 | 마이그레이션 |
|--------|------|------------|
| `TB_*` | 123 | ✅ 이관 (윌비스 25년 레거시) |
| OTHER | 72 | ✅ 이관 (eGovFramework `comtn*`, 공통코드 `cmmn_*`, 고시 `gosi_*`) |
| `acm_*` | 61 | ❌ 제외 (단, 회원/시험 데이터는 분석용 별도 인입) |
| `pt_/bk_/od_/en_/ex_/id_` | 14 | ✅ 이관 (신규 MSA prefix) |

## 사용 절차

이 자료는 **마이그레이션 작업의 입력**이며 PostgreSQL로 직접 import하지 않습니다.
실제 변환은 다음 순서로 수행:

1. `tables.tsv`에서 prefix별 그룹 파악
2. `acm_basic.schema.sql` MariaDB DDL → PostgreSQL DDL 변환
   - `AUTO_INCREMENT` → `BIGSERIAL/IDENTITY`
   - `DATETIME ON UPDATE CURRENT_TIMESTAMP` → 트리거 또는 JPA `@PreUpdate`
   - `TINYINT(1)` → `SMALLINT` 또는 `BOOLEAN`
   - `MEDIUMTEXT` → `TEXT`
   - `CHARSET=utf8mb4` 절 제거
3. `acm_basic.routines.sql` MariaDB SQL/PSM → PostgreSQL PL/pgSQL 변환
   - `ENCRYPT/DECRYPT` → `pgcrypto` 또는 애플리케이션 레벨로 이전
4. 변환 결과를 `hopenvision/api/src/main/resources/db/migration/V8~V??.sql` 시리즈로 분할 작성
5. 데이터는 `pgloader` 또는 `mysqldump → SQL 변환 → COPY` 순으로 별도 진행

## 갱신 정책

운영 MariaDB 스키마가 바뀌면 다음 명령으로 재생성:

```bash
mysqldump -h 127.0.0.1 -P 3306 -u root -p \
  --no-data --skip-comments --skip-opt --single-transaction \
  acm_basic > acm_basic.schema.sql

mysqldump -h 127.0.0.1 -P 3306 -u root -p \
  --routines --no-create-info --no-data --no-create-db --skip-opt --skip-triggers \
  --single-transaction --skip-comments \
  acm_basic > acm_basic.routines.sql
```
