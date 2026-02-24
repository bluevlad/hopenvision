package com.hopenvision.admin.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "gosi_rst_det")
@IdClass(GosiRstDetId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GosiRstDet {

    @Id
    @Column(name = "gosi_cd", length = 50)
    private String gosiCd;

    @Id
    @Column(name = "rst_no", length = 50)
    private String rstNo;

    @Id
    @Column(name = "subject_cd", length = 50)
    private String subjectCd;

    @Id
    @Column(name = "item_no")
    private Integer itemNo;

    @Column(name = "user_id", length = 100)
    private String userId;

    @Column(name = "answer_data", length = 10)
    private String answerData;

    @Column(name = "is_correct", length = 10)
    private String isCorrect;

    @Column(name = "reg_dt")
    private LocalDateTime regDt;
}
