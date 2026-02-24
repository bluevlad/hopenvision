package com.hopenvision.admin.dto;

import lombok.*;

import java.math.BigDecimal;

public class GosiPassDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class PassMstResponse {
        private String gosiCd;
        private String subjectCd;
        private String examType;
        private Integer itemNo;
        private String answerData;
        private String subjectNm;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class PassStaResponse {
        private String gosiCd;
        private String gosiType;
        private String gosiTypeNm;
        private BigDecimal passScore;
        private String isuse;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SearchRequest {
        private String gosiCd;
        private String subjectCd;
        private String examType;
        private int page = 0;
        private int size = 20;
    }
}
