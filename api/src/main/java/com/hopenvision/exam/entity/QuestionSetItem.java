package com.hopenvision.exam.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "question_set_item")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionSetItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "set_item_id")
    private Long setItemId;

    @Column(name = "set_id", nullable = false, insertable = false, updatable = false)
    private Long setId;

    @Column(name = "item_id", nullable = false)
    private Long itemId;

    @Column(name = "question_no")
    private Integer questionNo;

    @Column(name = "score", precision = 5, scale = 2)
    private BigDecimal score;

    @Column(name = "sort_order")
    @Builder.Default
    private Integer sortOrder = 1;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "set_id")
    private QuestionSet questionSet;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id", insertable = false, updatable = false)
    private QuestionBankItem bankItem;
}
