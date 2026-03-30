package com.hopenvision.exam.repository;

import com.hopenvision.exam.entity.ImportJob;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ImportJobRepository extends JpaRepository<ImportJob, String> {

    Optional<ImportJob> findByFileHashAndStatusIn(String fileHash, List<String> statuses);

    List<ImportJob> findByExamCdAndJobTypeOrderByRegDtDesc(String examCd, String jobType);

    List<ImportJob> findByExamCdOrderByRegDtDesc(String examCd);
}
