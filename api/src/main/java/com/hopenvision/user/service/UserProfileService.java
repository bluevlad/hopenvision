package com.hopenvision.user.service;

import com.hopenvision.user.dto.UserProfileDto;
import com.hopenvision.user.entity.UserProfile;
import com.hopenvision.user.repository.UserProfileRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserProfileService {

    private final UserProfileRepository userProfileRepository;

    @Transactional(readOnly = true)
    public UserProfileDto.Response getProfile(String userId) {
        return userProfileRepository.findById(userId)
                .map(this::toResponse)
                .orElse(null);
    }

    @Transactional(readOnly = true)
    public boolean hasProfile(String userId) {
        return userProfileRepository.existsById(userId);
    }

    @Transactional
    public UserProfileDto.Response upsertProfile(UserProfileDto.UpsertRequest request) {
        UserProfile profile = userProfileRepository.findById(request.getUserId())
                .map(existing -> {
                    existing.setUserNm(request.getUserNm());
                    existing.setEmail(request.getEmail());
                    existing.setNewsletterYn(request.getNewsletterYn() != null ? request.getNewsletterYn() : "N");
                    return existing;
                })
                .orElseGet(() -> UserProfile.builder()
                        .userId(request.getUserId())
                        .userNm(request.getUserNm())
                        .email(request.getEmail())
                        .newsletterYn(request.getNewsletterYn() != null ? request.getNewsletterYn() : "N")
                        .build());

        UserProfile saved = userProfileRepository.save(profile);
        return toResponse(saved);
    }

    private UserProfileDto.Response toResponse(UserProfile entity) {
        return UserProfileDto.Response.builder()
                .userId(entity.getUserId())
                .userNm(entity.getUserNm())
                .email(entity.getEmail())
                .newsletterYn(entity.getNewsletterYn())
                .regDt(entity.getRegDt())
                .updDt(entity.getUpdDt())
                .build();
    }
}
