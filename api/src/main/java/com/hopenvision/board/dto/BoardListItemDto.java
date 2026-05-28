package com.hopenvision.board.dto;

import com.hopenvision.board.entity.Board;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class BoardListItemDto {
    private Long boardId;
    private String subject;
    private LocalDateTime regDt;
    private Long hits;
    private String author;
    private String legacySource;
    private boolean noticeTop;
    private boolean hidden;

    public static BoardListItemDto from(Board b) {
        return BoardListItemDto.builder()
                .boardId(b.getBoardId())
                .subject(b.getSubject())
                .regDt(b.getRegDt())
                .hits(b.getHits())
                .author(b.resolveAuthor())
                .legacySource(b.getLegacySource())
                .noticeTop("Y".equalsIgnoreCase(b.getNoticeTopYn()))
                .hidden(!"Y".equalsIgnoreCase(b.getOpenYn()))
                .build();
    }
}
