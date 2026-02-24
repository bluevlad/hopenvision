package com.hopenvision.admin.controller;

import com.hopenvision.admin.dto.GosiMemberDto;
import com.hopenvision.admin.service.GosiMemberService;
import com.hopenvision.exam.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Tag(name = "합격예측 - 회원 관리", description = "회원 목록/상세 조회 API")
@RestController
@RequestMapping("/api/gosi/members")
@RequiredArgsConstructor
@Slf4j
public class GosiMemberController {

    private final GosiMemberService gosiMemberService;

    @Operation(summary = "회원 목록 조회", description = "회원 목록을 페이징으로 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<Page<GosiMemberDto.Response>>> getMemberList(
            @Parameter(description = "검색어") @RequestParam(required = false) String keyword,
            @Parameter(description = "페이지 번호") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "페이지 크기") @RequestParam(defaultValue = "20") int size
    ) {
        GosiMemberDto.SearchRequest request = GosiMemberDto.SearchRequest.builder()
                .keyword(keyword)
                .page(page)
                .size(size)
                .build();
        Page<GosiMemberDto.Response> result = gosiMemberService.getMemberList(request);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @Operation(summary = "회원 상세 조회", description = "회원 상세 정보를 조회합니다.")
    @GetMapping("/{userId}")
    public ResponseEntity<ApiResponse<GosiMemberDto.Response>> getMemberDetail(
            @Parameter(description = "사용자ID") @PathVariable String userId
    ) {
        GosiMemberDto.Response result = gosiMemberService.getMemberDetail(userId);
        return ResponseEntity.ok(ApiResponse.success(result));
    }
}
