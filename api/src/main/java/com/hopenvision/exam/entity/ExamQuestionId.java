package com.hopenvision.exam.entity;

import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class ExamQuestionId implements Serializable {

    private String examCd;
    private String subjectCd;
    private Integer questionNo;
}
