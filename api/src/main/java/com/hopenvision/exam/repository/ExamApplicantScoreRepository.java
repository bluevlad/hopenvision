package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.ExamApplicantScore;
import com.hopenvision.exam.entity.ExamApplicantScoreId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamApplicantScoreRepository extends JpaRepository<ExamApplicantScore, ExamApplicantScoreId> {

    List<ExamApplicantScore> findByExamCdAndApplicantNo(String examCd, String applicantNo);
}
