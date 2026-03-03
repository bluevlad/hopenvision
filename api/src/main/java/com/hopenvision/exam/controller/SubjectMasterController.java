package com.hopenvision.exam.controller;

import com.hopenvision.exam.dto.SubjectMasterDto;
import com.hopenvision.exam.service.SubjectMasterService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/subjects")
@RequiredArgsConstructor
public class SubjectMasterController {

    private final SubjectMasterService subjectMasterService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getSubjectList(
            @RequestParam(required = false) String category) {
        List<SubjectMasterDto.Response> subjects = subjectMasterService.getSubjectList(category);
        return ResponseEntity.ok(Map.of("success", true, "data", subjects));
    }

    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchSubjects(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String isUse,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        SubjectMasterDto.SearchRequest request = SubjectMasterDto.SearchRequest.builder()
                .keyword(keyword).category(category).isUse(isUse)
                .page(page).size(size).build();

        Page<SubjectMasterDto.Response> result = subjectMasterService.searchSubjects(request);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "data", result.getContent(),
                "totalElements", result.getTotalElements(),
                "totalPages", result.getTotalPages(),
                "page", result.getNumber(),
                "size", result.getSize()));
    }

    @GetMapping("/{subjectCd}")
    public ResponseEntity<Map<String, Object>> getSubjectDetail(@PathVariable String subjectCd) {
        SubjectMasterDto.Response subject = subjectMasterService.getSubjectDetail(subjectCd);
        return ResponseEntity.ok(Map.of("success", true, "data", subject));
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createSubject(
            @Valid @RequestBody SubjectMasterDto.Request request) {
        SubjectMasterDto.Response result = subjectMasterService.createSubject(request);
        return ResponseEntity.ok(Map.of("success", true, "data", result));
    }

    @PutMapping("/{subjectCd}")
    public ResponseEntity<Map<String, Object>> updateSubject(
            @PathVariable String subjectCd,
            @Valid @RequestBody SubjectMasterDto.Request request) {
        SubjectMasterDto.Response result = subjectMasterService.updateSubject(subjectCd, request);
        return ResponseEntity.ok(Map.of("success", true, "data", result));
    }

    @DeleteMapping("/{subjectCd}")
    public ResponseEntity<Map<String, Object>> deleteSubject(@PathVariable String subjectCd) {
        subjectMasterService.deleteSubject(subjectCd);
        return ResponseEntity.ok(Map.of("success", true));
    }
}
