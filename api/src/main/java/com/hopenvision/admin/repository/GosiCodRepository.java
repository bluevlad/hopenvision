package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiCod;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GosiCodRepository extends JpaRepository<GosiCod, String> {

    List<GosiCod> findByIsuseOrderByPos(String isuse);
}
