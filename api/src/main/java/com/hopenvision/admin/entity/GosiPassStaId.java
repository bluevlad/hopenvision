package com.hopenvision.admin.entity;

import lombok.*;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class GosiPassStaId implements Serializable {
    private String gosiCd;
    private String gosiType;
}
