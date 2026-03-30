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
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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

    // ==================== CSV 응시결과 등록 ====================

    @Operation(summary = "CSV 응시결과 등록 미리보기",
            description = "CSV 파일을 파싱하여 매칭 결과를 미리보기합니다. DB 변경 없음.")
    @PostMapping(value = "/csv-result/preview", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<ApplicantDto.CsvResultImportResult>> previewCsvResult(
            @PathVariable String examCd,
            @RequestParam("file") MultipartFile file
    ) {
        validateCsvFile(file);
        ApplicantDto.CsvResultImportResult result = applicantService.previewCsvResult(file);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "CSV 응시결과 등록 적용",
            description = "CSV 파일을 파싱하여 응시자 및 답안을 등록하고 자동 채점합니다.")
    @PostMapping(value = "/csv-result/apply", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<ApplicantDto.CsvResultImportResult>> applyCsvResult(
            @PathVariable String examCd,
            @RequestParam("file") MultipartFile file
    ) {
        validateCsvFile(file);
        ApplicantDto.CsvResultImportResult result = applicantService.applyCsvResult(file);
        return ResponseEntity.ok(ApiResponse.success(
                "총 " + result.getImportedRows() + "건 등록 완료", result));
    }

    // ==================== 임시점수결과 등록 ====================

    @Operation(summary = "임시점수결과 등록 미리보기",
            description = "CSV 점수 파일로 무작위 답안을 생성하여 미리보기합니다. DB 변경 없음.")
    @PostMapping(value = "/temp-score/preview", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<ApplicantDto.CsvResultImportResult>> previewTempScore(
            @PathVariable String examCd,
            @RequestParam("file") MultipartFile file
    ) {
        validateCsvFile(file);
        ApplicantDto.CsvResultImportResult result = applicantService.previewTempScore(file);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "임시점수결과 등록 적용",
            description = "CSV 점수 파일로 무작위 답안을 생성하고 응시결과로 저장합니다.")
    @PostMapping(value = "/temp-score/apply", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<ApplicantDto.CsvResultImportResult>> applyTempScore(
            @PathVariable String examCd,
            @RequestParam("file") MultipartFile file
    ) {
        validateCsvFile(file);
        ApplicantDto.CsvResultImportResult result = applicantService.applyTempScore(file);
        return ResponseEntity.ok(ApiResponse.success(
                "총 " + result.getImportedRows() + "건 등록 완료", result));
    }

    private void validateCsvFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("파일이 비어있습니다.");
        }
        String filename = file.getOriginalFilename();
        if (filename == null || !filename.toLowerCase().endsWith(".csv")) {
            throw new IllegalArgumentException("CSV 파일만 업로드 가능합니다.");
        }
    }
}
