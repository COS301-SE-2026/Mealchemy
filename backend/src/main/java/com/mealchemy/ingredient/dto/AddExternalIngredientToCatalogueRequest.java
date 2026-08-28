package com.mealchemy.ingredient.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record AddExternalIngredientToCatalogueRequest( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
   @JsonProperty("source_id") String sourceId,
   @JsonProperty("category_id") Integer categoryId // null on first, and supplied by frontend on retry
) {}