package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.Exam;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamRepository extends JpaRepository<Exam, String> {

    // 시험 유형별 조회
    List<Exam> findByExamType(String examType);

    // 시험 년도별 조회
    List<Exam> findByExamYear(String examYear);

    // 사용 여부로 조회
    List<Exam> findByIsUse(String isUse);

    // 사용 여부로 조회 (최신순 정렬)
    List<Exam> findByIsUseOrderByRegDtDesc(String isUse);

    // 검색 (시험명, 시험코드)
    @Query("SELECT e FROM Exam e WHERE " +
           "(:keyword IS NULL OR :keyword = '' OR e.examNm LIKE %:keyword% OR e.examCd LIKE %:keyword%) " +
           "AND (:examType IS NULL OR :examType = '' OR e.examType = :examType) " +
           "AND (:examYear IS NULL OR :examYear = '' OR e.examYear = :examYear) " +
           "AND (:isUse IS NULL OR :isUse = '' OR e.isUse = :isUse) " +
           "ORDER BY e.regDt DESC")
    Page<Exam> searchExams(
            @Param("keyword") String keyword,
            @Param("examType") String examType,
            @Param("examYear") String examYear,
            @Param("isUse") String isUse,
            Pageable pageable
    );

    // 시험별 과목 수 조회
    @Query("SELECT COUNT(s) FROM ExamSubject s WHERE s.examCd = :examCd")
    long countSubjectsByExamCd(@Param("examCd") String examCd);

    // 시험별 응시자 수 조회
    @Query("SELECT COUNT(a) FROM ExamApplicant a WHERE a.examCd = :examCd")
    long countApplicantsByExamCd(@Param("examCd") String examCd);

    // 시험 목록 + 과목/응시자 카운트 일괄 조회 (N+1 방지)
    @Query("SELECT e.examCd, " +
           "(SELECT COUNT(s) FROM ExamSubject s WHERE s.examCd = e.examCd), " +
           "(SELECT COUNT(a) FROM ExamApplicant a WHERE a.examCd = e.examCd) " +
           "FROM Exam e WHERE e.examCd IN :examCds")
    List<Object[]> findExamCountsByExamCds(@Param("examCds") List<String> examCds);
}
