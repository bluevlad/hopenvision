# Phase 1 — Academy DDL → Hopenvision Flyway 분할 계획

> 작성일: 2026-04-28
> 입력: `source/acm_basic.{schema,routines,views}.sql`, `source/inventory.md`
> 의존: [REVERT_SPRINT0.md](REVERT_SPRINT0.md), [ADR-001-academy-integration.md](../adr/ADR-001-academy-integration.md), [PHASE1_DECISIONS.md](decisions/PHASE1_DECISIONS.md)
> **결정 반영** (2026-04-28): REVERT 옵션 **A 확정** → academy 마이그레이션은 **V2부터** 시작. 본 문서의 V8~V60 표기는 **V2~V54 로 시프트** (-6).

## 1. 목표

academy `acm_basic` MariaDB의 **209개 테이블 + 2 뷰 + 35 프로시저 + 18 함수**를 hopenvision PostgreSQL로 변환·이관한다. Phase 1은 **DDL 변환만** 다룸 (데이터 ETL은 Phase 3).

## 2. 변환 핫스팟 인벤토리

`acm_basic.schema.sql` (249 KB) 정량 분석:

| 패턴 | 발생 횟수 | 변환 방법 |
|------|---------|---------|
| `AUTO_INCREMENT` (테이블 51개) | 43 occurrences | `BIGSERIAL` 또는 `INTEGER GENERATED ALWAYS AS IDENTITY` |
| `ON UPDATE CURRENT_TIMESTAMP` | 6 | 트리거 함수 + BEFORE UPDATE 트리거 (또는 JPA `@PreUpdate`) |
| `TINYINT(1)` (테이블 6개) | 6 | `BOOLEAN` 또는 `SMALLINT` (운영 코드가 0/1 직접 비교 시 SMALLINT 안전) |
| `MEDIUMTEXT/LONGTEXT` | 5 | `TEXT` (PG는 무제한) |
| `LONGBLOB` (BLOB) | 25 | `BYTEA` |
| `ENGINE=InnoDB` | 270 | 제거 (CREATE TABLE 종료 후 절 삭제) |
| `CHARSET=utf8mb3/utf8mb4 COLLATE=...` | 270 | 제거 (DB 레벨 UTF8) |
| `DATETIME` | 182 | `TIMESTAMP` (또는 `TIMESTAMPTZ` — 별도 결정) |
| `DATETIME DEFAULT ...` | 142 | DEFAULT 그대로, `current_timestamp()` → `CURRENT_TIMESTAMP` |
| `DATETIME NOT NULL DEFAULT current_timestamp` | 24 | 그대로 호환 (기본값만) |
| `DOUBLE`, `FLOAT` | 2 | `DOUBLE PRECISION`, `REAL` |
| ENUM | 0 | (없음) |
| JSON | 0 | (없음) |
| FULLTEXT KEY | 0 | (없음 — pg_trgm 도입 불필요) |
| PARTITION BY | 0 | (없음 — 운영 시 필요하면 후속 결정) |

**시사점**: MariaDB 전용 exotic 문법(JSON, ENUM, FULLTEXT, GENERATED, PARTITION)이 0건 → 자동화 변환 가능 비율 높음.

## 3. Flyway 마이그레이션 분할 (V8~V60 권장)

### 원칙
- **도메인별 그룹화** (alphabet 순서 X)
- 각 V는 1~10개 테이블 (가능하면 같은 prefix만)
- 종속성 순서 보장 (FK 참조하는 쪽이 나중)
- 데이터 INSERT는 별도 V (DDL과 분리)
- 프로시저/함수는 V51~ 후반부에 (테이블 모두 만든 후)

### V8~V60 그룹 매핑

```
V8   identity_admin                      id_admin (1 table)                              [academy V2 → PG]
V9   platform_common_codes               cmmn_code, cmmn_cl_code, cmmn_detail_code (3)   [공통코드]
V10  platform_egov_user_master           gnrl_mber, emplyr_info, entrprs_mber (3)         [eGov 회원]
V11  platform_egov_auth                  emplyrscrtyestbs, role_info, roles_hierarchy, author_info, author_role_relate, sys_log, mb_access_log, off_user, on_user, tbl_users (10) [eGov 권한/로그]
V12  platform_egov_bbs                   comtnbbs, comtnbbsmaster, comtnbbsmasteroptn, comtnbbsuse (4) [eGov 게시판]
V13  platform_egov_log                   comtnloginlog, comtnloginpolicy, comtnntwrksvcmntrng, comtnntwrksvcmntrngloginfo, comtnprivacylog, comtntrsmrcvlog, comtnuserlog, comtsbbssummary, comtssyslogsummary, comtstrsmrcvlogsummary, comtsweblogsummary, comtnprogrmlist, comtntmplatinfo, comtnmenuinfo, comvnusermaster_table_if_any (eGov 로그/모니터링 약 14) 
V14  platform_misc                       sc_tran, ba_config_cd, batch_opert, batch_schdul, batch_schdul_dfk, backup_opert, web_log, www_poll, www_poll_item (9)
V15  legacy_TB_member                    TB_MA_MEMBER, tb_tm_users, tm_device_history, tm_ist (윌비스 회원 4~6)
V16  legacy_TB_lecture                   TB_LEC_MST, TB_LEC_DET, TB_SUBJECT_INFO, tb_movie, tb_mymovie, tb_mylecture, tb_off_mylecture (등 강의 마스터 약 15)
V17  legacy_TB_order                     TB_ORDERS, tb_orders, tb_off_approvals, tb_approvals, tb_order_mgnt_no, tb_off_order_mgnt_no, tb_pmp_downlog (약 10)
V18  legacy_TB_book                      TB_BOOK*, tb_delivers (약 8)
V19  legacy_TB_board                     TB_BOARD_CS, tb_board, tb_tm_board (약 5)
V20  legacy_TB_misc                      tb_zipcode, tb_zipcode_new, tb_mileage_history, tb_tm_mycoupon, tb_off_user, ... (잔여 TB_* 약 30)
... (TB_* 123개를 V15~V25 사이에서 도메인별로 분할)

V26  identity_member_extension            id_member, id_member_grade, id_member_grade_history (3)  [hopenvision 신규 회원 모델 + academy 매핑]
V27  identity_legacy_map                  id_member_legacy_map (academy ↔ hopenvision 매핑) (1)
V28  content_lecture_extension            ct_category, ct_lecture, ct_subject, ct_teacher, ct_lecture_chapter (5)
V29  enrollment_cart                      en_cart_item (academy V5)
V30  enrollment_entitlement               en_enrollment, en_progress, en_reenroll_request (3)
V31  order_main                           od_order, od_order_item, od_payment, od_refund, od_cart (5)
V32  point_coupon                         pt_coupon, pt_coupon_user, pt_mileage_ledger, pt_member_coupon (4)
V33  book_catalog                         bk_book, bk_catalog, bk_inventory (3)
V34  book_delivery                        bk_delivery_address, bk_delivery, bk_delivery_item, bk_shipping_address (4)
V35  platform_role_menu                   pl_code, pl_code_group, pl_role, pl_member_role, pl_menu (5)
V36  inquiry_main                         tb_inquiry, tb_inquiry_file, tb_category_mapping (3)
V37  inquiry_ai                           tb_inquiry_train, tb_inquiry_analysis, tb_inquiry_routing_log, tb_inquiry_stats_monthly, tb_inquiry_embedding (5)
V38  gosi_master                          gosi_mst, gosi_cod, gosi_subject, gosi_sbj_mst, gosi_area_mst, gosi_pass_mst, gosi_pass_sta, gosi_stat_mst, gosi_vod (9)
V39  gosi_result                          gosi_rst_mst, gosi_rst_det, gosi_rst_sbj, gosi_rst_smp (4)
V40  counsel                              counsel_rst, counsel_sch, counsel_time (3)
V41  coop                                 coop_mst, coop_coupon, coop_coupon_mst, cop_seq (4)
V42  notuse_misc                          notuse_coupon_lecture, material_menu_mst, off_user, on_user 등 분류외 잔여 (varies)

V50  views                                comvnusermaster_view, v_inquiry_view (PostgreSQL 호환 변환)
V51  sequences                            seq_orderno, seq_offno, seq_offorderno, seq_no, seq_exam_nextseq, seq_exam_identyid, seq_exam_offererid (7)
       — 7개 GET_NEXTSEQ_* 프로시저를 PostgreSQL SEQUENCE로 일괄 대체

V52  functions_simple                     REVERSE_STR(text)→reverse 내장 사용, FN_GET_DATE_EXPIRED, FN_GET_BOOK_ORDER_CNT, 
                                          FN_GET_LEC_BRG_REQ_CNT, FN_GET_LEC_ON_REQ_CNT, FN_GET_LEC_REST,
                                          FN_GET_MULTI_BOOK_NM (STRING_AGG 사용),
                                          FN_GET_STUDY_DATE, GET_COUNSEL_USERCODE_NM, GET_COUNSEL_USERLEC_NM (10)
V53  functions_business                    ADVANCE_RECEIVED, FN_GET_GOSI_STANDARD, 
                                          FN_GET_OFF_PRICE_PRF_PACKAGE, FN_GET_ON_PRICE_PRF_PACKAGE,
                                          FN_GET_PRICE_PRF_PACKAGE (5)
V54  functions_crypto_pgcrypto_setup       CREATE EXTENSION IF NOT EXISTS pgcrypto;
                                           ENCRYPT/DECRYPT 정책 결정 — pgp_sym_encrypt 매핑 또는 애플리케이션 BCrypt로 이전
                                           HASH_STR_DATA 알고리즘 명세 확인 후 매핑 (별도 검증 필요)

V55  procedures_business_logic             SP_BUY_INSERT_POINT, SP_INS_BOOK_POINT, SP_SNS_INSERT_POINT, INSERT_POINT 
                                          (포인트 적립 4개) — JPA Service로 이전 권장 (DB 의존 최소화)
V56  procedures_lecture_book               INSERT_LECTURE, INSERT_LECTURE_PKG, SP_LECTURE_BOOK_INSERT,
                                          SP_LECTURE_OFF_BOOK_INSERT, SP_LECTURE_OFF_DAY_INSERT, EXT_MY_LECTURE_DAY (6)
V57  procedures_coupon_cart                INSERT_COUPON, INSERT_COOP_COUPON, DELETE_COOP_COUPON,
                                          SP_CART_DELETE, UPDATE_CART_JONG, UPDATE_OFF_CART_JONG (6)
V58  procedures_reply_member               SP_INS_REPLY, SP_INS_EVENT_REPLY,
                                          SP_NEW_MEMBER_INSERT_EVENT, SP_NEW_MEMBER_UPDATE_EVENT (4)
V59  procedures_gosi_stat                  SP_MAKE_GOSI_ADJUST, SP_MAKE_GOSI_ADJ_MST, SP_MAKE_GOSI_EXAM_RESULT,
                                          SP_MAKE_GOSI_STANDARD, SP_MAKE_GOSI_STAT,
                                          SP_MAKE_OFF_SALES_STAT, SP_MAKE_ON_SALES_STAT (7) — 통계 배치
V60  procedures_misc                       GET_DDL_PARTITION (PG는 PARTITION BY 네이티브, 미이전)
                                           cleanup
```

> **EXCLUDED (ADR-001)**: `ex_mock_exam`, `ex_mock_attempt` — 어떤 V에도 포함시키지 않음

### V 번호 할당 정책
- V8~V25: legacy + eGov + 공통코드 (FK가 없거나 마스터 성격)
- V26~V42: 신규 prefix 도메인 (FK 종속 있음, 순서 중요)
- V50~V54: 뷰, 시퀀스, 함수
- V55~V60: 프로시저
- V70+ 예약: 데이터 시드 (Phase 3)

## 4. 자동화 가능 변환 (스크립트화 대상)

다음 8개 패턴은 sed/awk 또는 Python 스크립트로 일괄 변환 가능 — `scripts/mariadb-to-pg.sh` (Phase 1-B에서 작성):

| 변환 룰 | sed 패턴 (예) |
|--------|------------|
| **케이스 정규화** (D-6 Phase 1) | 식별자(테이블명, 컬럼명, 인덱스명, FK명) → lowercase. `TB_MA_MEMBER` → `tb_ma_member`, `USER_ID` → `user_id`. **TB_ prefix는 보존** |
| 백틱 식별자 제거 | `s/\`//g` (PostgreSQL은 따옴표 없이도 lower-case 식별자 가능) |
| `ENGINE=...DEFAULT CHARSET=...COLLATE=...` 절 제거 | `s/) ENGINE=.*$/);/g` |
| `AUTO_INCREMENT` → `GENERATED ALWAYS AS IDENTITY` | `s/AUTO_INCREMENT/GENERATED ALWAYS AS IDENTITY/g` |
| `int(N)` → `INTEGER`, `bigint(N)` → `BIGINT` | `s/int([0-9]\+)/INTEGER/g` etc. |
| `tinyint(1)` → `SMALLINT` (보수적 선택) | `s/tinyint(1)/SMALLINT/g` |
| `datetime` → `TIMESTAMP` | `s/datetime/TIMESTAMP/g` |
| `mediumtext\|longtext` → `TEXT` | `s/mediumtext\|longtext/TEXT/g` |
| `longblob\|blob` → `BYTEA` | `s/longblob\|blob/BYTEA/g` |
| `varchar(N) CHARSET ...` → `VARCHAR(N)` | `s/CHARSET [a-z0-9_]*\( COLLATE [a-z0-9_]*\)\?//g` |
| `current_timestamp()` → `CURRENT_TIMESTAMP` | (이미 호환) |
| `KEY \`name\` (...)` (보조 인덱스) → `CREATE INDEX name ON table (...)` | 별도 후처리 필요 |
| `ON UPDATE CURRENT_TIMESTAMP` 제거 → 트리거 추가 | 별도 V에 트리거 함수 정의 |

자동화 후 **수동 검증 필수 항목**:
- FK 참조 순서 (테이블 생성 순서)
- 인덱스 이름 충돌 (PostgreSQL은 schema 단위 unique)
- 한글 컬럼 코멘트 (`COMMENT '...'` → `COMMENT ON COLUMN ...`)
- DEFINER 절 (함수/프로시저) 제거
- DELIMITER 절 (PostgreSQL은 `$$`)

## 5. 수동 변환 필수 (자동화 불가)

### 5.1 함수 18개 — 위험도별 처리

🟢 **LOW (5분 내 변환 가능, 9개)**:
- `REVERSE_STR(s)` → PostgreSQL `reverse(s)` 내장 함수 사용 (아예 함수 만들 필요 없음)
- `FN_GET_BOOK_ORDER_CNT`, `FN_GET_LEC_BRG_REQ_CNT`, `FN_GET_LEC_ON_REQ_CNT` — 단순 COUNT 집계
- `FN_GET_DATE_EXPIRED`, `FN_GET_STUDY_DATE` — 날짜 비교/계산
- `FN_GET_LEC_REST` — 잔여 좌석 산출 (단순 차감)
- `FN_GET_MULTI_BOOK_NM` — `GROUP_CONCAT` → `STRING_AGG(book_nm, ', ')`
- `GET_COUNSEL_USERCODE_NM`, `GET_COUNSEL_USERLEC_NM` — 코드→이름 룩업

🟡 **MID (30분~1시간, 5개)**:
- `ADVANCE_RECEIVED` — 비즈니스 로직, 스펙 확인 필요
- `FN_GET_GOSI_STANDARD` — 고시 기준 산출 (조건 분기 다수)
- `FN_GET_OFF_PRICE_PRF_PACKAGE`, `FN_GET_ON_PRICE_PRF_PACKAGE`, `FN_GET_PRICE_PRF_PACKAGE` — 패키지 가격 산출 (가격 정책 검증 필요)

🔴 **HIGH (반나절 이상, 4개) — 보안/암호화**:
- `ENCRYPT(STR, HASH_KEY) RETURNS VARBINARY(2048)` — MariaDB 자체 암호화 (대칭키)
- `DECRYPT(XCRYPT, HASH_KEY) RETURNS VARCHAR(2000)` — 위와 페어
- `HASH_STR_DATA() RETURNS INT` — 인자 없음 (random hash?), 사용처 추적 후 결정
- 변환 옵션:
  - (A) `pgcrypto.pgp_sym_encrypt(str, key)` → 알고리즘 다름, 기존 암호화 데이터 복호화 불가 → **데이터 재암호화 필수** (어려움)
  - (B) 애플리케이션 레벨로 이전 (Spring `Cipher` AES) → DB 함수 호출하던 코드 모두 수정
  - (C) MariaDB와 동일한 알고리즘을 PG `pgcrypto`로 재현 (가능 여부 검증 필요)
  - **사용 데이터 위치 추적 후 결정** — `acm_member.password`, `tbl_users.user_pwd` 등에 사용된 것으로 추정

### 5.2 프로시저 35개 — 처리 전략별 그룹

| 그룹 | 개수 | 처리 |
|-----|----|----|
| **PG SEQUENCE로 대체** | 7 (GET_NEXTSEQ_*, GET_EXAM_*) | V51에서 일괄 SEQUENCE 생성, 호출처는 `nextval('seq_name')` |
| **JPA Service 이전 권장** | 약 20 (포인트/쿠폰/카트/강의/회원이벤트) | DB에는 만들지 않고 Service 레이어에서 구현 (트랜잭션 명확) |
| **PL/pgSQL 1:1 포팅** | 약 7 (SP_MAKE_*_STAT, GET_DDL_PARTITION 제외) | 통계 배치 — DB 함수 유지 (스케줄러에서 호출) |

### 5.3 뷰 2개

**`comvnusermaster`** — academy ADR-005의 `comvnusermaster_view` 패턴:
- `gnrl_mber UNION ALL emplyr_info UNION ALL entrprs_mber`
- PostgreSQL 변환: 백틱 제거, 별칭 그대로, ORDER BY 마지막 절 (PG 호환)
- **추가 통합 가능성**: 통합 후에는 `id_member`도 UNION ALL로 추가 검토 (또는 `comvnusermaster_v2` 신규 작성)

**`v_inquiry`** — legacy + 신규 1:1 문의 통합:
- `convert(... using utf8mb4)` → 제거
- `cast(... as char(20) charset utf8mb4)` → `CAST(... AS VARCHAR(20))`
- `case ... when ... then ... else ... end` → 그대로 호환

## 6. 의사결정 (2026-04-28 owner 확정)

상세는 [PHASE1_DECISIONS.md](decisions/PHASE1_DECISIONS.md) 참조.

| # | 결정 | Plan 영향 |
|---|------|--------|
| D-1 | REVERT 옵션 **A** (운영 DB 수동 정리, V2부터 academy) | V8~V60 → **V2~V54** 시프트 |
| D-2 | 시간 타입 **TIMESTAMP** (TIMESTAMPTZ 아님) | `s/datetime/TIMESTAMP/gi` |
| D-3 | `TINYINT(1)` → **SMALLINT** (운영 호환) | `s/tinyint(1)/SMALLINT/gi`, JPA는 `Short` 매핑 |
| D-4 | ENCRYPT/DECRYPT/HASH_STR_DATA **미적용** | V54 (crypto setup) **삭제**, 사용자 로그인은 별도 신규 인증 시스템 |
| D-5 | 프로시저: 비즈니스 **JPA**, 통계 배치 **PL/pgSQL** | V51 시퀀스 / V52~V53 함수 / V55~V60 통계 프로시저만 |
| D-6 | TB_* **케이스 정규화만** (Phase 1) + 도메인 rename은 Phase 1.5 별도 PR | 자동 변환 룰에 lowercase 단계 추가, ADR-005 cross-ref 갱신 필요 |

## 7. 산출물 (Phase 1 완료 시점)

```
hopenvision/
├── api/src/main/resources/db/migration/
│   ├── V8__identity_admin.sql
│   ├── V9__platform_common_codes.sql
│   ├── ...
│   └── V60__procedures_misc.sql            (총 약 53개 V 파일)
├── docs/db-migration/
│   ├── source/                              (Phase 0 완료, 이미 존재)
│   │   ├── README.md
│   │   ├── inventory.md
│   │   ├── tables.tsv
│   │   ├── acm_basic.schema.sql
│   │   ├── acm_basic.routines.sql
│   │   └── acm_basic.views.sql
│   ├── REVERT_SPRINT0.md                    (Phase 0 완료)
│   ├── PHASE1_FLYWAY_PLAN.md                (이 문서)
│   ├── conversion-rules.md                  (Phase 1-B 자동화 룰 상세)
│   ├── checksum-validation.md               (Phase 1-C 검증 결과)
│   └── decisions/
│       ├── Q-PHASE1-1-revert-version.md
│       ├── Q-PHASE1-2-timestamp-tz.md
│       ├── Q-PHASE1-3-tinyint-mapping.md
│       └── Q-PHASE1-4-crypto-strategy.md
├── docs/adr/
│   └── ADR-001-academy-integration.md       (Phase 0 완료)
└── scripts/
    └── mariadb-to-pg.sh                     (Phase 1-B 자동 변환)
```

## 8. 일정 추정 (참고용, 1인 풀타임 기준)

| 단계 | 작업 | 예상 기간 |
|-----|-----|---------|
| 1-A | 의사결정 6개 (Q-PHASE1-1~6) | 1일 |
| 1-B | mariadb-to-pg.sh 자동 변환 스크립트 작성 | 2~3일 |
| 1-C | V8~V42 자동 변환 결과 검증 + 수동 보완 | 1~2주 |
| 1-D | V50 뷰 2개 변환 + 검증 | 0.5일 |
| 1-E | V51 시퀀스 7개 + V52 LOW 함수 9개 | 1일 |
| 1-F | V53 MID 함수 5개 + V54 ENCRYPT/DECRYPT 정책 결정 | 3~5일 |
| 1-G | V55~V60 프로시저 28개 (JPA 이전 또는 PL/pgSQL 포팅) | 1~2주 |
| 1-H | dev DB 통합 시뮬레이션 (V8~V60 일괄 실행 + 회귀 테스트) | 3일 |
| **합계** | **약 4~6주 (1인 풀타임)** | |

본 추정은 데이터 ETL (Phase 3)과 Java 코드 이식 (Phase 2) 미포함.

---

## Phase 1 완료 정의 (Definition of Done)

- [ ] V8~V60 (또는 V2~V54) 모든 Flyway 스크립트 작성 완료
- [ ] dev DB(`hopenvision_dev`)에 V8~V60 일괄 실행 성공 (오류 0)
- [ ] 모든 209개 테이블 + 2 뷰 + 시퀀스 + 함수 + 프로시저가 PG에 존재
- [ ] `flyway_schema_history` validation 통과
- [ ] PR 작성 (브랜치: `feature/academy-integration-phase1`)
- [ ] 6개 미해결 의사결정 모두 ADR 또는 PR description에 기록

Phase 1 완료 후 Phase 2(Java 이식) → Phase 3(데이터 ETL) → Phase 4(cut-over) 순으로 진행.
