package com.hopenvision.board.service;

import com.hopenvision.board.dto.BoardDetailDto;
import com.hopenvision.board.dto.BoardListItemDto;
import com.hopenvision.board.entity.Board;
import com.hopenvision.board.repository.BoardRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BoardService {

    private final BoardRepository boardRepository;

    @Transactional(readOnly = true)
    public Page<BoardListItemDto> list(String q, Pageable pageable) {
        return boardRepository.searchTopLevel(q, pageable).map(BoardListItemDto::from);
    }

    @Transactional
    public BoardDetailDto get(Long id) {
        Board board = boardRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "게시글을 찾을 수 없습니다"));
        boardRepository.incrementHits(id);
        List<Board> replies = boardRepository.findByParentBoardIdOrderByRegDtAscBoardIdAsc(id);
        return BoardDetailDto.from(board, replies);
    }
}
