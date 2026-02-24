package com.hopenvision.admin.entity;

import lombok.*;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class GosiAreaMstId implements Serializable {
    private String gosiType;
    private String gosiArea;
}
