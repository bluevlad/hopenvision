package com.hopenvision.user.repository;

import com.hopenvision.user.entity.UserTotalScore;
import com.hopenvision.user.entity.UserTotalScoreId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserTotalScoreRepository extends JpaRepository<UserTotalScore, UserTotalScoreId> {

    Optional<UserTotalScore> findByUserIdAndExamCd(String userId, String examCd);

    boolean existsByUserIdAndExamCd(String userId, String examCd);

    @Query("SELECT uts FROM UserTotalScore uts WHERE uts.examCd = :examCd ORDER BY uts.totalScore DESC")
    List<UserTotalScore> findByExamCdOrderByTotalScoreDesc(@Param("examCd") String examCd);

    @Query("SELECT uts FROM UserTotalScore uts WHERE uts.examCd = :examCd AND uts.batchYn = 'N'")
    List<UserTotalScore> findUnprocessedByExamCd(@Param("examCd") String examCd);

    @Query("SELECT COUNT(uts) FROM UserTotalScore uts WHERE uts.examCd = :examCd")
    Long countByExamCd(@Param("examCd") String examCd);

    @Query("SELECT COUNT(uts) FROM UserTotalScore uts WHERE uts.examCd = :examCd AND uts.totalScore > :score")
    Long countByExamCdAndScoreGreaterThan(@Param("examCd") String examCd, @Param("score") java.math.BigDecimal score);

    @Query("SELECT AVG(uts.totalScore) FROM UserTotalScore uts WHERE uts.examCd = :examCd")
    java.math.BigDecimal avgTotalScoreByExamCd(@Param("examCd") String examCd);

    @Query("SELECT MAX(uts.totalScore) FROM UserTotalScore uts WHERE uts.examCd = :examCd")
    java.math.BigDecimal maxTotalScoreByExamCd(@Param("examCd") String examCd);

    @Query("SELECT MIN(uts.totalScore) FROM UserTotalScore uts WHERE uts.examCd = :examCd")
    java.math.BigDecimal minTotalScoreByExamCd(@Param("examCd") String examCd);

    @Query("SELECT COUNT(uts) FROM UserTotalScore uts WHERE uts.examCd = :examCd AND uts.passYn = 'Y'")
    Long countPassedByExamCd(@Param("examCd") String examCd);

    @Query("SELECT COUNT(uts) FROM UserTotalScore uts WHERE uts.examCd = :examCd AND uts.totalScore <= :score")
    Long countByExamCdAndScoreLessThanOrEqual(@Param("examCd") String examCd, @Param("score") java.math.BigDecimal score);

    @Query("SELECT uts FROM UserTotalScore uts WHERE uts.userId = :userId ORDER BY uts.regDt DESC")
    List<UserTotalScore> findByUserIdOrderByRegDtDesc(@Param("userId") String userId);

    // 점수 분포 계산 (DB에서 직접 집계)
    @Query("SELECT " +
           "SUM(CASE WHEN uts.totalScore >= 90 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN uts.totalScore >= 80 AND uts.totalScore < 90 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN uts.totalScore >= 70 AND uts.totalScore < 80 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN uts.totalScore >= 60 AND uts.totalScore < 70 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN uts.totalScore >= 50 AND uts.totalScore < 60 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN uts.totalScore >= 40 AND uts.totalScore < 50 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN uts.totalScore >= 30 AND uts.totalScore < 40 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN uts.totalScore >= 20 AND uts.totalScore < 30 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN uts.totalScore >= 10 AND uts.totalScore < 20 THEN 1 ELSE 0 END), " +
           "SUM(CASE WHEN uts.totalScore < 10 THEN 1 ELSE 0 END) " +
           "FROM UserTotalScore uts WHERE uts.examCd = :examCd AND uts.totalScore IS NOT NULL")
    Object[] getScoreDistribution(@Param("examCd") String examCd);
}
