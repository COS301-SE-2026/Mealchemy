package com.mealchemy.shoppinglist.service;
//models
import com.mealchemy.shoppinglist.model.ShoppingList;
import com.mealchemy.shoppinglist.model.ShoppingListItem;

//repositories
import com.mealchemy.shoppinglist.repository.ShoppingListRepository;
import com.mealchemy.shoppinglist.repository.ShoppingListItemRepository;

import org.springframework.transaction.annotation.Transactional; //need to annotate any function that makes an update to the database

//dtos
import com.mealchemy.shoppinglist.dto.CreateShoppingListItemRequest;
import com.mealchemy.shoppinglist.dto.CreateShoppingListRequest;
import com.mealchemy.shoppinglist.dto.PantryRecipeComparisonRequest;
import com.mealchemy.shoppinglist.dto.PurchasedUpdateRequest;
import com.mealchemy.shoppinglist.dto.ShoppingListResponse;
import com.mealchemy.shoppinglist.dto.ShoppingListItemResponse;
import com.mealchemy.shoppinglist.dto.ShoppingListWithItemsResponse;
import com.mealchemy.shoppinglist.dto.UpdateShoppingListItemRequest;
import com.mealchemy.shoppinglist.dto.UpdateShoppingListRequest;

import java.util.List;
import java.util.stream.Collectors;
import java.util.Optional;
import java.math.BigDecimal;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service 
public class ShoppingListService {

    private final ShoppingListRepository shoppingListRepository;
    private final ShoppingListItemRepository shoppingListItemRepository;

    // constructor
    public ShoppingListService(ShoppingListRepository shoppingListRepository, ShoppingListItemRepository shoppingListItemRepository) {
        this.shoppingListRepository = shoppingListRepository;
        this.shoppingListItemRepository = shoppingListItemRepository;
    }

    // ========== Shopping List Level ==========

    // GET request - returns all shopping lists for the logged in user
    public List<ShoppingListResponse> getUsersShoppingLists(Integer userId) {
        List<ShoppingList> shoppingLists = shoppingListRepository.findByUserId(userId);

        // mapping entity to response
        return shoppingLists.stream()
                            .map(shoppingList -> new ShoppingListResponse(
                                shoppingList.getShoppingListId(),
                                shoppingList.getUserId(),
                                shoppingList.getName(),
                                shoppingList.getStatus(),
                                shoppingList.getCreatedAt()
                            ))
                            .collect(Collectors.toList());
    }






    // ========== Shopping List Item Level ==========

    public List<ShoppingListItemResponse> getSpecificListItems(Integer userId, Integer shoppingListId) {
        // get shopping list first
        ShoppingList list = shoppingListRepository.findById(shoppingListId)
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found")); //find by primary key

        // user authentication - check items in list belong to logged in user
        if(!list.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list");
        }

        List<ShoppingListItem> shoppingListItems = shoppingListItemRepository.findByShoppingListId(shoppingListId);

        // mapping entity to response
        return shoppingListItems.stream()
                                .map(item -> new ShoppingListItemResponse(
                                    item.getItemId(),
                                    item.getShoppingListId(),
                                    item.getIngId(),
                                    item.getName(),
                                    item.getQuantity(),
                                    item.getUnit(),
                                    item.getPurchased()
                                ))
                                .collect(Collectors.toList());
    }
}