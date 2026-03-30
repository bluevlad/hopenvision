package com.hopenvision.exam.service;

import com.hopenvision.exam.dto.SubjectMasterDto;
import com.hopenvision.exam.entity.SubjectMaster;
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
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class SubjectMasterService {

    private final SubjectMasterRepository subjectMasterRepository;

    /**
     * 과목 목록 조회 (페이징, 검색)
     */
    public Page<SubjectMasterDto.Response> getSubjectList(SubjectMasterDto.SearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());

        Page<SubjectMaster> page = subjectMasterRepository.searchSubjects(
                request.getKeyword(),
                request.getCategory(),
                request.getIsUse(),
                pageable
        );

        // 하위 과목 수 일괄 계산
        List<String> subjectCds = page.getContent().stream()
                .map(SubjectMaster::getSubjectCd)
                .collect(Collectors.toList());
        Map<String, Long> childCountMap = getChildCountMap(subjectCds);

        return page.map(subject -> toResponse(subject,
                childCountMap.getOrDefault(subject.getSubjectCd(), 0L)));
    }

    /**
     * 과목 상세 조회
     */
    public SubjectMasterDto.Response getSubjectDetail(String subjectCd) {
        SubjectMaster subject = subjectMasterRepository.findById(subjectCd)
                .orElseThrow(() -> new EntityNotFoundException("과목을 찾을 수 없습니다: " + subjectCd));

        long childCount = subjectMasterRepository.findByParentSubjectCdOrderBySortOrder(subjectCd).size();
        long examCount = subjectMasterRepository.countExamsBySubjectCd(subjectCd);

        return toResponse(subject, childCount, examCount);
    }

    /**
     * 과목 트리 조회
     */
    public List<SubjectMasterDto.TreeResponse> getSubjectTree(String category) {
        List<SubjectMaster> roots;
        if (category != null && !category.isEmpty()) {
            roots = subjectMasterRepository.findByCategoryAndIsUseOrderBySortOrder(category, "Y").stream()
                    .filter(s -> s.getParentSubjectCd() == null || s.getParentSubjectCd().isEmpty())
                    .collect(Collectors.toList());
        } else {
            roots = subjectMasterRepository.findByParentSubjectCdIsNullOrderBySortOrder();
        }

        return roots.stream()
                .map(this::toTreeResponse)
                .collect(Collectors.toList());
    }

    /**
     * 카테고리별 과목 목록 (사용 중인 것만)
     */
    public List<SubjectMasterDto.Response> getSubjectsByCategory(String category) {
        List<SubjectMaster> subjects;
        if (category != null && !category.isEmpty()) {
            subjects = subjectMasterRepository.findByCategoryAndIsUseOrderBySortOrder(category, "Y");
        } else {
            subjects = subjectMasterRepository.findByIsUseOrderBySortOrder("Y");
        }
        return subjects.stream()
                .map(s -> toResponse(s, 0L))
                .collect(Collectors.toList());
    }

    /**
     * 과목 등록
     */
    @Transactional
    public SubjectMasterDto.Response createSubject(SubjectMasterDto.Request request) {
        if (subjectMasterRepository.existsById(request.getSubjectCd())) {
            throw new IllegalArgumentException("이미 존재하는 과목코드입니다: " + request.getSubjectCd());
        }

        // 상위 과목 존재 검증
        if (request.getParentSubjectCd() != null && !request.getParentSubjectCd().isEmpty()) {
            if (!subjectMasterRepository.existsById(request.getParentSubjectCd())) {
                throw new IllegalArgumentException("상위 과목을 찾을 수 없습니다: " + request.getParentSubjectCd());
            }
        }

        SubjectMaster subject = SubjectMaster.builder()
                .subjectCd(request.getSubjectCd())
                .subjectNm(request.getSubjectNm())
                .parentSubjectCd(request.getParentSubjectCd())
                .subjectDepth(request.getSubjectDepth() != null ? request.getSubjectDepth() : 1)
                .category(request.getCategory())
                .description(request.getDescription())
                .sortOrder(request.getSortOrder() != null ? request.getSortOrder() : 1)
                .isUse(request.getIsUse() != null ? request.getIsUse() : "Y")
                .build();

        return toResponse(subjectMasterRepository.save(subject), 0L);
    }

    /**
     * 과목 수정
     */
    @Transactional
    public SubjectMasterDto.Response updateSubject(String subjectCd, SubjectMasterDto.Request request) {
        SubjectMaster subject = subjectMasterRepository.findById(subjectCd)
                .orElseThrow(() -> new EntityNotFoundException("과목을 찾을 수 없습니다: " + subjectCd));

        // 상위 과목 존재 검증
        if (request.getParentSubjectCd() != null && !request.getParentSubjectCd().isEmpty()) {
            if (request.getParentSubjectCd().equals(subjectCd)) {
                throw new IllegalArgumentException("자기 자신을 상위 과목으로 지정할 수 없습니다.");
            }
            if (!subjectMasterRepository.existsById(request.getParentSubjectCd())) {
                throw new IllegalArgumentException("상위 과목을 찾을 수 없습니다: " + request.getParentSubjectCd());
            }
        }

        subject.setSubjectNm(request.getSubjectNm());
        subject.setParentSubjectCd(request.getParentSubjectCd());
        if (request.getSubjectDepth() != null) subject.setSubjectDepth(request.getSubjectDepth());
        subject.setCategory(request.getCategory());
        subject.setDescription(request.getDescription());
        if (request.getSortOrder() != null) subject.setSortOrder(request.getSortOrder());
        if (request.getIsUse() != null) subject.setIsUse(request.getIsUse());

        long childCount = subjectMasterRepository.findByParentSubjectCdOrderBySortOrder(subjectCd).size();
        return toResponse(subjectMasterRepository.save(subject), childCount);
    }

    /**
     * 과목 삭제
     */
    @Transactional
    public void deleteSubject(String subjectCd) {
        if (!subjectMasterRepository.existsById(subjectCd)) {
            throw new EntityNotFoundException("과목을 찾을 수 없습니다: " + subjectCd);
        }

        // 시험에서 사용 중인지 확인
        long examCount = subjectMasterRepository.countExamsBySubjectCd(subjectCd);
        if (examCount > 0) {
            throw new IllegalStateException("이 과목은 " + examCount + "개 시험에서 사용 중이므로 삭제할 수 없습니다.");
        }

        // 하위 과목이 있는지 확인
        List<SubjectMaster> children = subjectMasterRepository.findByParentSubjectCdOrderBySortOrder(subjectCd);
        if (!children.isEmpty()) {
            throw new IllegalStateException("하위 과목이 " + children.size() + "개 있으므로 삭제할 수 없습니다. 하위 과목을 먼저 삭제하세요.");
        }

        subjectMasterRepository.deleteById(subjectCd);
    }

    // ==================== Mapper ====================

    private SubjectMasterDto.Response toResponse(SubjectMaster subject, long childCount) {
        return toResponse(subject, childCount, null);
    }

    private SubjectMasterDto.Response toResponse(SubjectMaster subject, long childCount, Long examCount) {
        return SubjectMasterDto.Response.builder()
                .subjectCd(subject.getSubjectCd())
                .subjectNm(subject.getSubjectNm())
                .parentSubjectCd(subject.getParentSubjectCd())
                .subjectDepth(subject.getSubjectDepth())
                .category(subject.getCategory())
                .description(subject.getDescription())
                .sortOrder(subject.getSortOrder())
                .isUse(subject.getIsUse())
                .regDt(subject.getRegDt())
                .updDt(subject.getUpdDt())
                .childCount(childCount)
                .examCount(examCount)
                .build();
    }

    private SubjectMasterDto.TreeResponse toTreeResponse(SubjectMaster subject) {
        List<SubjectMaster> children = subjectMasterRepository.findByParentSubjectCdOrderBySortOrder(subject.getSubjectCd());

        return SubjectMasterDto.TreeResponse.builder()
                .subjectCd(subject.getSubjectCd())
                .subjectNm(subject.getSubjectNm())
                .parentSubjectCd(subject.getParentSubjectCd())
                .subjectDepth(subject.getSubjectDepth())
                .category(subject.getCategory())
                .description(subject.getDescription())
                .sortOrder(subject.getSortOrder())
                .isUse(subject.getIsUse())
                .children(children.stream()
                        .map(this::toTreeResponse)
                        .collect(Collectors.toList()))
                .build();
    }

    private Map<String, Long> getChildCountMap(List<String> subjectCds) {
        if (subjectCds.isEmpty()) {
            return Map.of();
        }
        return subjectMasterRepository.findAll().stream()
                .filter(s -> s.getParentSubjectCd() != null && subjectCds.contains(s.getParentSubjectCd()))
                .collect(Collectors.groupingBy(SubjectMaster::getParentSubjectCd, Collectors.counting()));
    }
}
