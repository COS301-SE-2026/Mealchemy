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

// swagger 
import com.mealchemy.shared.dto.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.tags.Tag;


@RestController
@RequestMapping("/api/shopping-lists") 
@Tag(name = "Shopping Lists", description = "Shopping lists and their items")
public class ShoppingListController {

    private final ShoppingListService shoppingListService;

    public ShoppingListController(ShoppingListService shoppingListService) {
        this.shoppingListService = shoppingListService;
    }

    // ========== Shopping List Level ==========

    // get shopping lists that belong to logged in user
    @Operation(summary = "Get all the user's shopping lists", description = "Returns all shopping lists belonging to the authenticated user, with item counts.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Shopping lists retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = ShoppingListResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("")
    public ResponseEntity<List<ShoppingListResponse>> getShoppingLists(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(shoppingListService.getUsersShoppingLists(Integer.parseInt(userId)));
    }


    // manually create a new shopping list
    @Operation(summary = "Create a shopping list", description = "Creates a new empty shopping list for the authenticated user.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Shopping list created successfully", content = @Content(schema = @Schema(implementation = ShoppingListResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("")
    public ResponseEntity<ShoppingListResponse> createShoppingList(@AuthenticationPrincipal String userId, @RequestBody CreateShoppingListRequest request) {
        return ResponseEntity.ok(shoppingListService.createNewShoppingList(Integer.parseInt(userId), request));
    }


    // edits selected shopping list
    @Operation(summary = "Update a shopping list", description = "Updates the name and/or status of a shopping list owned by the authenticated user.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Shopping list updated successfully", content = @Content(schema = @Schema(implementation = ShoppingListResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this shopping list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Shopping list not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{id}")
    public ResponseEntity<ShoppingListResponse> updateSelectedShoppingList(@AuthenticationPrincipal String userId, @PathVariable Integer id, @RequestBody UpdateShoppingListRequest request) {
        return ResponseEntity.ok(shoppingListService.updateShoppingList(Integer.parseInt(userId), id, request));
    }


    // deletes selected shopping list
    @Operation(summary = "Delete a shopping list", description = "Deletes a shopping list and all of its items, owned by the authenticated user.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Shopping list deleted successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this shopping list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Shopping list not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletedSelectedShoppingList(@AuthenticationPrincipal String userId, @PathVariable Integer id) {
        shoppingListService.deleteShoppingList(Integer.parseInt(userId), id);
        return ResponseEntity.noContent().build();
    }


    // auto generates shopping list from a given recipe
    @Operation(summary = "Generate a shopping list from a recipe", description = "Creates a new shopping list from a recipe's ingredients. When includeAvailablePantryItems is false, every ingredient is added, when true, ingredients already sufficiently stocked in the user's pantry are skipped.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Shopping list generated successfully", content = @Content(schema = @Schema(implementation = ShoppingListResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found, or not accessible to the authenticated user", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/from-recipe/{recipeId}")
    public ResponseEntity<ShoppingListResponse> autoGenerateShoppingListFromRecipe(@AuthenticationPrincipal String userId, @PathVariable Integer recipeId, @RequestBody PantryRecipeComparisonRequest request) {
        return ResponseEntity.ok(shoppingListService.generateShoppingListFromRecipe(Integer.parseInt(userId), recipeId, request));
    }


    @Operation(summary = "Add a recipe's ingredients to an existing shopping list", description = "Merges a recipe's ingredients into an existing shopping list owned by the authenticated user, combining quantities with any matching existing items of the same unit already in the shopping list. When includeAvailablePantryItems is false, every ingredient is added, when true, ingredients already sufficiently stocked in the user's pantry are skipped or reduced.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Ingredients added to the shopping list successfully", content = @Content(schema = @Schema(implementation = ShoppingListWithItemsResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this shopping list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Shopping list not found, or recipe not found or not accessible to the authenticated user", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/add-from-recipe/{shoppingListId}/{recipeId}")
    public ResponseEntity<ShoppingListWithItemsResponse> autoGenerateFromRecipeToExistingList(@AuthenticationPrincipal String userId, @PathVariable Integer recipeId, @PathVariable Integer shoppingListId, @RequestBody AddRecipeToShoppingListRequest request) {
        return ResponseEntity.ok(shoppingListService.addRecipeIngredientsToShoppingList(Integer.parseInt(userId), shoppingListId, recipeId, request));
    }


    // ========== Shopping List Item Level ==========

    // get all items for specified list
    @Operation(summary = "Get a shopping list with its items", description = "Returns a shopping list and all of its items, converted to the authenticated user's preferred unit of measurement.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Shopping list retrieved successfully", content = @Content(schema = @Schema(implementation = ShoppingListWithItemsResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this shopping list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Shopping list not found, or user profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/{id}")
    public ResponseEntity<ShoppingListWithItemsResponse> getItemsForList(@AuthenticationPrincipal String userId, @PathVariable Integer id) {
        return ResponseEntity.ok(shoppingListService.getSpecificListItems(Integer.parseInt(userId), id));
    }


    // manually add a new item to a shopping list
    @Operation(summary = "Add an item to a shopping list", description = "Adds a new item to a shopping list owned by the authenticated user. Exaclty one of name or ingId must be provided.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Item added successfully", content = @Content(schema = @Schema(implementation = ShoppingListItemResponse.class))),
        @ApiResponse(responseCode = "400", description = "Neither name nor ingId was provided, or both were provided", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this shopping list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Shopping list not found, or user profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/{id}/items")
    public ResponseEntity<ShoppingListItemResponse> addItemToShoppingList(@AuthenticationPrincipal String userId, @PathVariable Integer id, @RequestBody CreateShoppingListItemRequest request) {
        return ResponseEntity.ok(shoppingListService.addNewShoppingListItem(Integer.parseInt(userId), id, request));
    }


    // edits selected shopping list item
    @Operation(summary = "Update a shopping list item", description = "Updates an item on a shopping list owned by the authenticated user. Exaclty one of name or ingId must be provided.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Item updated successfully", content = @Content(schema = @Schema(implementation = ShoppingListItemResponse.class))),
        @ApiResponse(responseCode = "400", description = "Neither name nor ingId was provided, or both were provided", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this shopping list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Shopping list not found, or user profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{id}/items/{itemId}")
    public ResponseEntity<ShoppingListItemResponse> updateSelectedShoppingListItem(@AuthenticationPrincipal String userId, @PathVariable Integer id, @PathVariable Integer itemId, @RequestBody UpdateShoppingListItemRequest request) {
        return ResponseEntity.ok(shoppingListService.updateShoppingListItem(Integer.parseInt(userId), id, itemId, request));
    }


    // udates purchased boolean flag
    @Operation(summary = "Update a items's purchased status", description = "Updates only the purchased flag for a single item on a shopping list owned by the authenticated user. Does not move the item to the pantry - use complete-shop for that.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Purchased status updated successfully", content = @Content(schema = @Schema(implementation = ShoppingListItemResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this shopping list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Shopping list not found, item not found, item does not belong to the specified list, or user profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PatchMapping("/{id}/items/{itemId}/purchased")
    public ResponseEntity<ShoppingListItemResponse> updateItemPurchased(@AuthenticationPrincipal String userId, @PathVariable Integer id, @PathVariable Integer itemId, @RequestBody PurchasedUpdateRequest request) {
        return ResponseEntity.ok(shoppingListService.updatePurchasedFlag(Integer.parseInt(userId), id, itemId, request));
    }


    // deletes selected shopping list item (singular)
    @Operation(summary = "Delete a shopping list item", description = "Deletes a single item from a shopping list owned by the authenticated user.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Item deleted successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this shopping list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Shopping list not found, item not found, item does not belong to the specified list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/{id}/items/{itemId}")
    public ResponseEntity<Void> deleteShoppingListItem(@AuthenticationPrincipal String userId, @PathVariable Integer id, @PathVariable Integer itemId) {
        shoppingListService.deleteShoppingListItem(Integer.parseInt(userId), id, itemId);
        return ResponseEntity.noContent().build();
    }


    // deletes an array of selected items in a list - using POST
    @Operation(summary = "Batch delete shopping list items", description = "Deletes multiple items from a shopping list owned by the authenticated user in one request. If any item ID is not found or does not belong to the specified, no items are deleted.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Items deleted successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this shopping list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Shopping list not found, an item was not found, or an item does not belong to the specified list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/{id}/items/batch-delete")
    public ResponseEntity<Void> deleteArrayItems(@AuthenticationPrincipal String userId, @PathVariable Integer id, @RequestBody DeleteBatchItemsRequest request) {
        shoppingListService.deleteSelectedItems(Integer.parseInt(userId), id, request);
        return ResponseEntity.noContent().build();
    }


    // select all items as purchased
    @Operation(summary = "Select all items as purchased", description = "Marks every item on a shopping list owned by the autheticated user as purchased.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "All items marked as purchased", content = @Content(schema = @Schema(implementation = ShoppingListWithItemsResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this shopping list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Shopping list not found, or user profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{id}/items/select-all")
    public ResponseEntity<ShoppingListWithItemsResponse> selectAllItems(@AuthenticationPrincipal String userId, @PathVariable Integer id) {
        return ResponseEntity.ok(shoppingListService.selectAllItemsAsPurchased(Integer.parseInt(userId), id));
    }


    // deselect all items as purchased
    @Operation(summary = "Deselect all items as purchased", description = "Marks every item on a shopping list owned by the autheticated user as not purchased.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "All items marked as not purchased", content = @Content(schema = @Schema(implementation = ShoppingListWithItemsResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this shopping list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Shopping list not found, or user profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{id}/items/deselect-all")
    public ResponseEntity<ShoppingListWithItemsResponse> deselectAllItems(@AuthenticationPrincipal String userId, @PathVariable Integer id) {
        return ResponseEntity.ok(shoppingListService.deselectAllItemsAsPurchased(Integer.parseInt(userId), id));
    }


    // complete shop - move purchased items to pantry and remove from list
    @Operation(summary = "Update the pantry", description = "Moves every purchased, catalogue-linked item into the authenticated user's pantry and removes those items from the list. Manually entered items are removed from the list but not added to the pantry. Unpurchased items are left untouched. shoppingListDeleted indicates the list is now empty and is a signal for the frontend to offer deleting it - backend does not delete the list iteself.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pantry updated successfully", content = @Content(schema = @Schema(implementation = CompleteShopResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Caller does not own this shopping list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Shopping list not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{id}/complete-shop")
    public ResponseEntity<CompleteShopResponse> completeShop(@AuthenticationPrincipal String userId, @PathVariable Integer id) {
        return ResponseEntity.ok(shoppingListService.autoAddToPantryRemoveFromList(Integer.parseInt(userId), id));
    }
}