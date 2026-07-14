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
}