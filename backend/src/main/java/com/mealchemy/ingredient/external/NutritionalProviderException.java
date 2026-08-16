package com.mealchemy.ingredient.external;

public class NutritionalProviderException extends RuntimeException {
    
    public NutritionalProviderException(String message) {
        super(message);
    }

    public NutritionalProviderException(String message, Throwabe cause) {
        super(message, cause);
    }
}
