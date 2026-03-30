package com.hopenvision.exam.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class QuestionBankDto {

    // ==================== Group ====================

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class GroupRequest {
        @NotBlank(message = "그룹코드는 필수입니다")
        @Size(min = 1, max = 50, message = "그룹코드는 1~50자입니다")
        private String groupCd;
        @NotBlank(message = "그룹명은 필수입니다")
        @Size(min = 1, max = 200, message = "그룹명은 1~200자입니다")
        private String groupNm;
        @Size(max = 4, message = "출제연도는 4자 이내입니다")
        private String examYear;
        @Min(value = 1, message = "회차는 1 이상입니다")
        private Integer examRound;
        @Size(max = 50, message = "카테고리는 50자 이내입니다")
        private String category;
        @Size(max = 100, message = "출처는 100자 이내입니다")
        private String source;
        private String description;
        @Size(max = 1, message = "사용여부는 1자입니다")
        private String isUse;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class GroupResponse {
        private Long groupId;
        private String groupCd;
        private String groupNm;
        private String examYear;
        private Integer examRound;
        private String category;
        private String source;
        private String description;
        private String isUse;
        private LocalDateTime regDt;
        private LocalDateTime updDt;
        private Long itemCount;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class GroupDetailResponse {
        private Long groupId;
        private String groupCd;
        private String groupNm;
        private String examYear;
        private Integer examRound;
        private String category;
        private String source;
        private String description;
        private String isUse;
        private LocalDateTime regDt;
        private LocalDateTime updDt;
        private List<ItemResponse> items;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class GroupSearchRequest {
        private String keyword;
        private String category;
        private String examYear;
        private String source;
        private String isUse;
        private int page = 0;
        private int size = 10;
    }

    // ==================== Item ====================

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ItemRequest {
        @NotBlank(message = "과목코드는 필수입니다")
        @Size(max = 20, message = "과목코드는 20자 이내입니다")
        private String subjectCd;
        @NotNull(message = "문항번호는 필수입니다")
        @Min(value = 1, message = "문항번호는 1 이상입니다")
        private Integer questionNo;
        @Size(max = 500, message = "문제 제목은 500자 이내입니다")
        private String questionTitle;
        private String questionText;
        private String contextText;
        @Size(max = 1000, message = "보기는 1000자 이내입니다")
        private String choice1;
        @Size(max = 1000, message = "보기는 1000자 이내입니다")
        private String choice2;
        @Size(max = 1000, message = "보기는 1000자 이내입니다")
        private String choice3;
        @Size(max = 1000, message = "보기는 1000자 이내입니다")
        private String choice4;
        @Size(max = 1000, message = "보기는 1000자 이내입니다")
        private String choice5;
        @NotBlank(message = "정답은 필수입니다")
        @Size(max = 100, message = "정답은 100자 이내입니다")
        private String correctAns;
        @Size(max = 1, message = "복수정답여부는 1자입니다")
        private String isMultiAns;
        private BigDecimal score;
        @Size(max = 100, message = "카테고리는 100자 이내입니다")
        private String category;
        @Size(max = 10, message = "난이도는 10자 이내입니다")
        private String difficulty;
        @Size(max = 20, message = "문항유형은 20자 이내입니다")
        private String questionType;
        @Size(max = 500, message = "태그는 500자 이내입니다")
        private String tags;
        private String explanation;
        private String correctionNote;
        @Size(max = 200, message = "이미지경로는 200자 이내입니다")
        private String imageFile;
        @Size(max = 1, message = "사용여부는 1자입니다")
        private String isUse;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ItemResponse {
        private Long itemId;
        private Long groupId;
        private String groupNm;
        private String subjectCd;
        private String subjectNm;
        private Integer questionNo;
        private String questionTitle;
        private String questionText;
        private String contextText;
        private String choice1;
        private String choice2;
        private String choice3;
        private String choice4;
        private String choice5;
        private String correctAns;
        private String isMultiAns;
        private BigDecimal score;
        private String category;
        private String difficulty;
        private String questionType;
        private String tags;
        private String explanation;
        private String correctionNote;
        private String imageFile;
        private Integer useCount;
        private BigDecimal correctRate;
        private String isUse;
        private LocalDateTime regDt;
        private LocalDateTime updDt;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ItemSearchRequest {
        private String keyword;
        private Long groupId;
        private String subjectCd;
        private String difficulty;
        private String questionType;
        private String category;
        private String isUse;
        private int page = 0;
        private int size = 20;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class BulkImportRequest {
        private List<ItemRequest> items;
    }
}
