package com.hopenvision.board.migration;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.stream.Collectors;

/**
 * 5개 추가 게시판 테이블의 Oracle 스키마를 PG 마이그레이션 설계 입력용으로 덤프한다.
 *
 * 활성화 조건: --spring.profiles.active=...,migrate-board AND migrate.board.schema-dump.enabled=true
 *
 * 출력물 (output-dir 하위):
 *   - willbes_public.json : PUBLIC 스키마 컬럼/주석/행수
 *   - willbes_gosi.json   : GOSI 스키마 동일
 *   - schema_diff.txt     : PUBLIC vs GOSI 컬럼 차이 (양쪽 합집합 기준 DDL 설계용)
 *
 * 동시에 동일 프로파일의 {@link BoardMigrationRunner}는 자체적으로 skip 처리됨
 * (schema-dump.enabled=true 일 때 일찍 return).
 */
@Slf4j
@Component
@Profile("migrate-board")
@ConditionalOnProperty(prefix = "migrate.board.schema-dump", name = "enabled", havingValue = "true")
@Order(0)  // BoardMigrationRunner 보다 먼저 실행
public class BoardSchemaDumpRunner implements CommandLineRunner {

    private static final List<String> TARGET_TABLES = List.of(
        "TB_BOARD_MNG",
        "TB_BOARD_CATEGORY_INFO",
        "TB_BOARD2",
        "TB_BOARD_CS",
        "TB_BOARD_FILE"
    );

    private static final String COLUMNS_SQL = ""
        + "SELECT TABLE_NAME, COLUMN_ID, COLUMN_NAME, DATA_TYPE, "
        + "       DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, DATA_DEFAULT "
        + "FROM   USER_TAB_COLUMNS "
        + "WHERE  TABLE_NAME IN ("
        + "  'TB_BOARD_MNG','TB_BOARD_CATEGORY_INFO','TB_BOARD2','TB_BOARD_CS','TB_BOARD_FILE'"
        + ") "
        + "ORDER  BY TABLE_NAME, COLUMN_ID";

    private static final String COL_COMMENTS_SQL = ""
        + "SELECT TABLE_NAME, COLUMN_NAME, COMMENTS "
        + "FROM   USER_COL_COMMENTS "
        + "WHERE  TABLE_NAME IN ("
        + "  'TB_BOARD_MNG','TB_BOARD_CATEGORY_INFO','TB_BOARD2','TB_BOARD_CS','TB_BOARD_FILE'"
        + ")";

    private static final String TABLE_COMMENTS_SQL = ""
        + "SELECT TABLE_NAME, COMMENTS "
        + "FROM   USER_TAB_COMMENTS "
        + "WHERE  TABLE_NAME IN ("
        + "  'TB_BOARD_MNG','TB_BOARD_CATEGORY_INFO','TB_BOARD2','TB_BOARD_CS','TB_BOARD_FILE'"
        + ")";

    private static final String PK_SQL = ""
        + "SELECT c.TABLE_NAME, cc.COLUMN_NAME, cc.POSITION "
        + "FROM   USER_CONSTRAINTS c "
        + "JOIN   USER_CONS_COLUMNS cc ON c.CONSTRAINT_NAME = cc.CONSTRAINT_NAME "
        + "WHERE  c.CONSTRAINT_TYPE = 'P' "
        + "  AND  c.TABLE_NAME IN ("
        + "    'TB_BOARD_MNG','TB_BOARD_CATEGORY_INFO','TB_BOARD2','TB_BOARD_CS','TB_BOARD_FILE'"
        + "  ) "
        + "ORDER  BY c.TABLE_NAME, cc.POSITION";

    private final JdbcTemplate oraclePublic;
    private final JdbcTemplate oracleGosi;

    @Value("${migrate.board.schema-dump.output-dir:./data/board-schema-dump}")
    private String outputDir;

    private final ObjectMapper objectMapper = new ObjectMapper()
        .enable(SerializationFeature.INDENT_OUTPUT);

    public BoardSchemaDumpRunner(
            @Qualifier("oraclePublicJdbc") JdbcTemplate oraclePublic,
            @Qualifier("oracleGosiJdbc") JdbcTemplate oracleGosi) {
        this.oraclePublic = oraclePublic;
        this.oracleGosi = oracleGosi;
    }

    @Override
    public void run(String... args) throws Exception {
        log.info("===============================================");
        log.info("Board Schema Dump Runner");
        log.info("===============================================");

        Path dir = Paths.get(outputDir).toAbsolutePath();
        Files.createDirectories(dir);
        log.info("[DUMP] 출력 디렉토리: {}", dir);

        Map<String, Object> pub = dumpSchema(oraclePublic, "WILLBES_PUBLIC");
        Map<String, Object> gos = dumpSchema(oracleGosi,   "WILLBES_GOSI");

        writeJson(dir.resolve("willbes_public.json"), pub);
        writeJson(dir.resolve("willbes_gosi.json"),   gos);

        writeDiff(dir.resolve("schema_diff.txt"), pub, gos);

        log.info("[DUMP] 완료. 파일 3개 생성: willbes_public.json, willbes_gosi.json, schema_diff.txt");
    }

    private Map<String, Object> dumpSchema(JdbcTemplate oracle, String schema) {
        log.info("[{}] 스키마 덤프 시작", schema);

        Map<String, Map<String, Object>> tables = new LinkedHashMap<>();
        for (String t : TARGET_TABLES) {
            Map<String, Object> tbl = new LinkedHashMap<>();
            tbl.put("columns", new ArrayList<Map<String, Object>>());
            tbl.put("primary_key", new ArrayList<String>());
            tbl.put("table_comment", null);
            tbl.put("row_count", null);
            tables.put(t, tbl);
        }

        // 컬럼 목록
        oracle.query(COLUMNS_SQL, (ResultSet rs) -> {
            String t = rs.getString("TABLE_NAME");
            Map<String, Object> col = new LinkedHashMap<>();
            col.put("ordinal", rs.getInt("COLUMN_ID"));
            col.put("name", rs.getString("COLUMN_NAME"));
            col.put("type", rs.getString("DATA_TYPE"));
            col.put("length", rs.getInt("DATA_LENGTH"));
            int precision = rs.getInt("DATA_PRECISION");
            col.put("precision", rs.wasNull() ? null : precision);
            int scale = rs.getInt("DATA_SCALE");
            col.put("scale", rs.wasNull() ? null : scale);
            col.put("nullable", rs.getString("NULLABLE"));
            col.put("default", rs.getString("DATA_DEFAULT"));
            col.put("comment", null);
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> cols =
                (List<Map<String, Object>>) tables.get(t).get("columns");
            cols.add(col);
        });

        // 컬럼 주석 머지
        oracle.query(COL_COMMENTS_SQL, (ResultSet rs) -> {
            String t = rs.getString("TABLE_NAME");
            String c = rs.getString("COLUMN_NAME");
            String cm = rs.getString("COMMENTS");
            if (cm == null || cm.isBlank()) return;
            Map<String, Object> tbl = tables.get(t);
            if (tbl == null) return;
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> cols = (List<Map<String, Object>>) tbl.get("columns");
            for (Map<String, Object> col : cols) {
                if (c.equals(col.get("name"))) {
                    col.put("comment", cm);
                    break;
                }
            }
        });

        // 테이블 주석
        oracle.query(TABLE_COMMENTS_SQL, (ResultSet rs) -> {
            String t = rs.getString("TABLE_NAME");
            Map<String, Object> tbl = tables.get(t);
            if (tbl != null) tbl.put("table_comment", rs.getString("COMMENTS"));
        });

        // PK
        oracle.query(PK_SQL, (ResultSet rs) -> {
            String t = rs.getString("TABLE_NAME");
            String c = rs.getString("COLUMN_NAME");
            Map<String, Object> tbl = tables.get(t);
            if (tbl == null) return;
            @SuppressWarnings("unchecked")
            List<String> pk = (List<String>) tbl.get("primary_key");
            pk.add(c);
        });

        // 행 수 (테이블별 COUNT — 누락 테이블은 -1)
        for (String t : TARGET_TABLES) {
            try {
                Long cnt = oracle.queryForObject("SELECT COUNT(*) FROM " + t, Long.class);
                tables.get(t).put("row_count", cnt);
                log.info("[{}] {} = {}건", schema, t, cnt);
            } catch (Exception e) {
                tables.get(t).put("row_count", -1L);
                tables.get(t).put("error", e.getMessage());
                log.warn("[{}] {} 행 수 조회 실패: {}", schema, t, e.getMessage());
            }
        }

        Map<String, Object> root = new LinkedHashMap<>();
        root.put("schema", schema);
        root.put("tables", tables);
        return root;
    }

    private void writeJson(Path path, Map<String, Object> data) throws Exception {
        try (var w = Files.newBufferedWriter(path, StandardCharsets.UTF_8)) {
            w.write(objectMapper.writeValueAsString(data));
        }
        log.info("[DUMP] {} 작성", path.getFileName());
    }

    private void writeDiff(Path path, Map<String, Object> pub, Map<String, Object> gos) throws Exception {
        StringBuilder sb = new StringBuilder();
        sb.append("# WILLBES_PUBLIC vs WILLBES_GOSI 컬럼 차이\n");
        sb.append("# (양쪽 합집합 기준으로 PG DDL 설계)\n\n");

        @SuppressWarnings("unchecked")
        Map<String, Map<String, Object>> pubTables =
            (Map<String, Map<String, Object>>) pub.get("tables");
        @SuppressWarnings("unchecked")
        Map<String, Map<String, Object>> gosTables =
            (Map<String, Map<String, Object>>) gos.get("tables");

        for (String t : TARGET_TABLES) {
            sb.append("## ").append(t).append("\n");
            Map<String, ColumnSig> pubCols = sigMap(pubTables.get(t));
            Map<String, ColumnSig> gosCols = sigMap(gosTables.get(t));

            Set<String> allNames = new TreeSet<>();
            allNames.addAll(pubCols.keySet());
            allNames.addAll(gosCols.keySet());

            sb.append(String.format("  PUBLIC 컬럼 %d개, GOSI 컬럼 %d개%n",
                pubCols.size(), gosCols.size()));

            List<String> onlyPub = pubCols.keySet().stream()
                .filter(n -> !gosCols.containsKey(n)).collect(Collectors.toList());
            List<String> onlyGos = gosCols.keySet().stream()
                .filter(n -> !pubCols.containsKey(n)).collect(Collectors.toList());
            if (!onlyPub.isEmpty()) sb.append("  - PUBLIC 전용: ").append(onlyPub).append("\n");
            if (!onlyGos.isEmpty()) sb.append("  - GOSI 전용  : ").append(onlyGos).append("\n");

            List<String> typeDiff = new ArrayList<>();
            for (String n : allNames) {
                ColumnSig p = pubCols.get(n), g = gosCols.get(n);
                if (p != null && g != null && !p.equals(g)) {
                    typeDiff.add(String.format("    %s : PUBLIC=%s / GOSI=%s", n, p, g));
                }
            }
            if (!typeDiff.isEmpty()) {
                sb.append("  - 타입 불일치:\n");
                typeDiff.forEach(d -> sb.append(d).append("\n"));
            }

            if (onlyPub.isEmpty() && onlyGos.isEmpty() && typeDiff.isEmpty()) {
                sb.append("  - (양쪽 스키마 동일)\n");
            }
            sb.append("\n");
        }

        Files.writeString(path, sb.toString(), StandardCharsets.UTF_8);
        log.info("[DUMP] {} 작성", path.getFileName());
    }

    private static Map<String, ColumnSig> sigMap(Map<String, Object> tbl) {
        Map<String, ColumnSig> out = new LinkedHashMap<>();
        if (tbl == null) return out;
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> cols = (List<Map<String, Object>>) tbl.get("columns");
        if (cols == null) return out;
        cols.stream()
            .sorted(Comparator.comparing(c -> ((Number) c.get("ordinal")).intValue()))
            .forEach(c -> out.put((String) c.get("name"), ColumnSig.of(c)));
        return out;
    }

    private record ColumnSig(String type, Integer length, Integer precision, Integer scale, String nullable) {
        static ColumnSig of(Map<String, Object> c) {
            return new ColumnSig(
                (String) c.get("type"),
                c.get("length") == null ? null : ((Number) c.get("length")).intValue(),
                c.get("precision") == null ? null : ((Number) c.get("precision")).intValue(),
                c.get("scale") == null ? null : ((Number) c.get("scale")).intValue(),
                (String) c.get("nullable")
            );
        }
        @Override
        public String toString() {
            StringBuilder sb = new StringBuilder(type);
            if (precision != null) {
                sb.append("(").append(precision);
                if (scale != null && scale != 0) sb.append(",").append(scale);
                sb.append(")");
            } else if (length != null && length > 0) {
                sb.append("(").append(length).append(")");
            }
            sb.append(" ").append("Y".equals(nullable) ? "NULL" : "NOT NULL");
            return sb.toString();
        }
    }
}
