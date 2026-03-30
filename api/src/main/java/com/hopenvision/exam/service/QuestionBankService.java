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
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.nio.charset.Charset;
import java.util.*;
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

    /**
     * 그룹 목록 조회 (페이징, 검색)
     */
    public Page<QuestionBankDto.GroupResponse> getGroupList(QuestionBankDto.GroupSearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());

        Page<QuestionBankGroup> page = groupRepository.searchGroups(
                request.getKeyword(),
                request.getCategory(),
                request.getExamYear(),
                request.getSource(),
                request.getIsUse(),
                pageable
        );

        // 항목 수 일괄 조회 (N+1 방지)
        List<Long> groupIds = page.getContent().stream()
                .map(QuestionBankGroup::getGroupId)
                .collect(Collectors.toList());
        Map<Long, Long> itemCountMap = getItemCountMap(groupIds);

        return page.map(group -> toGroupResponse(group,
                itemCountMap.getOrDefault(group.getGroupId(), 0L)));
    }

    /**
     * 그룹 상세 조회 (항목 포함)
     */
    public QuestionBankDto.GroupDetailResponse getGroupDetail(Long groupId) {
        QuestionBankGroup group = groupRepository.findById(groupId)
                .orElseThrow(() -> new EntityNotFoundException("문제은행 그룹을 찾을 수 없습니다: " + groupId));

        List<QuestionBankItem> items = itemRepository.findByGroupIdOrderByQuestionNo(groupId);
        Map<String, String> subjectNameMap = getSubjectNameMap(items);

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
                .items(items.stream()
                        .map(item -> toItemResponse(item, subjectNameMap.getOrDefault(item.getSubjectCd(), "")))
                        .collect(Collectors.toList()))
                .build();
    }

    /**
     * 그룹 등록
     */
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

    /**
     * 그룹 수정
     */
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

    /**
     * 그룹 삭제
     */
    @Transactional
    public void deleteGroup(Long groupId) {
        if (!groupRepository.existsById(groupId)) {
            throw new EntityNotFoundException("문제은행 그룹을 찾을 수 없습니다: " + groupId);
        }
        groupRepository.deleteById(groupId);
    }

    // ==================== Item ====================

    /**
     * 항목 목록 조회
     */
    public List<QuestionBankDto.ItemResponse> getItemList(Long groupId, String subjectCd) {
        List<QuestionBankItem> items;
        if (subjectCd != null && !subjectCd.isEmpty()) {
            items = itemRepository.findByGroupIdAndSubjectCdOrderByQuestionNo(groupId, subjectCd);
        } else {
            items = itemRepository.findByGroupIdOrderByQuestionNo(groupId);
        }

        Map<String, String> subjectNameMap = getSubjectNameMap(items);
        return items.stream()
                .map(item -> toItemResponse(item, subjectNameMap.getOrDefault(item.getSubjectCd(), "")))
                .collect(Collectors.toList());
    }

    /**
     * 항목 등록
     */
    @Transactional
    public QuestionBankDto.ItemResponse createItem(Long groupId, QuestionBankDto.ItemRequest request) {
        QuestionBankGroup group = groupRepository.findById(groupId)
                .orElseThrow(() -> new EntityNotFoundException("문제은행 그룹을 찾을 수 없습니다: " + groupId));

        QuestionBankItem item = buildItemFromRequest(request);
        group.addItem(item);
        groupRepository.save(group);

        String subjectNm = getSubjectName(request.getSubjectCd());
        return toItemResponse(item, subjectNm);
    }

    /**
     * 항목 수정
     */
    @Transactional
    public QuestionBankDto.ItemResponse updateItem(Long groupId, Long itemId, QuestionBankDto.ItemRequest request) {
        QuestionBankItem item = itemRepository.findById(itemId)
                .orElseThrow(() -> new EntityNotFoundException("문제은행 항목을 찾을 수 없습니다: " + itemId));

        if (!item.getGroupId().equals(groupId)) {
            throw new IllegalArgumentException("해당 그룹에 속하지 않는 항목입니다.");
        }

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
        item.setIsMultiAns(request.getIsMultiAns());
        item.setScore(request.getScore());
        item.setCategory(request.getCategory());
        item.setDifficulty(request.getDifficulty());
        item.setQuestionType(request.getQuestionType());
        item.setTags(request.getTags());
        item.setExplanation(request.getExplanation());
        item.setCorrectionNote(request.getCorrectionNote());
        item.setImageFile(request.getImageFile());

        String subjectNm = getSubjectName(request.getSubjectCd());
        return toItemResponse(itemRepository.save(item), subjectNm);
    }

    /**
     * 항목 삭제
     */
    @Transactional
    public void deleteItem(Long groupId, Long itemId) {
        QuestionBankItem item = itemRepository.findById(itemId)
                .orElseThrow(() -> new EntityNotFoundException("문제은행 항목을 찾을 수 없습니다: " + itemId));

        if (!item.getGroupId().equals(groupId)) {
            throw new IllegalArgumentException("해당 그룹에 속하지 않는 항목입니다.");
        }

        itemRepository.deleteById(itemId);
    }

    /**
     * 항목 일괄 등록
     */
    @Transactional
    public List<QuestionBankDto.ItemResponse> bulkImportItems(Long groupId, QuestionBankDto.BulkImportRequest request) {
        QuestionBankGroup group = groupRepository.findById(groupId)
                .orElseThrow(() -> new EntityNotFoundException("문제은행 그룹을 찾을 수 없습니다: " + groupId));

        List<QuestionBankItem> items = request.getItems().stream()
                .map(req -> {
                    QuestionBankItem item = buildItemFromRequest(req);
                    group.addItem(item);
                    return item;
                })
                .collect(Collectors.toList());

        groupRepository.save(group);

        Map<String, String> subjectNameMap = getSubjectNameMap(items);
        return items.stream()
                .map(item -> toItemResponse(item, subjectNameMap.getOrDefault(item.getSubjectCd(), "")))
                .collect(Collectors.toList());
    }

    // ==================== CSV Update ====================

    private static final Map<String, String> SUBJECT_NAME_ALIAS = Map.of(
            "행정법", "행정법총론"
    );

    /**
     * CSV 파일 파싱 → 미리보기 (DB 변경 없음)
     */
    public QuestionBankDto.CsvUpdateResult previewCsvUpdate(MultipartFile file) {
        List<QuestionBankDto.CsvUpdateRow> rows = parseCsvFile(file);
        matchRowsToItems(rows);
        return buildResult(rows, false);
    }

    /**
     * CSV 파일 파싱 → 실제 업데이트 적용
     */
    @Transactional
    public QuestionBankDto.CsvUpdateResult applyCsvUpdate(MultipartFile file) {
        List<QuestionBankDto.CsvUpdateRow> rows = parseCsvFile(file);
        matchRowsToItems(rows);

        int updatedCount = 0;
        for (QuestionBankDto.CsvUpdateRow row : rows) {
            if (!"MATCHED".equals(row.getStatus()) || row.getItemId() == null) {
                continue;
            }
            QuestionBankItem item = itemRepository.findById(row.getItemId()).orElse(null);
            if (item == null) {
                row.setStatus("ERROR");
                row.setMessage("항목을 찾을 수 없습니다");
                continue;
            }
            item.setCorrectAns(row.getCorrectAns());
            item.setScore(row.getScore());
            item.setDifficulty(row.getDifficulty());
            itemRepository.save(item);
            updatedCount++;
        }

        QuestionBankDto.CsvUpdateResult result = buildResult(rows, true);
        result.setUpdatedRows(updatedCount);
        return result;
    }

    private List<QuestionBankDto.CsvUpdateRow> parseCsvFile(MultipartFile file) {
        List<QuestionBankDto.CsvUpdateRow> rows = new ArrayList<>();
        // EUC-KR 시도, 실패 시 UTF-8
        Charset charset = Charset.forName("EUC-KR");
        try {
            byte[] bytes = file.getBytes();
            String firstLine = new String(bytes, 0, Math.min(bytes.length, 200), charset);
            if (firstLine.contains("\ufffd") || firstLine.contains("?")) {
                // EUC-KR 디코딩 실패 징후 → UTF-8로 전환
                charset = Charset.forName("UTF-8");
            }
        } catch (Exception e) {
            charset = Charset.forName("UTF-8");
        }

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(file.getInputStream(), charset))) {
            String line = reader.readLine(); // 헤더 스킵
            if (line == null) return rows;

            int rowNum = 1;
            while ((line = reader.readLine()) != null) {
                rowNum++;
                line = line.trim();
                if (line.isEmpty()) continue;

                String[] cols = line.split(",", -1);
                if (cols.length < 8) {
                    rows.add(QuestionBankDto.CsvUpdateRow.builder()
                            .rowNum(rowNum).status("ERROR")
                            .message("컬럼 수 부족 (8개 필요, " + cols.length + "개)")
                            .build());
                    continue;
                }

                try {
                    rows.add(QuestionBankDto.CsvUpdateRow.builder()
                            .rowNum(rowNum)
                            .examCd(cols[0].trim())
                            .examNm(cols[1].trim())
                            .round(parseIntSafe(cols[2].trim()))
                            .subjectNm(cols[3].trim())
                            .questionNo(parseIntSafe(cols[4].trim()))
                            .correctAns(cols[5].trim())
                            .score(parseBigDecimalSafe(cols[6].trim()))
                            .difficulty(cols[7].trim())
                            .status("PARSED")
                            .build());
                } catch (Exception e) {
                    rows.add(QuestionBankDto.CsvUpdateRow.builder()
                            .rowNum(rowNum).status("ERROR")
                            .message("파싱 오류: " + e.getMessage())
                            .build());
                }
            }
        } catch (Exception e) {
            log.error("CSV 파일 읽기 실패", e);
            throw new IllegalArgumentException("CSV 파일을 읽을 수 없습니다: " + e.getMessage());
        }
        return rows;
    }

    private void matchRowsToItems(List<QuestionBankDto.CsvUpdateRow> rows) {
        // groupCd 캐시
        Map<String, QuestionBankGroup> groupCache = new HashMap<>();

        for (QuestionBankDto.CsvUpdateRow row : rows) {
            if (!"PARSED".equals(row.getStatus())) continue;

            String subjectNm = row.getSubjectNm();
            String resolvedSubjectNm = SUBJECT_NAME_ALIAS.getOrDefault(subjectNm, subjectNm);
            String groupCd = row.getExamCd() + "-" + resolvedSubjectNm;
            row.setGroupCd(groupCd);

            // 그룹 조회
            QuestionBankGroup group = groupCache.computeIfAbsent(groupCd,
                    cd -> groupRepository.findByGroupCd(cd).orElse(null));

            if (group == null) {
                row.setStatus("SKIP");
                row.setMessage("그룹 없음: " + groupCd);
                continue;
            }
            row.setGroupId(group.getGroupId());

            // questionNo로 항목 매칭
            List<QuestionBankItem> items = itemRepository.findByGroupCdAndQuestionNo(groupCd, row.getQuestionNo());
            if (items.isEmpty()) {
                row.setStatus("NOT_FOUND");
                row.setMessage("문항 없음: " + groupCd + " #" + row.getQuestionNo());
                continue;
            }

            QuestionBankItem item = items.get(0);
            row.setItemId(item.getItemId());
            row.setPrevCorrectAns(item.getCorrectAns());
            row.setPrevScore(item.getScore());
            row.setPrevDifficulty(item.getDifficulty());
            row.setStatus("MATCHED");
        }
    }

    private QuestionBankDto.CsvUpdateResult buildResult(List<QuestionBankDto.CsvUpdateRow> rows, boolean isApply) {
        int matched = 0, skipped = 0, error = 0;
        for (QuestionBankDto.CsvUpdateRow row : rows) {
            switch (row.getStatus()) {
                case "MATCHED" -> matched++;
                case "SKIP", "NOT_FOUND" -> skipped++;
                default -> error++;
            }
        }
        return QuestionBankDto.CsvUpdateResult.builder()
                .totalRows(rows.size())
                .matchedRows(matched)
                .skippedRows(skipped)
                .errorRows(error)
                .updatedRows(isApply ? 0 : matched) // apply에서 덮어씀
                .rows(rows)
                .build();
    }

    private Integer parseIntSafe(String val) {
        if (val == null || val.isEmpty()) return null;
        return Integer.parseInt(val);
    }

    private BigDecimal parseBigDecimalSafe(String val) {
        if (val == null || val.isEmpty()) return null;
        return new BigDecimal(val);
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

    private QuestionBankDto.GroupResponse toGroupResponse(QuestionBankGroup group, long itemCount) {
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

    private QuestionBankDto.ItemResponse toItemResponse(QuestionBankItem item, String subjectNm) {
        return QuestionBankDto.ItemResponse.builder()
                .itemId(item.getItemId())
                .groupId(item.getGroupId())
                .groupNm(item.getGroup() != null ? item.getGroup().getGroupNm() : null)
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

    private Map<Long, Long> getItemCountMap(List<Long> groupIds) {
        if (groupIds.isEmpty()) {
            return Map.of();
        }
        Map<Long, Long> map = new HashMap<>();
        List<Object[]> counts = groupRepository.countItemsByGroupIds(groupIds);
        for (Object[] row : counts) {
            map.put((Long) row[0], (Long) row[1]);
        }
        return map;
    }

    private Map<String, String> getSubjectNameMap(List<QuestionBankItem> items) {
        List<String> subjectCds = items.stream()
                .map(QuestionBankItem::getSubjectCd)
                .distinct()
                .collect(Collectors.toList());
        if (subjectCds.isEmpty()) {
            return Map.of();
        }
        return subjectMasterRepository.findAllById(subjectCds).stream()
                .collect(Collectors.toMap(SubjectMaster::getSubjectCd, SubjectMaster::getSubjectNm));
    }

    private String getSubjectName(String subjectCd) {
        return subjectMasterRepository.findById(subjectCd)
                .map(SubjectMaster::getSubjectNm)
                .orElse("");
    }
}
