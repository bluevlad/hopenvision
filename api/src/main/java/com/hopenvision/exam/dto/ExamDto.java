package com.hopenvision.exam.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public class ExamDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Request {
        @NotBlank(message = "시험코드는 필수입니다")
        @Size(min = 1, max = 50, message = "시험코드는 1~50자입니다")
        private String examCd;
        @NotBlank(message = "시험명은 필수입니다")
        @Size(min = 1, max = 200, message = "시험명은 1~200자입니다")
        private String examNm;
        @NotBlank(message = "시험유형은 필수입니다")
        @Size(max = 20, message = "시험유형은 20자 이내입니다")
        private String examType;
        @Size(max = 4, message = "시험연도는 4자 이내입니다")
        private String examYear;
        @Min(value = 1, message = "회차는 1 이상입니다")
        @Max(value = 99, message = "회차는 99 이하입니다")
        private Integer examRound;
        private LocalDate examDate;
        @DecimalMin(value = "0", message = "총점은 0 이상입니다")
        @DecimalMax(value = "10000", message = "총점은 10000 이하입니다")
        private BigDecimal totalScore;
        @DecimalMin(value = "0", message = "합격점수는 0 이상입니다")
        @DecimalMax(value = "10000", message = "합격점수는 10000 이하입니다")
        private BigDecimal passScore;
        @Size(max = 1, message = "사용여부는 1자입니다")
        private String isUse;
        @Valid
        private List<SubjectDto.Request> subjects;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Response {
        private String examCd;
        private String examNm;
        private String examType;
        private String examYear;
        private Integer examRound;
        private LocalDate examDate;
        private BigDecimal totalScore;
        private BigDecimal passScore;
        private String isUse;
        private LocalDateTime regDt;
        private LocalDateTime updDt;
        private Long subjectCnt;
        private Long applicantCnt;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class DetailResponse {
        private String examCd;
        private String examNm;
        private String examType;
        private String examYear;
        private Integer examRound;
        private LocalDate examDate;
        private BigDecimal totalScore;
        private BigDecimal passScore;
        private String isUse;
        private LocalDateTime regDt;
        private LocalDateTime updDt;
        private List<SubjectDto.Response> subjects;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SearchRequest {
        private String keyword;
        private String examType;
        private String examYear;
        private String isUse;
        private int page = 0;
        private int size = 10;
    }
}
