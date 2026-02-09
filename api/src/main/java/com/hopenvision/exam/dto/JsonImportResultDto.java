package com.hopenvision.exam.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * JSON Import 결과 DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class JsonImportResultDto {

    private int totalCount;
    private int successCount;
    private int failCount;
    private List<String> errors;
    private List<ImportedQuestion> importedQuestions;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ImportedQuestion {
        private Integer questionNo;
        private String questionText;
        private String category;
        private String difficulty;
        private Integer correctAnswer;
        private String title;
    }
}
