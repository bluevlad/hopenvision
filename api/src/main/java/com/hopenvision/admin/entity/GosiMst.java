package com.hopenvision.admin.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "gosi_mst")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GosiMst {

    @Id
    @Column(name = "gosi_cd", length = 50)
    private String gosiCd;

    @Column(name = "gosi_nm", length = 200)
    private String gosiNm;

    @Column(name = "gosi_type", length = 50)
    private String gosiType;

    @Column(name = "start_dt")
    private LocalDateTime startDt;

    @Column(name = "end_dt")
    private LocalDateTime endDt;

    @Column(name = "isuse", length = 10)
    private String isuse;

    @Column(name = "reg_dt")
    private LocalDateTime regDt;

    @Column(name = "reg_ip", length = 50)
    private String regIp;

    @Column(name = "gosi_year", length = 10)
    private String gosiYear;

    @Column(name = "gosi_round", length = 10)
    private String gosiRound;

    @Column(name = "total_score", precision = 10, scale = 2)
    private BigDecimal totalScore;

    @Column(name = "pass_score", precision = 10, scale = 2)
    private BigDecimal passScore;
}
