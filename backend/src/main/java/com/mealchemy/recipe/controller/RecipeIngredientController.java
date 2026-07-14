package com.mealchemy.recipe.controller;

/* Import libraries */

import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */

import com.mealchemy.recipe.dto.RecipeIngredientRequest;
import com.mealchemy.recipe.dto.RecipeIngredientResponse;
import com.mealchemy.recipe.service.RecipeIngredientService;

@RestController
@RequestMapping("/ingredients")
public class RecipeIngredientController
{
    private final RecipeIngredientService recipeIngredientService;

    public RecipeIngredientController(RecipeIngredientService recipeIngredientService)
    {
        this.recipeIngredientService = recipeIngredientService;
    }

    /* Mapping functions */

    // Post
    @PostMapping("/recipe/{recipeId}/create")
    public RecipeIngredientResponse createRecipeIngredient(@Valid @RequestBody RecipeIngredientRequest request, @PathVariable Integer recipeId, 
        @AuthenticationPrincipal String ownerId)
    {
        return recipeService.createRecipeIngredient(request, recipeId, Integer.parseInt(ownerId));
    }

    // Put
    @PutMapping("/recipe/{recipeId}/step/{id}/edit")
    public RecipeIngredientResponse updateRecipeIngredient(@PathVariable int id, @Valid @RequestBody RecipeIngredientResponse request, 
        @PathVariable Integer recipeId, @AuthenticationPrincipal String ownerId)
    {
        return recipeService.updateRecipeIngredient(id, request, recipeId, Integer.parseInt(ownerId));
    }
}