package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.QuestionBankGroup;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface QuestionBankGroupRepository extends JpaRepository<QuestionBankGroup, Long> {

    Optional<QuestionBankGroup> findByGroupCd(String groupCd);

    boolean existsByGroupCd(String groupCd);

    @Query("SELECT g FROM QuestionBankGroup g WHERE " +
            "(:category IS NULL OR g.category = :category) " +
            "AND (:examYear IS NULL OR g.examYear = :examYear) " +
            "AND (:keyword IS NULL OR g.groupNm LIKE CONCAT('%', :keyword, '%') OR g.groupCd LIKE CONCAT('%', :keyword, '%')) " +
            "AND (:isUse IS NULL OR g.isUse = :isUse) " +
            "ORDER BY g.regDt DESC")
    Page<QuestionBankGroup> searchGroups(
            @Param("keyword") String keyword,
            @Param("category") String category,
            @Param("examYear") String examYear,
            @Param("isUse") String isUse,
            Pageable pageable);
}
