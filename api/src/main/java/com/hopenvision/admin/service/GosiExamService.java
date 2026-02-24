package com.hopenvision.admin.service;

import com.hopenvision.admin.dto.GosiExamDto;
import com.hopenvision.admin.entity.GosiAreaMst;
import com.hopenvision.admin.entity.GosiCod;
import com.hopenvision.admin.entity.GosiMst;
import com.hopenvision.admin.repository.GosiAreaMstRepository;
import com.hopenvision.admin.repository.GosiCodRepository;
import com.hopenvision.admin.repository.GosiMstRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class GosiExamService {

    private final GosiMstRepository gosiMstRepository;
    private final GosiCodRepository gosiCodRepository;
    private final GosiAreaMstRepository gosiAreaMstRepository;

    /**
     * 시험 목록 조회
     */
    public List<GosiExamDto.MstResponse> getExamList() {
        return gosiMstRepository.findAll().stream()
                .map(this::toMstResponse)
                .collect(Collectors.toList());
    }

    /**
     * 시험 상세 조회
     */
    public GosiExamDto.MstResponse getExamDetail(String gosiCd) {
        GosiMst mst = gosiMstRepository.findById(gosiCd)
                .orElseThrow(() -> new jakarta.persistence.EntityNotFoundException("시험을 찾을 수 없습니다: " + gosiCd));
        return toMstResponse(mst);
    }

    /**
     * 시험 유형 목록 조회
     */
    public List<GosiExamDto.CodResponse> getTypeList() {
        return gosiCodRepository.findAll().stream()
                .map(this::toCodResponse)
                .collect(Collectors.toList());
    }

    /**
     * 지역 목록 조회
     */
    public List<GosiExamDto.AreaResponse> getAreaList(String gosiType) {
        List<GosiAreaMst> areas;
        if (gosiType != null && !gosiType.isEmpty()) {
            areas = gosiAreaMstRepository.findByGosiTypeOrderByPos(gosiType);
        } else {
            areas = gosiAreaMstRepository.findAll();
        }
        return areas.stream()
                .map(this::toAreaResponse)
                .collect(Collectors.toList());
    }

    private GosiExamDto.MstResponse toMstResponse(GosiMst entity) {
        return GosiExamDto.MstResponse.builder()
                .gosiCd(entity.getGosiCd())
                .gosiNm(entity.getGosiNm())
                .gosiType(entity.getGosiType())
                .startDt(entity.getStartDt())
                .endDt(entity.getEndDt())
                .isuse(entity.getIsuse())
                .regDt(entity.getRegDt())
                .gosiYear(entity.getGosiYear())
                .gosiRound(entity.getGosiRound())
                .totalScore(entity.getTotalScore())
                .passScore(entity.getPassScore())
                .build();
    }

    private GosiExamDto.CodResponse toCodResponse(GosiCod entity) {
        return GosiExamDto.CodResponse.builder()
                .gosiType(entity.getGosiType())
                .gosiTypeNm(entity.getGosiTypeNm())
                .isuse(entity.getIsuse())
                .pos(entity.getPos())
                .build();
    }

    private GosiExamDto.AreaResponse toAreaResponse(GosiAreaMst entity) {
        return GosiExamDto.AreaResponse.builder()
                .gosiType(entity.getGosiType())
                .gosiArea(entity.getGosiArea())
                .gosiAreaNm(entity.getGosiAreaNm())
                .isuse(entity.getIsuse())
                .pos(entity.getPos())
                .build();
    }
}
