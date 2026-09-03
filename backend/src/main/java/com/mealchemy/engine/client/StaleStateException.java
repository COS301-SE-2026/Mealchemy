package com.mealchemy.engine.client;

public class StaleStateException extends RuntimeException {
    public StaleStateException(String message) {
        super(message);
    }
}