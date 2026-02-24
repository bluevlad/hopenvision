package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiRstSbj;
import com.hopenvision.admin.entity.GosiRstSbjId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GosiRstSbjRepository extends JpaRepository<GosiRstSbj, GosiRstSbjId> {

    List<GosiRstSbj> findByGosiCdAndRstNoOrderBySubjectCd(String gosiCd, String rstNo);
}
