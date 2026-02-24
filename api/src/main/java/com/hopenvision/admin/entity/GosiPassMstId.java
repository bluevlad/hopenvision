package com.hopenvision.admin.entity;

import lombok.*;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class GosiPassMstId implements Serializable {
    private String gosiCd;
    private String subjectCd;
    private String examType;
    private Integer itemNo;
}
