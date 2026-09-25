package com.mealchemy.recipe.service;

import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

import com.mealchemy.recipe.dto.RecipeEquipmentResponse;
import com.mealchemy.recipe.repository.RecipeEquipmentRepository;
import com.mealchemy.recipe.repository.RecipeRepository;

@Service
public class RecipeEquipmentService
{
    private final RecipeEquipmentRepository recipeEquipmentRepository;
    private final RecipeRepository recipeRepository;
    
    public RecipeEquipmentService(RecipeEquipmentRepository recipeEquipmentRepository, RecipeRepository recipeRepository)
    {
        this.recipeEquipmentRepository = recipeEquipmentRepository;
        this.recipeRepository = recipeRepository;
    }

    public List<RecipeEquipmentResponse> getAllEquipmentByRecipeId(Integer recipeId, Integer userId)
    {
        recipeRepository.findAccessibleByIdAndUserId(recipeId, userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));
        
        return recipeEquipmentRepository.findByRecipe_RecipeId(recipeId).stream().map(RecipeEquipmentResponse::from).collect(Collectors.toList());
    }
}