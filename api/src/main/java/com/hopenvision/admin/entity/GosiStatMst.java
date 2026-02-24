package com.hopenvision.admin.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "gosi_stat_mst")
@IdClass(GosiStatMstId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GosiStatMst {

    @Id
    @Column(name = "gosi_cd", length = 50)
    private String gosiCd;

    @Id
    @Column(name = "gosi_type", length = 50)
    private String gosiType;

    @Id
    @Column(name = "gosi_area", length = 50)
    private String gosiArea;

    @Id
    @Column(name = "gosi_subject_cd", length = 50)
    private String gosiSubjectCd;

    @Column(name = "gosi_type_nm", length = 200)
    private String gosiTypeNm;

    @Column(name = "gosi_area_nm", length = 200)
    private String gosiAreaNm;

    @Column(name = "gosi_subject_nm", length = 200)
    private String gosiSubjectNm;

    @Column(name = "total_cnt")
    private Integer totalCnt;

    @Column(name = "avg_score", precision = 10, scale = 2)
    private BigDecimal avgScore;

    @Column(name = "max_score", precision = 10, scale = 2)
    private BigDecimal maxScore;

    @Column(name = "min_score", precision = 10, scale = 2)
    private BigDecimal minScore;

    @Column(name = "pass_cnt")
    private Integer passCnt;

    @Column(name = "pass_rate", precision = 10, scale = 2)
    private BigDecimal passRate;
}
