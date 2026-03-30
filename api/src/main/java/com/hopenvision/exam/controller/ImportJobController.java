package com.hopenvision.exam.controller;

import com.hopenvision.exam.dto.ApiResponse;
import com.hopenvision.exam.entity.ImportJob;
import com.hopenvision.exam.service.ImportJobService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@Tag(name = "Import Job 관리", description = "비동기 파일 처리 Job 관리 API")
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@Slf4j
public class ImportJobController {

    private final ImportJobService importJobService;

    @Operation(summary = "임시점수결과 파일 업로드",
            description = "CSV 파일을 업로드하고 비동기 처리를 시작합니다. jobId를 즉시 반환합니다.")
    @PostMapping(value = "/exams/{examCd}/jobs/temp-score", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<Map<String, Object>>> uploadTempScore(
            @Parameter(description = "시험코드") @PathVariable String examCd,
            @RequestParam("file") MultipartFile file
    ) {
        validateCsvFile(file);
        ImportJob job = importJobService.uploadAndCreateJob(examCd, "TEMP_SCORE", file);

        // 비동기 처리 시작
        importJobService.processTempScoreAsync(job.getJobId());

        return ResponseEntity.ok(ApiResponse.success("파일 업로드 완료. 비동기 처리를 시작합니다.", Map.of(
                "jobId", job.getJobId(),
                "status", job.getStatus(),
                "fileName", job.getFileName()
        )));
    }

    @Operation(summary = "성적채점 시작",
            description = "시험별 응시자 총점/평균/순위를 비동기로 계산합니다.")
    @PostMapping("/exams/{examCd}/jobs/scoring")
    public ResponseEntity<ApiResponse<Map<String, Object>>> startScoring(
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        ImportJob job = importJobService.createScoringJob(examCd);
        importJobService.processScoringAsync(job.getJobId());

        return ResponseEntity.ok(ApiResponse.success("성적채점을 시작합니다.", Map.of(
                "jobId", job.getJobId(),
                "status", job.getStatus(),
                "examCd", examCd
        )));
    }

    @Operation(summary = "Job 상태 조회")
    @GetMapping("/jobs/{jobId}")
    public ResponseEntity<ApiResponse<ImportJob>> getJobStatus(
            @Parameter(description = "Job ID") @PathVariable String jobId
    ) {
        ImportJob job = importJobService.getJob(jobId);
        return ResponseEntity.ok(ApiResponse.success(job));
    }

    @Operation(summary = "시험별 Job 목록 조회")
    @GetMapping("/exams/{examCd}/jobs")
    public ResponseEntity<ApiResponse<List<ImportJob>>> getJobList(
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        List<ImportJob> jobs = importJobService.getJobList(examCd);
        return ResponseEntity.ok(ApiResponse.success(jobs));
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
