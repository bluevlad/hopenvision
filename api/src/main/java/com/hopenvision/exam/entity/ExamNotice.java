package com.hopenvision.exam.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "exam_notice")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamNotice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notice_id")
    private Long noticeId;

    @Column(name = "exam_cd", length = 50, nullable = false)
    private String examCd;

    @Column(name = "title", length = 200, nullable = false)
    private String title;

    @Column(name = "content", columnDefinition = "TEXT")
    private String content;

    @Column(name = "is_pinned", length = 1)
    @Builder.Default
    private String isPinned = "N";

    @Column(name = "is_use", length = 1)
    @Builder.Default
    private String isUse = "Y";

    @CreationTimestamp
    @Column(name = "reg_dt", updatable = false)
    private LocalDateTime regDt;

    @UpdateTimestamp
    @Column(name = "upd_dt")
    private LocalDateTime updDt;
}
