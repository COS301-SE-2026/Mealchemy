package com.mealchemy.shoppinglist.dto;

import java.util.List;

public record SmartAddMealPlanResponse(
    ShoppingListWithItemsResponse shoppingList,
    List<Integer> skippedRecipeIds
) {}