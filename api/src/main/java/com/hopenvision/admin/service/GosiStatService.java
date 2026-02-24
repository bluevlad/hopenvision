package com.hopenvision.admin.service;

import com.hopenvision.admin.dto.GosiStatDto;
import com.hopenvision.admin.entity.GosiSbjMst;
import com.hopenvision.admin.entity.GosiStatMst;
import com.hopenvision.admin.repository.GosiSbjMstRepository;
import com.hopenvision.admin.repository.GosiStatMstRepository;
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
public class GosiStatService {

    private final GosiStatMstRepository gosiStatMstRepository;
    private final GosiSbjMstRepository gosiSbjMstRepository;

    /**
     * 통계 목록 조회 (페이징)
     */
    public Page<GosiStatDto.StatMstResponse> getStatList(GosiStatDto.SearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());
        return gosiStatMstRepository.search(
                request.getGosiCd(),
                request.getGosiType(),
                pageable
        ).map(this::toStatMstResponse);
    }

    /**
     * 대시보드용 통계 전체 조회
     */
    public List<GosiStatDto.StatMstResponse> getDashboard(String gosiCd) {
        return gosiStatMstRepository.findByGosiCdOrderByGosiTypeAscGosiAreaAsc(gosiCd).stream()
                .map(this::toStatMstResponse)
                .collect(Collectors.toList());
    }

    /**
     * 과목 구분 목록 조회
     */
    public List<GosiStatDto.SbjMstResponse> getSbjMstList(String gosiCd) {
        return gosiSbjMstRepository.findByGosiCdOrderBySbjTypeAscSubjectCdAsc(gosiCd).stream()
                .map(this::toSbjMstResponse)
                .collect(Collectors.toList());
    }

    private GosiStatDto.StatMstResponse toStatMstResponse(GosiStatMst entity) {
        return GosiStatDto.StatMstResponse.builder()
                .gosiCd(entity.getGosiCd())
                .gosiType(entity.getGosiType())
                .gosiArea(entity.getGosiArea())
                .gosiSubjectCd(entity.getGosiSubjectCd())
                .gosiTypeNm(entity.getGosiTypeNm())
                .gosiAreaNm(entity.getGosiAreaNm())
                .gosiSubjectNm(entity.getGosiSubjectNm())
                .totalCnt(entity.getTotalCnt())
                .avgScore(entity.getAvgScore())
                .maxScore(entity.getMaxScore())
                .minScore(entity.getMinScore())
                .passCnt(entity.getPassCnt())
                .passRate(entity.getPassRate())
                .build();
    }

    private GosiStatDto.SbjMstResponse toSbjMstResponse(GosiSbjMst entity) {
        return GosiStatDto.SbjMstResponse.builder()
                .gosiCd(entity.getGosiCd())
                .sbjType(entity.getSbjType())
                .subjectCd(entity.getSubjectCd())
                .subjectNm(entity.getSubjectNm())
                .isuse(entity.getIsuse())
                .pos(entity.getPos())
                .build();
    }
}
