package com.hopenvision.admin.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "tb_ma_member")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GosiMember {

    @Id
    @Column(name = "user_id", length = 100)
    private String userId;

    @Column(name = "user_nm", length = 200)
    private String userNm;

    @Column(name = "user_nicknm", length = 200)
    private String userNicknm;

    @Column(name = "user_position", length = 100)
    private String userPosition;

    @Column(name = "sex", length = 10)
    private String sex;

    @Column(name = "user_role", length = 50)
    private String userRole;

    @Column(name = "admin_role", length = 50)
    private String adminRole;

    @Column(name = "user_pwd", length = 500)
    private String userPwd;

    @Column(name = "birth_day")
    private LocalDateTime birthDay;

    @Column(name = "category_code", length = 100)
    private String categoryCode;

    @Column(name = "user_point")
    private Integer userPoint;

    @Column(name = "payment")
    private Integer payment;

    @Column(name = "pic1", length = 500)
    private String pic1;

    @Column(name = "pic2", length = 500)
    private String pic2;

    @Column(name = "pic3", length = 500)
    private String pic3;

    @Column(name = "pic4", length = 500)
    private String pic4;

    @Column(name = "isuse", length = 10)
    private String isuse;
}
