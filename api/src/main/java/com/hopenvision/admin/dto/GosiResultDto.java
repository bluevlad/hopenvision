package com.hopenvision.admin.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class GosiResultDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RstMstResponse {
        private String gosiCd;
        private String rstNo;
        private String userId;
        private String gosiType;
        private String gosiArea;
        private BigDecimal totalScore;
        private BigDecimal avgScore;
        private String passYn;
        private LocalDateTime regDt;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RstDetResponse {
        private String gosiCd;
        private String rstNo;
        private String subjectCd;
        private Integer itemNo;
        private String userId;
        private String answerData;
        private String isCorrect;
        private LocalDateTime regDt;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RstSbjResponse {
        private String gosiCd;
        private String rstNo;
        private String subjectCd;
        private String subjectNm;
        private BigDecimal score;
        private Integer correctCnt;
        private Integer totalCnt;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RstDetailResponse {
        private RstMstResponse master;
        private List<RstSbjResponse> subjects;
        private List<RstDetResponse> details;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SearchRequest {
        private String gosiCd;
        private String gosiType;
        private String gosiArea;
        private String keyword;
        private int page = 0;
        private int size = 20;
    }
}
