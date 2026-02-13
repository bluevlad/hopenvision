package com.hopenvision.user.controller;

import com.hopenvision.exam.dto.ApiResponse;
import com.hopenvision.user.dto.UserProfileDto;
import com.hopenvision.user.service.UserProfileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/user/profile")
@RequiredArgsConstructor
@Tag(name = "사용자 - 프로필", description = "사용자 프로필 관리 API")
public class UserProfileController {

    private final UserProfileService userProfileService;

    private static final java.util.regex.Pattern USER_ID_PATTERN =
            java.util.regex.Pattern.compile("^[a-zA-Z0-9_-]{1,50}$");

    private String validateUserId(String userId) {
        if (userId == null || userId.isBlank() || !USER_ID_PATTERN.matcher(userId).matches()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "유효하지 않은 사용자 ID 형식입니다");
        }
        return userId;
    }

    @GetMapping
    @Operation(summary = "내 프로필 조회")
    public ApiResponse<UserProfileDto.Response> getProfile(
            @Parameter(description = "사용자 ID", example = "user001")
            @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId) {
        return ApiResponse.success(userProfileService.getProfile(validateUserId(userId)));
    }

    @GetMapping("/exists")
    @Operation(summary = "프로필 존재 여부 확인")
    public ApiResponse<Boolean> hasProfile(
            @Parameter(description = "사용자 ID", example = "user001")
            @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId) {
        return ApiResponse.success(userProfileService.hasProfile(validateUserId(userId)));
    }

    @PostMapping
    @Operation(summary = "프로필 생성/수정")
    public ApiResponse<UserProfileDto.Response> upsertProfile(
            @Parameter(description = "사용자 ID", example = "user001")
            @RequestHeader(value = "X-User-Id", defaultValue = "guest") String userId,
            @Valid @RequestBody UserProfileDto.UpsertRequest request) {
        String validatedUserId = validateUserId(userId);
        if (!validatedUserId.equals(request.getUserId())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "헤더의 사용자 ID와 요청 본문의 사용자 ID가 일치하지 않습니다");
        }
        return ApiResponse.success(userProfileService.upsertProfile(request));
    }
}
