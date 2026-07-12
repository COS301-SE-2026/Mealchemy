// stucture of a pantry request

package com.mealchemy.preference.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;
    
public record PantryIngredientRequest (
    //fields needed when adding or updating a pantry item (client -> backend) - userId comes from JWT
    @JsonProperty("ing_id") Integer ingId,
    BigDecimal quantity,
    String unit 
) {}