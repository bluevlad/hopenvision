package com.hopenvision.admin.entity;

import lombok.*;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class GosiVodId implements Serializable {
    private String gosiCd;
    private String prfId;
    private Integer idx;
}
