// stucture of a pantry request

package com.mealchemy.pantry.dto;

/* Import libraries */
import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;

/* Import classes */
import com.mealchemy.shared.enums.StorageLocation;
    
public record PantryIngredientRequest (
    //fields needed when adding or updating a pantry item (client -> backend) - userId comes from JWT
    @JsonProperty("ing_id") Integer ingId,
    BigDecimal quantity,
    String unit,
    @JsonProperty("storage_location") StorageLocation storageLocation
) {}