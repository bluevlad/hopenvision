package com.hopenvision.exam.service;

import com.hopenvision.exam.dto.*;
import com.hopenvision.exam.entity.*;
import com.hopenvision.exam.repository.*;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class ExamService {

    private final ExamRepository examRepository;
    private final ExamSubjectRepository subjectRepository;
    private final ExamAnswerKeyRepository answerKeyRepository;

    /**
     * 시험 목록 조회 (페이징, 검색)
     */
    public Page<ExamDto.Response> getExamList(ExamDto.SearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());

        Page<Exam> examPage = examRepository.searchExams(
                request.getKeyword(),
                request.getExamType(),
                request.getExamYear(),
                request.getIsUse(),
                pageable
        );

        // 배치로 카운트 조회 (N+1 방지)
        List<String> examCds = examPage.getContent().stream()
                .map(Exam::getExamCd).collect(Collectors.toList());
        Map<String, long[]> countsMap = new HashMap<>();
        if (!examCds.isEmpty()) {
            List<Object[]> counts = examRepository.findExamCountsByExamCds(examCds);
            for (Object[] row : counts) {
                countsMap.put((String) row[0], new long[]{(Long) row[1], (Long) row[2]});
            }
        }

        return examPage.map(exam -> {
            long[] counts = countsMap.getOrDefault(exam.getExamCd(), new long[]{0, 0});
            return toResponse(exam, counts[0], counts[1]);
        });
    }

    /**
     * 시험 상세 조회
     */
    public ExamDto.DetailResponse getExamDetail(String examCd) {
        Exam exam = examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        List<ExamSubject> subjects = subjectRepository.findByExamCdOrderBySortOrder(examCd);
        Map<String, Long> answerCntMap = getAnswerCountMap(examCd);

        return ExamDto.DetailResponse.builder()
                .examCd(exam.getExamCd())
                .examNm(exam.getExamNm())
                .examType(exam.getExamType())
                .examYear(exam.getExamYear())
                .examRound(exam.getExamRound())
                .examDate(exam.getExamDate())
                .totalScore(exam.getTotalScore())
                .passScore(exam.getPassScore())
                .isUse(exam.getIsUse())
                .regDt(exam.getRegDt())
                .updDt(exam.getUpdDt())
                .subjects(subjects.stream()
                        .map(s -> toSubjectResponse(s, answerCntMap.getOrDefault(s.getSubjectCd(), 0L)))
                        .collect(Collectors.toList()))
                .build();
    }

    /**
     * 시험 등록
     */
    @Transactional
    public ExamDto.Response createExam(ExamDto.Request request) {
        // 중복 체크
        if (examRepository.existsById(request.getExamCd())) {
            throw new IllegalArgumentException("이미 존재하는 시험코드입니다: " + request.getExamCd());
        }

        Exam exam = Exam.builder()
                .examCd(request.getExamCd())
                .examNm(request.getExamNm())
                .examType(request.getExamType())
                .examYear(request.getExamYear())
                .examRound(request.getExamRound())
                .examDate(request.getExamDate())
                .totalScore(request.getTotalScore())
                .passScore(request.getPassScore())
                .isUse(request.getIsUse() != null ? request.getIsUse() : "Y")
                .build();

        exam = examRepository.save(exam);

        // 과목 일괄 등록
        if (request.getSubjects() != null && !request.getSubjects().isEmpty()) {
            List<ExamSubject> subjects = request.getSubjects().stream()
                    .map(subjectReq -> ExamSubject.builder()
                            .examCd(exam.getExamCd())
                            .subjectCd(subjectReq.getSubjectCd())
                            .subjectNm(subjectReq.getSubjectNm())
                            .subjectType(subjectReq.getSubjectType())
                            .questionCnt(subjectReq.getQuestionCnt())
                            .scorePerQ(subjectReq.getScorePerQ())
                            .questionType(subjectReq.getQuestionType())
                            .cutLine(subjectReq.getCutLine())
                            .sortOrder(subjectReq.getSortOrder())
                            .isUse(subjectReq.getIsUse() != null ? subjectReq.getIsUse() : "Y")
                            .build())
                    .collect(Collectors.toList());
            subjectRepository.saveAll(subjects);
        }

        return toResponse(exam);
    }

    /**
     * 시험 수정
     */
    @Transactional
    public ExamDto.Response updateExam(String examCd, ExamDto.Request request) {
        Exam exam = examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        exam.setExamNm(request.getExamNm());
        exam.setExamType(request.getExamType());
        exam.setExamYear(request.getExamYear());
        exam.setExamRound(request.getExamRound());
        exam.setExamDate(request.getExamDate());
        exam.setTotalScore(request.getTotalScore());
        exam.setPassScore(request.getPassScore());
        exam.setIsUse(request.getIsUse());

        return toResponse(examRepository.save(exam));
    }

    /**
     * 시험 삭제
     */
    @Transactional
    public void deleteExam(String examCd) {
        if (!examRepository.existsById(examCd)) {
            throw new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd);
        }
        examRepository.deleteById(examCd);
    }

    // ==================== 과목 관련 ====================

    /**
     * 과목 목록 조회
     */
    public List<SubjectDto.Response> getSubjectList(String examCd) {
        Map<String, Long> answerCntMap = getAnswerCountMap(examCd);
        return subjectRepository.findByExamCdOrderBySortOrder(examCd)
                .stream()
                .map(s -> toSubjectResponse(s, answerCntMap.getOrDefault(s.getSubjectCd(), 0L)))
                .collect(Collectors.toList());
    }

    /**
     * 과목 등록/수정
     */
    @Transactional
    public SubjectDto.Response saveSubject(SubjectDto.Request request) {
        ExamSubjectId id = new ExamSubjectId(request.getExamCd(), request.getSubjectCd());

        ExamSubject subject = subjectRepository.findById(id)
                .map(existing -> {
                    existing.setSubjectNm(request.getSubjectNm());
                    existing.setSubjectType(request.getSubjectType());
                    existing.setQuestionCnt(request.getQuestionCnt());
                    existing.setScorePerQ(request.getScorePerQ());
                    existing.setQuestionType(request.getQuestionType());
                    existing.setCutLine(request.getCutLine());
                    existing.setSortOrder(request.getSortOrder());
                    existing.setIsUse(request.getIsUse());
                    return existing;
                })
                .orElseGet(() -> ExamSubject.builder()
                        .examCd(request.getExamCd())
                        .subjectCd(request.getSubjectCd())
                        .subjectNm(request.getSubjectNm())
                        .subjectType(request.getSubjectType())
                        .questionCnt(request.getQuestionCnt())
                        .scorePerQ(request.getScorePerQ())
                        .questionType(request.getQuestionType())
                        .cutLine(request.getCutLine())
                        .sortOrder(request.getSortOrder())
                        .isUse(request.getIsUse() != null ? request.getIsUse() : "Y")
                        .build());

        return toSubjectResponse(subjectRepository.save(subject));
    }

    /**
     * 과목 삭제
     */
    @Transactional
    public void deleteSubject(String examCd, String subjectCd) {
        ExamSubjectId id = new ExamSubjectId(examCd, subjectCd);
        if (!subjectRepository.existsById(id)) {
            throw new EntityNotFoundException("과목을 찾을 수 없습니다.");
        }
        subjectRepository.deleteById(id);
    }

    // ==================== 정답 관련 ====================

    /**
     * 정답 목록 조회
     */
    public List<AnswerKeyDto.Response> getAnswerKeyList(String examCd, String subjectCd) {
        List<ExamAnswerKey> answers;
        if (subjectCd != null && !subjectCd.isEmpty()) {
            answers = answerKeyRepository.findByExamCdAndSubjectCdOrderByQuestionNo(examCd, subjectCd);
        } else {
            answers = answerKeyRepository.findByExamCdOrderBySubjectCdAscQuestionNoAsc(examCd);
        }

        return answers.stream()
                .map(this::toAnswerKeyResponse)
                .collect(Collectors.toList());
    }

    /**
     * 정답 일괄 등록/수정 (saveAll 배치 저장)
     */
    @Transactional
    public void saveAnswerKeys(AnswerKeyDto.BulkRequest request) {
        // 기존 정답 삭제
        answerKeyRepository.deleteByExamCdAndSubjectCd(request.getExamCd(), request.getSubjectCd());

        // 새 정답 일괄 등록
        List<ExamAnswerKey> answerKeys = request.getAnswers().stream()
                .map(item -> ExamAnswerKey.builder()
                        .examCd(request.getExamCd())
                        .subjectCd(request.getSubjectCd())
                        .questionNo(item.getQuestionNo())
                        .correctAns(item.getCorrectAns())
                        .score(item.getScore())
                        .isMultiAns(item.getIsMultiAns() != null ? item.getIsMultiAns() : "N")
                        .build())
                .collect(Collectors.toList());
        answerKeyRepository.saveAll(answerKeys);
    }

    // ==================== Mapper ====================

    private ExamDto.Response toResponse(Exam exam) {
        return toResponse(exam,
                examRepository.countSubjectsByExamCd(exam.getExamCd()),
                examRepository.countApplicantsByExamCd(exam.getExamCd()));
    }

    private ExamDto.Response toResponse(Exam exam, long subjectCnt, long applicantCnt) {
        return ExamDto.Response.builder()
                .examCd(exam.getExamCd())
                .examNm(exam.getExamNm())
                .examType(exam.getExamType())
                .examYear(exam.getExamYear())
                .examRound(exam.getExamRound())
                .examDate(exam.getExamDate())
                .totalScore(exam.getTotalScore())
                .passScore(exam.getPassScore())
                .isUse(exam.getIsUse())
                .regDt(exam.getRegDt())
                .updDt(exam.getUpdDt())
                .subjectCnt(subjectCnt)
                .applicantCnt(applicantCnt)
                .build();
    }

    private SubjectDto.Response toSubjectResponse(ExamSubject subject) {
        return toSubjectResponse(subject, answerKeyRepository.countByExamCdAndSubjectCd(subject.getExamCd(), subject.getSubjectCd()));
    }

    private SubjectDto.Response toSubjectResponse(ExamSubject subject, long answerCnt) {
        return SubjectDto.Response.builder()
                .examCd(subject.getExamCd())
                .subjectCd(subject.getSubjectCd())
                .subjectNm(subject.getSubjectNm())
                .subjectType(subject.getSubjectType())
                .questionCnt(subject.getQuestionCnt())
                .scorePerQ(subject.getScorePerQ())
                .questionType(subject.getQuestionType())
                .cutLine(subject.getCutLine())
                .sortOrder(subject.getSortOrder())
                .isUse(subject.getIsUse())
                .regDt(subject.getRegDt())
                .answerCnt(answerCnt)
                .build();
    }

    private Map<String, Long> getAnswerCountMap(String examCd) {
        return answerKeyRepository.countByExamCdGroupBySubject(examCd).stream()
                .collect(Collectors.toMap(row -> (String) row[0], row -> (Long) row[1]));
    }

    private AnswerKeyDto.Response toAnswerKeyResponse(ExamAnswerKey answerKey) {
        return AnswerKeyDto.Response.builder()
                .examCd(answerKey.getExamCd())
                .subjectCd(answerKey.getSubjectCd())
                .questionNo(answerKey.getQuestionNo())
                .correctAns(answerKey.getCorrectAns())
                .score(answerKey.getScore())
                .isMultiAns(answerKey.getIsMultiAns())
                .regDt(answerKey.getRegDt())
                .updDt(answerKey.getUpdDt())
                .build();
    }
}
