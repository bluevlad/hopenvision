package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.ExamApplicant;
import com.hopenvision.exam.entity.ExamApplicantId;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ExamApplicantRepository extends JpaRepository<ExamApplicant, ExamApplicantId> {

    @Query("SELECT a FROM ExamApplicant a WHERE a.examCd = :examCd " +
           "AND (:keyword IS NULL OR :keyword = '' OR a.userNm LIKE %:keyword% OR a.applicantNo LIKE %:keyword%) " +
           "ORDER BY a.applicantNo")
    Page<ExamApplicant> searchByExamCd(
            @Param("examCd") String examCd,
            @Param("keyword") String keyword,
            Pageable pageable
    );

    long countByExamCd(String examCd);

    boolean existsByExamCdAndApplicantNo(String examCd, String applicantNo);

    java.util.List<ExamApplicant> findByExamCd(String examCd);

    @Query("SELECT COUNT(a) FROM ExamApplicant a WHERE a.examCd = :examCd AND a.avgScore >= :passScore")
    long countPassedByExamCd(@Param("examCd") String examCd, @Param("passScore") java.math.BigDecimal passScore);

    @Query("SELECT AVG(a.avgScore) FROM ExamApplicant a WHERE a.examCd = :examCd AND a.totalScore IS NOT NULL")
    java.math.BigDecimal avgScoreByExamCd(@Param("examCd") String examCd);

    @Query("SELECT MAX(a.avgScore) FROM ExamApplicant a WHERE a.examCd = :examCd AND a.totalScore IS NOT NULL")
    java.math.BigDecimal maxScoreByExamCd(@Param("examCd") String examCd);

    @Query("SELECT MIN(a.avgScore) FROM ExamApplicant a WHERE a.examCd = :examCd AND a.totalScore IS NOT NULL")
    java.math.BigDecimal minScoreByExamCd(@Param("examCd") String examCd);

    @Query("SELECT " +
           "SUM(CASE WHEN a.avgScore >= 90 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN a.avgScore >= 80 AND a.avgScore < 90 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN a.avgScore >= 70 AND a.avgScore < 80 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN a.avgScore >= 60 AND a.avgScore < 70 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN a.avgScore >= 50 AND a.avgScore < 60 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN a.avgScore >= 40 AND a.avgScore < 50 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN a.avgScore >= 30 AND a.avgScore < 40 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN a.avgScore >= 20 AND a.avgScore < 30 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN a.avgScore >= 10 AND a.avgScore < 20 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN a.avgScore < 10 THEN 1 ELSE 0 END) " +
           "FROM ExamApplicant a WHERE a.examCd = :examCd AND a.avgScore IS NOT NULL")
    java.util.List<Object[]> getScoreDistribution(@Param("examCd") String examCd);

    // 여러 시험의 채점완료 수 일괄 조회
    @Query("SELECT a.examCd, COUNT(a) FROM ExamApplicant a WHERE a.examCd IN :examCds AND a.scoreStatus = 'Y' GROUP BY a.examCd")
    java.util.List<Object[]> countScoredByExamCdIn(@Param("examCds") java.util.List<String> examCds);

    // 직렬별 통계: [applyArea, count, avgScore, maxScore, minScore, passedCount]
    @Query("SELECT a.applyArea, COUNT(a), AVG(a.totalScore), MAX(a.totalScore), MIN(a.totalScore), " +
           "SUM(CASE WHEN a.passYn = 'Y' THEN 1 ELSE 0 END) " +
           "FROM ExamApplicant a WHERE a.examCd = :examCd AND a.applyArea IS NOT NULL AND a.totalScore IS NOT NULL " +
           "GROUP BY a.applyArea ORDER BY a.applyArea")
    java.util.List<Object[]> getAreaStatistics(@Param("examCd") String examCd);
}
