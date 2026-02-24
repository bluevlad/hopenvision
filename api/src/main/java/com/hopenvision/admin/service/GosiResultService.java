package com.hopenvision.admin.service;

import com.hopenvision.admin.dto.GosiResultDto;
import com.hopenvision.admin.entity.GosiRstDet;
import com.hopenvision.admin.entity.GosiRstMst;
import com.hopenvision.admin.entity.GosiRstMstId;
import com.hopenvision.admin.entity.GosiRstSbj;
import com.hopenvision.admin.repository.GosiRstDetRepository;
import com.hopenvision.admin.repository.GosiRstMstRepository;
import com.hopenvision.admin.repository.GosiRstSbjRepository;
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
public class GosiResultService {

    private final GosiRstMstRepository gosiRstMstRepository;
    private final GosiRstDetRepository gosiRstDetRepository;
    private final GosiRstSbjRepository gosiRstSbjRepository;

    /**
     * 성적 목록 조회 (페이징)
     */
    public Page<GosiResultDto.RstMstResponse> getResultList(GosiResultDto.SearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());
        return gosiRstMstRepository.search(
                request.getGosiCd(),
                request.getGosiType(),
                request.getGosiArea(),
                request.getKeyword(),
                pageable
        ).map(this::toRstMstResponse);
    }

    /**
     * 성적 상세 조회
     */
    public GosiResultDto.RstDetailResponse getResultDetail(String gosiCd, String rstNo) {
        GosiRstMst master = gosiRstMstRepository.findById(new GosiRstMstId(gosiCd, rstNo))
                .orElseThrow(() -> new EntityNotFoundException("성적을 찾을 수 없습니다: " + gosiCd + "/" + rstNo));

        List<GosiRstSbj> subjects = gosiRstSbjRepository.findByGosiCdAndRstNoOrderBySubjectCd(gosiCd, rstNo);
        List<GosiRstDet> details = gosiRstDetRepository.findByGosiCdAndRstNoOrderBySubjectCdAscItemNoAsc(gosiCd, rstNo);

        return GosiResultDto.RstDetailResponse.builder()
                .master(toRstMstResponse(master))
                .subjects(subjects.stream().map(this::toRstSbjResponse).collect(Collectors.toList()))
                .details(details.stream().map(this::toRstDetResponse).collect(Collectors.toList()))
                .build();
    }

    private GosiResultDto.RstMstResponse toRstMstResponse(GosiRstMst entity) {
        return GosiResultDto.RstMstResponse.builder()
                .gosiCd(entity.getGosiCd())
                .rstNo(entity.getRstNo())
                .userId(entity.getUserId())
                .gosiType(entity.getGosiType())
                .gosiArea(entity.getGosiArea())
                .totalScore(entity.getTotalScore())
                .avgScore(entity.getAvgScore())
                .passYn(entity.getPassYn())
                .regDt(entity.getRegDt())
                .build();
    }

    private GosiResultDto.RstDetResponse toRstDetResponse(GosiRstDet entity) {
        return GosiResultDto.RstDetResponse.builder()
                .gosiCd(entity.getGosiCd())
                .rstNo(entity.getRstNo())
                .subjectCd(entity.getSubjectCd())
                .itemNo(entity.getItemNo())
                .userId(entity.getUserId())
                .answerData(entity.getAnswerData())
                .isCorrect(entity.getIsCorrect())
                .regDt(entity.getRegDt())
                .build();
    }

    private GosiResultDto.RstSbjResponse toRstSbjResponse(GosiRstSbj entity) {
        return GosiResultDto.RstSbjResponse.builder()
                .gosiCd(entity.getGosiCd())
                .rstNo(entity.getRstNo())
                .subjectCd(entity.getSubjectCd())
                .subjectNm(entity.getSubjectNm())
                .score(entity.getScore())
                .correctCnt(entity.getCorrectCnt())
                .totalCnt(entity.getTotalCnt())
                .build();
    }
}
