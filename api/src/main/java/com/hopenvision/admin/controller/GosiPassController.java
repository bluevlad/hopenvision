package com.hopenvision.admin.controller;

import com.hopenvision.admin.dto.GosiPassDto;
import com.hopenvision.admin.service.GosiPassService;
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

@Tag(name = "합격예측 - 정답 관리", description = "정답/합격선 조회 API")
@RestController
@RequestMapping("/api/gosi/pass")
@RequiredArgsConstructor
@Slf4j
public class GosiPassController {

    private final GosiPassService gosiPassService;

    @Operation(summary = "정답 목록 조회", description = "시험 정답 목록을 페이징으로 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<Page<GosiPassDto.PassMstResponse>>> getPassList(
            @Parameter(description = "시험코드") @RequestParam String gosiCd,
            @Parameter(description = "과목코드") @RequestParam(required = false) String subjectCd,
            @Parameter(description = "시험유형") @RequestParam(required = false) String examType,
            @Parameter(description = "페이지 번호") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "페이지 크기") @RequestParam(defaultValue = "20") int size
    ) {
        GosiPassDto.SearchRequest request = GosiPassDto.SearchRequest.builder()
                .gosiCd(gosiCd)
                .subjectCd(subjectCd)
                .examType(examType)
                .page(page)
                .size(size)
                .build();
        Page<GosiPassDto.PassMstResponse> result = gosiPassService.getPassList(request);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "합격선 조회", description = "시험 유형별 합격선을 조회합니다.")
    @GetMapping("/standards")
    public ResponseEntity<ApiResponse<List<GosiPassDto.PassStaResponse>>> getPassStaList(
            @Parameter(description = "시험코드") @RequestParam String gosiCd
    ) {
        List<GosiPassDto.PassStaResponse> result = gosiPassService.getPassStaList(gosiCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
}
