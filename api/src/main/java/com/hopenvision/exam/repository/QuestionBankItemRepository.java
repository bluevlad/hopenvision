package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.QuestionBankItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface QuestionBankItemRepository extends JpaRepository<QuestionBankItem, Long> {

    List<QuestionBankItem> findByGroupIdAndSubjectCdOrderByQuestionNo(Long groupId, String subjectCd);

    List<QuestionBankItem> findByGroupIdOrderByQuestionNo(Long groupId);
}
