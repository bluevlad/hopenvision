package com.hopenvision.exam.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class SubjectDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Request {
        @Size(max = 50, message = "시험코드는 50자 이내입니다")
        private String examCd;
        @Size(max = 50, message = "과목코드는 50자 이내입니다")
        private String subjectCd;
        @Size(max = 200, message = "과목명은 200자 이내입니다")
        private String subjectNm;
        @Size(max = 20, message = "과목유형은 20자 이내입니다")
        private String subjectType;
        @Min(value = 1, message = "문항수는 1 이상입니다")
        @Max(value = 999, message = "문항수는 999 이하입니다")
        private Integer questionCnt;
        @DecimalMin(value = "0", message = "배점은 0 이상입니다")
        @DecimalMax(value = "1000", message = "배점은 1000 이하입니다")
        private BigDecimal scorePerQ;
        @Size(max = 20, message = "문항유형은 20자 이내입니다")
        private String questionType;
        @DecimalMin(value = "0", message = "과락점수는 0 이상입니다")
        private BigDecimal cutLine;
        @Min(value = 0, message = "정렬순서는 0 이상입니다")
        @Max(value = 999, message = "정렬순서는 999 이하입니다")
        private Integer sortOrder;
        @Size(max = 1, message = "사용여부는 1자입니다")
        private String isUse;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Response {
        private String examCd;
        private String subjectCd;
        private String subjectNm;
        private String subjectType;
        private Integer questionCnt;
        private BigDecimal scorePerQ;
        private String questionType;
        private BigDecimal cutLine;
        private Integer sortOrder;
        private String isUse;
        private LocalDateTime regDt;
        private Long answerCnt;
    }
}
