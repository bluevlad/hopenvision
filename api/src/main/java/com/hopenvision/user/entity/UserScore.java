package com.hopenvision.user.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "USER_SCORE")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserScore {

    @EmbeddedId
    private UserScoreId id;

    @Column(name = "RAW_SCORE", precision = 5, scale = 2)
    private BigDecimal rawScore;

    @Column(name = "CORRECT_CNT")
    private Integer correctCnt;

    @Column(name = "WRONG_CNT")
    private Integer wrongCnt;

    @Column(name = "RANKING")
    private Integer ranking;

    @Column(name = "PERCENTILE", precision = 5, scale = 2)
    private BigDecimal percentile;

    @Column(name = "BATCH_YN", length = 1)
    @Builder.Default
    private String batchYn = "N";

    @Column(name = "REG_DT")
    private LocalDateTime regDt;

    @Column(name = "UPD_DT")
    private LocalDateTime updDt;

    @PrePersist
    public void prePersist() {
        this.regDt = LocalDateTime.now();
        if (this.batchYn == null) {
            this.batchYn = "N";
        }
    }

    @PreUpdate
    public void preUpdate() {
        this.updDt = LocalDateTime.now();
    }
}
