package com.hopenvision.board.migration;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.io.BufferedWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Clob;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Oracle TB_BOARD → 출력 마이그레이션 Runner. 3가지 모드:
 *
 * <ul>
 *   <li><b>dry-run</b> (기본): SELECT/COUNT만 수행. PG/파일 영향 0.</li>
 *   <li><b>export</b>: JSONL 파일로 출력. 학습모델 입력용. PG 영향 0.</li>
 *   <li><b>insert</b>: PG tb_board에 적재 + self-join UPDATE 로 parent 재매핑.</li>
 * </ul>
 *
 * 모드 선택 (우선순위):
 *   migrate.board.dry-run=true              → dry-run (기본)
 *   migrate.board.export.enabled=true       → export
 *   migrate.board.dry-run=false, export.enabled=false → insert
 *
 * 실행 예:
 *   # 1) dry-run (안전 검증)
 *   ./gradlew bootRun --args='--spring.profiles.active=local,migrate-board'
 *
 *   # 2) JSONL export (학습 데이터 생성)
 *   MIGRATE_DRY_RUN=false MIGRATE_EXPORT_ENABLED=true \
 *   ./gradlew bootRun --args='--spring.profiles.active=local,migrate-board'
 *
 *   # 3) PG 적재 (필요 시)
 *   MIGRATE_DRY_RUN=false \
 *   ./gradlew bootRun --args='--spring.profiles.active=dev,migrate-board'
 */
@Slf4j
@Component
@Profile("migrate-board")
public class BoardMigrationRunner implements CommandLineRunner {

    private static final String SOURCE_PUBLIC = "WILLBES_PUBLIC";
    private static final String SOURCE_GOSI   = "WILLBES_GOSI";
    private static final DateTimeFormatter ISO = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    private static final String SELECT_SQL = ""
        + "SELECT BOARD_MNG_SEQ, BOARD_SEQ, PARENT_BOARD_SEQ, OPEN_YN, NOTICE_TOP_YN, "
        + "       SUBJECT, CONTENT, ANSWER, "
        + "       REG_DT, REG_ID, UPD_DT, UPD_ID, HITS, CREATENAME, "
        + "       ISSUE, RECOMMEND, BOARD_SEQ3 "
        + "FROM   TB_BOARD";

    private static final String INSERT_SQL = ""
        + "INSERT INTO tb_board ("
        + "  legacy_source, legacy_board_seq, legacy_parent_seq, "
        + "  board_mng_seq, open_yn, notice_top_yn, "
        + "  subject, content, answer, "
        + "  reg_dt, reg_id, upd_dt, upd_id, hits, create_name, "
        + "  issue, recommend, board_seq3"
        + ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

    private static final String UPDATE_PARENT_SQL = ""
        + "UPDATE tb_board c "
        + "SET    parent_board_id = p.board_id "
        + "FROM   tb_board p "
        + "WHERE  c.parent_board_id IS NULL "
        + "  AND  c.legacy_parent_seq IS NOT NULL "
        + "  AND  c.legacy_parent_seq <> '0' "
        + "  AND  c.legacy_parent_seq <> c.legacy_board_seq "
        + "  AND  p.legacy_source     = c.legacy_source "
        + "  AND  p.legacy_board_seq  = c.legacy_parent_seq";

    private final JdbcTemplate oraclePublic;
    private final JdbcTemplate oracleGosi;
    private final JdbcTemplate pgJdbc;

    @Value("${migrate.board.dry-run:true}")
    private boolean dryRun;

    @Value("${migrate.board.chunk-size:500}")
    private int chunkSize;

    @Value("${migrate.board.export.enabled:false}")
    private boolean exportEnabled;

    @Value("${migrate.board.export.output-dir:./data/board-export}")
    private String exportDir;

    @Value("${migrate.board.export.group-by-thread:true}")
    private boolean groupByThread;

    private final ObjectMapper objectMapper = new ObjectMapper()
        .disable(SerializationFeature.FAIL_ON_EMPTY_BEANS);

    public BoardMigrationRunner(
            @Qualifier("oraclePublicJdbc") JdbcTemplate oraclePublic,
            @Qualifier("oracleGosiJdbc") JdbcTemplate oracleGosi,
            @Qualifier("pgJdbc") JdbcTemplate pgJdbc) {
        this.oraclePublic = oraclePublic;
        this.oracleGosi = oracleGosi;
        this.pgJdbc = pgJdbc;
    }

    @Override
    public void run(String... args) throws Exception {
        log.info("===============================================");
        log.info("Board Migration Runner (dryRun={}, exportEnabled={}, chunkSize={})",
            dryRun, exportEnabled, chunkSize);
        log.info("===============================================");

        verifyOracleConnections();

        // 1) dry-run
        if (dryRun) {
            long pub = countOnly(oraclePublic, SOURCE_PUBLIC);
            long gos = countOnly(oracleGosi, SOURCE_GOSI);
            log.info("[DRY-RUN] PUBLIC={}건, GOSI={}건 처리 가능 (실제 출력 없음)", pub, gos);
            return;
        }

        // 2) export 모드
        if (exportEnabled) {
            runExport();
            return;
        }

        // 3) PG 적재 모드
        runInsert();
    }

    // -------------------- 공통 --------------------

    private void verifyOracleConnections() {
        Integer pub = oraclePublic.queryForObject("SELECT COUNT(*) FROM TB_BOARD", Integer.class);
        Integer gos = oracleGosi.queryForObject("SELECT COUNT(*) FROM TB_BOARD", Integer.class);
        log.info("[Oracle] WILLBES_PUBLIC.TB_BOARD = {}건, WILLBES_GOSI.TB_BOARD = {}건", pub, gos);
    }

    private long countOnly(JdbcTemplate oracle, String source) {
        long[] cnt = {0};
        oracle.query(SELECT_SQL, (ResultSet rs) -> {
            Row.from(rs);
            cnt[0]++;
        });
        log.info("[{}] dry-run 변환 {}건", source, cnt[0]);
        return cnt[0];
    }

    // -------------------- EXPORT --------------------

    private void runExport() throws Exception {
        Path dir = Paths.get(exportDir).toAbsolutePath();
        Files.createDirectories(dir);
        log.info("[EXPORT] 출력 디렉토리: {} (groupByThread={})", dir, groupByThread);

        exportSchema(oraclePublic, SOURCE_PUBLIC, dir);
        exportSchema(oracleGosi,   SOURCE_GOSI,   dir);

        log.info("[EXPORT] 완료. 디렉토리: {}", dir);
    }

    private void exportSchema(JdbcTemplate oracle, String source, Path dir) throws Exception {
        log.info("[{}] EXPORT 시작 (전체 행 메모리 로딩)", source);

        List<Row> all = new ArrayList<>(20_000);
        oracle.query(SELECT_SQL, (ResultSet rs) -> { all.add(Row.from(rs)); });
        log.info("[{}] 메모리 로딩 {}건", source, all.size());

        Path outFile = dir.resolve(source.toLowerCase() + (groupByThread ? "_threads.jsonl" : ".jsonl"));
        long written;
        try (BufferedWriter w = Files.newBufferedWriter(outFile, StandardCharsets.UTF_8)) {
            written = groupByThread
                ? writeThreads(all, source, w)
                : writeFlat(all, source, w);
        }
        log.info("[{}] 파일 출력: {} ({}건)", source, outFile, written);
    }

    /** 평면 출력: 한 행 = 한 JSON record */
    private long writeFlat(List<Row> rows, String source, BufferedWriter w) throws Exception {
        long n = 0;
        for (Row r : rows) {
            Map<String, Object> rec = rowToMap(r);
            rec.put("source", source);
            w.write(objectMapper.writeValueAsString(rec));
            w.newLine();
            n++;
        }
        return n;
    }

    /**
     * 그룹 출력: 원본글(parent='0' or NULL or 자기참조) 기준으로 답글을 묶음.
     * 1단(질문-답변) 구조만 가정.
     */
    private long writeThreads(List<Row> rows, String source, BufferedWriter w) throws Exception {
        Map<String, Map<String, Object>> rootByBoardSeq = new LinkedHashMap<>(rows.size());
        List<Row> orphanCandidates = new ArrayList<>();

        // 1차 패스: root 인덱싱
        for (Row r : rows) {
            boolean isRoot = r.parentBoardSeq == null
                || "0".equals(r.parentBoardSeq)
                || r.parentBoardSeq.equals(r.boardSeq);
            if (isRoot) {
                Map<String, Object> thread = rowToMap(r);
                thread.put("source", source);
                thread.put("replies", new ArrayList<Map<String, Object>>());
                rootByBoardSeq.put(r.boardSeq, thread);
            } else {
                orphanCandidates.add(r);
            }
        }

        // 2차 패스: reply 매칭
        long orphanCnt = 0;
        for (Row r : orphanCandidates) {
            Map<String, Object> parent = rootByBoardSeq.get(r.parentBoardSeq);
            Map<String, Object> reply = rowToMap(r);
            if (parent != null) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> replies = (List<Map<String, Object>>) parent.get("replies");
                replies.add(reply);
            } else {
                // parent 매핑 실패 → 단독 thread 로 변환
                reply.put("source", source);
                reply.put("replies", new ArrayList<>());
                reply.put("_orphan", true);
                rootByBoardSeq.put("orphan_" + r.boardSeq, reply);
                orphanCnt++;
            }
        }
        log.info("[{}] root={}, replies={}, orphan={}",
            source, rootByBoardSeq.size() - orphanCnt, orphanCandidates.size() - orphanCnt, orphanCnt);

        long n = 0;
        for (Map<String, Object> thread : rootByBoardSeq.values()) {
            w.write(objectMapper.writeValueAsString(thread));
            w.newLine();
            n++;
        }
        return n;
    }

    private Map<String, Object> rowToMap(Row r) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("board_mng_seq", r.boardMngSeq);
        m.put("board_seq", r.boardSeq);
        m.put("parent_board_seq", r.parentBoardSeq);
        m.put("open_yn", r.openYn);
        m.put("notice_top_yn", r.noticeTopYn);
        m.put("subject", r.subject);
        m.put("content", r.content);
        m.put("answer", r.answer);
        m.put("reg_dt", toIso(r.regDt));
        m.put("reg_id", r.regId);
        m.put("upd_dt", toIso(r.updDt));
        m.put("upd_id", r.updId);
        m.put("hits", r.hits);
        m.put("create_name", r.createName);
        m.put("issue", r.issue);
        m.put("recommend", r.recommend);
        m.put("board_seq3", r.boardSeq3);
        return m;
    }

    private static String toIso(Timestamp ts) {
        return ts == null ? null : ts.toLocalDateTime().format(ISO);
    }

    // -------------------- INSERT (PG 적재) --------------------

    private void runInsert() {
        Integer existing = pgJdbc.queryForObject("SELECT COUNT(*) FROM tb_board", Integer.class);
        log.info("[PG] 기존 tb_board 행수 = {}", existing);
        if (existing != null && existing > 0) {
            log.error("PG tb_board에 데이터가 이미 존재 (count={}). 멱등성 보호를 위해 중단. "
                    + "재실행하려면 DELETE FROM tb_board 후 진행.", existing);
            return;
        }

        long pub = insertSchema(oraclePublic, SOURCE_PUBLIC);
        long gos = insertSchema(oracleGosi,   SOURCE_GOSI);
        log.info("[INSERT] PUBLIC={}건, GOSI={}건 INSERT 완료", pub, gos);

        log.info("[PARENT 매핑] self-join UPDATE 시작");
        int updated = pgJdbc.update(UPDATE_PARENT_SQL);
        log.info("[PARENT 매핑] {}건 parent_board_id 업데이트", updated);

        printValidation();
    }

    private long insertSchema(JdbcTemplate oracle, String source) {
        log.info("[{}] INSERT 시작", source);
        List<Row> buffer = new ArrayList<>(chunkSize);
        long[] inserted = {0};
        oracle.query(SELECT_SQL, (ResultSet rs) -> {
            buffer.add(Row.from(rs));
            if (buffer.size() >= chunkSize) {
                inserted[0] += flushInsert(buffer, source);
                buffer.clear();
            }
        });
        if (!buffer.isEmpty()) {
            inserted[0] += flushInsert(buffer, source);
            buffer.clear();
        }
        log.info("[{}] INSERT {}건", source, inserted[0]);
        return inserted[0];
    }

    private long flushInsert(List<Row> rows, String source) {
        int[] result = pgJdbc.batchUpdate(INSERT_SQL, new BatchPreparedStatementSetter() {
            @Override public int getBatchSize() { return rows.size(); }
            @Override public void setValues(PreparedStatement ps, int i) throws SQLException {
                Row r = rows.get(i);
                int idx = 1;
                ps.setString(idx++, source);
                ps.setString(idx++, r.boardSeq);
                ps.setString(idx++, r.parentBoardSeq);
                ps.setString(idx++, r.boardMngSeq);
                ps.setString(idx++, r.openYn);
                ps.setString(idx++, r.noticeTopYn);
                ps.setString(idx++, r.subject);
                ps.setString(idx++, r.content);
                ps.setString(idx++, r.answer);
                ps.setTimestamp(idx++, r.regDt);
                ps.setString(idx++, r.regId);
                ps.setTimestamp(idx++, r.updDt);
                ps.setString(idx++, r.updId);
                if (r.hits == null) ps.setNull(idx++, java.sql.Types.BIGINT); else ps.setLong(idx++, r.hits);
                ps.setString(idx++, r.createName);
                ps.setString(idx++, r.issue);
                ps.setString(idx++, r.recommend);
                if (r.boardSeq3 == null) ps.setNull(idx++, java.sql.Types.BIGINT); else ps.setLong(idx++, r.boardSeq3);
            }
        });
        return result.length;
    }

    private void printValidation() {
        log.info("--- 검증: 스키마별 건수 ---");
        pgJdbc.query("SELECT legacy_source, COUNT(*) FROM tb_board GROUP BY legacy_source",
            (ResultSet rs) -> { log.info("  {} = {}건", rs.getString(1), rs.getLong(2)); });

        log.info("--- 검증: 원본/답글 비율 ---");
        pgJdbc.query(
            "SELECT legacy_source, "
          + "       SUM(CASE WHEN parent_board_id IS NULL THEN 1 ELSE 0 END) AS root_cnt, "
          + "       SUM(CASE WHEN parent_board_id IS NOT NULL THEN 1 ELSE 0 END) AS reply_cnt "
          + "FROM tb_board GROUP BY legacy_source",
            (ResultSet rs) -> { log.info("  {} root={}, reply={}", rs.getString(1), rs.getLong(2), rs.getLong(3)); });

        log.info("--- 검증: 고아 답글 (parent 매핑 실패) ---");
        Integer orphan = pgJdbc.queryForObject(
            "SELECT COUNT(*) FROM tb_board "
          + "WHERE parent_board_id IS NULL "
          + "  AND legacy_parent_seq IS NOT NULL "
          + "  AND legacy_parent_seq <> '0' "
          + "  AND legacy_parent_seq <> legacy_board_seq",
            Integer.class);
        log.info("  고아 답글 = {}건 (0이면 정상; 자기참조 5건은 제외됨)", orphan);
    }

    // -------------------- Row --------------------

    private static class Row {
        String boardMngSeq;
        String boardSeq;
        String parentBoardSeq;
        String openYn;
        String noticeTopYn;
        String subject;
        String content;
        String answer;
        Timestamp regDt;
        String regId;
        Timestamp updDt;
        String updId;
        Long hits;
        String createName;
        String issue;
        String recommend;
        Long boardSeq3;

        static Row from(ResultSet rs) throws SQLException {
            Row r = new Row();
            r.boardMngSeq    = rs.getString("BOARD_MNG_SEQ");
            r.boardSeq       = rs.getString("BOARD_SEQ");
            r.parentBoardSeq = rs.getString("PARENT_BOARD_SEQ");
            r.openYn         = rs.getString("OPEN_YN");
            r.noticeTopYn    = rs.getString("NOTICE_TOP_YN");
            r.subject        = rs.getString("SUBJECT");
            r.content        = clobToString(rs.getClob("CONTENT"));
            r.answer         = clobToString(rs.getClob("ANSWER"));
            r.regDt          = rs.getTimestamp("REG_DT");
            r.regId          = rs.getString("REG_ID");
            r.updDt          = rs.getTimestamp("UPD_DT");
            r.updId          = rs.getString("UPD_ID");
            long hits        = rs.getLong("HITS");
            r.hits           = rs.wasNull() ? null : hits;
            r.createName     = rs.getString("CREATENAME");
            r.issue          = rs.getString("ISSUE");
            r.recommend      = rs.getString("RECOMMEND");
            long seq3        = rs.getLong("BOARD_SEQ3");
            r.boardSeq3      = rs.wasNull() ? null : seq3;
            return r;
        }

        private static String clobToString(Clob clob) throws SQLException {
            if (clob == null) return null;
            long len = clob.length();
            if (len == 0) return null;
            return clob.getSubString(1, (int) Math.min(len, Integer.MAX_VALUE));
        }
    }
}
