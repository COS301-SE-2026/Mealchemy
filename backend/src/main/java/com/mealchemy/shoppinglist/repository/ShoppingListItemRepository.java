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
    // find lists for a specific user
    List<ShoppingListItem> findByUserId(Integer userId);
    
}
