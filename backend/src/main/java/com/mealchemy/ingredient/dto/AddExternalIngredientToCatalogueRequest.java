package com.mealchemy.ingredient.dto;

public record AddExternalIngredientToCatalogueRequest( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
   String sourceId,
   Integer categoryId // null on first, and supplied by frontend on retry
) {}