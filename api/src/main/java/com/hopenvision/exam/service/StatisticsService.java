package com.hopenvision.exam.service;

import com.hopenvision.exam.dto.StatisticsDto;
import com.hopenvision.exam.entity.Exam;
import com.hopenvision.exam.entity.ExamAnswerKey;
import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.repository.ExamAnswerKeyRepository;
import com.hopenvision.exam.repository.ExamApplicantRepository;
import com.hopenvision.exam.repository.ExamRepository;
import com.hopenvision.exam.repository.ExamSubjectRepository;
import com.hopenvision.user.repository.UserAnswerRepository;
import com.hopenvision.user.repository.UserScoreRepository;
import com.hopenvision.user.repository.UserTotalScoreRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class StatisticsService {

    private final ExamRepository examRepository;
    private final ExamSubjectRepository subjectRepository;
    private final ExamAnswerKeyRepository answerKeyRepository;
    private final ExamApplicantRepository applicantRepository;
    private final UserTotalScoreRepository userTotalScoreRepository;
    private final UserScoreRepository userScoreRepository;
    private final UserAnswerRepository userAnswerRepository;

    public StatisticsDto.ExamStatistics getExamStatistics(String examCd) {
        Exam exam = examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        long totalApplicants = userTotalScoreRepository.countByExamCd(examCd);
        long passedCount = userTotalScoreRepository.countPassedByExamCd(examCd);
        BigDecimal avgScore = userTotalScoreRepository.avgTotalScoreByExamCd(examCd);
        BigDecimal maxScore = userTotalScoreRepository.maxTotalScoreByExamCd(examCd);
        BigDecimal minScore = userTotalScoreRepository.minTotalScoreByExamCd(examCd);

        BigDecimal passRate = BigDecimal.ZERO;
        if (totalApplicants > 0) {
            passRate = BigDecimal.valueOf(passedCount)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(BigDecimal.valueOf(totalApplicants), 2, RoundingMode.HALF_UP);
        }

        // 점수 분포 계산
        List<StatisticsDto.ScoreDistribution> distributions = calculateScoreDistribution(examCd, totalApplicants);

        // 과목별 통계 (단일 GROUP BY 쿼리로 일괄 조회)
        List<ExamSubject> subjects = subjectRepository.findByExamCdOrderBySortOrder(examCd);
        Map<String, Object[]> subjectStatsMap = new HashMap<>();
        for (Object[] row : userScoreRepository.getSubjectStatsBatch(examCd)) {
            subjectStatsMap.put((String) row[0], row);
        }

        List<StatisticsDto.SubjectStatistics> subjectStats = subjects.stream()
                .map(subject -> {
                    Object[] stats = subjectStatsMap.get(subject.getSubjectCd());
                    long subjectCount = stats != null ? (Long) stats[1] : 0;
                    Double subAvgDouble = stats != null ? (Double) stats[2] : null;
                    BigDecimal subAvg = subAvgDouble != null ? BigDecimal.valueOf(subAvgDouble) : null;
                    BigDecimal subMax = stats != null ? (BigDecimal) stats[3] : null;
                    BigDecimal subMin = stats != null ? (BigDecimal) stats[4] : null;

                    return StatisticsDto.SubjectStatistics.builder()
                            .subjectCd(subject.getSubjectCd())
                            .subjectNm(subject.getSubjectNm())
                            .applicantCount(subjectCount)
                            .avgScore(subAvg != null ? subAvg.setScale(2, RoundingMode.HALF_UP) : null)
                            .maxScore(subMax)
                            .minScore(subMin)
                            .build();
                })
                .collect(Collectors.toList());

        return StatisticsDto.ExamStatistics.builder()
                .examCd(examCd)
                .examNm(exam.getExamNm())
                .totalApplicants(totalApplicants)
                .passedCount(passedCount)
                .passRate(passRate)
                .avgScore(avgScore != null ? avgScore.setScale(2, RoundingMode.HALF_UP) : null)
                .maxScore(maxScore)
                .minScore(minScore)
                .scoreDistributions(distributions)
                .subjectStatistics(subjectStats)
                .build();
    }

    private List<StatisticsDto.ScoreDistribution> calculateScoreDistribution(String examCd, long totalApplicants) {
        // DB에서 점수 분포를 단일 쿼리로 계산 (메모리 로딩 제거)
        Object[] distResult = userTotalScoreRepository.getScoreDistribution(examCd);

        String[] ranges = { "90~100", "80~89", "70~79", "60~69", "50~59", "40~49", "30~39", "20~29", "10~19", "0~9" };
        List<StatisticsDto.ScoreDistribution> distributions = new ArrayList<>();

        for (int i = 0; i < ranges.length; i++) {
            long count = distResult != null && distResult[i] != null ? ((Number) distResult[i]).longValue() : 0;

            BigDecimal percentage = BigDecimal.ZERO;
            if (totalApplicants > 0) {
                percentage = BigDecimal.valueOf(count)
                        .multiply(BigDecimal.valueOf(100))
                        .divide(BigDecimal.valueOf(totalApplicants), 2, RoundingMode.HALF_UP);
            }

            distributions.add(StatisticsDto.ScoreDistribution.builder()
                    .range(ranges[i])
                    .count(count)
                    .percentage(percentage)
                    .build());
        }

        return distributions;
    }

    /**
     * 문항별 정답률 및 선택지 분포 통계
     */
    public List<StatisticsDto.QuestionStatistics> getQuestionStatistics(String examCd) {
        Exam exam = examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        List<ExamSubject> subjects = subjectRepository.findByExamCdOrderBySortOrder(examCd);

        // 과목별 정답 맵: subjectCd -> questionNo -> correctAns
        Map<String, Map<Integer, String>> answerKeyMap = new HashMap<>();
        for (ExamSubject subject : subjects) {
            List<ExamAnswerKey> keys = answerKeyRepository.findByExamCdAndSubjectCdOrderByQuestionNo(examCd, subject.getSubjectCd());
            Map<Integer, String> qMap = new HashMap<>();
            for (ExamAnswerKey key : keys) {
                qMap.put(key.getQuestionNo(), key.getCorrectAns());
            }
            answerKeyMap.put(subject.getSubjectCd(), qMap);
        }

        // 문항별 정답률 집계
        List<Object[]> correctRates = userAnswerRepository.getQuestionCorrectRates(examCd);
        // key: "subjectCd:questionNo" -> [correctCount, totalCount]
        Map<String, long[]> rateMap = new HashMap<>();
        for (Object[] row : correctRates) {
            String key = row[0] + ":" + row[1];
            long correct = ((Number) row[2]).longValue();
            long total = ((Number) row[3]).longValue();
            rateMap.put(key, new long[]{correct, total});
        }

        // 선택지 분포 집계
        List<Object[]> choiceRows = userAnswerRepository.getChoiceDistributions(examCd);
        // key: "subjectCd:questionNo" -> {choice -> count}
        Map<String, Map<String, Long>> choiceMap = new LinkedHashMap<>();
        for (Object[] row : choiceRows) {
            String key = row[0] + ":" + row[1];
            String choice = (String) row[2];
            long count = ((Number) row[3]).longValue();
            choiceMap.computeIfAbsent(key, k -> new LinkedHashMap<>())
                    .put(choice != null ? choice : "미응답", count);
        }

        // 과목별로 결과 조합
        List<StatisticsDto.QuestionStatistics> result = new ArrayList<>();

        for (ExamSubject subject : subjects) {
            Map<Integer, String> qAnswers = answerKeyMap.getOrDefault(subject.getSubjectCd(), Map.of());
            List<StatisticsDto.QuestionDetail> questions = new ArrayList<>();

            // 문항 번호 수집 (정답 키 기준)
            List<Integer> questionNos = new ArrayList<>(qAnswers.keySet());
            Collections.sort(questionNos);

            for (int qNo : questionNos) {
                String mapKey = subject.getSubjectCd() + ":" + qNo;
                long[] rates = rateMap.getOrDefault(mapKey, new long[]{0, 0});
                long correctCount = rates[0];
                long totalAnswered = rates[1];

                BigDecimal correctRate = BigDecimal.ZERO;
                if (totalAnswered > 0) {
                    correctRate = BigDecimal.valueOf(correctCount)
                            .multiply(BigDecimal.valueOf(100))
                            .divide(BigDecimal.valueOf(totalAnswered), 2, RoundingMode.HALF_UP);
                }

                // 난이도 판정
                String difficulty;
                if (correctRate.compareTo(BigDecimal.valueOf(70)) >= 0) {
                    difficulty = "상(쉬움)";
                } else if (correctRate.compareTo(BigDecimal.valueOf(40)) >= 0) {
                    difficulty = "중(보통)";
                } else {
                    difficulty = "하(어려움)";
                }

                // 선택지 분포
                String correctAns = qAnswers.get(qNo);
                Map<String, Long> choices = choiceMap.getOrDefault(mapKey, Map.of());
                List<StatisticsDto.ChoiceDistribution> choiceDist = new ArrayList<>();
                for (String choiceNum : List.of("1", "2", "3", "4", "5")) {
                    long cnt = choices.getOrDefault(choiceNum, 0L);
                    BigDecimal pct = BigDecimal.ZERO;
                    if (totalAnswered > 0) {
                        pct = BigDecimal.valueOf(cnt)
                                .multiply(BigDecimal.valueOf(100))
                                .divide(BigDecimal.valueOf(totalAnswered), 2, RoundingMode.HALF_UP);
                    }
                    choiceDist.add(StatisticsDto.ChoiceDistribution.builder()
                            .choice(choiceNum)
                            .count(cnt)
                            .percentage(pct)
                            .isCorrect(choiceNum.equals(correctAns))
                            .build());
                }

                questions.add(StatisticsDto.QuestionDetail.builder()
                        .questionNo(qNo)
                        .correctAns(correctAns)
                        .totalAnswered(totalAnswered)
                        .correctCount(correctCount)
                        .correctRate(correctRate)
                        .difficulty(difficulty)
                        .choiceDistributions(choiceDist)
                        .build());
            }

            result.add(StatisticsDto.QuestionStatistics.builder()
                    .subjectCd(subject.getSubjectCd())
                    .subjectNm(subject.getSubjectNm())
                    .questions(questions)
                    .build());
        }

        return result;
    }

    /**
     * 직렬별 통계 (T-008)
     */
    public List<StatisticsDto.AreaStatistics> getAreaStatistics(String examCd) {
        examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        List<Object[]> rows = applicantRepository.getAreaStatistics(examCd);
        List<StatisticsDto.AreaStatistics> result = new ArrayList<>();

        for (Object[] row : rows) {
            String area = (String) row[0];
            long count = ((Number) row[1]).longValue();
            Double avgDouble = row[2] != null ? ((Number) row[2]).doubleValue() : null;
            BigDecimal avg = avgDouble != null ? BigDecimal.valueOf(avgDouble).setScale(2, RoundingMode.HALF_UP) : null;
            BigDecimal max = row[3] != null ? new BigDecimal(row[3].toString()) : null;
            BigDecimal min = row[4] != null ? new BigDecimal(row[4].toString()) : null;
            long passed = row[5] != null ? ((Number) row[5]).longValue() : 0;

            BigDecimal passRate = BigDecimal.ZERO;
            if (count > 0) {
                passRate = BigDecimal.valueOf(passed)
                        .multiply(BigDecimal.valueOf(100))
                        .divide(BigDecimal.valueOf(count), 2, RoundingMode.HALF_UP);
            }

            result.add(StatisticsDto.AreaStatistics.builder()
                    .applyArea(area)
                    .applicantCount(count)
                    .avgScore(avg)
                    .maxScore(max)
                    .minScore(min)
                    .passedCount(passed)
                    .passRate(passRate)
                    .build());
        }

        return result;
    }

    /**
     * 응시 현황 대시보드 (T-010)
     */
    public List<StatisticsDto.ExamDashboardItem> getDashboard() {
        List<Exam> exams = examRepository.findByIsUse("Y");
        if (exams.isEmpty()) return List.of();

        List<String> examCds = exams.stream().map(Exam::getExamCd).collect(Collectors.toList());

        // 응시자 수 일괄 조회
        Map<String, Long> applicantCounts = new HashMap<>();
        for (Object[] row : examRepository.findExamCountsByExamCds(examCds)) {
            applicantCounts.put((String) row[0], (Long) row[2]);
        }

        // 제출 완료 수 일괄 조회
        Map<String, Long> submittedCounts = new HashMap<>();
        for (Object[] row : userTotalScoreRepository.countByExamCdIn(examCds)) {
            submittedCounts.put((String) row[0], (Long) row[1]);
        }

        return exams.stream().map(exam -> {
            long applicantCount = applicantCounts.getOrDefault(exam.getExamCd(), 0L);
            long submittedCount = submittedCounts.getOrDefault(exam.getExamCd(), 0L);
            BigDecimal submissionRate = BigDecimal.ZERO;
            if (applicantCount > 0) {
                submissionRate = BigDecimal.valueOf(submittedCount)
                        .multiply(BigDecimal.valueOf(100))
                        .divide(BigDecimal.valueOf(applicantCount), 2, RoundingMode.HALF_UP);
            }

            return StatisticsDto.ExamDashboardItem.builder()
                    .examCd(exam.getExamCd())
                    .examNm(exam.getExamNm())
                    .examType(exam.getExamType())
                    .examStatus(exam.getExamStatus())
                    .applicantCount(applicantCount)
                    .submittedCount(submittedCount)
                    .submissionRate(submissionRate)
                    .build();
        }).collect(Collectors.toList());
    }
}
