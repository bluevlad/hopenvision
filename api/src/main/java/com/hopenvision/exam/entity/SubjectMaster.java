package com.hopenvision.exam.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "subject_master")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SubjectMaster {

    @Id
    @Column(name = "subject_cd", length = 20)
    private String subjectCd;

    @Column(name = "subject_nm", length = 100, nullable = false)
    private String subjectNm;

    @Column(name = "parent_subject_cd", length = 20)
    private String parentSubjectCd;

    @Column(name = "subject_depth")
    @Builder.Default
    private Integer subjectDepth = 1;

    @Column(name = "sort_order")
    @Builder.Default
    private Integer sortOrder = 1;

    @Column(name = "category", length = 50)
    private String category;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "is_use", length = 1)
    @Builder.Default
    private String isUse = "Y";

    @CreationTimestamp
    @Column(name = "reg_dt", updatable = false)
    private LocalDateTime regDt;

    @UpdateTimestamp
    @Column(name = "upd_dt")
    private LocalDateTime updDt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_subject_cd", insertable = false, updatable = false)
    private SubjectMaster parentSubject;
}
