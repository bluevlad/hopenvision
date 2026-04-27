package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.ExamApplicantScore;
import com.hopenvision.exam.entity.ExamApplicantScoreId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamApplicantScoreRepository extends JpaRepository<ExamApplicantScore, ExamApplicantScoreId> {

    List<ExamApplicantScore> findByExamCdAndApplicantNo(String examCd, String applicantNo);

    // 과목별 통계 일괄 조회: [subjectCd, count, avg, max, min]
    @org.springframework.data.jpa.repository.Query(
        "SELECT s.subjectCd, COUNT(s), AVG(s.rawScore), MAX(s.rawScore), MIN(s.rawScore) " +
        "FROM ExamApplicantScore s WHERE s.examCd = :examCd GROUP BY s.subjectCd")
    List<Object[]> getSubjectStatsBatch(@org.springframework.data.repository.query.Param("examCd") String examCd);
}
