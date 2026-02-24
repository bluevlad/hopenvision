package com.hopenvision.admin.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "gosi_cod")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GosiCod {

    @Id
    @Column(name = "gosi_type", length = 50)
    private String gosiType;

    @Column(name = "gosi_type_nm", length = 200)
    private String gosiTypeNm;

    @Column(name = "isuse", length = 10)
    private String isuse;

    @Column(name = "pos", length = 10)
    private String pos;
}
