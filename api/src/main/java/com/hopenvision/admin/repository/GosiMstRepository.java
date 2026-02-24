package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiMst;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GosiMstRepository extends JpaRepository<GosiMst, String> {
}
