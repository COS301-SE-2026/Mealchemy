package com.mealchemy.auth.controller;

import com.mealchemy.auth.dto.AuthResponse;
import com.mealchemy.auth.dto.LoginRequest;
import com.mealchemy.auth.dto.RegisterRequest;
import com.mealchemy.auth.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

// swagger 
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import com.mealchemy.shared.dto.ErrorResponse;

@RestController
@RequestMapping("/auth")
@Tag(name = "Authentication", description = "User registration, login, and logout")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    // swagger comments
    @Operation(summary = "Register a new user", description = "Creates a user profile, default preference row, and a private vault. Returns a JWT.")
    @SecurityRequirements // public endpoint - no token required
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "User registered successfully", content = @Content(schema = @Schema(implementation = AuthResponse.class))),
        @ApiResponse(responseCode = "400", description = "Validation failed (e.g. invalid email, password too short)", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "409", description = "Email is already registered", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody @Valid RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }


    @Operation(summary = "Authenticate a user", description = "Validates user credentials and returns a JWT.")
    @SecurityRequirements
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Login successful", content = @Content(schema = @Schema(implementation = AuthResponse.class))),
        @ApiResponse(responseCode = "400", description = "Validation failed (e.g. missing email/password)", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "Invalid credentials, unknown email", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody @Valid LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }


    @Operation(summary = "Log out the current user", description = "Terminates the current session. No request body.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Logout successful, no content returned"),
        @ApiResponse(responseCode = "401", description = "No valid session/JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/logout")
    public ResponseEntity<Void> logout() {
        return ResponseEntity.noContent().build();
    }
}