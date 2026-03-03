package com.hopenvision.exam.service;

import com.hopenvision.exam.dto.QuestionBankDto;
import com.hopenvision.exam.entity.QuestionBankGroup;
import com.hopenvision.exam.entity.QuestionBankItem;
import com.hopenvision.exam.entity.SubjectMaster;
import com.hopenvision.exam.repository.QuestionBankGroupRepository;
import com.hopenvision.exam.repository.QuestionBankItemRepository;
import com.hopenvision.exam.repository.SubjectMasterRepository;
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
public class QuestionBankService {

    private final QuestionBankGroupRepository groupRepository;
    private final QuestionBankItemRepository itemRepository;
    private final SubjectMasterRepository subjectMasterRepository;

    // ==================== Group ====================

    public Page<QuestionBankDto.GroupResponse> getGroupList(QuestionBankDto.GroupSearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());
        Page<QuestionBankGroup> page = groupRepository.searchGroups(
                blankToNull(request.getKeyword()), blankToNull(request.getCategory()),
                blankToNull(request.getExamYear()), blankToNull(request.getIsUse()), pageable);

        return page.map(group -> {
            long itemCount = itemRepository.countByGroupId(group.getGroupId());
            return toGroupResponse(group, itemCount);
        });
    }

    public QuestionBankDto.GroupDetailResponse getGroupDetail(Long groupId) {
        QuestionBankGroup group = groupRepository.findById(groupId)
                .orElseThrow(() -> new EntityNotFoundException("문제은행 그룹을 찾을 수 없습니다: " + groupId));

        List<QuestionBankItem> items = itemRepository.findByGroupIdOrderByQuestionNo(groupId);

        return QuestionBankDto.GroupDetailResponse.builder()
                .groupId(group.getGroupId())
                .groupCd(group.getGroupCd())
                .groupNm(group.getGroupNm())
                .examYear(group.getExamYear())
                .examRound(group.getExamRound())
                .category(group.getCategory())
                .source(group.getSource())
                .description(group.getDescription())
                .isUse(group.getIsUse())
                .regDt(group.getRegDt())
                .updDt(group.getUpdDt())
                .items(items.stream().map(this::toItemResponse).collect(Collectors.toList()))
                .build();
    }

    @Transactional
    public QuestionBankDto.GroupResponse createGroup(QuestionBankDto.GroupRequest request) {
        if (groupRepository.existsByGroupCd(request.getGroupCd())) {
            throw new IllegalArgumentException("이미 존재하는 그룹코드입니다: " + request.getGroupCd());
        }

        QuestionBankGroup group = QuestionBankGroup.builder()
                .groupCd(request.getGroupCd())
                .groupNm(request.getGroupNm())
                .examYear(request.getExamYear())
                .examRound(request.getExamRound())
                .category(request.getCategory())
                .source(request.getSource())
                .description(request.getDescription())
                .isUse(request.getIsUse() != null ? request.getIsUse() : "Y")
                .build();

        return toGroupResponse(groupRepository.save(group), 0L);
    }

    @Transactional
    public QuestionBankDto.GroupResponse updateGroup(Long groupId, QuestionBankDto.GroupRequest request) {
        QuestionBankGroup group = groupRepository.findById(groupId)
                .orElseThrow(() -> new EntityNotFoundException("문제은행 그룹을 찾을 수 없습니다: " + groupId));

        group.setGroupNm(request.getGroupNm());
        group.setExamYear(request.getExamYear());
        group.setExamRound(request.getExamRound());
        group.setCategory(request.getCategory());
        group.setSource(request.getSource());
        group.setDescription(request.getDescription());
        if (request.getIsUse() != null) group.setIsUse(request.getIsUse());

        long itemCount = itemRepository.countByGroupId(groupId);
        return toGroupResponse(groupRepository.save(group), itemCount);
    }

    @Transactional
    public void deleteGroup(Long groupId) {
        if (!groupRepository.existsById(groupId)) {
            throw new EntityNotFoundException("문제은행 그룹을 찾을 수 없습니다: " + groupId);
        }
        groupRepository.deleteById(groupId);
    }

    // ==================== Item ====================

    public Page<QuestionBankDto.ItemResponse> getItemList(QuestionBankDto.ItemSearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());
        Page<QuestionBankItem> page = itemRepository.searchItems(
                request.getGroupId(), blankToNull(request.getSubjectCd()),
                blankToNull(request.getDifficulty()), blankToNull(request.getKeyword()),
                blankToNull(request.getIsUse()), pageable);

        return page.map(this::toItemResponse);
    }

    public QuestionBankDto.ItemResponse getItemDetail(Long itemId) {
        QuestionBankItem item = itemRepository.findById(itemId)
                .orElseThrow(() -> new EntityNotFoundException("문제를 찾을 수 없습니다: " + itemId));
        return toItemResponse(item);
    }

    @Transactional
    public QuestionBankDto.ItemResponse createItem(QuestionBankDto.ItemRequest request) {
        if (!groupRepository.existsById(request.getGroupId())) {
            throw new EntityNotFoundException("문제은행 그룹을 찾을 수 없습니다: " + request.getGroupId());
        }

        QuestionBankItem item = buildItemFromRequest(request);
        return toItemResponse(itemRepository.save(item));
    }

    @Transactional
    public QuestionBankDto.ItemResponse updateItem(Long itemId, QuestionBankDto.ItemRequest request) {
        QuestionBankItem item = itemRepository.findById(itemId)
                .orElseThrow(() -> new EntityNotFoundException("문제를 찾을 수 없습니다: " + itemId));

        item.setSubjectCd(request.getSubjectCd());
        item.setQuestionNo(request.getQuestionNo());
        item.setQuestionTitle(request.getQuestionTitle());
        item.setQuestionText(request.getQuestionText());
        item.setContextText(request.getContextText());
        item.setChoice1(request.getChoice1());
        item.setChoice2(request.getChoice2());
        item.setChoice3(request.getChoice3());
        item.setChoice4(request.getChoice4());
        item.setChoice5(request.getChoice5());
        item.setCorrectAns(request.getCorrectAns());
        item.setIsMultiAns(request.getIsMultiAns() != null ? request.getIsMultiAns() : "N");
        item.setScore(request.getScore());
        item.setCategory(request.getCategory());
        item.setDifficulty(request.getDifficulty());
        item.setQuestionType(request.getQuestionType() != null ? request.getQuestionType() : "CHOICE");
        item.setTags(request.getTags());
        item.setExplanation(request.getExplanation());
        item.setCorrectionNote(request.getCorrectionNote());
        item.setImageFile(request.getImageFile());
        if (request.getIsUse() != null) item.setIsUse(request.getIsUse());

        return toItemResponse(itemRepository.save(item));
    }

    @Transactional
    public void deleteItem(Long itemId) {
        if (!itemRepository.existsById(itemId)) {
            throw new EntityNotFoundException("문제를 찾을 수 없습니다: " + itemId);
        }
        itemRepository.deleteById(itemId);
    }

    @Transactional
    public List<QuestionBankDto.ItemResponse> bulkImportItems(Long groupId, QuestionBankDto.BulkImportRequest request) {
        if (!groupRepository.existsById(groupId)) {
            throw new EntityNotFoundException("문제은행 그룹을 찾을 수 없습니다: " + groupId);
        }

        List<QuestionBankItem> items = request.getItems().stream()
                .map(req -> {
                    QuestionBankItem item = buildItemFromRequest(req);
                    item.setGroupId(null); // will be set via group relation
                    QuestionBankGroup group = groupRepository.getReferenceById(groupId);
                    item.setGroup(group);
                    return item;
                })
                .collect(Collectors.toList());

        return itemRepository.saveAll(items).stream()
                .map(this::toItemResponse)
                .collect(Collectors.toList());
    }

    // ==================== Mapper ====================

    private QuestionBankItem buildItemFromRequest(QuestionBankDto.ItemRequest request) {
        return QuestionBankItem.builder()
                .subjectCd(request.getSubjectCd())
                .questionNo(request.getQuestionNo())
                .questionTitle(request.getQuestionTitle())
                .questionText(request.getQuestionText())
                .contextText(request.getContextText())
                .choice1(request.getChoice1())
                .choice2(request.getChoice2())
                .choice3(request.getChoice3())
                .choice4(request.getChoice4())
                .choice5(request.getChoice5())
                .correctAns(request.getCorrectAns())
                .isMultiAns(request.getIsMultiAns() != null ? request.getIsMultiAns() : "N")
                .score(request.getScore())
                .category(request.getCategory())
                .difficulty(request.getDifficulty())
                .questionType(request.getQuestionType() != null ? request.getQuestionType() : "CHOICE")
                .tags(request.getTags())
                .explanation(request.getExplanation())
                .correctionNote(request.getCorrectionNote())
                .imageFile(request.getImageFile())
                .isUse(request.getIsUse() != null ? request.getIsUse() : "Y")
                .build();
    }

    private String blankToNull(String value) {
        return (value != null && !value.isBlank()) ? value : null;
    }

    private QuestionBankDto.GroupResponse toGroupResponse(QuestionBankGroup group, Long itemCount) {
        return QuestionBankDto.GroupResponse.builder()
                .groupId(group.getGroupId())
                .groupCd(group.getGroupCd())
                .groupNm(group.getGroupNm())
                .examYear(group.getExamYear())
                .examRound(group.getExamRound())
                .category(group.getCategory())
                .source(group.getSource())
                .description(group.getDescription())
                .isUse(group.getIsUse())
                .regDt(group.getRegDt())
                .updDt(group.getUpdDt())
                .itemCount(itemCount)
                .build();
    }

    private QuestionBankDto.ItemResponse toItemResponse(QuestionBankItem item) {
        String groupNm = null;
        String subjectNm = null;

        if (item.getGroup() != null) {
            groupNm = item.getGroup().getGroupNm();
        }
        if (item.getSubject() != null) {
            subjectNm = item.getSubject().getSubjectNm();
        }

        return QuestionBankDto.ItemResponse.builder()
                .itemId(item.getItemId())
                .groupId(item.getGroup() != null ? item.getGroup().getGroupId() : item.getGroupId())
                .groupNm(groupNm)
                .subjectCd(item.getSubjectCd())
                .subjectNm(subjectNm)
                .questionNo(item.getQuestionNo())
                .questionTitle(item.getQuestionTitle())
                .questionText(item.getQuestionText())
                .contextText(item.getContextText())
                .choice1(item.getChoice1())
                .choice2(item.getChoice2())
                .choice3(item.getChoice3())
                .choice4(item.getChoice4())
                .choice5(item.getChoice5())
                .correctAns(item.getCorrectAns())
                .isMultiAns(item.getIsMultiAns())
                .score(item.getScore())
                .category(item.getCategory())
                .difficulty(item.getDifficulty())
                .questionType(item.getQuestionType())
                .tags(item.getTags())
                .explanation(item.getExplanation())
                .correctionNote(item.getCorrectionNote())
                .imageFile(item.getImageFile())
                .useCount(item.getUseCount())
                .correctRate(item.getCorrectRate())
                .isUse(item.getIsUse())
                .regDt(item.getRegDt())
                .updDt(item.getUpdDt())
                .build();
    }
}
