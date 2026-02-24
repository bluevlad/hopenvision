package com.hopenvision.admin.entity;

import lombok.*;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class GosiStatMstId implements Serializable {
    private String gosiCd;
    private String gosiType;
    private String gosiArea;
    private String gosiSubjectCd;
}
