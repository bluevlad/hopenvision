package com.hopenvision.user.service;

import com.hopenvision.exam.entity.Exam;
import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.repository.ExamRepository;
import com.hopenvision.exam.repository.ExamSubjectRepository;
import com.hopenvision.user.dto.UserExamDto;
import com.hopenvision.user.repository.UserAnswerRepository;
import com.hopenvision.user.repository.UserTotalScoreRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
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

        return exams.stream().map(exam -> {
            List<ExamSubject> subjects = examSubjectRepository.findByExamCdOrderBySortOrder(exam.getExamCd());
            Long applicantCount = userTotalScoreRepository.countByExamCd(exam.getExamCd());
            boolean hasSubmitted = userAnswerRepository.existsByIdUserIdAndIdExamCd(userId, exam.getExamCd());

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
                .orElseThrow(() -> new RuntimeException("시험을 찾을 수 없습니다: " + examCd));

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
}
