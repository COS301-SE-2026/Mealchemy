package com.mealchemy.ingredient.controller;

// import dtos
import com.mealchemy.ingredient.dto.*;
// import services
import com.mealchemy.ingredient.service.*;
// for jwt token
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;



@RestController
@RequestMapping("/api/ingredient-catalogue") 
public class IngredientCatalogueController {

    private final IngredientCatalogueService ingredientCatalogueService;

    public IngredientCatalogueController(IngredientCatalogueService ingredientCatalogueService) {
        this.ingredientCatalogueService = ingredientCatalogueService;
    }

    // get all ingredients in catalogue mapping
    @GetMapping("")
    public ResponseEntity<List<IngredientCatalogueResponse>> getIngredientCatalogue(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(ingredientCatalogueService.getIngredientCatalogue());
    }

    // user searching for ingredient by name
    @GetMapping("/search")
    public ResponseEntity<List<IngredientSearchResponse>> searchIngredientCatalogueByName(@AuthenticationPrincipal String userId, @RequestParam("q") String query) {
        return ResponseEntity.ok(ingredientCatalogueService.getIngredientByName(query));
    }

    @PostMapping("/add-external")
    public ResponseEntity<?> addExternalIngredient(@AuthenticationPrincipal String userId, @RequestBody AddExternalIngredientToCatalogueRequest request) {
        try {
            IngredientCatalogueResponse saved = ingredientCatalogueService.saveExternalIngredientToCatalogue(request.sourceId(), request.categoryId());
            return ResponseEntity.ok(saved);
        }
        catch (CategoryRequiredException e) {
            IngredientPendingResponse pending = new IngredientPendingResponse(e.getSourceId(), e.getName());
            return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(pending);
        }
    }
}