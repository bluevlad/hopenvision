package com.hopenvision.exam.controller;

import com.hopenvision.exam.dto.ApiResponse;
import com.hopenvision.exam.dto.StatisticsDto;
import com.hopenvision.exam.service.ExcelExportService;
import com.hopenvision.exam.service.StatisticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Tag(name = "통계", description = "시험 통계 API")
@RestController
@RequestMapping("/api/statistics")
@RequiredArgsConstructor
@Slf4j
public class StatisticsController {

    private final StatisticsService statisticsService;
    private final ExcelExportService excelExportService;

    @Operation(summary = "시험 통계 조회", description = "시험의 전체 통계를 조회합니다.")
    @GetMapping("/exams/{examCd}")
    public ResponseEntity<ApiResponse<StatisticsDto.ExamStatistics>> getExamStatistics(
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        StatisticsDto.ExamStatistics result = statisticsService.getExamStatistics(examCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "문항별 정답률 통계", description = "과목별 문항의 정답률, 선택지 분포, 난이도를 조회합니다.")
    @GetMapping("/exams/{examCd}/questions")
    public ResponseEntity<ApiResponse<java.util.List<StatisticsDto.QuestionStatistics>>> getQuestionStatistics(
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        var result = statisticsService.getQuestionStatistics(examCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "성적 Excel 내보내기", description = "시험 성적 데이터를 Excel 파일로 다운로드합니다.")
    @GetMapping("/exams/{examCd}/export")
    public ResponseEntity<byte[]> exportScores(
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) throws IOException {
        byte[] excelData = excelExportService.exportScores(examCd);
        String fileName = URLEncoder.encode("성적_" + examCd + ".xlsx", StandardCharsets.UTF_8);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .contentLength(excelData.length)
                .body(excelData);
    }
}
