package com.hopenvision.user.repository;

import com.hopenvision.user.entity.UserAnswer;
import com.hopenvision.user.entity.UserAnswerId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
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

    @Modifying
    @Query("DELETE FROM UserAnswer ua WHERE ua.id.userId = :userId AND ua.id.examCd = :examCd")
    void deleteByUserIdAndExamCd(@Param("userId") String userId, @Param("examCd") String examCd);

    boolean existsByIdUserIdAndIdExamCd(String userId, String examCd);

    // 사용자가 제출한 시험 코드 목록 일괄 조회 (N+1 방지)
    @Query("SELECT DISTINCT ua.id.examCd FROM UserAnswer ua WHERE ua.id.userId = :userId AND ua.id.examCd IN :examCds")
    List<String> findSubmittedExamCds(@Param("userId") String userId, @Param("examCds") List<String> examCds);

    // 문항별 정답률 집계: [subjectCd, questionNo, correctCount, totalCount]
    @Query("SELECT ua.id.subjectCd, ua.id.questionNo, " +
           "SUM(CASE WHEN ua.isCorrect = 'Y' THEN 1 ELSE 0 END), COUNT(ua) " +
           "FROM UserAnswer ua WHERE ua.id.examCd = :examCd " +
           "GROUP BY ua.id.subjectCd, ua.id.questionNo " +
           "ORDER BY ua.id.subjectCd, ua.id.questionNo")
    List<Object[]> getQuestionCorrectRates(@Param("examCd") String examCd);

    // 문항별 선택지 분포: [subjectCd, questionNo, userAns, count]
    @Query("SELECT ua.id.subjectCd, ua.id.questionNo, ua.userAns, COUNT(ua) " +
           "FROM UserAnswer ua WHERE ua.id.examCd = :examCd " +
           "GROUP BY ua.id.subjectCd, ua.id.questionNo, ua.userAns " +
           "ORDER BY ua.id.subjectCd, ua.id.questionNo, ua.userAns")
    List<Object[]> getChoiceDistributions(@Param("examCd") String examCd);

    // 특정 과목 문항별 정답 여부 (변별력 계산용): [userId, questionNo, isCorrect]
    @Query("SELECT ua.id.userId, ua.id.questionNo, ua.isCorrect " +
           "FROM UserAnswer ua WHERE ua.id.examCd = :examCd AND ua.id.subjectCd = :subjectCd " +
           "ORDER BY ua.id.userId, ua.id.questionNo")
    List<Object[]> getAnswersByExamAndSubject(@Param("examCd") String examCd, @Param("subjectCd") String subjectCd);
}
