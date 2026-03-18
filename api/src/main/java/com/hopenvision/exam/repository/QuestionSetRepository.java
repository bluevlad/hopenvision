package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.QuestionSet;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface QuestionSetRepository extends JpaRepository<QuestionSet, Long> {

    Optional<QuestionSet> findBySetCd(String setCd);

    boolean existsBySetCd(String setCd);

    @Query("SELECT qs FROM QuestionSet qs WHERE " +
           "(:keyword IS NULL OR :keyword = '' OR qs.setNm LIKE %:keyword% OR qs.setCd LIKE %:keyword%) " +
           "AND (:category IS NULL OR :category = '' OR qs.category = :category) " +
           "AND (:isUse IS NULL OR :isUse = '' OR qs.isUse = :isUse) " +
           "ORDER BY qs.regDt DESC")
    Page<QuestionSet> searchSets(
            @Param("keyword") String keyword,
            @Param("category") String category,
            @Param("isUse") String isUse,
            Pageable pageable
    );
}
