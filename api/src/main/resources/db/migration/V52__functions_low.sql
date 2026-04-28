-- ============================================
-- V52__functions_low.sql
-- LOW 위험도 함수 10개 PL/pgSQL 변환
-- 출처: docs/db-migration/source/acm_basic.routines.sql
-- ============================================
--
-- 변환 룰:
-- - IFNULL → COALESCE
-- - INSTR → STRPOS
-- - SUBSTRING(s, start, len) → SUBSTR(s, start, len)
-- - CONCAT(a, b) → a || b
-- - DATE_FORMAT(d, '%Y%m%d') → TO_CHAR(d, 'YYYYMMDD')
-- - STR_TO_DATE(s, '%Y-%m-%d') → TO_DATE(s, 'YYYY-MM-DD')
-- - DATE_ADD(d, INTERVAL n DAY) → d + (n || ' days')::INTERVAL
-- - CURDATE() → CURRENT_DATE
-- - CAST(x AS SIGNED) → x::INTEGER
-- - 커서 → STRING_AGG (집계)
-- - 식별자 lowercase

-- ============================================
-- (1) REVERSE_STR — PG 내장 reverse() wrapper
-- ============================================
CREATE OR REPLACE FUNCTION fn_reverse_str(i_string VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql IMMUTABLE
AS $$
BEGIN
    RETURN REVERSE(i_string);
END;
$$;

COMMENT ON FUNCTION fn_reverse_str(VARCHAR) IS 'academy REVERSE_STR — PG 내장 reverse() 래퍼';

-- ============================================
-- (2) FN_GET_DATE_EXPIRED — 만료일 비교 (Y/N)
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_date_expired(v_date VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
    v_diff INTEGER;
BEGIN
    v_diff := v_date::INTEGER - TO_CHAR(CURRENT_DATE, 'YYYYMMDD')::INTEGER;
    IF v_diff >= 0 THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;
END;
$$;

COMMENT ON FUNCTION fn_get_date_expired(VARCHAR) IS
    'YYYYMMDD 형식 날짜 만료 여부 (academy FN_GET_DATE_EXPIRED)';

-- ============================================
-- (3) FN_GET_LEC_REST — 강의 잔여 일수
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_lec_rest(v_leccode VARCHAR, v_date VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    v_cnt INTEGER := 0;
BEGIN
    -- lec_date 는 DATE, v_date 는 VARCHAR (YYYY-MM-DD 형식 가정) — 명시 캐스트
    SELECT COUNT(num) INTO v_cnt
      FROM tb_off_lecture_date
     WHERE leccode = v_leccode AND lec_date > v_date::DATE;
    RETURN v_cnt;
END;
$$;

COMMENT ON FUNCTION fn_get_lec_rest(VARCHAR, VARCHAR) IS
    '오프라인 강의 잔여 일수 (academy FN_GET_LEC_REST)';

-- ============================================
-- (4) FN_GET_BOOK_ORDER_CNT — 교재 주문 카운트
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_book_order_cnt(v_rsc_id VARCHAR, v_leccode VARCHAR, v_user_id VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    v_cnt1 INTEGER := 0;
    v_cnt2 INTEGER := 0;
BEGIN
    SELECT COUNT(*) INTO v_cnt1
      FROM tb_orders a
      JOIN tb_order_mgnt_no b ON a.orderno = b.orderno
     WHERE a.user_id = v_user_id
       AND b.mgntno = v_rsc_id;

    -- legacy: 2014-08-15 이전의 특정 6개 강의코드만 카운트 (히스토리 정합성)
    SELECT COUNT(*) INTO v_cnt2
      FROM tb_orders a
      JOIN tb_order_mgnt_no b ON a.orderno = b.orderno
     WHERE a.user_id = v_user_id
       AND b.mgntno = v_leccode
       AND b.mgntno IN ('D201401365','D201401406','D201401448','D201401418','D201401481','D201401495')
       AND a.reg_dt < DATE '2014-08-15';

    RETURN v_cnt1 + v_cnt2;
END;
$$;

COMMENT ON FUNCTION fn_get_book_order_cnt(VARCHAR, VARCHAR, VARCHAR) IS
    '교재 주문 카운트 — legacy 2014-08-15 이전 6개 강의 보정 포함 (academy FN_GET_BOOK_ORDER_CNT)';

-- ============================================
-- (5) FN_GET_LEC_BRG_REQ_CNT — 강의 bridge 신청 카운트
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_lec_brg_req_cnt(v_leccode VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    v_cnt INTEGER := 0;
BEGIN
    SELECT COALESCE(SUM(t.cnt), 0) INTO v_cnt
      FROM (
          SELECT COUNT(b.mgntno) AS cnt
            FROM tb_off_mylecture a
            JOIN tb_off_order_mgnt_no b ON a.orderno = b.orderno
            JOIN tb_off_lec_bridge c ON a.lecture_no = c.leccode
            JOIN (SELECT bridge_leccode, leccode FROM tb_off_lec_bridge WHERE leccode = v_leccode) d
              ON c.bridge_leccode = d.bridge_leccode
           WHERE a.package_no = b.mgntno
             AND b.statuscode IN ('DLV105', 'DLV230')
           GROUP BY b.orderno
          HAVING COUNT(b.mgntno) = 1
      ) t;
    RETURN v_cnt;
END;
$$;

COMMENT ON FUNCTION fn_get_lec_brg_req_cnt(VARCHAR) IS
    '오프라인 강의 bridge 신청 카운트 (academy FN_GET_LEC_BRG_REQ_CNT)';

-- ============================================
-- (6) FN_GET_LEC_ON_REQ_CNT — 온라인 강의 신청 카운트 (무료/유료 분기)
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_lec_on_req_cnt(v_leccode VARCHAR, v_wmp_pmp VARCHAR, v_free VARCHAR)
RETURNS INTEGER
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    v_cnt INTEGER := 0;
BEGIN
    IF v_free = 'Y' THEN
        SELECT COALESCE(COUNT(b.mgntno), 0) INTO v_cnt
          FROM tb_mylecture a
          JOIN tb_order_mgnt_no b ON a.orderno = b.orderno
         WHERE a.package_no = b.mgntno
           AND b.statuscode = 'DLV105'
           AND b.iscancel <> '2'
           AND b.price = 0
           AND b.wmv_pmp = v_wmp_pmp
           AND a.package_no = v_leccode;
    ELSE
        SELECT COALESCE(COUNT(b.mgntno), 0) INTO v_cnt
          FROM tb_mylecture a
          JOIN tb_order_mgnt_no b ON a.orderno = b.orderno
         WHERE a.package_no = b.mgntno
           AND b.statuscode = 'DLV105'
           AND b.iscancel <> '2'
           AND b.price > 0
           AND b.wmv_pmp = v_wmp_pmp
           AND a.package_no = v_leccode;
    END IF;
    RETURN v_cnt;
END;
$$;

COMMENT ON FUNCTION fn_get_lec_on_req_cnt(VARCHAR, VARCHAR, VARCHAR) IS
    '온라인 강의 신청 카운트 — 무료/유료 분기 (academy FN_GET_LEC_ON_REQ_CNT)';

-- ============================================
-- (7) FN_GET_MULTI_BOOK_NM — 주문번호별 교재명 목록 (CR/LF 구분)
-- 원본 cursor 패턴 → STRING_AGG 집계로 단순화
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_multi_book_nm(v_orderno VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    v_result VARCHAR;
BEGIN
    SELECT STRING_AGG(b.book_nm || ' ' || b.book_author, E'\r\n')
      INTO v_result
      FROM tb_order_mgnt_no a
      JOIN tb_ca_book b ON a.mgntno = b.rsc_id
     WHERE a.orderno = v_orderno
       AND a.statuscode = 'DLV105';
    -- 원본은 빈 문자열 반환 (NULL 아님)
    RETURN COALESCE(E'\r\n' || v_result, '');
END;
$$;

COMMENT ON FUNCTION fn_get_multi_book_nm(VARCHAR) IS
    '주문번호별 교재명 목록 (CR/LF 구분, academy FN_GET_MULTI_BOOK_NM)';

-- ============================================
-- (8) FN_GET_STUDY_DATE — 학습 시작/종료일 산출
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_study_date(v_userid VARCHAR, v_leccode VARCHAR, v_type VARCHAR)
RETURNS DATE
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    i_start_date       VARCHAR(10);
    i_end_date         VARCHAR(10);
    i_subject_period   INTEGER;
    i_lec_st_dt        DATE;
    i_date             DATE;
    start_date_as_date DATE;
BEGIN
    SELECT a.sdate, a.edate, b.subject_period,
           TO_DATE(b.subject_off_open_year || '-' || b.subject_off_open_month || '-' || b.subject_off_open_day, 'YYYY-MM-DD')
      INTO i_start_date, i_end_date, i_subject_period, i_lec_st_dt
      FROM tb_cc_cart a
      JOIN tb_lec_mst b ON a.leccode = b.leccode
     WHERE a.user_id = v_userid
       AND a.leccode = v_leccode
       AND a.kind_type <> 'L'
     LIMIT 1;

    IF i_lec_st_dt < CURRENT_DATE THEN
        BEGIN
            start_date_as_date := COALESCE(TO_DATE(i_start_date, 'YY-MM-DD'), CURRENT_DATE);
        EXCEPTION WHEN OTHERS THEN
            start_date_as_date := CURRENT_DATE;
        END;
        i_date := start_date_as_date + ((i_subject_period - 1) || ' days')::INTERVAL;
    ELSE
        start_date_as_date := i_lec_st_dt + INTERVAL '1 day';
        i_date := i_lec_st_dt + (i_subject_period || ' days')::INTERVAL;
    END IF;

    IF v_type = 'S' THEN
        RETURN start_date_as_date;
    ELSE
        RETURN i_date;
    END IF;
END;
$$;

COMMENT ON FUNCTION fn_get_study_date(VARCHAR, VARCHAR, VARCHAR) IS
    '학습 시작(S)/종료(other) 일자 산출 (academy FN_GET_STUDY_DATE)';

-- ============================================
-- (9) GET_COUNSEL_USERCODE_NM — 콤마 구분 코드 → 이름 변환
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_counsel_usercode_nm(v_usercode VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql STABLE
AS $$
DECLARE
    v_result VARCHAR;
BEGIN
    -- 원본 WHILE 루프 대신 SPLIT + STRING_AGG 로 단순화
    SELECT STRING_AGG(info.name, ',')
      INTO v_result
      FROM unnest(STRING_TO_ARRAY(v_usercode, ',')) AS code(c)
      JOIN tb_category_info info ON info.code = code.c
     WHERE LENGTH(info.name) > 0;
    RETURN COALESCE(v_result, '');
END;
$$;

COMMENT ON FUNCTION fn_get_counsel_usercode_nm(VARCHAR) IS
    '콤마 구분 코드 → 이름 (tb_category_info 룩업, academy GET_COUNSEL_USERCODE_NM)';

-- ============================================
-- (10) GET_COUNSEL_USERLEC_NM — 강의 유형 매핑 (F=학원, O=온라인, E=기타)
-- ============================================
CREATE OR REPLACE FUNCTION fn_get_counsel_userlec_nm(v_userlec VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql IMMUTABLE
AS $$
DECLARE
    v_parts TEXT[] := ARRAY[]::TEXT[];
BEGIN
    IF STRPOS(v_userlec, 'F') > 0 THEN
        v_parts := array_append(v_parts, '학원');
    END IF;
    IF STRPOS(v_userlec, 'O') > 0 THEN
        v_parts := array_append(v_parts, '온라인');
    END IF;
    IF STRPOS(v_userlec, 'E') > 0 THEN
        v_parts := array_append(v_parts, '기타');
    END IF;
    RETURN COALESCE(array_to_string(v_parts, ','), '');
END;
$$;

COMMENT ON FUNCTION fn_get_counsel_userlec_nm(VARCHAR) IS
    '강의 유형 코드(F/O/E) → 한글명 (academy GET_COUNSEL_USERLEC_NM)';
