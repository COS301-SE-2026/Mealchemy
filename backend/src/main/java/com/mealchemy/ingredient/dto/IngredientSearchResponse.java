package com.mealchemy.ingredient.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record IngredientSearchResponse( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
   @JsonProperty("ing_id") Integer ingId,
   String name,
   String category,
   @JsonProperty("source_id") String sourceId,
   @JsonProperty("source_api") String sourceApi
) {}