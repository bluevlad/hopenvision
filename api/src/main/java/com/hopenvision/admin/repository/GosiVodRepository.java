package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiVod;
import com.hopenvision.admin.entity.GosiVodId;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface GosiVodRepository extends JpaRepository<GosiVod, GosiVodId> {

    @Query("SELECT v FROM GosiVod v WHERE " +
           "(:gosiCd IS NULL OR :gosiCd = '' OR v.gosiCd = :gosiCd) " +
           "AND (:keyword IS NULL OR :keyword = '' OR v.subjectNm LIKE %:keyword% OR v.prfNm LIKE %:keyword% OR v.vodNm LIKE %:keyword%) " +
           "ORDER BY v.gosiCd, v.subjectCd, v.idx")
    Page<GosiVod> search(
            @Param("gosiCd") String gosiCd,
            @Param("keyword") String keyword,
            Pageable pageable);
}
