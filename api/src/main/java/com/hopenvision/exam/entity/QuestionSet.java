package com.hopenvision.exam.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "question_set")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionSet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "set_id")
    private Long setId;

    @Column(name = "set_cd", length = 50, unique = true, nullable = false)
    private String setCd;

    @Column(name = "set_nm", length = 200, nullable = false)
    private String setNm;

    @Column(name = "subject_cd", length = 20, nullable = false)
    private String subjectCd;

    @Column(name = "question_cnt")
    @Builder.Default
    private Integer questionCnt = 0;

    @Column(name = "total_score")
    @Builder.Default
    private Integer totalScore = 0;

    @Column(name = "category", length = 50)
    private String category;

    @Column(name = "difficulty_level", length = 10)
    private String difficultyLevel;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "is_use", length = 1)
    @Builder.Default
    private String isUse = "Y";

    @CreationTimestamp
    @Column(name = "reg_dt", updatable = false)
    private LocalDateTime regDt;

    @UpdateTimestamp
    @Column(name = "upd_dt")
    private LocalDateTime updDt;

    @OneToMany(mappedBy = "questionSet", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("sortOrder ASC")
    @Builder.Default
    private List<QuestionSetItem> items = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subject_cd", insertable = false, updatable = false)
    private SubjectMaster subject;

    public void addItem(QuestionSetItem item) {
        items.add(item);
        item.setQuestionSet(this);
    }

    public void removeItem(QuestionSetItem item) {
        items.remove(item);
        item.setQuestionSet(null);
    }
}
