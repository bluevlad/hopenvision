package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.QuestionSetItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionSetItemRepository extends JpaRepository<QuestionSetItem, Long> {

    List<QuestionSetItem> findBySetIdOrderBySortOrder(Long setId);

    List<QuestionSetItem> findBySetIdAndSubjectCdOrderBySortOrder(Long setId, String subjectCd);

    void deleteBySetId(Long setId);

    @Query("SELECT DISTINCT i.subjectCd FROM QuestionSetItem i WHERE i.setId = :setId ORDER BY i.subjectCd")
    List<String> findDistinctSubjectCdsBySetId(@Param("setId") Long setId);

    @Query("SELECT i.subjectCd, COUNT(i) FROM QuestionSetItem i WHERE i.setId = :setId GROUP BY i.subjectCd ORDER BY i.subjectCd")
    List<Object[]> countItemsBySubjectCd(@Param("setId") Long setId);
}
