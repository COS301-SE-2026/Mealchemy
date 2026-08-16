package com.mealchemy.recipe.controller;

/* Import libraries */

import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */

import com.mealchemy.recipe.dto.RecipeRequest;
import com.mealchemy.recipe.dto.RecipeFullRequest;
import com.mealchemy.recipe.dto.RecipePhotoUploadRequest;
import com.mealchemy.recipe.dto.RecipePhotoUploadResponse;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.recipe.service.RecipePhotoService;
import com.mealchemy.recipe.service.RecipeService;

@RestController
@RequestMapping("/recipes")
public class RecipeController
{
    private final RecipeService recipeService;
    private final RecipePhotoService recipePhotoService;

    public RecipeController(RecipeService recipeService, RecipePhotoService recipePhotoService)
    {
        this.recipeService = recipeService;
        this.recipePhotoService = recipePhotoService;
    }

    /* Mapping functions */

    // Get
    // changed to receive the authenticated user ID
    @GetMapping("/all")
    public List<RecipeResponse> getAllRecipes(@AuthenticationPrincipal String userId)
    {
        return recipeService.getAllRecipes(Integer.parseInt(userId));
    }

    // Get
    @GetMapping("/community")
    public List<RecipeResponse> getAllCommunityPublishedRecipes()
    {
        return recipeService.getAllCommunityPublishedRecipes();
    }

    // Get
    // changed to receive the authenticated user ID
    @GetMapping("/single/{id}")
    public RecipeResponse getRecipeById(@PathVariable Integer id, @AuthenticationPrincipal String userId)
    {
        return recipeService.getRecipeById(id, Integer.parseInt(userId));
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

    // Post
    // gets recipe id from path, validates reuqest dto, gets authenticated user id, returns signed upload info.
    @PostMapping("/{id}/photo-upload-url")
    public RecipePhotoUploadResponse createPhotoUploadUrl(
        @PathVariable Integer id,
        @Valid @RequestBody RecipePhotoUploadRequest request,
        @AuthenticationPrincipal String ownerId
    )
    {
        return recipePhotoService.createPhotoUploadUrl(
            id,
            request,
            Integer.parseInt(ownerId)
        );
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
