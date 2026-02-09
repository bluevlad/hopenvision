package com.hopenvision.user.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "USER_TOTAL_SCORE")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@IdClass(UserTotalScoreId.class)
public class UserTotalScore {

    @Id
    @Column(name = "USER_ID", length = 50)
    private String userId;

    @Id
    @Column(name = "EXAM_CD", length = 50)
    private String examCd;

    @Column(name = "TOTAL_SCORE", precision = 5, scale = 2)
    private BigDecimal totalScore;

    @Column(name = "AVG_SCORE", precision = 5, scale = 2)
    private BigDecimal avgScore;

    @Column(name = "TOTAL_RANKING")
    private Integer totalRanking;

    @Column(name = "AREA_RANKING")
    private Integer areaRanking;

    @Column(name = "TYPE_RANKING")
    private Integer typeRanking;

    @Column(name = "PERCENTILE", precision = 5, scale = 2)
    private BigDecimal percentile;

    @Column(name = "PASS_YN", length = 1)
    private String passYn;

    @Column(name = "CUT_FAIL_YN", length = 1)
    @Builder.Default
    private String cutFailYn = "N";

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
        if (this.batchYn == null) this.batchYn = "N";
        if (this.cutFailYn == null) this.cutFailYn = "N";
    }

    @PreUpdate
    public void preUpdate() {
        this.updDt = LocalDateTime.now();
    }
}
