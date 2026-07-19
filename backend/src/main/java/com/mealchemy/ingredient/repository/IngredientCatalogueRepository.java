// talks to ingredient_catalogue db table

package com.mealchemy.ingredient.repository;

import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.ingredient.dto.IngredientCatalogueResponse;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface IngredientCatalogueRepository extends JpaRepository<IngredientCatalogue, Integer> {
    @Query("""
            SELECT new com.mealchemy.ingredient.dto.IngredientCatalogueResponse(
                c.ingId,
                c.name,
                cat.name
            )
            FROM IngredientCatalogue c
            JOIN IngredientCategory cat ON c.categoryId = cat.categoryId
            """)
    List<IngredientCatalogueResponse> getIngredientCatalogueItems();

    @Query("""
        SELECT new com.mealchemy.ingredient.dto.IngredientCatalogueResponse(
            c.ingId,
            c.name,
            cat.name
        )
        FROM IngredientCatalogue c
        JOIN IngredientCategory cat ON c.categoryId = cat.categoryId
        WHERE LOWER(c.name) LIKE LOWER(CONCAT('%', :name, '%'))
    """)
    List<IngredientCatalogueResponse> getIngredientByName(@Param("name") String name);
}
