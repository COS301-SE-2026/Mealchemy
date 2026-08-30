package com.mealchemy.category.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record IngredientCategoryResponse( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
    @JsonProperty("category_id") Integer categoryId,
    String name
) {}