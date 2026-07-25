package com.mealchemy.recipe.repository;

/* Import libraries */

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
// import java.util.*;

/* Import classes */

import com.mealchemy.recipe.model.RecipeStep;

@Repository
public interface RecipeStepRepository extends JpaRepository<RecipeStep, Integer>
{
    List<RecipeStep> findByRecipe_RecipeId(Integer recipeId); 
}