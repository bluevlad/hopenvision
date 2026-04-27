package com.hopenvision.exam.service;

import com.hopenvision.exam.entity.ImportJob;
import com.hopenvision.exam.repository.ImportJobRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.FileReader;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class ImportJobService {

    private final ImportJobRepository jobRepository;
    private final ImportJobProcessor jobProcessor;

    private static final String UPLOAD_DIR = "/data/hopenvision/upload";
    private static final Random RANDOM = new Random();

    // ==================== Job 관리 ====================

    /**
     * 파일 업로드 → 저장 → Job 등록 → 즉시 jobId 반환
     */
    @Transactional
    public ImportJob uploadAndCreateJob(String examCd, String jobType, MultipartFile file) {
        // 1) 파일 해시 계산
        String fileHash = computeFileHash(file);

        // 2) 중복 체크 (PENDING 또는 PROCESSING 상태)
        Optional<ImportJob> existing = jobRepository.findByFileHashAndStatusIn(
                fileHash, List.of("PENDING", "PROCESSING"));
        if (existing.isPresent()) {
            ImportJob ej = existing.get();
            throw new IllegalArgumentException(
                    "동일한 파일이 처리 중입니다 (jobId: " + ej.getJobId() + ", status: " + ej.getStatus() + ")");
        }

        // 이미 완료된 동일 파일
        Optional<ImportJob> completed = jobRepository.findByFileHashAndStatusIn(
                fileHash, List.of("COMPLETED"));
        if (completed.isPresent()) {
            throw new IllegalArgumentException(
                    "이미 등록된 파일입니다 (jobId: " + completed.get().getJobId() + ")");
        }

        // 3) 파일 저장
        String savedPath = saveFile(file, jobType);

        // 4) Job 생성
        String jobId = UUID.randomUUID().toString();
        ImportJob job = ImportJob.builder()
                .jobId(jobId)
                .fileName(file.getOriginalFilename())
                .fileHash(fileHash)
                .filePath(savedPath)
                .jobType(jobType)
                .examCd(examCd)
                .status("PENDING")
                .build();

        return jobRepository.save(job);
    }

    public ImportJob getJob(String jobId) {
        return jobRepository.findById(jobId)
                .orElseThrow(() -> new IllegalArgumentException("Job을 찾을 수 없습니다: " + jobId));
    }

    public List<ImportJob> getJobList(String examCd) {
        return jobRepository.findByExamCdOrderByRegDtDesc(examCd);
    }

    /**
     * 성적채점 Job 생성 (파일 없음, 버튼 트리거)
     */
    @Transactional
    public ImportJob createScoringJob(String examCd) {
        // 중복 체크: 동일 시험에 PROCESSING 중인 SCORING Job 존재 여부
        String scoringHash = "SCORING:" + examCd;
        Optional<ImportJob> existing = jobRepository.findByFileHashAndStatusIn(
                scoringHash, List.of("PENDING", "PROCESSING"));
        if (existing.isPresent()) {
            throw new IllegalArgumentException(
                    "해당 시험의 채점이 진행 중입니다 (jobId: " + existing.get().getJobId() + ")");
        }

        // 이전 완료 Job의 해시 삭제 (재채점 허용)
        jobRepository.findByFileHashAndStatusIn(scoringHash, List.of("COMPLETED", "FAILED"))
                .ifPresent(old -> {
                    old.setFileHash(old.getFileHash() + ":" + old.getJobId().substring(0, 8));
                    jobRepository.save(old);
                });

        String jobId = UUID.randomUUID().toString();
        ImportJob job = ImportJob.builder()
                .jobId(jobId)
                .fileName("성적채점: " + examCd)
                .fileHash(scoringHash)
                .jobType("SCORING")
                .examCd(examCd)
                .status("PENDING")
                .build();

        return jobRepository.save(job);
    }

    // ==================== 비동기 처리 ====================

    @Async("importJobExecutor")
    public void processTempScoreAsync(String jobId) {
        ImportJob job = jobRepository.findById(jobId).orElse(null);
        if (job == null) return;

        job.setStatus("PROCESSING");
        job.setStartDt(LocalDateTime.now());
        jobRepository.save(job);

        try {
            List<String[]> rows = parseCsvFile(job.getFilePath());
            job.setTotalRows(rows.size());
            jobRepository.save(job);

            int success = 0;
            int error = 0;
            int processed = 0;
            Set<String> processedApplicants = new HashSet<>();
            Map<String, String> subjectCache = new HashMap<>();
            StringBuilder errors = new StringBuilder();

            for (String[] cols : rows) {
                processed++;
                try {
                    jobProcessor.processOneTempScoreRow(cols, job.getExamCd(), processedApplicants, subjectCache);
                    success++;
                } catch (Exception e) {
                    error++;
                    if (errors.length() < 2000) {
                        errors.append("행 ").append(processed + 1).append(": ").append(e.getMessage()).append("\n");
                    }
                }

                // 50건마다 진행률 업데이트
                if (processed % 50 == 0) {
                    job.setProcessedRows(processed);
                    job.setSuccessRows(success);
                    job.setErrorRows(error);
                    jobRepository.save(job);
                }
            }

            job.setStatus("COMPLETED");
            job.setProcessedRows(processed);
            job.setSuccessRows(success);
            job.setErrorRows(error);
            job.setEndDt(LocalDateTime.now());
            if (errors.length() > 0) {
                job.setErrorMessage(errors.toString());
            }
            job.setResultSummary("총 " + processed + "건 중 " + success + "건 성공, " + error + "건 오류");
            jobRepository.save(job);

            log.info("Job {} 완료: {}", jobId, job.getResultSummary());
        } catch (Exception e) {
            log.error("Job {} 처리 실패", jobId, e);
            job.setStatus("FAILED");
            job.setEndDt(LocalDateTime.now());
            job.setErrorMessage(e.getMessage());
            jobRepository.save(job);
        }
    }

    @Async("importJobExecutor")
    public void processScoringAsync(String jobId) {
        ImportJob job = jobRepository.findById(jobId).orElse(null);
        if (job == null) return;

        job.setStatus("PROCESSING");
        job.setStartDt(LocalDateTime.now());
        jobRepository.save(job);

        try {
            String examCd = job.getExamCd();

            // 1) 응시자별 총점/평균 계산
            int totalApplicants = jobProcessor.updateAllApplicantScores(examCd);
            job.setTotalRows(totalApplicants);
            job.setProcessedRows(totalApplicants);
            job.setSuccessRows(totalApplicants);
            jobRepository.save(job);

            // 2) 순위 계산
            int rankedCount = jobProcessor.updateRankings(examCd);

            job.setStatus("COMPLETED");
            job.setEndDt(LocalDateTime.now());
            job.setResultSummary("응시자 " + totalApplicants + "명 채점, " + rankedCount + "명 순위 산출 완료");
            jobRepository.save(job);

            log.info("Scoring Job {} 완료: {}", jobId, job.getResultSummary());
        } catch (Exception e) {
            log.error("Scoring Job {} 실패", jobId, e);
            job.setStatus("FAILED");
            job.setEndDt(LocalDateTime.now());
            job.setErrorMessage(e.getMessage());
            jobRepository.save(job);
        }
    }

    // ==================== Helper ====================

    private String computeFileHash(MultipartFile file) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(file.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("파일 해시 계산 실패", e);
        }
    }

    private String saveFile(MultipartFile file, String jobType) {
        try {
            String dir = UPLOAD_DIR + "/" + jobType.toLowerCase();
            Path dirPath = Paths.get(dir);
            Files.createDirectories(dirPath);

            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String savedName = timestamp + "_" + UUID.randomUUID().toString().substring(0, 8) + ".csv";
            Path filePath = dirPath.resolve(savedName);
            file.transferTo(filePath.toFile());
            return filePath.toString();
        } catch (Exception e) {
            throw new RuntimeException("파일 저장 실패", e);
        }
    }

    private List<String[]> parseCsvFile(String filePath) {
        List<String[]> rows = new ArrayList<>();
        Charset charset = Charset.forName("UTF-8");

        try {
            byte[] bytes = Files.readAllBytes(Paths.get(filePath));
            String probe = new String(bytes, 0, Math.min(bytes.length, 200), charset);
            if (probe.contains("\ufffd")) charset = Charset.forName("EUC-KR");
            if (probe.startsWith("\uFEFF")) probe = probe.substring(1);
        } catch (Exception ignored) {}

        try (BufferedReader reader = new BufferedReader(new FileReader(filePath, charset))) {
            String line = reader.readLine(); // 헤더 스킵
            if (line != null && line.startsWith("\uFEFF")) line = line.substring(1);

            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;
                rows.add(line.split(",", -1));
            }
        } catch (Exception e) {
            throw new RuntimeException("CSV 파일 읽기 실패: " + e.getMessage(), e);
        }
        return rows;
    }
}
