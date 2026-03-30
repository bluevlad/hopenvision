package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.QuestionBankGroup;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface QuestionBankGroupRepository extends JpaRepository<QuestionBankGroup, Long> {

    Optional<QuestionBankGroup> findByGroupCd(String groupCd);

    boolean existsByGroupCd(String groupCd);

    @Query("SELECT g FROM QuestionBankGroup g WHERE " +
           "(:keyword IS NULL OR :keyword = '' OR g.groupNm LIKE %:keyword% OR g.groupCd LIKE %:keyword%) " +
           "AND (:category IS NULL OR :category = '' OR g.category = :category) " +
           "AND (:examYear IS NULL OR :examYear = '' OR g.examYear = :examYear) " +
           "AND (:source IS NULL OR :source = '' OR g.source = :source) " +
           "AND (:isUse IS NULL OR :isUse = '' OR g.isUse = :isUse) " +
           "ORDER BY g.regDt DESC")
    Page<QuestionBankGroup> searchGroups(
            @Param("keyword") String keyword,
            @Param("category") String category,
            @Param("examYear") String examYear,
            @Param("source") String source,
            @Param("isUse") String isUse,
            Pageable pageable
    );

    @Query("SELECT g.groupId, COUNT(i) FROM QuestionBankGroup g LEFT JOIN g.items i " +
           "WHERE g.groupId IN :groupIds GROUP BY g.groupId")
    List<Object[]> countItemsByGroupIds(@Param("groupIds") List<Long> groupIds);
}
