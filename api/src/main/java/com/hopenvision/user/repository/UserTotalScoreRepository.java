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

    @Query("SELECT uts FROM UserTotalScore uts WHERE uts.examCd = :examCd ORDER BY uts.totalScore DESC")
    List<UserTotalScore> findByExamCdOrderByTotalScoreDesc(@Param("examCd") String examCd);

    @Query("SELECT uts FROM UserTotalScore uts WHERE uts.examCd = :examCd AND uts.batchYn = 'N'")
    List<UserTotalScore> findUnprocessedByExamCd(@Param("examCd") String examCd);

    @Query("SELECT COUNT(uts) FROM UserTotalScore uts WHERE uts.examCd = :examCd")
    Long countByExamCd(@Param("examCd") String examCd);

    @Query("SELECT COUNT(uts) FROM UserTotalScore uts WHERE uts.examCd = :examCd AND uts.totalScore > :score")
    Long countByExamCdAndScoreGreaterThan(@Param("examCd") String examCd, @Param("score") java.math.BigDecimal score);
}
