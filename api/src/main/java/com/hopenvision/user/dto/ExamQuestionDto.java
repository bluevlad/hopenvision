package com.hopenvision.user.dto;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamQuestionDto {
    private String subjectCd;
    private String subjectNm;
    private Integer timeLimit;
    private Integer questionCnt;
    private List<QuestionItem> questions;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class QuestionItem {
        private Integer questionNo;
        private String questionText;
        private String contextText;
        private List<String> choices;
        private String imageUrl;
    }
}
