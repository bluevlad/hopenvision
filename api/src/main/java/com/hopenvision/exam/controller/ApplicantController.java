package com.hopenvision.exam.controller;

import com.hopenvision.exam.dto.ApiResponse;
import com.hopenvision.exam.dto.ApplicantDto;
import com.hopenvision.exam.service.ApplicantService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "응시자 관리", description = "응시자 CRUD API")
@RestController
@RequestMapping("/api/exams/{examCd}/applicants")
@RequiredArgsConstructor
@Slf4j
public class ApplicantController {

    private final ApplicantService applicantService;

    @Operation(summary = "응시자 목록 조회", description = "시험별 응시자 목록을 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<Page<ApplicantDto.Response>>> getApplicantList(
            @Parameter(description = "시험코드") @PathVariable String examCd,
            @Parameter(description = "검색어 (이름, 수험번호)") @RequestParam(required = false) String keyword,
            @Parameter(description = "페이지 번호") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "페이지 크기") @RequestParam(defaultValue = "10") int size
    ) {
        ApplicantDto.SearchRequest request = ApplicantDto.SearchRequest.builder()
                .examCd(examCd)
                .keyword(keyword)
                .page(page)
                .size(size)
                .build();

        Page<ApplicantDto.Response> result = applicantService.getApplicantList(request);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "응시자 상세 조회")
    @GetMapping("/{applicantNo}")
    public ResponseEntity<ApiResponse<ApplicantDto.Response>> getApplicant(
            @Parameter(description = "시험코드") @PathVariable String examCd,
            @Parameter(description = "수험번호") @PathVariable String applicantNo
    ) {
        ApplicantDto.Response result = applicantService.getApplicant(examCd, applicantNo);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "응시자 등록")
    @PostMapping
    public ResponseEntity<ApiResponse<ApplicantDto.Response>> createApplicant(
            @Parameter(description = "시험코드") @PathVariable String examCd,
            @Valid @RequestBody ApplicantDto.Request request
    ) {
        ApplicantDto.Response result = applicantService.createApplicant(examCd, request);
        return ResponseEntity.ok(ApiResponse.success("응시자가 등록되었습니다.", result));
    }

    @Operation(summary = "응시자 수정")
    @PutMapping("/{applicantNo}")
    public ResponseEntity<ApiResponse<ApplicantDto.Response>> updateApplicant(
            @Parameter(description = "시험코드") @PathVariable String examCd,
            @Parameter(description = "수험번호") @PathVariable String applicantNo,
            @Valid @RequestBody ApplicantDto.Request request
    ) {
        ApplicantDto.Response result = applicantService.updateApplicant(examCd, applicantNo, request);
        return ResponseEntity.ok(ApiResponse.success("응시자가 수정되었습니다.", result));
    }

    @Operation(summary = "응시자 삭제")
    @DeleteMapping("/{applicantNo}")
    public ResponseEntity<ApiResponse<Void>> deleteApplicant(
            @Parameter(description = "시험코드") @PathVariable String examCd,
            @Parameter(description = "수험번호") @PathVariable String applicantNo
    ) {
        applicantService.deleteApplicant(examCd, applicantNo);
        return ResponseEntity.ok(ApiResponse.success("응시자가 삭제되었습니다.", null));
    }
}
