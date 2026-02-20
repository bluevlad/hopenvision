package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.ExamAnswerKey;
import com.hopenvision.exam.entity.ExamAnswerKeyId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamAnswerKeyRepository extends JpaRepository<ExamAnswerKey, ExamAnswerKeyId> {

    List<ExamAnswerKey> findByExamCdAndSubjectCdOrderByQuestionNo(String examCd, String subjectCd);

    List<ExamAnswerKey> findByExamCdOrderBySubjectCdAscQuestionNoAsc(String examCd);

    void deleteByExamCdAndSubjectCd(String examCd, String subjectCd);

    void deleteByExamCd(String examCd);

    long countByExamCdAndSubjectCd(String examCd, String subjectCd);

    @Query("SELECT ak.subjectCd, COUNT(ak) FROM ExamAnswerKey ak WHERE ak.examCd = :examCd GROUP BY ak.subjectCd")
    List<Object[]> countByExamCdGroupBySubject(@Param("examCd") String examCd);
}
