package com.mealchemy.moderation.dto;

// imported libraries
import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

public record UserSummaryResponse( 
    @JsonProperty("user_id") Integer userId,
    @JsonProperty("display_name") String displayName, 
    String email, 
    List<String> roles
) {}

