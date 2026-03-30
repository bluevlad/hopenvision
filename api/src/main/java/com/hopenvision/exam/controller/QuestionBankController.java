package com.hopenvision.exam.controller;

import com.hopenvision.exam.dto.ApiResponse;
import com.hopenvision.exam.dto.QuestionBankDto;
import com.hopenvision.exam.service.QuestionBankService;
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

import java.util.List;

@Tag(name = "문제은행 관리", description = "문제은행 그룹 및 항목 관리 API")
@RestController
@RequestMapping("/api/question-bank")
@RequiredArgsConstructor
@Slf4j
public class QuestionBankController {

    private final QuestionBankService questionBankService;

    // ==================== 그룹 관리 ====================

    @Operation(summary = "그룹 목록 조회", description = "페이징 및 검색 조건으로 문제은행 그룹 목록을 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<Page<QuestionBankDto.GroupResponse>>> getGroupList(
            @Parameter(description = "검색어 (그룹명, 그룹코드)") @RequestParam(required = false) String keyword,
            @Parameter(description = "카테고리 (시험유형)") @RequestParam(required = false) String category,
            @Parameter(description = "출제연도") @RequestParam(required = false) String examYear,
            @Parameter(description = "출처") @RequestParam(required = false) String source,
            @Parameter(description = "사용여부") @RequestParam(required = false) String isUse,
            @Parameter(description = "페이지 번호 (0부터 시작)") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "페이지 크기") @RequestParam(defaultValue = "10") int size
    ) {
        QuestionBankDto.GroupSearchRequest request = QuestionBankDto.GroupSearchRequest.builder()
                .keyword(keyword)
                .category(category)
                .examYear(examYear)
                .source(source)
                .isUse(isUse)
                .page(page)
                .size(size)
                .build();

        Page<QuestionBankDto.GroupResponse> result = questionBankService.getGroupList(request);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "그룹 상세 조회", description = "문제은행 그룹 상세 정보를 조회합니다. (항목 포함)")
    @GetMapping("/{groupId}")
    public ResponseEntity<ApiResponse<QuestionBankDto.GroupDetailResponse>> getGroupDetail(
            @Parameter(description = "그룹 ID") @PathVariable Long groupId
    ) {
        QuestionBankDto.GroupDetailResponse result = questionBankService.getGroupDetail(groupId);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "그룹 등록", description = "새로운 문제은행 그룹을 등록합니다.")
    @PostMapping
    public ResponseEntity<ApiResponse<QuestionBankDto.GroupResponse>> createGroup(
            @Valid @RequestBody QuestionBankDto.GroupRequest request
    ) {
        QuestionBankDto.GroupResponse result = questionBankService.createGroup(request);
        return ResponseEntity.ok(ApiResponse.success("문제은행 그룹이 등록되었습니다.", result));
    }

    @Operation(summary = "그룹 수정", description = "기존 문제은행 그룹 정보를 수정합니다.")
    @PutMapping("/{groupId}")
    public ResponseEntity<ApiResponse<QuestionBankDto.GroupResponse>> updateGroup(
            @Parameter(description = "그룹 ID") @PathVariable Long groupId,
            @Valid @RequestBody QuestionBankDto.GroupRequest request
    ) {
        QuestionBankDto.GroupResponse result = questionBankService.updateGroup(groupId, request);
        return ResponseEntity.ok(ApiResponse.success("문제은행 그룹이 수정되었습니다.", result));
    }

    @Operation(summary = "그룹 삭제", description = "문제은행 그룹을 삭제합니다. (하위 항목도 함께 삭제)")
    @DeleteMapping("/{groupId}")
    public ResponseEntity<ApiResponse<Void>> deleteGroup(
            @Parameter(description = "그룹 ID") @PathVariable Long groupId
    ) {
        questionBankService.deleteGroup(groupId);
        return ResponseEntity.ok(ApiResponse.success("문제은행 그룹이 삭제되었습니다.", null));
    }

    // ==================== 항목 관리 ====================

    @Operation(summary = "항목 목록 조회", description = "그룹의 문제 항목 목록을 조회합니다.")
    @GetMapping("/{groupId}/items")
    public ResponseEntity<ApiResponse<List<QuestionBankDto.ItemResponse>>> getItemList(
            @Parameter(description = "그룹 ID") @PathVariable Long groupId,
            @Parameter(description = "과목코드 (선택)") @RequestParam(required = false) String subjectCd
    ) {
        List<QuestionBankDto.ItemResponse> result = questionBankService.getItemList(groupId, subjectCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "항목 등록", description = "문제은행 그룹에 새로운 문제 항목을 등록합니다.")
    @PostMapping("/{groupId}/items")
    public ResponseEntity<ApiResponse<QuestionBankDto.ItemResponse>> createItem(
            @Parameter(description = "그룹 ID") @PathVariable Long groupId,
            @Valid @RequestBody QuestionBankDto.ItemRequest request
    ) {
        QuestionBankDto.ItemResponse result = questionBankService.createItem(groupId, request);
        return ResponseEntity.ok(ApiResponse.success("문제가 등록되었습니다.", result));
    }

    @Operation(summary = "항목 수정", description = "문제은행 항목을 수정합니다.")
    @PutMapping("/{groupId}/items/{itemId}")
    public ResponseEntity<ApiResponse<QuestionBankDto.ItemResponse>> updateItem(
            @Parameter(description = "그룹 ID") @PathVariable Long groupId,
            @Parameter(description = "항목 ID") @PathVariable Long itemId,
            @Valid @RequestBody QuestionBankDto.ItemRequest request
    ) {
        QuestionBankDto.ItemResponse result = questionBankService.updateItem(groupId, itemId, request);
        return ResponseEntity.ok(ApiResponse.success("문제가 수정되었습니다.", result));
    }

    @Operation(summary = "항목 삭제", description = "문제은행 항목을 삭제합니다.")
    @DeleteMapping("/{groupId}/items/{itemId}")
    public ResponseEntity<ApiResponse<Void>> deleteItem(
            @Parameter(description = "그룹 ID") @PathVariable Long groupId,
            @Parameter(description = "항목 ID") @PathVariable Long itemId
    ) {
        questionBankService.deleteItem(groupId, itemId);
        return ResponseEntity.ok(ApiResponse.success("문제가 삭제되었습니다.", null));
    }

    // ==================== CSV 업데이트 ====================

    @Operation(summary = "CSV 정답/배점/난이도 업데이트 미리보기",
            description = "CSV 파일을 파싱하여 매칭 결과를 미리보기합니다. DB 변경 없음.")
    @PostMapping(value = "/csv-update/preview", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<QuestionBankDto.CsvUpdateResult>> previewCsvUpdate(
            @RequestParam("file") MultipartFile file
    ) {
        validateCsvFile(file);
        QuestionBankDto.CsvUpdateResult result = questionBankService.previewCsvUpdate(file);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "CSV 정답/배점/난이도 업데이트 적용",
            description = "CSV 파일을 파싱하여 매칭된 항목의 정답/배점/난이도를 업데이트합니다.")
    @PostMapping(value = "/csv-update/apply", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<QuestionBankDto.CsvUpdateResult>> applyCsvUpdate(
            @RequestParam("file") MultipartFile file
    ) {
        validateCsvFile(file);
        QuestionBankDto.CsvUpdateResult result = questionBankService.applyCsvUpdate(file);
        return ResponseEntity.ok(ApiResponse.success(
                "총 " + result.getUpdatedRows() + "건 업데이트 완료", result));
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

    // ==================== Excel 업데이트 ====================

    @Operation(summary = "Excel 정답/배점/난이도 업데이트 미리보기",
            description = "Excel 파일을 파싱하여 매칭 결과를 미리보기합니다. DB 변경 없음.")
    @PostMapping(value = "/excel-update/preview", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<QuestionBankDto.CsvUpdateResult>> previewExcelUpdate(
            @RequestParam("file") MultipartFile file
    ) {
        validateExcelFile(file);
        QuestionBankDto.CsvUpdateResult result = questionBankService.previewExcelUpdate(file);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "Excel 정답/배점/난이도 업데이트 적용",
            description = "Excel 파일을 파싱하여 매칭된 항목의 정답/배점/난이도를 업데이트합니다.")
    @PostMapping(value = "/excel-update/apply", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<QuestionBankDto.CsvUpdateResult>> applyExcelUpdate(
            @RequestParam("file") MultipartFile file
    ) {
        validateExcelFile(file);
        QuestionBankDto.CsvUpdateResult result = questionBankService.applyExcelUpdate(file);
        return ResponseEntity.ok(ApiResponse.success(
                "총 " + result.getUpdatedRows() + "건 업데이트 완료", result));
    }

    private void validateExcelFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("파일이 비어있습니다.");
        }
        String filename = file.getOriginalFilename();
        if (filename == null || !(filename.toLowerCase().endsWith(".xlsx") || filename.toLowerCase().endsWith(".xls"))) {
            throw new IllegalArgumentException("Excel 파일(.xlsx, .xls)만 업로드 가능합니다.");
        }
    }

    @Operation(summary = "항목 일괄 등록", description = "문제은행 그룹에 문제 항목을 일괄 등록합니다.")
    @PostMapping("/{groupId}/bulk-import")
    public ResponseEntity<ApiResponse<List<QuestionBankDto.ItemResponse>>> bulkImportItems(
            @Parameter(description = "그룹 ID") @PathVariable Long groupId,
            @Valid @RequestBody QuestionBankDto.BulkImportRequest request
    ) {
        List<QuestionBankDto.ItemResponse> result = questionBankService.bulkImportItems(groupId, request);
        return ResponseEntity.ok(ApiResponse.success("총 " + result.size() + "개 문제가 등록되었습니다.", result));
    }
}
