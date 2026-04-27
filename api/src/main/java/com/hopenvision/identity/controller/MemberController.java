package com.hopenvision.identity.controller;

import com.hopenvision.identity.dto.MemberResponse;
import com.hopenvision.identity.dto.MemberSignupRequest;
import com.hopenvision.identity.service.MemberService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/identity/members")
@RequiredArgsConstructor
@Tag(name = "Identity — Member", description = "회원 가입·조회")
public class MemberController {

    private final MemberService memberService;

    @PostMapping
    @Operation(summary = "회원 가입")
    public ResponseEntity<MemberResponse> signup(@Valid @RequestBody MemberSignupRequest req) {
        return ResponseEntity.ok(memberService.signup(req));
    }

    @GetMapping("/by-email")
    @Operation(summary = "이메일로 회원 조회")
    public ResponseEntity<MemberResponse> getByEmail(@RequestParam String email) {
        return ResponseEntity.ok(memberService.getByEmail(email));
    }
}
