package com.mealchemy.pantry.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public record PantryIngredientResponse ( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
   @JsonProperty("p_ingredient_id") Integer pIngredientId,
   @JsonProperty("ing_id") Integer ingId,
   String name,
   String category,
   //freshness?
   String quantity,
   String unit,
   @JsonProperty("created_at") OffsetDateTime createdAt,
   @JsonProperty("updated_at") OffsetDateTime updatedAt
) {}

// name and category from ingredient catalogue - built in pantry/service by combining the data from the 2 sources