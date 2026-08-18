package com.mealchemy.ingredient.dto;

public record IngredientSearchResponse( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
   Integer ingId,
   String name,
   String category,
   String sourceId,
   String sourceApi
) {}