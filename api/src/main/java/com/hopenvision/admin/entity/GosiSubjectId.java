package com.hopenvision.admin.entity;

import lombok.*;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class GosiSubjectId implements Serializable {
    private String gosiType;
    private String gosiSubjectCd;
}
