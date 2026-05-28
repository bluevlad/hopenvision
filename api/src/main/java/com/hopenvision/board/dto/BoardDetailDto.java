package com.hopenvision.board.dto;

import com.hopenvision.board.entity.Board;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Builder
public class BoardDetailDto {
    private Long boardId;
    private String subject;
    private String content;
    private String answer;
    private LocalDateTime regDt;
    private LocalDateTime updDt;
    private Long hits;
    private String author;
    private String legacySource;
    private boolean noticeTop;
    private boolean hidden;
    private List<Reply> replies;

    public static BoardDetailDto from(Board b, List<Board> replyEntities) {
        return BoardDetailDto.builder()
                .boardId(b.getBoardId())
                .subject(b.getSubject())
                .content(b.getContent())
                .answer(b.getAnswer())
                .regDt(b.getRegDt())
                .updDt(b.getUpdDt())
                .hits(b.getHits())
                .author(b.resolveAuthor())
                .legacySource(b.getLegacySource())
                .noticeTop("Y".equalsIgnoreCase(b.getNoticeTopYn()))
                .hidden(!"Y".equalsIgnoreCase(b.getOpenYn()))
                .replies(replyEntities.stream().map(Reply::from).toList())
                .build();
    }

    @Getter
    @Builder
    public static class Reply {
        private Long boardId;
        private String subject;
        private String content;
        private LocalDateTime regDt;
        private String author;

        public static Reply from(Board b) {
            return Reply.builder()
                    .boardId(b.getBoardId())
                    .subject(b.getSubject())
                    .content(b.getContent())
                    .regDt(b.getRegDt())
                    .author(b.resolveAuthor())
                    .build();
        }
    }
}
