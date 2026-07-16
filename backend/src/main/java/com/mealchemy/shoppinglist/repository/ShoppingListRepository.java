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

public interface ShoppingListRepository extends JpaRepository<ShoppingList, Integer> {
    // get all items for specific shopping list
    List<ShoppingList> findByShoppingListId(Integer shoppingListId);
    
}
