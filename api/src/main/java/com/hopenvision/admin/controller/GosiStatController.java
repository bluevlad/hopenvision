package com.hopenvision.admin.controller;

import com.hopenvision.admin.dto.GosiStatDto;
import com.hopenvision.admin.service.GosiStatService;
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

@Tag(name = "합격예측 - 통계", description = "통계 조회/대시보드 API")
@RestController
@RequestMapping("/api/gosi/statistics")
@RequiredArgsConstructor
@Slf4j
public class GosiStatController {

    private final GosiStatService gosiStatService;

    @Operation(summary = "통계 목록 조회", description = "통계 목록을 페이징으로 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<Page<GosiStatDto.StatMstResponse>>> getStatList(
            @Parameter(description = "시험코드") @RequestParam String gosiCd,
            @Parameter(description = "시험유형") @RequestParam(required = false) String gosiType,
            @Parameter(description = "페이지 번호") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "페이지 크기") @RequestParam(defaultValue = "20") int size
    ) {
        GosiStatDto.SearchRequest request = GosiStatDto.SearchRequest.builder()
                .gosiCd(gosiCd)
                .gosiType(gosiType)
                .page(page)
                .size(size)
                .build();
        Page<GosiStatDto.StatMstResponse> result = gosiStatService.getStatList(request);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "대시보드 조회", description = "시험 전체 통계를 조회합니다.")
    @GetMapping("/dashboard")
    public ResponseEntity<ApiResponse<List<GosiStatDto.StatMstResponse>>> getDashboard(
            @Parameter(description = "시험코드") @RequestParam String gosiCd
    ) {
        List<GosiStatDto.StatMstResponse> result = gosiStatService.getDashboard(gosiCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "과목 구분 목록 조회", description = "시험별 과목 구분 목록을 조회합니다.")
    @GetMapping("/subjects")
    public ResponseEntity<ApiResponse<List<GosiStatDto.SbjMstResponse>>> getSbjMstList(
            @Parameter(description = "시험코드") @RequestParam String gosiCd
    ) {
        List<GosiStatDto.SbjMstResponse> result = gosiStatService.getSbjMstList(gosiCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    // === 성적 분석 ===

    @Operation(summary = "점수 분포 조회", description = "시험별 점수 분포를 10점 구간으로 조회합니다.")
    @GetMapping("/analytics/score-distribution")
    public ResponseEntity<ApiResponse<List<GosiStatDto.ScoreDistributionResponse>>> getScoreDistribution(
            @Parameter(description = "시험코드", required = true) @RequestParam String gosiCd,
            @Parameter(description = "시험유형") @RequestParam(required = false) String gosiType,
            @Parameter(description = "지역") @RequestParam(required = false) String gosiArea
    ) {
        List<GosiStatDto.ScoreDistributionResponse> result = gosiStatService.getScoreDistribution(gosiCd, gosiType, gosiArea);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "년도별 추이 조회", description = "년도별 평균점수와 합격률 추이를 조회합니다.")
    @GetMapping("/analytics/yearly-trend")
    public ResponseEntity<ApiResponse<List<GosiStatDto.YearlyTrendResponse>>> getYearlyTrend(
            @Parameter(description = "시험유형") @RequestParam(required = false) String gosiType
    ) {
        List<GosiStatDto.YearlyTrendResponse> result = gosiStatService.getYearlyTrend(gosiType);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "과목별 성적 비교", description = "시험별 과목별 평균/최고/최저 점수를 비교합니다.")
    @GetMapping("/analytics/subject-comparison")
    public ResponseEntity<ApiResponse<List<GosiStatDto.SubjectScoreResponse>>> getSubjectComparison(
            @Parameter(description = "시험코드", required = true) @RequestParam String gosiCd
    ) {
        List<GosiStatDto.SubjectScoreResponse> result = gosiStatService.getSubjectScoreComparison(gosiCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "지역별 성적 비교", description = "시험별 지역별 평균점수와 합격률을 비교합니다.")
    @GetMapping("/analytics/area-comparison")
    public ResponseEntity<ApiResponse<List<GosiStatDto.AreaScoreResponse>>> getAreaComparison(
            @Parameter(description = "시험코드", required = true) @RequestParam String gosiCd,
            @Parameter(description = "시험유형") @RequestParam(required = false) String gosiType
    ) {
        List<GosiStatDto.AreaScoreResponse> result = gosiStatService.getAreaScoreComparison(gosiCd, gosiType);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
}
