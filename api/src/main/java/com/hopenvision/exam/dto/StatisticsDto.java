package com.hopenvision.exam.dto;

import lombok.*;

import java.math.BigDecimal;
import java.util.List;

public class StatisticsDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ExamStatistics {
        private String examCd;
        private String examNm;
        private long totalApplicants;
        private long passedCount;
        private BigDecimal passRate;
        private BigDecimal avgScore;
        private BigDecimal maxScore;
        private BigDecimal minScore;
        private List<ScoreDistribution> scoreDistributions;
        private List<SubjectStatistics> subjectStatistics;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SubjectStatistics {
        private String subjectCd;
        private String subjectNm;
        private long applicantCount;
        private BigDecimal avgScore;
        private BigDecimal maxScore;
        private BigDecimal minScore;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ScoreDistribution {
        private String range;
        private long count;
        private BigDecimal percentage;
    }
}
