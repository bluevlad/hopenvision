package com.hopenvision.exam.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.time.LocalDateTime;

public class NoticeDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Request {
        @NotBlank(message = "제목은 필수입니다")
        @Size(max = 200)
        private String title;
        private String content;
        private String isPinned;
        private String isUse;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Response {
        private Long noticeId;
        private String examCd;
        private String title;
        private String content;
        private String isPinned;
        private String isUse;
        private LocalDateTime regDt;
        private LocalDateTime updDt;
    }
}
