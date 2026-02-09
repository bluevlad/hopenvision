package com.hopenvision.exam.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "exam_question")
@IdClass(ExamQuestionId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamQuestion {

    @Id
    @Column(name = "exam_cd", length = 50)
    private String examCd;

    @Id
    @Column(name = "subject_cd", length = 20)
    private String subjectCd;

    @Id
    @Column(name = "question_no")
    private Integer questionNo;

    @Column(name = "question_text", columnDefinition = "TEXT")
    private String questionText;

    @Column(name = "context_text", columnDefinition = "TEXT")
    private String contextText;

    @Column(name = "choice_1", length = 1000)
    private String choice1;

    @Column(name = "choice_2", length = 1000)
    private String choice2;

    @Column(name = "choice_3", length = 1000)
    private String choice3;

    @Column(name = "choice_4", length = 1000)
    private String choice4;

    @Column(name = "choice_5", length = 1000)
    private String choice5;

    @Column(name = "image_file", length = 200)
    private String imageFile;

    @Column(name = "category", length = 100)
    private String category;

    @Column(name = "difficulty", length = 10)
    private String difficulty;

    @Column(name = "title", length = 500)
    private String title;

    @Column(name = "explanation", columnDefinition = "TEXT")
    private String explanation;

    @Column(name = "correction_note", columnDefinition = "TEXT")
    private String correctionNote;

    @CreationTimestamp
    @Column(name = "reg_dt", updatable = false)
    private LocalDateTime regDt;

    @UpdateTimestamp
    @Column(name = "upd_dt")
    private LocalDateTime updDt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns({
        @JoinColumn(name = "exam_cd", referencedColumnName = "exam_cd", insertable = false, updatable = false),
        @JoinColumn(name = "subject_cd", referencedColumnName = "subject_cd", insertable = false, updatable = false)
    })
    private ExamSubject subject;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumns({
        @JoinColumn(name = "exam_cd", referencedColumnName = "exam_cd", insertable = false, updatable = false),
        @JoinColumn(name = "subject_cd", referencedColumnName = "subject_cd", insertable = false, updatable = false),
        @JoinColumn(name = "question_no", referencedColumnName = "question_no", insertable = false, updatable = false)
    })
    private ExamAnswerKey answerKey;
}
