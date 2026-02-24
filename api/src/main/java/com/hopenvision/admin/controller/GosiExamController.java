package com.hopenvision.admin.controller;

import com.hopenvision.admin.dto.GosiExamDto;
import com.hopenvision.admin.service.GosiExamService;
import com.hopenvision.exam.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "합격예측 - 시험 관리", description = "시험/유형/지역 조회 API")
@RestController
@RequestMapping("/api/gosi/exams")
@RequiredArgsConstructor
@Slf4j
public class GosiExamController {

    private final GosiExamService gosiExamService;

    @Operation(summary = "시험 목록 조회", description = "합격예측 시험 목록을 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<List<GosiExamDto.MstResponse>>> getExamList() {
        List<GosiExamDto.MstResponse> result = gosiExamService.getExamList();
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "시험 상세 조회", description = "시험코드로 시험 상세 정보를 조회합니다.")
    @GetMapping("/{gosiCd}")
    public ResponseEntity<ApiResponse<GosiExamDto.MstResponse>> getExamDetail(
            @Parameter(description = "시험코드") @PathVariable String gosiCd
    ) {
        GosiExamDto.MstResponse result = gosiExamService.getExamDetail(gosiCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "시험 유형 목록 조회", description = "합격예측 시험 유형 코드를 조회합니다.")
    @GetMapping("/types")
    public ResponseEntity<ApiResponse<List<GosiExamDto.CodResponse>>> getTypeList() {
        List<GosiExamDto.CodResponse> result = gosiExamService.getTypeList();
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "지역 목록 조회", description = "시험 유형별 지역 목록을 조회합니다.")
    @GetMapping("/areas")
    public ResponseEntity<ApiResponse<List<GosiExamDto.AreaResponse>>> getAreaList(
            @Parameter(description = "시험유형") @RequestParam(required = false) String gosiType
    ) {
        List<GosiExamDto.AreaResponse> result = gosiExamService.getAreaList(gosiType);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
}
