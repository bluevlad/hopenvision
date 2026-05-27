package com.hopenvision.board.migration;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;

/**
 * 게시판 마이그레이션 전용 Oracle DataSource 구성.
 * - oraclePublicJdbc : WILLBES_PUBLIC 스키마
 * - oracleGosiJdbc   : WILLBES_GOSI 스키마
 * - 기본 dataSource(spring.datasource.*) : hopenvision PostgreSQL (그대로 사용)
 *
 * migrate-board 프로파일에서만 활성화.
 */
@Slf4j
@Configuration
@Profile("migrate-board")
public class BoardMigrationConfig {

    @Value("${migrate.board.oracle.url}")
    private String oracleUrl;

    @Value("${migrate.board.oracle.public-user}")
    private String publicUser;

    @Value("${migrate.board.oracle.public-password}")
    private String publicPassword;

    @Value("${migrate.board.oracle.gosi-user}")
    private String gosiUser;

    @Value("${migrate.board.oracle.gosi-password}")
    private String gosiPassword;

    @Bean(name = "pgJdbc")
    @Primary
    public JdbcTemplate pgJdbc(DataSource dataSource) {
        log.info("[migrate-board] PostgreSQL JdbcTemplate 등록 (기본 dataSource)");
        return new JdbcTemplate(dataSource);
    }

    @Bean(name = "oraclePublicJdbc")
    public JdbcTemplate oraclePublicJdbc() {
        log.info("[migrate-board] Oracle PUBLIC user={} url={}", publicUser, oracleUrl);
        return new JdbcTemplate(buildOracleDataSource(publicUser, publicPassword, "ora-public"));
    }

    @Bean(name = "oracleGosiJdbc")
    public JdbcTemplate oracleGosiJdbc() {
        log.info("[migrate-board] Oracle GOSI user={} url={}", gosiUser, oracleUrl);
        return new JdbcTemplate(buildOracleDataSource(gosiUser, gosiPassword, "ora-gosi"));
    }

    private HikariDataSource buildOracleDataSource(String user, String password, String poolName) {
        HikariConfig cfg = new HikariConfig();
        cfg.setJdbcUrl(oracleUrl);
        cfg.setUsername(user);
        cfg.setPassword(password);
        cfg.setDriverClassName("oracle.jdbc.OracleDriver");
        cfg.setPoolName(poolName);
        cfg.setMaximumPoolSize(2);
        cfg.setMinimumIdle(1);
        cfg.setReadOnly(true);
        return new HikariDataSource(cfg);
    }
}
