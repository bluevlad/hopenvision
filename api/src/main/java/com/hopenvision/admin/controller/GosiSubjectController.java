package com.hopenvision.admin.controller;

import com.hopenvision.admin.dto.GosiSubjectDto;
import com.hopenvision.admin.dto.GosiVodDto;
import com.hopenvision.admin.service.GosiSubjectService;
import com.hopenvision.exam.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "합격예측 - 과목/VOD", description = "과목/VOD 조회 API")
@RestController
@RequestMapping("/api/gosi/subjects")
@RequiredArgsConstructor
@Slf4j
public class GosiSubjectController {

    private final GosiSubjectService gosiSubjectService;

    @Operation(summary = "과목 목록 조회", description = "시험 유형별 과목 목록을 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<List<GosiSubjectDto.Response>>> getSubjectList(
            @Parameter(description = "시험유형") @RequestParam(required = false) String gosiType
    ) {
        List<GosiSubjectDto.Response> result = gosiSubjectService.getSubjectList(gosiType);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "VOD 목록 조회", description = "VOD 목록을 페이징으로 조회합니다.")
    @GetMapping("/vods")
    public ResponseEntity<ApiResponse<Page<GosiVodDto.Response>>> getVodList(
            @Parameter(description = "시험코드") @RequestParam(required = false) String gosiCd,
            @Parameter(description = "검색어") @RequestParam(required = false) String keyword,
            @Parameter(description = "페이지 번호") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "페이지 크기") @RequestParam(defaultValue = "20") int size
    ) {
        GosiVodDto.SearchRequest request = GosiVodDto.SearchRequest.builder()
                .gosiCd(gosiCd)
                .keyword(keyword)
                .page(page)
                .size(size)
                .build();
        Page<GosiVodDto.Response> result = gosiSubjectService.getVodList(request);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
}
