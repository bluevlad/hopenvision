package com.hopenvision.exam.controller;

import com.hopenvision.exam.dto.ApiResponse;
import com.hopenvision.exam.dto.NoticeDto;
import com.hopenvision.exam.entity.ExamNotice;
import com.hopenvision.exam.repository.ExamNoticeRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@Tag(name = "공지사항", description = "시험별 공지사항 관리 API")
@RestController
@RequestMapping("/api/exams/{examCd}/notices")
@RequiredArgsConstructor
public class NoticeController {

    private final ExamNoticeRepository noticeRepository;

    @Operation(summary = "공지사항 목록 조회")
    @GetMapping
    public ResponseEntity<ApiResponse<List<NoticeDto.Response>>> getNotices(
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        List<NoticeDto.Response> result = noticeRepository
                .findByExamCdOrderByIsPinnedDescRegDtDesc(examCd)
                .stream().map(this::toResponse).collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "사용 중인 공지사항 목록 (사용자용)")
    @GetMapping("/active")
    public ResponseEntity<ApiResponse<List<NoticeDto.Response>>> getActiveNotices(
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        List<NoticeDto.Response> result = noticeRepository
                .findByExamCdAndIsUseOrderByIsPinnedDescRegDtDesc(examCd, "Y")
                .stream().map(this::toResponse).collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "공지사항 등록")
    @PostMapping
    public ResponseEntity<ApiResponse<NoticeDto.Response>> createNotice(
            @Parameter(description = "시험코드") @PathVariable String examCd,
            @Valid @RequestBody NoticeDto.Request request
    ) {
        ExamNotice notice = ExamNotice.builder()
                .examCd(examCd)
                .title(request.getTitle())
                .content(request.getContent())
                .isPinned(request.getIsPinned() != null ? request.getIsPinned() : "N")
                .isUse(request.getIsUse() != null ? request.getIsUse() : "Y")
                .build();
        return ResponseEntity.ok(ApiResponse.success("공지사항이 등록되었습니다.", toResponse(noticeRepository.save(notice))));
    }

    @Operation(summary = "공지사항 수정")
    @PutMapping("/{noticeId}")
    public ResponseEntity<ApiResponse<NoticeDto.Response>> updateNotice(
            @PathVariable String examCd,
            @PathVariable Long noticeId,
            @Valid @RequestBody NoticeDto.Request request
    ) {
        ExamNotice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new EntityNotFoundException("공지사항을 찾을 수 없습니다."));
        notice.setTitle(request.getTitle());
        notice.setContent(request.getContent());
        if (request.getIsPinned() != null) notice.setIsPinned(request.getIsPinned());
        if (request.getIsUse() != null) notice.setIsUse(request.getIsUse());
        return ResponseEntity.ok(ApiResponse.success("공지사항이 수정되었습니다.", toResponse(noticeRepository.save(notice))));
    }

    @Operation(summary = "공지사항 삭제")
    @DeleteMapping("/{noticeId}")
    public ResponseEntity<ApiResponse<Void>> deleteNotice(
            @PathVariable String examCd,
            @PathVariable Long noticeId
    ) {
        noticeRepository.deleteById(noticeId);
        return ResponseEntity.ok(ApiResponse.success("공지사항이 삭제되었습니다.", null));
    }

    private NoticeDto.Response toResponse(ExamNotice n) {
        return NoticeDto.Response.builder()
                .noticeId(n.getNoticeId())
                .examCd(n.getExamCd())
                .title(n.getTitle())
                .content(n.getContent())
                .isPinned(n.getIsPinned())
                .isUse(n.getIsUse())
                .regDt(n.getRegDt())
                .updDt(n.getUpdDt())
                .build();
    }
}
