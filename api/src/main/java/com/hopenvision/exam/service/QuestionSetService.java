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

import java.util.List;
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

    /**
     * 세트 목록 조회 (페이징, 검색)
     */
    public Page<QuestionSetDto.Response> getSetList(QuestionSetDto.SearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());

        Page<QuestionSet> page = setRepository.searchSets(
                request.getKeyword(),
                request.getSubjectCd(),
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
        String subjectNm = getSubjectName(set.getSubjectCd());

        return QuestionSetDto.DetailResponse.builder()
                .setId(set.getSetId())
                .setCd(set.getSetCd())
                .setNm(set.getSetNm())
                .subjectCd(set.getSubjectCd())
                .subjectNm(subjectNm)
                .questionCnt(set.getQuestionCnt())
                .totalScore(set.getTotalScore())
                .category(set.getCategory())
                .difficultyLevel(set.getDifficultyLevel())
                .description(set.getDescription())
                .isUse(set.getIsUse())
                .regDt(set.getRegDt())
                .updDt(set.getUpdDt())
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
                .subjectCd(request.getSubjectCd())
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
        set.setSubjectCd(request.getSubjectCd());
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

        item.setQuestionNo(request.getQuestionNo());
        item.setScore(request.getScore());
        item.setSortOrder(request.getSortOrder());

        setItemRepository.save(item);

        // 세트 통계 재계산
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

        // 세트 통계 재계산
        QuestionSet set = setRepository.findById(setId).orElseThrow();
        recalculateSetStats(set);
        setRepository.save(set);
    }

    /**
     * 세트를 시험에 배치 (exam_question + exam_answer_key 일괄 복사)
     */
    @Transactional
    public int deployToExam(Long setId, String examCd) {
        QuestionSet set = setRepository.findById(setId)
                .orElseThrow(() -> new EntityNotFoundException("문제세트를 찾을 수 없습니다: " + setId));

        if (!examRepository.existsById(examCd)) {
            throw new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd);
        }

        List<QuestionSetItem> setItems = setItemRepository.findBySetIdOrderBySortOrder(setId);
        if (setItems.isEmpty()) {
            throw new IllegalStateException("문제세트에 항목이 없습니다.");
        }

        String subjectCd = set.getSubjectCd();

        // 기존 해당 과목의 문제/정답 삭제
        examQuestionRepository.deleteByExamCdAndSubjectCd(examCd, subjectCd);
        examAnswerKeyRepository.deleteByExamCdAndSubjectCd(examCd, subjectCd);

        int deployed = 0;
        for (QuestionSetItem setItem : setItems) {
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

        log.info("문제세트 {} → 시험 {} 배치 완료: {}문항", set.getSetCd(), examCd, deployed);
        return deployed;
    }

    // ==================== 내부 헬퍼 ====================

    private void recalculateSetStats(QuestionSet set) {
        List<QuestionSetItem> items = set.getItems();
        set.setQuestionCnt(items.size());

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

    // ==================== Mapper ====================

    private QuestionSetDto.Response toResponse(QuestionSet set) {
        String subjectNm = getSubjectName(set.getSubjectCd());
        return QuestionSetDto.Response.builder()
                .setId(set.getSetId())
                .setCd(set.getSetCd())
                .setNm(set.getSetNm())
                .subjectCd(set.getSubjectCd())
                .subjectNm(subjectNm)
                .questionCnt(set.getQuestionCnt())
                .totalScore(set.getTotalScore())
                .category(set.getCategory())
                .difficultyLevel(set.getDifficultyLevel())
                .description(set.getDescription())
                .isUse(set.getIsUse())
                .regDt(set.getRegDt())
                .updDt(set.getUpdDt())
                .build();
    }

    private QuestionSetDto.ItemResponse toItemResponse(QuestionSetItem item) {
        QuestionBankItem bankItem = bankItemRepository.findById(item.getItemId()).orElse(null);

        return QuestionSetDto.ItemResponse.builder()
                .setItemId(item.getSetItemId())
                .setId(item.getSetId())
                .itemId(item.getItemId())
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

    private String getSubjectName(String subjectCd) {
        return subjectMasterRepository.findById(subjectCd)
                .map(SubjectMaster::getSubjectNm)
                .orElse("");
    }
}
