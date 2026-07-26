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

    // Get
    @GetMapping("/recipe/{recipeId}")
    {
        public List<RecipeIngredientResponse> getAllIngredientsByRecipeId(@PathVariable Integer recipeId)
        {
            return recipeStepService.getAllIngredientsByRecipeId(recipeId);
        }
    }

    // Get
    @GetMapping("/recipe/{recipeId}")
    public List<RecipeIngredientResponse> getIngredientsByRecipeId(@PathVariable Integer recipeId)
    {
        return recipeIngredientService.getIngredientsByRecipeId(recipeId);
    }

    // Post
    @PostMapping("/recipe/{recipeId}/ingredient/create")
    public RecipeIngredientResponse createRecipeIngredient(@Valid @RequestBody RecipeIngredientRequest request, @PathVariable Integer recipeId, 
        @AuthenticationPrincipal String ownerId)
    {
        return recipeIngredientService.createRecipeIngredient(request, recipeId, Integer.parseInt(ownerId));
    }

    // Put
    @PutMapping("/recipe/{recipeId}/ingredient/{id}/edit")
    public RecipeIngredientResponse updateRecipeIngredient(@PathVariable int id, @Valid @RequestBody RecipeIngredientRequest request, 
        @PathVariable Integer recipeId, @AuthenticationPrincipal String ownerId)
    {
        return recipeIngredientService.updateRecipeIngredient(id, request, recipeId, Integer.parseInt(ownerId));
    }

    // Delete
    @DeleteMapping("/recipe/{recipeId}/ingredient/{id}/delete")
    public void deleteRecipeIngredient(@PathVariable int id, @PathVariable Integer recipeId, @AuthenticationPrincipal String ownerId)
    {
        recipeIngredientService.deleteRecipeIngredient(id, recipeId, Integer.parseInt(ownerId));
    }
}