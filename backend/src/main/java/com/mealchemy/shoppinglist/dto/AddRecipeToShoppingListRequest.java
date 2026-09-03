package com.mealchemy.shoppinglist.dto;

import com.mealchemy.shared.enums.ShoppingListStatus;

import com.fasterxml.jackson.annotation.JsonProperty;

// for adding ingredients to an existing shopping list from a recipe
public record AddRecipeToShoppingListRequest( //records are immutable and auto generate constructors
    
    @JsonProperty("include_available_pantry_items") Boolean includeAvailablePantryItems 
) {}