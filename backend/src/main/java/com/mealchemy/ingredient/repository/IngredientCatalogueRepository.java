// talks to ingredient_catalogue db table

package com.mealchemy.ingredient.repository;

import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.ingredient.dto.IngredientCatalogueResponse;
import com.mealchemy.ingredient.dto.IngredientSearchResponse;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

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
        SELECT new com.mealchemy.ingredient.dto.IngredientSearchResponse(
            c.ingId,
            c.name,
            cat.name,
            null,
            null
        )
        FROM IngredientCatalogue c
        JOIN IngredientCategory cat ON c.categoryId = cat.categoryId
        WHERE LOWER(c.name) LIKE LOWER(CONCAT('%', :name, '%'))
    """)
    List<IngredientSearchResponse> getIngredientByName(@Param("name") String name);

    // exact match lookup - use to prevent concurrent saves
    Optional<IngredientCatalogue> findByName(String name);

    @Query("""
        SELECT c.name FROM IngredientCatalogue c WHERE c.name IN :names
    """)
    List<String> findExistingNames(@Param("names") List<String> names);
}
