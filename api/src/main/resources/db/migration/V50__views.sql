-- ============================================
-- V50__views.sql
-- 뷰 2개 (comvnusermaster, v_inquiry) PostgreSQL 변환
-- 출처: docs/db-migration/source/acm_basic.views.sql
-- ============================================
--
-- MariaDB → PostgreSQL 변환 메모:
-- - ALGORITHM=UNDEFINED, DEFINER, SQL SECURITY DEFINER 절 제거 (PG 미지원)
-- - 백틱 식별자 → 따옴표 없이 lowercase
-- - convert(... using utf8mb4) → convert_from(..., 'UTF8') (BYTEA → TEXT)
-- - cast(... as char(20) charset utf8mb4) → CAST(... AS VARCHAR(20))
-- - left(text, n) — PG 호환 그대로 사용
-- - case ... when ... then ... else ... end — PG 호환

-- ============================================
-- VIEW: comvnusermaster
-- ============================================
-- gnrl_mber + emplyr_info + entrprs_mber 통합 회원 조회 (eGovFramework 표준)

CREATE OR REPLACE VIEW comvnusermaster AS
SELECT
    gnrl_mber.esntl_id          AS esntl_id,
    gnrl_mber.mber_id           AS user_id,
    gnrl_mber.password          AS password,
    gnrl_mber.mber_nm           AS user_nm,
    gnrl_mber.zip               AS zip,
    gnrl_mber.adres             AS adres,
    gnrl_mber.mber_email_adres  AS mber_email_adres,
    ' '                         AS name_exp_8,
    'GNR'                       AS user_se,
    ' '                         AS orgnzt_id
FROM gnrl_mber
UNION ALL
SELECT
    emplyr_info.esntl_id        AS esntl_id,
    emplyr_info.emplyr_id       AS user_id,
    emplyr_info.password        AS password,
    emplyr_info.user_nm         AS user_nm,
    emplyr_info.zip             AS zip,
    emplyr_info.house_adres     AS adres,
    emplyr_info.email_adres     AS mber_email_adres,
    emplyr_info.group_id        AS name_exp_8,
    'USR'                       AS user_se,
    emplyr_info.orgnzt_id       AS orgnzt_id
FROM emplyr_info
UNION ALL
SELECT
    entrprs_mber.esntl_id              AS esntl_id,
    entrprs_mber.entrprs_mber_id       AS user_id,
    entrprs_mber.entrprs_mber_password AS password,
    entrprs_mber.cmpny_nm              AS user_nm,
    entrprs_mber.zip                   AS zip,
    entrprs_mber.adres                 AS adres,
    entrprs_mber.applcnt_email_adres   AS mber_email_adres,
    ' '                                AS name_exp_8,
    'ENT'                              AS user_se,
    ' '                                AS orgnzt_id
FROM entrprs_mber
ORDER BY esntl_id;

COMMENT ON VIEW comvnusermaster IS 'eGov 통합 사용자 마스터 — gnrl_mber/emplyr_info/entrprs_mber UNION';


-- ============================================
-- VIEW: v_inquiry
-- ============================================
-- 1:1 문의 통합 조회 — legacy tb_board_cs (source='L') + 신규 tb_inquiry (source='N')
-- legacy 분류는 tb_category_mapping 으로 표준 카테고리 매핑

CREATE OR REPLACE VIEW v_inquiry AS
SELECT
    'L'                                                       AS source,
    L.board_seq                                               AS inquiry_id,
    L.reg_id                                                  AS user_id,
    L.createname                                              AS user_name,
    L.subject                                                 AS title,
    -- BYTEA (longblob 변환분) → UTF8 텍스트로 디코드, 65535 자 제한
    LEFT(convert_from(L.content, 'UTF8'), 65535)              AS body,
    L.reg_dt                                                  AS inquiry_date,
    NULL::VARCHAR(30)                                         AS predicted_category,
    NULL::NUMERIC(5,4)                                        AS predicted_confidence,
    NULL::VARCHAR(50)                                         AS classified_by_model,
    NULL::TIMESTAMP                                           AS classified_at,
    M.std_category                                            AS actual_category,
    L.counselor_id                                            AS assigned_to,
    0                                                         AS reroute_count,
    LEFT(convert_from(L.answer, 'UTF8'), 65535)               AS answer_body,
    L.counselor_id                                            AS answered_by,
    CASE WHEN L.answer IS NOT NULL THEN L.upd_dt ELSE NULL END AS answered_at,
    CASE L.action_yn WHEN 'Y' THEN 'RESOLVED' ELSE 'OPEN' END AS resolution_state,
    NULL::SMALLINT                                            AS user_satisfaction,
    L.reg_dt                                                  AS reg_dt,
    L.upd_dt                                                  AS upd_dt,
    'N'::CHAR(1)                                              AS is_deleted
FROM tb_board_cs L
LEFT JOIN tb_category_mapping M
       ON M.legacy_cs_div  = L.cs_div
      AND (M.legacy_cs_kind = COALESCE(L.cs_kind, '')
        OR M.legacy_cs_kind = '')

UNION ALL

SELECT
    'N'                              AS source,
    CAST(N.inquiry_id AS VARCHAR(20)) AS inquiry_id,
    N.user_id                        AS user_id,
    N.user_name                      AS user_name,
    N.title                          AS title,
    N.body                           AS body,
    N.inquiry_date                   AS inquiry_date,
    N.predicted_category             AS predicted_category,
    N.predicted_confidence           AS predicted_confidence,
    N.classified_by_model            AS classified_by_model,
    N.classified_at                  AS classified_at,
    N.actual_category                AS actual_category,
    N.assigned_to                    AS assigned_to,
    N.reroute_count                  AS reroute_count,
    N.answer_body                    AS answer_body,
    N.answered_by                    AS answered_by,
    N.answered_at                    AS answered_at,
    N.resolution_state               AS resolution_state,
    N.user_satisfaction              AS user_satisfaction,
    N.reg_dt                         AS reg_dt,
    N.upd_dt                         AS upd_dt,
    N.is_deleted                     AS is_deleted
FROM tb_inquiry N
WHERE N.is_deleted = 'N';

COMMENT ON VIEW v_inquiry IS '1:1 문의 통합 조회 — legacy tb_board_cs (source=L) + 신규 tb_inquiry (source=N)';
