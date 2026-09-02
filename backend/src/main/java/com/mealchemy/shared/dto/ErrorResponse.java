package com.mealchemy.shared.dto;

import java.time.Instant;

public record ErrorResponse(
    int status,
    String error, // machine readable
    String message, // human readable
    Instant timestamp
) {}