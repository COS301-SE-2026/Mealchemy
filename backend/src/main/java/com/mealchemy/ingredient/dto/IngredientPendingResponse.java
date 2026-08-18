package com.mealchemy.ingredient.dto;

public record IngredientPendingResponse( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
   String sourceId, // so you can find the ingredient again
   String name
) {}