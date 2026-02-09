package com.hopenvision.user.dto;

import lombok.*;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScoringResultDto {
    private String examCd;
    private String examNm;
    private BigDecimal totalScore;
    private BigDecimal avgScore;
    private Integer totalCorrect;
    private Integer totalWrong;
    private Integer totalQuestions;
    private BigDecimal correctRate;
    private Integer estimatedRanking;
    private Long totalApplicants;
    private String passYn;
    private String cutFailYn;
    private List<SubjectResult> subjectResults;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SubjectResult {
        private String subjectCd;
        private String subjectNm;
        private BigDecimal score;
        private Integer correctCnt;
        private Integer wrongCnt;
        private Integer totalQuestions;
        private BigDecimal correctRate;
        private BigDecimal cutLine;
        private String cutFailYn;
        private List<QuestionResult> questionResults;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class QuestionResult {
        private Integer questionNo;
        private String userAns;
        private String correctAns;
        private String isCorrect;
        private BigDecimal score;
    }
}
