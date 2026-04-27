package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.ExamApplicantAns;
import com.hopenvision.exam.entity.ExamApplicantAnsId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamApplicantAnsRepository extends JpaRepository<ExamApplicantAns, ExamApplicantAnsId> {

    List<ExamApplicantAns> findByExamCdAndApplicantNoAndSubjectCd(
            String examCd, String applicantNo, String subjectCd);

    void deleteByExamCdAndApplicantNoAndSubjectCd(
            String examCd, String applicantNo, String subjectCd);
}
