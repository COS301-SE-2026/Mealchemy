package com.mealchemy.externallinks.controller;

// import dtos
import com.mealchemy.externallinks.dto.*;
// import services
import com.mealchemy.externallinks.service.*;
// for jwt token
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import java.util.List;
import jakarta.validation.Valid;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/external-links") 
public class ExternalLinkController {

    private final ExternalLinkService externalLinkService;

    public ExternalLinkController(ExternalLinkService externalLinkService) {
        this.externalLinkService = externalLinkService;
    }

    @GetMapping("")
    public ResponseEntity<List<ExternalLinkResponse>> getUserExternalLinks(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(externalLinkService.getExternalLinks(Integer.parseInt(userId)));
    }

    @PostMapping("")
    public ResponseEntity<ExternalLinkResponse> createNewExternalLink(@AuthenticationPrincipal String userId, @Valid @RequestBody ExternalLinkRequest request) {
        return ResponseEntity.ok(externalLinkService.createExternalLink(Integer.parseInt(userId), request));
    }

    @PutMapping("/{linkId}")
    public ResponseEntity<ExternalLinkResponse> updateExternalLink(@AuthenticationPrincipal String userId, @PathVariable Integer linkId, @Valid @RequestBody ExternalLinkRequest request) {
        return ResponseEntity.ok(externalLinkService.updateExternalLink(linkId, Integer.parseInt(userId), request));
    }

    @DeleteMapping("/{linkId}")
    public ResponseEntity<Void> removeExternalLink(@AuthenticationPrincipal String userId, @PathVariable Integer linkId) {
        externalLinkService.deleteExternalLink(linkId, Integer.parseInt(userId));
        return ResponseEntity.noContent().build();
    }
    
}