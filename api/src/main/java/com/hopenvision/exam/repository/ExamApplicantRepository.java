package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.ExamApplicant;
import com.hopenvision.exam.entity.ExamApplicantId;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ExamApplicantRepository extends JpaRepository<ExamApplicant, ExamApplicantId> {

    @Query("SELECT a FROM ExamApplicant a WHERE a.examCd = :examCd " +
           "AND (:keyword IS NULL OR :keyword = '' OR a.userNm LIKE %:keyword% OR a.applicantNo LIKE %:keyword%) " +
           "ORDER BY a.applicantNo")
    Page<ExamApplicant> searchByExamCd(
            @Param("examCd") String examCd,
            @Param("keyword") String keyword,
            Pageable pageable
    );

    long countByExamCd(String examCd);

    boolean existsByExamCdAndApplicantNo(String examCd, String applicantNo);
}
