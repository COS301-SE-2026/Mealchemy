// talks to ingredient_catalogue db table

package com.mealchemy.nutritionalcalculator.repository;
import com.mealchemy.nutritionalcalculator.dto.RecipeIngredientNutrition;

import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.recipe.model.RecipeIngredient;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface NutritionalCalculatorRepository extends JpaRepository<RecipeIngredient, Integer> {
    @Query("""
            SELECT new com.mealchemy.nutritionalcalculator.dto.RecipeIngredientNutrition(
                c.ingId,
                c.name,
                r.quantity,
                r.unit,
                c.caloriesKCal,
                c.proteinG,
                c.carbsG,
                c.fatG,
                c.fibreG,
                c.sodiumMg
            )
            FROM RecipeIngredient r 
            JOIN IngredientCatalogue c ON r.ingId = c.ingId
            WHERE r.recipe.recipeId = :recipeId
            """)
    List<RecipeIngredientNutrition> getRecipeIngredientsNutrition(@Param("recipeId") Integer recipeId);

}