# Sprint 0 V2~V7 Revert 계획 (B안)

> 작성일: 2026-04-28
> 컨텍스트: Academy → Hopenvision 통합 결정 (사용자 Q1 가안)에 따라
> hopenvision Sprint 0(PR #470)의 임시 skeleton과 academy 운영 정의가 충돌.
> 더 성숙한 academy 정의를 채택하기 위해 Sprint 0 skeleton을 되돌린다.

## 1. 현재 상태 (2026-04-28 기준)

### 소스 (`origin/main`, `origin/prod`)
PR #470에서 추가된 자산:

**Flyway 마이그레이션** (6개):
- `V2__mvp_identity_member.sql` — id_member, id_member_grade, id_member_grade_history
- `V3__mvp_content_lecture.sql` — ct_category, ct_lecture, ct_lecture_chapter, ct_subject, ct_teacher
- `V4__mvp_enrollment_order.sql` — en_entitlement, en_progress, en_reenroll_request, od_cart, od_order, od_order_item, od_payment, od_refund
- `V5__mvp_point_coupon.sql` — pt_coupon, pt_member_coupon, pt_mileage_ledger
- `V6__mvp_book_delivery.sql` — bk_catalog, bk_delivery, bk_delivery_item, bk_inventory, bk_shipping_address
- `V7__mvp_platform_config.sql` — pl_code, pl_code_group, pl_member_role, pl_menu, pl_role

**Java skeleton 패키지**:
- `book/`, `content/`, `enrollment/`, `order/`, `platform/`, `point/` — 빈 `package-info.java` 만 존재
- `identity/` — 실구현 (Member entity, Repository, Service, Controller, DTOs)

**기타 (재사용)**:
- `config/AsyncConfig.java`
- `config/GlobalExceptionHandler.java`
- `identity/config/IdentityPasswordConfig.java`
- `application.yml` — Flyway/Redis 설정
- `build.gradle` — Flyway/Redis 의존성

### 운영 hopenvision DB (PostgreSQL)

**Flyway 적용 이력** (확인일: 2026-04-28):
```
version | description           | success | installed_on
1       | << Flyway Baseline >> | t       | 2026-04-27
2       | mvp identity member   | t       | 2026-04-27
3       | mvp content lecture   | t       | 2026-04-27
4       | mvp enrollment order  | t       | 2026-04-27
5       | mvp point coupon      | t       | 2026-04-27
6       | mvp book delivery     | t       | 2026-04-27
7       | mvp platform config   | t       | 2026-04-27
```

**데이터 현황**: 생성된 30개 테이블 중 단 2개에만 seed 데이터 존재
| 테이블 | 행 수 | 비고 |
|-------|------|------|
| `id_member_grade` | 4 | V2 seed |
| `pl_role` | 4 | V7 seed |
| 그 외 28개 | 0 | 비어있음 |

### dev DB (`hopenvision_dev`)
- `flyway_schema_history` 테이블 자체가 **존재하지 않음** → V1~V7 단 한 번도 실행 안 됨
- → dev에서는 별도 처리 불필요 (academy 통합 마이그레이션이 처음 실행될 것)

## 2. Revert 범위

### 삭제 대상

**Flyway SQL** (6개, 모두):
- `api/src/main/resources/db/migration/V2__mvp_identity_member.sql`
- `api/src/main/resources/db/migration/V3__mvp_content_lecture.sql`
- `api/src/main/resources/db/migration/V4__mvp_enrollment_order.sql`
- `api/src/main/resources/db/migration/V5__mvp_point_coupon.sql`
- `api/src/main/resources/db/migration/V6__mvp_book_delivery.sql`
- `api/src/main/resources/db/migration/V7__mvp_platform_config.sql`

**identity 모듈 실구현** (`id_member` 테이블 의존, 6개 파일):
- `api/src/main/java/com/hopenvision/identity/entity/Member.java`
- `api/src/main/java/com/hopenvision/identity/repository/MemberRepository.java`
- `api/src/main/java/com/hopenvision/identity/service/MemberService.java`
- `api/src/main/java/com/hopenvision/identity/controller/MemberController.java`
- `api/src/main/java/com/hopenvision/identity/dto/MemberSignupRequest.java`
- `api/src/main/java/com/hopenvision/identity/dto/MemberResponse.java`

> 회원 모델은 academy 이관 시 `acm_member` + `TB_MA_MEMBER` + `gnrl_mber` 통합으로 재설계 필요. 임시 Member.java를 들고 가는 것보다 깔끔하게 비우고 시작.

### 유지 대상

**재사용 가능한 인프라**:
- `api/src/main/java/com/hopenvision/config/AsyncConfig.java` — @Async/Scheduling 설정
- `api/src/main/java/com/hopenvision/config/GlobalExceptionHandler.java` — REST 예외 처리
- `api/src/main/java/com/hopenvision/identity/config/IdentityPasswordConfig.java` — BCrypt 인코더 (academy 회원 PW BCrypt 변환에 활용)
- `application.yml` Flyway/Redis 설정
- `build.gradle` Flyway/Redis 의존성

**도메인 marker**:
- `book/`, `content/`, `enrollment/`, `order/`, `platform/`, `point/`, `identity/` 의 `package-info.java` (빈 파일, academy 이관 시 채울 예정)

## 3. 운영 DB 처리 — **옵션 A 확정** (2026-04-28, [PHASE1_DECISIONS.md D-1](decisions/PHASE1_DECISIONS.md#d-1))

### 옵션 A — Source-clean (수동 DB op 필요, 사용자 원안 "V2부터 academy") ✅ CHOSEN

**절차**:
1. 운영 DB에서 수동 SQL 실행:
   ```sql
   -- 30개 테이블 일괄 DROP (CASCADE)
   DROP TABLE IF EXISTS bk_catalog, bk_delivery, bk_delivery_item, bk_inventory, bk_shipping_address,
                        ct_category, ct_lecture, ct_lecture_chapter, ct_subject, ct_teacher,
                        en_entitlement, en_progress, en_reenroll_request,
                        od_cart, od_order, od_order_item, od_payment, od_refund,
                        pl_code, pl_code_group, pl_member_role, pl_menu, pl_role,
                        pt_coupon, pt_member_coupon, pt_mileage_ledger,
                        id_member, id_member_grade, id_member_grade_history CASCADE;
   -- Flyway history 정리
   DELETE FROM flyway_schema_history WHERE version IN ('2','3','4','5','6','7');
   ```
2. PR로 V2~V7 파일 + identity 실구현 삭제
3. 다음 deploy 시 Flyway는 V1만 적용된 상태로 인식 → V2~V?? academy 마이그레이션 정상 실행

**장점**: 소스가 깨끗, 사용자가 원한 "V2부터 academy" 정확히 구현
**단점**: 운영 DB 수동 op 필요, 실수 시 복구 어려움 (단 데이터 8행 = seed라 복구 부담은 낮음)

### 옵션 B — Forward-only (DB op 없이, audit trail 보존)

**절차**:
1. V8__cleanup_sprint0_skeleton.sql 새로 추가:
   ```sql
   DROP TABLE IF EXISTS bk_catalog, ..., id_member_grade_history CASCADE;
   ```
2. V2~V7 SQL 파일은 **그대로 유지** (Flyway checksum validation 통과)
3. PR로 identity 실구현만 삭제 (V2~V7 SQL은 건드리지 않음)
4. V9~V?? academy 마이그레이션
5. 결과: V2~V7은 source에 "skeleton then dropped" 화석으로 남음

**장점**: 운영 DB 수동 op 불필요, 100% Flyway 자동화, 모든 변경이 audit trail
**단점**: 소스에 dead V2~V7 파일이 남음, V8이 갑자기 DROP만 하는 어색한 마이그레이션

## 4. 옵션 A 채택 근거
1. 운영 데이터가 사실상 0 (seed 8행, 재생성 가능)
2. 사용자 원안("V2부터 academy 새로 시작")과 정확히 일치
3. 소스가 깨끗 → 신규 개발자 진입 장벽 ↓
4. 향후 ADR/문서에서 "V2~V7은 폐기됨"을 명시적으로 설명할 필요 없음

**수동 SQL 실행 책임**: owner가 직접 (운영 DB 변경 권한 owner 한정)

## 5. 실행 순서

```
[1] 사용자 승인 (옵션 A 확정 ✅ 2026-04-28)
   ↓
[2] PR 작성 (브랜치: feature/revert-sprint0-skeleton)
    - V2~V7 SQL 6개 삭제
    - identity 실구현 6개 파일 삭제
    - REVERT_SPRINT0.md 동시 커밋 (이 문서)
   ↓
[3] PR 리뷰 → main merge
   ↓
[4] owner가 운영 DB 수동 SQL 실행 (옵션 A 한정)
   ↓
[5] main → prod merge → 자동 deploy
   ↓
[6] 다음 작업: ADR 작성 (Task #3) + Flyway PLAN.md (Task #6)
```

## 6. 검증 체크리스트

- [ ] PR diff에 V2~V7.sql 6개 모두 삭제 표시
- [ ] PR diff에 identity Member/MemberRepository/MemberService/MemberController/DTOs 6개 삭제 표시
- [ ] AsyncConfig, GlobalExceptionHandler, IdentityPasswordConfig는 그대로
- [ ] application.yml Flyway/Redis 설정 보존 확인
- [ ] (옵션 A) 운영 DB DROP 후 `\dt id_*` `\dt en_*` 등 비어있음 확인
- [ ] (옵션 A) `SELECT * FROM flyway_schema_history` 결과가 V1 baseline 1행만 존재
- [ ] dev DB는 변경 불필요 (애초에 V1~V7 미적용)
