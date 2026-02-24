package com.hopenvision.admin.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "gosi_subject")
@IdClass(GosiSubjectId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GosiSubject {

    @Id
    @Column(name = "gosi_type", length = 50)
    private String gosiType;

    @Id
    @Column(name = "gosi_subject_cd", length = 50)
    private String gosiSubjectCd;

    @Column(name = "gosi_subjec_nm", length = 200)
    private String gosiSubjecNm;

    @Column(name = "isuse", length = 10)
    private String isuse;

    @Column(name = "pos", length = 10)
    private String pos;
}
