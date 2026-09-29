package com.mealchemy.recipe.repository;

/* Import libraries */

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
// import java.util.*;

/* Import classes */

import com.mealchemy.recipe.model.RecipeEquipment;
import java.util.*;

@Repository
public interface RecipeEquipmentRepository extends JpaRepository<RecipeEquipment, Integer>
{
    List<RecipeEquipment> findByRecipe_RecipeId(Integer recipeId); 

    void deleteByRecipe_RecipeId(Integer recipeId);
}