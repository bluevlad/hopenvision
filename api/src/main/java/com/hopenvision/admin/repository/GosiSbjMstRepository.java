package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiSbjMst;
import com.hopenvision.admin.entity.GosiSbjMstId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GosiSbjMstRepository extends JpaRepository<GosiSbjMst, GosiSbjMstId> {

    List<GosiSbjMst> findByGosiCdOrderBySbjTypeAscSubjectCdAsc(String gosiCd);
}
