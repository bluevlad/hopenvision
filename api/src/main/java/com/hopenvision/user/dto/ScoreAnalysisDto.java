package com.hopenvision.user.dto;

import lombok.*;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScoreAnalysisDto {
    private String examCd;
    private String examNm;
    private BigDecimal myTotalScore;
    private BigDecimal myAvgScore;
    private Integer ranking;
    private Long totalApplicants;
    private BigDecimal percentile;
    private String passYn;
    private List<ScoreDistribution> scoreDistributions;
    private List<SubjectComparison> subjectComparisons;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ScoreDistribution {
        private String range;
        private int count;
        private double percentage;
        private boolean isUserInRange;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SubjectComparison {
        private String subjectCd;
        private String subjectNm;
        private BigDecimal myScore;
        private BigDecimal avgScore;
        private BigDecimal maxScore;
        private BigDecimal minScore;
        private Integer ranking;
        private Long totalCount;
    }
}
