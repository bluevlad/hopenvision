package com.hopenvision.user.service;

import com.hopenvision.exam.entity.Exam;
import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.repository.ExamRepository;
import com.hopenvision.exam.repository.ExamSubjectRepository;
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
