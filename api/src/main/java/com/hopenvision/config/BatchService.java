package com.hopenvision.config;

import com.hopenvision.exam.entity.Exam;
import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.repository.ExamRepository;
import com.hopenvision.exam.repository.ExamSubjectRepository;
import com.hopenvision.user.entity.UserScore;
import com.hopenvision.user.entity.UserTotalScore;
import com.hopenvision.user.repository.UserScoreRepository;
import com.hopenvision.user.repository.UserTotalScoreRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 배치 서비스 — 순위 계산, 백분위, 표준점수, 통계 집계
 * Spring Batch 대신 경량 Service 기반 구현
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class BatchService {

    private final ExamRepository examRepository;
    private final ExamSubjectRepository subjectRepository;
    private final UserTotalScoreRepository userTotalScoreRepository;
    private final UserScoreRepository userScoreRepository;

    /**
     * 시험별 전체 배치 실행 (순위 + 백분위 + 표준점수)
     */
    @Transactional
    public Map<String, Object> runBatch(String examCd) {
        log.info("배치 시작: examCd={}", examCd);
        long start = System.currentTimeMillis();

        int rankingCount = calculateTotalRanking(examCd);
        int subjectRankCount = calculateSubjectRanking(examCd);
        int percentileCount = calculatePercentile(examCd);
        int standardScoreCount = calculateStandardScore(examCd);

        long elapsed = System.currentTimeMillis() - start;
        log.info("배치 완료: examCd={}, 소요시간={}ms", examCd, elapsed);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("examCd", examCd);
        result.put("totalRankingUpdated", rankingCount);
        result.put("subjectRankingUpdated", subjectRankCount);
        result.put("percentileUpdated", percentileCount);
        result.put("standardScoreUpdated", standardScoreCount);
        result.put("elapsedMs", elapsed);
        result.put("executedAt", LocalDateTime.now().toString());
        return result;
    }

    /**
     * 전체 순위 계산 (4.3.1)
     */
    @Transactional
    public int calculateTotalRanking(String examCd) {
        List<UserTotalScore> scores = userTotalScoreRepository.findByExamCdOrderByTotalScoreDesc(examCd);
        if (scores.isEmpty()) return 0;

        int rank = 0;
        int sameCount = 0;
        BigDecimal prevScore = null;

        for (UserTotalScore ts : scores) {
            sameCount++;
            if (prevScore == null || ts.getTotalScore().compareTo(prevScore) != 0) {
                rank = sameCount;
            }
            ts.setTotalRanking(rank);
            prevScore = ts.getTotalScore();
        }

        return scores.size();
    }

    /**
     * 과목별 순위 계산
     */
    @Transactional
    public int calculateSubjectRanking(String examCd) {
        List<ExamSubject> subjects = subjectRepository.findByExamCdOrderBySortOrder(examCd);
        int totalUpdated = 0;

        for (ExamSubject subject : subjects) {
            List<UserScore> scores = userScoreRepository.findByExamCdAndSubjectCdOrderByScore(examCd, subject.getSubjectCd());
            int rank = 0;
            int sameCount = 0;
            BigDecimal prevScore = null;

            for (UserScore us : scores) {
                sameCount++;
                if (prevScore == null || us.getRawScore().compareTo(prevScore) != 0) {
                    rank = sameCount;
                }
                us.setRanking(rank);
                prevScore = us.getRawScore();
            }
            totalUpdated += scores.size();
        }

        return totalUpdated;
    }

    /**
     * 백분위 계산 (4.3.4)
     */
    @Transactional
    public int calculatePercentile(String examCd) {
        List<UserTotalScore> scores = userTotalScoreRepository.findByExamCdOrderByTotalScoreDesc(examCd);
        if (scores.isEmpty()) return 0;

        long total = scores.size();

        for (UserTotalScore ts : scores) {
            long lowerCount = scores.stream()
                    .filter(s -> s.getTotalScore().compareTo(ts.getTotalScore()) < 0)
                    .count();
            BigDecimal percentile = BigDecimal.valueOf(lowerCount)
                    .multiply(BigDecimal.valueOf(100))
                    .divide(BigDecimal.valueOf(total), 2, RoundingMode.HALF_UP);
            ts.setPercentile(percentile);
        }

        // 과목별 백분위
        List<ExamSubject> subjects = subjectRepository.findByExamCdOrderBySortOrder(examCd);
        for (ExamSubject subject : subjects) {
            List<UserScore> subjectScores = userScoreRepository.findByExamCdAndSubjectCdOrderByScore(examCd, subject.getSubjectCd());
            long subTotal = subjectScores.size();
            for (UserScore us : subjectScores) {
                long lower = subjectScores.stream()
                        .filter(s -> s.getRawScore().compareTo(us.getRawScore()) < 0)
                        .count();
                BigDecimal pct = BigDecimal.valueOf(lower)
                        .multiply(BigDecimal.valueOf(100))
                        .divide(BigDecimal.valueOf(Math.max(1, subTotal)), 2, RoundingMode.HALF_UP);
                us.setPercentile(pct);
            }
        }

        return scores.size();
    }

    /**
     * 표준점수 산출 (T-004)
     * 표준점수 = ((원점수 - 평균) / 표준편차) * 20 + 100
     */
    @Transactional
    public int calculateStandardScore(String examCd) {
        List<UserTotalScore> scores = userTotalScoreRepository.findByExamCdOrderByTotalScoreDesc(examCd);
        if (scores.size() < 2) return 0;

        // 전체 총점 기준 표준점수
        double[] totalScores = scores.stream()
                .mapToDouble(s -> s.getTotalScore().doubleValue())
                .toArray();
        double mean = Arrays.stream(totalScores).average().orElse(0);
        double variance = Arrays.stream(totalScores).map(s -> Math.pow(s - mean, 2)).average().orElse(0);
        double stdDev = Math.sqrt(variance);

        if (stdDev == 0) return 0;

        for (UserTotalScore ts : scores) {
            double raw = ts.getTotalScore().doubleValue();
            double standardScore = ((raw - mean) / stdDev) * 20 + 100;
            ts.setStandardScore(BigDecimal.valueOf(standardScore).setScale(2, RoundingMode.HALF_UP));
            ts.setBatchYn("Y");
        }

        // 과목별 표준점수
        List<ExamSubject> subjects = subjectRepository.findByExamCdOrderBySortOrder(examCd);
        for (ExamSubject subject : subjects) {
            List<UserScore> subjectScores = userScoreRepository.findByExamCdAndSubjectCdOrderByScore(
                    examCd, subject.getSubjectCd());
            if (subjectScores.size() < 2) continue;

            double[] rawScores = subjectScores.stream()
                    .mapToDouble(s -> s.getRawScore().doubleValue())
                    .toArray();
            double subMean = Arrays.stream(rawScores).average().orElse(0);
            double subVar = Arrays.stream(rawScores).map(s -> Math.pow(s - subMean, 2)).average().orElse(0);
            double subStdDev = Math.sqrt(subVar);

            if (subStdDev == 0) continue;

            for (UserScore us : subjectScores) {
                double raw = us.getRawScore().doubleValue();
                double ss = ((raw - subMean) / subStdDev) * 20 + 100;
                us.setStandardScore(BigDecimal.valueOf(ss).setScale(2, RoundingMode.HALF_UP));
            }
        }

        return scores.size();
    }

    /**
     * 모든 사용 중인 시험에 대해 배치 실행
     */
    @Transactional
    public List<Map<String, Object>> runAllBatches() {
        List<Exam> exams = examRepository.findByIsUse("Y");
        List<Map<String, Object>> results = new ArrayList<>();
        for (Exam exam : exams) {
            try {
                results.add(runBatch(exam.getExamCd()));
            } catch (Exception e) {
                log.error("배치 실패: examCd={}", exam.getExamCd(), e);
                Map<String, Object> error = new LinkedHashMap<>();
                error.put("examCd", exam.getExamCd());
                error.put("error", e.getMessage());
                results.add(error);
            }
        }
        return results;
    }
}
