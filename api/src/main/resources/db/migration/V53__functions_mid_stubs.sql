-- ============================================
-- V53__functions_mid_stubs.sql
-- MID 위험도 함수 5개 — STUB 정의 + TODO
-- ============================================
--
-- ⚠️  본 V53 은 STUB만 생성합니다. 실 비즈니스 로직(가격 산출/고시 기준)은
-- academy 운영 코드 검증 후 별도 PR (V53.1~V53.5) 로 본문 채움.
--
-- 이유:
-- - 5개 함수 모두 비즈니스 로직 (가격, 환불, 패키지)
-- - 잘못 변환 시 매출 영향 직접 발생
-- - academy MyBatis Mapper 가 이 함수를 호출하는 위치 추적 후 결정
--
-- 원본 SQL 은 docs/db-migration/source/acm_basic.routines.sql 참조
-- 함수별 위험도/검증 포인트는 docs/db-migration/source/inventory.md 참조

-- ============================================
-- (1) ADVANCE_RECEIVED — 선수금 산출 (125줄, 가장 복잡)
-- 입력: I_START_DATE VARCHAR(8) — TODO: 정확한 시그니처 확인
-- 출력: 선수금 금액 (DECIMAL 추정)
-- TODO: academy backend 의 호출처 추적 → JPA Service 이전 vs PL/pgSQL 보존 결정
-- ============================================
CREATE OR REPLACE FUNCTION fn_advance_received(i_start_date VARCHAR)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    -- TODO: 원본 academy ADVANCE_RECEIVED 본문 (acm_basic.routines.sql) PL/pgSQL 변환
    RAISE EXCEPTION 'fn_advance_received not yet implemented — see V53__functions_mid_stubs.sql';
END;
$$;

COMMENT ON FUNCTION fn_advance_received(VARCHAR) IS
    'STUB — 선수금 산출 (academy ADVANCE_RECEIVED). V53.1 PR 에서 본문 작성 예정';

-- ============================================
-- (2) FN_GET_GOSI_STANDARD — 고시 기준 산출 (46줄)
-- 입력: V_SUBJECT_CD VARCHAR(255)
-- 출력: 기준값 (TBD)
-- TODO: 고시 도메인 비즈니스 룰 검증
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_gosi_standard(v_subject_cd VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
BEGIN
    -- TODO: 원본 FN_GET_GOSI_STANDARD 본문 PL/pgSQL 변환
    RAISE EXCEPTION 'fn_get_gosi_standard not yet implemented — see V53__functions_mid_stubs.sql';
END;
$$;

COMMENT ON FUNCTION fn_get_gosi_standard(VARCHAR) IS
    'STUB — 고시 기준 산출 (academy FN_GET_GOSI_STANDARD). V53.2 PR';

-- ============================================
-- (3) FN_GET_OFF_PRICE_PRF_PACKAGE — 오프라인 패키지 가격 산출 (60줄)
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_off_price_prf_package(v_orderno VARCHAR, v_package_no VARCHAR, v_lecture_no VARCHAR)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    -- TODO: 원본 FN_GET_OFF_PRICE_PRF_PACKAGE 본문 PL/pgSQL 변환 (NUMERIC 19,4)
    RAISE EXCEPTION 'fn_get_off_price_prf_package not yet implemented — see V53__functions_mid_stubs.sql';
END;
$$;

COMMENT ON FUNCTION fn_get_off_price_prf_package(VARCHAR, VARCHAR, VARCHAR) IS
    'STUB — 오프라인 패키지 가격 산출. V53.3 PR — ⚠️ 매출 직결';

-- ============================================
-- (4) FN_GET_ON_PRICE_PRF_PACKAGE — 온라인 패키지 가격 산출 (50줄)
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_on_price_prf_package(v_orderno VARCHAR, v_package_no VARCHAR, v_lecture_no VARCHAR, v_order_status VARCHAR)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    -- TODO: 원본 FN_GET_ON_PRICE_PRF_PACKAGE 본문 PL/pgSQL 변환 (NUMERIC 19,4)
    RAISE EXCEPTION 'fn_get_on_price_prf_package not yet implemented — see V53__functions_mid_stubs.sql';
END;
$$;

COMMENT ON FUNCTION fn_get_on_price_prf_package(VARCHAR, VARCHAR, VARCHAR, VARCHAR) IS
    'STUB — 온라인 패키지 가격 산출. V53.4 PR — ⚠️ 매출 직결';

-- ============================================
-- (5) FN_GET_PRICE_PRF_PACKAGE — 패키지 가격 산출 (47줄, generic)
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_price_prf_package(v_orderno VARCHAR)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    -- TODO: 원본 FN_GET_PRICE_PRF_PACKAGE 본문 PL/pgSQL 변환 (NUMERIC 19,4)
    -- 원본 시그니처: 가변 인자 가능성 — academy 호출처 검증 필요
    RAISE EXCEPTION 'fn_get_price_prf_package not yet implemented — see V53__functions_mid_stubs.sql';
END;
$$;

COMMENT ON FUNCTION fn_get_price_prf_package(VARCHAR) IS
    'STUB — 패키지 가격 산출 (단일 인자). V53.5 PR — ⚠️ 매출 직결';

-- ============================================
-- 후속 작업
-- ============================================
-- V53.1 ~ V53.5 별도 PR 로 각 함수 본문 채움.
-- 각 PR 마다:
-- 1. academy MyBatis Mapper 호출처 grep
-- 2. 원본 MariaDB 함수 본문 PL/pgSQL 변환
-- 3. 단위 테스트 (운영 데이터 샘플로 input/output 비교)
-- 4. RAISE EXCEPTION 제거 + 정상 본문 교체
