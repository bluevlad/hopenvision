package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiStatMst;
import com.hopenvision.admin.entity.GosiStatMstId;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GosiStatMstRepository extends JpaRepository<GosiStatMst, GosiStatMstId> {

    @Query("SELECT s FROM GosiStatMst s WHERE s.gosiCd = :gosiCd " +
           "AND (:gosiType IS NULL OR :gosiType = '' OR s.gosiType = :gosiType) " +
           "ORDER BY s.gosiType, s.gosiArea, s.gosiSubjectCd")
    Page<GosiStatMst> search(
            @Param("gosiCd") String gosiCd,
            @Param("gosiType") String gosiType,
            Pageable pageable);

    List<GosiStatMst> findByGosiCdOrderByGosiTypeAscGosiAreaAsc(String gosiCd);
}
