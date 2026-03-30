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

    // 직렬별 통계: [applyArea, count, avgScore, maxScore, minScore, passedCount]
    @Query("SELECT a.applyArea, COUNT(a), AVG(a.totalScore), MAX(a.totalScore), MIN(a.totalScore), " +
           "SUM(CASE WHEN a.passYn = 'Y' THEN 1 ELSE 0 END) " +
           "FROM ExamApplicant a WHERE a.examCd = :examCd AND a.applyArea IS NOT NULL AND a.totalScore IS NOT NULL " +
           "GROUP BY a.applyArea ORDER BY a.applyArea")
    java.util.List<Object[]> getAreaStatistics(@Param("examCd") String examCd);
}
