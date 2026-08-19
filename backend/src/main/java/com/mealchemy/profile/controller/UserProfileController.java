package com.mealchemy.profile.controller;

// import dtos
import com.mealchemy.profile.dto.*;
// import services
import com.mealchemy.profile.service.*;
// for jwt token
import org.springframework.security.core.annotation.AuthenticationPrincipal;


import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;



@RestController
@RequestMapping("/user/profile") 
public class UserProfileController {

    private final UserProfileService userProfileService;

    public UserProfileController(UserProfileService userProfileService) {
        this.userProfileService = userProfileService;
    }

    @GetMapping("")
    public ResponseEntity<UserProfileResponse> getUserProfileDetails(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(userProfileService.getUserProfile(Integer.parseInt(userId)));
    }

    @PutMapping("")
    public ResponseEntity<UserProfileResponse> updateUserProfileDetails(@AuthenticationPrincipal String userId, @RequestBody UserProfileUpdateRequest request) {
        return ResponseEntity.ok(userProfileService.updateUserProfile(Integer.parseInt(userId), request));
    }
    
}