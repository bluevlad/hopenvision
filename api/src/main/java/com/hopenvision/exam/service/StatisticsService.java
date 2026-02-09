package com.hopenvision.exam.service;

import com.hopenvision.exam.dto.StatisticsDto;
import com.hopenvision.exam.entity.Exam;
import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.repository.ExamRepository;
import com.hopenvision.exam.repository.ExamSubjectRepository;
import com.hopenvision.user.entity.UserTotalScore;
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
import java.util.List;
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

        // 과목별 통계
        List<ExamSubject> subjects = subjectRepository.findByExamCdOrderBySortOrder(examCd);
        List<StatisticsDto.SubjectStatistics> subjectStats = subjects.stream()
                .map(subject -> {
                    long subjectCount = userScoreRepository.countByExamCdAndSubjectCd(examCd, subject.getSubjectCd());
                    BigDecimal subAvg = userScoreRepository.avgScoreByExamCdAndSubjectCd(examCd, subject.getSubjectCd());
                    BigDecimal subMax = userScoreRepository.maxScoreByExamCdAndSubjectCd(examCd, subject.getSubjectCd());
                    BigDecimal subMin = userScoreRepository.minScoreByExamCdAndSubjectCd(examCd, subject.getSubjectCd());

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
        List<UserTotalScore> allScores = userTotalScoreRepository.findByExamCdOrderByTotalScoreDesc(examCd);

        String[] ranges = { "90~100", "80~89", "70~79", "60~69", "50~59", "40~49", "30~39", "20~29", "10~19", "0~9" };
        int[][] bounds = { {90, 100}, {80, 89}, {70, 79}, {60, 69}, {50, 59}, {40, 49}, {30, 39}, {20, 29}, {10, 19}, {0, 9} };

        List<StatisticsDto.ScoreDistribution> distributions = new ArrayList<>();

        for (int i = 0; i < ranges.length; i++) {
            int low = bounds[i][0];
            int high = bounds[i][1];
            long count = allScores.stream()
                    .filter(s -> s.getTotalScore() != null)
                    .filter(s -> {
                        int score = s.getTotalScore().intValue();
                        return score >= low && score <= high;
                    })
                    .count();

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
