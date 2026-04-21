package com.hopenvision.identity.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * Identity 모듈 전용 Password 인코더 빈.
 *
 * <p>전역 SecurityConfig 는 Google OAuth + JWT 중심이라 PasswordEncoder 를 등록하지 않음.
 * 이메일+비밀번호 가입을 도입하는 identity 모듈이 자체적으로 제공.
 */
@Configuration
public class IdentityPasswordConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
