package com.hopenvision.user.controller;

import com.hopenvision.exam.dto.ApiResponse;
import com.hopenvision.user.dto.HistoryDto;
import com.hopenvision.user.dto.ScoreAnalysisDto;
import com.hopenvision.user.dto.ScoringResultDto;
import com.hopenvision.user.dto.UserAnswerDto;
import com.hopenvision.user.dto.UserExamDto;
import com.hopenvision.user.service.ScoreAnalysisService;
import com.hopenvision.user.service.UserExamService;
import com.hopenvision.user.service.UserScoringService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
@Tag(name = "사용자 - 시험", description = "사용자용 시험 조회 및 채점 API")
public class UserExamController {

    private final UserExamService userExamService;
    private final UserScoringService userScoringService;
    private final ScoreAnalysisService scoreAnalysisService;

    @GetMapping("/exams")
    @Operation(summary = "채점 가능한 시험 목록 조회")
    public ApiResponse<List<UserExamDto>> getAvailableExams(
            @Parameter(description = "사용자 ID (임시)", example = "user001")
            @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId) {
        return ApiResponse.success(userExamService.getAvailableExams(userId));
    }

    @GetMapping("/exams/{examCd}")
    @Operation(summary = "시험 상세 조회")
    public ApiResponse<UserExamDto> getExamDetail(
            @Parameter(description = "사용자 ID (임시)")
            @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId,
            @PathVariable String examCd) {
        return ApiResponse.success(userExamService.getExamDetail(userId, examCd));
    }

    @PostMapping("/exams/{examCd}/submit")
    @Operation(summary = "답안 제출 및 채점")
    public ApiResponse<ScoringResultDto> submitAnswers(
            @Parameter(description = "사용자 ID (임시)")
            @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId,
            @PathVariable String examCd,
            @RequestBody UserAnswerDto.SubmitRequest request) {
        request.setExamCd(examCd);
        return ApiResponse.success(userScoringService.submitAndScore(userId, request));
    }

    @GetMapping("/exams/{examCd}/result")
    @Operation(summary = "내 채점 결과 조회")
    public ApiResponse<ScoringResultDto> getMyResult(
            @Parameter(description = "사용자 ID (임시)")
            @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId,
            @PathVariable String examCd) {
        return ApiResponse.success(userScoringService.getMyScore(userId, examCd));
    }

    @GetMapping("/exams/{examCd}/analysis")
    @Operation(summary = "성적 비교/분석 조회")
    public ApiResponse<ScoreAnalysisDto> getScoreAnalysis(
            @Parameter(description = "사용자 ID (임시)")
            @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId,
            @PathVariable String examCd) {
        return ApiResponse.success(scoreAnalysisService.getScoreAnalysis(userId, examCd));
    }

    @GetMapping("/history")
    @Operation(summary = "채점 이력 조회")
    public ApiResponse<List<HistoryDto.HistoryItem>> getUserHistory(
            @Parameter(description = "사용자 ID (임시)")
            @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId) {
        return ApiResponse.success(userExamService.getUserHistory(userId));
    }
}
