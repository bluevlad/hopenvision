-- ============================================
-- 게시판 추가 5개 테이블 마이그레이션 DDL
-- Source: Oracle WILLBES_PUBLIC + WILLBES_GOSI
--   - TB_BOARD_MNG, TB_BOARD_CATEGORY_INFO, TB_BOARD2, TB_BOARD_CS, TB_BOARD_FILE
-- Target: PostgreSQL hopenvision_dev
-- ============================================
--
-- 적용 순서:
--   1) 이 DDL을 hopenvision PG에 실행 (수동, 1회)
--   2) Spring Boot --spring.profiles.active=dev,migrate-board
--      + MIGRATE_EXTRA_ENABLED=true 로 실행
--      → BoardExtraMigrationRunner 가 5개 테이블 일괄 적재
--   3) 하단 검증 쿼리로 무결성 확인
--
-- 설계 결정:
--   - 양쪽 스키마 (PUBLIC/GOSI) 100% 동일 → 단일 DDL set
--   - 신규 PK: BIGSERIAL <table>_id
--   - 자연 키: (legacy_source, ...) UNIQUE
--   - DATE → TIMESTAMP, NUMBER → BIGINT, CLOB → TEXT, VARCHAR2 → VARCHAR
--   - TB_BOARD2 는 TB_BOARD와 동일 패턴 (self-ref parent)
--   - TB_BOARD_CS 는 thread 없음 (ANSWER 인라인) — parent_*_id 컬럼 미생성
--   - TB_BOARD_FILE 의 parent_table 컬럼: BOARD_MNG_SEQ 분포로 매핑
-- ============================================

-- ============================================
-- 1. TB_BOARD_MNG (게시판 마스터)
--    합성 PK: (BOARD_MNG_SEQ, ONOFF_DIV)
-- ============================================
CREATE TABLE tb_board_mng (
    board_mng_id           BIGSERIAL PRIMARY KEY,

    legacy_source          VARCHAR(20) NOT NULL,
    legacy_board_mng_seq   VARCHAR(20) NOT NULL,
    legacy_onoff_div       VARCHAR(1)  NOT NULL,

    board_mng_name         VARCHAR(200) NOT NULL,
    board_mng_type         VARCHAR(20),
    attach_file_yn         VARCHAR(1),
    open_yn                VARCHAR(1),
    reply_yn               VARCHAR(1),
    isuse                  VARCHAR(1),

    reg_dt                 TIMESTAMP,
    reg_id                 VARCHAR(30),
    upd_dt                 TIMESTAMP,
    upd_id                 VARCHAR(30),

    CONSTRAINT uq_tb_board_mng_legacy
        UNIQUE (legacy_source, legacy_board_mng_seq, legacy_onoff_div)
);
CREATE INDEX idx_tb_board_mng_lookup
    ON tb_board_mng (legacy_source, legacy_board_mng_seq);

COMMENT ON TABLE  tb_board_mng                       IS '게시판 마스터 (WILLBES 마이그레이션)';
COMMENT ON COLUMN tb_board_mng.legacy_onoff_div      IS '오프라인/온라인 구분 (합성 PK 일부)';
COMMENT ON COLUMN tb_board_mng.board_mng_type        IS '게시판 분류 (공지/게시판/FAQ 등)';


-- ============================================
-- 2. TB_BOARD_CATEGORY_INFO (게시판-카테고리 매핑)
--    Oracle PK 없음. 자연 합성 키만 존재.
-- ============================================
CREATE TABLE tb_board_category_info (
    board_category_id      BIGSERIAL PRIMARY KEY,

    legacy_source          VARCHAR(20) NOT NULL,
    legacy_board_mng_seq   VARCHAR(20) NOT NULL,
    legacy_board_seq       VARCHAR(20) NOT NULL,
    category_code          VARCHAR(20) NOT NULL,

    CONSTRAINT uq_tb_board_category_info_legacy
        UNIQUE (legacy_source, legacy_board_mng_seq, legacy_board_seq, category_code)
);
CREATE INDEX idx_tb_board_category_info_lookup
    ON tb_board_category_info (legacy_source, legacy_board_mng_seq, legacy_board_seq);
CREATE INDEX idx_tb_board_category_info_cat
    ON tb_board_category_info (category_code);

COMMENT ON TABLE  tb_board_category_info             IS '게시판 글-카테고리 매핑 (직종 분류)';
COMMENT ON COLUMN tb_board_category_info.category_code IS '직종 코드';


-- ============================================
-- 3. TB_BOARD2 (게시판 v2 - TB_BOARD와 동일 패턴)
--    self-ref parent 있음
-- ============================================
CREATE TABLE tb_board2 (
    board2_id              BIGSERIAL PRIMARY KEY,
    parent_board2_id       BIGINT,

    legacy_source          VARCHAR(20) NOT NULL,
    legacy_board_mng_seq   VARCHAR(20) NOT NULL,
    legacy_board_seq       VARCHAR(20) NOT NULL,
    legacy_parent_seq      VARCHAR(20),

    open_yn                VARCHAR(1),
    notice_top_yn          VARCHAR(1),
    subject                VARCHAR(200),
    content                TEXT,
    answer                 TEXT,

    file_path                VARCHAR(100),
    file_name                VARCHAR(100),
    real_file_name           VARCHAR(100),
    thumbnail_file_path      VARCHAR(100),
    thumbnail_file_name      VARCHAR(100),
    thumbnail_file_real_name VARCHAR(100),

    reg_dt                 TIMESTAMP,
    reg_id                 VARCHAR(30),
    upd_dt                 TIMESTAMP,
    upd_id                 VARCHAR(30),
    hits                   BIGINT,
    create_name            VARCHAR(30),
    issue                  VARCHAR(1),
    recommend              VARCHAR(1),

    CONSTRAINT uq_tb_board2_legacy
        UNIQUE (legacy_source, legacy_board_mng_seq, legacy_board_seq),
    CONSTRAINT fk_tb_board2_parent FOREIGN KEY (parent_board2_id)
        REFERENCES tb_board2(board2_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX idx_tb_board2_lookup
    ON tb_board2 (legacy_source, legacy_board_mng_seq, legacy_board_seq);
CREATE INDEX idx_tb_board2_parent
    ON tb_board2 (parent_board2_id);
CREATE INDEX idx_tb_board2_mng
    ON tb_board2 (legacy_source, legacy_board_mng_seq);

COMMENT ON TABLE  tb_board2                          IS '게시판 v2 (WILLBES 마이그레이션)';
COMMENT ON COLUMN tb_board2.parent_board2_id         IS '답글의 부모 board2_id (원본글은 NULL)';


-- ============================================
-- 4. TB_BOARD_CS (1:1 고객상담)
--    thread 없음. PARENT_BOARD_SEQ 컬럼은 보존만 (parent_*_id 신규 컬럼 미생성)
--    합성 PK: (BOARD_MNG_SEQ, BOARD_SEQ)
-- ============================================
CREATE TABLE tb_board_cs (
    board_cs_id            BIGSERIAL PRIMARY KEY,

    legacy_source          VARCHAR(20) NOT NULL,
    legacy_board_mng_seq   VARCHAR(20) NOT NULL,
    legacy_board_seq       VARCHAR(20) NOT NULL,
    legacy_parent_seq      VARCHAR(20),

    cs_div                 VARCHAR(20),
    cs_kind                VARCHAR(20),
    open_yn                VARCHAR(1),
    notice_top_yn          VARCHAR(1),
    subject                VARCHAR(200),
    content                TEXT,
    answer                 TEXT,

    file_path                VARCHAR(100),
    file_name                VARCHAR(100),
    real_file_name           VARCHAR(100),
    thumbnail_file_path      VARCHAR(100),
    thumbnail_file_name      VARCHAR(100),
    thumbnail_file_real_name VARCHAR(100),

    reg_dt                 TIMESTAMP,
    reg_id                 VARCHAR(30),
    upd_dt                 TIMESTAMP,
    upd_id                 VARCHAR(30),
    hits                   BIGINT,
    create_name            VARCHAR(30),
    issue                  VARCHAR(1),
    recommend              VARCHAR(1),

    counselor_id           VARCHAR(30),
    action_yn              VARCHAR(20),

    CONSTRAINT uq_tb_board_cs_legacy
        UNIQUE (legacy_source, legacy_board_mng_seq, legacy_board_seq)
);
CREATE INDEX idx_tb_board_cs_lookup
    ON tb_board_cs (legacy_source, legacy_board_mng_seq, legacy_board_seq);
CREATE INDEX idx_tb_board_cs_counselor
    ON tb_board_cs (counselor_id);
CREATE INDEX idx_tb_board_cs_mng
    ON tb_board_cs (legacy_source, legacy_board_mng_seq);

COMMENT ON TABLE  tb_board_cs                        IS '1:1 고객상담 (WILLBES 마이그레이션)';
COMMENT ON COLUMN tb_board_cs.counselor_id           IS '상담사 ID';
COMMENT ON COLUMN tb_board_cs.action_yn              IS '조치 여부';


-- ============================================
-- 5. TB_BOARD_FILE (첨부파일 — polymorphic)
--    Oracle BOARD_MNG_SEQ/BOARD_SEQ가 nullable이라 PG도 nullable 보존
--    parent_table 컬럼: 적재 후 BOARD_MNG_SEQ 분포로 채움
-- ============================================
CREATE TABLE tb_board_file (
    board_file_id          BIGSERIAL PRIMARY KEY,

    legacy_source          VARCHAR(20) NOT NULL,
    legacy_board_mng_seq   VARCHAR(20),
    legacy_board_seq       VARCHAR(20),
    legacy_file_no         VARCHAR(20) NOT NULL,
    legacy_parent_seq      VARCHAR(20),

    parent_table           VARCHAR(20),   -- 'TB_BOARD' | 'TB_BOARD2' | 'TB_BOARD_CS' | NULL

    file_name              VARCHAR(100),
    file_path              VARCHAR(100),

    reg_dt                 TIMESTAMP,
    reg_id                 VARCHAR(30),
    upd_dt                 TIMESTAMP,
    upd_id                 VARCHAR(30)
);
CREATE INDEX idx_tb_board_file_lookup
    ON tb_board_file (legacy_source, legacy_board_mng_seq, legacy_board_seq);
CREATE INDEX idx_tb_board_file_parent_table
    ON tb_board_file (parent_table);
CREATE INDEX idx_tb_board_file_mng
    ON tb_board_file (legacy_source, legacy_board_mng_seq);

COMMENT ON TABLE  tb_board_file                      IS '게시판 첨부파일 (TB_BOARD/TB_BOARD2/TB_BOARD_CS 공통)';
COMMENT ON COLUMN tb_board_file.parent_table         IS '첨부 대상 테이블 (적재 후 BOARD_MNG_SEQ 분포로 라우팅)';


-- ============================================
-- 마이그레이션 후 검증 쿼리
-- ============================================

-- (1) 스키마별 행 수
-- SELECT 'tb_board_mng'             AS t, legacy_source, COUNT(*) FROM tb_board_mng             GROUP BY legacy_source UNION ALL
-- SELECT 'tb_board_category_info',  legacy_source, COUNT(*) FROM tb_board_category_info GROUP BY legacy_source UNION ALL
-- SELECT 'tb_board2',                legacy_source, COUNT(*) FROM tb_board2                GROUP BY legacy_source UNION ALL
-- SELECT 'tb_board_cs',              legacy_source, COUNT(*) FROM tb_board_cs              GROUP BY legacy_source UNION ALL
-- SELECT 'tb_board_file',            legacy_source, COUNT(*) FROM tb_board_file            GROUP BY legacy_source
-- ORDER BY 1, 2;
-- 기대값:
--   tb_board_mng            PUBLIC=37   GOSI=53
--   tb_board_category_info  PUBLIC=22007 GOSI=25626
--   tb_board2               PUBLIC=2272 GOSI=2272
--   tb_board_cs             PUBLIC=4426 GOSI=5430
--   tb_board_file           PUBLIC=1860 GOSI=2843

-- (2) tb_board2 답글 매핑 검증
-- SELECT legacy_source,
--        SUM(CASE WHEN parent_board2_id IS NULL THEN 1 ELSE 0 END) AS root_cnt,
--        SUM(CASE WHEN parent_board2_id IS NOT NULL THEN 1 ELSE 0 END) AS reply_cnt
-- FROM   tb_board2 GROUP BY legacy_source;

-- (3) tb_board2 고아 답글
-- SELECT legacy_source, legacy_board_seq, legacy_parent_seq
-- FROM   tb_board2
-- WHERE  parent_board2_id IS NULL
--   AND  legacy_parent_seq IS NOT NULL
--   AND  legacy_parent_seq <> '0'
--   AND  legacy_parent_seq <> legacy_board_seq;

-- (4) tb_board_file parent_table 라우팅 분포
-- SELECT legacy_source, parent_table, COUNT(*)
-- FROM   tb_board_file GROUP BY legacy_source, parent_table
-- ORDER BY 1, 2;

-- (5) tb_board_file 매핑 실패 (parent_table NULL이고 board_mng_seq 존재)
-- SELECT legacy_source, legacy_board_mng_seq, COUNT(*)
-- FROM   tb_board_file
-- WHERE  parent_table IS NULL
--   AND  legacy_board_mng_seq IS NOT NULL
-- GROUP  BY legacy_source, legacy_board_mng_seq
-- ORDER  BY 1, 2;
