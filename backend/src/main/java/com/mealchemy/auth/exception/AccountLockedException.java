package com.mealchemy.auth.exception;

/* Import libraries */
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

/* Import classes */

public class AccountLockedException extends RuntimeException {
    
    private final long retryAfterSeconds;
    
    public AccountLockedException(long retryAfterSeconds) {
        super("Too many failed login attempts");
        this.retryAfterSeconds = retryAfterSeconds;
    }

    public long getRetryAfterSeconds() {
        return retryAfterSeconds;
    }
}