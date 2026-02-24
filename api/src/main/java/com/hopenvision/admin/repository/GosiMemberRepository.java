package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiMember;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface GosiMemberRepository extends JpaRepository<GosiMember, String> {

    @Query("SELECT m FROM GosiMember m WHERE " +
           "(:keyword IS NULL OR :keyword = '' OR m.userId LIKE %:keyword% OR m.userNm LIKE %:keyword% OR m.userNicknm LIKE %:keyword%) " +
           "ORDER BY m.userId")
    Page<GosiMember> search(
            @Param("keyword") String keyword,
            Pageable pageable);
}
