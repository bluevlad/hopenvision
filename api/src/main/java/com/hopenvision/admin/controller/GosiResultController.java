package com.hopenvision.admin.controller;

import com.hopenvision.admin.dto.GosiResultDto;
import com.hopenvision.admin.service.GosiResultService;
import com.hopenvision.exam.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "합격예측 - 성적 관리", description = "성적 목록/상세 조회 API")
@RestController
@RequestMapping("/api/gosi/results")
@RequiredArgsConstructor
@Slf4j
public class GosiResultController {

    private final GosiResultService gosiResultService;

    @Operation(summary = "성적 목록 조회", description = "성적 목록을 페이징으로 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<Page<GosiResultDto.RstMstResponse>>> getResultList(
            @Parameter(description = "시험코드") @RequestParam String gosiCd,
            @Parameter(description = "시험유형") @RequestParam(required = false) String gosiType,
            @Parameter(description = "지역") @RequestParam(required = false) String gosiArea,
            @Parameter(description = "검색어") @RequestParam(required = false) String keyword,
            @Parameter(description = "페이지 번호") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "페이지 크기") @RequestParam(defaultValue = "20") int size
    ) {
        GosiResultDto.SearchRequest request = GosiResultDto.SearchRequest.builder()
                .gosiCd(gosiCd)
                .gosiType(gosiType)
                .gosiArea(gosiArea)
                .keyword(keyword)
                .page(page)
                .size(size)
                .build();
        Page<GosiResultDto.RstMstResponse> result = gosiResultService.getResultList(request);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "성적 상세 조회", description = "성적 상세 정보를 조회합니다.")
    @GetMapping("/{gosiCd}/{rstNo}")
    public ResponseEntity<ApiResponse<GosiResultDto.RstDetailResponse>> getResultDetail(
            @Parameter(description = "시험코드") @PathVariable String gosiCd,
            @Parameter(description = "성적번호") @PathVariable String rstNo
    ) {
        GosiResultDto.RstDetailResponse result = gosiResultService.getResultDetail(gosiCd, rstNo);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
}
