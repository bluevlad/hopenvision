package com.hopenvision.admin.dto;

import lombok.*;

public class GosiSubjectDto {

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class Response {
        private String gosiType;
        private String gosiSubjectCd;
        private String gosiSubjecNm;
        private String isuse;
        private String pos;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class SearchRequest {
        private String gosiType;
        private String isuse;
    }
}
