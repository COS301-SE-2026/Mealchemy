// talks to ingredient_categories db table
package com.mealchemy.category.repository;

import com.mealchemy.category.model.IngredientCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface IngredientCategoryRepository extends JpaRepository<IngredientCategory, Integer> {
    // built-in types

    @Query("""
        SELECT c FROM IngredientCategory c
        WHERE LOWER(c.name) LIKE LOWER(CONCAT('%', :name, '%'))
    """)
    List<IngredientCategory> findByCatNameFuzzy(@Param("name") String name);
  
}
