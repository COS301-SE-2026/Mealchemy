package com.mealchemy.mealprep.exception;

/* Import libraries */
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

/* Import classes */

public class RecommendationGenerationException extends ResponseStatusException {
    public RecommendationGenerationException(String reason)
    {
        super(HttpStatus.INTERNAL_SERVER_ERROR, reason);
    }

    public RecommendationGenerationException(HttpStatus status, String reason)
    {
        super(status, reason);
    }
}