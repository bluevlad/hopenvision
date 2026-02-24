package com.hopenvision.admin.service;

import com.hopenvision.admin.dto.GosiSubjectDto;
import com.hopenvision.admin.dto.GosiVodDto;
import com.hopenvision.admin.entity.GosiSubject;
import com.hopenvision.admin.entity.GosiVod;
import com.hopenvision.admin.repository.GosiSubjectRepository;
import com.hopenvision.admin.repository.GosiVodRepository;
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
public class GosiSubjectService {

    private final GosiSubjectRepository gosiSubjectRepository;
    private final GosiVodRepository gosiVodRepository;

    /**
     * 과목 목록 조회
     */
    public List<GosiSubjectDto.Response> getSubjectList(String gosiType) {
        List<GosiSubject> subjects;
        if (gosiType != null && !gosiType.isEmpty()) {
            subjects = gosiSubjectRepository.findByGosiTypeOrderByPos(gosiType);
        } else {
            subjects = gosiSubjectRepository.findAll();
        }
        return subjects.stream()
                .map(this::toSubjectResponse)
                .collect(Collectors.toList());
    }

    /**
     * VOD 목록 조회 (페이징)
     */
    public Page<GosiVodDto.Response> getVodList(GosiVodDto.SearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());
        return gosiVodRepository.search(
                request.getGosiCd(),
                request.getKeyword(),
                pageable
        ).map(this::toVodResponse);
    }

    private GosiSubjectDto.Response toSubjectResponse(GosiSubject entity) {
        return GosiSubjectDto.Response.builder()
                .gosiType(entity.getGosiType())
                .gosiSubjectCd(entity.getGosiSubjectCd())
                .gosiSubjecNm(entity.getGosiSubjecNm())
                .isuse(entity.getIsuse())
                .pos(entity.getPos())
                .build();
    }

    private GosiVodDto.Response toVodResponse(GosiVod entity) {
        return GosiVodDto.Response.builder()
                .gosiCd(entity.getGosiCd())
                .prfId(entity.getPrfId())
                .idx(entity.getIdx())
                .subjectCd(entity.getSubjectCd())
                .subjectNm(entity.getSubjectNm())
                .prfNm(entity.getPrfNm())
                .vodUrl(entity.getVodUrl())
                .vodNm(entity.getVodNm())
                .isuse(entity.getIsuse())
                .build();
    }
}
