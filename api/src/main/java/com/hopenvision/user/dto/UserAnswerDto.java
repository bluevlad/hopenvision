package com.hopenvision.user.dto;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserAnswerDto {
    private String subjectCd;
    private String subjectNm;
    private Integer questionNo;
    private String userAns;
    private String correctAns;
    private String isCorrect;
    private Integer score;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SubmitRequest {
        private String examCd;
        private List<SubjectAnswer> subjects;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SubjectAnswer {
        private String subjectCd;
        private List<QuestionAnswer> answers;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class QuestionAnswer {
        private Integer questionNo;
        private String answer;
    }
}
