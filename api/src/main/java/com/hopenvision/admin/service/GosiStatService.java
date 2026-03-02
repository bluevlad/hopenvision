package com.hopenvision.admin.service;

import com.hopenvision.admin.dto.GosiStatDto;
import com.hopenvision.admin.entity.GosiSbjMst;
import com.hopenvision.admin.entity.GosiStatMst;
import com.hopenvision.admin.repository.GosiRstMstRepository;
import com.hopenvision.admin.repository.GosiRstSbjRepository;
import com.hopenvision.admin.repository.GosiSbjMstRepository;
import com.hopenvision.admin.repository.GosiStatMstRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class GosiStatService {

    private final GosiStatMstRepository gosiStatMstRepository;
    private final GosiSbjMstRepository gosiSbjMstRepository;
    private final GosiRstMstRepository gosiRstMstRepository;
    private final GosiRstSbjRepository gosiRstSbjRepository;

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

    /**
     * 점수 분포 조회
     */
    public List<GosiStatDto.ScoreDistributionResponse> getScoreDistribution(String gosiCd, String gosiType, String gosiArea) {
        return gosiRstMstRepository.findScoreDistribution(gosiCd, gosiType, gosiArea).stream()
                .map(row -> GosiStatDto.ScoreDistributionResponse.builder()
                        .range((String) row[0])
                        .count(((Number) row[1]).longValue())
                        .build())
                .collect(Collectors.toList());
    }

    /**
     * 년도별 추이 조회
     */
    public List<GosiStatDto.YearlyTrendResponse> getYearlyTrend(String gosiType) {
        return gosiRstMstRepository.findYearlyTrend(gosiType).stream()
                .map(row -> GosiStatDto.YearlyTrendResponse.builder()
                        .gosiYear((String) row[0])
                        .avgScore(toBigDecimal(row[1]))
                        .passRate(toBigDecimal(row[2]))
                        .totalCnt(((Number) row[3]).longValue())
                        .build())
                .collect(Collectors.toList());
    }

    /**
     * 과목별 성적 비교
     */
    public List<GosiStatDto.SubjectScoreResponse> getSubjectScoreComparison(String gosiCd) {
        return gosiRstSbjRepository.findSubjectScoreComparison(gosiCd).stream()
                .map(row -> GosiStatDto.SubjectScoreResponse.builder()
                        .subjectCd((String) row[0])
                        .subjectNm((String) row[1])
                        .avgScore(toBigDecimal(row[2]))
                        .maxScore(toBigDecimal(row[3]))
                        .minScore(toBigDecimal(row[4]))
                        .totalCnt(((Number) row[5]).longValue())
                        .build())
                .collect(Collectors.toList());
    }

    /**
     * 지역별 성적 비교
     */
    public List<GosiStatDto.AreaScoreResponse> getAreaScoreComparison(String gosiCd, String gosiType) {
        return gosiStatMstRepository.findAreaScoreComparison(gosiCd, gosiType).stream()
                .map(row -> GosiStatDto.AreaScoreResponse.builder()
                        .gosiArea((String) row[0])
                        .gosiAreaNm((String) row[1])
                        .avgScore(toBigDecimal(row[2]))
                        .passRate(toBigDecimal(row[3]))
                        .totalCnt(((Number) row[4]).intValue())
                        .build())
                .collect(Collectors.toList());
    }

    private BigDecimal toBigDecimal(Object value) {
        if (value == null) return BigDecimal.ZERO;
        if (value instanceof BigDecimal) return ((BigDecimal) value).setScale(2, RoundingMode.HALF_UP);
        return BigDecimal.valueOf(((Number) value).doubleValue()).setScale(2, RoundingMode.HALF_UP);
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
