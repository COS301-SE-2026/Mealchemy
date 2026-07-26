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

    // Get
    @GetMapping("/recipe/{recipeId}")
    {
        public List<RecipeStepResponse> getAllStepsByRecipeId(@PathVariable Integer recipeId)
        {
            return recipeStepService.getAllStepsByRecipeId(recipeId);
        }
    }

    // Get
    @GetMapping("/recipe/{recipeId}")
    public List<RecipeStepResponse> getAllStepsByRecipeId(@PathVariable Integer recipeId)
    {
        return recipeStepService.getAllStepsByRecipeId(recipeId);
    }

    // Post
    @PostMapping("/recipe/{recipeId}/step/create")
    public RecipeStepResponse createRecipeStep(@Valid @RequestBody RecipeStepRequest request, @PathVariable Integer recipeId, 
        @AuthenticationPrincipal String ownerId)
    {
        return recipeStepService.createRecipeStep(request, recipeId, Integer.parseInt(ownerId));
    }

    // Put
    @PutMapping("/recipe/{recipeId}/step/{id}/edit")
    public RecipeStepResponse updateRecipeStep(@PathVariable int id, @Valid @RequestBody RecipeStepRequest request, 
        @PathVariable Integer recipeId, @AuthenticationPrincipal String ownerId)
    {
        return recipeStepService.updateRecipeStep(id, request, recipeId, Integer.parseInt(ownerId));
    }

    // Put
    @PutMapping("/recipe/{recipeId}/reorder")
    public List<RecipeStepResponse> reorderSteps(@PathVariable Integer recipeId, @Valid @RequestBody RecipeStepReorderRequest request,
    @AuthenticationPrincipal String ownerId)
    {
        return recipeStepService.reorderSteps(recipeId, request, Integer.parseInt(ownerId));
    }

    // Delete
    @DeleteMapping("/recipe/{recipeId}/step/{id}/delete")
    public void deleteRecipeStep(@PathVariable int id, @PathVariable Integer recipeId, @AuthenticationPrincipal String ownerId)
    {
        recipeStepService.deleteRecipeStep(id, recipeId, Integer.parseInt(ownerId));
    }
}