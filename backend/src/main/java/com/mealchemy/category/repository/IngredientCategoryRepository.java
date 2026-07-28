// talks to ingredient_categories db table
package com.mealchemy.category.repository;

import com.mealchemy.pantry.dto.PantryIngredientResponse;
import com.mealchemy.category.model.IngredientCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface IngredientCategoryRepository extends JpaRepository<IngredientCategory, Integer> {
    // built-in types


    
}
