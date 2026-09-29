// talks to flagged_recipes db table

package com.mealchemy.moderation.repository;

import com.mealchemy.moderation.model.FlaggedRecipe;

import com.mealchemy.shared.enums.FlagStatus;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;


public interface FlaggedRecipeRepository extends JpaRepository<FlaggedRecipe, Integer> {
    
    List<FlaggedRecipe> findByStatus(FlagStatus status); //admin queue

    boolean existsByRecipeIdAndUserIdAndStatus(Integer recipeId, Integer userId, FlagStatus status);

    List<FlaggedRecipe> findByRecipeIdAndReasonAndStatus(Integer recipeId, String reason, FlagStatus status);
}
