-- ============================================
-- V55__procedures_stat_stubs.sql
-- 통계 배치 프로시저 7개 — STUB 정의 + TODO
-- ============================================
--
-- ⚠️  본 V55 은 STUB만 생성합니다. PL/pgSQL 본문은 후속 PR (V55.1~V55.7) 에서 작성.
--
-- D-5 결정에 따라 통계 배치는 PL/pgSQL 보존 (JPA 미이전):
-- - 대용량 집계 → DB 내부 처리 효율적
-- - 스케줄러(@Scheduled)에서 호출
--
-- 비즈니스 프로시저 28개는 별도 처리:
-- - 본 V 에 정의 안 함
-- - PROCEDURES_TO_JPA.md (별도 문서) 에 매핑 표 작성
-- - Phase 2 Java 작업에서 JPA Service 로 이전

-- ============================================
-- (1) SP_MAKE_GOSI_ADJUST — 고시 보정 데이터 생성 (62줄)
-- ============================================
CREATE OR REPLACE PROCEDURE sp_make_gosi_adjust()
LANGUAGE plpgsql
AS $$
BEGIN
    -- TODO: 원본 SP_MAKE_GOSI_ADJUST 본문 PL/pgSQL 변환
    RAISE EXCEPTION 'sp_make_gosi_adjust not yet implemented — see V55__procedures_stat_stubs.sql';
END;
$$;

COMMENT ON PROCEDURE sp_make_gosi_adjust() IS
    'STUB — 고시 보정 데이터 생성 배치 (academy SP_MAKE_GOSI_ADJUST). V55.1 PR';

-- ============================================
-- (2) SP_MAKE_GOSI_ADJ_MST — 고시 보정 마스터 생성 (57줄)
-- ============================================
CREATE OR REPLACE PROCEDURE sp_make_gosi_adj_mst()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'sp_make_gosi_adj_mst not yet implemented — see V55__procedures_stat_stubs.sql';
END;
$$;

COMMENT ON PROCEDURE sp_make_gosi_adj_mst() IS
    'STUB — 고시 보정 마스터 배치 (academy SP_MAKE_GOSI_ADJ_MST). V55.2 PR';

-- ============================================
-- (3) SP_MAKE_GOSI_EXAM_RESULT — 고시 시험 결과 집계 (79줄)
-- ============================================
CREATE OR REPLACE PROCEDURE sp_make_gosi_exam_result()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'sp_make_gosi_exam_result not yet implemented — see V55__procedures_stat_stubs.sql';
END;
$$;

COMMENT ON PROCEDURE sp_make_gosi_exam_result() IS
    'STUB — 고시 시험 결과 집계 배치 (academy SP_MAKE_GOSI_EXAM_RESULT). V55.3 PR';

-- ============================================
-- (4) SP_MAKE_GOSI_STANDARD — 고시 기준 데이터 생성 (41줄, 가장 짧음)
-- ============================================
CREATE OR REPLACE PROCEDURE sp_make_gosi_standard()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'sp_make_gosi_standard not yet implemented — see V55__procedures_stat_stubs.sql';
END;
$$;

COMMENT ON PROCEDURE sp_make_gosi_standard() IS
    'STUB — 고시 기준 데이터 생성 (academy SP_MAKE_GOSI_STANDARD). V55.4 PR';

-- ============================================
-- (5) SP_MAKE_GOSI_STAT — 고시 통계 집계 (179줄, 가장 큼)
-- ============================================
CREATE OR REPLACE PROCEDURE sp_make_gosi_stat()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'sp_make_gosi_stat not yet implemented — see V55__procedures_stat_stubs.sql';
END;
$$;

COMMENT ON PROCEDURE sp_make_gosi_stat() IS
    'STUB — 고시 통계 집계 (academy SP_MAKE_GOSI_STAT, 179줄). V55.5 PR — 가장 복잡';

-- ============================================
-- (6) SP_MAKE_OFF_SALES_STAT — 오프라인 매출 통계 (92줄)
-- ============================================
CREATE OR REPLACE PROCEDURE sp_make_off_sales_stat()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'sp_make_off_sales_stat not yet implemented — see V55__procedures_stat_stubs.sql';
END;
$$;

COMMENT ON PROCEDURE sp_make_off_sales_stat() IS
    'STUB — 오프라인 매출 통계 (academy SP_MAKE_OFF_SALES_STAT). V55.6 PR';

-- ============================================
-- (7) SP_MAKE_ON_SALES_STAT — 온라인 매출 통계 (92줄)
-- ============================================
CREATE OR REPLACE PROCEDURE sp_make_on_sales_stat()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'sp_make_on_sales_stat not yet implemented — see V55__procedures_stat_stubs.sql';
END;
$$;

COMMENT ON PROCEDURE sp_make_on_sales_stat() IS
    'STUB — 온라인 매출 통계 (academy SP_MAKE_ON_SALES_STAT). V55.7 PR';
