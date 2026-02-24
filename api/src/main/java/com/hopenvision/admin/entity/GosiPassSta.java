package com.hopenvision.admin.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "gosi_pass_sta")
@IdClass(GosiPassStaId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GosiPassSta {

    @Id
    @Column(name = "gosi_cd", length = 50)
    private String gosiCd;

    @Id
    @Column(name = "gosi_type", length = 50)
    private String gosiType;

    @Column(name = "gosi_type_nm", length = 200)
    private String gosiTypeNm;

    @Column(name = "pass_score", precision = 10, scale = 2)
    private BigDecimal passScore;

    @Column(name = "isuse", length = 10)
    private String isuse;
}
