package com.hopenvision.exam.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "exam_applicant_ans")
@IdClass(ExamApplicantAnsId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamApplicantAns {

    @Id
    @Column(name = "exam_cd", length = 50)
    private String examCd;

    @Id
    @Column(name = "applicant_no", length = 20)
    private String applicantNo;

    @Id
    @Column(name = "subject_cd", length = 20)
    private String subjectCd;

    @Id
    @Column(name = "question_no")
    private Integer questionNo;

    @Column(name = "user_ans", length = 10)
    private String userAns;

    @Column(name = "is_correct", length = 1)
    private String isCorrect;

    @CreationTimestamp
    @Column(name = "reg_dt", updatable = false)
    private LocalDateTime regDt;
}
