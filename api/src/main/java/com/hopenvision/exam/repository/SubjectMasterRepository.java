package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.SubjectMaster;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface SubjectMasterRepository extends JpaRepository<SubjectMaster, String> {

    List<SubjectMaster> findByCategoryAndIsUseOrderBySortOrder(String category, String isUse);

    List<SubjectMaster> findByIsUseOrderByCategoryAscSortOrderAsc(String isUse);

    List<SubjectMaster> findByParentSubjectCdAndIsUseOrderBySortOrder(String parentSubjectCd, String isUse);

    @Query("SELECT s FROM SubjectMaster s WHERE s.isUse = :isUse " +
            "AND (:category IS NULL OR s.category = :category) " +
            "AND (:keyword IS NULL OR s.subjectNm LIKE CONCAT('%', :keyword, '%') OR s.subjectCd LIKE CONCAT('%', :keyword, '%')) " +
            "ORDER BY s.category, s.sortOrder")
    Page<SubjectMaster> searchSubjects(
            @Param("keyword") String keyword,
            @Param("category") String category,
            @Param("isUse") String isUse,
            Pageable pageable);

    @Query("SELECT s FROM SubjectMaster s WHERE " +
            "(:category IS NULL OR s.category = :category) " +
            "AND (:keyword IS NULL OR s.subjectNm LIKE CONCAT('%', :keyword, '%') OR s.subjectCd LIKE CONCAT('%', :keyword, '%')) " +
            "ORDER BY s.category, s.sortOrder")
    Page<SubjectMaster> searchSubjectsAll(
            @Param("keyword") String keyword,
            @Param("category") String category,
            Pageable pageable);
}
