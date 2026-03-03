package com.hopenvision.exam.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "question_bank_group")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionBankGroup {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "group_id")
    private Long groupId;

    @Column(name = "group_cd", length = 50, unique = true, nullable = false)
    private String groupCd;

    @Column(name = "group_nm", length = 200, nullable = false)
    private String groupNm;

    @Column(name = "exam_year", length = 4)
    private String examYear;

    @Column(name = "exam_round")
    private Integer examRound;

    @Column(name = "category", length = 50)
    private String category;

    @Column(name = "source", length = 100)
    private String source;

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

    @OneToMany(mappedBy = "group", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<QuestionBankItem> items = new ArrayList<>();

    public void addItem(QuestionBankItem item) {
        items.add(item);
        item.setGroup(this);
    }

    public void removeItem(QuestionBankItem item) {
        items.remove(item);
        item.setGroup(null);
    }
}
