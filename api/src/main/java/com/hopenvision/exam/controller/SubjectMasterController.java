package com.hopenvision.exam.controller;

import com.hopenvision.exam.dto.ApiResponse;
import com.hopenvision.exam.dto.SubjectMasterDto;
import com.hopenvision.exam.service.SubjectMasterService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "과목 마스터 관리", description = "재사용 가능한 과목 마스터 데이터 관리 API")
@RestController
@RequestMapping("/api/subjects")
@RequiredArgsConstructor
@Slf4j
public class SubjectMasterController {

    private final SubjectMasterService subjectMasterService;

    @Operation(summary = "과목 목록 조회", description = "페이징 및 검색 조건으로 과목 목록을 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<Page<SubjectMasterDto.Response>>> getSubjectList(
            @Parameter(description = "검색어 (과목명, 과목코드)") @RequestParam(required = false) String keyword,
            @Parameter(description = "카테고리 (시험유형)") @RequestParam(required = false) String category,
            @Parameter(description = "사용여부") @RequestParam(required = false) String isUse,
            @Parameter(description = "페이지 번호 (0부터 시작)") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "페이지 크기") @RequestParam(defaultValue = "20") int size
    ) {
        SubjectMasterDto.SearchRequest request = SubjectMasterDto.SearchRequest.builder()
                .keyword(keyword)
                .category(category)
                .isUse(isUse)
                .page(page)
                .size(size)
                .build();

        Page<SubjectMasterDto.Response> result = subjectMasterService.getSubjectList(request);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "과목 트리 조회", description = "계층 구조로 과목을 조회합니다.")
    @GetMapping("/tree")
    public ResponseEntity<ApiResponse<List<SubjectMasterDto.TreeResponse>>> getSubjectTree(
            @Parameter(description = "카테고리 (시험유형)") @RequestParam(required = false) String category
    ) {
        List<SubjectMasterDto.TreeResponse> result = subjectMasterService.getSubjectTree(category);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "카테고리별 과목 목록", description = "카테고리별 사용 중인 과목 목록을 조회합니다. (드롭다운용)")
    @GetMapping("/by-category")
    public ResponseEntity<ApiResponse<List<SubjectMasterDto.Response>>> getSubjectsByCategory(
            @Parameter(description = "카테고리 (시험유형)") @RequestParam(required = false) String category
    ) {
        List<SubjectMasterDto.Response> result = subjectMasterService.getSubjectsByCategory(category);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "과목 상세 조회", description = "과목코드로 과목 상세 정보를 조회합니다.")
    @GetMapping("/{subjectCd}")
    public ResponseEntity<ApiResponse<SubjectMasterDto.Response>> getSubjectDetail(
            @Parameter(description = "과목코드") @PathVariable String subjectCd
    ) {
        SubjectMasterDto.Response result = subjectMasterService.getSubjectDetail(subjectCd);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "과목 등록", description = "새로운 과목을 등록합니다.")
    @PostMapping
    public ResponseEntity<ApiResponse<SubjectMasterDto.Response>> createSubject(
            @Valid @RequestBody SubjectMasterDto.Request request
    ) {
        SubjectMasterDto.Response result = subjectMasterService.createSubject(request);
        return ResponseEntity.ok(ApiResponse.success("과목이 등록되었습니다.", result));
    }

    @Operation(summary = "과목 수정", description = "기존 과목 정보를 수정합니다.")
    @PutMapping("/{subjectCd}")
    public ResponseEntity<ApiResponse<SubjectMasterDto.Response>> updateSubject(
            @Parameter(description = "과목코드") @PathVariable String subjectCd,
            @Valid @RequestBody SubjectMasterDto.Request request
    ) {
        SubjectMasterDto.Response result = subjectMasterService.updateSubject(subjectCd, request);
        return ResponseEntity.ok(ApiResponse.success("과목이 수정되었습니다.", result));
    }

    @Operation(summary = "과목 삭제", description = "과목을 삭제합니다. (시험에서 사용 중이면 삭제 불가)")
    @DeleteMapping("/{subjectCd}")
    public ResponseEntity<ApiResponse<Void>> deleteSubject(
            @Parameter(description = "과목코드") @PathVariable String subjectCd
    ) {
        subjectMasterService.deleteSubject(subjectCd);
        return ResponseEntity.ok(ApiResponse.success("과목이 삭제되었습니다.", null));
    }
}
