package com.hopenvision.admin.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "gosi_area_mst")
@IdClass(GosiAreaMstId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GosiAreaMst {

    @Id
    @Column(name = "gosi_type", length = 50)
    private String gosiType;

    @Id
    @Column(name = "gosi_area", length = 50)
    private String gosiArea;

    @Column(name = "gosi_area_nm", length = 200)
    private String gosiAreaNm;

    @Column(name = "isuse", length = 10)
    private String isuse;

    @Column(name = "pos", length = 10)
    private String pos;
}
