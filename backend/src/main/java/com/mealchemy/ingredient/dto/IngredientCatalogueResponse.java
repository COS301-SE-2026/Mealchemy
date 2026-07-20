package com.mealchemy.ingredient.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record IngredientCatalogueResponse ( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
   @JsonProperty("ing_id") Integer ingId,
   String name,
   String category // get category name from id in repository
) {}

// name and category from ingredient catalogue - built in pantry/service by combining the data from the 2 sources