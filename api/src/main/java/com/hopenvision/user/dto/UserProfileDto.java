package com.hopenvision.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.time.LocalDateTime;

public class UserProfileDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Response {
        private String userId;
        private String userNm;
        private String email;
        private String newsletterYn;
        private LocalDateTime regDt;
        private LocalDateTime updDt;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class UpsertRequest {
        @NotBlank(message = "사용자 ID는 필수입니다")
        @Size(min = 1, max = 50, message = "사용자 ID는 1~50자입니다")
        private String userId;

        @NotBlank(message = "이름은 필수입니다")
        @Size(min = 1, max = 100, message = "이름은 1~100자입니다")
        private String userNm;

        @Email(message = "올바른 이메일 형식이 아닙니다")
        @Size(max = 200, message = "이메일은 200자 이내입니다")
        private String email;

        @Pattern(regexp = "^[YN]$", message = "뉴스레터 수신 여부는 Y 또는 N입니다")
        private String newsletterYn;
    }
}
