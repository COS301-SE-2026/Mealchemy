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
@RequestMapping("/api/shopping-lists") 
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

    // manually create a new shopping list
    @PostMapping("")
    public ResponseEntity<ShoppingListResponse> createShoppingList(@AuthenticationPrincipal String userId, @RequestBody CreateShoppingListRequest request) {
        return ResponseEntity.ok(shoppingListService.createNewShoppingList(Integer.parseInt(userId), request));
    }

    // edits selected shopping list
    @PutMapping("/{id}")
    public ResponseEntity<ShoppingListResponse> updateSelectedShoppingList(@AuthenticationPrincipal String userId, @PathVariable Integer id, @RequestBody UpdateShoppingListRequest request) {
        return ResponseEntity.ok(shoppingListService.updateShoppingList(Integer.parseInt(userId), id, request));
    }

    // deletes selected shopping list
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletedSelectedShoppingList(@AuthenticationPrincipal String userId, @PathVariable Integer id) {
        shoppingListService.deleteShoppingList(Integer.parseInt(userId), id);
        return ResponseEntity.noContent().build();
    }


    // ========== Shopping List Item Level ==========

    // get all items for specified list
    @GetMapping("/{id}")
    public ResponseEntity<ShoppingListWithItemsResponse> getItemsForList(@AuthenticationPrincipal String userId, @PathVariable Integer id) {
        return ResponseEntity.ok(shoppingListService.getSpecificListItems(Integer.parseInt(userId), id));
    }

    // manually add a new item to a shopping list
    @PostMapping("/{id}/items")
    public ResponseEntity<ShoppingListItemResponse> addItemToShoppingList(@AuthenticationPrincipal String userId, @PathVariable Integer id, @RequestBody CreateShoppingListItemRequest request) {
        return ResponseEntity.ok(shoppingListService.addNewShoppingListItem(Integer.parseInt(userId), id, request));
    }

    // edits selected shopping list item
    @PutMapping("/{id}/items/{itemId}")
    public ResponseEntity<ShoppingListItemResponse> updateSelectedShoppingListItem(@AuthenticationPrincipal String userId, @PathVariable Integer id, @PathVariable Integer itemId, @RequestBody UpdateShoppingListItemRequest request) {
        return ResponseEntity.ok(shoppingListService.updateShoppingListItem(Integer.parseInt(userId), id, itemId, request));
    }

     // udates purchased boolean flag
    @PatchMapping("/{id}/items/{itemId}/purchased")
    public ResponseEntity<ShoppingListItemResponse> updateItemPurchased(@AuthenticationPrincipal String userId, @PathVariable Integer id, @PathVariable Integer itemId, @RequestBody PurchasedUpdateRequest request) {
        return ResponseEntity.ok(shoppingListService.updatePurchasedFlag(Integer.parseInt(userId), id, itemId, request));
    }

    // deletes selected shopping list item (singular)
    @DeleteMapping("/{id}/items/{itemId}")
    public ResponseEntity<Void> deleteShoppingListItem(@AuthenticationPrincipal String userId, @PathVariable Integer id, @PathVariable Integer itemId) {
        shoppingListService.deleteShoppingListItem(Integer.parseInt(userId), id, itemId);
        return ResponseEntity.noContent().build();
    }

    // deletes an array of selected items in a list - using POST
    @PostMapping("/{id}/items/batch-delete")
    public ResponseEntity<Void> deleteArrayItems(@AuthenticationPrincipal String userId, @PathVariable Integer id, @RequestBody DeleteBatchItemsRequest request) {
        shoppingListService.deleteSelectedItems(Integer.parseInt(userId), id, request);
        return ResponseEntity.noContent().build();
    }
}