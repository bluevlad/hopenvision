package com.hopenvision.admin.dto;

import lombok.*;

public class GosiVodDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Response {
        private String gosiCd;
        private String prfId;
        private Integer idx;
        private String subjectCd;
        private String subjectNm;
        private String prfNm;
        private String vodUrl;
        private String vodNm;
        private String isuse;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SearchRequest {
        private String gosiCd;
        private String keyword;
        private int page = 0;
        private int size = 20;
    }
}
