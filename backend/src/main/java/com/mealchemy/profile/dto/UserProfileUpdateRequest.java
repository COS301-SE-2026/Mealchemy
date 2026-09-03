// stucture of a prefernece request

package com.mealchemy.profile.dto;

import com.mealchemy.shared.enums.PreferredUnit;
import java.time.OffsetDateTime;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public record UserProfileUpdateRequest(
    @JsonProperty("display_name") String displayName,
    @JsonProperty("avatar_url") String avatarUrl,
    @JsonProperty("preferred_unit") PreferredUnit preferredUnit,
    List<String> equipment
) {}