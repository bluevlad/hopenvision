package com.hopenvision.exam.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class AnswerKeyDto {

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
        @Min(value = 1, message = "문항번호는 1 이상입니다")
        @Max(value = 999, message = "문항번호는 999 이하입니다")
        private Integer questionNo;
        @Size(max = 100, message = "정답은 100자 이내입니다")
        private String correctAns;
        @DecimalMin(value = "0", message = "배점은 0 이상입니다")
        @DecimalMax(value = "1000", message = "배점은 1000 이하입니다")
        private BigDecimal score;
        @Size(max = 1, message = "복수정답여부는 1자입니다")
        private String isMultiAns;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class BulkRequest {
        @NotBlank(message = "시험코드는 필수입니다")
        @Size(max = 50, message = "시험코드는 50자 이내입니다")
        private String examCd;
        @NotBlank(message = "과목코드는 필수입니다")
        @Size(max = 50, message = "과목코드는 50자 이내입니다")
        private String subjectCd;
        @NotNull(message = "정답 목록은 필수입니다")
        @Valid
        private List<AnswerItem> answers;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AnswerItem {
        @NotNull(message = "문항번호는 필수입니다")
        @Min(value = 1, message = "문항번호는 1 이상입니다")
        private Integer questionNo;
        @Size(max = 100, message = "정답은 100자 이내입니다")
        private String correctAns;
        @DecimalMin(value = "0", message = "배점은 0 이상입니다")
        private BigDecimal score;
        @Size(max = 1, message = "복수정답여부는 1자입니다")
        private String isMultiAns;
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
        private Integer questionNo;
        private String correctAns;
        private BigDecimal score;
        private String isMultiAns;
        private LocalDateTime regDt;
        private LocalDateTime updDt;
    }
}
