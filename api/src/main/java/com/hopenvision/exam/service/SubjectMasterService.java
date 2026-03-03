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

    public List<SubjectMasterDto.Response> getSubjectList(String category) {
        List<SubjectMaster> subjects;
        if (category != null && !category.isBlank()) {
            subjects = subjectMasterRepository.findByCategoryAndIsUseOrderBySortOrder(category, "Y");
        } else {
            subjects = subjectMasterRepository.findByIsUseOrderByCategoryAscSortOrderAsc("Y");
        }
        return buildTree(subjects);
    }

    public Page<SubjectMasterDto.Response> searchSubjects(SubjectMasterDto.SearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());

        String keyword = blankToNull(request.getKeyword());
        String category = blankToNull(request.getCategory());
        String isUse = blankToNull(request.getIsUse());

        Page<SubjectMaster> page;
        if (isUse != null) {
            page = subjectMasterRepository.searchSubjects(keyword, category, isUse, pageable);
        } else {
            page = subjectMasterRepository.searchSubjectsAll(keyword, category, pageable);
        }

        return page.map(this::toResponse);
    }

    private String blankToNull(String value) {
        return (value != null && !value.isBlank()) ? value : null;
    }

    public SubjectMasterDto.Response getSubjectDetail(String subjectCd) {
        SubjectMaster subject = subjectMasterRepository.findById(subjectCd)
                .orElseThrow(() -> new EntityNotFoundException("과목을 찾을 수 없습니다: " + subjectCd));

        SubjectMasterDto.Response response = toResponse(subject);

        List<SubjectMaster> children = subjectMasterRepository
                .findByParentSubjectCdAndIsUseOrderBySortOrder(subjectCd, "Y");
        if (!children.isEmpty()) {
            response.setChildren(children.stream().map(this::toResponse).collect(Collectors.toList()));
        }

        return response;
    }

    @Transactional
    public SubjectMasterDto.Response createSubject(SubjectMasterDto.Request request) {
        if (subjectMasterRepository.existsById(request.getSubjectCd())) {
            throw new IllegalArgumentException("이미 존재하는 과목코드입니다: " + request.getSubjectCd());
        }

        SubjectMaster subject = SubjectMaster.builder()
                .subjectCd(request.getSubjectCd())
                .subjectNm(request.getSubjectNm())
                .parentSubjectCd(request.getParentSubjectCd())
                .subjectDepth(request.getSubjectDepth() != null ? request.getSubjectDepth() : 1)
                .sortOrder(request.getSortOrder() != null ? request.getSortOrder() : 1)
                .category(request.getCategory())
                .description(request.getDescription())
                .isUse(request.getIsUse() != null ? request.getIsUse() : "Y")
                .build();

        return toResponse(subjectMasterRepository.save(subject));
    }

    @Transactional
    public SubjectMasterDto.Response updateSubject(String subjectCd, SubjectMasterDto.Request request) {
        SubjectMaster subject = subjectMasterRepository.findById(subjectCd)
                .orElseThrow(() -> new EntityNotFoundException("과목을 찾을 수 없습니다: " + subjectCd));

        subject.setSubjectNm(request.getSubjectNm());
        subject.setParentSubjectCd(request.getParentSubjectCd());
        if (request.getSubjectDepth() != null) subject.setSubjectDepth(request.getSubjectDepth());
        if (request.getSortOrder() != null) subject.setSortOrder(request.getSortOrder());
        subject.setCategory(request.getCategory());
        subject.setDescription(request.getDescription());
        if (request.getIsUse() != null) subject.setIsUse(request.getIsUse());

        return toResponse(subjectMasterRepository.save(subject));
    }

    @Transactional
    public void deleteSubject(String subjectCd) {
        SubjectMaster subject = subjectMasterRepository.findById(subjectCd)
                .orElseThrow(() -> new EntityNotFoundException("과목을 찾을 수 없습니다: " + subjectCd));

        subject.setIsUse("N");
        subjectMasterRepository.save(subject);
    }

    private List<SubjectMasterDto.Response> buildTree(List<SubjectMaster> subjects) {
        List<SubjectMasterDto.Response> allResponses = subjects.stream()
                .map(this::toResponse).collect(Collectors.toList());

        Map<String, List<SubjectMasterDto.Response>> childrenMap = allResponses.stream()
                .filter(r -> r.getParentSubjectCd() != null)
                .collect(Collectors.groupingBy(SubjectMasterDto.Response::getParentSubjectCd));

        List<SubjectMasterDto.Response> roots = allResponses.stream()
                .filter(r -> r.getParentSubjectCd() == null)
                .collect(Collectors.toList());

        roots.forEach(root -> root.setChildren(childrenMap.get(root.getSubjectCd())));

        return roots;
    }

    private SubjectMasterDto.Response toResponse(SubjectMaster subject) {
        return SubjectMasterDto.Response.builder()
                .subjectCd(subject.getSubjectCd())
                .subjectNm(subject.getSubjectNm())
                .parentSubjectCd(subject.getParentSubjectCd())
                .subjectDepth(subject.getSubjectDepth())
                .sortOrder(subject.getSortOrder())
                .category(subject.getCategory())
                .description(subject.getDescription())
                .isUse(subject.getIsUse())
                .regDt(subject.getRegDt())
                .updDt(subject.getUpdDt())
                .build();
    }
}
