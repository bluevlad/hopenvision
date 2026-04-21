package com.hopenvision.identity.dto;

import com.hopenvision.identity.entity.Member;

import java.time.LocalDateTime;

public record MemberResponse(
        Long memberId,
        String email,
        String name,
        String memberType,
        String memberStatus,
        LocalDateTime regDt
) {
    public static MemberResponse from(Member m) {
        return new MemberResponse(
                m.getMemberId(),
                m.getEmail(),
                m.getName(),
                m.getMemberType(),
                m.getMemberStatus(),
                m.getRegDt()
        );
    }
}
