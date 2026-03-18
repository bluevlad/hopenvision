package com.hopenvision.exam.service;

import com.hopenvision.exam.dto.QuestionSetDto;
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

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class QuestionSetService {

    private final QuestionSetRepository setRepository;
    private final QuestionSetItemRepository setItemRepository;
    private final QuestionBankItemRepository bankItemRepository;
    private final SubjectMasterRepository subjectMasterRepository;
    private final ExamQuestionRepository examQuestionRepository;
    private final ExamAnswerKeyRepository examAnswerKeyRepository;
    private final ExamRepository examRepository;
    private final ExamSubjectRepository examSubjectRepository;

    /**
     * 세트 목록 조회 (페이징, 검색)
     */
    public Page<QuestionSetDto.Response> getSetList(QuestionSetDto.SearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());

        Page<QuestionSet> page = setRepository.searchSets(
                request.getKeyword(),
                request.getCategory(),
                request.getIsUse(),
                pageable
        );

        return page.map(this::toResponse);
    }

    /**
     * 세트 상세 조회 (항목 포함)
     */
    public QuestionSetDto.DetailResponse getSetDetail(Long setId) {
        QuestionSet set = setRepository.findById(setId)
                .orElseThrow(() -> new EntityNotFoundException("문제세트를 찾을 수 없습니다: " + setId));

        List<QuestionSetItem> items = setItemRepository.findBySetIdOrderBySortOrder(setId);
        List<QuestionSetDto.SubjectSummary> summaries = getSubjectSummaries(setId);

        return QuestionSetDto.DetailResponse.builder()
                .setId(set.getSetId())
                .setCd(set.getSetCd())
                .setNm(set.getSetNm())
                .questionCnt(set.getQuestionCnt())
                .totalScore(set.getTotalScore())
                .subjectCnt(set.getSubjectCnt())
                .category(set.getCategory())
                .difficultyLevel(set.getDifficultyLevel())
                .description(set.getDescription())
                .isUse(set.getIsUse())
                .regDt(set.getRegDt())
                .updDt(set.getUpdDt())
                .subjectSummaries(summaries)
                .items(items.stream()
                        .map(this::toItemResponse)
                        .collect(Collectors.toList()))
                .build();
    }

    /**
     * 세트 등록
     */
    @Transactional
    public QuestionSetDto.Response createSet(QuestionSetDto.Request request) {
        if (setRepository.existsBySetCd(request.getSetCd())) {
            throw new IllegalArgumentException("이미 존재하는 세트코드입니다: " + request.getSetCd());
        }

        QuestionSet set = QuestionSet.builder()
                .setCd(request.getSetCd())
                .setNm(request.getSetNm())
                .category(request.getCategory())
                .difficultyLevel(request.getDifficultyLevel())
                .description(request.getDescription())
                .isUse(request.getIsUse() != null ? request.getIsUse() : "Y")
                .build();

        return toResponse(setRepository.save(set));
    }

    /**
     * 세트 수정
     */
    @Transactional
    public QuestionSetDto.Response updateSet(Long setId, QuestionSetDto.Request request) {
        QuestionSet set = setRepository.findById(setId)
                .orElseThrow(() -> new EntityNotFoundException("문제세트를 찾을 수 없습니다: " + setId));

        set.setSetNm(request.getSetNm());
        set.setCategory(request.getCategory());
        set.setDifficultyLevel(request.getDifficultyLevel());
        set.setDescription(request.getDescription());
        set.setIsUse(request.getIsUse());

        return toResponse(setRepository.save(set));
    }

    /**
     * 세트 삭제
     */
    @Transactional
    public void deleteSet(Long setId) {
        if (!setRepository.existsById(setId)) {
            throw new EntityNotFoundException("문제세트를 찾을 수 없습니다: " + setId);
        }
        setRepository.deleteById(setId);
    }

    /**
     * 세트에 항목 추가
     */
    @Transactional
    public QuestionSetDto.ItemResponse addItem(Long setId, QuestionSetDto.ItemRequest request) {
        QuestionSet set = setRepository.findById(setId)
                .orElseThrow(() -> new EntityNotFoundException("문제세트를 찾을 수 없습니다: " + setId));

        if (!bankItemRepository.existsById(request.getItemId())) {
            throw new EntityNotFoundException("문제은행 항목을 찾을 수 없습니다: " + request.getItemId());
        }

        QuestionSetItem item = QuestionSetItem.builder()
                .itemId(request.getItemId())
                .subjectCd(request.getSubjectCd())
                .questionNo(request.getQuestionNo())
                .score(request.getScore())
                .sortOrder(request.getSortOrder() != null ? request.getSortOrder() : set.getItems().size() + 1)
                .build();

        set.addItem(item);
        recalculateSetStats(set);
        setRepository.save(set);

        return toItemResponse(item);
    }

    /**
     * 세트 항목 수정
     */
    @Transactional
    public QuestionSetDto.ItemResponse updateItem(Long setId, Long setItemId, QuestionSetDto.ItemRequest request) {
        QuestionSetItem item = setItemRepository.findById(setItemId)
                .orElseThrow(() -> new EntityNotFoundException("세트 항목을 찾을 수 없습니다: " + setItemId));

        if (!item.getSetId().equals(setId)) {
            throw new IllegalArgumentException("해당 세트에 속하지 않는 항목입니다.");
        }

        item.setSubjectCd(request.getSubjectCd());
        item.setQuestionNo(request.getQuestionNo());
        item.setScore(request.getScore());
        item.setSortOrder(request.getSortOrder());

        setItemRepository.save(item);

        QuestionSet set = setRepository.findById(setId).orElseThrow();
        recalculateSetStats(set);
        setRepository.save(set);

        return toItemResponse(item);
    }

    /**
     * 세트에서 항목 제거
     */
    @Transactional
    public void removeItem(Long setId, Long setItemId) {
        QuestionSetItem item = setItemRepository.findById(setItemId)
                .orElseThrow(() -> new EntityNotFoundException("세트 항목을 찾을 수 없습니다: " + setItemId));

        if (!item.getSetId().equals(setId)) {
            throw new IllegalArgumentException("해당 세트에 속하지 않는 항목입니다.");
        }

        setItemRepository.deleteById(setItemId);

        QuestionSet set = setRepository.findById(setId).orElseThrow();
        recalculateSetStats(set);
        setRepository.save(set);
    }

    /**
     * 문제세트를 시험에 연결 (exam_mst.question_set_id 설정 + 과목별 exam_question/answer_key 일괄 생성)
     */
    @Transactional
    public Map<String, Object> deployToExam(Long setId, String examCd) {
        QuestionSet set = setRepository.findById(setId)
                .orElseThrow(() -> new EntityNotFoundException("문제세트를 찾을 수 없습니다: " + setId));

        Exam exam = examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        List<QuestionSetItem> setItems = setItemRepository.findBySetIdOrderBySortOrder(setId);
        if (setItems.isEmpty()) {
            throw new IllegalStateException("문제세트에 항목이 없습니다.");
        }

        // 시험에 문제세트 연결
        exam.setQuestionSetId(set.getSetId());
        examRepository.save(exam);

        // 과목별로 그룹핑
        Map<String, List<QuestionSetItem>> itemsBySubject = setItems.stream()
                .collect(Collectors.groupingBy(QuestionSetItem::getSubjectCd, LinkedHashMap::new, Collectors.toList()));

        int totalDeployed = 0;
        List<String> deployedSubjects = new ArrayList<>();

        for (Map.Entry<String, List<QuestionSetItem>> entry : itemsBySubject.entrySet()) {
            String subjectCd = entry.getKey();
            List<QuestionSetItem> subjectItems = entry.getValue();

            // 기존 해당 과목의 문제/정답 삭제
            examQuestionRepository.deleteByExamCdAndSubjectCd(examCd, subjectCd);
            examAnswerKeyRepository.deleteByExamCdAndSubjectCd(examCd, subjectCd);

            int deployed = 0;
            for (QuestionSetItem setItem : subjectItems) {
                QuestionBankItem bankItem = bankItemRepository.findById(setItem.getItemId()).orElse(null);
                if (bankItem == null) continue;

                int questionNo = setItem.getQuestionNo() != null ? setItem.getQuestionNo() : deployed + 1;

                // exam_question 생성
                ExamQuestion examQuestion = ExamQuestion.builder()
                        .examCd(examCd)
                        .subjectCd(subjectCd)
                        .questionNo(questionNo)
                        .questionText(bankItem.getQuestionText())
                        .contextText(bankItem.getContextText())
                        .choice1(bankItem.getChoice1())
                        .choice2(bankItem.getChoice2())
                        .choice3(bankItem.getChoice3())
                        .choice4(bankItem.getChoice4())
                        .choice5(bankItem.getChoice5())
                        .imageFile(bankItem.getImageFile())
                        .category(bankItem.getCategory())
                        .difficulty(bankItem.getDifficulty())
                        .title(bankItem.getQuestionTitle())
                        .explanation(bankItem.getExplanation())
                        .correctionNote(bankItem.getCorrectionNote())
                        .build();
                examQuestionRepository.save(examQuestion);

                // exam_answer_key 생성
                ExamAnswerKey answerKey = ExamAnswerKey.builder()
                        .examCd(examCd)
                        .subjectCd(subjectCd)
                        .questionNo(questionNo)
                        .correctAns(bankItem.getCorrectAns())
                        .score(setItem.getScore() != null ? setItem.getScore() : bankItem.getScore())
                        .isMultiAns(bankItem.getIsMultiAns())
                        .build();
                examAnswerKeyRepository.save(answerKey);

                // 문제은행 사용횟수 증가
                bankItem.setUseCount(bankItem.getUseCount() + 1);
                bankItemRepository.save(bankItem);

                deployed++;
            }

            totalDeployed += deployed;
            deployedSubjects.add(subjectCd);
        }

        log.info("문제세트 {} → 시험 {} 배치 완료: {}과목, {}문항", set.getSetCd(), examCd, deployedSubjects.size(), totalDeployed);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("examCd", examCd);
        result.put("questionSetId", set.getSetId());
        result.put("deployedCount", totalDeployed);
        result.put("subjectCount", deployedSubjects.size());
        result.put("subjects", deployedSubjects);
        return result;
    }

    // ==================== 내부 헬퍼 ====================

    private void recalculateSetStats(QuestionSet set) {
        List<QuestionSetItem> items = set.getItems();
        set.setQuestionCnt(items.size());

        long subjectCount = items.stream()
                .map(QuestionSetItem::getSubjectCd)
                .distinct()
                .count();
        set.setSubjectCnt((int) subjectCount);

        int total = 0;
        for (QuestionSetItem item : items) {
            if (item.getScore() != null) {
                total += item.getScore().intValue();
            } else {
                QuestionBankItem bankItem = bankItemRepository.findById(item.getItemId()).orElse(null);
                if (bankItem != null && bankItem.getScore() != null) {
                    total += bankItem.getScore().intValue();
                }
            }
        }
        set.setTotalScore(total);
    }

    private List<QuestionSetDto.SubjectSummary> getSubjectSummaries(Long setId) {
        List<Object[]> counts = setItemRepository.countItemsBySubjectCd(setId);
        if (counts.isEmpty()) return Collections.emptyList();

        List<String> subjectCds = counts.stream().map(r -> (String) r[0]).collect(Collectors.toList());
        Map<String, String> nameMap = subjectMasterRepository.findAllById(subjectCds).stream()
                .collect(Collectors.toMap(SubjectMaster::getSubjectCd, SubjectMaster::getSubjectNm));

        return counts.stream()
                .map(row -> QuestionSetDto.SubjectSummary.builder()
                        .subjectCd((String) row[0])
                        .subjectNm(nameMap.getOrDefault((String) row[0], (String) row[0]))
                        .itemCount((Long) row[1])
                        .build())
                .collect(Collectors.toList());
    }

    // ==================== Mapper ====================

    private QuestionSetDto.Response toResponse(QuestionSet set) {
        List<QuestionSetDto.SubjectSummary> summaries = getSubjectSummaries(set.getSetId());
        return QuestionSetDto.Response.builder()
                .setId(set.getSetId())
                .setCd(set.getSetCd())
                .setNm(set.getSetNm())
                .questionCnt(set.getQuestionCnt())
                .totalScore(set.getTotalScore())
                .subjectCnt(set.getSubjectCnt())
                .category(set.getCategory())
                .difficultyLevel(set.getDifficultyLevel())
                .description(set.getDescription())
                .isUse(set.getIsUse())
                .regDt(set.getRegDt())
                .updDt(set.getUpdDt())
                .subjectSummaries(summaries)
                .build();
    }

    private QuestionSetDto.ItemResponse toItemResponse(QuestionSetItem item) {
        QuestionBankItem bankItem = bankItemRepository.findById(item.getItemId()).orElse(null);
        String subjectNm = subjectMasterRepository.findById(item.getSubjectCd())
                .map(SubjectMaster::getSubjectNm).orElse("");

        return QuestionSetDto.ItemResponse.builder()
                .setItemId(item.getSetItemId())
                .setId(item.getSetId())
                .itemId(item.getItemId())
                .subjectCd(item.getSubjectCd())
                .subjectNm(subjectNm)
                .questionNo(item.getQuestionNo())
                .score(item.getScore())
                .sortOrder(item.getSortOrder())
                .questionTitle(bankItem != null ? bankItem.getQuestionTitle() : null)
                .questionText(bankItem != null ? bankItem.getQuestionText() : null)
                .correctAns(bankItem != null ? bankItem.getCorrectAns() : null)
                .difficulty(bankItem != null ? bankItem.getDifficulty() : null)
                .questionType(bankItem != null ? bankItem.getQuestionType() : null)
                .bankScore(bankItem != null ? bankItem.getScore() : null)
                .build();
    }
}
