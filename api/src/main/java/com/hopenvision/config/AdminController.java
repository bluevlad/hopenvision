package com.hopenvision.config;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @PostMapping("/verify")
    public ResponseEntity<Map<String, Object>> verify() {
        // SecurityConfig에 의해 POST 요청은 인증 필요
        // 이 메서드에 도달했다면 API Key 인증이 통과된 것
        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "인증 성공"
        ));
    }
}
