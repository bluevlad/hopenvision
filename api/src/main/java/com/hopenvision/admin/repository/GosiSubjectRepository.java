package com.hopenvision.admin.repository;

import com.hopenvision.admin.entity.GosiSubject;
import com.hopenvision.admin.entity.GosiSubjectId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GosiSubjectRepository extends JpaRepository<GosiSubject, GosiSubjectId> {

    List<GosiSubject> findByGosiTypeOrderByPos(String gosiType);

    List<GosiSubject> findByGosiTypeAndIsuseOrderByPos(String gosiType, String isuse);
}
