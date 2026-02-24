package com.hopenvision.admin.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class GosiExamDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class MstResponse {
        private String gosiCd;
        private String gosiNm;
        private String gosiType;
        private LocalDateTime startDt;
        private LocalDateTime endDt;
        private String isuse;
        private LocalDateTime regDt;
        private String gosiYear;
        private String gosiRound;
        private BigDecimal totalScore;
        private BigDecimal passScore;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CodResponse {
        private String gosiType;
        private String gosiTypeNm;
        private String isuse;
        private String pos;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AreaResponse {
        private String gosiType;
        private String gosiArea;
        private String gosiAreaNm;
        private String isuse;
        private String pos;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AreaSearchRequest {
        private String gosiType;
        private String isuse;
    }
}
