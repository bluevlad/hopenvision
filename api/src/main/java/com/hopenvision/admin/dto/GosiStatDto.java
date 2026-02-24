package com.hopenvision.admin.dto;

import lombok.*;

import java.math.BigDecimal;

public class GosiStatDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class StatMstResponse {
        private String gosiCd;
        private String gosiType;
        private String gosiArea;
        private String gosiSubjectCd;
        private String gosiTypeNm;
        private String gosiAreaNm;
        private String gosiSubjectNm;
        private Integer totalCnt;
        private BigDecimal avgScore;
        private BigDecimal maxScore;
        private BigDecimal minScore;
        private Integer passCnt;
        private BigDecimal passRate;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SbjMstResponse {
        private String gosiCd;
        private String sbjType;
        private String subjectCd;
        private String subjectNm;
        private String isuse;
        private String pos;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SearchRequest {
        private String gosiCd;
        private String gosiType;
        private int page = 0;
        private int size = 20;
    }
}
