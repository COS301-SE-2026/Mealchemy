// stucture of a external link response

package com.mealchemy.externallinks.dto;

import java.time.OffsetDateTime;

import com.fasterxml.jackson.annotation.JsonProperty;

public record ExternalLinkResponse(
    @JsonProperty("link_id") Integer linkId,
    String name,
    String url,
    @JsonProperty("created_at") OffsetDateTime createdAt,
    @JsonProperty("updated_at") OffsetDateTime updatedAt
) {}