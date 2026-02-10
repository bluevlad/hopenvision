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
                .orElseThrow(() -> new RuntimeException("시험을 찾을 수 없습니다: " + examCd));

        UserTotalScore myTotal = userTotalScoreRepository.findByUserIdAndExamCd(userId, examCd)
                .orElseThrow(() -> new RuntimeException("채점 결과를 찾을 수 없습니다."));

        Long totalApplicants = userTotalScoreRepository.countByExamCd(examCd);
        Long higherCount = userTotalScoreRepository.countByExamCdAndScoreGreaterThan(examCd, myTotal.getTotalScore());
        int ranking = higherCount.intValue() + 1;

        // 백분위 계산: (자신보다 낮거나 같은 사람 수 / 전체) * 100
        Long lowerOrEqualCount = userTotalScoreRepository.countByExamCdAndScoreLessThanOrEqual(examCd, myTotal.getTotalScore());
        BigDecimal percentile = totalApplicants > 0
                ? BigDecimal.valueOf(lowerOrEqualCount * 100.0 / totalApplicants).setScale(1, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        // 점수 분포
        List<UserTotalScore> allScores = userTotalScoreRepository.findByExamCdOrderByTotalScoreDesc(examCd);
        List<ScoreAnalysisDto.ScoreDistribution> distributions = buildScoreDistributions(allScores, myTotal.getTotalScore());

        // 과목별 비교
        List<UserScore> myScores = userScoreRepository.findByUserIdAndExamCd(userId, examCd);
        List<ExamSubject> subjects = examSubjectRepository.findByExamCdOrderBySortOrder(examCd);
        Map<String, ExamSubject> subjectMap = subjects.stream()
                .collect(Collectors.toMap(ExamSubject::getSubjectCd, s -> s));

        List<ScoreAnalysisDto.SubjectComparison> subjectComparisons = new ArrayList<>();
        for (UserScore myScore : myScores) {
            String subjectCd = myScore.getId().getSubjectCd();
            ExamSubject subject = subjectMap.get(subjectCd);

            BigDecimal avgScore = userScoreRepository.avgScoreByExamCdAndSubjectCd(examCd, subjectCd);
            BigDecimal maxScore = userScoreRepository.maxScoreByExamCdAndSubjectCd(examCd, subjectCd);
            BigDecimal minScore = userScoreRepository.minScoreByExamCdAndSubjectCd(examCd, subjectCd);
            Long subjectCount = userScoreRepository.countByExamCdAndSubjectCd(examCd, subjectCd);
            Long subjectHigher = userScoreRepository.countByExamCdAndSubjectCdAndScoreGreaterThan(examCd, subjectCd, myScore.getRawScore());

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

    private List<ScoreAnalysisDto.ScoreDistribution> buildScoreDistributions(
            List<UserTotalScore> allScores, BigDecimal myScore) {

        String[][] ranges = {
                {"90~100", "90", "100"},
                {"80~89", "80", "89"},
                {"70~79", "70", "79"},
                {"60~69", "60", "69"},
                {"50~59", "50", "59"},
                {"40~49", "40", "49"},
                {"30~39", "30", "39"},
                {"0~29", "0", "29"},
        };

        int total = allScores.size();
        List<ScoreAnalysisDto.ScoreDistribution> distributions = new ArrayList<>();

        for (String[] range : ranges) {
            BigDecimal low = new BigDecimal(range[1]);
            BigDecimal high = new BigDecimal(range[2]);

            int count = 0;
            for (UserTotalScore score : allScores) {
                BigDecimal s = score.getTotalScore();
                if (s != null && s.compareTo(low) >= 0 && s.compareTo(high) <= 0) {
                    count++;
                }
            }

            boolean isUserInRange = myScore != null
                    && myScore.compareTo(low) >= 0
                    && myScore.compareTo(high) <= 0;

            double percentage = total > 0 ? Math.round(count * 1000.0 / total) / 10.0 : 0;

            distributions.add(ScoreAnalysisDto.ScoreDistribution.builder()
                    .range(range[0])
                    .count(count)
                    .percentage(percentage)
                    .isUserInRange(isUserInRange)
                    .build());
        }

        return distributions;
    }
}
