package com.hopenvision.admin.dto;

import lombok.*;

import java.time.LocalDateTime;

public class GosiMemberDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Response {
        private String userId;
        private String userNm;
        private String userNicknm;
        private String userPosition;
        private String sex;
        private String userRole;
        private String adminRole;
        private LocalDateTime birthDay;
        private String categoryCode;
        private Integer userPoint;
        private Integer payment;
        private String isuse;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SearchRequest {
        private String keyword;
        private int page = 0;
        private int size = 20;
    }
}
