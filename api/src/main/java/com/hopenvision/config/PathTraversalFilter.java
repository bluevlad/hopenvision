package com.hopenvision.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

/**
 * Path Traversal 공격을 감지하고 차단하는 필터.
 * 요청 URI와 쿼리 파라미터에서 경로 탐색 패턴을 검사하여 400 응답을 반환한다.
 */
@Slf4j
public class PathTraversalFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        // 요청 URI 검사
        String requestUri = request.getRequestURI();
        if (containsPathTraversal(requestUri)) {
            log.warn("Path Traversal 시도 차단 - URI: {}", requestUri);
            sendBadRequest(response, "잘못된 요청 경로입니다.");
            return;
        }

        // 쿼리 스트링 검사
        String queryString = request.getQueryString();
        if (queryString != null && containsPathTraversal(queryString)) {
            log.warn("Path Traversal 시도 차단 - Query: {}", queryString);
            sendBadRequest(response, "잘못된 요청 파라미터입니다.");
            return;
        }

        filterChain.doFilter(request, response);
    }

    private boolean containsPathTraversal(String value) {
        if (value == null || value.isEmpty()) {
            return false;
        }

        // Null byte 검사
        if (value.contains("%00") || value.indexOf('\0') >= 0) {
            return true;
        }

        // 원본 값 검사
        if (hasTraversalPattern(value)) {
            return true;
        }

        // URL 디코딩 후 검사 (이중 인코딩 우회 방지)
        try {
            String decoded = URLDecoder.decode(value, StandardCharsets.UTF_8);
            if (!decoded.equals(value)) {
                if (decoded.indexOf('\0') >= 0) {
                    return true;
                }
                if (hasTraversalPattern(decoded)) {
                    return true;
                }
                // 이중 인코딩 검사
                String doubleDecoded = URLDecoder.decode(decoded, StandardCharsets.UTF_8);
                if (!doubleDecoded.equals(decoded)) {
                    if (doubleDecoded.indexOf('\0') >= 0) {
                        return true;
                    }
                    if (hasTraversalPattern(doubleDecoded)) {
                        return true;
                    }
                }
            }
        } catch (IllegalArgumentException e) {
            // 디코딩 실패 시 무시
        }

        return false;
    }

    private boolean hasTraversalPattern(String value) {
        String lower = value.toLowerCase();

        // 인코딩된 패턴 검사 (디코딩 전 원본에서)
        if (lower.contains("..%2f") || lower.contains("%2e%2e%2f") ||
            lower.contains("%2e%2e/") || lower.contains("..%5c") ||
            lower.contains("%2e%2e%5c") || lower.contains("%2e%2e\\") ||
            lower.contains("%2e.%2f") || lower.contains(".%2e%2f") ||
            lower.contains("%2e./") || lower.contains(".%2e/") ||
            lower.contains("%2e.\\") || lower.contains(".%2e\\") ||
            lower.contains("..%255c") || lower.contains("..%252f") ||
            lower.contains("%c0%ae") || lower.contains("%c1%9c")) {
            return true;
        }

        // 디코딩된 값에서 ../ 또는 ..\ 검사
        if (value.contains("../") || value.contains("..\\")) {
            return true;
        }

        // /.. 패턴 (경로 세그먼트로서의 ..)
        if (value.contains("/..") || value.contains("\\..")) {
            return true;
        }

        return false;
    }

    private void sendBadRequest(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":false,\"code\":\"PATH_TRAVERSAL\",\"message\":\"" + message + "\",\"data\":null}");
    }
}
