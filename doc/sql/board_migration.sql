-- ============================================
-- 게시판 마이그레이션 DDL
-- Source: Oracle WILLBES_PUBLIC.TB_BOARD, WILLBES_GOSI.TB_BOARD
-- Target: PostgreSQL hopenvision.tb_board
-- ============================================
--
-- 적용 순서:
--   1) 이 DDL을 hopenvision PG에 실행 (수동)
--   2) Spring Boot --spring.profiles.active=dev,migrate-board 로 실행
--      → BoardMigrationRunner 가 데이터 적재 + parent 재매핑
--   3) 하단 검증 쿼리로 무결성 확인
--
-- 설계 결정:
--   - 신규 PK: BIGSERIAL board_id
--   - self-ref FK: parent_board_id → board_id (1단 답글만 가정)
--   - legacy_*: 영구 보존 (롤백/역추적용)
--   - PARENT_BOARD_SEQ='0' (Oracle 원본 글) → parent_board_id NULL
--   - 자기참조 5건 (PARENT=BOARD_SEQ) → parent_board_id NULL (원본글로 정규화)
--   - 첨부파일 컬럼(FILE_*, THUMBNAIL_*) 제외 (학습모델 텍스트만 필요)
-- ============================================

CREATE TABLE tb_board (
    board_id            BIGSERIAL PRIMARY KEY,
    parent_board_id     BIGINT,

    -- legacy 추적 (영구 보존)
    legacy_source       VARCHAR(20) NOT NULL,                  -- 'WILLBES_PUBLIC' | 'WILLBES_GOSI'
    legacy_board_seq    VARCHAR(20) NOT NULL,                  -- 원본 BOARD_SEQ
    legacy_parent_seq   VARCHAR(20),                           -- 원본 PARENT_BOARD_SEQ ('0' 또는 다른 BOARD_SEQ)

    -- 본문
    board_mng_seq       VARCHAR(20),                           -- 게시판 분류 (NOTICE_000, BOARD_003 등)
    open_yn             VARCHAR(1),
    notice_top_yn       VARCHAR(1),
    subject             VARCHAR(200),
    content             TEXT,
    answer              TEXT,

    -- 메타데이터
    reg_dt              TIMESTAMP,
    reg_id              VARCHAR(30),
    upd_dt              TIMESTAMP,
    upd_id              VARCHAR(30),
    hits                BIGINT,
    create_name         VARCHAR(30),
    issue               VARCHAR(1),
    recommend           VARCHAR(1),
    board_seq3          BIGINT,

    CONSTRAINT uq_tb_board_legacy UNIQUE (legacy_source, legacy_board_seq),
    CONSTRAINT fk_tb_board_parent FOREIGN KEY (parent_board_id)
        REFERENCES tb_board(board_id) DEFERRABLE INITIALLY DEFERRED
);

CREATE INDEX idx_tb_board_legacy_lookup
    ON tb_board (legacy_source, legacy_board_seq);

CREATE INDEX idx_tb_board_parent
    ON tb_board (parent_board_id);

CREATE INDEX idx_tb_board_mng_seq
    ON tb_board (board_mng_seq);

COMMENT ON TABLE  tb_board                   IS '게시판 (WILLBES 마이그레이션)';
COMMENT ON COLUMN tb_board.board_id          IS '신규 PK';
COMMENT ON COLUMN tb_board.parent_board_id   IS '답글의 부모 board_id (원본글은 NULL)';
COMMENT ON COLUMN tb_board.legacy_source     IS '원본 스키마 (WILLBES_PUBLIC | WILLBES_GOSI)';
COMMENT ON COLUMN tb_board.legacy_board_seq  IS '원본 BOARD_SEQ (VARCHAR2)';
COMMENT ON COLUMN tb_board.legacy_parent_seq IS '원본 PARENT_BOARD_SEQ (검증용 보존)';
COMMENT ON COLUMN tb_board.board_mng_seq     IS '게시판 분류 코드';
COMMENT ON COLUMN tb_board.answer            IS '인라인 답변 (사용 빈도 낮으나 학습모델용 보존)';

-- ============================================
-- 마이그레이션 후 검증 쿼리
-- ============================================

-- (1) 스키마별 건수
-- SELECT legacy_source, COUNT(*) FROM tb_board GROUP BY legacy_source;
-- 기대값: WILLBES_PUBLIC = 18266, WILLBES_GOSI = 19945

-- (2) 원본글 vs 답글 비율
-- SELECT legacy_source,
--        SUM(CASE WHEN parent_board_id IS NULL THEN 1 ELSE 0 END) AS root_cnt,
--        SUM(CASE WHEN parent_board_id IS NOT NULL THEN 1 ELSE 0 END) AS reply_cnt
-- FROM   tb_board GROUP BY legacy_source;

-- (3) 고아 답글 (legacy_parent_seq가 '0'도 아니고 자기참조도 아닌데 parent_board_id NULL) — 매핑 실패
-- SELECT legacy_source, legacy_board_seq, legacy_parent_seq
-- FROM   tb_board
-- WHERE  parent_board_id IS NULL
--   AND  legacy_parent_seq IS NOT NULL
--   AND  legacy_parent_seq <> '0'
--   AND  legacy_parent_seq <> legacy_board_seq;
