package com.hopenvision.user.repository;

import com.hopenvision.user.entity.UserScore;
import com.hopenvision.user.entity.UserScoreId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserScoreRepository extends JpaRepository<UserScore, UserScoreId> {

    @Query("SELECT us FROM UserScore us WHERE us.id.userId = :userId AND us.id.examCd = :examCd ORDER BY us.id.subjectCd")
    List<UserScore> findByUserIdAndExamCd(@Param("userId") String userId, @Param("examCd") String examCd);

    @Query("SELECT us FROM UserScore us WHERE us.id.examCd = :examCd AND us.batchYn = 'N'")
    List<UserScore> findUnprocessedByExamCd(@Param("examCd") String examCd);

    @Query("SELECT COUNT(us) FROM UserScore us WHERE us.id.examCd = :examCd AND us.id.subjectCd = :subjectCd")
    Long countByExamCdAndSubjectCd(@Param("examCd") String examCd, @Param("subjectCd") String subjectCd);

    @Query("SELECT COUNT(DISTINCT us.id.userId) FROM UserScore us WHERE us.id.examCd = :examCd")
    Long countDistinctUsersByExamCd(@Param("examCd") String examCd);

    @Query("SELECT us FROM UserScore us WHERE us.id.examCd = :examCd AND us.id.subjectCd = :subjectCd ORDER BY us.rawScore DESC")
    List<UserScore> findByExamCdAndSubjectCdOrderByScore(@Param("examCd") String examCd, @Param("subjectCd") String subjectCd);

    @Query("SELECT AVG(us.rawScore) FROM UserScore us WHERE us.id.examCd = :examCd AND us.id.subjectCd = :subjectCd")
    java.math.BigDecimal avgScoreByExamCdAndSubjectCd(@Param("examCd") String examCd, @Param("subjectCd") String subjectCd);

    @Query("SELECT MAX(us.rawScore) FROM UserScore us WHERE us.id.examCd = :examCd AND us.id.subjectCd = :subjectCd")
    java.math.BigDecimal maxScoreByExamCdAndSubjectCd(@Param("examCd") String examCd, @Param("subjectCd") String subjectCd);

    @Query("SELECT MIN(us.rawScore) FROM UserScore us WHERE us.id.examCd = :examCd AND us.id.subjectCd = :subjectCd")
    java.math.BigDecimal minScoreByExamCdAndSubjectCd(@Param("examCd") String examCd, @Param("subjectCd") String subjectCd);

    @Query("SELECT COUNT(us) FROM UserScore us WHERE us.id.examCd = :examCd AND us.id.subjectCd = :subjectCd AND us.rawScore > :score")
    Long countByExamCdAndSubjectCdAndScoreGreaterThan(@Param("examCd") String examCd, @Param("subjectCd") String subjectCd, @Param("score") java.math.BigDecimal score);

    // 과목별 통계 일괄 조회 (N+1 방지)
    @Query("SELECT us.id.subjectCd, COUNT(us), AVG(us.rawScore), MAX(us.rawScore), MIN(us.rawScore) " +
           "FROM UserScore us WHERE us.id.examCd = :examCd GROUP BY us.id.subjectCd")
    List<Object[]> getSubjectStatsBatch(@Param("examCd") String examCd);

    // 과목별 통계 + 특정 사용자 점수보다 높은 수 일괄 조회 (ScoreAnalysis N+1 방지)
    @Query("SELECT us.id.subjectCd, COUNT(us), AVG(us.rawScore), MAX(us.rawScore), MIN(us.rawScore), " +
           "SUM(CASE WHEN us.rawScore > (SELECT us2.rawScore FROM UserScore us2 WHERE us2.id.userId = :userId AND us2.id.examCd = :examCd AND us2.id.subjectCd = us.id.subjectCd) THEN 1 ELSE 0 END) " +
           "FROM UserScore us WHERE us.id.examCd = :examCd GROUP BY us.id.subjectCd")
    List<Object[]> getSubjectStatsWithRanking(@Param("examCd") String examCd, @Param("userId") String userId);
}
