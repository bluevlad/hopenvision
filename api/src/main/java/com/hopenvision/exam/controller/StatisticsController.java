package com.hopenvision.exam.controller;

import com.hopenvision.exam.dto.ApiResponse;
import com.hopenvision.exam.dto.StatisticsDto;
import com.hopenvision.exam.service.StatisticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "통계", description = "시험 통계 API")
@RestController
@RequestMapping("/api/statistics")
@RequiredArgsConstructor
@Slf4j
public class StatisticsController {

    private final StatisticsService statisticsService;

    @Operation(summary = "시험 통계 조회", description = "시험의 전체 통계를 조회합니다.")
    @GetMapping("/exams/{examCd}")
    public ResponseEntity<ApiResponse<StatisticsDto.ExamStatistics>> getExamStatistics(
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        StatisticsDto.ExamStatistics result = statisticsService.getExamStatistics(examCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
}
