package com.hopenvision.exam.controller;

import com.hopenvision.exam.dto.ApiResponse;
import com.hopenvision.exam.dto.StatisticsDto;
import com.hopenvision.exam.service.ExcelExportService;
import com.hopenvision.exam.service.PdfExportService;
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
    private final PdfExportService pdfExportService;

    @Operation(summary = "시험 통계 조회", description = "시험의 전체 통계를 조회합니다.")
    @GetMapping("/exams/{examCd}")
    public ResponseEntity<ApiResponse<StatisticsDto.ExamStatistics>> getExamStatistics(
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        StatisticsDto.ExamStatistics result = statisticsService.getExamStatistics(examCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "성적 추이 조회", description = "사용자의 회차별 과목 점수 변화를 조회합니다.")
    @GetMapping("/trend")
    public ResponseEntity<ApiResponse<java.util.List<StatisticsDto.ScoreTrendItem>>> getScoreTrend(
            @Parameter(description = "사용자 ID") @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId
    ) {
        var result = statisticsService.getScoreTrend(userId);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "약점 과목 진단", description = "사용자의 과목별 정답률 기반 약점을 분석합니다.")
    @GetMapping("/exams/{examCd}/weakness")
    public ResponseEntity<ApiResponse<java.util.List<StatisticsDto.WeaknessAnalysis>>> getWeaknessAnalysis(
            @Parameter(description = "사용자 ID") @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId,
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        var result = statisticsService.getWeaknessAnalysis(userId, examCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "문항 변별력 분석", description = "과목별 문항의 변별력 지수를 산출합니다.")
    @GetMapping("/exams/{examCd}/subjects/{subjectCd}/discrimination")
    public ResponseEntity<ApiResponse<java.util.List<StatisticsDto.DiscriminationDetail>>> getDiscriminationIndex(
            @Parameter(description = "시험코드") @PathVariable String examCd,
            @Parameter(description = "과목코드") @PathVariable String subjectCd
    ) {
        var result = statisticsService.getDiscriminationIndex(examCd, subjectCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "응시 현황 대시보드", description = "사용 중인 시험들의 응시 현황을 조회합니다.")
    @GetMapping("/dashboard")
    public ResponseEntity<ApiResponse<java.util.List<StatisticsDto.ExamDashboardItem>>> getDashboard() {
        var result = statisticsService.getDashboard();
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "직렬별 통계", description = "시험의 직렬(applyArea)별 통계를 조회합니다.")
    @GetMapping("/exams/{examCd}/area")
    public ResponseEntity<ApiResponse<java.util.List<StatisticsDto.AreaStatistics>>> getAreaStatistics(
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        var result = statisticsService.getAreaStatistics(examCd);
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

    @Operation(summary = "성적표 PDF 다운로드", description = "개인 성적표를 PDF 파일로 다운로드합니다.")
    @GetMapping("/exams/{examCd}/pdf")
    public ResponseEntity<byte[]> exportPdf(
            @Parameter(description = "시험코드") @PathVariable String examCd,
            @Parameter(description = "사용자 ID") @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId
    ) throws IOException {
        byte[] pdfData = pdfExportService.generateScoreReport(userId, examCd);
        String fileName = URLEncoder.encode("성적표_" + examCd + "_" + userId + ".pdf", StandardCharsets.UTF_8);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                .contentType(MediaType.APPLICATION_PDF)
                .contentLength(pdfData.length)
                .body(pdfData);
    }

    @Operation(summary = "합격 예측", description = "현재 성적 기반 합격 가능성을 예측합니다.")
    @GetMapping("/exams/{examCd}/prediction")
    public ResponseEntity<ApiResponse<StatisticsDto.PassPrediction>> getPassPrediction(
            @Parameter(description = "사용자 ID") @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId,
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        var result = statisticsService.getPassPrediction(userId, examCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "오답 유형 분석", description = "사용자의 과목별 오답 패턴을 분석합니다.")
    @GetMapping("/exams/{examCd}/wrong-patterns")
    public ResponseEntity<ApiResponse<java.util.List<StatisticsDto.WrongAnswerPattern>>> getWrongAnswerPatterns(
            @Parameter(description = "사용자 ID") @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId,
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        var result = statisticsService.getWrongAnswerPatterns(userId, examCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
}
