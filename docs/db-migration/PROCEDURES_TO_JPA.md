# 비즈니스 프로시저 → JPA Service 이전 매핑

> [PHASE1_DECISIONS.md D-5](decisions/PHASE1_DECISIONS.md): 비즈니스 로직 프로시저 28개는 DB 함수가 아닌 **Spring JPA Service 레이어**로 이전.
> 작성일: 2026-04-28

academy `acm_basic` 의 35개 프로시저 중 통계 배치 7개를 제외한 28개는 비즈니스 로직 (포인트 적립, 강의 등록, 쿠폰, 카트, 회원 이벤트, 댓글 등). DB 함수가 아닌 Spring `@Service` 클래스로 이전한다.

## 처리 방식

- **본 매핑에 포함된 프로시저**: PostgreSQL 에 함수/프로시저로 만들지 않음 (V55~V60 스크립트 범위 밖)
- 각 프로시저는 Phase 2 Java 작업에서 `com.hopenvision.<module>.service.*` 클래스의 메서드로 구현
- 메서드 시그니처는 academy MyBatis Mapper XML 의 호출처 분석 후 결정
- `@Transactional` 명시 필수 (academy 는 procedure 트랜잭션 자동, JPA 는 명시적)

## 매핑 표 (28개)

### Point — 포인트 적립 (4개)

| 원본 프로시저 | 입력 | 처리 | JPA 위치 |
|------------|-----|------|---------|
| `INSERT_POINT` | point, userid, txt, event_no | 일반 포인트 적립 | `com.hopenvision.point.service.PointService#insertPoint` |
| `SP_BUY_INSERT_POINT` | (cursor 파라미터) | 구매 시 포인트 적립 | `PointService#insertOnPurchase` |
| `SP_INS_BOOK_POINT` | (cursor 파라미터) | 교재 구매 포인트 적립 | `PointService#insertOnBookPurchase` |
| `SP_SNS_INSERT_POINT` | (cursor 파라미터) | SNS 공유 포인트 적립 | `PointService#insertOnSnsShare` |

### Coupon — 쿠폰 (3개)

| 원본 프로시저 | 입력 | 처리 | JPA 위치 |
|------------|-----|------|---------|
| `INSERT_COUPON` | coupon, userid, day, event_no | 쿠폰 발급 | `com.hopenvision.point.service.CouponService#issue` |
| `INSERT_COOP_COUPON` | coop_cd, coupon_nm, leccode, st_dt, ed_dt, coupon_cnt | 협력사 쿠폰 일괄 발급 | `CouponService#issueCoopBatch` |
| `DELETE_COOP_COUPON` | coop_cd, leccode | 협력사 쿠폰 삭제 | `CouponService#deleteCoopBatch` |

### Cart — 장바구니 (3개)

| 원본 프로시저 | 입력 | 처리 | JPA 위치 |
|------------|-----|------|---------|
| `SP_CART_DELETE` | (cursor 파라미터) | 카트 삭제 | `com.hopenvision.enrollment.service.CartService#delete` |
| `UPDATE_CART_JONG` | user_id, leccode | 카트 종속 갱신 (online) | `CartService#updateCartJong` |
| `UPDATE_OFF_CART_JONG` | user_id | 오프라인 카트 종속 갱신 | `CartService#updateOffCartJong` |

### Lecture — 강의/교재 등록 (6개)

| 원본 프로시저 | 입력 | 처리 | JPA 위치 |
|------------|-----|------|---------|
| `INSERT_LECTURE` | user_id, leccode, txt, day | 온라인 강의 등록 | `com.hopenvision.enrollment.service.MyLectureService#enroll` |
| `INSERT_LECTURE_PKG` | user_id, leccode, txt, day | 강의 패키지 등록 | `MyLectureService#enrollPackage` |
| `SP_LECTURE_BOOK_INSERT` | (cursor 파라미터) | 강의 + 교재 동시 등록 | `MyLectureService#enrollWithBook` |
| `SP_LECTURE_OFF_BOOK_INSERT` | (cursor 파라미터) | 오프라인 강의 + 교재 등록 | `MyLectureService#enrollOfflineWithBook` |
| `SP_LECTURE_OFF_DAY_INSERT` | (cursor 파라미터) | 오프라인 강의 일정 등록 | `MyLectureService#enrollOfflineSchedule` |
| `EXT_MY_LECTURE_DAY` | user_id, orderno, leccode, day, free | 강의 기간 연장 | `MyLectureService#extendDays` |

### Reply — 댓글 (2개)

| 원본 프로시저 | 입력 | 처리 | JPA 위치 |
|------------|-----|------|---------|
| `SP_INS_REPLY` | (cursor 파라미터) | 일반 댓글 등록 | `com.hopenvision.platform.service.CommentService#insert` |
| `SP_INS_EVENT_REPLY` | (cursor 파라미터) | 이벤트 댓글 등록 | `CommentService#insertEventReply` |

### Member Event — 회원 이벤트 (2개)

| 원본 프로시저 | 입력 | 처리 | JPA 위치 |
|------------|-----|------|---------|
| `SP_NEW_MEMBER_INSERT_EVENT` | (cursor 파라미터) | 신규 회원 가입 이벤트 적용 | `com.hopenvision.identity.service.MemberEventService#onSignup` |
| `SP_NEW_MEMBER_UPDATE_EVENT` | (cursor 파라미터) | 회원 정보 갱신 이벤트 적용 | `MemberEventService#onProfileUpdate` |

### Misc — 기타 (8개 — JPA 미이전, 폐기 검토)

| 원본 프로시저 | 입력 | 처리 | 처리 방향 |
|------------|-----|------|---------|
| `GET_DDL_PARTITION` | (DDL 생성) | PostgreSQL 은 PARTITION BY 네이티브 — **폐기** | — |

## Phase 2 작업 가이드

각 프로시저 → JPA Service 이전 PR 작성 시:

1. **호출처 추적**: academy `backend/src/main/resources/mapper/*.xml` 에서 `<call>` 또는 `CALL <procedure>` 검색
2. **입력 파라미터 정확화**: 원본 IN/OUT/INOUT 파라미터 모두 확인
3. **트랜잭션 경계**: `@Transactional(propagation = REQUIRED)` 기본
4. **테스트**: 운영 데이터 샘플로 input/output 비교 (`@SpringBootTest` 통합 테스트)
5. **본 문서 갱신**: "JPA 위치" 컬럼에 실제 클래스 경로 + 메서드명 기재

## 미해결 결정

다음 프로시저들은 cursor 패턴이라 시그니처가 호출처 검증 후 확정됨:
- `SP_CART_DELETE`, `SP_BUY_INSERT_POINT`, `SP_INS_BOOK_POINT`, `SP_SNS_INSERT_POINT`
- `SP_LECTURE_BOOK_INSERT`, `SP_LECTURE_OFF_BOOK_INSERT`, `SP_LECTURE_OFF_DAY_INSERT`
- `SP_INS_REPLY`, `SP_INS_EVENT_REPLY`
- `SP_NEW_MEMBER_INSERT_EVENT`, `SP_NEW_MEMBER_UPDATE_EVENT`

→ Phase 2 시작 전 academy mapper 일괄 grep 후 본 문서 갱신.
