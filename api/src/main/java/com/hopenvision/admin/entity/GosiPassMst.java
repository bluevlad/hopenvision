package com.hopenvision.admin.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "gosi_pass_mst")
@IdClass(GosiPassMstId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GosiPassMst {

    @Id
    @Column(name = "gosi_cd", length = 50)
    private String gosiCd;

    @Id
    @Column(name = "subject_cd", length = 50)
    private String subjectCd;

    @Id
    @Column(name = "exam_type", length = 50)
    private String examType;

    @Id
    @Column(name = "item_no")
    private Integer itemNo;

    @Column(name = "answer_data", length = 10)
    private String answerData;

    @Column(name = "subject_nm", length = 200)
    private String subjectNm;
}
