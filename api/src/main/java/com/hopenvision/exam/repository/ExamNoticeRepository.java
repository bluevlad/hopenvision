package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.ExamNotice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamNoticeRepository extends JpaRepository<ExamNotice, Long> {

    List<ExamNotice> findByExamCdAndIsUseOrderByIsPinnedDescRegDtDesc(String examCd, String isUse);

    List<ExamNotice> findByExamCdOrderByIsPinnedDescRegDtDesc(String examCd);
}
