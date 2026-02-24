package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiAreaMst;
import com.hopenvision.admin.entity.GosiAreaMstId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GosiAreaMstRepository extends JpaRepository<GosiAreaMst, GosiAreaMstId> {

    List<GosiAreaMst> findByGosiTypeOrderByPos(String gosiType);

    List<GosiAreaMst> findByGosiTypeAndIsuseOrderByPos(String gosiType, String isuse);
}
