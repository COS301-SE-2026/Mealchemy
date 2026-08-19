package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import jakarta.validation.constraints.*;
import java.util.*;
import java.math.BigDecimal;
import com.fasterxml.jackson.annotation.JsonProperty;

public record IngredientRequest(
    @JsonProperty("ing_id") Integer ingId,
    @JsonProperty("category_id") Integer categoryId,
    String name,
    BigDecimal quantity,
    String unit
)
{
    public static IngredientRequest from(Integer ingIdIn, Integer categoryIdIn, String nameIn, BigDecimal quantityIn, String unitIn)
    {
        return new IngredientRequest(
            ingIdIn,
            categoryIdIn,
            nameIn,
            quantityIn,
            unitId
        );
    }
}
