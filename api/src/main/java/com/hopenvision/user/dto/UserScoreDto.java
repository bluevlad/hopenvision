package com.hopenvision.user.dto;

import lombok.*;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserScoreDto {
    private String subjectCd;
    private String subjectNm;
    private BigDecimal rawScore;
    private Integer correctCnt;
    private Integer wrongCnt;
    private Integer totalQuestions;
    private Integer ranking;
    private BigDecimal percentile;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class TotalScore {
        private String examCd;
        private String examNm;
        private BigDecimal totalScore;
        private BigDecimal avgScore;
        private Integer totalRanking;
        private Long totalApplicants;
        private BigDecimal percentile;
        private String passYn;
        private String cutFailYn;
        private List<UserScoreDto> subjectScores;
    }
}
