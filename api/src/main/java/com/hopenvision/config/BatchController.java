package com.hopenvision.config;

import com.hopenvision.exam.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "배치 관리", description = "통계 집계, 순위 계산, 배치 실행 API")
@RestController
@RequestMapping("/api/batch")
@RequiredArgsConstructor
public class BatchController {

    private final BatchService batchService;

    @Operation(summary = "시험별 배치 실행", description = "순위 계산, 백분위, 표준점수를 일괄 산출합니다.")
    @PostMapping("/exams/{examCd}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> runBatch(
            @Parameter(description = "시험코드") @PathVariable String examCd
    ) {
        Map<String, Object> result = batchService.runBatch(examCd);
        return ResponseEntity.ok(ApiResponse.success("배치가 완료되었습니다.", result));
    }

    @Operation(summary = "전체 배치 실행", description = "모든 사용 중인 시험에 대해 배치를 실행합니다.")
    @PostMapping("/run-all")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> runAllBatches() {
        List<Map<String, Object>> results = batchService.runAllBatches();
        return ResponseEntity.ok(ApiResponse.success("전체 배치가 완료되었습니다.", results));
    }

    @Operation(summary = "전체 순위 계산", description = "시험의 전체 순위를 재계산합니다.")
    @PostMapping("/exams/{examCd}/ranking")
    public ResponseEntity<ApiResponse<Map<String, Object>>> calculateRanking(
            @PathVariable String examCd
    ) {
        int count = batchService.calculateTotalRanking(examCd);
        return ResponseEntity.ok(ApiResponse.success("순위 계산 완료",
                Map.of("examCd", examCd, "updatedCount", count)));
    }

    @Operation(summary = "백분위 계산", description = "시험의 백분위를 재계산합니다.")
    @PostMapping("/exams/{examCd}/percentile")
    public ResponseEntity<ApiResponse<Map<String, Object>>> calculatePercentile(
            @PathVariable String examCd
    ) {
        int count = batchService.calculatePercentile(examCd);
        return ResponseEntity.ok(ApiResponse.success("백분위 계산 완료",
                Map.of("examCd", examCd, "updatedCount", count)));
    }
}
