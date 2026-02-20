package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.entity.ExamSubjectId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamSubjectRepository extends JpaRepository<ExamSubject, ExamSubjectId> {

    List<ExamSubject> findByExamCdOrderBySortOrder(String examCd);

    List<ExamSubject> findByExamCdAndIsUse(String examCd, String isUse);

    void deleteByExamCd(String examCd);

    // 여러 시험의 과목을 일괄 조회 (N+1 방지)
    @Query("SELECT s FROM ExamSubject s WHERE s.examCd IN :examCds ORDER BY s.examCd, s.sortOrder")
    List<ExamSubject> findByExamCdInOrderBySortOrder(@Param("examCds") List<String> examCds);
}
