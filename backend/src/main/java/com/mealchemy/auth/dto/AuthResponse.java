// AuthResponse dto shapes the authentication response sent to flutter 

package com.mealchemy.auth.dto;
import com.fasterxml.jackson.annotation.JsonProperty;

public record AuthResponse( //records are immutable and auto generate constructors
    @JsonProperty("user_id") Long userId,
    @JsonProperty("token") String accessToken,
    @JsonProperty("onboarding_required") boolean onboardingRequired
) {}