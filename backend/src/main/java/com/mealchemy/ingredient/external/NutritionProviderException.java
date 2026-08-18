package com.mealchemy.ingredient.external;

public class NutritionProviderException extends RuntimeException {
    
    public NutritionProviderException(String message) {
        super(message);
    }

    public NutritionProviderException(String message, Throwable cause) {
        super(message, cause);
    }
}
