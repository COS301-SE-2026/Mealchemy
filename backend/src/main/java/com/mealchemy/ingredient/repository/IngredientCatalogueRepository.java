// talks to ingredient_catalogue db table

package com.mealchemy.ingredient.repository;

import com.mealchemy.ingredient.model.IngredientCatalogue;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface IngredientCatalogueRepository extends JpaRepository<IngredientCatalogue, Integer> {
    // when using ingredients catalogue - usually fininding ingredients by name
    List<IngredientCatalogue> findByNameContaining(String name);
}
