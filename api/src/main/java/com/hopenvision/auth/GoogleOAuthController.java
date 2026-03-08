package com.hopenvision.auth;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.hopenvision.exam.dto.ApiResponse;
import lombok.Getter;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@Slf4j
@RestController
@RequestMapping("/api/auth/google")
public class GoogleOAuthController {

    private final JwtTokenProvider jwtTokenProvider;
    private final Set<String> superAdminEmails;
    private final GoogleIdTokenVerifier verifier;

    public GoogleOAuthController(
            JwtTokenProvider jwtTokenProvider,
            @Value("${app.google.client-id:}") String googleClientId,
            @Value("${app.super-admin-emails:}") String superAdminEmailsCsv) {

        this.jwtTokenProvider = jwtTokenProvider;

        // Parse comma-separated admin emails
        this.superAdminEmails = new HashSet<>();
        if (superAdminEmailsCsv != null && !superAdminEmailsCsv.isBlank()) {
            Arrays.stream(superAdminEmailsCsv.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .forEach(superAdminEmails::add);
        }

        // Build Google ID token verifier
        if (googleClientId != null && !googleClientId.isBlank()) {
            this.verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(Collections.singletonList(googleClientId))
                    .build();
        } else {
            this.verifier = null;
            log.warn("GOOGLE_CLIENT_ID is not configured. Google OAuth will be disabled.");
        }
    }

    @PostMapping("/verify")
    public ResponseEntity<ApiResponse<AuthResponse>> verifyGoogleToken(@RequestBody TokenRequest request) {
        if (verifier == null) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(ApiResponse.error("Google OAuth is not configured"));
        }

        if (request.getIdToken() == null || request.getIdToken().isBlank()) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("ID token is required"));
        }

        try {
            GoogleIdToken idToken = verifier.verify(request.getIdToken());
            if (idToken == null) {
                log.warn("Invalid Google ID token received");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(ApiResponse.error("Invalid Google ID token"));
            }

            GoogleIdToken.Payload payload = idToken.getPayload();
            String email = payload.getEmail();
            String name = (String) payload.get("name");
            String picture = (String) payload.get("picture");

            // Check if the email is in the super admin list
            if (!superAdminEmails.contains(email)) {
                log.warn("Unauthorized admin login attempt from: {}", email);
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(ApiResponse.error("Access denied. Not an authorized admin."));
            }

            // Generate JWT token
            String jwt = jwtTokenProvider.generateToken(email, name);

            AuthResponse authResponse = new AuthResponse();
            authResponse.setToken(jwt);
            authResponse.setEmail(email);
            authResponse.setName(name);
            authResponse.setPicture(picture);

            log.info("Admin login successful: {}", email);
            return ResponseEntity.ok(ApiResponse.success("Login successful", authResponse));

        } catch (Exception e) {
            log.error("Google token verification failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Token verification failed: " + e.getMessage()));
        }
    }

    @Getter
    @Setter
    public static class TokenRequest {
        private String idToken;
    }

    @Getter
    @Setter
    public static class AuthResponse {
        private String token;
        private String email;
        private String name;
        private String picture;
    }
}
