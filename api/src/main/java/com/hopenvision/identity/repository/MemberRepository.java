package com.hopenvision.identity.repository;

import com.hopenvision.identity.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, Long> {

    Optional<Member> findByEmail(String email);

    Optional<Member> findByGoogleSub(String googleSub);

    boolean existsByEmail(String email);
}
