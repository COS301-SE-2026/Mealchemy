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

// swagger 
import com.mealchemy.shared.dto.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/external-links") 
@Tag(name = "External Links", description = "User-managed external recipe/reference links")
public class ExternalLinkController {

    private final ExternalLinkService externalLinkService;

    public ExternalLinkController(ExternalLinkService externalLinkService) {
        this.externalLinkService = externalLinkService;
    }

    // swagger comments
    @Operation(summary = "Get the logged-in user's external links", description = "Returns all external links that belong to the authenticated user.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "External links retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = ExternalLinkResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("")
    public ResponseEntity<List<ExternalLinkResponse>> getUserExternalLinks(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(externalLinkService.getExternalLinks(Integer.parseInt(userId)));
    }


    @Operation(summary = "Create a new external link", description = "Adds a new external link for the authenticated user.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "External link created successfully", content = @Content(schema = @Schema(implementation = ExternalLinkResponse.class))),
        @ApiResponse(responseCode = "400", description = "Validation failed (e.g. missing name or invalid URL)", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("")
    public ResponseEntity<ExternalLinkResponse> createNewExternalLink(@AuthenticationPrincipal String userId, @Valid @RequestBody ExternalLinkRequest request) {
        return ResponseEntity.ok(externalLinkService.createExternalLink(Integer.parseInt(userId), request));
    }


    @Operation(summary = "Update an external link", description = "Updates the name and/or URL of an existing external link owned by the authenticated user.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "External link updated successfully", content = @Content(schema = @Schema(implementation = ExternalLinkResponse.class))),
        @ApiResponse(responseCode = "400", description = "Validation failed (e.g. missing name or invalid URL)", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Link not found, or not owned by the authenticated user", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{linkId}")
    public ResponseEntity<ExternalLinkResponse> updateExternalLink(@AuthenticationPrincipal String userId, @PathVariable Integer linkId, @Valid @RequestBody ExternalLinkRequest request) {
        return ResponseEntity.ok(externalLinkService.updateExternalLink(linkId, Integer.parseInt(userId), request));
    }


    @Operation(summary = "Delete an external link", description = "Deletes an existing external link owned by the authenticated user.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "External link deleted successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Link not found, or not owned by the authenticated user", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/{linkId}")
    public ResponseEntity<Void> removeExternalLink(@AuthenticationPrincipal String userId, @PathVariable Integer linkId) {
        externalLinkService.deleteExternalLink(linkId, Integer.parseInt(userId));
        return ResponseEntity.noContent().build();
    }
    
}