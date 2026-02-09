package com.hopenvision.user.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "USER_ANSWER")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserAnswer {

    @EmbeddedId
    private UserAnswerId id;

    @Column(name = "USER_ANS", length = 100)
    private String userAns;

    @Column(name = "IS_CORRECT", length = 1)
    private String isCorrect;

    @Column(name = "REG_DT")
    private LocalDateTime regDt;

    @PrePersist
    public void prePersist() {
        this.regDt = LocalDateTime.now();
    }
}
