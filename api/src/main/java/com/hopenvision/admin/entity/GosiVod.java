package com.hopenvision.admin.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "gosi_vod")
@IdClass(GosiVodId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GosiVod {

    @Id
    @Column(name = "gosi_cd", length = 50)
    private String gosiCd;

    @Id
    @Column(name = "prf_id", length = 100)
    private String prfId;

    @Id
    @Column(name = "idx")
    private Integer idx;

    @Column(name = "subject_cd", length = 50)
    private String subjectCd;

    @Column(name = "subject_nm", length = 200)
    private String subjectNm;

    @Column(name = "prf_nm", length = 200)
    private String prfNm;

    @Column(name = "vod_url", length = 1000)
    private String vodUrl;

    @Column(name = "vod_nm", length = 500)
    private String vodNm;

    @Column(name = "isuse", length = 10)
    private String isuse;
}
