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
}
