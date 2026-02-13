package com.hopenvision.user.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_profile")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProfile {

    @Id
    @Column(name = "user_id", length = 50)
    private String userId;

    @Column(name = "user_nm", length = 100, nullable = false)
    private String userNm;

    @Column(name = "email", length = 200)
    private String email;

    @Column(name = "newsletter_yn", length = 1)
    @Builder.Default
    private String newsletterYn = "N";

    @Version
    @Column(name = "version")
    private Long version;

    @CreationTimestamp
    @Column(name = "reg_dt", updatable = false)
    private LocalDateTime regDt;

    @UpdateTimestamp
    @Column(name = "upd_dt")
    private LocalDateTime updDt;
}
