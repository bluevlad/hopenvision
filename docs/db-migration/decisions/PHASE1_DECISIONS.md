# Phase 1 의사결정 로그

> 작성일: 2026-04-28 (owner 승인 완료)
> 관련: [PHASE1_FLYWAY_PLAN.md](../PHASE1_FLYWAY_PLAN.md), [ADR-001](../../adr/ADR-001-academy-integration.md)

PHASE1 PLAN의 미해결 의사결정 6건에 대한 owner 결정 기록.
Phase 1 작업 중 이 문서가 단일 진실 원천(SoT)이며, PLAN/ADR은 본 문서를 참조한다.

---

## D-1. REVERT_SPRINT0 옵션 — **A안 채택**

**결정**: 운영 hopenvision DB에서 V2~V7 적용분을 수동으로 정리한 후, 소스 V2~V7 SQL 파일 삭제. academy 마이그레이션은 V2부터 새로 시작.

**근거**:
- V2~V7로 생성된 30개 테이블의 데이터가 사실상 0 (id_member_grade 4행 + pl_role 4행 = seed)
- 소스 트리가 깨끗 → 신규 개발자 진입 장벽 ↓
- ADR/PLAN에서 "V2~V7은 폐기됨" 별도 설명 불필요

**영향**:
- PHASE1 PLAN의 V8~V60 → **V2~V54로 시프트** (-6)
- REVERT PR이 운영 DB 수동 SQL 실행을 owner에게 의존
- 운영 DB SQL: `DROP TABLE ... CASCADE` + `DELETE FROM flyway_schema_history WHERE version IN ('2','3','4','5','6','7')`

---

## D-2. 시간 타입 — **TIMESTAMP 채택** (TIMESTAMPTZ 아님)

**결정**: 모든 `DATETIME` → `TIMESTAMP` (timezone 없음).

**근거**:
- hopenvision 기존 `exam_*` 테이블이 `TIMESTAMP` 사용 — 통합 후 일관성
- 학원 운영은 KST 단일 timezone — TIMESTAMPTZ 오버스펙
- Spring/JPA에서 `LocalDateTime` 매핑이 자연스러움

**영향**:
- 자동 변환 룰: `s/datetime/TIMESTAMP/gi` (단순)
- 향후 다국가/다지역 운영 시 별도 ADR로 재평가

---

## D-3. TINYINT(1) 매핑 — **SMALLINT 채택** (BOOLEAN 아님)

**결정**: 모든 `TINYINT(1)` → `SMALLINT` (0/1 정수).

**근거**:
- academy MyBatis Mapper 400+가 `WHERE flag = 1` 직접 비교 다수 — Boolean 변환 시 PostgreSQL `WHERE flag = TRUE`로 모두 수정 필요
- JPA 측은 `Short` 또는 `Integer` 매핑으로 처리 가능
- 운영 호환성 > 코드 우아함

**영향**:
- 자동 변환 룰: `s/tinyint(1)/SMALLINT/gi`
- 영향 테이블 6개: `batch_schdul`, `batch_schdul_dfk`, `bk_book`, `bk_delivery`, `bk_delivery_address`, `gosi_stat_mst`, `gosi_subject` (`ex_mock_*`은 폐기)

---

## D-4. ENCRYPT/DECRYPT/HASH_STR_DATA — **현재 미적용** (실 사용자 로그인은 별도 신규 시스템)

**결정**:
- Phase 1에서 `ENCRYPT`, `DECRYPT`, `HASH_STR_DATA` 함수 변환·이전 **수행하지 않음**
- 통합 hopenvision의 사용자 로그인/패스워드 암호화는 **별도 신규 인증 시스템**으로 구성 (BCrypt + Spring Security 표준)
- academy 측 암호화된 데이터는 **분석용 archive 데이터로만 보존** (복호화 불필요)

**근거**:
- MariaDB 자체 암호화 알고리즘과 PostgreSQL `pgcrypto`의 호환 불가 — 데이터 재암호화 부담 회피
- 통합 시스템의 회원 모델은 hopenvision `id_member` 기반으로 새로 구축 — 기존 password hash 이관 의미 없음
- 회원 데이터는 이메일 + 신규 패스워드 등록 플로우로 흡수 (기존 패스워드 폐기)

**영향**:
- PHASE1 PLAN에서 V54(crypto setup) **삭제**
- ENCRYPT/DECRYPT 사용 컬럼은 PG에서 BYTEA 그대로 보존 (분석 dump 인입 시 raw로 두고 사용 불가 표시)
- HASH_STR_DATA 사용처도 그대로 보존 (재계산 불필요)
- 실제 사용자 로그인은 별도 ADR로 신규 인증 시스템 설계 (Phase 2 예정)

**미해결 후속 결정**:
- 회원 이관 플로우 시 기존 academy 회원에게 "신규 패스워드 등록 안내" 메일 발송 정책
- OAuth(Google) 만 허용할지, 이메일+패스워드 병행할지

---

## D-5. 프로시저 35개 — **제안한 분할 채택** (비즈니스 JPA, 통계 PL/pgSQL)

**결정**: 프로시저를 그룹별로 다르게 처리.

| 그룹 | 개수 | 처리 |
|-----|----|----|
| **PG SEQUENCE 대체** | 7 | `GET_NEXTSEQ_*`, `GET_EXAM_*` → `CREATE SEQUENCE` + `nextval()` |
| **JPA Service 이전** | 약 20 | 포인트 적립, 강의/교재 등록, 쿠폰, 카트, 댓글, 회원 이벤트 — DB 함수 미생성, Spring Service 레이어에서 구현 |
| **PL/pgSQL 1:1 포팅** | 약 7 | 통계 배치 (`SP_MAKE_GOSI_*`, `SP_MAKE_*_SALES_STAT`) — DB 함수 유지, 스케줄러에서 호출 |
| **미이전** | 1 | `GET_DDL_PARTITION` (PG는 PARTITION BY 네이티브) |

**근거**:
- 비즈니스 로직은 트랜잭션 경계 명확화 + 테스트 용이성을 위해 애플리케이션 레이어로
- 통계 배치는 대용량 집계가 DB 내부에서 수행되는 게 효율적

**영향**:
- PHASE1 PLAN의 V51~V60 그대로 유지 (V51 시퀀스, V52~V53 함수, V55~V60 프로시저)
- Phase 2 Java 작업 시 JPA로 이전할 프로시저 20개 목록을 별도 워크 아이템으로 추적

---

## D-6. TB_* 컬럼명/테이블명 정규화 — **단계적 정규화 + 매핑 가이드 별도 관리**

**결정**: 정규화는 2단계로 진행.

### Phase 1 (지금) — **케이스 정규화만**
- 테이블명: `TB_MA_MEMBER` → `tb_ma_member` (lowercase, prefix 보존)
- 컬럼명: `USER_ID` → `user_id` (snake_case lowercase)
- TB_ prefix는 그대로 유지 → 자동 변환 가능, 모든 SQL/Mapper 호환

### Phase 1.5 (별도 PR) — **도메인별 prefix 재명명** (선택적, 도메인 분석 후)
- 예: `tb_ma_member` → `member_legacy` 또는 `legacy_member`
- 예: `tb_lec_mst` → `lecture_master_legacy`
- TB_ → 도메인 분류 매핑은 academy `package-info.java` + ADR-005의 prefix 매핑 표 활용
- **각 rename마다 매핑 row 추가**: `legacy_table_mapping` 테이블 (academy_table, hopenvision_table, renamed_at, reason)

### 가이드 문서 (Claude-Opus-bluevlad)
다음 2개 문서를 새로 작성:
1. `Claude-Opus-bluevlad/standards/db/NAMING_CONVENTION.md`
   - PostgreSQL 식별자 컨벤션 (snake_case lowercase, 단복수, 약어 처리)
   - 테이블 prefix 정책 (도메인별 prefix vs flat)
   - hopenvision 통합 후 표준 (모듈 prefix 9개 + tb_ legacy 예외)
2. `Claude-Opus-bluevlad/standards/db/LEGACY_TB_MAPPING.md`
   - 윌비스 25년 레거시 TB_* 123개의 매핑 표
   - 컬럼: TB_원본 / Phase1_normalized / Phase1.5_renamed / 도메인 / 사용처 (Mapper 위치)
   - 신규 개발자가 "TB_MA_MEMBER가 뭐야?" 질문 1회 해결

**근거**:
- 한 번에 모든 정규화하면 위험 ↑ (테이블 123개 + 컬럼 수천 개)
- 케이스 정규화만으로도 PostgreSQL/JPA 표준 호환 달성
- 도메인 prefix 변경은 academy 패키지/Mapper 전수 검토 후 진행

**영향**:
- 자동 변환 룰에 케이스 정규화 단계 추가 (`tr 'A-Z' 'a-z'` 등)
- ADR-005의 "TB_* 변경 금지" 정책 → 본 결정으로 **케이스 변경은 허용** 으로 갱신 (ADR-005에 cross-reference 추가 필요)

---

## 다음 액션 (이 결정에 따른 후속 작업)

1. **이 문서 커밋** + 기존 PLAN/REVERT 갱신 (Q섹션 → 결정 반영)
2. **Task #8**: Claude-Opus-bluevlad 가이드 2개 문서 작성 + ADR-005 cross-reference 갱신
3. **Phase 1-A 본 작업 시작**:
   - 자동 변환 스크립트 (`scripts/mariadb-to-pg.sh`) 작성
   - V2~V54 (옵션A 시프트) 실제 SQL 파일 작성
4. **REVERT PR** 작성 (V2~V7 + identity 실구현 삭제)
   - 운영 DB 수동 SQL 실행 가이드 첨부
