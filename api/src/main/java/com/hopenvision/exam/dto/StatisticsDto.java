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

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class QuestionStatistics {
        private String subjectCd;
        private String subjectNm;
        private List<QuestionDetail> questions;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class QuestionDetail {
        private int questionNo;
        private String correctAns;
        private long totalAnswered;
        private long correctCount;
        private BigDecimal correctRate;
        private String difficulty;
        private List<ChoiceDistribution> choiceDistributions;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ChoiceDistribution {
        private String choice;
        private long count;
        private BigDecimal percentage;
        private boolean isCorrect;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AreaStatistics {
        private String applyArea;
        private long applicantCount;
        private BigDecimal avgScore;
        private BigDecimal maxScore;
        private BigDecimal minScore;
        private long passedCount;
        private BigDecimal passRate;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ExamDashboardItem {
        private String examCd;
        private String examNm;
        private String examType;
        private String examStatus;
        private long applicantCount;
        private long submittedCount;
        private BigDecimal submissionRate;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ScoreTrendItem {
        private String examCd;
        private String examNm;
        private BigDecimal totalScore;
        private BigDecimal avgScore;
        private String passYn;
        private String regDt;
        private List<SubjectScoreItem> subjectScores;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SubjectScoreItem {
        private String subjectCd;
        private String subjectNm;
        private BigDecimal score;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class WeaknessAnalysis {
        private String subjectCd;
        private String subjectNm;
        private BigDecimal correctRate;
        private String level;
        private int correctCnt;
        private int wrongCnt;
        private int totalQuestions;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class DiscriminationDetail {
        private int questionNo;
        private BigDecimal correctRate;
        private String difficulty;
        private BigDecimal discriminationIndex;
        private String discriminationLevel;
    }
}
