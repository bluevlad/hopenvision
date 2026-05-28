package com.hopenvision.board.repository;

import com.hopenvision.board.entity.Board;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BoardRepository extends JpaRepository<Board, Long> {

    @Query("SELECT b FROM Board b " +
           "WHERE b.parentBoardId IS NULL " +
           "AND (:q IS NULL OR :q = '' OR LOWER(b.subject) LIKE LOWER(CONCAT('%', :q, '%'))) " +
           "ORDER BY CASE WHEN b.noticeTopYn = 'Y' THEN 0 ELSE 1 END, b.regDt DESC NULLS LAST, b.boardId DESC")
    Page<Board> searchTopLevel(@Param("q") String q, Pageable pageable);

    List<Board> findByParentBoardIdOrderByRegDtAscBoardIdAsc(Long parentBoardId);

    @Modifying
    @Query("UPDATE Board b SET b.hits = COALESCE(b.hits, 0) + 1 WHERE b.boardId = :id")
    int incrementHits(@Param("id") Long id);
}
