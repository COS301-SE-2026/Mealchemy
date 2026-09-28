package com.mealchemy.shoppinglist.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public record SmartAddMealPlanResponse(
    @JsonProperty("shopping_list") ShoppingListWithItemsResponse shoppingList,
    @JsonProperty("skipped_recipe_ids") List<Integer> skippedRecipeIds
) {}