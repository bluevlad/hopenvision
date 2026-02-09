package com.hopenvision.user.dto;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserExamDto {
    private String examCd;
    private String examNm;
    private String examType;
    private String examYear;
    private Integer examRound;
    private LocalDate examDate;
    private BigDecimal totalScore;
    private BigDecimal passScore;
    private Long applicantCount;
    private Boolean hasSubmitted;
    private List<SubjectInfo> subjects;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SubjectInfo {
        private String subjectCd;
        private String subjectNm;
        private String subjectType;
        private Integer questionCnt;
        private BigDecimal scorePerQ;
        private String questionType;
        private BigDecimal cutLine;
    }
}
