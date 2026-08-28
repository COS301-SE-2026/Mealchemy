package com.mealchemy.ingredient.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record IngredientPendingResponse( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
   @JsonProperty("source_id") String sourceId, // so you can find the ingredient again
   String name
) {}