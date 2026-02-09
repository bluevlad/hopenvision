package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.ExamQuestion;
import com.hopenvision.exam.entity.ExamQuestionId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamQuestionRepository extends JpaRepository<ExamQuestion, ExamQuestionId> {

    List<ExamQuestion> findByExamCdAndSubjectCdOrderByQuestionNo(String examCd, String subjectCd);

    List<ExamQuestion> findByExamCdOrderBySubjectCdAscQuestionNoAsc(String examCd);

    void deleteByExamCdAndSubjectCd(String examCd, String subjectCd);

    void deleteByExamCd(String examCd);

    long countByExamCdAndSubjectCd(String examCd, String subjectCd);

    List<ExamQuestion> findByCategory(String category);

    List<ExamQuestion> findByDifficulty(String difficulty);

    List<ExamQuestion> findByCategoryAndDifficulty(String category, String difficulty);
}
