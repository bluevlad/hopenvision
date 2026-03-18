package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.QuestionSetItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionSetItemRepository extends JpaRepository<QuestionSetItem, Long> {

    List<QuestionSetItem> findBySetIdOrderBySortOrder(Long setId);

    void deleteBySetId(Long setId);
}
