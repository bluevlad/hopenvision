package com.hopenvision.exam.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "import_job_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ImportJob {

    @Id
    @Column(name = "job_id", length = 36)
    private String jobId;

    @Column(name = "file_name", length = 200)
    private String fileName;

    @Column(name = "file_hash", length = 64, unique = true)
    private String fileHash;

    @Column(name = "file_path", length = 500)
    private String filePath;

    @Column(name = "job_type", length = 20)
    private String jobType;  // TEMP_SCORE, CSV_RESULT, SCORING, RANKING

    @Column(name = "exam_cd", length = 50)
    private String examCd;

    @Column(name = "status", length = 20)
    @Builder.Default
    private String status = "PENDING";  // PENDING, PROCESSING, COMPLETED, FAILED

    @Column(name = "total_rows")
    @Builder.Default
    private Integer totalRows = 0;

    @Column(name = "processed_rows")
    @Builder.Default
    private Integer processedRows = 0;

    @Column(name = "success_rows")
    @Builder.Default
    private Integer successRows = 0;

    @Column(name = "error_rows")
    @Builder.Default
    private Integer errorRows = 0;

    @Column(name = "error_message", columnDefinition = "TEXT")
    private String errorMessage;

    @Column(name = "result_summary", columnDefinition = "TEXT")
    private String resultSummary;

    @CreationTimestamp
    @Column(name = "reg_dt", updatable = false)
    private LocalDateTime regDt;

    @Column(name = "start_dt")
    private LocalDateTime startDt;

    @Column(name = "end_dt")
    private LocalDateTime endDt;
}
