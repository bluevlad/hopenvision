package com.hopenvision.exam.service;

import com.hopenvision.exam.dto.StatisticsDto;
import com.hopenvision.exam.entity.Exam;
import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.repository.ExamRepository;
import com.hopenvision.exam.repository.ExamSubjectRepository;
import com.hopenvision.user.repository.UserScoreRepository;
import com.hopenvision.user.repository.UserTotalScoreRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class StatisticsService {

    private final ExamRepository examRepository;
    private final ExamSubjectRepository subjectRepository;
    private final UserTotalScoreRepository userTotalScoreRepository;
    private final UserScoreRepository userScoreRepository;

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
}
