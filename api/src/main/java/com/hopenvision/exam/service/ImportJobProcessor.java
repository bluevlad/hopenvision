package com.hopenvision.exam.service;

import com.hopenvision.exam.entity.*;
import com.hopenvision.exam.repository.*;
import com.hopenvision.user.entity.UserProfile;
import com.hopenvision.user.repository.UserProfileRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;

/**
 * Import Job의 개별 행 처리 (트랜잭션 적용을 위해 별도 Bean 분리)
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ImportJobProcessor {

    private final ExamApplicantRepository applicantRepository;
    private final ExamApplicantAnsRepository ansRepository;
    private final ExamApplicantScoreRepository scoreRepository;
    private final ExamAnswerKeyRepository answerKeyRepository;
    private final SubjectMasterRepository subjectMasterRepository;
    private final QuestionBankGroupRepository questionBankGroupRepository;
    private final QuestionBankItemRepository questionBankItemRepository;
    private final UserProfileRepository userProfileRepository;

    private static final Random RANDOM = new Random();

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

        // 응시자 총점/평균 자동 갱신
        updateApplicantTotalScore(csvExamCd, userId);
    }

    /**
     * 응시자의 전체 과목 점수를 합산하여 총점/평균/순위 업데이트
     */
    private void updateApplicantTotalScore(String examCd, String applicantNo) {
        ExamApplicantId appId = new ExamApplicantId(examCd, applicantNo);
        ExamApplicant applicant = applicantRepository.findById(appId).orElse(null);
        if (applicant == null) return;

        // 해당 응시자의 모든 과목 점수 조회
        List<ExamApplicantScore> scores = scoreRepository.findByExamCdAndApplicantNo(examCd, applicantNo);
        if (scores.isEmpty()) return;

        BigDecimal sumScore = BigDecimal.ZERO;
        for (ExamApplicantScore s : scores) {
            if (s.getRawScore() != null) {
                sumScore = sumScore.add(s.getRawScore());
            }
        }
        BigDecimal avgScore = sumScore.divide(BigDecimal.valueOf(scores.size()), 2, java.math.RoundingMode.HALF_UP);

        applicant.setTotalScore(sumScore);
        applicant.setAvgScore(avgScore);
        applicant.setScoreStatus("Y");
        applicantRepository.save(applicant);
    }

    // ==================== Helper ====================

    @lombok.AllArgsConstructor
    static class AnswerInfo {
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
