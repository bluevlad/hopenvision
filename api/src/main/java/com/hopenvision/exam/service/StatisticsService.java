package com.hopenvision.exam.service;

import com.hopenvision.exam.dto.StatisticsDto;
import com.hopenvision.exam.entity.Exam;
import com.hopenvision.exam.entity.ExamAnswerKey;
import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.repository.ExamAnswerKeyRepository;
import com.hopenvision.exam.repository.ExamApplicantRepository;
import com.hopenvision.exam.repository.ExamApplicantScoreRepository;
import com.hopenvision.exam.repository.ExamRepository;
import com.hopenvision.exam.repository.ExamSubjectRepository;
import com.hopenvision.user.entity.UserAnswer;
import com.hopenvision.user.entity.UserScore;
import com.hopenvision.user.entity.UserTotalScore;
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
    private final ExamApplicantScoreRepository applicantScoreRepository;
    private final UserTotalScoreRepository userTotalScoreRepository;
    private final UserScoreRepository userScoreRepository;
    private final UserAnswerRepository userAnswerRepository;

    public StatisticsDto.ExamStatistics getExamStatistics(String examCd) {
        Exam exam = examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        long totalApplicants = applicantRepository.countByExamCd(examCd);
        long passedCount = applicantRepository.countPassedByExamCd(examCd);
        BigDecimal avgScore = applicantRepository.avgScoreByExamCd(examCd);
        BigDecimal maxScore = applicantRepository.maxScoreByExamCd(examCd);
        BigDecimal minScore = applicantRepository.minScoreByExamCd(examCd);

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
        for (Object[] row : applicantScoreRepository.getSubjectStatsBatch(examCd)) {
            subjectStatsMap.put((String) row[0], row);
        }

        List<StatisticsDto.SubjectStatistics> subjectStats = subjects.stream()
                .map(subject -> {
                    Object[] stats = subjectStatsMap.get(subject.getSubjectCd());
                    long subjectCount = stats != null ? (Long) stats[1] : 0;
                    BigDecimal subAvg = stats != null && stats[2] != null ? new BigDecimal(stats[2].toString()).setScale(2, RoundingMode.HALF_UP) : null;
                    BigDecimal subMax = stats != null ? (BigDecimal) stats[3] : null;
                    BigDecimal subMin = stats != null ? (BigDecimal) stats[4] : null;

                    return StatisticsDto.SubjectStatistics.builder()
                            .subjectCd(subject.getSubjectCd())
                            .subjectNm(subject.getSubjectNm())
                            .applicantCount(subjectCount)
                            .avgScore(subAvg)
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
        // DB에서 점수 분포를 단일 쿼리로 계산
        List<Object[]> distRows = applicantRepository.getScoreDistribution(examCd);
        Object[] distResult = distRows != null && !distRows.isEmpty() ? distRows.get(0) : null;

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

        // 채점 완료 수 일괄 조회
        Map<String, Long> submittedCounts = new HashMap<>();
        for (Object[] row : applicantRepository.countScoredByExamCdIn(examCds)) {
            submittedCounts.put((String) row[0], ((Number) row[1]).longValue());
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

    /**
     * 성적 추이 — 사용자의 회차별 과목 점수 변화 (S-014, T-009)
     */
    public List<StatisticsDto.ScoreTrendItem> getScoreTrend(String userId) {
        List<UserTotalScore> totals = userTotalScoreRepository.findByUserIdOrderByRegDtDesc(userId);
        if (totals.isEmpty()) return List.of();

        List<StatisticsDto.ScoreTrendItem> result = new ArrayList<>();

        for (UserTotalScore ts : totals) {
            Exam exam = examRepository.findById(ts.getExamCd()).orElse(null);
            if (exam == null) continue;

            List<UserScore> userScores = userScoreRepository.findByUserIdAndExamCd(userId, ts.getExamCd());
            List<ExamSubject> subjects = subjectRepository.findByExamCdOrderBySortOrder(ts.getExamCd());
            Map<String, String> subjectNames = subjects.stream()
                    .collect(Collectors.toMap(ExamSubject::getSubjectCd, ExamSubject::getSubjectNm));

            List<StatisticsDto.SubjectScoreItem> subjectScores = new ArrayList<>();
            for (UserScore us : userScores) {
                subjectScores.add(StatisticsDto.SubjectScoreItem.builder()
                        .subjectCd(us.getId().getSubjectCd())
                        .subjectNm(subjectNames.getOrDefault(us.getId().getSubjectCd(), us.getId().getSubjectCd()))
                        .score(us.getRawScore())
                        .build());
            }

            result.add(StatisticsDto.ScoreTrendItem.builder()
                    .examCd(ts.getExamCd())
                    .examNm(exam.getExamNm())
                    .totalScore(ts.getTotalScore())
                    .avgScore(ts.getAvgScore())
                    .passYn(ts.getPassYn())
                    .regDt(ts.getRegDt() != null ? ts.getRegDt().toString() : null)
                    .subjectScores(subjectScores)
                    .build());
        }

        // 오래된 순으로 정렬 (차트에서 왼→오 시간 흐름)
        Collections.reverse(result);
        return result;
    }

    /**
     * 약점 과목 진단 — 과목별 정답률 분석 (T-013)
     */
    public List<StatisticsDto.WeaknessAnalysis> getWeaknessAnalysis(String userId, String examCd) {
        examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        List<UserScore> userScores = userScoreRepository.findByUserIdAndExamCd(userId, examCd);
        List<ExamSubject> subjects = subjectRepository.findByExamCdOrderBySortOrder(examCd);
        Map<String, ExamSubject> subjectMap = subjects.stream()
                .collect(Collectors.toMap(ExamSubject::getSubjectCd, s -> s));

        List<StatisticsDto.WeaknessAnalysis> result = new ArrayList<>();
        for (UserScore us : userScores) {
            ExamSubject subject = subjectMap.get(us.getId().getSubjectCd());
            int total = (us.getCorrectCnt() != null ? us.getCorrectCnt() : 0) + (us.getWrongCnt() != null ? us.getWrongCnt() : 0);
            BigDecimal correctRate = total > 0
                    ? BigDecimal.valueOf(us.getCorrectCnt()).multiply(BigDecimal.valueOf(100))
                            .divide(BigDecimal.valueOf(total), 2, RoundingMode.HALF_UP)
                    : BigDecimal.ZERO;

            String level;
            if (correctRate.compareTo(BigDecimal.valueOf(80)) >= 0) level = "강점";
            else if (correctRate.compareTo(BigDecimal.valueOf(60)) >= 0) level = "보통";
            else if (correctRate.compareTo(BigDecimal.valueOf(40)) >= 0) level = "주의";
            else level = "약점";

            result.add(StatisticsDto.WeaknessAnalysis.builder()
                    .subjectCd(us.getId().getSubjectCd())
                    .subjectNm(subject != null ? subject.getSubjectNm() : us.getId().getSubjectCd())
                    .correctRate(correctRate)
                    .level(level)
                    .correctCnt(us.getCorrectCnt() != null ? us.getCorrectCnt() : 0)
                    .wrongCnt(us.getWrongCnt() != null ? us.getWrongCnt() : 0)
                    .totalQuestions(total)
                    .build());
        }
        result.sort(Comparator.comparing(StatisticsDto.WeaknessAnalysis::getCorrectRate));
        return result;
    }

    /**
     * 문항 변별력 지수 산출 (T-007)
     * 상위 27% 정답률 - 하위 27% 정답률
     */
    public List<StatisticsDto.DiscriminationDetail> getDiscriminationIndex(String examCd, String subjectCd) {
        // 해당 과목 응시자의 총점 기준으로 상/하위 27% 구분
        List<UserScore> allScores = userScoreRepository.findByExamCdAndSubjectCdOrderByScore(examCd, subjectCd);
        if (allScores.size() < 4) return List.of(); // 최소 4명 필요

        int n27 = Math.max(1, (int) Math.round(allScores.size() * 0.27));
        Set<String> topUsers = new HashSet<>();
        for (UserScore us : allScores.subList(0, n27)) {
            topUsers.add(us.getId().getUserId());
        }
        Set<String> bottomUsers = new HashSet<>();
        for (UserScore us : allScores.subList(allScores.size() - n27, allScores.size())) {
            bottomUsers.add(us.getId().getUserId());
        }

        // 문항별 정답 데이터
        List<Object[]> answers = userAnswerRepository.getAnswersByExamAndSubject(examCd, subjectCd);
        // questionNo -> {top correct, top total, bottom correct, bottom total}
        Map<Integer, int[]> qStats = new HashMap<>();

        for (Object[] row : answers) {
            String uid = (String) row[0];
            int qNo = ((Number) row[1]).intValue();
            boolean correct = "Y".equals(row[2]);

            qStats.computeIfAbsent(qNo, k -> new int[4]);
            int[] stats = qStats.get(qNo);

            if (topUsers.contains(uid)) {
                stats[1]++;
                if (correct) stats[0]++;
            }
            if (bottomUsers.contains(uid)) {
                stats[3]++;
                if (correct) stats[2]++;
            }
        }

        // 전체 정답률도 계산
        List<Object[]> correctRates = userAnswerRepository.getQuestionCorrectRates(examCd);
        Map<String, long[]> rateMap = new HashMap<>();
        for (Object[] row : correctRates) {
            if (subjectCd.equals(row[0])) {
                rateMap.put(row[1].toString(), new long[]{((Number) row[2]).longValue(), ((Number) row[3]).longValue()});
            }
        }

        List<Integer> questionNos = new ArrayList<>(qStats.keySet());
        Collections.sort(questionNos);

        return questionNos.stream().map(qNo -> {
            int[] stats = qStats.get(qNo);
            BigDecimal topRate = stats[1] > 0 ? BigDecimal.valueOf(stats[0]).divide(BigDecimal.valueOf(stats[1]), 4, RoundingMode.HALF_UP) : BigDecimal.ZERO;
            BigDecimal bottomRate = stats[3] > 0 ? BigDecimal.valueOf(stats[2]).divide(BigDecimal.valueOf(stats[3]), 4, RoundingMode.HALF_UP) : BigDecimal.ZERO;
            BigDecimal di = topRate.subtract(bottomRate).setScale(2, RoundingMode.HALF_UP);

            long[] rates = rateMap.getOrDefault(String.valueOf(qNo), new long[]{0, 1});
            BigDecimal cr = BigDecimal.valueOf(rates[0]).multiply(BigDecimal.valueOf(100))
                    .divide(BigDecimal.valueOf(Math.max(1, rates[1])), 2, RoundingMode.HALF_UP);

            String difficulty = cr.compareTo(BigDecimal.valueOf(70)) >= 0 ? "상(쉬움)" :
                    cr.compareTo(BigDecimal.valueOf(40)) >= 0 ? "중(보통)" : "하(어려움)";

            String diLevel = di.compareTo(BigDecimal.valueOf(0.4)) >= 0 ? "우수" :
                    di.compareTo(BigDecimal.valueOf(0.2)) >= 0 ? "양호" : "부적절";

            return StatisticsDto.DiscriminationDetail.builder()
                    .questionNo(qNo)
                    .correctRate(cr)
                    .difficulty(difficulty)
                    .discriminationIndex(di)
                    .discriminationLevel(diLevel)
                    .build();
        }).collect(Collectors.toList());
    }

    /**
     * 합격 예측 (T-015)
     */
    public StatisticsDto.PassPrediction getPassPrediction(String userId, String examCd) {
        Exam exam = examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        UserTotalScore ts = userTotalScoreRepository.findByUserIdAndExamCd(userId, examCd)
                .orElseThrow(() -> new EntityNotFoundException("채점 결과를 찾을 수 없습니다."));

        long totalApplicants = userTotalScoreRepository.countByExamCd(examCd);
        long passedCount = userTotalScoreRepository.countPassedByExamCd(examCd);
        BigDecimal passRate = totalApplicants > 0
                ? BigDecimal.valueOf(passedCount).multiply(BigDecimal.valueOf(100))
                        .divide(BigDecimal.valueOf(totalApplicants), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        BigDecimal examPassScore = exam.getPassScore() != null ? exam.getPassScore() : BigDecimal.valueOf(60);
        BigDecimal myAvg = ts.getAvgScore() != null ? ts.getAvgScore() : BigDecimal.ZERO;
        BigDecimal gap = myAvg.subtract(examPassScore);

        Long lowerCount = userTotalScoreRepository.countByExamCdAndScoreLessThanOrEqual(examCd, ts.getTotalScore());
        BigDecimal percentile = totalApplicants > 0
                ? BigDecimal.valueOf(lowerCount).multiply(BigDecimal.valueOf(100))
                        .divide(BigDecimal.valueOf(totalApplicants), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        String prediction;
        if ("Y".equals(ts.getPassYn())) {
            prediction = "합격권";
        } else if ("Y".equals(ts.getCutFailYn())) {
            prediction = "과락 — 약점 과목 집중 필요";
        } else if (gap.compareTo(BigDecimal.valueOf(-5)) >= 0) {
            prediction = "합격 근접 — 소폭 향상 필요";
        } else if (gap.compareTo(BigDecimal.valueOf(-15)) >= 0) {
            prediction = "노력 필요 — 전 과목 보강 필요";
        } else {
            prediction = "기초 보강 필요";
        }

        return StatisticsDto.PassPrediction.builder()
                .myTotalScore(ts.getTotalScore())
                .myAvgScore(myAvg)
                .examPassScore(examPassScore)
                .currentPassLine(examPassScore)
                .gapToPassLine(gap)
                .prediction(prediction)
                .percentile(percentile)
                .totalApplicants(totalApplicants)
                .passedCount(passedCount)
                .passRate(passRate)
                .build();
    }

    /**
     * 오답 유형 분석 (T-016)
     */
    public List<StatisticsDto.WrongAnswerPattern> getWrongAnswerPatterns(String userId, String examCd) {
        examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        List<ExamSubject> subjects = subjectRepository.findByExamCdOrderBySortOrder(examCd);
        List<UserAnswer> allAnswers = userAnswerRepository.findByUserIdAndExamCd(userId, examCd);
        Map<String, List<UserAnswer>> bySubject = allAnswers.stream()
                .collect(Collectors.groupingBy(ua -> ua.getId().getSubjectCd()));

        List<StatisticsDto.WrongAnswerPattern> result = new ArrayList<>();

        for (ExamSubject subject : subjects) {
            List<UserAnswer> answers = bySubject.getOrDefault(subject.getSubjectCd(), List.of());
            List<StatisticsDto.WrongQuestionInfo> wrongQuestions = new ArrayList<>();

            for (UserAnswer ua : answers) {
                if ("N".equals(ua.getIsCorrect())) {
                    // 정답 조회
                    ExamAnswerKey key = answerKeyRepository.findByExamCdAndSubjectCdOrderByQuestionNo(examCd, subject.getSubjectCd())
                            .stream().filter(k -> k.getQuestionNo().equals(ua.getId().getQuestionNo()))
                            .findFirst().orElse(null);

                    wrongQuestions.add(StatisticsDto.WrongQuestionInfo.builder()
                            .questionNo(ua.getId().getQuestionNo())
                            .userAns(ua.getUserAns())
                            .correctAns(key != null ? key.getCorrectAns() : "-")
                            .build());
                }
            }

            int totalQ = answers.size();
            BigDecimal wrongRate = totalQ > 0
                    ? BigDecimal.valueOf(wrongQuestions.size()).multiply(BigDecimal.valueOf(100))
                            .divide(BigDecimal.valueOf(totalQ), 2, RoundingMode.HALF_UP)
                    : BigDecimal.ZERO;

            result.add(StatisticsDto.WrongAnswerPattern.builder()
                    .subjectCd(subject.getSubjectCd())
                    .subjectNm(subject.getSubjectNm())
                    .wrongCount(wrongQuestions.size())
                    .totalQuestions(totalQ)
                    .wrongRate(wrongRate)
                    .wrongQuestions(wrongQuestions)
                    .build());
        }

        return result;
    }
}
