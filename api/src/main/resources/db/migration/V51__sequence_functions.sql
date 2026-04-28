-- ============================================
-- V51__sequence_functions.sql
-- 시퀀스 발급 함수 7개 (academy 프로시저 → PostgreSQL 함수)
-- 출처: docs/db-migration/source/acm_basic.routines.sql
-- ============================================
--
-- 변환 메모:
-- - MariaDB OUT 파라미터 → PG 함수 RETURNS
-- - DATE_FORMAT(CURDATE(),'%Y') → EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER (gyear=BIGINT)
-- - DATE_FORMAT(CURDATE(),'%y') → TO_CHAR(CURRENT_DATE,'YY')
-- - LPAD(n, 7, '0') → LPAD(n::TEXT, 7, '0')
-- - CONCAT(a, b) → a || b (PG 표준)
-- - 백업 테이블: tb_seq_orderno, tb_seqoff_orderno, tb_texamidseq (V11/V18 에서 생성)

-- ============================================
-- (1) GET_NEXTSEQ_NO — 온라인 주문번호 시퀀스 발급
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_nextseq_no(p_gubun VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_year   BIGINT := EXTRACT(YEAR FROM CURRENT_DATE)::BIGINT;
    v_gubun  VARCHAR := UPPER(p_gubun);
    v_seq    INTEGER;
BEGIN
    INSERT INTO tb_seq_orderno (gubun, gyear, seq)
    SELECT v_gubun, v_year, 1
    WHERE NOT EXISTS (
        SELECT 1 FROM tb_seq_orderno WHERE gubun = v_gubun AND gyear = v_year
    );

    UPDATE tb_seq_orderno
       SET seq = seq + 1
     WHERE gubun = v_gubun AND gyear = v_year;

    SELECT seq INTO v_seq
      FROM tb_seq_orderno
     WHERE gubun = v_gubun AND gyear = v_year;

    RETURN v_seq;
END;
$$;

COMMENT ON FUNCTION fn_get_nextseq_no(VARCHAR) IS
    '온라인 주문번호 시퀀스 — (gubun, year) 키로 카운터 증분 (academy GET_NEXTSEQ_NO)';

-- ============================================
-- (2) GET_NEXTSEQ_OFFNO — 오프라인 주문번호 시퀀스 발급
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_nextseq_offno(p_gubun VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_year   BIGINT := EXTRACT(YEAR FROM CURRENT_DATE)::BIGINT;
    v_gubun  VARCHAR := UPPER(p_gubun);
    v_seq    INTEGER;
BEGIN
    INSERT INTO tb_seqoff_orderno (gubun, gyear, seq)
    SELECT v_gubun, v_year, 1
    WHERE NOT EXISTS (
        SELECT 1 FROM tb_seqoff_orderno WHERE gubun = v_gubun AND gyear = v_year
    );

    UPDATE tb_seqoff_orderno
       SET seq = seq + 1
     WHERE gubun = v_gubun AND gyear = v_year;

    SELECT seq INTO v_seq
      FROM tb_seqoff_orderno
     WHERE gubun = v_gubun AND gyear = v_year;

    RETURN v_seq;
END;
$$;

COMMENT ON FUNCTION fn_get_nextseq_offno(VARCHAR) IS
    '오프라인 주문번호 시퀀스 — (gubun, year) 키 카운터 증분 (academy GET_NEXTSEQ_OFFNO)';

-- ============================================
-- (3) GET_NEXTSEQ_ORDERNO — 온라인 주문번호 포맷팅 (gubun + YY + 7자리)
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_nextseq_orderno(p_gubun VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    v_seq INTEGER;
BEGIN
    v_seq := fn_get_nextseq_no(p_gubun);
    IF v_seq IS NULL THEN
        RETURN 'NO';
    END IF;
    RETURN UPPER(p_gubun) || TO_CHAR(CURRENT_DATE, 'YY') || LPAD(v_seq::TEXT, 7, '0');
END;
$$;

COMMENT ON FUNCTION fn_get_nextseq_orderno(VARCHAR) IS
    '주문번호 발급: GUBUN + YY + 7자리 시퀀스 (academy GET_NEXTSEQ_ORDERNO)';

-- ============================================
-- (4) GET_NEXTSEQ_OFFORDERNO — 오프라인 주문번호 포맷팅 (gubun + F + YY + 7자리)
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_nextseq_offorderno(p_gubun VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    v_seq INTEGER;
BEGIN
    v_seq := fn_get_nextseq_offno(p_gubun);
    IF v_seq IS NULL THEN
        RETURN 'NO';
    END IF;
    RETURN UPPER(p_gubun) || 'F' || TO_CHAR(CURRENT_DATE, 'YY') || LPAD(v_seq::TEXT, 7, '0');
END;
$$;

COMMENT ON FUNCTION fn_get_nextseq_offorderno(VARCHAR) IS
    '오프라인 주문번호 발급: GUBUN + F + YY + 7자리 시퀀스 (academy GET_NEXTSEQ_OFFORDERNO)';

-- ============================================
-- (5) GET_EXAM_NEXTSEQ — 시험 ID 시퀀스 발급 (시작값 100)
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_exam_nextseq(p_gubun VARCHAR, p_param VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_gubun  VARCHAR := UPPER(p_gubun);
    v_param  VARCHAR := UPPER(p_param);
    v_seq    INTEGER;
BEGIN
    INSERT INTO tb_texamidseq (gubun, idtype, seq)
    SELECT v_gubun, v_param, 100
    WHERE NOT EXISTS (
        SELECT 1 FROM tb_texamidseq WHERE gubun = v_gubun AND idtype = v_param
    );

    UPDATE tb_texamidseq
       SET seq = seq + 1
     WHERE gubun = v_gubun AND idtype = v_param;

    SELECT seq INTO v_seq
      FROM tb_texamidseq
     WHERE gubun = v_gubun AND idtype = v_param;

    RETURN v_seq;
END;
$$;

COMMENT ON FUNCTION fn_get_exam_nextseq(VARCHAR, VARCHAR) IS
    '시험 ID 시퀀스 — (gubun, idtype) 키 카운터 증분, 시작값 100 (academy GET_EXAM_NEXTSEQ)';

-- ============================================
-- (6) GET_EXAM_IDENTYID — 시험 IDENTYID 포맷 (param + 4자리)
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_exam_identyid(p_gubun VARCHAR, p_param VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    v_seq INTEGER;
BEGIN
    v_seq := fn_get_exam_nextseq(p_gubun, p_param);
    IF v_seq IS NULL THEN
        RETURN 'NO';
    END IF;
    RETURN UPPER(p_param) || LPAD(v_seq::TEXT, 4, '0');
END;
$$;

COMMENT ON FUNCTION fn_get_exam_identyid(VARCHAR, VARCHAR) IS
    '시험 IDENTYID 발급: param + 4자리 시퀀스 (academy GET_EXAM_IDENTYID)';

-- ============================================
-- (7) GET_EXAM_OFFERERID — 시험 OFFERERID 포맷 (param + 6자리)
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_exam_offererid(p_gubun VARCHAR, p_param VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    v_seq INTEGER;
BEGIN
    v_seq := fn_get_exam_nextseq(p_gubun, p_param);
    IF v_seq IS NULL THEN
        RETURN 'NO';
    END IF;
    RETURN UPPER(p_param) || LPAD(v_seq::TEXT, 6, '0');
END;
$$;

COMMENT ON FUNCTION fn_get_exam_offererid(VARCHAR, VARCHAR) IS
    '시험 OFFERERID 발급: param + 6자리 시퀀스 (academy GET_EXAM_OFFERERID)';
