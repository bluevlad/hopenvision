package com.hopenvision.exam.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

public class SubjectMasterDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Request {
        @NotBlank(message = "과목코드는 필수입니다")
        @Size(min = 1, max = 20, message = "과목코드는 1~20자입니다")
        private String subjectCd;
        @NotBlank(message = "과목명은 필수입니다")
        @Size(min = 1, max = 100, message = "과목명은 1~100자입니다")
        private String subjectNm;
        @Size(max = 20, message = "상위과목코드는 20자 이내입니다")
        private String parentSubjectCd;
        @Min(value = 1, message = "계층깊이는 1 이상입니다")
        @Max(value = 5, message = "계층깊이는 5 이하입니다")
        private Integer subjectDepth;
        @Size(max = 50, message = "카테고리는 50자 이내입니다")
        private String category;
        private String description;
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
        private String subjectCd;
        private String subjectNm;
        private String parentSubjectCd;
        private Integer subjectDepth;
        private String category;
        private String description;
        private Integer sortOrder;
        private String isUse;
        private LocalDateTime regDt;
        private LocalDateTime updDt;
        private Long childCount;
        private Long examCount;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class TreeResponse {
        private String subjectCd;
        private String subjectNm;
        private String parentSubjectCd;
        private Integer subjectDepth;
        private String category;
        private String description;
        private Integer sortOrder;
        private String isUse;
        private List<TreeResponse> children;
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
        private int size = 20;
    }
}
