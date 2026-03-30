package com.hopenvision.exam.service;

import com.hopenvision.exam.entity.*;
import com.hopenvision.exam.repository.*;
import com.hopenvision.user.entity.UserProfile;
import com.hopenvision.user.repository.UserProfileRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.FileReader;
import java.math.BigDecimal;
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
    private final ExamApplicantRepository applicantRepository;
    private final ExamApplicantAnsRepository ansRepository;
    private final ExamApplicantScoreRepository scoreRepository;
    private final ExamAnswerKeyRepository answerKeyRepository;
    private final SubjectMasterRepository subjectMasterRepository;
    private final QuestionBankGroupRepository questionBankGroupRepository;
    private final QuestionBankItemRepository questionBankItemRepository;
    private final UserProfileRepository userProfileRepository;
    private final ExamRepository examRepository;

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
                    processOneTempScoreRow(cols, job.getExamCd(), processedApplicants, subjectCache);
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

    @Transactional
    public void processOneTempScoreRow(String[] cols, String examCd,
                                        Set<String> processedApplicants,
                                        Map<String, String> subjectCache) {
        if (cols.length < 5) throw new IllegalArgumentException("컬럼 수 부족");

        String csvExamCd = cols[0].trim();
        String subjectNm = cols[1].trim();
        String userNm = cols[2].trim();
        String userId = cols[3].trim();
        String scoreStr = cols[4].trim();

        if (userId.isEmpty()) throw new IllegalArgumentException("사용자ID 없음");
        if (userId.length() > 20) throw new IllegalArgumentException("사용자ID 20자 초과");
        if (userNm.isEmpty()) userNm = "[수험생]";

        BigDecimal targetScore = new BigDecimal(scoreStr);

        // 과목 매핑
        String subjectCd = subjectCache.computeIfAbsent(subjectNm, nm ->
                subjectMasterRepository.findBySubjectNm(nm)
                        .map(SubjectMaster::getSubjectCd)
                        .orElse(null));
        if (subjectCd == null) throw new IllegalArgumentException("과목 없음: " + subjectNm);

        // 정답 맵
        Map<Integer, AnswerInfo> answerMap = buildAnswerMap(csvExamCd, subjectCd, subjectNm);
        if (answerMap.isEmpty()) throw new IllegalArgumentException("정답키 없음");

        // UserProfile
        if (!userProfileRepository.existsById(userId)) {
            userProfileRepository.save(UserProfile.builder().userId(userId).userNm(userNm).build());
        }

        // ExamApplicant
        String applicantKey = csvExamCd + "|" + userId;
        if (!processedApplicants.contains(applicantKey)) {
            ExamApplicantId appId = new ExamApplicantId(csvExamCd, userId);
            if (!applicantRepository.existsById(appId)) {
                applicantRepository.save(ExamApplicant.builder()
                        .examCd(csvExamCd).applicantNo(userId)
                        .userId(userId).userNm(userNm).scoreStatus("N").build());
            }
            processedApplicants.add(applicantKey);
        }

        // 기존 답안 삭제
        ansRepository.deleteByExamCdAndApplicantNoAndSubjectCd(csvExamCd, userId, subjectCd);

        // 무작위 답안 생성
        String[] generatedAnswers = generateRandomAnswers(answerMap, targetScore);
        int correctCnt = 0;
        BigDecimal totalScore = BigDecimal.ZERO;

        for (int q = 1; q <= 20; q++) {
            String userAns = generatedAnswers[q - 1];
            boolean isN = "N".equals(userAns);
            AnswerInfo ai = answerMap.get(q);
            String isCorrect = "N";
            if (!isN && ai != null && userAns.equals(ai.correctAns)) {
                isCorrect = "Y";
                correctCnt++;
                totalScore = totalScore.add(ai.score);
            }
            ansRepository.save(ExamApplicantAns.builder()
                    .examCd(csvExamCd).applicantNo(userId).subjectCd(subjectCd)
                    .questionNo(q).userAns(isN ? null : userAns).isCorrect(isCorrect).build());
        }

        // 과목별 점수
        ExamApplicantScoreId scoreId = new ExamApplicantScoreId(csvExamCd, userId, subjectCd);
        ExamApplicantScore score = scoreRepository.findById(scoreId).orElse(
                ExamApplicantScore.builder().examCd(csvExamCd).applicantNo(userId).subjectCd(subjectCd).build());
        score.setRawScore(totalScore);
        score.setCorrectCnt(correctCnt);
        score.setWrongCnt(20 - correctCnt);
        scoreRepository.save(score);
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

    @lombok.AllArgsConstructor
    private static class AnswerInfo {
        final String correctAns;
        final BigDecimal score;
    }

    private Map<Integer, AnswerInfo> buildAnswerMap(String examCd, String subjectCd, String subjectNm) {
        Map<Integer, AnswerInfo> map = new HashMap<>();

        List<ExamAnswerKey> answerKeys = answerKeyRepository
                .findByExamCdAndSubjectCdOrderByQuestionNo(examCd, subjectCd);
        if (!answerKeys.isEmpty()) {
            for (ExamAnswerKey key : answerKeys) {
                map.put(key.getQuestionNo(), new AnswerInfo(
                        key.getCorrectAns(), key.getScore() != null ? key.getScore() : new BigDecimal("5")));
            }
            return map;
        }

        String groupCd = examCd + "-" + subjectNm;
        questionBankGroupRepository.findByGroupCd(groupCd).ifPresent(group -> {
            List<QuestionBankItem> items = questionBankItemRepository.findByGroupIdOrderByQuestionNo(group.getGroupId());
            for (QuestionBankItem item : items) {
                if (item.getCorrectAns() != null && !item.getCorrectAns().isEmpty()) {
                    map.put(item.getQuestionNo(), new AnswerInfo(
                            item.getCorrectAns(), item.getScore() != null ? item.getScore() : new BigDecimal("5")));
                }
            }
        });
        return map;
    }

    private String[] generateRandomAnswers(Map<Integer, AnswerInfo> answerMap, BigDecimal targetScore) {
        String[] result = new String[20];
        Arrays.fill(result, "N");

        List<Integer> questionNos = new ArrayList<>(answerMap.keySet());
        Collections.shuffle(questionNos, RANDOM);

        BigDecimal accumulated = BigDecimal.ZERO;
        Set<Integer> correctQuestions = new HashSet<>();

        for (int qno : questionNos) {
            AnswerInfo ai = answerMap.get(qno);
            if (accumulated.add(ai.score).compareTo(targetScore) <= 0) {
                correctQuestions.add(qno);
                accumulated = accumulated.add(ai.score);
            }
            if (accumulated.compareTo(targetScore) == 0) break;
        }

        for (int q = 1; q <= 20; q++) {
            AnswerInfo ai = answerMap.get(q);
            if (ai == null) { result[q - 1] = "N"; continue; }
            if (correctQuestions.contains(q)) {
                result[q - 1] = ai.correctAns;
            } else {
                List<String> choices = new ArrayList<>(List.of("1", "2", "3", "4"));
                choices.remove(ai.correctAns);
                result[q - 1] = choices.isEmpty() ? "N" : choices.get(RANDOM.nextInt(choices.size()));
            }
        }
        return result;
    }
}
