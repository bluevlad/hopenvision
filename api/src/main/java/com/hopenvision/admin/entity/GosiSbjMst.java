package com.hopenvision.admin.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "gosi_sbj_mst")
@IdClass(GosiSbjMstId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GosiSbjMst {

    @Id
    @Column(name = "gosi_cd", length = 50)
    private String gosiCd;

    @Id
    @Column(name = "sbj_type", length = 50)
    private String sbjType;

    @Id
    @Column(name = "subject_cd", length = 50)
    private String subjectCd;

    @Column(name = "subject_nm", length = 200)
    private String subjectNm;

    @Column(name = "isuse", length = 10)
    private String isuse;

    @Column(name = "pos", length = 10)
    private String pos;
}
