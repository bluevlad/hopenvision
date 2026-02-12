package com.hopenvision.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Value("${app.admin.api-key:}")
    private String adminApiKey;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // Swagger/OpenAPI - 허용
                .requestMatchers("/swagger-ui/**", "/api-docs/**", "/v3/api-docs/**").permitAll()
                // 사용자 시험 응시 API - 허용 (X-User-Id 헤더 검증은 컨트롤러에서)
                .requestMatchers("/api/user/**").permitAll()
                // 통계 조회 - 허용
                .requestMatchers(HttpMethod.GET, "/api/statistics/**").permitAll()
                // 관리자 API - API Key 필수
                .requestMatchers(HttpMethod.POST, "/api/**").authenticated()
                .requestMatchers(HttpMethod.PUT, "/api/**").authenticated()
                .requestMatchers(HttpMethod.DELETE, "/api/**").authenticated()
                // GET 요청 - 허용
                .requestMatchers(HttpMethod.GET, "/api/**").permitAll()
                .anyRequest().permitAll()
            )
            .addFilterBefore(new ApiKeyAuthFilter(adminApiKey), UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * API Key 인증 필터
     * X-Api-Key 헤더 또는 Authorization: Bearer <key> 헤더로 인증
     */
    static class ApiKeyAuthFilter extends OncePerRequestFilter {

        private final String apiKey;

        ApiKeyAuthFilter(String apiKey) {
            this.apiKey = apiKey;
        }

        @Override
        protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                        FilterChain filterChain) throws ServletException, IOException {
            // API key가 설정되지 않은 경우 모든 요청 허용 (개발 환경)
            if (apiKey == null || apiKey.isBlank()) {
                filterChain.doFilter(request, response);
                return;
            }

            String requestApiKey = request.getHeader("X-Api-Key");
            if (requestApiKey == null) {
                String authHeader = request.getHeader("Authorization");
                if (authHeader != null && authHeader.startsWith("Bearer ")) {
                    requestApiKey = authHeader.substring(7);
                }
            }

            if (apiKey.equals(requestApiKey)) {
                var auth = new org.springframework.security.authentication.UsernamePasswordAuthenticationToken(
                        "admin", null,
                        java.util.List.of(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_ADMIN"))
                );
                org.springframework.security.core.context.SecurityContextHolder.getContext().setAuthentication(auth);
            }

            filterChain.doFilter(request, response);
        }
    }
}
