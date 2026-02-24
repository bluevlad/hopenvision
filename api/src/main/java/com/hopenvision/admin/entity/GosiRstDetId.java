package com.hopenvision.admin.entity;

import lombok.*;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class GosiRstDetId implements Serializable {
    private String gosiCd;
    private String rstNo;
    private String subjectCd;
    private Integer itemNo;
}
