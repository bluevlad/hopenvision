package com.hopenvision.exam.service;

import com.hopenvision.exam.dto.ApplicantDto;
import com.hopenvision.exam.entity.ExamApplicant;
import com.hopenvision.exam.entity.ExamApplicantId;
import com.hopenvision.exam.repository.ExamApplicantRepository;
import com.hopenvision.exam.repository.ExamRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class ApplicantService {

    private final ExamApplicantRepository applicantRepository;
    private final ExamRepository examRepository;

    public Page<ApplicantDto.Response> getApplicantList(ApplicantDto.SearchRequest request) {
        if (!examRepository.existsById(request.getExamCd())) {
            throw new EntityNotFoundException("시험을 찾을 수 없습니다: " + request.getExamCd());
        }

        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());
        return applicantRepository.searchByExamCd(request.getExamCd(), request.getKeyword(), pageable)
                .map(this::toResponse);
    }

    public ApplicantDto.Response getApplicant(String examCd, String applicantNo) {
        ExamApplicant applicant = applicantRepository.findById(new ExamApplicantId(examCd, applicantNo))
                .orElseThrow(() -> new EntityNotFoundException("응시자를 찾을 수 없습니다: " + applicantNo));
        return toResponse(applicant);
    }

    @Transactional
    public ApplicantDto.Response createApplicant(String examCd, ApplicantDto.Request request) {
        if (!examRepository.existsById(examCd)) {
            throw new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd);
        }
        if (applicantRepository.existsByExamCdAndApplicantNo(examCd, request.getApplicantNo())) {
            throw new IllegalArgumentException("이미 존재하는 수험번호입니다: " + request.getApplicantNo());
        }

        ExamApplicant applicant = ExamApplicant.builder()
                .examCd(examCd)
                .applicantNo(request.getApplicantNo())
                .userId(request.getUserId())
                .userNm(request.getUserNm())
                .applyArea(request.getApplyArea())
                .applyType(request.getApplyType())
                .addScore(request.getAddScore() != null ? request.getAddScore() : BigDecimal.ZERO)
                .build();

        return toResponse(applicantRepository.save(applicant));
    }

    @Transactional
    public ApplicantDto.Response updateApplicant(String examCd, String applicantNo, ApplicantDto.Request request) {
        ExamApplicant applicant = applicantRepository.findById(new ExamApplicantId(examCd, applicantNo))
                .orElseThrow(() -> new EntityNotFoundException("응시자를 찾을 수 없습니다: " + applicantNo));

        applicant.setUserNm(request.getUserNm());
        applicant.setUserId(request.getUserId());
        applicant.setApplyArea(request.getApplyArea());
        applicant.setApplyType(request.getApplyType());
        applicant.setAddScore(request.getAddScore() != null ? request.getAddScore() : BigDecimal.ZERO);

        return toResponse(applicantRepository.save(applicant));
    }

    @Transactional
    public void deleteApplicant(String examCd, String applicantNo) {
        ExamApplicantId id = new ExamApplicantId(examCd, applicantNo);
        if (!applicantRepository.existsById(id)) {
            throw new EntityNotFoundException("응시자를 찾을 수 없습니다: " + applicantNo);
        }
        applicantRepository.deleteById(id);
    }

    private ApplicantDto.Response toResponse(ExamApplicant applicant) {
        return ApplicantDto.Response.builder()
                .examCd(applicant.getExamCd())
                .applicantNo(applicant.getApplicantNo())
                .userId(applicant.getUserId())
                .userNm(applicant.getUserNm())
                .applyArea(applicant.getApplyArea())
                .applyType(applicant.getApplyType())
                .addScore(applicant.getAddScore())
                .totalScore(applicant.getTotalScore())
                .avgScore(applicant.getAvgScore())
                .ranking(applicant.getRanking())
                .passYn(applicant.getPassYn())
                .scoreStatus(applicant.getScoreStatus())
                .regDt(applicant.getRegDt())
                .updDt(applicant.getUpdDt())
                .build();
    }
}
