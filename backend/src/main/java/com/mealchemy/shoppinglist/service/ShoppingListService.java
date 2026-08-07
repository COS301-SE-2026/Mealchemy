package com.mealchemy.shoppinglist.service;
//models
import com.mealchemy.shoppinglist.model.ShoppingList;
import com.mealchemy.shoppinglist.model.ShoppingListItem;
import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.category.model.IngredientCategory;
import com.mealchemy.pantry.model.PantryIngredient;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeIngredient; // can get recipeId from recipe ingredients table
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultFolderRecipe;

//repositories
import com.mealchemy.shoppinglist.repository.ShoppingListRepository;
import com.mealchemy.shoppinglist.repository.ShoppingListItemRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.category.repository.IngredientCategoryRepository;
import com.mealchemy.pantry.repository.PantryIngredientRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.recipe.repository.RecipeIngredientRepository;
import com.mealchemy.vault.repository.VaultFolderRecipeRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;

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
import com.mealchemy.shoppinglist.dto.DeleteBatchItemsRequest;
import com.mealchemy.shoppinglist.dto.CompleteShopResponse;

//enum for shopping list status
import com.mealchemy.shared.enums.ShoppingListStatus;

import java.util.List;
import java.util.ArrayList;
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

    private final IngredientCatalogueRepository ingredientCatalogueRepository;
    private final IngredientCategoryRepository ingredientCategoryRepository;

    private final PantryIngredientRepository pantryIngredientRepository;

    private final RecipeRepository recipeRepository;
    private final RecipeIngredientRepository recipeIngredientRepository;

    private final VaultFolderRecipeRepository vaultFolderRecipeRepository;
    private final VaultMemberRepository vaultMemberRepository; 


    // constructor
    public ShoppingListService(ShoppingListRepository shoppingListRepository, ShoppingListItemRepository shoppingListItemRepository, IngredientCatalogueRepository ingredientCatalogueRepository, IngredientCategoryRepository ingredientCategoryRepository, PantryIngredientRepository pantryIngredientRepository, RecipeRepository recipeRepository, RecipeIngredientRepository recipeIngredientRepository, VaultFolderRecipeRepository vaultFolderRecipeRepository, VaultMemberRepository vaultMemberRepository) {
        this.shoppingListRepository = shoppingListRepository;
        this.shoppingListItemRepository = shoppingListItemRepository;

        this.ingredientCatalogueRepository = ingredientCatalogueRepository;
        this.ingredientCategoryRepository = ingredientCategoryRepository;

        this.pantryIngredientRepository = pantryIngredientRepository;

        this.recipeRepository = recipeRepository;
        this.recipeIngredientRepository = recipeIngredientRepository;

        this.vaultFolderRecipeRepository = vaultFolderRecipeRepository;
        this.vaultMemberRepository = vaultMemberRepository;
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
                                shoppingListItemRepository.countByShoppingListId(shoppingList.getShoppingListId()),
                                shoppingList.getStatus(),
                                shoppingList.getCreatedAt()
                            ))
                            .collect(Collectors.toList());
    }

    // POST request - manually creates a new shopping list 
    @Transactional
    public ShoppingListResponse createNewShoppingList(Integer userId, CreateShoppingListRequest request) {
        ShoppingList newList = new ShoppingList();
        newList.setUserId(userId);
        newList.setName(request.name());
        //new list should automatically be active (default in db)
        if(request.status() != null) {
            newList.setStatus(request.status());
        }
        else {
            newList.setStatus(ShoppingListStatus.ACTIVE);
        }

        ShoppingList saved = shoppingListRepository.save(newList);

        return new ShoppingListResponse(saved.getShoppingListId(),
                                        saved.getUserId(),
                                        saved.getName(),
                                        0,
                                        saved.getStatus(),
                                        saved.getCreatedAt()
        );
    
    }


    //PUT request - updates the details of a current shopping list
    @Transactional 
    public ShoppingListResponse updateShoppingList(Integer userId, Integer shoppingListId, UpdateShoppingListRequest request) { // shopping list id from path
        // get shopping list and check ownership
        ShoppingList selectedList = shoppingListRepository.findById(shoppingListId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        if(!selectedList.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list");
        }

        selectedList.setName(request.name());
        selectedList.setStatus(request.status());

        ShoppingList saved = shoppingListRepository.save(selectedList);

        return new ShoppingListResponse(saved.getShoppingListId(),
                                        saved.getUserId(),
                                        saved.getName(),
                                        shoppingListItemRepository.countByShoppingListId(saved.getShoppingListId()),
                                        saved.getStatus(),
                                        saved.getCreatedAt()
        );

    }

    // DELETE - deletes an entire shopping list
    @Transactional 
    public void deleteShoppingList(Integer userId, Integer shoppingListId) {
        // get shopping list and check ownership
        ShoppingList selectedList = shoppingListRepository.findById(shoppingListId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        if(!selectedList.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list");
        }

        shoppingListRepository.delete(selectedList);
    }


    // ========== Shopping List Item Level ==========

    // GET - all shopping list items in a particular list
    public ShoppingListWithItemsResponse getSpecificListItems(Integer userId, Integer shoppingListId) {
        // get shopping list first
        ShoppingList list = shoppingListRepository.findById(shoppingListId)
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found")); //find by primary key

        // user authentication - check items in list belong to logged in user
        if(!list.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list");
        }

        List<ShoppingListItemResponse> items = shoppingListItemRepository.getSpecificShoppingListItems(shoppingListId);

        return new ShoppingListWithItemsResponse(
            list.getShoppingListId(),
            list.getUserId(),
            list.getName(),
            list.getStatus(),
            list.getCreatedAt(),
            items.size(),
            items
        );
    }


    // POST request - manually add a new ingedient
    @Transactional
    public ShoppingListItemResponse addNewShoppingListItem(Integer userId, Integer id, CreateShoppingListItemRequest request) {
        // get shopping list to check ownership
        ShoppingList list = shoppingListRepository.findById(id)
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        if(!list.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list");
        }

        if(request.name() == null && request.ingId() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You are missing a name or ingredient id");
        }

        if(request.name() != null && request.ingId() != null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You should have a name or ingredient id"); //CHECK
        }

        // creating the new item
        ShoppingListItem newItem = new ShoppingListItem();
        newItem.setShoppingListId(id);

        // if ingredient id is in request
        if(request.ingId() != null) {
            newItem.setIngId(request.ingId());
        }
        // if ingredient id is not present - set name
        if(request.name() != null) {
            newItem.setName(request.name());
        }
        
        newItem.setQuantity(request.quantity());
        newItem.setUnit(request.unit());
        newItem.setPurchased(false);

        ShoppingListItem saved = shoppingListItemRepository.save(newItem);
        
        return new ShoppingListItemResponse(
            saved.getItemId(),
            saved.getShoppingListId(),
            saved.getIngId(),
            getItemName(saved.getIngId(), saved.getName()),
            getCategoryName(saved.getIngId()),
            saved.getQuantity(),
            saved.getUnit(),
            saved.getPurchased()
        );
    }

    // helper
    private String getCategoryName(Integer ingId) {
        if (ingId == null) {
            return null;
        }

        Optional<IngredientCatalogue> catalogueEntry = ingredientCatalogueRepository.findById(ingId);

        if (catalogueEntry.isEmpty()) {
            return null;
        }

        // ingredient found, now find category
        Optional<IngredientCategory> category = ingredientCategoryRepository.findById(catalogueEntry.get().getCategoryId());

        if (category.isEmpty()) {
            return null;
        }

        return category.get().getCategoryName();
    }

    private String getItemName(Integer ingId, String manualName) {
        if (ingId == null) {
            return manualName;
        }
        return ingredientCatalogueRepository.findById(ingId).map(IngredientCatalogue::getName)
                                                            .orElse(manualName);
    }


    // PUT request - manually edit shopping list item
    @Transactional
    public ShoppingListItemResponse updateShoppingListItem(Integer userId, Integer shoppingListId, Integer itemId, UpdateShoppingListItemRequest request) { // get from rquest path
        // get shopping list and check ownership
       ShoppingList selectedList = shoppingListRepository.findById(shoppingListId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        if(!selectedList.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list");
        }

        // get selected item
        ShoppingListItem selectedItem = shoppingListItemRepository.findById(itemId)
                                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Item not found"));

        // check item is in shopping list
        if(!selectedItem.getShoppingListId().equals(shoppingListId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "The selected item is not in the shopping list");
        }

        if(request.name() == null && request.ingId() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You are missing a name or ingredient id");
        }

        if(request.name() != null && request.ingId() != null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "You should have a name or ingredient id"); //CHECK
        }

       
        // if ingredient id is in request
        if(request.ingId() != null) {
            selectedItem.setIngId(request.ingId());
        }
        // if ingredient id is not present - set name
        if(request.name() != null) {
            selectedItem.setName(request.name());
        }
        
        selectedItem.setQuantity(request.quantity());
        selectedItem.setUnit(request.unit());
        selectedItem.setPurchased(request.purchased());

        ShoppingListItem saved = shoppingListItemRepository.save(selectedItem);
        
        return new ShoppingListItemResponse(
            saved.getItemId(),
            saved.getShoppingListId(),
            saved.getIngId(),
            getItemName(saved.getIngId(), saved.getName()),
            getCategoryName(saved.getIngId()),
            saved.getQuantity(),
            saved.getUnit(),
            saved.getPurchased()
        );


    }


    // PATCH request - updated purchased field
    @Transactional
    public ShoppingListItemResponse updatePurchasedFlag(Integer userId, Integer shoppingListId, Integer itemId, PurchasedUpdateRequest request) {
        // get shopping list and check ownership
        ShoppingList selectedList = shoppingListRepository.findById(shoppingListId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        if(!selectedList.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list");
        }

        // get selected item
        ShoppingListItem selectedItem = shoppingListItemRepository.findById(itemId)
                                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Item not found"));

        // check item is in shopping list
        if(!selectedItem.getShoppingListId().equals(shoppingListId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "The selected item is not in the shopping list");
        }

        // update the purchased field
        selectedItem.setPurchased(request.purchased());

        ShoppingListItem saved = shoppingListItemRepository.save(selectedItem);
        
        return new ShoppingListItemResponse(
            saved.getItemId(),
            saved.getShoppingListId(),
            saved.getIngId(),
            getItemName(saved.getIngId(), saved.getName()),
            getCategoryName(saved.getIngId()),
            saved.getQuantity(),
            saved.getUnit(),
            saved.getPurchased()
        );
    }

    // DELETE - deletes a specified item in a shopping list
    @Transactional 
    public void deleteShoppingListItem(Integer userId, Integer shoppingListId, Integer itemId) {
        // get shopping list and check ownership
        ShoppingList selectedList = shoppingListRepository.findById(shoppingListId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        if(!selectedList.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list");
        }

        // get selected item
        ShoppingListItem selectedItem = shoppingListItemRepository.findById(itemId)
                                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Item not found"));

        // check item is in shopping list
        if(!selectedItem.getShoppingListId().equals(shoppingListId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "The selected item is not in the shopping list");
        }

        shoppingListItemRepository.delete(selectedItem);
    }


    // POST - Delete multiple selected shopping list items via a POST request - stay RESTful pure
    @Transactional
    public void deleteSelectedItems(Integer userId, Integer shoppingListId, DeleteBatchItemsRequest request) {
        // check ownership
        ShoppingList selectedList = shoppingListRepository.findById(shoppingListId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        if(!selectedList.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list");
        }
        
        // extract items from request list
        List<Integer> shoppingListItemIds = request.itemIds();

        // for each id find the item and remove it
        for (Integer itemId : shoppingListItemIds) {
            ShoppingListItem selectedItem = shoppingListItemRepository.findById(itemId)
                                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Item not found"));

            // check selected item belongs to shopping list
            if(!selectedItem.getShoppingListId().equals(shoppingListId)) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "The selected item is not in the shopping list");
            }

            shoppingListItemRepository.delete(selectedItem);
        }
    }


    // ========== Generating Shopping List Items (Compares recipe to current pantry ingredients and inserts the rest into shopping list) ==========

    // POST request - automatically creates a shopping list from a give recipe
    @Transactional
    public ShoppingListResponse generateShoppingListFromRecipe(Integer userId, Integer recipeId, PantryRecipeComparisonRequest request) { 
        // check recipe exists
        Recipe selectedRecipe = recipeRepository.findById(recipeId)
                            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found"));

        // could be owned by user in private vault, be a recipe in a shared vault or be in the global 
        if (!canUserAccessRecipe(userId, selectedRecipe)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found");
        }

        // create new list
        ShoppingList newList = new ShoppingList();
        newList.setUserId(userId);
        newList.setName(request.name());
        newList.setStatus(ShoppingListStatus.ACTIVE);

        ShoppingList saved = shoppingListRepository.save(newList);

        // get all recipe ingredients
        List<RecipeIngredient> recipeIngredients = recipeIngredientRepository.findByRecipe_RecipeId(recipeId);

        // check if to add all recipe ingredients
        if (!request.includeAvailablePantryItems()) { //don't compare to pantry, add all recipe ingredients to list
            // loop through ingredients, map each one to shopping list item and add to new list    
            for (RecipeIngredient ingredient : recipeIngredients) {
                //create new item
                ShoppingListItem newItem = new ShoppingListItem();
                newItem.setShoppingListId(saved.getShoppingListId());
                newItem.setIngId(ingredient.getIngId());
                newItem.setName(null); // because ingId from recipe will never be null
                newItem.setQuantity(ingredient.getQuantity());
                newItem.setUnit(ingredient.getUnit());
                newItem.setPurchased(false);
                shoppingListItemRepository.save(newItem);
            }
        }
        else { // include_pantry_availability = true - compare items already in pantry to recipe ingredients and only add missing ones to list
            // get all pantry items that belong to user
            for (RecipeIngredient ingredient : recipeIngredients) {
                // find match to current recipe ingredient
                List<PantryIngredient> currentPantryIngredient = pantryIngredientRepository.findByUserIdAndIngId(userId, ingredient.getIngId());
                
                // if multiple of same ingredient is in pantry, check if all there quantities added are > recipe ingredients quantity else add ingredient to list
                BigDecimal totalIngredientQuantity = BigDecimal.ZERO;
                Boolean isEnough = true;
                if (!currentPantryIngredient.isEmpty()) {
                    for (PantryIngredient ing : currentPantryIngredient) {
                        totalIngredientQuantity = totalIngredientQuantity.add(ing.getQuantity());
                    }
                    if (totalIngredientQuantity.compareTo(ingredient.getQuantity()) < 0) {
                        isEnough = false; // not enough of the ingredient in the pantry- will need to add it
                    }
                }
                // if list is empty - no match already in pantry therfore add item
                if (currentPantryIngredient.isEmpty() || !isEnough) {
                    //create new item
                    ShoppingListItem newItem = new ShoppingListItem();
                    newItem.setShoppingListId(saved.getShoppingListId());
                    newItem.setIngId(ingredient.getIngId());
                    newItem.setName(null); // because ingId from recipe will never be null
                    newItem.setQuantity(ingredient.getQuantity().subtract(totalIngredientQuantity)); //subtract the difference - if pantry has some of quantity, shopping list adds the rest
                    newItem.setUnit(ingredient.getUnit());
                    newItem.setPurchased(false);
                    // save item to repository
                    shoppingListItemRepository.save(newItem);
                }
                // else skip if exists in pantry (don't add to shopping list)
            }
        }

        // return Shopping List Response
        return new ShoppingListResponse(saved.getShoppingListId(),
                                        saved.getUserId(),
                                        saved.getName(),
                                        shoppingListItemRepository.countByShoppingListId(saved.getShoppingListId()),
                                        saved.getStatus(),
                                        saved.getCreatedAt()
        );
    }

    // helper to check if recipe is accessable
    private Boolean canUserAccessRecipe(Integer userId, Recipe recipe) {
        // recipe belongs to logged in user
        if (recipe.getOwnerId().equals(userId)) {
            return true;
        }
        // recipe in community repository
        if (recipe.getIsCommunityPublished()) {
            return true;
        }
        // recipe in a shared vault that user belongs to
        List<VaultFolderRecipe> placements = vaultFolderRecipeRepository.findByRecipe_RecipeId(recipe.getRecipeId());
        for (VaultFolderRecipe placement : placements) {
            Vault vault = placement.getFolder().getVault();
            boolean isOwner = vault.getOwnerId().equals(userId);
            boolean isMember = vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(vault.getVaultId(), userId);
            if (isOwner || isMember) {
                return true;
            }
        }
        return false;
    }

    // PUT request - update all items purchased flag to true (select all items in list on frontend)
    @Transactional
    public ShoppingListWithItemsResponse selectAllItemsAsPurchased(Integer userId, Integer shoppingListId) {
        // get shopping list and check ownership
        ShoppingList selectedList = shoppingListRepository.findById(shoppingListId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        if(!selectedList.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list");
        }

        List<ShoppingListItem> items = shoppingListItemRepository.findByShoppingListId(shoppingListId);

        for (ShoppingListItem item : items) {
            item.setPurchased(true);
            shoppingListItemRepository.save(item);
        }

        List<ShoppingListItemResponse> itemsToSave = shoppingListItemRepository.getSpecificShoppingListItems(shoppingListId);

        return new ShoppingListWithItemsResponse(
            selectedList.getShoppingListId(),
            selectedList.getUserId(),
            selectedList.getName(),
            selectedList.getStatus(),
            selectedList.getCreatedAt(),
            itemsToSave.size(),
            itemsToSave
        );
    }

    // PUT request - update all items purchased flag to false (deselect all items in list on frontend)
    @Transactional
    public ShoppingListWithItemsResponse deselectAllItemsAsPurchased(Integer userId, Integer shoppingListId) {
        // get shopping list and check ownership
        ShoppingList selectedList = shoppingListRepository.findById(shoppingListId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        if(!selectedList.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list");
        }

        List<ShoppingListItem> items = shoppingListItemRepository.findByShoppingListId(shoppingListId);
                               
        for (ShoppingListItem item : items) {
            item.setPurchased(false);
            shoppingListItemRepository.save(item);
        }

        List<ShoppingListItemResponse> itemsToSave = shoppingListItemRepository.getSpecificShoppingListItems(shoppingListId);

        return new ShoppingListWithItemsResponse(
            selectedList.getShoppingListId(),
            selectedList.getUserId(),
            selectedList.getName(),
            selectedList.getStatus(),
            selectedList.getCreatedAt(),
            itemsToSave.size(),
            itemsToSave
        );
    }


    // PUT request - automatically removes items with purchased flag set to true from shopping list and inserts them into pantry (upon clicking update pantry button)
    @Transactional
    public CompleteShopResponse autoAddToPantryRemoveFromList(Integer userId, Integer shoppingListId) {
        // get shopping list and check ownership
        ShoppingList selectedList = shoppingListRepository.findById(shoppingListId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Shopping list not found"));

        if(!selectedList.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "You do not own this shopping list");
        }

        // find all items where purchased flag is true - list can be empty so if not found don't throw error
        List<ShoppingListItem> items = shoppingListItemRepository.findByShoppingListId(shoppingListId);
        
        Integer addedToPantryCount = 0;
        List<String> skippedManualItemNames = new ArrayList<>();
        
        for (ShoppingListItem item : items) {
            // if ing_id is false don't add to pantry
            if (item.getPurchased()) {
                if (item.getIngId() != null) {
                    // don't mearge pantry ingredients - need separate entries for the createdAt date for freshness purposes
                    PantryIngredient newPantryItem = new PantryIngredient();
                    newPantryItem.setUserId(userId);
                    newPantryItem.setIngredientId(item.getIngId());
                    newPantryItem.setQuantity(item.getQuantity());
                    newPantryItem.setUnit(item.getUnit());
                    pantryIngredientRepository.save(newPantryItem);
                    addedToPantryCount++;
                }
                else {
                    skippedManualItemNames.add(item.getName());
                }
                // remove item from shopping list
                shoppingListItemRepository.delete(item);
            }
        }

        List<ShoppingListItem> remainingItems = shoppingListItemRepository.findByShoppingListId(shoppingListId);
        Boolean shoppingListDeleted = false;

        if (remainingItems.isEmpty()) {
            shoppingListDeleted = true;
            shoppingListRepository.delete(selectedList);
        }

        return new CompleteShopResponse(
            addedToPantryCount,
            skippedManualItemNames,
            shoppingListDeleted
        );
    }
}