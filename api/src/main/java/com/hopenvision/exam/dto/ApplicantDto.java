package com.hopenvision.exam.dto;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class ApplicantDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Request {
        @NotBlank(message = "수험번호는 필수입니다")
        @Size(min = 1, max = 20, message = "수험번호는 1~20자입니다")
        private String applicantNo;
        @Size(max = 50, message = "사용자ID는 50자 이내입니다")
        private String userId;
        @NotBlank(message = "이름은 필수입니다")
        @Size(min = 1, max = 100, message = "이름은 1~100자입니다")
        private String userNm;
        @Size(max = 50, message = "응시지역은 50자 이내입니다")
        private String applyArea;
        @Size(max = 20, message = "응시유형은 20자 이내입니다")
        private String applyType;
        @DecimalMin(value = "0", message = "가산점은 0 이상입니다")
        @DecimalMax(value = "100", message = "가산점은 100 이하입니다")
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

    // ==================== CSV Result Import ====================

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CsvResultRow {
        private int rowNum;
        private String examCd;
        private String subjectNm;
        private String userNm;
        private String userId;
        private String answers;          // 원본 답안 문자열
        // 매칭 결과
        private String subjectCd;        // 매칭된 과목코드
        private int answerCount;         // 파싱된 답안 수
        private int correctCnt;          // 정답 수
        private int wrongCnt;            // 오답 수
        private BigDecimal score;        // 점수
        private String status;           // MATCHED, SKIP, ERROR, DUPLICATE
        private String message;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class CsvResultImportResult {
        private int totalRows;
        private int matchedRows;
        private int skippedRows;
        private int errorRows;
        private int importedRows;
        private List<CsvResultRow> rows;
    }
}
