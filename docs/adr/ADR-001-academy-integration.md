# ADR-001 — Academy 흡수 통합 및 모의고사 시스템 정본 결정

- Status: **Proposed** (사용자 승인 후 Accepted 전환)
- Date: 2026-04-28
- Deciders: owner (rainend) + Claude
- 관련: [ADR-005 academy DB 테이블 전략](../../../Claude-Opus-bluevlad/services/academy/adr/ADR-005-db-table-strategy.md), [edufit ADR-002 PostgreSQL 단일화](../../../Claude-Opus-bluevlad/services/edufit/adr/002-unified-postgresql-db.md)

---

## 1. 컨텍스트

### 1.1 현재 두 서비스의 분리 운영 상태

- **academy** (`/Users/rainend/GIT/academy`)
  - Spring Boot 3.2 (Java 21) + Maven + MyBatis
  - MariaDB 11.8 (`acm_basic`, 로컬 3306)
  - 270 테이블 / 2 뷰 / 35 프로시저 / 18 함수 / 약 428 MB
  - 학원 전반 운영 시스템 (수강/주문/결제/포인트/교재/배송/고시/문의/회원)
- **hopenvision** (`/Users/rainend/GIT/hopenvision`, 본 레포)
  - Spring Boot 3.2 (Java 17) + Gradle + JPA
  - PostgreSQL 15 (`hopenvision`, Docker 내부)
  - 20개 exam/question/user 테이블 — 공무원 시험 모의고사·채점 특화
  - 공무원 시험 응시·채점·통계 대시보드

### 1.2 통합 의사결정의 배경

owner 결정사항:
1. 두 서비스를 단일 운영 시스템으로 통합 (프로젝트명 `hopenvision` 유지)
2. **academy의 학원 전반 구조**가 base, 여기에 **hopenvision의 모의고사 시스템**을 흡수
3. PostgreSQL 단일 인스턴스로 통일 (기존 `hopenvision` DB 확장)
4. MyBatis → JPA 일괄 전환 (academy MyBatis 코드는 archive로 보존)
5. `acm_*` 제외 모든 객체 (TB_*, tb_*, id_/en_/od_/pt_/bk_/ex_, OTHER 72개) 이관
6. `acm_*` 회원·시험 데이터는 분석/통계/테스트용으로 별도 schema 인입

### 1.3 모의고사 시스템 충돌

academy와 hopenvision 모두 모의고사 도메인을 가지고 있어 정본 결정이 필요:

**academy 측** (`ex_*` prefix, `/Users/rainend/GIT/academy/backend/src/main/resources/db/migration/V7__mocktest.sql`):
- `ex_mock_exam` — 모의고사 마스터 (PK: CHAR(36) UUID)
  - 컬럼: exam_id, name, subject_cd, schedule_date, max_score, is_open, created_at
  - **현재 데이터: 0행**
- `ex_mock_attempt` — 응시 기록 (PK: CHAR(36) UUID)
  - 컬럼: attempt_id, user_id, exam_id, score, status, answer_sheet (TEXT), registered_at, submitted_at
  - **현재 데이터: 0행**
- 운영 사용 흔적 없음 (Sprint 1-1 시점에 신규 정의된 skeleton)

**hopenvision 측** (`exam_*` 시리즈, 운영 중):
- `exam_mst` (2행), `exam_subject`, `exam_question`, `exam_answer_key`, `exam_applicant`, `exam_applicant_ans`, `exam_applicant_score`, `exam_pass_line`, `exam_stat`, `exam_notice`
- `question_bank_group`, `question_bank_item`, `question_set`, `question_set_item`
- `user_answer`, `user_score`, `user_total_score`, `user_profile`
- `subject_master` (110행 — 과목 마스터 데이터)
- `import_job_history` — 비동기 채점 잡 추적
- 총 20개 테이블, 운영 중 (체점/통계/엑셀 import 모두 구현 완료)

---

## 2. 결정

### 2.1 모의고사 시스템 정본: **hopenvision `exam_*` 시리즈**

이유:
1. **운영 성숙도**: hopenvision은 채점·통계·Excel/CSV import·비동기 잡까지 구현 완료, academy `ex_mock_*`은 skeleton (DDL만)
2. **데이터 보존 가치**: hopenvision `subject_master` 110행 + `exam_mst` 2행 = 운영 자산. academy는 0행
3. **도메인 적합성**: hopenvision은 공무원 시험 특화 (성적 분포·합격선·등급), academy는 일반 학원 모의고사 일반화 모델 — 통합 시스템의 모의고사 요구에 hopenvision 모델이 더 정확
4. **PK 일관성**: hopenvision은 `exam_cd VARCHAR(50)` 코드 체계 (운영 중), academy는 UUID — 운영 코드 체계 유지가 마찰 적음

### 2.2 academy `ex_mock_exam`, `ex_mock_attempt` 폐기

**처리 방식**:
- 두 테이블의 **DDL을 PostgreSQL로 변환하지 않음**
- 두 테이블의 **데이터를 이관하지 않음** (어차피 0행)
- 분석용 archive 인입 대상에서도 **제외** (Q2의 회원/시험 분석 인입은 `acm_member*`, `acm_exam*`, `acm_mocktest*` 등 운영 데이터를 의미. `ex_mock_*`은 academy에서도 미사용 skeleton)

**소스 코드 측 영향**:
- academy의 mocktest 관련 MyBatis Mapper / Service / Controller가 있다면 **이관하지 않음**
- 통합 hopenvision의 모의고사 기능은 기존 `com.hopenvision.exam.*` 패키지 그대로 사용

**문서화 근거**:
- 이 ADR 자체가 폐기 결정 근거
- Phase 1 Flyway PLAN에서 `ex_*` prefix 테이블 2개를 "EXCLUDE — 본 ADR-001에 따라" 명시

### 2.3 academy 신규 prefix → hopenvision 통합 매핑

academy ADR-005가 정의한 9개 MSA prefix 중, hopenvision으로 가져갈 매핑:

| academy prefix | hopenvision 모듈 (com.hopenvision.*) | 정본 채택 |
|---------------|----------------------------------|---------|
| `id_*` | `identity` | academy V2 정의 (id_admin) — academy의 정의가 실구현 |
| `ct_*` | `content` | academy V3+ 정의 + TB_LEC_MST/TB_SUBJECT_INFO 통합 |
| `en_*` | `enrollment` | academy V5 정의 (en_cart_item, en_enrollment) |
| `od_*` | `order` | academy V5 정의 (od_order, od_order_item, od_payment) |
| `pt_*` | `point` | academy V6 정의 (pt_coupon, pt_coupon_user, pt_mileage_ledger) |
| `bk_*` | `book` | academy V6 정의 (bk_book, bk_delivery_address, bk_delivery) |
| `pl_*` | `platform` | academy 정의 (공통코드, 메뉴, 권한) |
| `ex_*` | `exam` (hopenvision 기존) | **hopenvision 정본** (academy ex_mock_* 폐기) |
| `op_*` | `operation` | academy 정의 (사물함/독서실, MVP 이후) |

추가로 academy 전용 prefix (hopenvision에 없음, 신규 모듈로 흡수):
- `tb_inquiry*` → `inquiry` 모듈 (1:1 문의 + AI 분류)
- `gosi_*` → `gosi` 모듈 (고시 통계, hopenvision exam과 매핑 검토)
- `comtn*` (eGovFramework) → `egov` 또는 `legacy` 모듈 (보존만, 가능하면 새 prefix로 점진 이전)

### 2.4 회원 도메인 통합 원칙

- **정본**: hopenvision `id_member` 모델 (BIGSERIAL PK, email-centric, OAuth + password 병행)
- **academy 회원 흡수**:
  - `acm_member` — 신규 academy 회원 (분석용 archive)
  - `TB_MA_MEMBER` — 윌비스 25년 레거시 회원
  - `gnrl_mber`, `entrprs_mber`, `emplyr_info`, `tbl_users` — eGovFramework 회원
  - 통합 뷰 `comvnusermaster`가 이미 3개 eGov 테이블을 통합 조회 — 이 패턴을 PostgreSQL `id_member` 통합 후 archive 뷰로 보존
- **매핑 키**: 이메일 우선, 없으면 신규 `member_id` 발급 + `id_member_legacy_map` 매핑 테이블

---

## 3. 결과

### 긍정적
- 모의고사 도메인의 정본이 확정 → 향후 신규 개발자가 어느 모델을 쓸지 헷갈릴 위험 0
- academy `ex_mock_*` 폐기로 마이그레이션 작업량 -2 테이블, -2 entity/repo/service 세트
- 통합 시스템에서 공무원 시험 특화 기능 (성적 통계·합격선·통계 대시보드) 그대로 활용
- subject_master 110행 등 운영 자산 보존

### 부정적 (Trade-off)
- academy 측에서 향후 모의고사를 추가 도메인(예: 일반 학원 자체 모의고사)으로 확장할 경우, hopenvision exam 모델로 대응해야 함 (UUID 코드 체계 변경 비용 발생 가능)
- academy의 mocktest 관련 코드를 작성한 적이 있는 개발자가 있다면 인지 변경 필요

### 후속 결정 필요
- `gosi_*` 16개 테이블이 hopenvision `exam_*`과 어느 정도 통합 가능한지 (별도 ADR 후속 작성 예정)
- academy의 일반 학원 모의고사 요구가 미래에 발생할 시 처리 방안

---

## 4. 실행 항목

이 ADR이 Accepted되면 다음 작업이 트리거됨:

1. [Task #2] Sprint 0 V2~V7 Revert PR (`REVERT_SPRINT0.md` 옵션 A 또는 B 선택)
2. [Task #6] Phase 1 Flyway PLAN 작성 시 `ex_mock_exam`, `ex_mock_attempt` 를 EXCLUDE 목록에 본 ADR 참조하여 명시
3. (이후) Phase 2 Java 이식 시 academy의 mocktest 패키지를 이관 대상에서 제외, 대신 hopenvision `com.hopenvision.exam.*` 그대로 사용 검증
