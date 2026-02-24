package com.hopenvision.admin.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "gosi_rst_mst")
@IdClass(GosiRstMstId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GosiRstMst {

    @Id
    @Column(name = "gosi_cd", length = 50)
    private String gosiCd;

    @Id
    @Column(name = "rst_no", length = 50)
    private String rstNo;

    @Column(name = "user_id", length = 100)
    private String userId;

    @Column(name = "gosi_type", length = 50)
    private String gosiType;

    @Column(name = "gosi_area", length = 50)
    private String gosiArea;

    @Column(name = "total_score", precision = 10, scale = 2)
    private BigDecimal totalScore;

    @Column(name = "avg_score", precision = 10, scale = 2)
    private BigDecimal avgScore;

    @Column(name = "pass_yn", length = 10)
    private String passYn;

    @Column(name = "reg_dt")
    private LocalDateTime regDt;
}
