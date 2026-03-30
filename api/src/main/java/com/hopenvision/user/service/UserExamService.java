package com.hopenvision.user.service;

import com.hopenvision.exam.entity.Exam;
import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.entity.QuestionBankItem;
import com.hopenvision.exam.entity.QuestionSetItem;
import com.hopenvision.exam.repository.ExamRepository;
import com.hopenvision.exam.repository.ExamSubjectRepository;
import com.hopenvision.exam.repository.QuestionBankItemRepository;
import com.hopenvision.exam.repository.QuestionSetItemRepository;
import com.hopenvision.user.dto.ExamQuestionDto;
import com.hopenvision.user.dto.HistoryDto;
import com.hopenvision.user.dto.UserExamDto;
import jakarta.persistence.EntityNotFoundException;
import com.hopenvision.user.entity.UserTotalScore;
import com.hopenvision.user.repository.UserAnswerRepository;
import com.hopenvision.user.repository.UserTotalScoreRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserExamService {

    private final ExamRepository examRepository;
    private final ExamSubjectRepository examSubjectRepository;
    private final QuestionBankItemRepository questionBankItemRepository;
    private final QuestionSetItemRepository questionSetItemRepository;
    private final UserAnswerRepository userAnswerRepository;
    private final UserTotalScoreRepository userTotalScoreRepository;

    public List<UserExamDto> getAvailableExams(String userId) {
        List<Exam> exams = examRepository.findByIsUseOrderByRegDtDesc("Y");

        if (exams.isEmpty()) {
            return Collections.emptyList();
        }

        List<String> examCds = exams.stream().map(Exam::getExamCd).collect(Collectors.toList());

        // 배치 조회: 전체 과목을 한 번에 조회 후 시험별로 그룹핑
        Map<String, List<ExamSubject>> subjectsByExam = examSubjectRepository
                .findByExamCdInOrderBySortOrder(examCds).stream()
                .collect(Collectors.groupingBy(ExamSubject::getExamCd));

        // 배치 조회: 시험별 응시자 수
        Map<String, Long> applicantCounts = new HashMap<>();
        for (Object[] row : userTotalScoreRepository.countByExamCdIn(examCds)) {
            applicantCounts.put((String) row[0], (Long) row[1]);
        }

        // 배치 조회: 사용자가 제출한 시험 목록
        Set<String> submittedExamCds = new HashSet<>(
                userAnswerRepository.findSubmittedExamCds(userId, examCds));

        return exams.stream().map(exam -> {
            List<ExamSubject> subjects = subjectsByExam.getOrDefault(exam.getExamCd(), Collections.emptyList());
            Long applicantCount = applicantCounts.getOrDefault(exam.getExamCd(), 0L);
            boolean hasSubmitted = submittedExamCds.contains(exam.getExamCd());

            return UserExamDto.builder()
                    .examCd(exam.getExamCd())
                    .examNm(exam.getExamNm())
                    .examType(exam.getExamType())
                    .examYear(exam.getExamYear())
                    .examRound(exam.getExamRound())
                    .examDate(exam.getExamDate())
                    .totalScore(exam.getTotalScore())
                    .passScore(exam.getPassScore())
                    .applicantCount(applicantCount)
                    .hasSubmitted(hasSubmitted)
                    .subjects(subjects.stream()
                            .map(s -> UserExamDto.SubjectInfo.builder()
                                    .subjectCd(s.getSubjectCd())
                                    .subjectNm(s.getSubjectNm())
                                    .subjectType(s.getSubjectType())
                                    .questionCnt(s.getQuestionCnt())
                                    .scorePerQ(s.getScorePerQ())
                                    .questionType(s.getQuestionType())
                                    .cutLine(s.getCutLine())
                                    .timeLimit(s.getTimeLimit())
                                    .groupId(s.getGroupId())
                                    .build())
                            .collect(Collectors.toList()))
                    .build();
        }).collect(Collectors.toList());
    }

    public UserExamDto getExamDetail(String userId, String examCd) {
        Exam exam = examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        List<ExamSubject> subjects = examSubjectRepository.findByExamCdOrderBySortOrder(examCd);
        Long applicantCount = userTotalScoreRepository.countByExamCd(examCd);
        boolean hasSubmitted = userAnswerRepository.existsByIdUserIdAndIdExamCd(userId, examCd);

        return UserExamDto.builder()
                .examCd(exam.getExamCd())
                .examNm(exam.getExamNm())
                .examType(exam.getExamType())
                .examYear(exam.getExamYear())
                .examRound(exam.getExamRound())
                .examDate(exam.getExamDate())
                .totalScore(exam.getTotalScore())
                .passScore(exam.getPassScore())
                .applicantCount(applicantCount)
                .hasSubmitted(hasSubmitted)
                .subjects(subjects.stream()
                        .map(s -> UserExamDto.SubjectInfo.builder()
                                .subjectCd(s.getSubjectCd())
                                .subjectNm(s.getSubjectNm())
                                .subjectType(s.getSubjectType())
                                .questionCnt(s.getQuestionCnt())
                                .scorePerQ(s.getScorePerQ())
                                .questionType(s.getQuestionType())
                                .cutLine(s.getCutLine())
                                .build())
                        .collect(Collectors.toList()))
                .build();
    }

    public ExamQuestionDto getSubjectQuestions(String examCd, String subjectCd) {
        ExamSubject subject = examSubjectRepository.findById(
                new com.hopenvision.exam.entity.ExamSubjectId(examCd, subjectCd))
                .orElseThrow(() -> new EntityNotFoundException(
                        "과목을 찾을 수 없습니다: " + examCd + "/" + subjectCd));

        // 시험에 연결된 문제세트에서 먼저 조회
        Exam exam = examRepository.findById(examCd).orElse(null);
        List<QuestionBankItem> items;

        if (exam != null && exam.getQuestionSetId() != null) {
            // 문제세트에서 해당 과목 문제 로딩
            List<QuestionSetItem> setItems = questionSetItemRepository
                    .findBySetIdAndSubjectCdOrderBySortOrder(exam.getQuestionSetId(), subjectCd);
            if (setItems.isEmpty()) {
                throw new EntityNotFoundException("문제세트에 해당 과목의 문제가 없습니다: " + subjectCd);
            }
            List<Long> itemIds = setItems.stream()
                    .map(QuestionSetItem::getItemId)
                    .collect(Collectors.toList());
            items = questionBankItemRepository.findAllById(itemIds);
            // 세트 내 정렬 순서 유지
            Map<Long, Integer> orderMap = new HashMap<>();
            for (int i = 0; i < setItems.size(); i++) {
                orderMap.put(setItems.get(i).getItemId(), i);
            }
            items.sort(Comparator.comparingInt(item -> orderMap.getOrDefault(item.getItemId(), 999)));
        } else if (subject.getGroupId() != null) {
            // 기존 방식: groupId로 문제은행에서 로딩
            items = questionBankItemRepository
                    .findByGroupIdAndSubjectCdOrderByQuestionNo(subject.getGroupId(), subjectCd);
        } else {
            throw new EntityNotFoundException("해당 과목에 연결된 문제가 없습니다: " + subjectCd);
        }

        List<ExamQuestionDto.QuestionItem> questions = items.stream()
                .map(item -> {
                    List<String> choices = new ArrayList<>();
                    if (item.getChoice1() != null) choices.add(item.getChoice1());
                    if (item.getChoice2() != null) choices.add(item.getChoice2());
                    if (item.getChoice3() != null) choices.add(item.getChoice3());
                    if (item.getChoice4() != null) choices.add(item.getChoice4());
                    if (item.getChoice5() != null) choices.add(item.getChoice5());

                    return ExamQuestionDto.QuestionItem.builder()
                            .questionNo(item.getQuestionNo())
                            .questionText(item.getQuestionText())
                            .contextText(item.getContextText())
                            .choices(choices)
                            .imageUrl(item.getImageFile())
                            .build();
                })
                .collect(Collectors.toList());

        return ExamQuestionDto.builder()
                .subjectCd(subject.getSubjectCd())
                .subjectNm(subject.getSubjectNm())
                .timeLimit(subject.getTimeLimit())
                .questionCnt(subject.getQuestionCnt())
                .questions(questions)
                .build();
    }

    public List<HistoryDto.HistoryItem> getUserHistory(String userId) {
        List<UserTotalScore> scores = userTotalScoreRepository.findByUserIdOrderByRegDtDesc(userId);

        List<String> examCds = scores.stream().map(UserTotalScore::getExamCd).collect(Collectors.toList());
        Map<String, String> examNames = examRepository.findAllById(examCds).stream()
                .collect(Collectors.toMap(Exam::getExamCd, Exam::getExamNm));

        return scores.stream().map(score -> HistoryDto.HistoryItem.builder()
                .examCd(score.getExamCd())
                .examNm(examNames.getOrDefault(score.getExamCd(), score.getExamCd()))
                .totalScore(score.getTotalScore())
                .avgScore(score.getAvgScore())
                .passYn(score.getPassYn())
                .regDt(score.getRegDt())
                .build()
        ).collect(Collectors.toList());
    }
}
