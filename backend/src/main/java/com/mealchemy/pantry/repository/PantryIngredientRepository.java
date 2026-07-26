package com.mealchemy.pantry.repository;

import com.mealchemy.pantry.model.PantryIngredient;
import com.mealchemy.pantry.dto.PantryIngredientResponse;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface PantryIngredientRepository extends JpaRepository<PantryIngredient, Integer> {
    // user defined queries

    // pantry ingredients needed per user
    List<PantryIngredient> findByUserId(Integer userId);

    List<PantryIngredient> findByIngId(Integer ingId);

    @Query("""
        SELECT new com.mealchemy.pantry.dto.PantryIngredientResponse(
            p.pIngredientId,
            p.ingId,
            c.name,
            cat.name,
            p.quantity,
            p.unit,
            p.createdAt,
            p.updatedAt
        )
        FROM PantryIngredient p
        JOIN IngredientCatalogue c ON p.ingId = c.ingId
        JOIN IngredientCategory cat ON c.categoryId = cat.categoryId
        WHERE p.userId = :userId
    """)
    List<PantryIngredientResponse> findPantryIngredientsByUserId(@Param("userId") Integer userId);

    
    @Query("""
        SELECT new com.mealchemy.pantry.dto.PantryIngredientResponse(
            p.pIngredientId,
            p.ingId,
            c.name,
            cat.name,
            p.quantity,
            p.unit,
            p.createdAt,
            p.updatedAt
        )
        FROM PantryIngredient p
        JOIN IngredientCatalogue c ON p.ingId = c.ingId
        JOIN IngredientCategory cat ON c.categoryId = cat.categoryId
        WHERE p.userId = :userId AND LOWER(c.name) LIKE LOWER(CONCAT('%', :name, '%'))
    """)
    List<PantryIngredientResponse> getIngredientByName(@Param("userId") Integer userId, @Param("name") String name);
    
}
