// stucture of a prefernece request

package com.mealchemy.externallinks.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;


// create and update
public record ExternalLinkRequest( // specific link will come from api url parameter
    @NotBlank @Size(max = 150) String name,
    @NotBlank @Pattern(regexp = "^https?://.+", message = "URL must start with http:// or https://") String url
) {}