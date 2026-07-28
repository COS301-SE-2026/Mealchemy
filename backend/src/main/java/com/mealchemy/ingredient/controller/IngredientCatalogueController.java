package com.mealchemy.ingredient.controller;

// import dtos
import com.mealchemy.ingredient.dto.*;
// import services
import com.mealchemy.ingredient.service.*;
// for jwt token
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import java.util.List;
import org.springframework.http.ResponseEntity;
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
    public ResponseEntity<List<IngredientCatalogueResponse>> searchIngredientCatalogueByName(@AuthenticationPrincipal String userId, @RequestParam("q") String query) {
        return ResponseEntity.ok(ingredientCatalogueService.getIngredientByName(query));
    }

}