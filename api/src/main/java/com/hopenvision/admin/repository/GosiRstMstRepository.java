package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiRstMst;
import com.hopenvision.admin.entity.GosiRstMstId;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface GosiRstMstRepository extends JpaRepository<GosiRstMst, GosiRstMstId> {

    @Query("SELECT r FROM GosiRstMst r WHERE r.gosiCd = :gosiCd " +
           "AND (:gosiType IS NULL OR :gosiType = '' OR r.gosiType = :gosiType) " +
           "AND (:gosiArea IS NULL OR :gosiArea = '' OR r.gosiArea = :gosiArea) " +
           "AND (:keyword IS NULL OR :keyword = '' OR r.userId LIKE %:keyword% OR r.rstNo LIKE %:keyword%) " +
           "ORDER BY r.regDt DESC")
    Page<GosiRstMst> search(
            @Param("gosiCd") String gosiCd,
            @Param("gosiType") String gosiType,
            @Param("gosiArea") String gosiArea,
            @Param("keyword") String keyword,
            Pageable pageable);
}
