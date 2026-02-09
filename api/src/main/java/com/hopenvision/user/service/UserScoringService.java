package com.hopenvision.user.service;

import com.hopenvision.exam.entity.Exam;
import com.hopenvision.exam.entity.ExamAnswerKey;
import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.repository.ExamAnswerKeyRepository;
import com.hopenvision.exam.repository.ExamRepository;
import com.hopenvision.exam.repository.ExamSubjectRepository;
import com.hopenvision.user.dto.ScoringResultDto;
import com.hopenvision.user.dto.UserAnswerDto;
import com.hopenvision.user.entity.*;
import com.hopenvision.user.repository.UserAnswerRepository;
import com.hopenvision.user.repository.UserScoreRepository;
import com.hopenvision.user.repository.UserTotalScoreRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class UserScoringService {

    private final ExamRepository examRepository;
    private final ExamSubjectRepository examSubjectRepository;
    private final ExamAnswerKeyRepository examAnswerKeyRepository;
    private final UserAnswerRepository userAnswerRepository;
    private final UserScoreRepository userScoreRepository;
    private final UserTotalScoreRepository userTotalScoreRepository;

    public ScoringResultDto submitAndScore(String userId, UserAnswerDto.SubmitRequest request) {
        String examCd = request.getExamCd();

        // 1. 시험 정보 조회
        Exam exam = examRepository.findById(examCd)
                .orElseThrow(() -> new RuntimeException("시험을 찾을 수 없습니다: " + examCd));

        // 2. 과목 정보 조회
        List<ExamSubject> subjects = examSubjectRepository.findByExamCdOrderBySortOrder(examCd);
        Map<String, ExamSubject> subjectMap = subjects.stream()
                .collect(Collectors.toMap(ExamSubject::getSubjectCd, s -> s));

        // 3. 정답 조회
        List<ExamAnswerKey> answerKeys = examAnswerKeyRepository.findByExamCdOrderBySubjectCdAscQuestionNoAsc(examCd);
        Map<String, Map<Integer, ExamAnswerKey>> answerKeyMap = new HashMap<>();
        for (ExamAnswerKey key : answerKeys) {
            answerKeyMap
                    .computeIfAbsent(key.getSubjectCd(), k -> new HashMap<>())
                    .put(key.getQuestionNo(), key);
        }

        // 4. 사용자 답안 저장 및 채점
        List<ScoringResultDto.SubjectResult> subjectResults = new ArrayList<>();
        BigDecimal totalScore = BigDecimal.ZERO;
        int totalCorrect = 0;
        int totalWrong = 0;
        int totalQuestions = 0;
        boolean hasCutFail = false;

        for (UserAnswerDto.SubjectAnswer subjectAnswer : request.getSubjects()) {
            String subjectCd = subjectAnswer.getSubjectCd();
            ExamSubject subject = subjectMap.get(subjectCd);
            if (subject == null) continue;

            Map<Integer, ExamAnswerKey> subjectAnswerKeys = answerKeyMap.getOrDefault(subjectCd, new HashMap<>());

            List<ScoringResultDto.QuestionResult> questionResults = new ArrayList<>();
            BigDecimal subjectScore = BigDecimal.ZERO;
            int correctCnt = 0;
            int wrongCnt = 0;

            for (UserAnswerDto.QuestionAnswer qa : subjectAnswer.getAnswers()) {
                ExamAnswerKey answerKey = subjectAnswerKeys.get(qa.getQuestionNo());
                String correctAns = answerKey != null ? answerKey.getCorrectAns() : "";
                boolean isCorrect = correctAns.equals(qa.getAnswer());
                BigDecimal score = BigDecimal.ZERO;

                if (isCorrect && answerKey != null) {
                    score = answerKey.getScore() != null ? answerKey.getScore() : subject.getScorePerQ();
                    subjectScore = subjectScore.add(score);
                    correctCnt++;
                } else {
                    wrongCnt++;
                }

                // 사용자 답안 저장
                UserAnswerId answerId = new UserAnswerId(userId, examCd, subjectCd, qa.getQuestionNo());
                UserAnswer userAnswer = UserAnswer.builder()
                        .id(answerId)
                        .userAns(qa.getAnswer())
                        .isCorrect(isCorrect ? "Y" : "N")
                        .build();
                userAnswerRepository.save(userAnswer);

                questionResults.add(ScoringResultDto.QuestionResult.builder()
                        .questionNo(qa.getQuestionNo())
                        .userAns(qa.getAnswer())
                        .correctAns(correctAns)
                        .isCorrect(isCorrect ? "Y" : "N")
                        .score(score)
                        .build());
            }

            // 과락 체크
            BigDecimal cutLine = subject.getCutLine() != null ? subject.getCutLine() : BigDecimal.valueOf(40);
            boolean isCutFail = subjectScore.compareTo(cutLine) < 0;
            if (isCutFail) hasCutFail = true;

            // 과목 점수 저장
            UserScoreId scoreId = new UserScoreId(userId, examCd, subjectCd);
            UserScore userScore = UserScore.builder()
                    .id(scoreId)
                    .rawScore(subjectScore)
                    .correctCnt(correctCnt)
                    .wrongCnt(wrongCnt)
                    .batchYn("N")
                    .build();
            userScoreRepository.save(userScore);

            int subjectTotalQuestions = subjectAnswer.getAnswers().size();
            BigDecimal correctRate = subjectTotalQuestions > 0
                    ? BigDecimal.valueOf(correctCnt * 100.0 / subjectTotalQuestions).setScale(1, RoundingMode.HALF_UP)
                    : BigDecimal.ZERO;

            subjectResults.add(ScoringResultDto.SubjectResult.builder()
                    .subjectCd(subjectCd)
                    .subjectNm(subject.getSubjectNm())
                    .score(subjectScore)
                    .correctCnt(correctCnt)
                    .wrongCnt(wrongCnt)
                    .totalQuestions(subjectTotalQuestions)
                    .correctRate(correctRate)
                    .cutLine(cutLine)
                    .cutFailYn(isCutFail ? "Y" : "N")
                    .questionResults(questionResults)
                    .build());

            totalScore = totalScore.add(subjectScore);
            totalCorrect += correctCnt;
            totalWrong += wrongCnt;
            totalQuestions += subjectTotalQuestions;
        }

        // 5. 총점 저장
        BigDecimal avgScore = !subjectResults.isEmpty()
                ? totalScore.divide(BigDecimal.valueOf(subjectResults.size()), 2, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        UserTotalScore totalScoreEntity = UserTotalScore.builder()
                .userId(userId)
                .examCd(examCd)
                .totalScore(totalScore)
                .avgScore(avgScore)
                .cutFailYn(hasCutFail ? "Y" : "N")
                .passYn(!hasCutFail && avgScore.compareTo(exam.getPassScore()) >= 0 ? "Y" : "N")
                .batchYn("N")
                .build();
        userTotalScoreRepository.save(totalScoreEntity);

        // 6. 임시 순위 계산 (현재까지 채점된 응시자 기준)
        Long totalApplicants = userTotalScoreRepository.countByExamCd(examCd);
        Long higherScoreCount = userTotalScoreRepository.countByExamCdAndScoreGreaterThan(examCd, totalScore);
        int estimatedRanking = higherScoreCount.intValue() + 1;

        BigDecimal totalCorrectRate = totalQuestions > 0
                ? BigDecimal.valueOf(totalCorrect * 100.0 / totalQuestions).setScale(1, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        return ScoringResultDto.builder()
                .examCd(examCd)
                .examNm(exam.getExamNm())
                .totalScore(totalScore)
                .avgScore(avgScore)
                .totalCorrect(totalCorrect)
                .totalWrong(totalWrong)
                .totalQuestions(totalQuestions)
                .correctRate(totalCorrectRate)
                .estimatedRanking(estimatedRanking)
                .totalApplicants(totalApplicants)
                .passYn(totalScoreEntity.getPassYn())
                .cutFailYn(totalScoreEntity.getCutFailYn())
                .subjectResults(subjectResults)
                .build();
    }

    @Transactional(readOnly = true)
    public ScoringResultDto getMyScore(String userId, String examCd) {
        Exam exam = examRepository.findById(examCd)
                .orElseThrow(() -> new RuntimeException("시험을 찾을 수 없습니다: " + examCd));

        UserTotalScore totalScore = userTotalScoreRepository.findByUserIdAndExamCd(userId, examCd)
                .orElseThrow(() -> new RuntimeException("채점 결과를 찾을 수 없습니다."));

        List<UserScore> userScores = userScoreRepository.findByUserIdAndExamCd(userId, examCd);
        List<UserAnswer> userAnswers = userAnswerRepository.findByUserIdAndExamCd(userId, examCd);

        Map<String, List<UserAnswer>> answersBySubject = userAnswers.stream()
                .collect(Collectors.groupingBy(ua -> ua.getId().getSubjectCd()));

        List<ExamSubject> subjects = examSubjectRepository.findByExamCdOrderBySortOrder(examCd);
        Map<String, ExamSubject> subjectMap = subjects.stream()
                .collect(Collectors.toMap(ExamSubject::getSubjectCd, s -> s));

        List<ExamAnswerKey> answerKeys = examAnswerKeyRepository.findByExamCdOrderBySubjectCdAscQuestionNoAsc(examCd);
        Map<String, Map<Integer, ExamAnswerKey>> answerKeyMap = new HashMap<>();
        for (ExamAnswerKey key : answerKeys) {
            answerKeyMap
                    .computeIfAbsent(key.getSubjectCd(), k -> new HashMap<>())
                    .put(key.getQuestionNo(), key);
        }

        List<ScoringResultDto.SubjectResult> subjectResults = new ArrayList<>();
        int totalCorrect = 0;
        int totalWrong = 0;
        int totalQuestions = 0;

        for (UserScore us : userScores) {
            String subjectCd = us.getId().getSubjectCd();
            ExamSubject subject = subjectMap.get(subjectCd);
            List<UserAnswer> subjectAnswers = answersBySubject.getOrDefault(subjectCd, Collections.emptyList());
            Map<Integer, ExamAnswerKey> subjectAnswerKeys = answerKeyMap.getOrDefault(subjectCd, new HashMap<>());

            List<ScoringResultDto.QuestionResult> questionResults = subjectAnswers.stream()
                    .map(ua -> {
                        ExamAnswerKey ak = subjectAnswerKeys.get(ua.getId().getQuestionNo());
                        BigDecimal questionScore = "Y".equals(ua.getIsCorrect()) && ak != null
                                ? (ak.getScore() != null ? ak.getScore() : subject.getScorePerQ())
                                : BigDecimal.ZERO;
                        return ScoringResultDto.QuestionResult.builder()
                                .questionNo(ua.getId().getQuestionNo())
                                .userAns(ua.getUserAns())
                                .correctAns(ak != null ? ak.getCorrectAns() : "")
                                .isCorrect(ua.getIsCorrect())
                                .score(questionScore)
                                .build();
                    })
                    .sorted(Comparator.comparingInt(ScoringResultDto.QuestionResult::getQuestionNo))
                    .collect(Collectors.toList());

            BigDecimal cutLine = subject != null && subject.getCutLine() != null
                    ? subject.getCutLine() : BigDecimal.valueOf(40);
            int subjectTotalQuestions = questionResults.size();
            BigDecimal correctRate = subjectTotalQuestions > 0
                    ? BigDecimal.valueOf(us.getCorrectCnt() * 100.0 / subjectTotalQuestions).setScale(1, RoundingMode.HALF_UP)
                    : BigDecimal.ZERO;

            subjectResults.add(ScoringResultDto.SubjectResult.builder()
                    .subjectCd(subjectCd)
                    .subjectNm(subject != null ? subject.getSubjectNm() : subjectCd)
                    .score(us.getRawScore())
                    .correctCnt(us.getCorrectCnt())
                    .wrongCnt(us.getWrongCnt())
                    .totalQuestions(subjectTotalQuestions)
                    .correctRate(correctRate)
                    .cutLine(cutLine)
                    .cutFailYn(us.getRawScore().compareTo(cutLine) < 0 ? "Y" : "N")
                    .questionResults(questionResults)
                    .build());

            totalCorrect += us.getCorrectCnt();
            totalWrong += us.getWrongCnt();
            totalQuestions += subjectTotalQuestions;
        }

        Long totalApplicants = userTotalScoreRepository.countByExamCd(examCd);
        BigDecimal totalCorrectRate = totalQuestions > 0
                ? BigDecimal.valueOf(totalCorrect * 100.0 / totalQuestions).setScale(1, RoundingMode.HALF_UP)
                : BigDecimal.ZERO;

        return ScoringResultDto.builder()
                .examCd(examCd)
                .examNm(exam.getExamNm())
                .totalScore(totalScore.getTotalScore())
                .avgScore(totalScore.getAvgScore())
                .totalCorrect(totalCorrect)
                .totalWrong(totalWrong)
                .totalQuestions(totalQuestions)
                .correctRate(totalCorrectRate)
                .estimatedRanking(totalScore.getTotalRanking())
                .totalApplicants(totalApplicants)
                .passYn(totalScore.getPassYn())
                .cutFailYn(totalScore.getCutFailYn())
                .subjectResults(subjectResults)
                .build();
    }
}
