package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiRstMst;
import com.hopenvision.admin.entity.GosiRstMstId;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GosiRstMstRepository extends JpaRepository<GosiRstMst, GosiRstMstId> {

    @Query("SELECT r FROM GosiRstMst r WHERE r.gosiCd = :gosiCd " +
           "AND (:gosiType IS NULL OR :gosiType = '' OR r.gosiType = :gosiType) " +
           "AND (:gosiArea IS NULL OR :gosiArea = '' OR r.gosiArea = :gosiArea) " +
           "AND (:keyword IS NULL OR :keyword = '' OR r.userId LIKE %:keyword% OR r.rstNo LIKE %:keyword%) " +
           "ORDER BY r.regDt DESC")
    Page<GosiRstMst> search(
            @Param("gosiCd") String gosiCd,
            @Param("gosiType") String gosiType,
            @Param("gosiArea") String gosiArea,
            @Param("keyword") String keyword,
            Pageable pageable);

    @Query(value = "SELECT " +
            "CASE WHEN FLOOR(total_score / 10) >= 10 THEN '90~100' " +
            "     ELSE CONCAT(CAST(FLOOR(total_score / 10) * 10 AS INTEGER), '~', CAST(FLOOR(total_score / 10) * 10 + 9 AS INTEGER)) " +
            "END AS range, " +
            "COUNT(*) AS count " +
            "FROM gosi_rst_mst " +
            "WHERE gosi_cd = :gosiCd " +
            "AND (:gosiType IS NULL OR :gosiType = '' OR gosi_type = :gosiType) " +
            "AND (:gosiArea IS NULL OR :gosiArea = '' OR gosi_area = :gosiArea) " +
            "GROUP BY CASE WHEN FLOOR(total_score / 10) >= 10 THEN '90~100' " +
            "     ELSE CONCAT(CAST(FLOOR(total_score / 10) * 10 AS INTEGER), '~', CAST(FLOOR(total_score / 10) * 10 + 9 AS INTEGER)) " +
            "END " +
            "ORDER BY MIN(total_score)", nativeQuery = true)
    List<Object[]> findScoreDistribution(
            @Param("gosiCd") String gosiCd,
            @Param("gosiType") String gosiType,
            @Param("gosiArea") String gosiArea);

    @Query(value = "SELECT m.gosi_year, " +
            "AVG(r.total_score) AS avg_score, " +
            "CASE WHEN COUNT(*) > 0 THEN " +
            "  CAST(SUM(CASE WHEN r.pass_yn = 'Y' THEN 1 ELSE 0 END) AS DECIMAL) * 100.0 / COUNT(*) " +
            "ELSE 0 END AS pass_rate, " +
            "COUNT(*) AS total_cnt " +
            "FROM gosi_rst_mst r " +
            "JOIN gosi_mst m ON r.gosi_cd = m.gosi_cd " +
            "WHERE (:gosiType IS NULL OR :gosiType = '' OR r.gosi_type = :gosiType) " +
            "GROUP BY m.gosi_year " +
            "ORDER BY m.gosi_year", nativeQuery = true)
    List<Object[]> findYearlyTrend(@Param("gosiType") String gosiType);
}
