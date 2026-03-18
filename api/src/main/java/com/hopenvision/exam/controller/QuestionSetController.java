package com.hopenvision.exam.controller;

import com.hopenvision.exam.dto.ApiResponse;
import com.hopenvision.exam.dto.QuestionSetDto;
import com.hopenvision.exam.service.QuestionSetService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Tag(name = "문제세트 관리", description = "과목별 문제세트 구성 및 시험 배치 API")
@RestController
@RequestMapping("/api/question-sets")
@RequiredArgsConstructor
@Slf4j
public class QuestionSetController {

    private final QuestionSetService questionSetService;

    // ==================== 세트 관리 ====================

    @Operation(summary = "세트 목록 조회", description = "페이징 및 검색 조건으로 문제세트 목록을 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<Page<QuestionSetDto.Response>>> getSetList(
            @Parameter(description = "검색어 (세트명, 세트코드)") @RequestParam(required = false) String keyword,
            @Parameter(description = "과목코드") @RequestParam(required = false) String subjectCd,
            @Parameter(description = "카테고리 (시험유형)") @RequestParam(required = false) String category,
            @Parameter(description = "사용여부") @RequestParam(required = false) String isUse,
            @Parameter(description = "페이지 번호 (0부터 시작)") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "페이지 크기") @RequestParam(defaultValue = "10") int size
    ) {
        QuestionSetDto.SearchRequest request = QuestionSetDto.SearchRequest.builder()
                .keyword(keyword)
                .subjectCd(subjectCd)
                .category(category)
                .isUse(isUse)
                .page(page)
                .size(size)
                .build();

        Page<QuestionSetDto.Response> result = questionSetService.getSetList(request);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "세트 상세 조회", description = "문제세트 상세 정보를 조회합니다. (항목 포함)")
    @GetMapping("/{setId}")
    public ResponseEntity<ApiResponse<QuestionSetDto.DetailResponse>> getSetDetail(
            @Parameter(description = "세트 ID") @PathVariable Long setId
    ) {
        QuestionSetDto.DetailResponse result = questionSetService.getSetDetail(setId);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "세트 등록", description = "새로운 문제세트를 등록합니다.")
    @PostMapping
    public ResponseEntity<ApiResponse<QuestionSetDto.Response>> createSet(
            @Valid @RequestBody QuestionSetDto.Request request
    ) {
        QuestionSetDto.Response result = questionSetService.createSet(request);
        return ResponseEntity.ok(ApiResponse.success("문제세트가 등록되었습니다.", result));
    }

    @Operation(summary = "세트 수정", description = "기존 문제세트 정보를 수정합니다.")
    @PutMapping("/{setId}")
    public ResponseEntity<ApiResponse<QuestionSetDto.Response>> updateSet(
            @Parameter(description = "세트 ID") @PathVariable Long setId,
            @Valid @RequestBody QuestionSetDto.Request request
    ) {
        QuestionSetDto.Response result = questionSetService.updateSet(setId, request);
        return ResponseEntity.ok(ApiResponse.success("문제세트가 수정되었습니다.", result));
    }

    @Operation(summary = "세트 삭제", description = "문제세트를 삭제합니다.")
    @DeleteMapping("/{setId}")
    public ResponseEntity<ApiResponse<Void>> deleteSet(
            @Parameter(description = "세트 ID") @PathVariable Long setId
    ) {
        questionSetService.deleteSet(setId);
        return ResponseEntity.ok(ApiResponse.success("문제세트가 삭제되었습니다.", null));
    }

    // ==================== 항목 관리 ====================

    @Operation(summary = "세트에 항목 추가", description = "문제세트에 문제은행 항목을 추가합니다.")
    @PostMapping("/{setId}/items")
    public ResponseEntity<ApiResponse<QuestionSetDto.ItemResponse>> addItem(
            @Parameter(description = "세트 ID") @PathVariable Long setId,
            @Valid @RequestBody QuestionSetDto.ItemRequest request
    ) {
        QuestionSetDto.ItemResponse result = questionSetService.addItem(setId, request);
        return ResponseEntity.ok(ApiResponse.success("항목이 추가되었습니다.", result));
    }

    @Operation(summary = "세트 항목 수정", description = "문제세트 항목(문항번호, 배점, 순서)을 수정합니다.")
    @PutMapping("/{setId}/items/{setItemId}")
    public ResponseEntity<ApiResponse<QuestionSetDto.ItemResponse>> updateItem(
            @Parameter(description = "세트 ID") @PathVariable Long setId,
            @Parameter(description = "세트 항목 ID") @PathVariable Long setItemId,
            @Valid @RequestBody QuestionSetDto.ItemRequest request
    ) {
        QuestionSetDto.ItemResponse result = questionSetService.updateItem(setId, setItemId, request);
        return ResponseEntity.ok(ApiResponse.success("항목이 수정되었습니다.", result));
    }

    @Operation(summary = "세트에서 항목 제거", description = "문제세트에서 항목을 제거합니다.")
    @DeleteMapping("/{setId}/items/{setItemId}")
    public ResponseEntity<ApiResponse<Void>> removeItem(
            @Parameter(description = "세트 ID") @PathVariable Long setId,
            @Parameter(description = "세트 항목 ID") @PathVariable Long setItemId
    ) {
        questionSetService.removeItem(setId, setItemId);
        return ResponseEntity.ok(ApiResponse.success("항목이 제거되었습니다.", null));
    }

    // ==================== 시험 배치 ====================

    @Operation(summary = "시험에 배치", description = "문제세트를 시험에 배치합니다. (해당 과목의 기존 문제/정답을 교체)")
    @PostMapping("/{setId}/deploy/{examCd}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> deployToExam(
            @Parameter(description = "세트 ID") @PathVariable Long setId,
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        int count = questionSetService.deployToExam(setId, examCd);
        return ResponseEntity.ok(ApiResponse.success("시험에 배치되었습니다.",
                Map.of("deployedCount", count, "examCd", examCd)));
    }
}
