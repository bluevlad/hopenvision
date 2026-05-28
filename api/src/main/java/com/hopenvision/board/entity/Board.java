package com.hopenvision.board.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "tb_board")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Board {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "board_id")
    private Long boardId;

    @Column(name = "subject", length = 200)
    private String subject;

    @Column(name = "content", columnDefinition = "text")
    private String content;

    @Column(name = "answer", columnDefinition = "text")
    private String answer;

    @Column(name = "reg_dt")
    private LocalDateTime regDt;

    @Column(name = "upd_dt")
    private LocalDateTime updDt;

    @Column(name = "reg_id", length = 30)
    private String regId;

    @Column(name = "upd_id", length = 30)
    private String updId;

    @Column(name = "hits")
    private Long hits;

    @Column(name = "is_use", length = 1)
    private String isUse;

    @Column(name = "open_yn", length = 1)
    private String openYn;

    @Column(name = "notice_top_yn", length = 1)
    private String noticeTopYn;

    @Column(name = "recommend", length = 1)
    private String recommend;

    @Column(name = "parent_board_id")
    private Long parentBoardId;

    @Column(name = "legacy_board_seq", length = 20, nullable = false)
    private String legacyBoardSeq;

    @Column(name = "legacy_source", length = 20, nullable = false)
    private String legacySource;

    @Column(name = "legacy_parent_seq", length = 20)
    private String legacyParentSeq;

    @Column(name = "createname", length = 30)
    private String createname;

    @Column(name = "create_name", length = 30)
    private String createName;

    public String resolveAuthor() {
        if (createname != null && !createname.isBlank()) return createname;
        if (createName != null && !createName.isBlank()) return createName;
        return regId;
    }
}
