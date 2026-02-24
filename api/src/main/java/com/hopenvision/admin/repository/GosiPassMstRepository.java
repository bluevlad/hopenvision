package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiPassMst;
import com.hopenvision.admin.entity.GosiPassMstId;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GosiPassMstRepository extends JpaRepository<GosiPassMst, GosiPassMstId> {

    List<GosiPassMst> findByGosiCdOrderBySubjectCdAscItemNoAsc(String gosiCd);

    List<GosiPassMst> findByGosiCdAndSubjectCdOrderByItemNo(String gosiCd, String subjectCd);

    @Query("SELECT p FROM GosiPassMst p WHERE p.gosiCd = :gosiCd " +
           "AND (:subjectCd IS NULL OR :subjectCd = '' OR p.subjectCd = :subjectCd) " +
           "AND (:examType IS NULL OR :examType = '' OR p.examType = :examType) " +
           "ORDER BY p.subjectCd, p.itemNo")
    Page<GosiPassMst> search(
            @Param("gosiCd") String gosiCd,
            @Param("subjectCd") String subjectCd,
            @Param("examType") String examType,
            Pageable pageable);
}
