package com.mealchemy.shoppinglist.dto;

import com.mealchemy.shared.enums.ShoppingListStatus;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;

public record ShoppingListItemResponse( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has
    @JsonProperty("item_id") Integer itemId,
    @JsonProperty("shopping_list_id") Integer shoppingListId,
    @JsonProperty("ing_id") Integer ingId,
    String name,
    String category,
    BigDecimal quantity,
    String unit,
    Boolean purchased    
) {}