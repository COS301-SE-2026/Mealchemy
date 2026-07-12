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

    @Query("""
        SELECT new com.mealchemy.pantry.dto.PantryIngredientResponse(
            p.pIngredientId,
            p.ingId,
            c.name,
            cat.name,
            p.quantity,
            p.unit,
            p.createdAt,
            p.updtaedAt
        )
        FROM PantryIngredient p
        JOIN IngredientCatalogue c ON p.ingId = c.ingId
        JOIN IngredientCategory cat ON c.categoryId = cat.categoryId
        WHERE p.userId = :userId
    """)
    List<PantryIngredientResponse> findPantryIngredientsByUserId(@Param("userId") Integer userId);
    
}
