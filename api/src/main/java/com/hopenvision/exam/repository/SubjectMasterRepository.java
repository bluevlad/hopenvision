package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.SubjectMaster;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SubjectMasterRepository extends JpaRepository<SubjectMaster, String> {

    java.util.Optional<SubjectMaster> findBySubjectNm(String subjectNm);

    List<SubjectMaster> findByIsUseOrderBySortOrder(String isUse);

    List<SubjectMaster> findByCategoryAndIsUseOrderBySortOrder(String category, String isUse);

    List<SubjectMaster> findByIsUseOrderByCategoryAscSortOrderAsc(String isUse);

    List<SubjectMaster> findByParentSubjectCdAndIsUseOrderBySortOrder(String parentSubjectCd, String isUse);

    List<SubjectMaster> findByParentSubjectCdOrderBySortOrder(String parentSubjectCd);

    List<SubjectMaster> findByParentSubjectCdIsNullOrderBySortOrder();

    List<SubjectMaster> findBySubjectDepthOrderBySortOrder(Integer subjectDepth);

    @Query("SELECT s FROM SubjectMaster s WHERE " +
           "(:keyword IS NULL OR :keyword = '' OR s.subjectNm LIKE %:keyword% OR s.subjectCd LIKE %:keyword%) " +
           "AND (:category IS NULL OR :category = '' OR s.category = :category) " +
           "AND (:isUse IS NULL OR :isUse = '' OR s.isUse = :isUse) " +
           "ORDER BY s.sortOrder ASC, s.subjectCd ASC")
    Page<SubjectMaster> searchSubjects(
            @Param("keyword") String keyword,
            @Param("category") String category,
            @Param("isUse") String isUse,
            Pageable pageable
    );

    @Query("SELECT COUNT(es) FROM ExamSubject es WHERE es.subjectCd = :subjectCd")
    long countExamsBySubjectCd(@Param("subjectCd") String subjectCd);
}
