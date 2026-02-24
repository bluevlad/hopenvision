package com.hopenvision.admin.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "gosi_rst_sbj")
@IdClass(GosiRstSbjId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GosiRstSbj {

    @Id
    @Column(name = "gosi_cd", length = 50)
    private String gosiCd;

    @Id
    @Column(name = "rst_no", length = 50)
    private String rstNo;

    @Id
    @Column(name = "subject_cd", length = 50)
    private String subjectCd;

    @Column(name = "subject_nm", length = 200)
    private String subjectNm;

    @Column(name = "score", precision = 10, scale = 2)
    private BigDecimal score;

    @Column(name = "correct_cnt")
    private Integer correctCnt;

    @Column(name = "total_cnt")
    private Integer totalCnt;
}
