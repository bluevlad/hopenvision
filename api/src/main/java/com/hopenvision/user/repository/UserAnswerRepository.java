package com.hopenvision.user.repository;

import com.hopenvision.user.entity.UserAnswer;
import com.hopenvision.user.entity.UserAnswerId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserAnswerRepository extends JpaRepository<UserAnswer, UserAnswerId> {

    @Query("SELECT ua FROM UserAnswer ua WHERE ua.id.userId = :userId AND ua.id.examCd = :examCd ORDER BY ua.id.subjectCd, ua.id.questionNo")
    List<UserAnswer> findByUserIdAndExamCd(@Param("userId") String userId, @Param("examCd") String examCd);

    @Query("SELECT ua FROM UserAnswer ua WHERE ua.id.userId = :userId AND ua.id.examCd = :examCd AND ua.id.subjectCd = :subjectCd ORDER BY ua.id.questionNo")
    List<UserAnswer> findByUserIdAndExamCdAndSubjectCd(@Param("userId") String userId, @Param("examCd") String examCd, @Param("subjectCd") String subjectCd);

    @Query("DELETE FROM UserAnswer ua WHERE ua.id.userId = :userId AND ua.id.examCd = :examCd")
    void deleteByUserIdAndExamCd(@Param("userId") String userId, @Param("examCd") String examCd);

    boolean existsByIdUserIdAndIdExamCd(String userId, String examCd);
}
