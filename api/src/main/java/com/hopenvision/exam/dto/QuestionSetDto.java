package com.hopenvision.exam.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class QuestionSetDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Request {
        @NotBlank(message = "세트코드는 필수입니다")
        @Size(min = 1, max = 50, message = "세트코드는 1~50자입니다")
        private String setCd;
        @NotBlank(message = "세트명은 필수입니다")
        @Size(min = 1, max = 200, message = "세트명은 1~200자입니다")
        private String setNm;
        @Size(max = 50, message = "카테고리는 50자 이내입니다")
        private String category;
        @Size(max = 10, message = "난이도는 10자 이내입니다")
        private String difficultyLevel;
        private String description;
        @Size(max = 1, message = "사용여부는 1자입니다")
        private String isUse;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Response {
        private Long setId;
        private String setCd;
        private String setNm;
        private Integer questionCnt;
        private Integer totalScore;
        private Integer subjectCnt;
        private String category;
        private String difficultyLevel;
        private String description;
        private String isUse;
        private LocalDateTime regDt;
        private LocalDateTime updDt;
        private List<SubjectSummary> subjectSummaries;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SubjectSummary {
        private String subjectCd;
        private String subjectNm;
        private Long itemCount;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class DetailResponse {
        private Long setId;
        private String setCd;
        private String setNm;
        private Integer questionCnt;
        private Integer totalScore;
        private Integer subjectCnt;
        private String category;
        private String difficultyLevel;
        private String description;
        private String isUse;
        private LocalDateTime regDt;
        private LocalDateTime updDt;
        private List<SubjectSummary> subjectSummaries;
        private List<ItemResponse> items;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ItemRequest {
        @NotNull(message = "문제은행 항목 ID는 필수입니다")
        private Long itemId;
        @NotBlank(message = "과목코드는 필수입니다")
        @Size(max = 20, message = "과목코드는 20자 이내입니다")
        private String subjectCd;
        @Min(value = 1, message = "문항번호는 1 이상입니다")
        private Integer questionNo;
        private BigDecimal score;
        @Min(value = 0, message = "정렬순서는 0 이상입니다")
        private Integer sortOrder;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ItemResponse {
        private Long setItemId;
        private Long setId;
        private Long itemId;
        private String subjectCd;
        private String subjectNm;
        private Integer questionNo;
        private BigDecimal score;
        private Integer sortOrder;
        // 문제은행 항목 정보
        private String questionTitle;
        private String questionText;
        private String correctAns;
        private String difficulty;
        private String questionType;
        private BigDecimal bankScore;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SearchRequest {
        private String keyword;
        private String category;
        private String isUse;
        private int page = 0;
        private int size = 10;
    }
}
