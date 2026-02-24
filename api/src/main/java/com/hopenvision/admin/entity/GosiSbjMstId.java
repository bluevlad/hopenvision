package com.hopenvision.admin.entity;

import lombok.*;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class GosiSbjMstId implements Serializable {
    private String gosiCd;
    private String sbjType;
    private String subjectCd;
}
