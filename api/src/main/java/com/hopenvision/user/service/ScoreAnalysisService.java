package com.hopenvision.user.service;

import com.hopenvision.exam.entity.Exam;
import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.repository.ExamRepository;
import com.hopenvision.exam.repository.ExamSubjectRepository;
import com.hopenvision.user.dto.ScoreAnalysisDto;
import com.hopenvision.user.entity.UserScore;
import com.hopenvision.user.entity.UserTotalScore;
import com.hopenvision.user.repository.UserScoreRepository;
import com.hopenvision.user.repository.UserTotalScoreRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ScoreAnalysisService {

    private final ExamRepository examRepository;
    private final ExamSubjectRepository examSubjectRepository;
    private final UserTotalScoreRepository userTotalScoreRepository;
    private final UserScoreRepository userScoreRepository;

    public ScoreAnalysisDto getScoreAnalysis(String userId, String examCd) {
        Exam exam = examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        UserTotalScore myTotal = userTotalScoreRepository.findByUserIdAndExamCd(userId, examCd)
                .orElseThrow(() -> new EntityNotFoundException("채점 결과를 찾을 수 없습니다."));

        Long totalApplicants = userTotalScoreRepository.countByExamCd(examCd);
        Long higherCount = userTotalScoreRepository.countByExamCdAndScoreGreaterThan(examCd, myTotal.getTotalScore());
        int ranking = higherCount.intValue() + 1;

        // 백분위 계산: (자신보다 낮거나 같은 사람 수 / 전체) * 100
        Long lowerOrEqualCount = userTotalScoreRepository.countByExamCdAndScoreLessThanOrEqual(examCd, myTotal.getTotalScore());
        BigDecimal percentile = totalApplicants > 0
                ? BigDecimal.valueOf(lowerOrEqualCount * 100.0 / totalApplicants).setScale(1, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        // 점수 분포 (DB 집계 쿼리 사용)
        List<ScoreAnalysisDto.ScoreDistribution> distributions = buildScoreDistributionsFromDb(examCd, totalApplicants, myTotal.getTotalScore());

        // 과목별 비교 (GROUP BY 배치 쿼리로 N+1 방지)
        List<UserScore> myScores = userScoreRepository.findByUserIdAndExamCd(userId, examCd);
        List<ExamSubject> subjects = examSubjectRepository.findByExamCdOrderBySortOrder(examCd);
        Map<String, ExamSubject> subjectMap = subjects.stream()
                .collect(Collectors.toMap(ExamSubject::getSubjectCd, s -> s));

        // 과목별 통계 + 순위를 단일 쿼리로 일괄 조회
        Map<String, Object[]> subjectStatsMap = new java.util.HashMap<>();
        for (Object[] row : userScoreRepository.getSubjectStatsWithRanking(examCd, userId)) {
            subjectStatsMap.put((String) row[0], row);
        }

        List<ScoreAnalysisDto.SubjectComparison> subjectComparisons = new ArrayList<>();
        for (UserScore myScore : myScores) {
            String subjectCd = myScore.getId().getSubjectCd();
            ExamSubject subject = subjectMap.get(subjectCd);
            Object[] stats = subjectStatsMap.get(subjectCd);

            Long subjectCount = stats != null ? (Long) stats[1] : 0L;
            Double avgDouble = stats != null ? (Double) stats[2] : null;
            BigDecimal avgScore = avgDouble != null ? BigDecimal.valueOf(avgDouble) : null;
            BigDecimal maxScore = stats != null ? (BigDecimal) stats[3] : null;
            BigDecimal minScore = stats != null ? (BigDecimal) stats[4] : null;
            Long subjectHigher = stats != null && stats[5] != null ? ((Number) stats[5]).longValue() : 0L;

            subjectComparisons.add(ScoreAnalysisDto.SubjectComparison.builder()
                    .subjectCd(subjectCd)
                    .subjectNm(subject != null ? subject.getSubjectNm() : subjectCd)
                    .myScore(myScore.getRawScore())
                    .avgScore(avgScore != null ? avgScore.setScale(1, RoundingMode.HALF_UP) : BigDecimal.ZERO)
                    .maxScore(maxScore != null ? maxScore : BigDecimal.ZERO)
                    .minScore(minScore != null ? minScore : BigDecimal.ZERO)
                    .ranking(subjectHigher.intValue() + 1)
                    .totalCount(subjectCount)
                    .build());
        }

        return ScoreAnalysisDto.builder()
                .examCd(examCd)
                .examNm(exam.getExamNm())
                .myTotalScore(myTotal.getTotalScore())
                .myAvgScore(myTotal.getAvgScore())
                .ranking(ranking)
                .totalApplicants(totalApplicants)
                .percentile(percentile)
                .passYn(myTotal.getPassYn())
                .scoreDistributions(distributions)
                .subjectComparisons(subjectComparisons)
                .build();
    }

    private List<ScoreAnalysisDto.ScoreDistribution> buildScoreDistributionsFromDb(
            String examCd, long total, BigDecimal myScore) {

        Object[] dist = userTotalScoreRepository.getScoreDistribution(examCd);

        String[][] ranges = {
                {"90~100", "90", "100"},
                {"80~89", "80", "89"},
                {"70~79", "70", "79"},
                {"60~69", "60", "69"},
                {"50~59", "50", "59"},
                {"40~49", "40", "49"},
                {"30~39", "30", "39"},
                {"20~29", "20", "29"},
                {"10~19", "10", "19"},
                {"0~9", "0", "9"},
        };

        List<ScoreAnalysisDto.ScoreDistribution> distributions = new ArrayList<>();

        for (int i = 0; i < ranges.length && i < dist.length; i++) {
            int count = dist[i] != null ? ((Number) dist[i]).intValue() : 0;
            BigDecimal low = new BigDecimal(ranges[i][1]);
            BigDecimal high = new BigDecimal(ranges[i][2]);

            boolean isUserInRange = myScore != null
                    && myScore.compareTo(low) >= 0
                    && myScore.compareTo(high) <= 0;

            double percentage = total > 0 ? Math.round(count * 1000.0 / total) / 10.0 : 0;

            distributions.add(ScoreAnalysisDto.ScoreDistribution.builder()
                    .range(ranges[i][0])
                    .count(count)
                    .percentage(percentage)
                    .isUserInRange(isUserInRange)
                    .build());
        }

        return distributions;
    }
}
