package com.hopenvision.user.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.*;

import java.io.Serializable;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class UserScoreId implements Serializable {

    @Column(name = "USER_ID", length = 50)
    private String userId;

    @Column(name = "EXAM_CD", length = 50)
    private String examCd;

    @Column(name = "SUBJECT_CD", length = 50)
    private String subjectCd;
}
