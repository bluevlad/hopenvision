package com.hopenvision.user.entity;

import lombok.*;

import java.io.Serializable;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class UserTotalScoreId implements Serializable {
    private String userId;
    private String examCd;
}
