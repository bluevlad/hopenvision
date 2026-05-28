package com.hopenvision.board.controller;

import com.hopenvision.board.dto.BoardDetailDto;
import com.hopenvision.board.dto.BoardListItemDto;
import com.hopenvision.board.service.BoardService;
import com.hopenvision.exam.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/board")
@RequiredArgsConstructor
@Tag(name = "게시판", description = "공지·자료실·Q&A 조회 API (읽기 전용)")
public class BoardController {

    private final BoardService boardService;

    @GetMapping
    @Operation(summary = "게시글 목록 조회 (최상위 게시글, 공지 고정 우선)")
    public ApiResponse<Page<BoardListItemDto>> list(
            @Parameter(description = "제목 검색어") @RequestParam(required = false) String q,
            @PageableDefault(size = 20) Pageable pageable
    ) {
        return ApiResponse.success(boardService.list(q, pageable));
    }

    @GetMapping("/{id}")
    @Operation(summary = "게시글 상세 조회 (조회수 +1, 답글 포함)")
    public ApiResponse<BoardDetailDto> get(@PathVariable Long id) {
        return ApiResponse.success(boardService.get(id));
    }
}
