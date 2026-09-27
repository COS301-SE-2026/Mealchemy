package com.mealchemy.mealprep.exception;

/* Import libraries */
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

/* Import classes */

public class InvalidMealSlotTimeException extends ResponseStatusException {
    public InvalidMealSlotTimeException(String message)
    {
        super(HttpStatus.BAD_REQUEST, message);
    }
}