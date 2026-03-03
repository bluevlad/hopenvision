package com.hopenvision.exam.controller;

import com.hopenvision.exam.dto.QuestionBankDto;
import com.hopenvision.exam.service.QuestionBankService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/question-bank")
@RequiredArgsConstructor
public class QuestionBankController {

    private final QuestionBankService questionBankService;

    // ==================== Group ====================

    @GetMapping("/groups")
    public ResponseEntity<Map<String, Object>> getGroupList(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String examYear,
            @RequestParam(required = false) String isUse,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        QuestionBankDto.GroupSearchRequest request = QuestionBankDto.GroupSearchRequest.builder()
                .keyword(keyword).category(category).examYear(examYear)
                .isUse(isUse).page(page).size(size).build();

        Page<QuestionBankDto.GroupResponse> result = questionBankService.getGroupList(request);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "data", result.getContent(),
                "totalElements", result.getTotalElements(),
                "totalPages", result.getTotalPages(),
                "page", result.getNumber(),
                "size", result.getSize()));
    }

    @GetMapping("/groups/{groupId}")
    public ResponseEntity<Map<String, Object>> getGroupDetail(@PathVariable Long groupId) {
        QuestionBankDto.GroupDetailResponse result = questionBankService.getGroupDetail(groupId);
        return ResponseEntity.ok(Map.of("success", true, "data", result));
    }

    @PostMapping("/groups")
    public ResponseEntity<Map<String, Object>> createGroup(
            @Valid @RequestBody QuestionBankDto.GroupRequest request) {
        QuestionBankDto.GroupResponse result = questionBankService.createGroup(request);
        return ResponseEntity.ok(Map.of("success", true, "data", result));
    }

    @PutMapping("/groups/{groupId}")
    public ResponseEntity<Map<String, Object>> updateGroup(
            @PathVariable Long groupId,
            @Valid @RequestBody QuestionBankDto.GroupRequest request) {
        QuestionBankDto.GroupResponse result = questionBankService.updateGroup(groupId, request);
        return ResponseEntity.ok(Map.of("success", true, "data", result));
    }

    @DeleteMapping("/groups/{groupId}")
    public ResponseEntity<Map<String, Object>> deleteGroup(@PathVariable Long groupId) {
        questionBankService.deleteGroup(groupId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    // ==================== Item ====================

    @GetMapping("/items")
    public ResponseEntity<Map<String, Object>> getItemList(
            @RequestParam(required = false) Long groupId,
            @RequestParam(required = false) String subjectCd,
            @RequestParam(required = false) String difficulty,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String isUse,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        QuestionBankDto.ItemSearchRequest request = QuestionBankDto.ItemSearchRequest.builder()
                .groupId(groupId).subjectCd(subjectCd).difficulty(difficulty)
                .keyword(keyword).isUse(isUse).page(page).size(size).build();

        Page<QuestionBankDto.ItemResponse> result = questionBankService.getItemList(request);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "data", result.getContent(),
                "totalElements", result.getTotalElements(),
                "totalPages", result.getTotalPages(),
                "page", result.getNumber(),
                "size", result.getSize()));
    }

    @GetMapping("/items/{itemId}")
    public ResponseEntity<Map<String, Object>> getItemDetail(@PathVariable Long itemId) {
        QuestionBankDto.ItemResponse result = questionBankService.getItemDetail(itemId);
        return ResponseEntity.ok(Map.of("success", true, "data", result));
    }

    @PostMapping("/items")
    public ResponseEntity<Map<String, Object>> createItem(
            @Valid @RequestBody QuestionBankDto.ItemRequest request) {
        QuestionBankDto.ItemResponse result = questionBankService.createItem(request);
        return ResponseEntity.ok(Map.of("success", true, "data", result));
    }

    @PutMapping("/items/{itemId}")
    public ResponseEntity<Map<String, Object>> updateItem(
            @PathVariable Long itemId,
            @Valid @RequestBody QuestionBankDto.ItemRequest request) {
        QuestionBankDto.ItemResponse result = questionBankService.updateItem(itemId, request);
        return ResponseEntity.ok(Map.of("success", true, "data", result));
    }

    @DeleteMapping("/items/{itemId}")
    public ResponseEntity<Map<String, Object>> deleteItem(@PathVariable Long itemId) {
        questionBankService.deleteItem(itemId);
        return ResponseEntity.ok(Map.of("success", true));
    }

    @PostMapping("/groups/{groupId}/bulk-import")
    public ResponseEntity<Map<String, Object>> bulkImportItems(
            @PathVariable Long groupId,
            @Valid @RequestBody QuestionBankDto.BulkImportRequest request) {
        List<QuestionBankDto.ItemResponse> result = questionBankService.bulkImportItems(groupId, request);
        return ResponseEntity.ok(Map.of("success", true, "data", result, "count", result.size()));
    }
}
