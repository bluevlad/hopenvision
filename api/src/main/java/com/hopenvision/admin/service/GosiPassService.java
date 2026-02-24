package com.hopenvision.admin.service;

import com.hopenvision.admin.dto.GosiPassDto;
import com.hopenvision.admin.entity.GosiPassMst;
import com.hopenvision.admin.entity.GosiPassSta;
import com.hopenvision.admin.repository.GosiPassMstRepository;
import com.hopenvision.admin.repository.GosiPassStaRepository;
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
public class GosiPassService {

    private final GosiPassMstRepository gosiPassMstRepository;
    private final GosiPassStaRepository gosiPassStaRepository;

    /**
     * 정답 목록 조회 (페이징)
     */
    public Page<GosiPassDto.PassMstResponse> getPassList(GosiPassDto.SearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());
        return gosiPassMstRepository.search(
                request.getGosiCd(),
                request.getSubjectCd(),
                request.getExamType(),
                pageable
        ).map(this::toPassMstResponse);
    }

    /**
     * 합격선 조회
     */
    public List<GosiPassDto.PassStaResponse> getPassStaList(String gosiCd) {
        return gosiPassStaRepository.findByGosiCd(gosiCd).stream()
                .map(this::toPassStaResponse)
                .collect(Collectors.toList());
    }

    private GosiPassDto.PassMstResponse toPassMstResponse(GosiPassMst entity) {
        return GosiPassDto.PassMstResponse.builder()
                .gosiCd(entity.getGosiCd())
                .subjectCd(entity.getSubjectCd())
                .examType(entity.getExamType())
                .itemNo(entity.getItemNo())
                .answerData(entity.getAnswerData())
                .subjectNm(entity.getSubjectNm())
                .build();
    }

    private GosiPassDto.PassStaResponse toPassStaResponse(GosiPassSta entity) {
        return GosiPassDto.PassStaResponse.builder()
                .gosiCd(entity.getGosiCd())
                .gosiType(entity.getGosiType())
                .gosiTypeNm(entity.getGosiTypeNm())
                .passScore(entity.getPassScore())
                .isuse(entity.getIsuse())
                .build();
    }
}
