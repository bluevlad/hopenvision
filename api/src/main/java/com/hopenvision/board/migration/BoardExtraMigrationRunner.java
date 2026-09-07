package com.hopenvision.board.migration;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.sql.Clob;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * Oracle TB_BOARD_MNG / TB_BOARD_CATEGORY_INFO / TB_BOARD2 / TB_BOARD_CS / TB_BOARD_FILE
 * → PostgreSQL 5개 테이블 마이그레이션.
 *
 * 활성화: --spring.profiles.active=...,migrate-board AND migrate.board.extra.enabled=true
 *
 * 모드:
 *   migrate.board.dry-run=true (기본)            → SELECT/COUNT만, PG 영향 0
 *   migrate.board.dry-run=false                  → PG 적재 + tb_board2 self-ref UPDATE
 *                                                  + tb_board_file parent_table 라우팅
 *
 * 적재 순서: tb_board_mng → tb_board_category_info → tb_board2 → tb_board_cs → tb_board_file
 *
 * 멱등성: 각 테이블이 비어있을 때만 적재. 재실행 시 DELETE 후 진행 필요.
 */
@Slf4j
@Component
@Profile("migrate-board")
@ConditionalOnProperty(prefix = "migrate.board.extra", name = "enabled", havingValue = "true")
@Order(10)
public class BoardExtraMigrationRunner implements CommandLineRunner {

    private static final String SOURCE_PUBLIC = "WILLBES_PUBLIC";
    private static final String SOURCE_GOSI   = "WILLBES_GOSI";

    private final JdbcTemplate oraclePublic;
    private final JdbcTemplate oracleGosi;
    private final JdbcTemplate pgJdbc;

    @Value("${migrate.board.dry-run:true}")
    private boolean dryRun;

    @Value("${migrate.board.extra.chunk-size:500}")
    private int chunkSize;

    public BoardExtraMigrationRunner(
            @Qualifier("oraclePublicJdbc") JdbcTemplate oraclePublic,
            @Qualifier("oracleGosiJdbc") JdbcTemplate oracleGosi,
            @Qualifier("pgJdbc") JdbcTemplate pgJdbc) {
        this.oraclePublic = oraclePublic;
        this.oracleGosi = oracleGosi;
        this.pgJdbc = pgJdbc;
    }

    @Override
    public void run(String... args) {
        log.info("===============================================");
        log.info("Board EXTRA Migration Runner (dryRun={}, chunkSize={})", dryRun, chunkSize);
        log.info("===============================================");

        verifyOracleCounts();

        if (dryRun) {
            log.info("[DRY-RUN] PG 적재 없이 종료. 실행하려면 MIGRATE_DRY_RUN=false");
            return;
        }

        if (!guardEmpty()) return;

        // 1) tb_board_mng
        long mngPub = insertBoardMng(oraclePublic, SOURCE_PUBLIC);
        long mngGos = insertBoardMng(oracleGosi,   SOURCE_GOSI);
        log.info("[tb_board_mng] PUBLIC={}건, GOSI={}건 INSERT", mngPub, mngGos);

        // 2) tb_board_category_info
        long catPub = insertCategoryInfo(oraclePublic, SOURCE_PUBLIC);
        long catGos = insertCategoryInfo(oracleGosi,   SOURCE_GOSI);
        log.info("[tb_board_category_info] PUBLIC={}건, GOSI={}건 INSERT", catPub, catGos);

        // 3) tb_board2 (+ self-ref UPDATE)
        long b2Pub = insertBoard2(oraclePublic, SOURCE_PUBLIC);
        long b2Gos = insertBoard2(oracleGosi,   SOURCE_GOSI);
        log.info("[tb_board2] PUBLIC={}건, GOSI={}건 INSERT", b2Pub, b2Gos);
        int board2ParentUpdated = pgJdbc.update(
            "UPDATE tb_board2 c "
          + "SET    parent_board2_id = p.board2_id "
          + "FROM   tb_board2 p "
          + "WHERE  c.parent_board2_id IS NULL "
          + "  AND  c.legacy_parent_seq IS NOT NULL "
          + "  AND  c.legacy_parent_seq <> '0' "
          + "  AND  c.legacy_parent_seq <> c.legacy_board_seq "
          + "  AND  p.legacy_source        = c.legacy_source "
          + "  AND  p.legacy_board_mng_seq = c.legacy_board_mng_seq "
          + "  AND  p.legacy_board_seq     = c.legacy_parent_seq");
        log.info("[tb_board2] parent_board2_id {}건 업데이트", board2ParentUpdated);

        // 4) tb_board_cs
        long csPub = insertBoardCs(oraclePublic, SOURCE_PUBLIC);
        long csGos = insertBoardCs(oracleGosi,   SOURCE_GOSI);
        log.info("[tb_board_cs] PUBLIC={}건, GOSI={}건 INSERT", csPub, csGos);

        // 5) tb_board_file (+ parent_table 라우팅)
        long fPub = insertBoardFile(oraclePublic, SOURCE_PUBLIC);
        long fGos = insertBoardFile(oracleGosi,   SOURCE_GOSI);
        log.info("[tb_board_file] PUBLIC={}건, GOSI={}건 INSERT", fPub, fGos);
        routeBoardFile();

        printValidation();
    }

    private void verifyOracleCounts() {
        log.info("[Oracle] 행 수 검증:");
        for (String t : new String[]{
                "TB_BOARD_MNG","TB_BOARD_CATEGORY_INFO","TB_BOARD2","TB_BOARD_CS","TB_BOARD_FILE"}) {
            Integer pub = oraclePublic.queryForObject("SELECT COUNT(*) FROM " + t, Integer.class);
            Integer gos = oracleGosi.queryForObject("SELECT COUNT(*) FROM " + t, Integer.class);
            log.info("  {} : PUBLIC={}, GOSI={}", t, pub, gos);
        }
    }

    private boolean guardEmpty() {
        for (String t : new String[]{
                "tb_board_mng","tb_board_category_info","tb_board2","tb_board_cs","tb_board_file"}) {
            Integer cnt = pgJdbc.queryForObject("SELECT COUNT(*) FROM " + t, Integer.class);
            if (cnt != null && cnt > 0) {
                log.error("[GUARD] {} 에 이미 {}건 존재 → 중단. 재실행 전 DELETE 필요.", t, cnt);
                return false;
            }
        }
        return true;
    }

    // ============================================================
    // 1) TB_BOARD_MNG
    // ============================================================
    private static final String INS_MNG =
        "INSERT INTO tb_board_mng ("
      + "  legacy_source, legacy_board_mng_seq, legacy_onoff_div, "
      + "  board_mng_name, board_mng_type, attach_file_yn, open_yn, reply_yn, isuse, "
      + "  reg_dt, reg_id, upd_dt, upd_id"
      + ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?) ON CONFLICT DO NOTHING";

    private long insertBoardMng(JdbcTemplate oracle, String source) {
        List<MngRow> buf = new ArrayList<>(chunkSize);
        long[] cnt = {0};
        oracle.query(
            "SELECT ONOFF_DIV, BOARD_MNG_SEQ, BOARD_MNG_NAME, BOARD_MNG_TYPE, "
          + "       ATTACH_FILE_YN, OPEN_YN, REPLY_YN, ISUSE, "
          + "       REG_DT, REG_ID, UPD_DT, UPD_ID FROM TB_BOARD_MNG",
            (ResultSet rs) -> {
                buf.add(MngRow.from(rs));
                if (buf.size() >= chunkSize) { cnt[0] += flushMng(buf, source); buf.clear(); }
            });
        if (!buf.isEmpty()) { cnt[0] += flushMng(buf, source); buf.clear(); }
        return cnt[0];
    }

    private int flushMng(List<MngRow> rows, String source) {
        return pgJdbc.batchUpdate(INS_MNG, new BatchPreparedStatementSetter() {
            @Override public int getBatchSize() { return rows.size(); }
            @Override public void setValues(PreparedStatement ps, int i) throws SQLException {
                MngRow r = rows.get(i); int k = 1;
                ps.setString(k++, source);
                ps.setString(k++, r.boardMngSeq);
                ps.setString(k++, r.onoffDiv);
                ps.setString(k++, r.boardMngName);
                ps.setString(k++, r.boardMngType);
                ps.setString(k++, r.attachFileYn);
                ps.setString(k++, r.openYn);
                ps.setString(k++, r.replyYn);
                ps.setString(k++, r.isuse);
                ps.setTimestamp(k++, r.regDt);
                ps.setString(k++, r.regId);
                ps.setTimestamp(k++, r.updDt);
                ps.setString(k++, r.updId);
            }
        }).length;
    }

    private static class MngRow {
        String onoffDiv, boardMngSeq, boardMngName, boardMngType;
        String attachFileYn, openYn, replyYn, isuse, regId, updId;
        Timestamp regDt, updDt;
        static MngRow from(ResultSet rs) throws SQLException {
            MngRow r = new MngRow();
            r.onoffDiv     = rs.getString("ONOFF_DIV");
            r.boardMngSeq  = rs.getString("BOARD_MNG_SEQ");
            r.boardMngName = rs.getString("BOARD_MNG_NAME");
            r.boardMngType = rs.getString("BOARD_MNG_TYPE");
            r.attachFileYn = rs.getString("ATTACH_FILE_YN");
            r.openYn       = rs.getString("OPEN_YN");
            r.replyYn      = rs.getString("REPLY_YN");
            r.isuse        = rs.getString("ISUSE");
            r.regDt        = rs.getTimestamp("REG_DT");
            r.regId        = rs.getString("REG_ID");
            r.updDt        = rs.getTimestamp("UPD_DT");
            r.updId        = rs.getString("UPD_ID");
            return r;
        }
    }

    // ============================================================
    // 2) TB_BOARD_CATEGORY_INFO
    // ============================================================
    private static final String INS_CAT =
        "INSERT INTO tb_board_category_info ("
      + "  legacy_source, legacy_board_mng_seq, legacy_board_seq, category_code"
      + ") VALUES (?,?,?,?) ON CONFLICT DO NOTHING";

    private long insertCategoryInfo(JdbcTemplate oracle, String source) {
        List<CatRow> buf = new ArrayList<>(chunkSize);
        long[] cnt = {0};
        oracle.query(
            "SELECT BOARD_MNG_SEQ, BOARD_SEQ, CATEGORY_CODE FROM TB_BOARD_CATEGORY_INFO",
            (ResultSet rs) -> {
                CatRow r = new CatRow();
                r.boardMngSeq  = rs.getString("BOARD_MNG_SEQ");
                r.boardSeq     = rs.getString("BOARD_SEQ");
                r.categoryCode = rs.getString("CATEGORY_CODE");
                buf.add(r);
                if (buf.size() >= chunkSize) { cnt[0] += flushCat(buf, source); buf.clear(); }
            });
        if (!buf.isEmpty()) { cnt[0] += flushCat(buf, source); buf.clear(); }
        return cnt[0];
    }

    private int flushCat(List<CatRow> rows, String source) {
        return pgJdbc.batchUpdate(INS_CAT, new BatchPreparedStatementSetter() {
            @Override public int getBatchSize() { return rows.size(); }
            @Override public void setValues(PreparedStatement ps, int i) throws SQLException {
                CatRow r = rows.get(i); int k = 1;
                ps.setString(k++, source);
                ps.setString(k++, r.boardMngSeq);
                ps.setString(k++, r.boardSeq);
                ps.setString(k++, r.categoryCode);
            }
        }).length;
    }

    private static class CatRow {
        String boardMngSeq, boardSeq, categoryCode;
    }

    // ============================================================
    // 3) TB_BOARD2
    // ============================================================
    private static final String INS_B2 =
        "INSERT INTO tb_board2 ("
      + "  legacy_source, legacy_board_mng_seq, legacy_board_seq, legacy_parent_seq, "
      + "  open_yn, notice_top_yn, subject, content, answer, "
      + "  file_path, file_name, real_file_name, "
      + "  thumbnail_file_path, thumbnail_file_name, thumbnail_file_real_name, "
      + "  reg_dt, reg_id, upd_dt, upd_id, hits, create_name, issue, recommend"
      + ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ON CONFLICT DO NOTHING";

    private long insertBoard2(JdbcTemplate oracle, String source) {
        List<Board2Row> buf = new ArrayList<>(chunkSize);
        long[] cnt = {0};
        oracle.query(
            "SELECT BOARD_MNG_SEQ, BOARD_SEQ, PARENT_BOARD_SEQ, OPEN_YN, NOTICE_TOP_YN, "
          + "       SUBJECT, CONTENT, ANSWER, "
          + "       FILE_PATH, FILE_NAME, REAL_FILE_NAME, "
          + "       THUMBNAIL_FILE_PATH, THUMBNAIL_FILE_NAME, THUMBNAIL_FILE_REAL_NAME, "
          + "       REG_DT, REG_ID, UPD_DT, UPD_ID, HITS, CREATENAME, ISSUE, RECOMMEND "
          + "FROM   TB_BOARD2",
            (ResultSet rs) -> {
                buf.add(Board2Row.from(rs));
                if (buf.size() >= chunkSize) { cnt[0] += flushBoard2(buf, source); buf.clear(); }
            });
        if (!buf.isEmpty()) { cnt[0] += flushBoard2(buf, source); buf.clear(); }
        return cnt[0];
    }

    private int flushBoard2(List<Board2Row> rows, String source) {
        return pgJdbc.batchUpdate(INS_B2, new BatchPreparedStatementSetter() {
            @Override public int getBatchSize() { return rows.size(); }
            @Override public void setValues(PreparedStatement ps, int i) throws SQLException {
                Board2Row r = rows.get(i); int k = 1;
                ps.setString(k++, source);
                ps.setString(k++, r.boardMngSeq);
                ps.setString(k++, r.boardSeq);
                ps.setString(k++, r.parentBoardSeq);
                ps.setString(k++, r.openYn);
                ps.setString(k++, r.noticeTopYn);
                ps.setString(k++, r.subject);
                ps.setString(k++, r.content);
                ps.setString(k++, r.answer);
                ps.setString(k++, r.filePath);
                ps.setString(k++, r.fileName);
                ps.setString(k++, r.realFileName);
                ps.setString(k++, r.thumbPath);
                ps.setString(k++, r.thumbName);
                ps.setString(k++, r.thumbRealName);
                ps.setTimestamp(k++, r.regDt);
                ps.setString(k++, r.regId);
                ps.setTimestamp(k++, r.updDt);
                ps.setString(k++, r.updId);
                setNullableLong(ps, k++, r.hits);
                ps.setString(k++, r.createName);
                ps.setString(k++, r.issue);
                ps.setString(k++, r.recommend);
            }
        }).length;
    }

    private static class Board2Row {
        String boardMngSeq, boardSeq, parentBoardSeq, openYn, noticeTopYn;
        String subject, content, answer;
        String filePath, fileName, realFileName, thumbPath, thumbName, thumbRealName;
        Timestamp regDt, updDt;
        String regId, updId, createName, issue, recommend;
        Long hits;
        static Board2Row from(ResultSet rs) throws SQLException {
            Board2Row r = new Board2Row();
            r.boardMngSeq    = rs.getString("BOARD_MNG_SEQ");
            r.boardSeq       = rs.getString("BOARD_SEQ");
            r.parentBoardSeq = rs.getString("PARENT_BOARD_SEQ");
            r.openYn         = rs.getString("OPEN_YN");
            r.noticeTopYn    = rs.getString("NOTICE_TOP_YN");
            r.subject        = rs.getString("SUBJECT");
            r.content        = clobToString(rs.getClob("CONTENT"));
            r.answer         = clobToString(rs.getClob("ANSWER"));
            r.filePath       = rs.getString("FILE_PATH");
            r.fileName       = rs.getString("FILE_NAME");
            r.realFileName   = rs.getString("REAL_FILE_NAME");
            r.thumbPath      = rs.getString("THUMBNAIL_FILE_PATH");
            r.thumbName      = rs.getString("THUMBNAIL_FILE_NAME");
            r.thumbRealName  = rs.getString("THUMBNAIL_FILE_REAL_NAME");
            r.regDt          = rs.getTimestamp("REG_DT");
            r.regId          = rs.getString("REG_ID");
            r.updDt          = rs.getTimestamp("UPD_DT");
            r.updId          = rs.getString("UPD_ID");
            long hv = rs.getLong("HITS");
            r.hits           = rs.wasNull() ? null : hv;
            r.createName     = rs.getString("CREATENAME");
            r.issue          = rs.getString("ISSUE");
            r.recommend      = rs.getString("RECOMMEND");
            return r;
        }
    }

    // ============================================================
    // 4) TB_BOARD_CS
    // ============================================================
    private static final String INS_CS =
        "INSERT INTO tb_board_cs ("
      + "  legacy_source, legacy_board_mng_seq, legacy_board_seq, legacy_parent_seq, "
      + "  cs_div, cs_kind, open_yn, notice_top_yn, "
      + "  subject, content, answer, "
      + "  file_path, file_name, real_file_name, "
      + "  thumbnail_file_path, thumbnail_file_name, thumbnail_file_real_name, "
      + "  reg_dt, reg_id, upd_dt, upd_id, hits, create_name, issue, recommend, "
      + "  counselor_id, action_yn"
      + ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ON CONFLICT DO NOTHING";

    private long insertBoardCs(JdbcTemplate oracle, String source) {
        List<CsRow> buf = new ArrayList<>(chunkSize);
        long[] cnt = {0};
        oracle.query(
            "SELECT BOARD_MNG_SEQ, BOARD_SEQ, PARENT_BOARD_SEQ, CS_DIV, CS_KIND, "
          + "       OPEN_YN, NOTICE_TOP_YN, SUBJECT, CONTENT, ANSWER, "
          + "       FILE_PATH, FILE_NAME, REAL_FILE_NAME, "
          + "       THUMBNAIL_FILE_PATH, THUMBNAIL_FILE_NAME, THUMBNAIL_FILE_REAL_NAME, "
          + "       REG_DT, REG_ID, UPD_DT, UPD_ID, HITS, CREATENAME, ISSUE, RECOMMEND, "
          + "       COUNSELOR_ID, ACTION_YN "
          + "FROM   TB_BOARD_CS",
            (ResultSet rs) -> {
                buf.add(CsRow.from(rs));
                if (buf.size() >= chunkSize) { cnt[0] += flushCs(buf, source); buf.clear(); }
            });
        if (!buf.isEmpty()) { cnt[0] += flushCs(buf, source); buf.clear(); }
        return cnt[0];
    }

    private int flushCs(List<CsRow> rows, String source) {
        return pgJdbc.batchUpdate(INS_CS, new BatchPreparedStatementSetter() {
            @Override public int getBatchSize() { return rows.size(); }
            @Override public void setValues(PreparedStatement ps, int i) throws SQLException {
                CsRow r = rows.get(i); int k = 1;
                ps.setString(k++, source);
                ps.setString(k++, r.boardMngSeq);
                ps.setString(k++, r.boardSeq);
                ps.setString(k++, r.parentBoardSeq);
                ps.setString(k++, r.csDiv);
                ps.setString(k++, r.csKind);
                ps.setString(k++, r.openYn);
                ps.setString(k++, r.noticeTopYn);
                ps.setString(k++, r.subject);
                ps.setString(k++, r.content);
                ps.setString(k++, r.answer);
                ps.setString(k++, r.filePath);
                ps.setString(k++, r.fileName);
                ps.setString(k++, r.realFileName);
                ps.setString(k++, r.thumbPath);
                ps.setString(k++, r.thumbName);
                ps.setString(k++, r.thumbRealName);
                ps.setTimestamp(k++, r.regDt);
                ps.setString(k++, r.regId);
                ps.setTimestamp(k++, r.updDt);
                ps.setString(k++, r.updId);
                setNullableLong(ps, k++, r.hits);
                ps.setString(k++, r.createName);
                ps.setString(k++, r.issue);
                ps.setString(k++, r.recommend);
                ps.setString(k++, r.counselorId);
                ps.setString(k++, r.actionYn);
            }
        }).length;
    }

    private static class CsRow {
        String boardMngSeq, boardSeq, parentBoardSeq, csDiv, csKind;
        String openYn, noticeTopYn, subject, content, answer;
        String filePath, fileName, realFileName, thumbPath, thumbName, thumbRealName;
        Timestamp regDt, updDt;
        String regId, updId, createName, issue, recommend, counselorId, actionYn;
        Long hits;
        static CsRow from(ResultSet rs) throws SQLException {
            CsRow r = new CsRow();
            r.boardMngSeq    = rs.getString("BOARD_MNG_SEQ");
            r.boardSeq       = rs.getString("BOARD_SEQ");
            r.parentBoardSeq = rs.getString("PARENT_BOARD_SEQ");
            r.csDiv          = rs.getString("CS_DIV");
            r.csKind         = rs.getString("CS_KIND");
            r.openYn         = rs.getString("OPEN_YN");
            r.noticeTopYn    = rs.getString("NOTICE_TOP_YN");
            r.subject        = rs.getString("SUBJECT");
            r.content        = clobToString(rs.getClob("CONTENT"));
            r.answer         = clobToString(rs.getClob("ANSWER"));
            r.filePath       = rs.getString("FILE_PATH");
            r.fileName       = rs.getString("FILE_NAME");
            r.realFileName   = rs.getString("REAL_FILE_NAME");
            r.thumbPath      = rs.getString("THUMBNAIL_FILE_PATH");
            r.thumbName      = rs.getString("THUMBNAIL_FILE_NAME");
            r.thumbRealName  = rs.getString("THUMBNAIL_FILE_REAL_NAME");
            r.regDt          = rs.getTimestamp("REG_DT");
            r.regId          = rs.getString("REG_ID");
            r.updDt          = rs.getTimestamp("UPD_DT");
            r.updId          = rs.getString("UPD_ID");
            long hv = rs.getLong("HITS");
            r.hits           = rs.wasNull() ? null : hv;
            r.createName     = rs.getString("CREATENAME");
            r.issue          = rs.getString("ISSUE");
            r.recommend      = rs.getString("RECOMMEND");
            r.counselorId    = rs.getString("COUNSELOR_ID");
            r.actionYn       = rs.getString("ACTION_YN");
            return r;
        }
    }

    // ============================================================
    // 5) TB_BOARD_FILE
    // ============================================================
    private static final String INS_FILE =
        "INSERT INTO tb_board_file ("
      + "  legacy_source, legacy_board_mng_seq, legacy_board_seq, legacy_file_no, legacy_parent_seq, "
      + "  file_name, file_path, "
      + "  reg_dt, reg_id, upd_dt, upd_id"
      + ") VALUES (?,?,?,?,?,?,?,?,?,?,?)";

    private long insertBoardFile(JdbcTemplate oracle, String source) {
        List<FileRow> buf = new ArrayList<>(chunkSize);
        long[] cnt = {0};
        oracle.query(
            "SELECT BOARD_MNG_SEQ, BOARD_SEQ, FILE_NO, PARENT_BOARD_SEQ, "
          + "       FILE_NAME, FILE_PATH, REG_DT, REG_ID, UPD_DT, UPD_ID "
          + "FROM   TB_BOARD_FILE",
            (ResultSet rs) -> {
                FileRow r = new FileRow();
                r.boardMngSeq    = rs.getString("BOARD_MNG_SEQ");
                r.boardSeq       = rs.getString("BOARD_SEQ");
                r.fileNo         = rs.getString("FILE_NO");
                r.parentBoardSeq = rs.getString("PARENT_BOARD_SEQ");
                r.fileName       = rs.getString("FILE_NAME");
                r.filePath       = rs.getString("FILE_PATH");
                r.regDt          = rs.getTimestamp("REG_DT");
                r.regId          = rs.getString("REG_ID");
                r.updDt          = rs.getTimestamp("UPD_DT");
                r.updId          = rs.getString("UPD_ID");
                buf.add(r);
                if (buf.size() >= chunkSize) { cnt[0] += flushFile(buf, source); buf.clear(); }
            });
        if (!buf.isEmpty()) { cnt[0] += flushFile(buf, source); buf.clear(); }
        return cnt[0];
    }

    private int flushFile(List<FileRow> rows, String source) {
        return pgJdbc.batchUpdate(INS_FILE, new BatchPreparedStatementSetter() {
            @Override public int getBatchSize() { return rows.size(); }
            @Override public void setValues(PreparedStatement ps, int i) throws SQLException {
                FileRow r = rows.get(i); int k = 1;
                ps.setString(k++, source);
                ps.setString(k++, r.boardMngSeq);
                ps.setString(k++, r.boardSeq);
                ps.setString(k++, r.fileNo);
                ps.setString(k++, r.parentBoardSeq);
                ps.setString(k++, r.fileName);
                ps.setString(k++, r.filePath);
                ps.setTimestamp(k++, r.regDt);
                ps.setString(k++, r.regId);
                ps.setTimestamp(k++, r.updDt);
                ps.setString(k++, r.updId);
            }
        }).length;
    }

    private static class FileRow {
        String boardMngSeq, boardSeq, fileNo, parentBoardSeq;
        String fileName, filePath, regId, updId;
        Timestamp regDt, updDt;
    }

    /**
     * tb_board_file.parent_table 라우팅:
     *   BOARD_MNG_SEQ 가 어느 부모 테이블의 board_mng_seq 분포에 속하는지로 결정.
     *   같은 SEQ 가 여러 테이블에 등장하면 우선순위: CS > BOARD2 > BOARD.
     *   기존 tb_board 는 board_mng_seq 컬럼명을 그대로 사용 (legacy 접두사 없음).
     */
    private void routeBoardFile() {
        log.info("[tb_board_file] parent_table 라우팅 시작 (우선순위: BOARD < BOARD2 < CS)");

        int n1 = pgJdbc.update(
            "UPDATE tb_board_file f "
          + "SET    parent_table = 'TB_BOARD' "
          + "WHERE  f.parent_table IS NULL "
          + "  AND  f.legacy_board_mng_seq IS NOT NULL "
          + "  AND  EXISTS (SELECT 1 FROM tb_board b "
          + "                WHERE b.legacy_source = f.legacy_source "
          + "                  AND b.board_mng_seq = f.legacy_board_mng_seq)");
        log.info("  TB_BOARD 매핑: {}건", n1);

        int n2 = pgJdbc.update(
            "UPDATE tb_board_file f "
          + "SET    parent_table = 'TB_BOARD2' "
          + "WHERE  f.legacy_board_mng_seq IS NOT NULL "
          + "  AND  EXISTS (SELECT 1 FROM tb_board2 b "
          + "                WHERE b.legacy_source        = f.legacy_source "
          + "                  AND b.legacy_board_mng_seq = f.legacy_board_mng_seq)");
        log.info("  TB_BOARD2 매핑(덮어쓰기 포함): {}건", n2);

        int n3 = pgJdbc.update(
            "UPDATE tb_board_file f "
          + "SET    parent_table = 'TB_BOARD_CS' "
          + "WHERE  f.legacy_board_mng_seq IS NOT NULL "
          + "  AND  EXISTS (SELECT 1 FROM tb_board_cs c "
          + "                WHERE c.legacy_source        = f.legacy_source "
          + "                  AND c.legacy_board_mng_seq = f.legacy_board_mng_seq)");
        log.info("  TB_BOARD_CS 매핑(덮어쓰기 포함): {}건", n3);

        Integer unrouted = pgJdbc.queryForObject(
            "SELECT COUNT(*) FROM tb_board_file "
          + "WHERE  parent_table IS NULL AND legacy_board_mng_seq IS NOT NULL",
            Integer.class);
        log.info("  매핑 실패 (BOARD_MNG_SEQ 존재하나 부모 테이블 없음): {}건", unrouted);
    }

    // ============================================================
    // Helpers
    // ============================================================

    private static String clobToString(Clob clob) throws SQLException {
        if (clob == null) return null;
        long len = clob.length();
        if (len == 0) return null;
        return clob.getSubString(1, (int) Math.min(len, Integer.MAX_VALUE));
    }

    private static void setNullableLong(PreparedStatement ps, int idx, Long v) throws SQLException {
        if (v == null) ps.setNull(idx, Types.BIGINT); else ps.setLong(idx, v);
    }

    private void printValidation() {
        log.info("--- 검증: 테이블별 스키마 행 수 ---");
        for (String t : new String[]{
                "tb_board_mng","tb_board_category_info","tb_board2","tb_board_cs","tb_board_file"}) {
            pgJdbc.query(
                "SELECT legacy_source, COUNT(*) FROM " + t + " GROUP BY legacy_source ORDER BY 1",
                (ResultSet rs) -> log.info("  {} [{}] = {}건",
                    t, rs.getString(1), rs.getLong(2)));
        }

        log.info("--- 검증: tb_board2 답글 매핑 ---");
        pgJdbc.query(
            "SELECT legacy_source, "
          + "       SUM(CASE WHEN parent_board2_id IS NULL THEN 1 ELSE 0 END) AS root, "
          + "       SUM(CASE WHEN parent_board2_id IS NOT NULL THEN 1 ELSE 0 END) AS reply "
          + "FROM   tb_board2 GROUP BY legacy_source ORDER BY 1",
            (ResultSet rs) -> log.info("  tb_board2 [{}] root={}, reply={}",
                rs.getString(1), rs.getLong(2), rs.getLong(3)));

        log.info("--- 검증: tb_board_file parent_table 라우팅 ---");
        pgJdbc.query(
            "SELECT legacy_source, parent_table, COUNT(*) FROM tb_board_file "
          + "GROUP BY legacy_source, parent_table ORDER BY 1, 2",
            (ResultSet rs) -> log.info("  tb_board_file [{}] parent_table={} : {}건",
                rs.getString(1), rs.getString(2), rs.getLong(3)));
    }
}
