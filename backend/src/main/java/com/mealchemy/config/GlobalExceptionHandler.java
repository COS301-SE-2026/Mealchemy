package com.mealchemy.config;

import com.mealchemy.shared.dto.ErrorResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

import java.time.Instant;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

//handles exceptions accross all controllers
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    
    //handles exceptions thrown manually in service layer
    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<ErrorResponse> handleResponseStatus(ResponseStatusException e) { //returns status code and message as JSON object
        HttpStatus status = HttpStatus.valueOf(e.getStatusCode().value());
        return ResponseEntity.status(status).body(new ErrorResponse(
                                                        status.value(),
                                                        status.name(),
                                                        e.getReason(),
                                                        Instant.now()
        ));
    }

    //handles @Valid failures on request DTOs
    //missing input parameters - bad request
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        String message = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(e -> e.getField() + ": " + e.getDefaultMessage())
                .findFirst()
                .orElse("Validation failed");
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new ErrorResponse(
                                                                        HttpStatus.BAD_REQUEST.value(),
                                                                        "VALIDATION_ERROR",
                                                                        message,
                                                                        Instant.now()
        ));
    }

    //malinformed request body and invalid path variale types
    @ExceptionHandler({HttpMessageNotReadableException.class, MethodArgumentTypeMismatchException.class})
    public ResponseEntity<ErrorResponse> handleBadRequest(Exception ex) {
        log.error("Bad request", ex);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new ErrorResponse(
                                                                        HttpStatus.BAD_REQUEST.value(),
                                                                        "BAD_REQUEST",
                                                                        "Invalid request",
                                                                        Instant.now()
        ));
    }

    //catches anything unexpected - returns generic message
    //prevents stack traces and sensitive information leaking to Flutter
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneric(Exception ex) {
        log.error("Unexpected error", ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(new ErrorResponse(
                                                                        HttpStatus.INTERNAL_SERVER_ERROR.value(),
                                                                        "INTERNAL_ERROR",
                                                                        "An unexpected error occurred",
                                                                        Instant.now()
        ));
    }
}