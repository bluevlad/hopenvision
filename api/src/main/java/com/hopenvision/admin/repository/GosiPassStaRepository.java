package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiPassSta;
import com.hopenvision.admin.entity.GosiPassStaId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GosiPassStaRepository extends JpaRepository<GosiPassSta, GosiPassStaId> {

    List<GosiPassSta> findByGosiCd(String gosiCd);
}
