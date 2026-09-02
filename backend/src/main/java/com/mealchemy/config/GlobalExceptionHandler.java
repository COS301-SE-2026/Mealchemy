package com.mealchemy.config;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.ErrorResponse;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import com.mealchemy.engine.client.EmptyPoolException;
import com.mealchemy.engine.client.StaleStateException;
import com.mealchemy.engine.client.InvalidSwipeException;

import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

//handles exceptions accross all controllers
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);
    
    //handles exceptions thrown manually in service layer
    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String, String>> handleResponseStatus(ResponseStatusException e) { //returns status code and message as JSON object
        return ResponseEntity
                .status(e.getStatusCode())
                .body(Map.of("message", e.getReason()));
    }

    //handles @Valid failures on request DTOs
    //missing input parameters - bad request
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidation(MethodArgumentNotValidException ex) {
        String message = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(e -> e.getField() + ": " + e.getDefaultMessage())
                .findFirst()
                .orElse("Validation failed");
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(Map.of("message", message));
    }

    //malinformed request body and invalid path variale types
    @ExceptionHandler({HttpMessageNotReadableException.class, MethodArgumentTypeMismatchException.class})
    public ResponseEntity<Map<String, String>> handleBadRequest(Exception ex) {
        // log.error("Bad request", ex);
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(Map.of("message", "Invalid request"));
    }

    //handles engine-originated exceptions surfaced from EngineClient
    @ExceptionHandler(EmptyPoolException.class)
    public ResponseEntity<Map<String, String>> handleEmptyPool(EmptyPoolException ex) {
        return ResponseEntity
                .status(HttpStatus.UNPROCESSABLE_ENTITY)
                .body(Map.of("message", ex.getMessage()));
    }

    @ExceptionHandler(StaleStateException.class)
    public ResponseEntity<Map<String, String>> handleStaleState(StaleStateException ex) {
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(Map.of("message", ex.getMessage()));
    }

    @ExceptionHandler(InvalidSwipeException.class)
    public ResponseEntity<Map<String, String>> handleInvalidSwipe(InvalidSwipeException ex) {
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(Map.of("message", ex.getMessage()));
    }
    
    //catches anything unexpected - returns generic message
    //prevents stack traces and sensitive information leaking to Flutter
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleGeneric(Exception ex) {
        ex.printStackTrace();
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("message", "An unexpected error occurred"));
    }

}