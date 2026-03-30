package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.QuestionBankItem;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface QuestionBankItemRepository extends JpaRepository<QuestionBankItem, Long> {

    List<QuestionBankItem> findByGroupIdOrderByQuestionNo(Long groupId);

    List<QuestionBankItem> findByGroupIdAndSubjectCdOrderByQuestionNo(Long groupId, String subjectCd);

    @Query("SELECT i FROM QuestionBankItem i WHERE " +
            "(:groupId IS NULL OR i.groupId = :groupId) " +
            "AND (:subjectCd IS NULL OR i.subjectCd = :subjectCd) " +
            "AND (:difficulty IS NULL OR i.difficulty = :difficulty) " +
            "AND (:keyword IS NULL OR i.questionTitle LIKE CONCAT('%', CAST(:keyword AS string), '%') " +
            "     OR i.questionText LIKE CONCAT('%', CAST(:keyword AS string), '%') " +
            "     OR i.tags LIKE CONCAT('%', CAST(:keyword AS string), '%')) " +
            "AND (:isUse IS NULL OR i.isUse = :isUse) " +
            "ORDER BY i.groupId, i.questionNo")
    Page<QuestionBankItem> searchItems(
            @Param("groupId") Long groupId,
            @Param("subjectCd") String subjectCd,
            @Param("difficulty") String difficulty,
            @Param("keyword") String keyword,
            @Param("isUse") String isUse,
            Pageable pageable);

    long countByGroupId(Long groupId);
}
