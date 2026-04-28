# `acm_basic` 인벤토리

> 추출일: 2026-04-28 · MariaDB 11.8.5 (`127.0.0.1:3306/acm_basic`)
> 사용자 결정: `acm_*` 만 제외, 나머지는 모두 PostgreSQL로 이관 (Q1 가안, Q2 회원/시험 데이터는 분석용 별도 인입)

## 1. 전체 수치

| Object Type | Count |
|-------------|-------|
| BASE TABLE | 270 |
| VIEW | 2 |
| PROCEDURE | 35 |
| FUNCTION | 18 |
| TRIGGER | 0 |

총 데이터: **428.5 MB / 약 310만 행**

## 2. Prefix 분포 (테이블 270개)

| Prefix | 테이블 수 | 행 수 추정 | 데이터 크기 | 액션 |
|--------|---------|----------|----------|------|
| `TB_*` | 123 | 1,894,067 | 287.0 MB | ✅ MIGRATE — 윌비스 25년 레거시 |
| OTHER | 72 | 320,386 | 27.6 MB | ✅ MIGRATE — eGov/공통/고시/상담 |
| `acm_*` | 61 | 899,816 | 113.4 MB | ❌ EXCLUDE (회원/시험은 분석 인입) |
| `od_*` | 3 | 0 | 0.1 MB | ✅ MIGRATE — 신규 주문 |
| `pt_*` | 3 | 0 | 0.1 MB | ✅ MIGRATE — 신규 포인트 |
| `bk_*` | 3 | 0 | 0.1 MB | ✅ MIGRATE — 신규 교재 |
| `en_*` | 2 | 0 | 0.1 MB | ✅ MIGRATE — 신규 수강 |
| `ex_*` | 2 | 0 | 0.1 MB | ⚠️ MIGRATE 후 폐기 — `ex_mock_exam` (Q3 hopenvision exam_*로 통일) |
| `id_*` | 1 | 3 | 0.0 MB | ✅ MIGRATE — 신규 관리자 |

**이관 범위**: 270 - 61 = **209개 테이블** + 2 뷰 + 35 프로시저 + 18 함수

## 3. OTHER 72개 분류 (자세히)

| 카테고리 | 패턴 예 | 테이블 수 (추정) | 비고 |
|---------|--------|---------------|------|
| eGovFramework | `comtn*`, `comts*`, `comvn*` | 약 18 | 한국 전자정부 표준 (로그/모니터링/메뉴/탬플릿) |
| 공통코드 | `cmmn_*` | 3 | 공통 코드 마스터 |
| 고시 (공무원시험) | `gosi_*` | 16 | 시험 통계 핵심 — hopenvision exam과 매핑 검토 |
| 상담 | `counsel_*` | 3 | 1:1 상담 |
| 협력/쿠폰 | `coop_*` | 4 | 외부 협력사 쿠폰 |
| 회원 (eGov) | `gnrl_mber`, `entrprs_mber`, `emplyr_info`, `tbl_users` | 4 | View `comvnusermaster`가 통합 조회 |
| 우편번호 | `tb_zipcode`, `tb_zipcode_new` | 2 | 외부 데이터 (재인입 가능) |
| 게시판 (eGov) | `comtnbbs*` | 4 | |
| 인증/배치/로그 | `comtnloginlog`, `batch_*`, `web_log`, `sys_log`, `mb_access_log` | 약 10 | 운영 데이터 — 보존만 |
| 기타 | `author_info`, `role_info`, `roles_hierarchy`, `comtnmenuinfo` 등 | 약 8 | 권한 체계 |

## 4. 함수 18개 (PostgreSQL PL/pgSQL 변환 대상)

| 함수명 | 위험도 | PostgreSQL 변환 메모 |
|--------|-------|--------------------|
| **ENCRYPT** | 🔴 HIGH | MariaDB 자체 암호화 → `pgcrypto.pgp_sym_encrypt()` 또는 애플리케이션 레벨 |
| **DECRYPT** | 🔴 HIGH | 위와 동일 |
| **HASH_STR_DATA** | 🔴 HIGH | 알고리즘 동일성 검증 (MD5/SHA?) |
| ADVANCE_RECEIVED | 🟡 MID | 비즈니스 로직, JPA로 이전 검토 |
| FN_GET_BOOK_ORDER_CNT | 🟢 LOW | COUNT 단순 집계 |
| FN_GET_DATE_EXPIRED | 🟢 LOW | 날짜 비교 |
| FN_GET_GOSI_STANDARD | 🟡 MID | 고시 기준 산출 |
| FN_GET_LEC_BRG_REQ_CNT | 🟢 LOW | COUNT |
| FN_GET_LEC_ON_REQ_CNT | 🟢 LOW | COUNT |
| FN_GET_LEC_REST | 🟡 MID | 잔여 좌석 산출 |
| FN_GET_MULTI_BOOK_NM | 🟢 LOW | GROUP_CONCAT 대체 (`STRING_AGG`) |
| FN_GET_OFF_PRICE_PRF_PACKAGE | 🟡 MID | 패키지 가격 산출 |
| FN_GET_ON_PRICE_PRF_PACKAGE | 🟡 MID | 위와 동일 |
| FN_GET_PRICE_PRF_PACKAGE | 🟡 MID | |
| FN_GET_STUDY_DATE | 🟢 LOW | 날짜 계산 |
| GET_COUNSEL_USERCODE_NM | 🟢 LOW | 코드 → 이름 |
| GET_COUNSEL_USERLEC_NM | 🟢 LOW | |
| REVERSE_STR | 🟢 LOW | PostgreSQL `reverse()` 내장 |

## 5. 프로시저 35개 (PostgreSQL PL/pgSQL 변환 대상)

| 카테고리 | 프로시저 (예) | 처리 전략 |
|---------|------------|---------|
| **시퀀스 발급** | `GET_NEXTSEQ_NO`, `GET_NEXTSEQ_OFFNO`, `GET_NEXTSEQ_OFFORDERNO`, `GET_NEXTSEQ_ORDERNO`, `GET_EXAM_NEXTSEQ`, `GET_EXAM_IDENTYID`, `GET_EXAM_OFFERERID` | PostgreSQL `SEQUENCE` + `nextval()` 로 일괄 대체 |
| **통계 집계** | `SP_MAKE_GOSI_*` (5개), `SP_MAKE_OFF_SALES_STAT`, `SP_MAKE_ON_SALES_STAT` | PL/pgSQL 함수로 1:1 포팅 (배치성) |
| **포인트 적립** | `INSERT_POINT`, `SP_BUY_INSERT_POINT`, `SP_INS_BOOK_POINT`, `SP_SNS_INSERT_POINT` | JPA Service로 이전 검토 |
| **강의/교재 등록** | `INSERT_LECTURE`, `INSERT_LECTURE_PKG`, `SP_LECTURE_BOOK_INSERT`, `SP_LECTURE_OFF_BOOK_INSERT`, `SP_LECTURE_OFF_DAY_INSERT`, `EXT_MY_LECTURE_DAY` | JPA Service로 이전 권장 |
| **쿠폰** | `INSERT_COUPON`, `INSERT_COOP_COUPON`, `DELETE_COOP_COUPON` | JPA Service |
| **장바구니** | `SP_CART_DELETE`, `UPDATE_CART_JONG`, `UPDATE_OFF_CART_JONG` | JPA Service |
| **댓글** | `SP_INS_REPLY`, `SP_INS_EVENT_REPLY` | JPA Service |
| **회원 이벤트** | `SP_NEW_MEMBER_INSERT_EVENT`, `SP_NEW_MEMBER_UPDATE_EVENT` | JPA Service |
| **파티션** | `GET_DDL_PARTITION` | PostgreSQL `PARTITION BY` 네이티브로 대체 |

## 6. 뷰 2개 (PostgreSQL 호환 변환)

### `comvnusermaster`
- **목적**: 3개 회원 테이블(`gnrl_mber`, `emplyr_info`, `entrprs_mber`)의 통합 조회
- **변환**: `UNION ALL` 그대로 호환. 백틱(\` \`) → 쌍따옴표(\" \") 또는 제거
- **주의**: PostgreSQL은 `ORDER BY`가 마지막 SELECT 뒤에만 가능 → 구조 그대로 호환

### `v_inquiry`
- **목적**: legacy `tb_board_cs` + 신규 `tb_inquiry` 통합 1:1 문의 조회
- **변환 핫스팟**:
  - `convert(... using utf8mb4)` → 제거 (PostgreSQL은 이미 UTF8)
  - `cast(... as char(20) charset utf8mb4)` → `CAST(... AS VARCHAR(20))`
  - `case ... when ... then ... else ... end` → 그대로 호환
  - `coalesce()` → 그대로 호환

## 7. acm_* 61개 중 분석용 인입 후보 (Q2)

회원/시험 데이터를 분석/통계/테스트 자료로 별도 인입. 별도 schema(`analytics`)로 격리 권장.

추출 명령 (Phase 3):
```bash
mysqldump -h 127.0.0.1 -P 3306 -u root -p \
  --skip-extended-insert \
  acm_basic $(mysql -h 127.0.0.1 -P 3306 -u root -p acm_basic -B -N -e \
    "SELECT GROUP_CONCAT(table_name SEPARATOR ' ') FROM information_schema.tables \
     WHERE table_schema='acm_basic' AND table_name LIKE 'acm\\_member%' \
        OR table_name LIKE 'acm\\_exam%'") \
  > acm_analytics_seed.sql
```

## 8. 다음 단계

이 인벤토리를 입력으로 다음 작업 수행:
1. **Task #2** — hopenvision Sprint 0 V2~V7 revert 범위 확정 (충돌 회피)
2. **Task #3** — `ex_mock_exam` 폐기 ADR 작성
3. **Task #6** — Phase 1 Flyway 스크립트 분할 계획 (V8~V?? 매핑)
