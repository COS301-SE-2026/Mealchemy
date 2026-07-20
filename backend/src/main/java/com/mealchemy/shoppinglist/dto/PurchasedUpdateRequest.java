package com.mealchemy.shoppinglist.dto;

import com.mealchemy.shared.enums.ShoppingListStatus;

import com.fasterxml.jackson.annotation.JsonProperty;

public record PurchasedUpdateRequest( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has

   //get specified shopping list and item from URL therefore not in request body
    Boolean purchased
) {}