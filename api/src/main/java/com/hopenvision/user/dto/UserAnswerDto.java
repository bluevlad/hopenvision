package com.hopenvision.user.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
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
        @NotBlank(message = "시험코드는 필수입니다")
        @Size(max = 50, message = "시험코드는 50자 이내입니다")
        private String examCd;
        @NotNull(message = "과목 답안 목록은 필수입니다")
        @Size(min = 1, message = "최소 1개 과목의 답안이 필요합니다")
        @Valid
        private List<SubjectAnswer> subjects;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SubjectAnswer {
        @NotBlank(message = "과목코드는 필수입니다")
        @Size(max = 50, message = "과목코드는 50자 이내입니다")
        private String subjectCd;
        @NotNull(message = "답안 목록은 필수입니다")
        @Valid
        private List<QuestionAnswer> answers;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class QuestionAnswer {
        @NotNull(message = "문항번호는 필수입니다")
        @Min(value = 1, message = "문항번호는 1 이상입니다")
        private Integer questionNo;
        @Size(max = 100, message = "답안은 100자 이내입니다")
        private String answer;
    }
}
