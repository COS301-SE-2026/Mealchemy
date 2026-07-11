package com.mealchemy.pantry.repository;

import com.mealchemy.pantry.model.PantryIngredient;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;

public class PantryIngredientRepository {
    List<PantryIngredient> findByPIngredientId(Integer pIngredientId);

    // user defined queries
    
    // pantry ingredients needed per user
    List<PantryIngredient> findByUserId(Integer userId);
    
}
