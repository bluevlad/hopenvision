package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiRstDet;
import com.hopenvision.admin.entity.GosiRstDetId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GosiRstDetRepository extends JpaRepository<GosiRstDet, GosiRstDetId> {

    List<GosiRstDet> findByGosiCdAndRstNoOrderBySubjectCdAscItemNoAsc(String gosiCd, String rstNo);
}
