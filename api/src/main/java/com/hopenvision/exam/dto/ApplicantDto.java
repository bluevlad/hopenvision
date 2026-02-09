package com.hopenvision.exam.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class ApplicantDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Request {
        @NotBlank(message = "수험번호는 필수입니다")
        private String applicantNo;
        private String userId;
        @NotBlank(message = "이름은 필수입니다")
        private String userNm;
        private String applyArea;
        private String applyType;
        private BigDecimal addScore;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Response {
        private String examCd;
        private String applicantNo;
        private String userId;
        private String userNm;
        private String applyArea;
        private String applyType;
        private BigDecimal addScore;
        private BigDecimal totalScore;
        private BigDecimal avgScore;
        private Integer ranking;
        private String passYn;
        private String scoreStatus;
        private LocalDateTime regDt;
        private LocalDateTime updDt;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SearchRequest {
        private String examCd;
        private String keyword;
        private int page = 0;
        private int size = 10;
    }
}
