package com.mealchemy.preference.controller;

// import dtos
import com.mealchemy.preference.dto.*;
// import services
import com.mealchemy.preference.service.*;
// for jwt token
import org.springframework.security.core.annotation.AuthenticationPrincipal;


import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;



@RestController
@RequestMapping("/user/preferences") 
public class PreferenceController {

    private final PreferenceService preferenceService;

    public PreferenceController(PreferenceService preferenceService) {
        this.preferenceService = preferenceService;
    }

    @GetMapping("")
    public ResponseEntity<PreferenceResponse> getUserPreferences(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(preferenceService.preferences(Integer.parseInt(userId)));
    }

    @PutMapping("")
    public ResponseEntity<PreferenceResponse> updateUserPreferences(@AuthenticationPrincipal String userId, @RequestBody PreferenceRequest request) {
        return ResponseEntity.ok(preferenceService.updatePreferences(Integer.parseInt(userId), request));
    }
    
}