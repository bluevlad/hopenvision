package com.hopenvision.config;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 헬스체크 전용 엔드포인트.
 * /api/health — 애플리케이션 liveness (DB 무관)
 * /api/health/ready — DB 연결 포함 readiness
 */
@RestController
public class HealthController {

    private final DataSource dataSource;

    public HealthController(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @GetMapping("/api/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> result = new LinkedHashMap<>();
        result.put("status", "UP");
        return ResponseEntity.ok(result);
    }

    @GetMapping("/api/health/ready")
    public ResponseEntity<Map<String, Object>> readiness() {
        Map<String, Object> result = new LinkedHashMap<>();
        try (Connection conn = dataSource.getConnection();
             var stmt = conn.createStatement()) {
            stmt.execute("SELECT 1");
            result.put("status", "UP");
            result.put("database", "UP");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            result.put("status", "DOWN");
            result.put("database", "DOWN");
            result.put("error", e.getMessage());
            return ResponseEntity.status(503).body(result);
        }
    }
}
