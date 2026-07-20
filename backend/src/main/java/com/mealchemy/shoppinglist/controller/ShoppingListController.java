package com.mealchemy.shoppinglist.controller;

// import dtos
import com.mealchemy.shoppinglist.dto.*;
// import services
import com.mealchemy.shoppinglist.service.*;
// for jwt token
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/shopping-list") 
public class ShoppingListController {

    private final ShoppingListService shoppingListService;

    public ShoppingListController(ShoppingListService shoppingListService) {
        this.shoppingListService = shoppingListService;
    }

    // ========== Shopping List Level ==========

    // get shopping lists that belong to logged in user
    @GetMapping("")
    public ResponseEntity<List<ShoppingListResponse>> getShoppingLists(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(shoppingListService.getUsersShoppingLists(Integer.parseInt(userId)));
    }





    // ========== Shopping List Item Level ==========

    // get 
    @GetMapping("/{id}")
    public ResponseEntity<List<ShoppingListItemResponse>> getItemsForList(@AuthenticationPrincipal String userId, @PathVariable Integer id) {
        return ResponseEntity.ok(shoppingListService.getSpecificListItems(Integer.parseInt(userId), id));
    }

}