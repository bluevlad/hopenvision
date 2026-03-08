package com.hopenvision.config;

import com.hopenvision.auth.JwtTokenProvider;
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

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.HexFormat;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Value("${app.admin.api-key:}")
    private String adminApiKey;

    @Value("${app.user.auth-secret:}")
    private String userAuthSecret;

    private final JwtTokenProvider jwtTokenProvider;

    public SecurityConfig(JwtTokenProvider jwtTokenProvider) {
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // Swagger/OpenAPI - 허용
                .requestMatchers("/swagger-ui/**", "/api-docs/**", "/v3/api-docs/**").permitAll()
                // Google OAuth 인증 - 허용
                .requestMatchers("/api/auth/**").permitAll()
                // 사용자 시험 응시 API - 허용 (X-User-Id 헤더 검증은 컨트롤러에서)
                .requestMatchers("/api/user/**").permitAll()
                // 통계 조회 - 허용
                .requestMatchers(HttpMethod.GET, "/api/statistics/**").permitAll()
                // 관리자 API - API Key 또는 JWT 필수
                .requestMatchers(HttpMethod.POST, "/api/**").authenticated()
                .requestMatchers(HttpMethod.PUT, "/api/**").authenticated()
                .requestMatchers(HttpMethod.DELETE, "/api/**").authenticated()
                // GET 요청 - 허용
                .requestMatchers(HttpMethod.GET, "/api/**").permitAll()
                .anyRequest().permitAll()
            )
            .addFilterBefore(new ApiKeyAuthFilter(adminApiKey, jwtTokenProvider), UsernamePasswordAuthenticationFilter.class)
            .addFilterBefore(new UserIdAuthFilter(userAuthSecret), ApiKeyAuthFilter.class);

        return http.build();
    }

    /**
     * X-User-Id HMAC 서명 검증 필터
     * USER_AUTH_SECRET이 설정된 경우 X-User-Signature 헤더로 서명 검증
     */
    static class UserIdAuthFilter extends OncePerRequestFilter {

        private final String authSecret;

        UserIdAuthFilter(String authSecret) {
            this.authSecret = authSecret;
        }

        @Override
        protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                        FilterChain filterChain) throws ServletException, IOException {
            String userId = request.getHeader("X-User-Id");

            // X-User-Id가 없으면 스킵
            if (userId == null || userId.isBlank()) {
                filterChain.doFilter(request, response);
                return;
            }

            // auth-secret이 미설정이면 검증 스킵 (개발 환경 호환)
            if (authSecret == null || authSecret.isBlank()) {
                filterChain.doFilter(request, response);
                return;
            }

            // HMAC 서명 검증
            String signature = request.getHeader("X-User-Signature");
            if (signature == null || !verifyHmac(userId, signature)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"error\":\"Invalid user signature\"}");
                return;
            }

            filterChain.doFilter(request, response);
        }

        private boolean verifyHmac(String userId, String signature) {
            try {
                Mac mac = Mac.getInstance("HmacSHA256");
                mac.init(new SecretKeySpec(authSecret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
                String expected = HexFormat.of().formatHex(mac.doFinal(userId.getBytes(StandardCharsets.UTF_8)));
                return expected.equalsIgnoreCase(signature);
            } catch (Exception e) {
                return false;
            }
        }
    }

    /**
     * API Key 및 JWT 인증 필터
     * X-Api-Key 헤더, Authorization: Bearer <api-key>, 또는 Authorization: Bearer <jwt> 로 인증
     */
    static class ApiKeyAuthFilter extends OncePerRequestFilter {

        private final String apiKey;
        private final JwtTokenProvider jwtTokenProvider;

        ApiKeyAuthFilter(String apiKey, JwtTokenProvider jwtTokenProvider) {
            this.apiKey = apiKey;
            this.jwtTokenProvider = jwtTokenProvider;
        }

        @Override
        protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                        FilterChain filterChain) throws ServletException, IOException {
            // Try X-Api-Key header first
            String requestApiKey = request.getHeader("X-Api-Key");
            String bearerToken = null;

            if (requestApiKey == null) {
                String authHeader = request.getHeader("Authorization");
                if (authHeader != null && authHeader.startsWith("Bearer ")) {
                    bearerToken = authHeader.substring(7);
                    requestApiKey = bearerToken; // might be API key or JWT
                }
            }

            // Check API Key auth
            if (apiKey != null && !apiKey.isBlank() && apiKey.equals(requestApiKey)) {
                setAdminAuth("admin");
                filterChain.doFilter(request, response);
                return;
            }

            // Check JWT auth (Bearer token that is not the API key)
            if (bearerToken != null && jwtTokenProvider.isValid(bearerToken)) {
                String email = jwtTokenProvider.getEmail(bearerToken);
                String role = jwtTokenProvider.getRole(bearerToken);
                if ("ADMIN".equals(role)) {
                    setAdminAuth(email);
                }
                filterChain.doFilter(request, response);
                return;
            }

            // API key not configured - allow all (development environment)
            if (apiKey == null || apiKey.isBlank()) {
                filterChain.doFilter(request, response);
                return;
            }

            filterChain.doFilter(request, response);
        }

        private void setAdminAuth(String principal) {
            var auth = new org.springframework.security.authentication.UsernamePasswordAuthenticationToken(
                    principal, null,
                    java.util.List.of(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_ADMIN"))
            );
            org.springframework.security.core.context.SecurityContextHolder.getContext().setAuthentication(auth);
        }
    }
}
