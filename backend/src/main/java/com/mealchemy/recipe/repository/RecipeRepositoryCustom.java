package com.mealchemy.recipe.repository;

import java.util.List;
import java.util.Optional;

import com.mealchemy.recipe.model.Recipe;

public interface RecipeRepositoryCustom
{
    List<Recipe> findAllAccessibleByUserId(Integer userId);
    Optional<Recipe> findAccessibleByIdAndUserId(Integer recipeId, Integer userId);
}
