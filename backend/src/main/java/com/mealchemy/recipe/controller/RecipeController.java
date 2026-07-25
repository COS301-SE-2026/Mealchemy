package com.mealchemy.recipe.controller;

/* Import libraries */

import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */

import com.mealchemy.recipe.dto.RecipeRequest;
import com.mealchemy.recipe.dto.RecipeFullRequest;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.recipe.service.RecipeService;

@RestController
@RequestMapping("/recipes")
public class RecipeController
{
    private final RecipeService recipeService;

    public RecipeController(RecipeService recipeService)
    {
        this.recipeService = recipeService;
    }

    /* Mapping functions */

    // Get
    @GetMapping("/all")
    public List<RecipeResponse> getAllRecipes()
    {
        return recipeService.getAllRecipes();
    }

    // Get
    @GetMapping("/community")
    public List<RecipeResponse> getAllCommunityPublishedRecipes()
    {
        return recipeService.getAllCommunityPublishedRecipes();
    }

    // Get
    @GetMapping("/single/{id}")
    public RecipeResponse getRecipeById(@PathVariable Integer id)
    {
        return recipeService.getRecipeById(id);
    }

    // Post
    @PostMapping("/create")
    public RecipeResponse createRecipe(@Valid @RequestBody RecipeRequest request, @AuthenticationPrincipal String ownerId)
    {
        return recipeService.createRecipe(request, Integer.parseInt(ownerId));
    }

    // Post
    @PostMapping("/{sourceId}/copy")
    public RecipeResponse createFromFullRecipe(@Valid @RequestBody RecipeFullRequest request, @AuthenticationPrincipal String ownerId, @PathVariable Integer sourceId)
    {
        return recipeService.createFromFullRecipe(request, Integer.parseInt(ownerId), sourceId);
    }

    // Put
    @PutMapping("/edit/{id}")
    public RecipeResponse updateRecipe(@PathVariable int id, @Valid @RequestBody RecipeRequest request, @AuthenticationPrincipal String ownerId)
    {
        return recipeService.updateRecipe(id, request, Integer.parseInt(ownerId));
    }

    // Delete
    @DeleteMapping("/delete/{id}")
    public void deleteRecipe(@PathVariable int id, @AuthenticationPrincipal String ownerId)
    {
        recipeService.deleteRecipe(id, Integer.parseInt(ownerId));
    }
}