package com.hopenvision.auth;

import com.hopenvision.exam.dto.ApiResponse;
import com.hopenvision.user.entity.UserProfile;
import com.hopenvision.user.repository.UserProfileRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.Map;

@Tag(name = "사용자 인증", description = "사용자 회원가입/로그인 API")
@RestController
@RequestMapping("/api/auth/user")
@RequiredArgsConstructor
@Slf4j
public class UserAuthController {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserProfileRepository userProfileRepository;

    public record RegisterRequest(
            @NotBlank(message = "사용자 ID는 필수입니다")
            @Size(min = 3, max = 50, message = "사용자 ID는 3~50자입니다")
            String userId,
            @NotBlank(message = "이름은 필수입니다")
            @Size(max = 100)
            String userNm,
            @Size(max = 200)
            String email
    ) {}

    public record LoginRequest(
            @NotBlank(message = "사용자 ID는 필수입니다")
            String userId
    ) {}

    @Operation(summary = "사용자 회원가입", description = "새 사용자를 등록하고 JWT 토큰을 발급합니다.")
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<Map<String, Object>>> register(@Valid @RequestBody RegisterRequest request) {
        if (userProfileRepository.existsById(request.userId())) {
            throw new IllegalArgumentException("이미 존재하는 사용자 ID입니다: " + request.userId());
        }

        UserProfile profile = UserProfile.builder()
                .userId(request.userId())
                .userNm(request.userNm())
                .email(request.email())
                .build();
        userProfileRepository.save(profile);

        String token = jwtTokenProvider.generateUserToken(request.userId(), request.userNm());

        return ResponseEntity.ok(ApiResponse.success("회원가입이 완료되었습니다.", Map.of(
                "userId", request.userId(),
                "userNm", request.userNm(),
                "token", token
        )));
    }

    @Operation(summary = "사용자 로그인", description = "사용자 ID로 로그인하고 JWT 토큰을 발급합니다.")
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<Map<String, Object>>> login(@Valid @RequestBody LoginRequest request) {
        UserProfile profile = userProfileRepository.findById(request.userId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다: " + request.userId()));

        String token = jwtTokenProvider.generateUserToken(profile.getUserId(), profile.getUserNm());

        return ResponseEntity.ok(ApiResponse.success("로그인 성공", Map.of(
                "userId", profile.getUserId(),
                "userNm", profile.getUserNm(),
                "token", token
        )));
    }
}
