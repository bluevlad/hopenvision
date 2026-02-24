package com.hopenvision.admin.service;

import com.hopenvision.admin.dto.GosiMemberDto;
import com.hopenvision.admin.entity.GosiMember;
import com.hopenvision.admin.repository.GosiMemberRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class GosiMemberService {

    private final GosiMemberRepository gosiMemberRepository;

    /**
     * 회원 목록 조회 (페이징)
     */
    public Page<GosiMemberDto.Response> getMemberList(GosiMemberDto.SearchRequest request) {
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize());
        return gosiMemberRepository.search(request.getKeyword(), pageable)
                .map(this::toResponse);
    }

    /**
     * 회원 상세 조회
     */
    public GosiMemberDto.Response getMemberDetail(String userId) {
        GosiMember member = gosiMemberRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("회원을 찾을 수 없습니다: " + userId));
        return toResponse(member);
    }

    private GosiMemberDto.Response toResponse(GosiMember entity) {
        return GosiMemberDto.Response.builder()
                .userId(entity.getUserId())
                .userNm(entity.getUserNm())
                .userNicknm(entity.getUserNicknm())
                .userPosition(entity.getUserPosition())
                .sex(entity.getSex())
                .userRole(entity.getUserRole())
                .adminRole(entity.getAdminRole())
                .birthDay(entity.getBirthDay())
                .categoryCode(entity.getCategoryCode())
                .userPoint(entity.getUserPoint())
                .payment(entity.getPayment())
                .isuse(entity.getIsuse())
                .build();
    }
}
