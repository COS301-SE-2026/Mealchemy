package com.mealchemy.category.controller;

// import dtos
import com.mealchemy.category.dto.*;
// import services
import com.mealchemy.category.service.*;

import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/categories") 
public class IngredientCategoryController {

    private final IngredientCategoryService ingredientCategoryService;

    public IngredientCategoryController(IngredientCategoryService ingredientCategoryService) {
        this.ingredientCategoryService = ingredientCategoryService;
    }

    
    // get mapping - get all ingredient categories options for frontend to display
    @GetMapping("")
    public ResponseEntity<List<IngredientCategoryResponse>> getAllIngredientCategories() {
        return ResponseEntity.ok(ingredientCategoryService.getAllIngredientCategoryOptions());
    }
}
