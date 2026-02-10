package com.hopenvision.user.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class HistoryDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class HistoryItem {
        private String examCd;
        private String examNm;
        private BigDecimal totalScore;
        private BigDecimal avgScore;
        private String passYn;
        private LocalDateTime regDt;
    }
}
