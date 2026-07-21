package com.mealchemy.shoppinglist.repository;
// models
import com.mealchemy.shoppinglist.model.ShoppingList;
import com.mealchemy.shoppinglist.model.ShoppingListItem;
// dtos
import com.mealchemy.shoppinglist.dto.ShoppingListResponse;
import com.mealchemy.shoppinglist.dto.ShoppingListItemResponse;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ShoppingListItemRepository extends JpaRepository<ShoppingListItem, Integer> {
    // get all items for specific shopping list
    List<ShoppingListItem> findByShoppingListId(Integer shoppingListId);

    @Query("""
            SELECT new com.mealchemy.shoppinglist.dto.ShoppingListItemResponse(
                i.itemId,
                i.shoppingListId,
                i.ingId,
                c.name,
                cat.name,
                i.quantity,
                i.unit,
                i.purchased
            )
            FROM ShoppingListItem i
            LEFT JOIN IngredientCatalogue c ON i.ingId = c.ingId
            LEFT JOIN IngredientCategory cat ON c.categoryId = cat.categoryId
            WHERE i.shoppingListId = :shoppingListId
        """)
        List<ShoppingListItemResponse> getSpecificShoppingListItems(@Param("shoppingListId")Integer shoppingListId);
    
}
