package com.hopenvision.exam.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "question_bank_item")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionBankItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "item_id")
    private Long itemId;

    @Column(name = "group_id", nullable = false, insertable = false, updatable = false)
    private Long groupId;

    @Column(name = "subject_cd", length = 20, nullable = false)
    private String subjectCd;

    @Column(name = "question_no")
    private Integer questionNo;

    @Column(name = "question_title", length = 500)
    private String questionTitle;

    @Column(name = "question_text", columnDefinition = "TEXT")
    private String questionText;

    @Column(name = "context_text", columnDefinition = "TEXT")
    private String contextText;

    @Column(name = "choice1", length = 1000)
    private String choice1;

    @Column(name = "choice2", length = 1000)
    private String choice2;

    @Column(name = "choice3", length = 1000)
    private String choice3;

    @Column(name = "choice4", length = 1000)
    private String choice4;

    @Column(name = "choice5", length = 1000)
    private String choice5;

    @Column(name = "correct_ans", length = 100, nullable = false)
    private String correctAns;

    @Column(name = "is_multi_ans", length = 1)
    @Builder.Default
    private String isMultiAns = "N";

    @Column(name = "score", precision = 5, scale = 2)
    @Builder.Default
    private BigDecimal score = new BigDecimal("5");

    @Column(name = "category", length = 100)
    private String category;

    @Column(name = "difficulty", length = 10)
    private String difficulty;

    @Column(name = "question_type", length = 20)
    @Builder.Default
    private String questionType = "CHOICE";

    @Column(name = "tags", length = 500)
    private String tags;

    @Column(name = "explanation", columnDefinition = "TEXT")
    private String explanation;

    @Column(name = "correction_note", columnDefinition = "TEXT")
    private String correctionNote;

    @Column(name = "image_file", length = 200)
    private String imageFile;

    @Column(name = "use_count")
    @Builder.Default
    private Integer useCount = 0;

    @Column(name = "correct_rate", precision = 5, scale = 2)
    private BigDecimal correctRate;

    @Column(name = "is_use", length = 1)
    @Builder.Default
    private String isUse = "Y";

    @CreationTimestamp
    @Column(name = "reg_dt", updatable = false)
    private LocalDateTime regDt;

    @UpdateTimestamp
    @Column(name = "upd_dt")
    private LocalDateTime updDt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "group_id")
    private QuestionBankGroup group;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subject_cd", insertable = false, updatable = false)
    private SubjectMaster subject;
}
