package com.mealchemy.shoppinglist.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public record CompleteShopResponse( //records are immutable and auto generate constructors
   //exactly what client sees not necessarily same as what model has

   //get specified shopping list from URL therefore not in request body
    @JsonProperty("added_to_pantry_count") Integer addedToPantryCount,
    @JsonProperty("skipped_manual_items") List<String> skippedManualItemNames,
    @JsonProperty("can_delete_shopping_list") Boolean canDeleteShoppingList
) {}