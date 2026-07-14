package com.mealchemy.recipe.controller;

/* Import libraries */

import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */

import com.mealchemy.recipe.dto.RecipeStepRequest;
import com.mealchemy.recipe.dto.RecipeStepResponse;
import com.mealchemy.recipe.service.RecipeStepService;

@RestController
@RequestMapping("/steps")
public class RecipeStepController
{
    private final RecipeStepService recipeStepService;
    
    public RecipeStepController(RecipeStepService recipeStepService)
    {
        this.recipeStepService = recipeStepService;
    }

    /* Mapping functions */

    // Post
    @PostMapping("/recipe/{recipeId}/step/create")
    public RecipeStepResponse createRecipeStep(@Valid @RequestBody RecipeStepRequest request, @PathVariable Integer recipeId, 
        @AuthenticationPrincipal String ownerId)
    {
        return recipeStepService.createRecipeStep(request, recipeId, Integer.parseInt(ownerId));
    }
}