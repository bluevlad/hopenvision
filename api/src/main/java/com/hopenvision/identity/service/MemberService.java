package com.hopenvision.identity.service;

import com.hopenvision.identity.dto.MemberResponse;
import com.hopenvision.identity.dto.MemberSignupRequest;
import com.hopenvision.identity.entity.Member;
import com.hopenvision.identity.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberService {

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public MemberResponse signup(MemberSignupRequest req) {
        if (memberRepository.existsByEmail(req.email())) {
            throw new IllegalArgumentException("이미 등록된 이메일입니다: " + req.email());
        }
        Member member = Member.signup(
                req.email(),
                passwordEncoder.encode(req.password()),
                req.name(),
                req.phone()
        );
        Member saved = memberRepository.save(member);
        return MemberResponse.from(saved);
    }

    public MemberResponse getByEmail(String email) {
        Member m = memberRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("회원을 찾을 수 없습니다: " + email));
        return MemberResponse.from(m);
    }
}
