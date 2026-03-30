package com.hopenvision.exam.service;

import com.hopenvision.exam.dto.ApplicantDto;
import com.hopenvision.exam.entity.*;
import com.hopenvision.exam.repository.*;
import com.hopenvision.user.entity.UserProfile;
import com.hopenvision.user.repository.UserProfileRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.Charset;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class ApplicantService {

    private final ExamApplicantRepository applicantRepository;
    private final ExamRepository examRepository;
    private final ExamApplicantAnsRepository ansRepository;
    private final ExamApplicantScoreRepository scoreRepository;
    private final ExamAnswerKeyRepository answerKeyRepository;
    private final SubjectMasterRepository subjectMasterRepository;
    private final UserProfileRepository userProfileRepository;
    private final QuestionBankGroupRepository questionBankGroupRepository;
    private final QuestionBankItemRepository questionBankItemRepository;

    public Page<ApplicantDto.Response> getApplicantList(ApplicantDto.SearchRequest request) {
        if (!examRepository.existsById(request.getExamCd())) {
            throw new EntityNotFoundException("시험을 찾을 수 없습니다: " + request.getExamCd());
        }

        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());
        return applicantRepository.searchByExamCd(request.getExamCd(), request.getKeyword(), pageable)
                .map(this::toResponse);
    }

    public ApplicantDto.Response getApplicant(String examCd, String applicantNo) {
        ExamApplicant applicant = applicantRepository.findById(new ExamApplicantId(examCd, applicantNo))
                .orElseThrow(() -> new EntityNotFoundException("응시자를 찾을 수 없습니다: " + applicantNo));
        return toResponse(applicant);
    }

    @Transactional
    public ApplicantDto.Response createApplicant(String examCd, ApplicantDto.Request request) {
        if (!examRepository.existsById(examCd)) {
            throw new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd);
        }
        if (applicantRepository.existsByExamCdAndApplicantNo(examCd, request.getApplicantNo())) {
            throw new IllegalArgumentException("이미 존재하는 수험번호입니다: " + request.getApplicantNo());
        }

        ExamApplicant applicant = ExamApplicant.builder()
                .examCd(examCd)
                .applicantNo(request.getApplicantNo())
                .userId(request.getUserId())
                .userNm(request.getUserNm())
                .applyArea(request.getApplyArea())
                .applyType(request.getApplyType())
                .addScore(request.getAddScore() != null ? request.getAddScore() : BigDecimal.ZERO)
                .build();

        return toResponse(applicantRepository.save(applicant));
    }

    @Transactional
    public ApplicantDto.Response updateApplicant(String examCd, String applicantNo, ApplicantDto.Request request) {
        ExamApplicant applicant = applicantRepository.findById(new ExamApplicantId(examCd, applicantNo))
                .orElseThrow(() -> new EntityNotFoundException("응시자를 찾을 수 없습니다: " + applicantNo));

        applicant.setUserNm(request.getUserNm());
        applicant.setUserId(request.getUserId());
        applicant.setApplyArea(request.getApplyArea());
        applicant.setApplyType(request.getApplyType());
        applicant.setAddScore(request.getAddScore() != null ? request.getAddScore() : BigDecimal.ZERO);

        return toResponse(applicantRepository.save(applicant));
    }

    @Transactional
    public void deleteApplicant(String examCd, String applicantNo) {
        ExamApplicantId id = new ExamApplicantId(examCd, applicantNo);
        if (!applicantRepository.existsById(id)) {
            throw new EntityNotFoundException("응시자를 찾을 수 없습니다: " + applicantNo);
        }
        applicantRepository.deleteById(id);
    }

    // ==================== CSV Result Import ====================

    /**
     * CSV 응시결과 미리보기 (DB 변경 없음)
     */
    public ApplicantDto.CsvResultImportResult previewCsvResult(MultipartFile file) {
        List<ApplicantDto.CsvResultRow> rows = parseCsvResultFile(file);
        matchCsvResultRows(rows);
        return buildCsvResult(rows, false);
    }

    /**
     * CSV 응시결과 적용
     */
    @Transactional
    public ApplicantDto.CsvResultImportResult applyCsvResult(MultipartFile file) {
        List<ApplicantDto.CsvResultRow> rows = parseCsvResultFile(file);
        matchCsvResultRows(rows);

        int importedCount = 0;
        // 같은 examCd+userId 조합 추적 (중복 과목 등록)
        Set<String> processedApplicants = new HashSet<>();

        for (ApplicantDto.CsvResultRow row : rows) {
            if (!"MATCHED".equals(row.getStatus())) continue;

            try {
                String applicantKey = row.getExamCd() + "|" + row.getUserId();

                // 1) UserProfile 생성 (없으면)
                if (!userProfileRepository.existsById(row.getUserId())) {
                    UserProfile profile = UserProfile.builder()
                            .userId(row.getUserId())
                            .userNm(row.getUserNm())
                            .build();
                    userProfileRepository.save(profile);
                }

                // 2) ExamApplicant 생성/갱신 (applicantNo = userId)
                if (!processedApplicants.contains(applicantKey)) {
                    ExamApplicantId appId = new ExamApplicantId(row.getExamCd(), row.getUserId());
                    ExamApplicant applicant = applicantRepository.findById(appId).orElse(null);
                    if (applicant == null) {
                        applicant = ExamApplicant.builder()
                                .examCd(row.getExamCd())
                                .applicantNo(row.getUserId())
                                .userId(row.getUserId())
                                .userNm(row.getUserNm())
                                .scoreStatus("N")
                                .build();
                        applicantRepository.save(applicant);
                    }
                    processedApplicants.add(applicantKey);
                }

                // 3) 기존 답안 삭제 후 재등록
                ansRepository.deleteByExamCdAndApplicantNoAndSubjectCd(
                        row.getExamCd(), row.getUserId(), row.getSubjectCd());
                ansRepository.flush();

                // 4) 답안 파싱 및 저장
                String[] answers = parseAnswers(row.getAnswers());
                Map<Integer, AnswerInfo> answerMap = buildAnswerMap(
                        row.getExamCd(), row.getSubjectCd(), row.getSubjectNm());

                int correctCnt = 0;
                int wrongCnt = 0;
                BigDecimal totalScore = BigDecimal.ZERO;

                for (int q = 1; q <= 20; q++) {
                    String userAns = (q <= answers.length) ? answers[q - 1] : "N";
                    boolean isN = "N".equalsIgnoreCase(userAns);

                    AnswerInfo ai = answerMap.get(q);
                    String isCorrect = "N";
                    if (!isN && ai != null && userAns.equals(ai.correctAns)) {
                        isCorrect = "Y";
                        correctCnt++;
                        totalScore = totalScore.add(ai.score);
                    } else {
                        wrongCnt++;
                    }

                    ExamApplicantAns ans = ExamApplicantAns.builder()
                            .examCd(row.getExamCd())
                            .applicantNo(row.getUserId())
                            .subjectCd(row.getSubjectCd())
                            .questionNo(q)
                            .userAns(isN ? null : userAns)
                            .isCorrect(isCorrect)
                            .build();
                    ansRepository.save(ans);
                }

                // 5) 과목별 점수 저장
                ExamApplicantScoreId scoreId = new ExamApplicantScoreId(
                        row.getExamCd(), row.getUserId(), row.getSubjectCd());
                ExamApplicantScore score = scoreRepository.findById(scoreId).orElse(
                        ExamApplicantScore.builder()
                                .examCd(row.getExamCd())
                                .applicantNo(row.getUserId())
                                .subjectCd(row.getSubjectCd())
                                .build());
                score.setRawScore(totalScore);
                score.setCorrectCnt(correctCnt);
                score.setWrongCnt(wrongCnt);
                scoreRepository.save(score);

                row.setCorrectCnt(correctCnt);
                row.setWrongCnt(wrongCnt);
                row.setScore(totalScore);
                importedCount++;
            } catch (Exception e) {
                log.error("CSV 결과 적용 오류: row={}", row.getRowNum(), e);
                row.setStatus("ERROR");
                row.setMessage("적용 오류: " + e.getMessage());
            }
        }

        ApplicantDto.CsvResultImportResult result = buildCsvResult(rows, true);
        result.setImportedRows(importedCount);
        return result;
    }

    private List<ApplicantDto.CsvResultRow> parseCsvResultFile(MultipartFile file) {
        List<ApplicantDto.CsvResultRow> rows = new ArrayList<>();
        Charset charset = Charset.forName("UTF-8");
        try {
            byte[] bytes = file.getBytes();
            // BOM 처리
            String probe = new String(bytes, 0, Math.min(bytes.length, 200), charset);
            if (probe.contains("\ufffd")) {
                charset = Charset.forName("EUC-KR");
            }
        } catch (Exception ignored) {
        }

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(file.getInputStream(), charset))) {
            String line = reader.readLine(); // 헤더 스킵
            if (line == null) return rows;
            // BOM 제거
            if (line.startsWith("\uFEFF")) line = line.substring(1);

            int rowNum = 1;
            while ((line = reader.readLine()) != null) {
                rowNum++;
                line = line.trim();
                if (line.isEmpty()) continue;

                String[] cols = line.split(",", -1);
                if (cols.length < 5) {
                    rows.add(ApplicantDto.CsvResultRow.builder()
                            .rowNum(rowNum).status("ERROR")
                            .message("컬럼 수 부족 (5개 필요, " + cols.length + "개)")
                            .build());
                    continue;
                }

                try {
                    String examCd = cols[0].trim();
                    String subjectNm = cols[1].trim();
                    String userNm = cols[2].trim();
                    String userId = cols[3].trim();
                    String answers = cols[4].trim();

                    // 이름 누락 시 사용자ID가 있으면 [수험생]으로 대체
                    if (userNm.isEmpty() && !userId.isEmpty()) {
                        userNm = "[수험생]";
                    }

                    // 답안 개수 검증
                    String[] ansParts = answers.split("/", -1);

                    rows.add(ApplicantDto.CsvResultRow.builder()
                            .rowNum(rowNum)
                            .examCd(examCd)
                            .subjectNm(subjectNm)
                            .userNm(userNm)
                            .userId(userId)
                            .answers(answers)
                            .answerCount(ansParts.length)
                            .status("PARSED")
                            .build());
                } catch (Exception e) {
                    rows.add(ApplicantDto.CsvResultRow.builder()
                            .rowNum(rowNum).status("ERROR")
                            .message("파싱 오류: " + e.getMessage())
                            .build());
                }
            }
        } catch (Exception e) {
            log.error("CSV 파일 읽기 실패", e);
            throw new IllegalArgumentException("CSV 파일을 읽을 수 없습니다: " + e.getMessage());
        }
        return rows;
    }

    private void matchCsvResultRows(List<ApplicantDto.CsvResultRow> rows) {
        // 과목명 → 과목코드 캐시
        Map<String, String> subjectCache = new HashMap<>();

        for (ApplicantDto.CsvResultRow row : rows) {
            if (!"PARSED".equals(row.getStatus())) continue;

            // 시험 존재 확인
            if (!examRepository.existsById(row.getExamCd())) {
                row.setStatus("SKIP");
                row.setMessage("시험 없음: " + row.getExamCd());
                continue;
            }

            // userId 검증 (20자 제한)
            if (row.getUserId() == null || row.getUserId().isEmpty()) {
                row.setStatus("ERROR");
                row.setMessage("사용자ID가 비어있습니다");
                continue;
            }
            if (row.getUserId().length() > 20) {
                row.setStatus("ERROR");
                row.setMessage("사용자ID가 20자를 초과합니다: " + row.getUserId());
                continue;
            }

            // 과목명 → 과목코드 매핑
            String subjectNm = row.getSubjectNm();
            String subjectCd = subjectCache.computeIfAbsent(subjectNm, nm ->
                    subjectMasterRepository.findBySubjectNm(nm)
                            .map(SubjectMaster::getSubjectCd)
                            .orElse(null));

            if (subjectCd == null) {
                row.setStatus("SKIP");
                row.setMessage("과목 없음: " + subjectNm);
                continue;
            }
            row.setSubjectCd(subjectCd);

            // 답안 개수 검증 — 20개 미만이면 N으로 채움
            String[] ansParts = row.getAnswers().split("/", -1);
            if (ansParts.length < 20) {
                StringBuilder sb = new StringBuilder(row.getAnswers());
                for (int i = ansParts.length; i < 20; i++) {
                    sb.append("/N");
                }
                row.setAnswers(sb.toString());
                row.setAnswerCount(20);
                row.setMessage("답안 " + ansParts.length + "개 → 20개로 채움 (나머지 N)");
            }

            // 정답 맵 구성 (exam_answer_key 우선, 없으면 question_bank_item 폴백)
            Map<Integer, AnswerInfo> answerMap = buildAnswerMap(row.getExamCd(), subjectCd, subjectNm);

            if (answerMap.isEmpty()) {
                row.setStatus("SKIP");
                row.setMessage("정답키 없음 (시험 정답키/문제은행 모두 없음)");
                continue;
            }

            String[] answers = parseAnswers(row.getAnswers());
            int correctCnt = 0;
            int wrongCnt = 0;
            BigDecimal totalScore = BigDecimal.ZERO;
            for (int q = 1; q <= 20; q++) {
                String userAns = (q <= answers.length) ? answers[q - 1] : "N";
                boolean isN = "N".equalsIgnoreCase(userAns);
                AnswerInfo ai = answerMap.get(q);
                if (!isN && ai != null && userAns.equals(ai.correctAns)) {
                    correctCnt++;
                    totalScore = totalScore.add(ai.score);
                } else {
                    wrongCnt++;
                }
            }
            row.setCorrectCnt(correctCnt);
            row.setWrongCnt(wrongCnt);
            row.setScore(totalScore);
            row.setStatus("MATCHED");
        }
    }

    /**
     * 정답 정보를 담는 내부 클래스
     */
    @lombok.AllArgsConstructor
    private static class AnswerInfo {
        final String correctAns;
        final BigDecimal score;
    }

    /**
     * 정답 맵 구성: exam_answer_key 우선, 없으면 question_bank_item에서 폴백
     */
    private Map<Integer, AnswerInfo> buildAnswerMap(String examCd, String subjectCd, String subjectNm) {
        Map<Integer, AnswerInfo> map = new HashMap<>();

        // 1) exam_answer_key에서 조회
        List<ExamAnswerKey> answerKeys = answerKeyRepository
                .findByExamCdAndSubjectCdOrderByQuestionNo(examCd, subjectCd);
        if (!answerKeys.isEmpty()) {
            for (ExamAnswerKey key : answerKeys) {
                map.put(key.getQuestionNo(), new AnswerInfo(
                        key.getCorrectAns(),
                        key.getScore() != null ? key.getScore() : new BigDecimal("5")));
            }
            return map;
        }

        // 2) 문제은행에서 폴백: 그룹코드 = examCd-과목명
        String groupCd = examCd + "-" + subjectNm;
        Optional<QuestionBankGroup> groupOpt = questionBankGroupRepository.findByGroupCd(groupCd);
        if (groupOpt.isPresent()) {
            List<QuestionBankItem> items = questionBankItemRepository
                    .findByGroupIdOrderByQuestionNo(groupOpt.get().getGroupId());
            for (QuestionBankItem item : items) {
                if (item.getCorrectAns() != null && !item.getCorrectAns().isEmpty()) {
                    map.put(item.getQuestionNo(), new AnswerInfo(
                            item.getCorrectAns(),
                            item.getScore() != null ? item.getScore() : new BigDecimal("5")));
                }
            }
        }

        return map;
    }

    // ==================== 임시점수결과 등록 ====================

    private static final Random RANDOM = new Random();

    /**
     * 임시점수 CSV 미리보기 (DB 변경 없음)
     */
    public ApplicantDto.CsvResultImportResult previewTempScore(MultipartFile file) {
        List<ApplicantDto.CsvResultRow> rows = parseTempScoreCsvFile(file);
        matchTempScoreRows(rows);
        return buildCsvResult(rows, false);
    }

    /**
     * 임시점수 CSV 적용 — 점수 기반 무작위 답안 생성 후 저장
     */
    @Transactional
    public ApplicantDto.CsvResultImportResult applyTempScore(MultipartFile file) {
        List<ApplicantDto.CsvResultRow> rows = parseTempScoreCsvFile(file);
        matchTempScoreRows(rows);

        int importedCount = 0;
        Set<String> processedApplicants = new HashSet<>();

        for (ApplicantDto.CsvResultRow row : rows) {
            if (!"MATCHED".equals(row.getStatus())) continue;

            try {
                String applicantKey = row.getExamCd() + "|" + row.getUserId();

                // 1) UserProfile 생성
                if (!userProfileRepository.existsById(row.getUserId())) {
                    UserProfile profile = UserProfile.builder()
                            .userId(row.getUserId())
                            .userNm(row.getUserNm())
                            .build();
                    userProfileRepository.save(profile);
                }

                // 2) ExamApplicant 생성/갱신
                if (!processedApplicants.contains(applicantKey)) {
                    ExamApplicantId appId = new ExamApplicantId(row.getExamCd(), row.getUserId());
                    ExamApplicant applicant = applicantRepository.findById(appId).orElse(null);
                    if (applicant == null) {
                        applicant = ExamApplicant.builder()
                                .examCd(row.getExamCd())
                                .applicantNo(row.getUserId())
                                .userId(row.getUserId())
                                .userNm(row.getUserNm())
                                .scoreStatus("N")
                                .build();
                        applicantRepository.save(applicant);
                    }
                    processedApplicants.add(applicantKey);
                }

                // 3) 기존 답안 삭제
                ansRepository.deleteByExamCdAndApplicantNoAndSubjectCd(
                        row.getExamCd(), row.getUserId(), row.getSubjectCd());
                ansRepository.flush();

                // 4) 무작위 답안 생성 및 저장
                Map<Integer, AnswerInfo> answerMap = buildAnswerMap(
                        row.getExamCd(), row.getSubjectCd(), row.getSubjectNm());
                String[] generatedAnswers = generateRandomAnswers(answerMap, row.getScore());

                int correctCnt = 0;
                int wrongCnt = 0;
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
                    } else {
                        wrongCnt++;
                    }

                    ExamApplicantAns ans = ExamApplicantAns.builder()
                            .examCd(row.getExamCd())
                            .applicantNo(row.getUserId())
                            .subjectCd(row.getSubjectCd())
                            .questionNo(q)
                            .userAns(isN ? null : userAns)
                            .isCorrect(isCorrect)
                            .build();
                    ansRepository.save(ans);
                }

                // 5) 과목별 점수 저장
                ExamApplicantScoreId scoreId = new ExamApplicantScoreId(
                        row.getExamCd(), row.getUserId(), row.getSubjectCd());
                ExamApplicantScore score = scoreRepository.findById(scoreId).orElse(
                        ExamApplicantScore.builder()
                                .examCd(row.getExamCd())
                                .applicantNo(row.getUserId())
                                .subjectCd(row.getSubjectCd())
                                .build());
                score.setRawScore(totalScore);
                score.setCorrectCnt(correctCnt);
                score.setWrongCnt(wrongCnt);
                scoreRepository.save(score);

                // 생성된 답안 문자열을 row에 반영
                row.setAnswers(String.join("/", generatedAnswers));
                row.setCorrectCnt(correctCnt);
                row.setWrongCnt(wrongCnt);
                row.setScore(totalScore);
                importedCount++;
            } catch (Exception e) {
                log.error("임시점수 적용 오류: row={}", row.getRowNum(), e);
                row.setStatus("ERROR");
                row.setMessage("적용 오류: " + e.getMessage());
            }
        }

        ApplicantDto.CsvResultImportResult result = buildCsvResult(rows, true);
        result.setImportedRows(importedCount);
        return result;
    }

    private List<ApplicantDto.CsvResultRow> parseTempScoreCsvFile(MultipartFile file) {
        List<ApplicantDto.CsvResultRow> rows = new ArrayList<>();
        Charset charset = Charset.forName("UTF-8");
        try {
            byte[] bytes = file.getBytes();
            String probe = new String(bytes, 0, Math.min(bytes.length, 200), charset);
            if (probe.contains("\ufffd")) {
                charset = Charset.forName("EUC-KR");
            }
        } catch (Exception ignored) {
        }

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(file.getInputStream(), charset))) {
            String line = reader.readLine();
            if (line == null) return rows;
            if (line.startsWith("\uFEFF")) line = line.substring(1);

            int rowNum = 1;
            while ((line = reader.readLine()) != null) {
                rowNum++;
                line = line.trim();
                if (line.isEmpty()) continue;

                String[] cols = line.split(",", -1);
                if (cols.length < 5) {
                    rows.add(ApplicantDto.CsvResultRow.builder()
                            .rowNum(rowNum).status("ERROR")
                            .message("컬럼 수 부족 (5개 필요, " + cols.length + "개)")
                            .build());
                    continue;
                }

                try {
                    String examCd = cols[0].trim();
                    String subjectNm = cols[1].trim();
                    String userNm = cols[2].trim();
                    String userId = cols[3].trim();
                    String scoreStr = cols[4].trim();

                    if (userNm.isEmpty() && !userId.isEmpty()) {
                        userNm = "[수험생]";
                    }

                    BigDecimal scoreVal = new BigDecimal(scoreStr);

                    rows.add(ApplicantDto.CsvResultRow.builder()
                            .rowNum(rowNum)
                            .examCd(examCd)
                            .subjectNm(subjectNm)
                            .userNm(userNm)
                            .userId(userId)
                            .score(scoreVal)
                            .answerCount(20)
                            .status("PARSED")
                            .build());
                } catch (Exception e) {
                    rows.add(ApplicantDto.CsvResultRow.builder()
                            .rowNum(rowNum).status("ERROR")
                            .message("파싱 오류: " + e.getMessage())
                            .build());
                }
            }
        } catch (Exception e) {
            log.error("CSV 파일 읽기 실패", e);
            throw new IllegalArgumentException("CSV 파일을 읽을 수 없습니다: " + e.getMessage());
        }
        return rows;
    }

    private void matchTempScoreRows(List<ApplicantDto.CsvResultRow> rows) {
        Map<String, String> subjectCache = new HashMap<>();

        for (ApplicantDto.CsvResultRow row : rows) {
            if (!"PARSED".equals(row.getStatus())) continue;

            if (!examRepository.existsById(row.getExamCd())) {
                row.setStatus("SKIP");
                row.setMessage("시험 없음: " + row.getExamCd());
                continue;
            }

            if (row.getUserId() == null || row.getUserId().isEmpty()) {
                row.setStatus("ERROR");
                row.setMessage("사용자ID가 비어있습니다");
                continue;
            }
            if (row.getUserId().length() > 20) {
                row.setStatus("ERROR");
                row.setMessage("사용자ID가 20자를 초과합니다");
                continue;
            }

            String subjectNm = row.getSubjectNm();
            String subjectCd = subjectCache.computeIfAbsent(subjectNm, nm ->
                    subjectMasterRepository.findBySubjectNm(nm)
                            .map(SubjectMaster::getSubjectCd)
                            .orElse(null));

            if (subjectCd == null) {
                row.setStatus("SKIP");
                row.setMessage("과목 없음: " + subjectNm);
                continue;
            }
            row.setSubjectCd(subjectCd);

            // 정답 맵
            Map<Integer, AnswerInfo> answerMap = buildAnswerMap(row.getExamCd(), subjectCd, subjectNm);
            if (answerMap.isEmpty()) {
                row.setStatus("SKIP");
                row.setMessage("정답키 없음");
                continue;
            }

            // 점수 유효성: 0 ~ 만점 범위
            BigDecimal maxScore = BigDecimal.ZERO;
            for (AnswerInfo ai : answerMap.values()) {
                maxScore = maxScore.add(ai.score);
            }
            if (row.getScore().compareTo(BigDecimal.ZERO) < 0 || row.getScore().compareTo(maxScore) > 0) {
                row.setStatus("ERROR");
                row.setMessage("점수 범위 초과 (0~" + maxScore + ")");
                continue;
            }

            // 미리보기: 무작위 답안 생성하여 정답/오답 수 계산
            String[] generatedAnswers = generateRandomAnswers(answerMap, row.getScore());
            int correctCnt = 0;
            BigDecimal actualScore = BigDecimal.ZERO;
            for (int q = 1; q <= 20; q++) {
                AnswerInfo ai = answerMap.get(q);
                if (ai != null && generatedAnswers[q - 1].equals(ai.correctAns)) {
                    correctCnt++;
                    actualScore = actualScore.add(ai.score);
                }
            }
            row.setAnswers(String.join("/", generatedAnswers));
            row.setCorrectCnt(correctCnt);
            row.setWrongCnt(20 - correctCnt);
            row.setScore(actualScore);
            row.setStatus("MATCHED");
        }
    }

    /**
     * 점수에 맞게 무작위 답안 생성
     * 정답키에서 점수 합이 targetScore에 가장 가까운 조합을 무작위로 선택
     */
    private String[] generateRandomAnswers(Map<Integer, AnswerInfo> answerMap, BigDecimal targetScore) {
        String[] result = new String[20];
        Arrays.fill(result, "N");

        // 문항별 배점 리스트 구성
        List<Integer> questionNos = new ArrayList<>(answerMap.keySet());
        Collections.shuffle(questionNos, RANDOM);

        // 배점 합이 targetScore에 도달할 때까지 정답 배치
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

        // 답안 배치
        for (int q = 1; q <= 20; q++) {
            AnswerInfo ai = answerMap.get(q);
            if (ai == null) {
                result[q - 1] = "N";
                continue;
            }
            if (correctQuestions.contains(q)) {
                // 정답
                result[q - 1] = ai.correctAns;
            } else {
                // 오답: 정답을 제외한 1~4 중 랜덤
                result[q - 1] = generateWrongAnswer(ai.correctAns);
            }
        }
        return result;
    }

    /**
     * 정답을 제외한 1~4 중 무작위 오답 생성
     */
    private String generateWrongAnswer(String correctAns) {
        List<String> choices = new ArrayList<>(List.of("1", "2", "3", "4"));
        choices.remove(correctAns);
        if (choices.isEmpty()) return "N";
        return choices.get(RANDOM.nextInt(choices.size()));
    }

    private String[] parseAnswers(String answers) {
        String[] parts = answers.split("/", -1);
        // 최대 20개
        if (parts.length > 20) {
            return Arrays.copyOf(parts, 20);
        }
        return parts;
    }

    private ApplicantDto.CsvResultImportResult buildCsvResult(
            List<ApplicantDto.CsvResultRow> rows, boolean isApply) {
        int matched = 0, skipped = 0, error = 0;
        for (ApplicantDto.CsvResultRow row : rows) {
            switch (row.getStatus()) {
                case "MATCHED" -> matched++;
                case "SKIP" -> skipped++;
                default -> error++;
            }
        }
        return ApplicantDto.CsvResultImportResult.builder()
                .totalRows(rows.size())
                .matchedRows(matched)
                .skippedRows(skipped)
                .errorRows(error)
                .importedRows(isApply ? 0 : matched)
                .rows(rows)
                .build();
    }

    private ApplicantDto.Response toResponse(ExamApplicant applicant) {
        return ApplicantDto.Response.builder()
                .examCd(applicant.getExamCd())
                .applicantNo(applicant.getApplicantNo())
                .userId(applicant.getUserId())
                .userNm(applicant.getUserNm())
                .applyArea(applicant.getApplyArea())
                .applyType(applicant.getApplyType())
                .addScore(applicant.getAddScore())
                .totalScore(applicant.getTotalScore())
                .avgScore(applicant.getAvgScore())
                .ranking(applicant.getRanking())
                .passYn(applicant.getPassYn())
                .scoreStatus(applicant.getScoreStatus())
                .regDt(applicant.getRegDt())
                .updDt(applicant.getUpdDt())
                .build();
    }
}
